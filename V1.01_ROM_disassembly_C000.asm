    org 0xc000

PUBLIC _main
    ; Interrupt Vector Table (?)
    ; This looks like one
_main:
    jp      $c030                           ;[c000] reset vector
    jp      $c027                           ;[c003] reset SIO interrupts
    jp      $c027                           ;[c006] reset SIO interrupts
    jp      $c45e                           ;[c009] putchar()
    jp      $c027                           ;[c00c] reset SIO interrupts
    jp      $c027                           ;[c00f] reset SIO interrupts
    jp      $c027                           ;[c012] reset SIO interrupts
    jp      $c027                           ;[c015] reset SIO interrupts
    jp      fdc_rwfs_c19d                   ;[c018] floppy disk software driver
    jp      putstr                          ;[c01b] print null-terminated string
    jp      prhex                           ;[c01e] print a byte as hex
    jp      $cde2                           ;[c021]
    jp      $cdf4                           ;[c024]

    ; disable SIO interrupts
label_c027:
    di                                      ;[c027] disable interrupts
    ld      a,$10                           ;[c028] load A with $10 (reset SIO interrupts)
    out     ($b1),a                         ;[c02a] write SIO control of channel A
    out     ($b3),a                         ;[c02c] write SIO control of channel B
    jr      label_c040                      ;[c02e]

    ; main entrypoint, after reset

    ; setup uPD8255 (GPIO IC)
    ; - set PORTA as output (not connected ?)
    ; - set PORTB as output (bank switching ?)
    ; - set PORTC as input (both high and low nibble) (bit 1 = used by something unknown, bit 2 = floppy related)
    ; - set all ports to Mode 0 (latched outputs, not-latched inputs)
    ld      a,$89                           ;[c030] load configuration in A
    out     ($83),a                         ;[c032] write configuration

    di                                      ;[c034] disable interrupts

    ld      a,$10                           ;[c035]
    out     ($81),a                         ;[c037] PORTB = 0x10 (bank 4 in)

    ; delay, measured oscilloscope 208 ms
    ld      h,$7d                           ;[c039] hl = $7d
label_c03b:
    dec     hl                              ;[c03b]
    ld      a,h                             ;[c03c]
    or      l                               ;[c03d] check for hl == 0
    jr      nz,label_c03b                   ;[c03e]

label_c040:
    ld      sp,$0080                        ;[c040] setup stack pointer
    call    $c0c2                           ;[c043] initialize IO peripherals
    call    $c6af                           ;[c046] initialize display management variables
    call    $c14e                           ;[c049] bios_copy_to_ram()
    ld      a,$12                           ;[c04c] load A with $12 (keyboard initialization)
    out     ($b2),a                         ;[c04e] send keyboard configuration
label_c050:
    in      a,($b3)                         ;[c050]
    bit     0,a                             ;[c052]
    jr      z,label_c050                    ;[c054]
    in      a,($b2)                         ;[c056] read A from keyboard
    out     ($da),a                         ;[c058] sound speaker beep
    ld      c,$56                           ;[c05a] hardcoded 'V' for splash screen
    call    $c45e                           ;[c05c] putchar()
    ld      hl,$cffc                        ;[c05f] "Splash screen" string pointer
    ld      b,$04                           ;[c062]
label_c064:
    ld      c,(hl)                          ;[c064] for (b = 4; b > 0; --b) {
    inc     hl                              ;[c065]
    call    $c45e                           ;[c066]     putchar()
    djnz    label_c064                      ;[c069] } loop

    ; Boot procedure: execute a routine associated to a keypress
    ; - if BOOT, execute bios_bootkey
    ; - if F15, execute bios_boot_from_8000
bios_waitkey:
    call    kbd_getchar                     ;[c06b] kbd_getchar()
    ld      a,b                             ;[c06e]
    cp      $4d                             ;[c06f]
    jr      z,bios_bootkey                  ;[c071] jump if kbd_getchar() == $4D (BOOT key)
    cp      $5c                             ;[c073]
    jr      nz,bios_waitkey                 ;[c075] repeat if kbd_getchar() != $5C (F15)

    ; Boot trampoline executed when F15 key is pressed
    ; Check signature: trampoline is identified by a magic $3C
bios_boot_from_8000:
    ld      a,($8000)                       ;[c077] a = (*$8000)
    cpl                                     ;[c07a] a = ~a
    ld      ($8000),a                       ;[c07b] write back...
    ld      a,($8000)                       ;[c07e] ...and read again
    cp      $c3                             ;[c081] check if equal to $C3 (which is absolute JMP opcode)
    jr      nz,label_c027                   ;[c083] if not, reset computer...
    jp      $8000                           ;[c085] ...else, execute trampoline at $8000

    ; Boot trampoline executed when BOOT key is pressed
bios_bootkey:
    ld      de,$0000                        ;[c088] d = track = 0; e = sector = 0
    ld      bc,$4000                        ;[c08b] b = cmd = read ($40); c = drive = 0
    ld      hl,$0080                        ;[c08e] load in $0080
    ld      a,$01                           ;[c091] formatting mode, seems to be 384 bytes per sector
    call    fdc_rwfs_c19d                   ;[c093] invoke reading
    cp      $ff                             ;[c096] check for error...
    jr      nz,bios_bootdisk                ;[c098] ...if ok, go on with loading
    out     ($da),a                         ;[c09a] ... else, beep and try again
    jr      bios_bootkey                    ;[c09c]
    ; if disk has been correctly copied into RAM, execute it
bios_bootdisk:
    ld      a,$06                           ;[c09e] load A with $06
    out     ($b2),a                         ;[c0a0] send to keyboard
    out     ($da),a                         ;[c0a2] sound speaker beep
    jp      $0080                           ;[c0a4] execute fresh code from ram

    ; SUBROUTINE C0A7: kbd_getchar()
    ; Read from keyboard
    ; Returns in (B,C) = (first,second)

    ;    |-----------------------|
    ; BC | 0xxx xxxx | 1xxx xxxx |
    ;    |-----------------------|

    ; When no keyboard is connected, Sanco loops in this loop forever
kbd_getchar:
    in      a,($b3)                         ;[c0a7] read SIO control register of channel B (keyboard)
    bit     0,a                             ;[c0a9] test LSB (character available)
    jr      z,kbd_getchar                   ;[c0ab] if no char available, loop

    ; a char is available from keyboard
    in      a,($b2)                         ;[c0ad] read A from keyboard
    ld      b,a                             ;[c0af]
    bit     7,a                             ;[c0b0]
    jr      nz,kbd_getchar                  ;[c0b2] if A >= 128, discard char and read next one
label_c0b4:
    in      a,($b3)                         ;[c0b4] read SIO control register of channel B (keyboard)
    bit     0,a                             ;[c0b6]
    jr      z,label_c0b4                    ;[c0b8] if no char available, loop

    in      a,($b2)                         ;[c0ba] read A from keyboard
    ld      c,a                             ;[c0bc]
    bit     7,a                             ;[c0bd]
    jr      z,label_c0b4                    ;[c0bf] if A < 128, discard char and read next one
    ret                                     ;[c0c1] (B,C) now holds (first,second) char read from keyboard

    ; SUBROUTINE C0C2
    im      2                               ;[c0c2] set interrupt mode 2
    call    $c0d1                           ;[c0c4] initialize timer ($e0)
    call    fdc_init                        ;[c0c7] initialize floppy drive controller ($c0)
    call    $c108                           ;[c0ca] setup SIO ($b0 peripheral)
    call    $c88d                           ;[c0cd] setup CRTC ($a0) and do some stuff with bank switch? ($80)
    ret                                     ;[c0d0]

    ; SUBROUTINE C0D1; initialize timer (base ioaddr(0xE0))
    ld      hl,$c0f1                        ;[c0d1] ; initialization table base address
label_c0d4:
    ld      a,(hl)                          ;[c0d4]
    inc     hl                              ;[c0d5]
    cp      $ff                             ;[c0d6] check for initialization table end
    jr      z,label_c0e1                    ;[c0d8] if table is ended, go on
    ld      c,a                             ;[c0da]
    ld      a,(hl)                          ;[c0db]
    inc     hl                              ;[c0dc]
    out     (c),a                           ;[c0dd]
    jr      label_c0d4                      ;[c0df] loop table

label_c0e1:
    in      a,($d6)                         ;[c0e1] read index ("$06")
    and     $07                             ;[c0e3] clamp in interval [0;7]
    ld      d,$00                           ;[c0e5]
    ld      e,a                             ;[c0e7]
    add     hl,de                           ;[c0e8] hl += "$06"
    ld      a,(hl)                          ;[c0e9] timer 1: time constant ("$02")
    out     ($e1),a                         ;[c0ea]
    ld      a,$41                           ;[c0ec] timer 1: select counter mode
    out     ($e1),a                         ;[c0ee]
    ret                                     ;[c0f0]

    ; STATIC DATA for C0D1
    ; timer 2: configuration
    BYTE $e2
    BYTE $05
    ; timer 2: time constant
    BYTE $e2
    BYTE $10
    ; timer 2: select counter mode
    BYTE $e2
    BYTE $41
    ; timer 3: configuration
    BYTE $e3
    BYTE $05
    ; timer 3: time constant
    BYTE $e3
    BYTE $01
    ; timer 3: select counter mode
    BYTE $e3
    BYTE $41
    ; timer 1: configuration
    BYTE $e1
    BYTE $05
    ; terminator
    BYTE $ff

    ; probably another table
    ; len = 8, deduced from what happens at C0E3
    ; this could be some prescaler for timer1
    BYTE $ae                                 ;[c100]
    BYTE $40                                 ;[c101]
    BYTE $20                                 ;[c102]
    BYTE $10                                 ;[c103]
    BYTE $08                                 ;[c104]
    BYTE $04                                 ;[c105]
    BYTE $02                                 ;[c106]
    BYTE $01                                 ;[c107]

    ; SIO configuration routine
    ; Channel A runs at 153.6 kHz / 16 = 9600 bps (user RS/232)
    ; Channel B runs at 19.2 kHz / 16 = 1200 bps  (keyboard)
    ; $b0   : channel A, data register
    ; $b1   : channel A, control register
    ; $b2   : channel B, data register
    ; $b3   : channel B, control register
    ld      hl,$c134                        ;[c108]

    ; loop around $c134 table, writing to $b1 (channel A)
label_c10b:
    ld      a,(hl)                          ;[c10b] load index of internal SIO register
    inc     hl                              ;[c10c] fetch next data
    cp      $ff                             ;[c10d] check table end
    jr      z,label_c119                    ;[c10f] if table end, configure channel B
    out     ($b1),a                         ;[c111] index internal SIO register
    ld      a,(hl)                          ;[c113] load desired internal SIO register value
    out     ($b1),a                         ;[c114] write desidered internal SIO register value
    inc     hl                              ;[c116] fetch next data
    jr      label_c10b                      ;[c117] loop

    ; loop around $c141 table, writing to $b3 (channel B)
    ; same as channel A
label_c119:
    ld      a,(hl)                          ;[c119]
    cp      $ff                             ;[c11a]
    jr      z,label_c127                    ;[c11c]
    out     ($b3),a                         ;[c11e]
    inc     hl                              ;[c120]
    ld      a,(hl)                          ;[c121]
    out     ($b3),a                         ;[c122]
    inc     hl                              ;[c124]
    jr      label_c119                      ;[c125]

    ; Each SIO channel has a 3 word RX FIFO: flush them.
label_c127:
    in      a,($b0)                         ;[c127] read channel A data register (and discard)
    in      a,($b2)                         ;[c129] read channel B data register (and discard)
    in      a,($b0)                         ;[c12b]
    in      a,($b2)                         ;[c12d]
    in      a,($b0)                         ;[c12f]
    in      a,($b2)                         ;[c131]
    ret                                     ;[c133]

    ; Configuration table for SIO ChA?
sio_chA_cfg_base:
    BYTE $00                                ;[c134] register 0
    BYTE $10                                ;[c135] reset peripheral interrupts
    BYTE $00                                ;[c136]
    BYTE $10                                ;[c137]
    BYTE $04                                ;[c138] register 4
    BYTE $44                                ;[c139] 1 stop bit, /16 clock divider
    BYTE $01                                ;[c13a] register 1
    BYTE $00                                ;[c13b] disable all interrupts
    BYTE $03                                ;[c13c] register 3
    BYTE $c1                                ;[c13d] rx 8 bit word, synch character load inhibit
    BYTE $05                                ;[c13e] register 5
    BYTE $ea                                ;[c13f] enable tx, RTS, DTR, tx 8 bit word
    BYTE $ff                                ;[c140] end of table

    ; Configuration table for SIO ChB?
    ; Note: channel configuration is identical as above
sio_chB_cfg_base:
    BYTE $00                                ;[c141]
    BYTE $10                                ;[c142]
    BYTE $00                                ;[c143]
    BYTE $10                                ;[c144]
    BYTE $04                                ;[c145]
    BYTE $44                                ;[c146]
    BYTE $01                                ;[c147]
    BYTE $00                                ;[c148]
    BYTE $03                                ;[c149]
    BYTE $c1                                ;[c14a]
    BYTE $05                                ;[c14b]
    BYTE $ea                                ;[c14c]
    BYTE $ff                                ;[c14d]

    ; SUBROUTINE C14E; bios_copy_to_ram()
    ; Loads a piece of code in RAM, then executes it
    ld      hl,$c165                        ;[c14e]
    ld      de,$0010                        ;[c151]
    ld      bc,$000f                        ;[c154]
    ; LDIR: memcpy(de: dst, hl: src, bc: size)
    ldir                                    ;[c157] copy code from [$c165:$c174] to [$0010:$000f]
    ld      hl,$0000                        ;[c159]
    ld      de,$0000                        ;[c15c]
    ld      bc,$0000                        ;[c15f]
    jp      $0010                           ;[c162] jump to just loaded code

    ; This $c165/$0010 routine copies whole RAM content, from [$0000:$ffff],
    ; into the same location. This recomputes the parity bit of all memory locations.
    ; Parity is held in DRAM chip located in cell K9.

    ; this code is executed from [$0010:$000e]
    ; arguments:
    ; - hl: src
    ; - de: dst
    ; - bc: size
    in      a,($81)                         ;[c165]/[0010]
    set     0,a                             ;[c167]/[0012]
    out     ($81),a                         ;[c169]/[0014] PORTB |= 0x01 (bank 0 in)
    ldir                                    ;[c16b]/[0016] perform the memcpy
    res     0,a                             ;[c16d]/[0018]
    out     ($81),a                         ;[c16f]/[001a] PORTB &= ~0x01 (bank 0 out)
    out     ($de),a                         ;[c171]/[001c] and copy same value in $de
    ret                                     ;[c173]/[001e]

    ; prhex(a) - prints the hex value in a
    ; This function is a "giro di labbrate" (i.e. spaghetti code, very hard to explain line by line)
prhex:
    push    af                              ;[c174] save a
    rrca                                    ;[c175]
    rrca                                    ;[c176]
    rrca                                    ;[c177]
    rrca                                    ;[c178]
    and     $0f                             ;[c179] take most significant nibble
    call    prmsn                           ;[c17b] convert to ASCII digit and print it (0-9A-F)
    pop     af                              ;[c17e] restore a
    and     $0f                             ;[c17f] take least significant nibble
prmsn:
    call    tohex                           ;[c181] convert to ASCII digit
    jp      $c45e                           ;[c184] print it (0-9A-F)
; Interesting part of code that converts least significant nibble in a
; to an ASCII digit
tohex:
    add     $90                             ;[c187]
    daa                                     ;[c189] decimal adjust
    adc     $40                             ;[c18a]
    daa                                     ;[c18c] decimal adjust
    ld      c,a                             ;[c18d] move a in c for putchar(c)
    ret                                     ;[c18e]

; putstr: prints a null-terminated string
; String is automatically passed when calling this routine, and must be located immediately after the call. Example:
; call putstr
; BYTE "Hello, world!\x00"
; ;;; rest of the code...
putstr:
    ex      (sp),hl                         ;[c18f] load the argument from the stack in hl
label_c190:
    ld      a,(hl)                          ;[c190]
    inc     hl                              ;[c191] a = *(hl++)
    or      a                               ;[c192]
    jr      z,label_c19b                    ;[c193] return if a == '\0'
    ld      c,a                             ;[c195]
    call    $c45e                           ;[c196] putchar()
    jr      label_c190                      ;[c199] repeat again
label_c19b:
    ex      (sp),hl                         ;[c19b] reload altered hl onto the stack
    ret                                     ;[c19c]

    ; FDC Read Write Format Seek routine.
    ; Arguments:
    ; - a: bytes per sector "shift factor", bps = 0x80 << a
    ; - b: operation command, see switch in this routine
    ; - c: drive number (0-3) + HD flag
    ; - d: track number
    ; - e: sector number
    ; - hl: read/write buffer address
fdc_rwfs_c19d:
    push    bc                              ;[c19d]
    push    de                              ;[c19e]
    push    hl                              ;[c19f]
    ld      ($ffb8),a                       ;[c1a0] bytes per sector
    ld      a,$0a                           ;[c1a3]
    ld      ($ffbf),a                       ;[c1a5] value used in error checking routines
    ld      ($ffb9),bc                      ;[c1a8] *$ffb9 = drive no. + HD flag, *$ffba = operation command
    ld      ($ffbb),de                      ;[c1ac] *$ffbb = sector number, *$ffbc = track number
    ld      ($ffbd),hl                      ;[c1b0] base address for read/write buffer
    call    fdc_initialize_drive_c423       ;[c1b3] move head to track 0 if never done before on current drive
    ld      a,($ffba)                       ;[c1b6] load command byte
    and     $f0                             ;[c1b9] take only the most significant nibble
    jp      z,fdc_sw_track0                 ;[c1bb] case $00: move to track 0 (home)
    cp      $40                             ;[c1be]
    jp      z,fdc_sw_read_data              ;[c1c0] case $40: read sector in hl buffer
    cp      $80                             ;[c1c3]
    jp      z,fdc_sw_write_data             ;[c1c5] case $80: write sector in hl buffer
    cp      $20                             ;[c1c8]
    jp      z,fdc_sw_seek                   ;[c1ca] case $20: move head to desired track
    cp      $f0                             ;[c1cd]
    jp      z,fdc_sw_format                 ;[c1cf] case $f0: format desired track
    ld      a,$ff                           ;[c1d2]
    jp      fdc_sw_default                  ;[c1d4] default: return -1
fdc_sw_write_data:
    call    fdc_write_data_c1f4             ;[c1d7]
    jr      fdc_sw_default                  ;[c1da]
fdc_sw_read_data:
    call    fdc_read_data_c24a              ;[c1dc]
    jr      fdc_sw_default                  ;[c1df]
fdc_sw_seek:
    call    fdc_seek_c3a9                   ;[c1e1]
    jr      fdc_sw_default                  ;[c1e4]
fdc_sw_track0:
    call    fdc_track0_c391                 ;[c1e6]
    jr      fdc_sw_default                  ;[c1e9]
fdc_sw_format:
    call    fdc_format_c2e3                 ;[c1eb]
    jr      fdc_sw_default                  ;[c1ee]
fdc_sw_default:
    pop     hl                              ;[c1f0]
    pop     de                              ;[c1f1]
    pop     bc                              ;[c1f2]
    ret                                     ;[c1f3]

    ; FDC write data routine
    ; Writes data from *$ffbd to desired track/sector
    ; Arguments are stored in $ffb8-$ffbf, as explained in caller fdc_rwfs_c19d
fdc_write_data_c1f4:
    call    fdc_seek_c3a9                   ;[c1f4] move to desired track
fdc_write_retry_c1f7:
    call    fdc_compute_bps_c2b7            ;[c1f7] compute byte per sectors, result in de
    push    de                              ;[c1fa]
    call    fdc_wait_busy                   ;[c1fb]
    ld      c,$c5                           ;[c1fe] load "write data" command with MT and MF flags set
    ld      a,($ffb8)                       ;[c200]
    or      a                               ;[c203]
    jr      nz,label_c208                   ;[c204] if *ffb8 == 0 (128 bytes per sector)...
    res     6,c                             ;[c206] ...clear MF flag (FM mode)
label_c208:
    call    fdc_send_cmd                    ;[c208] send the "write data" command with desired MF flag
    di                                      ;[c20b] disable interrupts
    call    fdc_send_rw_args_c34e           ;[c20c] send "write data" arguments (common with "read data" arguments)
    pop     de                              ;[c20f]
    ld      c,$c1                           ;[c210] prepare IO address in c
    ld      b,e                             ;[c212] load number of bytes to write (LSB)
    ld      hl,($ffbd)                      ;[c213] load base address of writing buffer
    ; Buffer writing loop
label_c216:
    in      a,($82)                         ;[c216] read PORTC
    bit     2,a                             ;[c218]
    jr      z,label_c216                    ;[c21a]
    in      a,($c0)                         ;[c21c] read FDC main status register
    bit     5,a                             ;[c21e] check if still in execution phase...
    jr      z,label_c229                    ;[c220] ...if not, end writing
    outi                                    ;[c222] write data from buffer to FDC:  IO(c) = *(hl++); b--;
    jr      nz,label_c216                   ;[c224]
    dec     d                               ;[c226] bytes per sector is usually 512, must use a double byte counter
    jr      nz,label_c216                   ;[c227] write ends when d = 0 and b = 0

label_c229:
    out     ($dc),a                         ;[c229]
    ei                                      ;[c22b] enable interrupts again
    call    fdc_rw_status_c3f4              ;[c22c] command response, put it in $ffc0-$ffc6
    ld      a,($ffc0)                       ;[c22f] fetch status (ST0)
    and     $c0                             ;[c232] mask Interrupt Code bits (as in fdc_sis routine)...
    cp      $40                             ;[c234]
    jr      nz,label_c248                   ;[c236] ... and return if IC != 01 (!= "readfail")
    call    fdc_err_check_c2a0              ;[c238] after-write error checking (common with "read data")
    ld      a,($ffbf)                       ;[c23b] keep a retry counter to avoid infinite loops
    dec     a                               ;[c23e] decrement number of remaining retry
    ld      ($ffbf),a                       ;[c23f]
    jp      nz,fdc_write_retry_c1f7         ;[c242] after 256 retry give up and...
    ld      a,$ff                           ;[c245]
    ret                                     ;[c247] ... return -1
label_c248:
    xor     a                               ;[c248]
    ret                                     ;[c249] return 0

    ; FDC read data routine
    ; Read data from desired track/sector to *$ffbd
    ; Arguments are stored in $ffb8-$ffbf, as explained in caller fdc_rwfs_c19d
fdc_read_data_c24a:
    call    fdc_seek_c3a9                   ;[c24a] move to desired track
fdc_read_retry_c24d:
    call    fdc_compute_bps_c2b7            ;[c24d] compute byte per sectors, result in de
    push    de                              ;[c250]
    call    fdc_wait_busy                   ;[c251]
    ld      c,$c6                           ;[c254] load "read data" command with MT and MF flags set
    ld      a,($ffb8)                       ;[c256]
    or      a                               ;[c259]
    jr      nz,label_c25e                   ;[c25a] if *ffb8 == 0 (128 bytes per sector)...
    res     6,c                             ;[c25c] ...clear MF flag (FM mode)
label_c25e:
    call    fdc_send_cmd                    ;[c25e] send the "read data" command
    di                                      ;[c261] disable interrupts
    call    fdc_send_rw_args_c34e           ;[c262] send "read data" arguments (common with "write data" arguments)
    pop     de                              ;[c265]
    ld      c,$c1                           ;[c266] prepare IO address in c
    ld      b,e                             ;[c268] load number of bytes to write (LSB)
    ld      hl,($ffbd)                      ;[c269] load base address of reading buffer
label_c26c:
    in      a,($82)                         ;[c26c] read PORTC
    bit     2,a                             ;[c26e]
    jr      z,label_c26c                    ;[c270]
    in      a,($c0)                         ;[c272] read FDC main status register
    bit     5,a                             ;[c274] check if still in execution phase...
    jr      z,label_c27f                    ;[c276] ...if not, end reading
    ini                                     ;[c278] read data from FDC to *hl, hl++, b--
    jr      nz,label_c26c                   ;[c27a]
    dec     d                               ;[c27c] bytes per sector is usually 512, must use a double byte counter
    jr      nz,label_c26c                   ;[c27d] read ends when d = 0 and b = 0

label_c27f:
    out     ($dc),a                         ;[c27f]
    ei                                      ;[c281] enable interrupts again
    call    fdc_rw_status_c3f4              ;[c282] command response, put it in $ffc0-$ffc6
    ld      a,($ffc0)                       ;[c285] fetch status (ST0)
    and     $c0                             ;[c288] mask Interrupt Code bits (as in fdc_sis routine)...
    cp      $40                             ;[c28a]
    jr      nz,label_c29e                   ;[c28c]... and return if IC != 01 (!= "readfail")
    call    fdc_err_check_c2a0              ;[c28e] after-write error checking (common with "read data")
    ld      a,($ffbf)                       ;[c291] keep a retry counter to avoid infinite loops
    dec     a                               ;[c294] decrement number of remaining retry
    ld      ($ffbf),a                       ;[c295]
    jp      nz,fdc_read_retry_c24d          ;[c298] after 256 retry give up and...
    ld      a,$ff                           ;[c29b]
    ret                                     ;[c29d] ... return -1
label_c29e:
    xor     a                               ;[c29e]
    ret                                     ;[c29f] return 0

    ; TODO this is a FDC routine related to error checking after read/write
fdc_err_check_c2a0:
    ld      a,($ffc2)                       ;[c2a0] read 2nd status register (ST1)
    bit     4,a                             ;[c2a3] check OverRun bit (OR)
    jr      z,label_c2ab                    ;[c2a5] if not set, return, else...
    call    fdc_track0_c391                 ;[c2a7] ...reset head position...
    ret                                     ;[c2aa] ...and return for retry
label_c2ab:
    ld      a,($ffc1)                       ;[c2ab] read 3rd status register (ST2)
    bit     0,a                             ;[c2ae] check Missing Address Mark in Data Field (MD) bit
    jr      z,label_c2b6                    ;[c2b0] if not set, return, else...
    call    fdc_track0_c391                 ;[c2b2] ...reset head position...
    ret                                     ;[c2b5] ...and return for retry
label_c2b6:
    ret                                     ;[c2b6] return and just retry

    ; Compute number of bytes per sector
    ; Arguments:
    ; - $ffb8: bytes per sector "shift factor". If = 0, FM encoding is used. If != 0, MFM encoding is used
    ; - $ffba: lower nibble, manually add some more bps (TODO)
    ; - $ffbb: sector number (only bit 7 is considered)
    ; Return:
    ; - de: bytes per sector
fdc_compute_bps_c2b7:
    ld      e,$00                           ;[c2b7] e = 0
    ld      a,($ffb8)                       ;[c2b9] load bytes per sector
    cp      $03                             ;[c2bc]
    jr      nz,label_c2d4                   ;[c2be] if 1024 bytes per sector (*$ffb8 == 3)...
    ld      d,$04                           ;[c2c0] ... d = 4
    ld      a,($ffbb)                       ;[c2c2] load sector number
    bit     7,a                             ;[c2c5]
    jr      z,label_c2e2                    ;[c2c7] if MSb is not set, return
    ld      a,($ffba)                       ;[c2c9] load (lower nibble of) operation command
    and     $0f                             ;[c2cc]
    rlca                                    ;[c2ce]
    rlca                                    ;[c2cf]
    add     d                               ;[c2d0]
    ld      d,a                             ;[c2d1] d = ((*$ffba & 0xf) + 1) * 4
    jr      label_c2e2                      ;[c2d2] return, d as above, e = 0
label_c2d4:                                 ;       if bytes per sector != 1024...
    or      a                               ;[c2d4]
    jr      nz,label_c2d9                   ;[c2d5] if bytes per sector != 128 (*$ffb8 = 0)...
    ld      e,$80                           ;[c2d7] e = 128
label_c2d9:
    ld      a,($ffba)                       ;[c2d9] load (lower nibble of) operation command
    and     $0f                             ;[c2dc]
    ld      d,$01                           ;[c2de]
    add     d                               ;[c2e0]
    ld      d,a                             ;[c2e1] d = (*$ffba & 0xf) + 1
label_c2e2:
    ret                                     ;[c2e2]

    ; Format floppy disk
    ; Arguments are stored in $ffb8-$ffbf, as explained in caller fdc_rwfs_c19d
fdc_format_c2e3:
    call    fdc_seek_c3a9                   ;[c2e3] move to desired track
    cp      $ff                             ;[c2e6] if not able to locate track...
    ret     z                               ;[c2e8] ...return
    ld      b,$14                           ;[c2e9] b default value is 20
    ld      a,($ffb8)                       ;[c2eb] a is bytes per sector
    cp      $03                             ;[c2ee]
    jr      z,label_c2f4                    ;[c2f0] if less than 1024 bytes per sector...
    ld      b,$40                           ;[c2f2] b = 64
label_c2f4:
    push    bc                              ;[c2f4]
    call    fdc_wait_busy                   ;[c2f5]
    ld      c,$4d                           ;[c2f8]
    call    fdc_send_cmd                    ;[c2fa] send "write id" command
    ld      bc,($ffb9)                      ;[c2fd] 1st argument: drive number (c <= *$ffb9)
    call    fdc_send_cmd                    ;[c301]
    ld      a,($ffb8)                       ;[c304] 2nd argument: bytes per sector "factor"
    ld      c,a                             ;[c307]
    call    fdc_send_cmd                    ;[c308]
    ld      c,$05                           ;[c30b] default sectors/track number, 5
    ld      a,($ffb8)                       ;[c30d] same as before, load formatting encoding in a
    cp      $03                             ;[c310]
    jr      z,label_c316                    ;[c312]
    ld      c,$10                           ;[c314] if *$ffb8 != 3, sectors/track = 16
label_c316:
    call    fdc_send_cmd                    ;[c316] 3rd argument: sectors/track number
    ld      c,$28                           ;[c319] gap length is 40
    call    fdc_send_cmd                    ;[c31b] 4rd argument: gap3 length
    di                                      ;[c31e] disable interrupts
    ld      c,$e5                           ;[c31f]
    call    fdc_send_cmd                    ;[c321] 5th argument: filler byte value
    pop     bc                              ;[c324] reload bytes per sector in b
    ld      c,$c1                           ;[c325]
    ld      hl,($ffbd)                      ;[c327]
label_c32a:
    in      a,($82)                         ;[c32a] read PORTC
    bit     2,a                             ;[c32c]
    jr      z,label_c32a                    ;[c32e]
    in      a,($c0)                         ;[c330] read main status register
    bit     5,a                             ;[c332] check if still in execution phase...
    jr      z,label_c33a                    ;[c334] ...if not, end formatting
    outi                                    ;[c336] TODO why do I have to write something if i'm formatting?
    jr      nz,label_c32a                   ;[c338]
label_c33a:
    out     ($dc),a                         ;[c33a]
    ei                                      ;[c33c]
    call    fdc_rw_status_c3f4              ;[c33d] command response, put it in $ffc0-$ffc6
    ld      a,($ffc0)                       ;[c340] fetch status (ST0)
    and     $c0                             ;[c343] mask Interrupt Code bits (as in fdc_sis routine)...
    cp      $40                             ;[c345]
    jr      nz,label_c34c                   ;[c347] ... and return if IC != 01 (!= "readfail")
    ld      a,$ff                           ;[c349]
    ret                                     ;[c34b] return -1
label_c34c:
    xor     a                               ;[c34c]
    ret                                     ;[c34d] return 0

    ; FDC utility function: send arguments for read or write data commands
fdc_send_rw_args_c34e:
    ld      bc,($ffb9)                      ;[c34e] 1st argument: load drive number
    call    fdc_send_cmd                    ;[c352]
    ld      de,($ffbb)                      ;[c355] 2nd argument: track number
    ld      c,d                             ;[c359] track is in d <= *$ffbc
    call    fdc_send_cmd                    ;[c35a]
    ld      bc,($ffb9)                      ;[c35d] ffb9 contains HD flag too (physical head number)
    ld      a,c                             ;[c361]
    and     $04                             ;[c362] extract bit 2 (HD)
    rrca                                    ;[c364]
    rrca                                    ;[c365] Move in bit 0 position
    ld      c,a                             ;[c366]
    call    fdc_send_cmd                    ;[c367] 3rd argument: head number (0/1)
    res     7,e                             ;[c36a] reset bit 7 in e (sector number register loaded before)
    ld      c,e                             ;[c36c]
    inc     c                               ;[c36d] hypothesys: sector number - 1 is stored in $ffbb
    call    fdc_send_cmd                    ;[c36e] 4th argument: sector number to write
    ld      a,($ffb8)                       ;[c371]
    ld      c,a                             ;[c374]
    call    fdc_send_cmd                    ;[c375] 5th argument: bytes per sector "factor"
    ld      c,$05                           ;[c378] default value for EOT = 5
    ld      a,($ffb8)                       ;[c37a] load bytes per sector "factor"
    cp      $03                             ;[c37d]
    jr      z,label_c383                    ;[c37f] if less than 1024 bytes per sector...
    ld      c,$10                           ;[c381] override EOT with c = 16
label_c383:
    call    fdc_send_cmd                    ;[c383] 6th argument: EOT - final sector of a track
    ld      c,$28                           ;[c386]
    call    fdc_send_cmd                    ;[c388] 7th argument: GPL - gap length fixed to 0x28
    ld      c,$ff                           ;[c38b]
    call    fdc_send_cmd                    ;[c38d] 8th argument: DTL - data length, should be invalid if 5th argument is != 0
    ret                                     ;[c390]

    ; This routine seems to move the floppy head to track 0, then waits for the operation execution
fdc_track0_c391:
    call    fdc_wait_busy                   ;[c391]
    ld      c,$07                           ;[c394] Recalibrate command
    call    fdc_send_cmd                    ;[c396] Send command to FDC
    ld      bc,($ffb9)                      ;[c399] Load drive number?
    res     2,c                             ;[c39d] For some reason, clear bit 2. Recalibrate argument must be 0b000000xx, where xx = drive number in [0,3]
    call    fdc_send_cmd                    ;[c39f] Send command to FDC
    call    fdc_sis_c3d2                    ;[c3a2] send SIS to check if head movement was correctly completed
    jr      z,fdc_track0_c391               ;[c3a5] check if return is "readfail" (Z = 0) then retry, else...
    xor     a                               ;[c3a7] ... return 0
    ret                                     ;[c3a8]

    ; FDC: sends the seek command and move head upon desired track
    ; Arguments:
    ; - $ffbb: new track number
    ; - $ffb9: drive number
fdc_seek_c3a9:
    ld      de,($ffbb)                      ;[c3a9] load track number
    ld      a,d                             ;[c3ad] track number is in d <= *$ffbc
    or      a                               ;[c3ae] check if requested track is 0...
    jp      z,fdc_track0_c391               ;[c3af] if track = 0, skip this and call appropriate routine
    call    fdc_wait_busy                   ;[c3b2]
    ld      c,$0f                           ;[c3b5] send "seek" command
    call    fdc_send_cmd                    ;[c3b7]
    ld      bc,($ffb9)                      ;[c3ba] 1st arg: load and send *$ffb9 = drive number + HD flag
    call    fdc_send_cmd                    ;[c3be]
    ld      c,d                             ;[c3c1] 2nd arg: send NCN (new cylinder number) = desired track
    call    fdc_send_cmd                    ;[c3c2]
    call    fdc_sis_c3d2                    ;[c3c5] sends SIS to check if head movement was correctly completed
    jr      nz,label_c3d0                   ;[c3c8] if fdc_sis returns "OK" (Z != 0), return, else...
    call    fdc_track0_c391                 ;[c3ca] ...move head to track 0...
    jp      fdc_seek_c3a9                   ;[c3cd] ...and try again
label_c3d0:
    xor     a                               ;[c3d0] On success, a=0 and return
    ret                                     ;[c3d1]

    ; FDC utility function: send "Sense Interrupt Status" command and read the two bytes (ST0, PCN)
    ; Return:
    ; - Z flag from the comparison (ST0 & 0xC0) == 0x40.
    ;   ST0[7:6] is Interrupt Code, and is:
    ;     - 00 if previous operation was successful (OK);
    ;     - 01 if previous operation was not successful (readfail);
    ;     - other cases are treated as successful.
fdc_sis_c3d2:
    in      a,($82)                         ;[c3d2] read PORTC
    bit     2,a                             ;[c3d4]
    jp      z,fdc_sis_c3d2                  ;[c3d6] busy wait until PORTC[2] != 0
    call    fdc_wait_busy                   ;[c3d9]
    call    fdc_wait_rqm_wr                 ;[c3dc] wait until FDC is ready for write request
    ld      a,$08                           ;[c3df] send "Sense Interrupt Status" command
    out     ($c1),a                         ;[c3e1]
    call    fdc_wait_rqm_rd                 ;[c3e3] wait for data ready from FDC
    in      a,($c1)                         ;[c3e6] read status byte (ST0)
    ld      b,a                             ;[c3e8]
    call    fdc_wait_rqm_rd                 ;[c3e9]
    in      a,($c1)                         ;[c3ec] read present cylinder number (PCN), aka current track
    ld      a,b                             ;[c3ee] discard PCN
    and     $c0                             ;[c3ef]
    cp      $40                             ;[c3f1] perform (ST0 & 0xC0) == 0x40
    ret                                     ;[c3f3] return is in Z flag

    ; FDC utility function: read response after read/write/format execution.
    ; A 7 byte response is given, read it all in $ffc0-$ffc6
fdc_rw_status_c3f4:
    ld      hl,$ffc0                        ;[c3f4] buffer pointer
    ld      b,$07                           ;[c3f7] data length, answer is 7 byte long
    ld      c,$c1                           ;[c3f9] IO address
label_c3fb:
    call    fdc_wait_rqm_rd                 ;[c3fb] wait until FDC is ready to send data
    ini                                     ;[c3fe] read from IO in *hl, hl++, b--
    jr      nz,label_c3fb                   ;[c400] end if b = 0
    ret                                     ;[c402]

    ; SUBROUTINE C403 ; wait for ioaddr(0xc0) to become "0b10xxxxxx"
    ; FDC utility function: read main status register and wait for RQM = 1 and DIO = 0.
    ; RQM = request from master, RQM = 1 means FDC is ready for communication with the CPU
    ; DIO = data input/output, DIO = 0 means transfer from CPU to FDC
fdc_wait_rqm_wr:
    in      a,($c0)                         ;[c403]
    rlca                                    ;[c405]
    jr      nc,fdc_wait_rqm_wr              ;[c406] while (bit7 == 0), try again
    rlca                                    ;[c408]
    jr      c,fdc_wait_rqm_wr               ;[c409] while (bit7 == 1) && (bit6 == 1), try again
    ret                                     ;[c40b]

    ; SUBROUTINE C40C ; wait for ioaddr(0xc0) to become "0b11xxxxxx"
    ; FDC utility function: read main status register and wait for RQM = 1 and DIO = 1
    ; RQM = request from master, RQM = 1 means FDC is ready for communication with the CPU
    ; DIO = data input/output, DIO = 1 means transfer from FDC to CPU
fdc_wait_rqm_rd:
    in      a,($c0)                         ;[c40c]
    rlca                                    ;[c40e]
    jr      nc,fdc_wait_rqm_rd              ;[c40f] while (bit7 == 0), try again
    rlca                                    ;[c411]
    jr      nc,fdc_wait_rqm_rd              ;[c412] while (bit7 == 1) && (bit6 == 0), try again
    ret                                     ;[c414]

    ; SUBROUTINE C415
    ; FDC utility function: send a command byte to the FDC
    ; Arguments:
    ; - c: the command byte
fdc_send_cmd:
    call    fdc_wait_rqm_wr                 ;[c415] wait until FDC is ready to receive data
    ld      a,c                             ;[c418]
    out     ($c1),a                         ;[c419] actually send the comamnd
    ret                                     ;[c41b]

    ; SUBROUTINE C41C ; while( ioaddr(0xc0).4 == 1 ), wait
    ; FDC utility function: wait until the FDC is no more busy.
    ; $C0 may be the main status register, where bit 4 is the CB (active high busy) flag.
fdc_wait_busy:
    in      a,($c0)                         ;[c41c]
    bit     4,a                             ;[c41e]
    jr      nz,fdc_wait_busy                ;[c420]
    ret                                     ;[c422]

    ; FDC utility routine: IDEA reset head position at least one time per drive since the computer was turned on
    ; Arguments:
    ; - c: drive number from rwfs routine
fdc_initialize_drive_c423:
    ld      b,$01                           ;[c423]
    ld      a,c                             ;[c425]
    and     $03                             ;[c426] mask drive number only
    or      a                               ;[c428]
    jr      z,label_c430                    ;[c429] if drive is != 0 (not drive A)...
label_c42b:
    rlc     b                               ;[c42b] at the end of the cycle...
    dec     a                               ;[c42d] ... b = 1 << (drive number)
    jr      nz,label_c42b                   ;[c42e]
label_c430:
    ld      a,($ffc7)                       ;[c430] idea: *ffc7 = mask of the accessed drives
    ld      c,a                             ;[c433]
    and     b                               ;[c434]
    ret     nz                              ;[c435] return if rwfs is trying to access an already "initialized" drive
    ld      a,c                             ;[c436]
    or      b                               ;[c437] else, mark this drive as initialized...
    ld      ($ffc7),a                       ;[c438] ...store this information in ram...
    call    fdc_track0_c391                 ;[c43b] ...and perform initialization (aka moving head to track 0)
    ret                                     ;[c43e]

    ; SUBROUTINE C43F
    ; FDC initialization.
    ; Configure the FDC IC with:
    ; - SRT = 6 (Step Rate Time = 6ms)
    ; - HUT = F (Head Unload Time = 240ms)
    ; - HLT = A (Head Load Time = 22ms)
    ; - ND = 1 (DMA mode disabled)
fdc_init:
    push    bc                              ;[c43f]
    push    hl                              ;[c440]
    ld      hl,fdc_cfg_base                 ;[c441] prepare HL to address FDC configuration table
    call    fdc_wait_busy                   ;[c444]
    ld      c,$03                           ;[c447] send "specify" command
    call    fdc_send_cmd                    ;[c449]
    ld      c,(hl)                          ;[c44c] load first "specify" argument from table
    inc     hl                              ;[c44d]
    call    fdc_send_cmd                    ;[c44e] send SRT | HUT
    ld      c,(hl)                          ;[c451] load second "specify" argument from table
    call    fdc_send_cmd                    ;[c452] send HLT | ND
    xor     a                               ;[c455]
    ld      ($ffc7),a                       ;[c456] *$ffc7 = 0
    pop     hl                              ;[c459]
    pop     bc                              ;[c45a]
    ret                                     ;[c45b]

    ; STATIC DATA for C43F
fdc_cfg_base:
    BYTE $6f                                ;[c45c] SRT << 4 | HUT
    BYTE $1b                                ;[c45d] HLT << 1 | ND

    ; SUBROUTINE C45E: bios_putchar()
    ; Input
    ;   C: character to be printed
bios_putchar_c45e:
    push    af                              ;[c45e] save all registers
    push    bc                              ;[c45f]
    push    de                              ;[c460]
    push    hl                              ;[c461]
    push    ix                              ;[c462]
    push    iy                              ;[c464]
    call    $c69a                           ;[c466] bios_load_ix_iy()

    ; if escaping a char from previous call, then jump to second-stage escape handler
    ld      a,($ffd8)                       ;[c469]
    or      a                               ;[c46c]
    jp      nz,$c9e3                        ;[c46d]

    ; check if should override character switch behaviour
    ld      a,($ffcc)                       ;[c470]
    cp      $ff                             ;[c473] if *$ffcc is == $ff...
    jp      z,$c6a3                         ;[c475]     save_index_restore_registers_and_ret()
    or      a                               ;[c478] if *$ffcc is != 0...
    jp      nz,label_c4be                   ;[c479] print c even if is not a printable char

    ; Character switch: handle not printable characters
    ld      a,c                             ;[c47c]
    cp      $1b                             ;[c47d] jump if ESC
    jr      z,label_c4b6                    ;[c47f]
    cp      $20                             ;[c481] jump if printable (>=' ')
    jp      nc,label_c4be                   ;[c483]
    cp      $0d                             ;[c486] jump if CR
    jp      z,label_c524                    ;[c488]
    cp      $0a                             ;[c48b] jump if LF
    jp      z,label_c532                    ;[c48d]
    cp      $0b                             ;[c490] jump if TAB
    jp      z,label_c558                    ;[c492]
    cp      $0c                             ;[c495] jump if NewPage
    jp      z,label_c56f                    ;[c497]
    cp      $08                             ;[c49a] jump if Backspace
    jp      z,label_c59b                    ;[c49c]
    cp      $1e                             ;[c49f] jump if RS
    jp      z,label_c5db                    ;[c4a1]
    cp      $1a                             ;[c4a4] jump if SUB
    jp      z,label_c5ee                    ;[c4a6]
    cp      $07                             ;[c4a9] jump if BEL
    call    z,label_c5f4                    ;[c4ab]
    cp      $00                             ;[c4ae] jump if NUL
    jp      z,label_c6a3                    ;[c4b0]     save_index_restore_registers_and_ret()
    jp      label_c4be                      ;[c4b3] jump if any other not printable character

    ; Handle escape (first stage): remember that a character is being escaped, for next putchar()
label_c4b6:
    ld      a,$01                           ;[c4b6]
    ld      ($ffd8),a                       ;[c4b8] "ecaped_char" = 1
    jp      label_c6a3                      ;[c4bb] save_index_restore_registers_and_ret()

    ; Handle all, but special characters
label_c4be:
    push    iy                              ;[c4be]
    pop     hl                              ;[c4c0] hl <- iy (copy of cursor position)
    call    $c715                           ;[c4c1] display_cursor_to_video_mem_ptr()
    ld      (hl),c                          ;[c4c4] put character in video memory
    call    $c795                           ;[c4c5] bank_video_attribute_memory()
    ld      a,($ffd1)                       ;[c4c8]
    ld      b,a                             ;[c4cb]
    ld      a,($ffd2)                       ;[c4cc]
    and     (hl)                            ;[c4cf] a = *(0xffd2) & character in video memory
    or      b                               ;[c4d0] a |= *(0xffd1)
    ld      (hl),a                          ;[c4d1] write again in video memory
    call    $c79e                           ;[c4d2] bank_video_char_memory()
    call    $c5f8                           ;[c4d5] increment cursor column position
    jr      c,label_c4e0                    ;[c4d8] if posx > "max column width", must do something else before the end
    call    $c613                           ;[c4da] increments hl counter and update cursor position in CRTC
    jp      label_c6a3                      ;[c4dd] putchar epilogue: save_index_restore_registers_and_ret()

label_c4e0:
    ld      a,($ffcb)                       ;[c4e0] load "current_row"
    ld      b,a                             ;[c4e3]
    ld      a,($ffcd)                       ;[c4e4] read "number of rows" of display
    cp      b                               ;[c4e7]
    jr      z,label_c501                    ;[c4e8] jump if posy reached last row
    inc     b                               ;[c4ea] increment cursor posy?
    ld      a,b                             ;[c4eb]
    ld      ($ffcb),a                       ;[c4ec] save "current_row"
    ld      a,($ffc9)                       ;[c4ef]
    or      a                               ;[c4f2]
    jr      nz,label_c4fb                   ;[c4f3] jump if *$ffc9 != 0
    call    $c613                           ;[c4f5] increments hl counter and update cursor position in CRTC
    jp      label_c6a3                      ;[c4f8] putchar epilogue: save_index_restore_registers_and_ret()

    ; SUBROUTINE 0xC4FB; called by c4e0 if *$ffc9 == 0
label_c4fb:
    call    $c620                           ;[c4fb]
    jp      label_c6a3                      ;[c4fe] putchar epilogue: save_index_restore_registers_and_ret()

    ; SUBROUTINE C501
    ; Perform display frame scroll
label_c501:
    ld      a,($ffc9)                       ;[c501]
    or      a                               ;[c504]
    jr      nz,label_c510                   ;[c505]
    call    $c613                           ;[c507]
    call    $c62e                           ;[c50a]
    jp      label_c6a3                      ;[c50d] putchar epilogue: save_index_restore_registers_and_ret()

label_c510:
    ld      a,($ffcd)                       ;[c510] read "number of rows" of display
    ld      b,a                             ;[c513]
    ld      a,($ffd0)                       ;[c514]
    ld      c,a                             ;[c517]
    call    $c6f1                           ;[c518] display_add_row_column()
    call    $c71c                           ;[c51b] crtc_update_cursor_position()
    call    $c62e                           ;[c51e]
    jp      label_c6a3                      ;[c521] save_index_restore_registers_and_ret()

    ; print CR ($0d) Carriage Return
label_c524:
    ld      a,($ffd0)                       ;[c524]
    ld      ($ffca),a                       ;[c527] copy content $FFCA = $FFD0
    ld      c,a                             ;[c52a] C = var$FFD0
    ld      a,($ffcb)                       ;[c52b]
    ld      b,a                             ;[c52e] B = "current_row"
    jp      label_c5e5                      ;[c52f]

    ; print LF ($0a) Line Feed
label_c532:
    ld      a,($ffcb)                       ;[c532]
    ld      b,a                             ;[c535] B = "current_row"
    ld      a,($ffcd)                       ;[c536] read "number of rows" of display
    cp      b                               ;[c539]
    jr      z,label_c54b                    ;[c53a] if "current_row" != "number of rows" {
    inc     b                               ;[c53c]
    ld      a,b                             ;[c53d]
    ld      ($ffcb),a                       ;[c53e]     "current_row" ++
label_c541:
    push    iy                              ;[c541]
    pop     hl                              ;[c543]
    ld      de,$0050                        ;[c544]
    add     hl,de                           ;[c547]     IY += 80 (next row, in linear position)
    jp      label_c5e8                      ;[c548]     always the same save, cleanup and return stuff
                                            ;       }
label_c54b:
    call    $c62e                           ;[c54b]
    ld      a,($ffcb)                       ;[c54e] read "current_row"
    ld      b,a                             ;[c551]
    ld      a,($ffca)                       ;[c552] read "current_column"
    ld      c,a                             ;[c555]
    jr      label_c541                      ;[c556]

    ; print TAB ($09)
label_c558:
    ld      a,($ffcb)                       ;[c558] read "current_row"
    ld      b,a                             ;[c55b]
    ld      a,($ffce)                       ;[c55c] read current column? what
    cp      b                               ;[c55f] if A == B
    jp      z,label_c6a3                    ;[c560]     save_index_restore_registers_and_ret()
    dec     b                               ;[c563]
    ld      a,b                             ;[c564]
    ld      ($ffcb),a                       ;[c565] "current_row" --
    ld      a,($ffca)                       ;[c568] read "current_column"
    ld      c,a                             ;[c56b]
    jp      label_c5e5                      ;[c56c] goto and call display_add_row_column()
label_c56f:
    call    $c5f8                           ;[c56f]
    ld      a,($ffcb)                       ;[c572]
    ld      b,a                             ;[c575]
    jr      c,label_c57b                    ;[c576]
    jp      label_c5e5                      ;[c578]
label_c57b:
    ld      a,($ffd0)                       ;[c57b]
    ld      ($ffca),a                       ;[c57e] store "current_column"
    ld      c,a                             ;[c581]
    ld      a,($ffcb)                       ;[c582]
    ld      b,a                             ;[c585]
    ld      a,($ffcd)                       ;[c586] read "number of rows" of display
    cp      b                               ;[c589]
    jr      z,label_c594                    ;[c58a]
    inc     b                               ;[c58c]
    ld      a,b                             ;[c58d]
    ld      ($ffcb),a                       ;[c58e]
    jp      label_c5e5                      ;[c591]
label_c594:
    push    bc                              ;[c594]
    call    $c62e                           ;[c595]
    pop     bc                              ;[c598]
    jr      label_c5e5                      ;[c599]
label_c59b:
    ld      a,($ffca)                       ;[c59b] read "current_column"
    ld      c,a                             ;[c59e]
    ld      a,($ffd0)                       ;[c59f]
    cp      c                               ;[c5a2]
    jr      z,label_c5b8                    ;[c5a3]
    dec     c                               ;[c5a5]

    ld      a,($ffd1)                       ;[c5a6] if (text attribute == stretch) {
    bit     3,a                             ;[c5a9]
    jr      z,label_c5ae                    ;[c5ab]
    dec     c                               ;[c5ad]     decrement C again
                                            ;       }
label_c5ae:
    ld      a,c                             ;[c5ae]
    ld      ($ffca),a                       ;[c5af] store "current_column"
    ld      a,($ffcb)                       ;[c5b2] load "current_row"
    ld      b,a                             ;[c5b5]
    jr      label_c5e5                      ;[c5b6]
label_c5b8:
    ld      a,($ffcf)                       ;[c5b8]
    ld      b,a                             ;[c5bb]

    ; if (magenta:3 == 0), jump to label_c5c4
    ld      a,($ffd1)                       ;[c5bc] if (text attribute == stretch) {
    bit     3,a                             ;[c5bf]
    jr      z,label_c5c4                    ;[c5c1]
    dec     b                               ;[c5c3]     decrement B
                                            ;       }
label_c5c4:
    ld      a,b                             ;[c5c4]
    ld      ($ffca),a                       ;[c5c5] store "current_column"
    ld      c,a                             ;[c5c8]
    ld      a,($ffcb)                       ;[c5c9]
    ld      b,a                             ;[c5cc]
    ld      a,($ffce)                       ;[c5cd]
    cp      b                               ;[c5d0] if A == B
    jp      z,label_c6a3                    ;[c5d1]     save_index_restore_registers_and_ret()
    dec     b                               ;[c5d4]
    ld      a,b                             ;[c5d5]
    ld      ($ffcb),a                       ;[c5d6]
    jr      label_c5e5                      ;[c5d9]
label_c5db:
    xor     a                               ;[c5db]
    ld      ($ffcb),a                       ;[c5dc] "current_row" = 0
    ld      ($ffca),a                       ;[c5df] "current_column" = 0
    ld      bc,$0000                        ;[c5e2] prepare parameters for next function call
label_c5e5:
    call    $c6f1                           ;[c5e5] display_add_row_column()
label_c5e8:
    call    crtc_update_cursor_position     ;[c5e8] crtc_update_cursor_position()
    jp      label_c6a3                      ;[c5eb] save_index_restore_registers_and_ret()
label_c5ee:
    call    $c764                           ;[c5ee] display_clear()
    jp      label_c6a3                      ;[c5f1] save_index_restore_registers_and_ret()

    ; "prints" BEL, making speaker beep
label_c5f4:
    xor     a                               ;[c5f4]
    out     ($da),a                         ;[c5f5] sound speaker beep
    ret                                     ;[c5f7]

    ; SUBROUTINE 0xC5F8
    ; this subroutine advances the cursor,
    ; taking into account end-of-line and "stretch" attribute
    ld      a,($ffca)                       ;[c5f8] load cursor posx
    ld      c,a                             ;[c5fb]
    inc     c                               ;[c5fc] increment posx

    ld      a,($ffd1)                       ;[c5fd] if (text attribute == "stretch") {
    bit     3,a                             ;[c600]
    jr      z,label_c605                    ;[c602]
    inc     c                               ;[c604]     increment posx again
                                            ;       }
label_c605:
    ld      a,($ffcf)                       ;[c605] load "maximum column width - 1" value
    cp      c                               ;[c608]
    ld      a,c                             ;[c609]
    jr      nc,label_c60f                   ;[c60a] if posx > *$ffcf...
    ld      a,($ffd0)                       ;[c60c] put posx to "column 0"
label_c60f:
    ld      ($ffca),a                       ;[c60f] store "current_column"
    ret                                     ;[c612]

    ; SUBROUTINE $C613
    inc     hl                              ;[c613] increment hl (pointer to video memory location)
    ld      a,($ffd1)                       ;[c614] if (text attribute == "stretch") {
    bit     3,a                             ;[c617]
    jr      z,label_c61c                    ;[c619]
    inc     hl                              ;[c61b]     increment hl again
                                            ;       }
label_c61c:
    call    crtc_update_cursor_position     ;[c61c] crtc_update_cursor_position(hl, ix)
    ret                                     ;[c61f]

    ld      a,($ffc8)                       ;[c620] 3a c8 ff
    ld      e,a                             ;[c623] 5f
    ld      d,$00                           ;[c624] 16 00
    push    iy                              ;[c626] fd e5
    pop     hl                              ;[c628] e1
    add     hl,de                           ;[c629] 19
    call    $c71c                           ;[c62a] crtc_update_cursor_position()
    ret                                     ;[c62d] c9

    ; SUBROUTINE $C62E
    ; Handle hardware frame scroll
    ld      a,($ffc9)                       ;[c62e]
    or      a                               ;[c631]
    jr      nz,label_c647                   ;[c632]
    push    ix                              ;[c634]
    pop     hl                              ;[c636] HL = CRTC video memory base address
    ld      de,$0050                        ;[c637] DE = 80 (number of columns)
    add     hl,de                           ;[c63a] HL += DE
    call    $c742                           ;[c63b]
    ld      b,$17                           ;[c63e]
    call    $c7fa                           ;[c640] copy status bar one line below (first stage)
    call    $c670                           ;[c643] clear line text and reset attributes
    ret                                     ;[c646]

label_c647:
    ld      a,($ffd0)                       ;[c647] 3a d0 ff
    ld      c,a                             ;[c64a] 4f
    ld      a,($ffce)                       ;[c64b] 3a ce ff
    ld      b,a                             ;[c64e] 47
    ld      a,($ffce)                       ;[c64f] 3a ce ff
    ld      d,a                             ;[c652] 57
    ld      a,($ffcd)                       ;[c653] read "number of rows" of display
    sub     d                               ;[c656] 92
    jr      z,label_c664                    ;[c657] 28 0b
    ld      d,a                             ;[c659] 57
label_c65a:
    inc     b                               ;[c65a] 04
    call    $c6f1                           ;[c65b] display_add_row_column()
    call    $c7a7                           ;[c65e] cd a7 c7
    dec     d                               ;[c661] 15
    jr      nz,label_c65a                   ;[c662] 20 f6
label_c664:
    ld      a,($ffcd)                       ;[c664] read "number of rows" of display
    ld      d,a                             ;[c667]
    ld      a,($ffcf)                       ;[c668]
    ld      e,a                             ;[c66b]
    call    $c805                           ;[c66c]
    ret                                     ;[c66f]

    ; SUBROUTINE C670
    ; Clear line chars and its attributes.
    ; Input:
    ;   - IX: CRTC video memory start
    push    ix                              ;[c670]
    pop     hl                              ;[c672]
    ld      de,$0730                        ;[c673] DE = 0x730 = 23 * 80
    ld      b,$50                           ;[c676]
    add     hl,de                           ;[c678] HL = IX + 0x730
    ld      de,$2000                        ;[c679]
    call    $c795                           ;[c67c] bank_video_attribute_memory()
    call    $c715                           ;[c67f] display_cursor_to_video_mem_ptr()
    push    hl                              ;[c682]
    push    bc                              ;[c683]
    ld      e,$00                           ;[c684] E = 0 (text attributes empty)
    call    $c690                           ;[c686] reset(E)
    pop     bc                              ;[c689]
    pop     hl                              ;[c68a]
    call    $c79e                           ;[c68b] bank_video_char_memory()
    ld      e,$20                           ;[c68e] E = 0x20 (space char)

    ; SUBROUTINE C690
label_c690:
    ld      (hl),e                          ;[c690] for (B = 0x50; B > 0; --B) {
    inc     hl                              ;[c691]     /* reset text chars and attributes */
    bit     3,h                             ;[c692]     if (HL < 2048)
    call    z,$c715                         ;[c694]         display_cursor_to_video_mem_ptr()
    djnz    label_c690                      ;[c697] }
    ret                                     ;[c699]

    ; SUBROUTINE C69A ; bios_load_ix_iy()
    ; load cursor position (?)
    ld      ix,($ffd4)                      ;[c69a]
    ld      iy,($ffd6)                      ;[c69e] Load current cursor position as in CRTC R14:R15 registers
    ret                                     ;[c6a2]

    ; SUBROUTINE C6A3: save_index_restore_registers_and_ret()
label_c6a3:
    call    $c6e8                           ;[c6a3] bios_save_ix_iy()
    pop     iy                              ;[c6a6] function epilogue: restore all registers
    pop     ix                              ;[c6a8]
    pop     hl                              ;[c6aa]
    pop     de                              ;[c6ab]
    pop     bc                              ;[c6ac]
    pop     af                              ;[c6ad]
    ret                                     ;[c6ae]

    ; SUBROUTINE C6AF; display variables initialization
    ld      hl,$ffc9                        ;[c6af]
    xor     a                               ;[c6b2]
    ld      (hl),a                          ;[c6b3] *$ffc9 = 0
    inc     hl                              ;[c6b4]
    ld      (hl),a                          ;[c6b5] *$ffca = 0 ("current_column")
    inc     hl                              ;[c6b6]
    ld      (hl),a                          ;[c6b7] *$ffcb = 0 ("current_row")
    inc     hl                              ;[c6b8]
    ld      (hl),a                          ;[c6b9] *$ffcc = 0
    inc     hl                              ;[c6ba]
    ld      (hl),$17                        ;[c6bb] *$ffce = "23" (rows(?)-1)
    inc     hl                              ;[c6bd]
    ld      (hl),a                          ;[c6be] *$ffcf = 0
    inc     hl                              ;[c6bf]
    ld      (hl),$4f                        ;[c6c0] *$ffd0 = "79" (columns-1)
    inc     hl                              ;[c6c2]
    ld      (hl),a                          ;[c6c3] *$ffd1 = 0 (clear "magenta") (text attribute bitmap)
    inc     hl                              ;[c6c4]
    ld      (hl),a                          ;[c6c5] *$ffd2 = 0
    inc     hl                              ;[c6c6]
    ld      (hl),$80                        ;[c6c7] *$ffd3 = 0 (memory backup of CRTC register 0x0A)
    inc     hl                              ;[c6c9]
    ld      a,($c86f)                       ;[c6ca] a <- cursor data raster from crtc_cfg, "$0d"
    ld      d,a                             ;[c6cd] d <- a
    in      a,($d6)                         ;[c6ce]
    bit     5,a                             ;[c6d0]
    jr      z,label_c6d6                    ;[c6d2]
    ld      d,$03                           ;[c6d4]
label_c6d6:
    bit     6,a                             ;[c6d6]
    jr      z,label_c6de                    ;[c6d8]
    set     5,d                             ;[c6da]
    set     6,d                             ;[c6dc]
label_c6de:
    ld      (hl),d                          ;[c6de] *$ffd4 value is not prior known
    xor     a                               ;[c6df] prepare registers for $c6e3 loop
    inc     hl                              ;[c6e0]
    ld      b,$15                           ;[c6e1]
label_c6e3:
    ld      (hl),a                          ;[c6e3] write 0 in all memory in [$ffd5:$ffe9]
    inc     hl                              ;[c6e4]
    djnz    label_c6e3                      ;[c6e5]
    ret                                     ;[c6e7]

    ; SUBROUTINE C6E8; save IX and IY
    ; Save IX and IY
bios_save_ix_iy:
    ld      ($ffd4),ix                      ;[c6e8]
    ld      ($ffd6),iy                      ;[c6ec]
    ret                                     ;[c6f0]

    ; SUBROUTINE C6F1; display_add_row_column()
    ; Linearize row and column coordinates, and add to IX
    ; Input:
    ;   - IX: CRTC start address
    ;   - B: number of row
    ;   - C: number of column
    ; Output:
    ;   HL = IX + 80 * B + C
display_add_row_column:
    ; function prologue, save registers
    push    af                              ;[c6f1]
    push    bc                              ;[c6f2]
    push    de                              ;[c6f3]

    push    ix                              ;[c6f4]
    pop     hl                              ;[c6f6] HL = IX

    ; prepare add-and-shift multiplication
    ld      de,$0050                        ;[c6f7] DE = 80 (display columns)
    ld      a,b                             ;[c6fa] A = B
                                            ;       Maximum number of row is 24, which stays on 5 bits,
                                            ;       then do this add-and-shift multiplication for 5 times max
    ld      b,$05                           ;[c6fb] B = 5

    ; perform add-and-shift multiplication loop
label_c6fd:
    rra                                     ;[c6fd] extract lsb of A
    jr      nc,label_c701                   ;[c6fe] if bit == 1, then
    add     hl,de                           ;[c700]     HL += 80 (add...)
label_c701:
    or      a                               ;[c701] reset carry flag
    rl      e                               ;[c702]
    rl      d                               ;[c704] DE *= 2 (...and shift)
    dec     b                               ;[c706] --B
    jr      nz,label_c6fd                   ;[c707] if B > 0, loop

    ; add C
    ld      d,$00                           ;[c709]
    ld      e,c                             ;[c70b]
    add     hl,de                           ;[c70c] HL += C
    ld      a,h                             ;[c70d]
    and     $0f                             ;[c70e]
    ld      h,a                             ;[c710] clamp final value to 0xFFF (4096 - 1)
                                            ;       result is left in HL

    ; function epilogue, restore registers
    pop     de                              ;[c711]
    pop     bc                              ;[c712]
    pop     af                              ;[c713]
    ret                                     ;[c714]

    ; SUBROUTINE 0xC715; display_cursor_to_video_mem_ptr()
    ; Compute current video memory pointer from current cursor
    ; Input:
    ; - HL: cursor position
    ; Return:
    ; - HL: video memory pointer
    ; Memento: video memory is mapped to 0xd000:0xd7ff
    ld      a,h                             ;[c715]
    and     $07                             ;[c716] hl &= 0x07ff (clamp to max video memory address)
    or      $d0                             ;[c718] hl += 0xd000
    ld      h,a                             ;[c71a]
    ret                                     ;[c71b]

    ; SUBROUTINE C71C; crtc_update_cursor_position(HL: value, IX)
    ; Write cursor position into CRTC hardware registers.
    ; (CRTC can display cursor in using hardware acceleration)
    ; Cursor position is specified as if the video matrix has been linearized.
    ; Example: row 7, column 4 => position = (7 * 80) + 4 = $234 => CRTC R14 = $02, CRTC R15 = $34
    ; Input:
    ;   - HL: l_cur_pos: pointer to next free video memory location (possibly overflowing)
    ;   - IX
    ; Output:
    ;   - IY
crtc_update_cursor_position:
    ; first, transform absolute video memory pointer to relative video memory pointer
    ; (for CRTC consumption - a.k.a. "HL - $d000")
    ld      a,h                             ;[c71c]
    and     $07                             ;[c71d]
    ld      h,a                             ;[c71f] l_cur_pos &= 0x07FF (clamp to range [0;2048[ )
                                            ;       video memory is 2000 bytes long (80x25)
                                            ;       video memory page is 2048 bytes long (2k)
    push    ix                              ;[c720]
    pop     de                              ;[c722]
    ex      de,hl                           ;[c723] HL = IX; DE = l_cur_pos
    or      a                               ;[c724] clear carry
    sbc     hl,de                           ;[c725] HL = IX - l_cur_pos
    jr      c,label_c730                    ;[c727]
    jr      z,label_c730                    ;[c729] if (IX > l_cur_pos) {
    ld      hl,$0800                        ;[c72b]     HL = $0800
    add     hl,de                           ;[c72e]
    ex      de,hl                           ;[c72f]     DE = l_cur_pos + $0800
                                            ;       }
label_c730:
    ; Write cursor position into CRTC register (DE = l_cur_pos)
    ld      a,$0e                           ;[c730] CRTC R14: cursor position HI
    out     ($a0),a                         ;[c732]
    ld      a,d                             ;[c734]
    out     ($a1),a                         ;[c735]

    ld      a,$0f                           ;[c737] CRTC R15: cursor position LO
    out     ($a0),a                         ;[c739]
    ld      a,e                             ;[c73b]
    out     ($a1),a                         ;[c73c]

    push    de                              ;[c73e]
    pop     iy                              ;[c73f] iy = l_cur_pos
    ret                                     ;[c741]

    ; SUBROUTINE $C742
    ; Update CRTC video memory base address register using HL
    ; Input:
    ;   - HL: CRTC base address register for video memory
    ; Output:
    ;   - IX: CRTC base address register for video memory
    ld      a,h                             ;[c742]
    and     $07                             ;[c743] clamp HL to [0;2048[
    ld      h,a                             ;[c745]
    call    $c75b                           ;[c746] wait for sync ?
    ld      a,$0c                           ;[c749] CRTC start address H
    out     ($a0),a                         ;[c74b]
    ld      a,h                             ;[c74d]
    out     ($a1),a                         ;[c74e]
    ld      a,$0d                           ;[c750] CRTC start address L
    out     ($a0),a                         ;[c752]
    ld      a,l                             ;[c754]
    out     ($a1),a                         ;[c755]
    push    hl                              ;[c757]
    pop     ix                              ;[c758]
    ret                                     ;[c75a]

    ; SUBROUTINE $C75D
    in      a,($a0)                         ;[c75b] read from CRTC (any register will do)
                                            ;       this resets the frame sync detection circuit
                                            ;       (74LS109 JK in L9)
label_c75d:
    in      a,($82)                         ;[c75d] read PORTC
    bit     1,a                             ;[c75f]
    jr      z,label_c75d                    ;[c761] wait PORTC:1 == 1 (next frame)
    ret                                     ;[c763]

    ; SUBROUTINE C764; display_clear()
    ; This routine clears the display (fills it with empty spaces),
    ; and resets current cursor (row,column) indexes at ($ffcb,$ffca) ("current_row","current_column")
    ; 24 rows x 80 columns
    ; Input:
    ;   IX: cursor pointer
    ; Output:
    ;   None
    ld      bc,$0780                        ;[c764] 24*80 = "1920"
    push    ix                              ;[c767]
    pop     hl                              ;[c769] hl <- ix
    ld      de,$2000                        ;[c76a]
    call    $c715                           ;[c76d] HL = display_cursor_to_video_mem_ptr()
label_c770:
    ld      (hl),d                          ;[c770] write $20 in video memory: " "
    in      a,($81)                         ;[c771]
    set     7,a                             ;[c773]
    out     ($81),a                         ;[c775] PORTB |= 0x80 (bank 7 in)
    ld      (hl),e                          ;[c777] write 0 in bank switched video memory (?)
    res     7,a                             ;[c778] PORTB &= ~0x80 (bank 7 out)
    out     ($81),a                         ;[c77a]
    inc     hl                              ;[c77c] move to next video memory address
    bit     3,h                             ;[c77d] if (HL < 2048)
    call    z,$c715                         ;[c77f]     display_cursor_to_video_mem_ptr()
    dec     bc                              ;[c782]
    ld      a,b                             ;[c783]
    or      c                               ;[c784]
    jr      nz,label_c770                   ;[c785] repeat from $c770 while bc > 0
    push    ix                              ;[c787]
    pop     hl                              ;[c789] hl <- ix
    call    $c71c                           ;[c78a] crtc_update_cursor_position()

    xor     a                               ;[c78d]
    ld      ($ffca),a                       ;[c78e] "current_column" = 0
    ld      ($ffcb),a                       ;[c791] "current_row" = 0
    ret                                     ;[c794]

    ; SUBROUTINE C795: bank_video_attribute_memory()
    ; Bank out memory chip in H8-H9-H10.
    ; Bank in memory chip in J8-J9-J10.
    ; Enable access to the character attribute video memory.
    push    af                              ;[c795]
    in      a,($81)                         ;[c796]
    set     7,a                             ;[c798]
    out     ($81),a                         ;[c79a] PORTB |= 0x80 (bank 7 in)
    pop     af                              ;[c79c]
    ret                                     ;[c79d]

    ; SUBROUTINE C79E: bank_video_char_memory()
    ; Bank out memory chip in J8-J9-J10.
    ; Bank in memory chip in H8-H9-H10.
    ; Enable access to the character video memory.
    push    af                              ;[c79e]
    in      a,($81)                         ;[c79f]
    res     7,a                             ;[c7a1]
    out     ($81),a                         ;[c7a3] PORTB &= ~0x80 (bank 7 out)
    pop     af                              ;[c7a5]
    ret                                     ;[c7a6]

    push    de                              ;[c7a7]
    push    bc                              ;[c7a8]
    ld      a,$50                           ;[c7a9]
    cpl                                     ;[c7ab]
    ld      d,$ff                           ;[c7ac]
    ld      e,a                             ;[c7ae]
    inc     de                              ;[c7af]
    call    $c7b6                           ;[c7b0] copy_status_bar()
    pop     bc                              ;[c7b3]
    pop     de                              ;[c7b4]
    ret                                     ;[c7b5]

    ; SUBROUTINE C7B6; copy_status_bar() -- second stage
    ; Copy bottom status bar one line below (both chars and their attributes)
    ; Input:
    ;   - DE
    ld      a,($ffd0)                       ;[c7b6]
    ld      c,a                             ;[c7b9]
    call    $c6f1                           ;[c7ba] display_add_row_column()
    push    hl                              ;[c7bd]
    add     hl,de                           ;[c7be]
    ex      de,hl                           ;[c7bf]
    pop     hl                              ;[c7c0]
    ld      a,($ffd0)                       ;[c7c1]
    ld      b,a                             ;[c7c4]
    ld      a,($ffcf)                       ;[c7c5] read "last column" - 1 (= 0x4f)
    sub     b                               ;[c7c8]
    inc     a                               ;[c7c9]
    ld      b,a                             ;[c7ca] B = 0x50 (?)
    call    $c715                           ;[c7cb] display_cursor_to_video_mem_ptr()
    ex      de,hl                           ;[c7ce]
    call    $c715                           ;[c7cf] display_cursor_to_video_mem_ptr()
    ex      de,hl                           ;[c7d2]
    push    bc                              ;[c7d3]
    push    de                              ;[c7d4]
    push    hl                              ;[c7d5]
    ld      c,$02                           ;[c7d6] C = 2 (copy operation is performed twice, one time for chars and the other for attributes)
label_c7d8:                                 ;       copy bottom status bar to last row
                                            ;       (remember that whole display has just been moved one line up)
    ld      a,(hl)                          ;[c7d8] for (B = 0x50; B > 0; --B) {
    ld      (de),a                          ;[c7d9]
    inc     de                              ;[c7da]
    ld      a,d                             ;[c7db]
    and     $07                             ;[c7dc]
    or      $d0                             ;[c7de]
    ld      d,a                             ;[c7e0]
    inc     hl                              ;[c7e1]
    bit     3,h                             ;[c7e2]     if (HL < 2048)
    call    z,$c715                         ;[c7e4]         display_cursor_to_video_mem_ptr()
    djnz    label_c7d8                      ;[c7e7] }
    dec     c                               ;[c7e9] if (--C != 0) {
    jr      z,label_c7f6                    ;[c7ea]     /*  bank switch enable text attribute memory,
    ld      a,c                             ;[c7ec]         and copy them too :-) */
    pop     hl                              ;[c7ed]
    pop     de                              ;[c7ee]
    pop     bc                              ;[c7ef]
    ld      c,a                             ;[c7f0]
    call    $c795                           ;[c7f1]     bank_video_attribute_memory()
    jr      label_c7d8                      ;[c7f4] }
label_c7f6:
    call    $c79e                           ;[c7f6] bank_video_char_memory() /* restore video char memory bank */
    ret                                     ;[c7f9]

    ; SUBROUTINE C7FA
    ; Copy status bar one line below (first stage)
    push    de                              ;[c7fa]
    push    bc                              ;[c7fb]
    ld      de,$0050                        ;[c7fc]
    call    $c7b6                           ;[c7ff] copy_status_bar()
    pop     bc                              ;[c802]
    pop     de                              ;[c803]
    ret                                     ;[c804]

    ; SUBROUTINE C805
    ; Clear display (?)
    ld      a,e                             ;[c805]
    sub     c                               ;[c806]
    inc     a                               ;[c807]
    ld      e,a                             ;[c808] E = E - C + 1
    ld      a,d                             ;[c809]
    sub     b                               ;[c80a]
    inc     a                               ;[c80b]
    ld      d,a                             ;[c80c] D = D - B + 1
label_c80d:
    call    $c6f1                           ;[c80d] display_add_row_column()
label_c810:
    call    $c715                           ;[c810] display_cursor_to_video_mem_ptr()
    ld      (hl),$20                        ;[c813] write ' ' directly in char video mem
    call    $c795                           ;[c815] bank_video_attribute_memory()
    ld      (hl),$00                        ;[c818] write 0x00 in attribute video memory (no attribute)
    call    $c79e                           ;[c81a] bank_video_char_memory()
    inc     hl                              ;[c81d] increment video mem pointer
    dec     e                               ;[c81e]
    jr      nz,label_c810                   ;[c81f]
    inc     b                               ;[c821]
    ld      a,($ffd0)                       ;[c822]
    ld      c,a                             ;[c825]
    ld      a,($ffcf)                       ;[c826]
    sub     c                               ;[c829]
    inc     a                               ;[c82a]
    ld      e,a                             ;[c82b]
    dec     d                               ;[c82c]
    jr      nz,label_c80d                   ;[c82d]
    ret                                     ;[c82f]

    ld      a,($ffcd)                       ;[c830] read "number of rows" of display
    ld      b,a                             ;[c833]
    ld      a,($ffce)                       ;[c834] read "current row" (?)
    cp      b                               ;[c837]
    jr      z,label_c845                    ;[c838] if (current_row == number_of_rows), jump
    ld      d,a                             ;[c83a]
    ld      a,b                             ;[c83b]
    sub     d                               ;[c83c]
    ld      d,a                             ;[c83d]
label_c83e:
    dec     b                               ;[c83e] 05
    call    $c7fa                           ;[c83f] cd fa c7
    dec     d                               ;[c842] 15
    jr      nz,label_c83e                   ;[c843] 20 f9
label_c845:
    ld      a,($ffce)                       ;[c845] read "current row" (?)
    ld      b,a                             ;[c848]
    ld      d,a                             ;[c849]
    ld      a,($ffd0)                       ;[c84a] 3a d0 ff
    ld      c,a                             ;[c84d] 4f
    ld      a,($ffcf)                       ;[c84e] 3a cf ff
    ld      e,a                             ;[c851] 5f
    call    $c805                           ;[c852] cd 05 c8
    ret                                     ;[c855] c9

    push    bc                              ;[c856] c5
    ld      b,$1e                           ;[c857] 06 1e
    ld      c,$0f                           ;[c859] 0e 0f
    dec     c                               ;[c85b] 0d
    jp      nz,$c85b                        ;[c85c] c2 5b c8
    dec     b                               ;[c85f] 05
    jp      nz,$c859                        ;[c860] c2 59 c8
    pop     bc                              ;[c863] c1
    ret                                     ;[c864] c9

    ; CRTC Configuration Table
crtc_cfg_base:
    ; R0  Horizontal total character - 1 ; 100 - 1 = "99"
    BYTE $63                                ;[c865]
    ; R1  Horizontal disp character "80"
    BYTE $50                                ;[c866]
    ; R2  Horizontal sync pulse position
    BYTE $54                                ;[c867]
    ; R3  Horizontal sync pulse length
    BYTE $aa                                ;[c868]
    ; R4  Vertical total character
    BYTE $19                                ;[c869]
    ; R5  Total raster adjust
    BYTE $06                                ;[c86a]
    ; R6  Vertical displayed characters
    BYTE $19                                ;[c86b]
    ; R7  Vertical sync pulse position
    BYTE $19                                ;[c86c]
    ; R8  Interlaced mode (not interlaced)
    BYTE $00                                ;[c86d]
    ; R9  Maximum raster (?)
    BYTE $0d                                ;[c86e]
    ; R10 Cursor start raster
    BYTE $0d                                ;[c86f]
    ; R11 Cursor end raster
    BYTE $0d                                ;[c870]
    ; R12 Start address HI
    BYTE $00                                ;[c871]
    ; R13 Start address LO
    BYTE $00                                ;[c872]
    ; R14 Cursor HI
    BYTE $00                                ;[c873]
    ; R15 Cursor LO
    BYTE $00                                ;[c874]


    ; set magenta:3 => enable text attribute "stretch"
    ld      a,($ffd1)                       ;[c875]
    set     3,a                             ;[c878]
    ld      ($ffd1),a                       ;[c87a]

    ld      a,($ffca)                       ;[c87d] read "current_column"
    ld      c,a                             ;[c880]
    rra                                     ;[c881]
    jr      nc,label_c88b                   ;[c882]
    inc     iy                              ;[c884]
    inc     c                               ;[c886]
    ld      a,c                             ;[c887]
    ld      ($ffca),a                       ;[c888] store "current_column"
label_c88b:
    xor     a                               ;[c88b] af
    ret                                     ;[c88c] c9

    ; SUBROUTINE C88D; CRTC initialization
    ; Return:
    ;   a = 0
    ld      hl,crtc_cfg_base                ;[c88d] CRTC configuration table addr
    ld      b,$10                           ;[c890] CRTC counter, $10 = # of entries in crtc_cfg table
    ld      c,$a1                           ;[c892] address CRTC with RS=1 (data)
    xor     a                               ;[c894] clear a
label_c895:
    out     ($a0),a                         ;[c895] set CRTC internal register address to A (RS=0)
    inc     a                               ;[c897] move to next address
    ; OUTI: outputs (HL++) to port in C, then decrements B and sets Z if B=0
    outi                                    ;[c898] output data in HL to CRTC register
    jr      nz,label_c895                   ;[c89a] loop while B!=0
    ;
    ld      ix,$0000                        ;[c89c] initialize IX = 0 (linear cursor address)
    call    $c764                           ;[c8a0] display_clear()
    call    $c8b6                           ;[c8a3] crtc_set_vertical_lines()
    ld      hl,$0000                        ;[c8a6]
    call    $c71c                           ;[c8a9] crtc_update_cursor_position()

    ; clear magenta:3 => disable text attribute "stretch"
    ld      a,($ffd1)                       ;[c8ac]
    res     3,a                             ;[c8af]
    ld      ($ffd1),a                       ;[c8b1]

    xor     a                               ;[c8b4] clear a when return
    ret                                     ;[c8b5]

    ; SUBROUTINE C8B6; crtc_set_vertical_lines()
    ; Configure CRTC number of rows (24)
    ld      a,$06                           ;[c8b6]
    out     ($a0),a                         ;[c8b8] Select R6 CRTC register
    ld      a,$18                           ;[c8ba]
    out     ($a1),a                         ;[c8bc] Set 24 character lines
    ret                                     ;[c8be]

    ; SUBROUTINE C8BF: display_init_variables()
    ; Initialize some display-related stuff.
    xor     a                               ;[c8bf] A = 0

    ld      ($ffce),a                       ;[c8c0] var$ffce = 0
    ld      ($ffd0),a                       ;[c8c3] var$ffd0 = 0
    ld      ($ffc9),a                       ;[c8c6] var$ffc9 = 0

    ld      a,$17                           ;[c8c9]
    ld      ($ffcd),a                       ;[c8cb] "number of rows" of display = 24
    ret                                     ;[c8ce]

    ld      b,$04                           ;[c8cf] 06 04
    call    $c75b                           ;[c8d1] cd 5b c7
    xor     a                               ;[c8d4] af
    ld      c,$a1                           ;[c8d5] 0e a1
label_c8d7:
    out     ($a0),a                         ;[c8d7] d3 a0
    inc     a                               ;[c8d9] 3c
    outi                                    ;[c8da] ed a3
    jr      nz,label_c8d7                   ;[c8dc] 20 f9
    ret                                     ;[c8de] c9

    ; some display-related stuff
    ld      a,($ffd9)                       ;[c8df] read "blues"
    or      a                               ;[c8e2]
    jr      nz,label_c8ea                   ;[c8e3]
    inc     a                               ;[c8e5]
    ld      ($ffd9),a                       ;[c8e6] store "blues"
    ret                                     ;[c8e9]

label_c8ea:
    ld      a,c                             ;[c8ea]
    and     $0f                             ;[c8eb]
    rlca                                    ;[c8ed]
    rlca                                    ;[c8ee]
    rlca                                    ;[c8ef]
    rlca                                    ;[c8f0]
    cpl                                     ;[c8f1]
    ld      b,a                             ;[c8f2]
    ld      a,($ffd1)                       ;[c8f3] magenta: change text attributes
    and     b                               ;[c8f6]
    ld      ($ffd1),a                       ;[c8f7]
    xor     a                               ;[c8fa]
    ret                                     ;[c8fb]

    ; SUBROUTINE C8FC: reset magenta => clear all text attributes
    xor     a                               ;[c8fc]
    ld      ($ffd1),a                       ;[c8fd]
    ret                                     ;[c900]

    ; SUBROUTINE C901
    ; Read a value and do things with it :TM:
    ld      a,($ffd9)                       ;[c901] read "blues" content
    ld      b,a                             ;[c904] and remember its value in B register

    ld      d,$00                           ;[c905]
    ld      e,a                             ;[c907] DE = A
    ld      hl,$ffd9                        ;[c908] HL = &"blues"
    add     hl,de                           ;[c90b] HL += A
    ld      a,c                             ;[c90c]
    sub     $20                             ;[c90d] C -= 32
    ld      (hl),a                          ;[c90f] store A in (HL)
                                            ; blues[blues[0]] = (C - 0x20)

    ld      a,b                             ;[c910]
    inc     a                               ;[c911]
    ld      ($ffd9),a                       ;[c912] store A in "blues"
    ret                                     ;[c915]

    ; SUBROUTINE C916: crtc_write_register()
    ; Input:
    ;   B = CRTC internal register address
    ;   C = content
    ld      a,b                             ;[c916]
    out     ($a0),a                         ;[c917]
    ld      a,c                             ;[c919]
    out     ($a1),a                         ;[c91a]
    ret                                     ;[c91c]

    ; SUBROUTINE C91D: display_mangle_some_banked_memory()
    ; Mangle some video memory
    call    $c6f1                           ;[c91d] display_add_row_column(row = cyan[0], column = cyan[1]) (preserve A)
    push    hl                              ;[c920] remember result for later
    ld      b,d                             ;[c921]
    ld      c,e                             ;[c922]
    call    $c6f1                           ;[c923] display_add_row_column(row = cyan[2], column = E) (preserve A)
    pop     de                              ;[c926] restore result of first call in DE,
    push    de                              ;[c927]     ... and also remember for later
    or      a                               ;[c928] clear carry flag
    sbc     hl,de                           ;[c929] compute difference (second call) - (first call)
    inc     hl                              ;[c92b] but add +1
    ex      de,hl                           ;[c92c] DE = difference
    pop     hl                              ;[c92d] restore result of first call in HL
    ld      b,a                             ;[c92e] B = A (the same from caller, is always preserved)
    call    $c795                           ;[c92f] bank_video_attribute_memory()

                                            ;       do {
label_c932:
    call    $c715                           ;[c932]     display_cursor_to_video_mem_ptr()

    ld      a,(hl)                          ;[c935]     mangle video memory, OR with A (passed by caller)
    or      b                               ;[c936]
    ld      (hl),a                          ;[c937]

    inc     hl                              ;[c938]     next address
    dec     de                              ;[c939]     loop index--

    ld      a,d                             ;[c93a]
    or      e                               ;[c93b]
    jr      nz,label_c932                   ;[c93c] } while (DE != 0);

    call    $c79e                           ;[c93e] bank_video_char_memory()
    ret                                     ;[c941]

    ; SUBROUTINE C942: crtc_cursor_start_raster()
    ; Changes cursor raster settings (blinking, period, ...)
    ; if (C == $44), command = $40, else...
    ld      a,c                             ;[c942]
    cp      $44                             ;[c943]
    jr      nz,label_c94b                   ;[c945]
    ld      c,$40                           ;[c947] (cursor blink "on", speed "slow")
    jr      label_c984                      ;[c949] execute
    ; ... else if (C == $45), command = $60, else...
label_c94b:
    cp      $45                             ;[c94b]
    jr      nz,label_c953                   ;[c94d]
    ld      c,$60                           ;[c94f] (cursor blink "on", speed "fast")
    jr      label_c984                      ;[c951] execute
    ; ... else if (C == $46), command = $20, else ...
label_c953:
    cp      $46                             ;[c953]
    jr      nz,label_c95b                   ;[c955]
    ld      c,$20                           ;[c957] (cursor blink "off", "speed" "fast")
    jr      label_c984                      ;[c959] execute
    ; ... else, ??? restore default settings based on IO port read ???
label_c95b:
    ld      a,($c86f)                       ;[c95b] load default CRTC R10 configuration
    ld      d,a                             ;[c95e]
    in      a,($d6)                         ;[c95f]
    bit     5,a                             ;[c961]
    jr      z,label_c967                    ;[c963]
    ld      d,$03                           ;[c965]
label_c967:
    bit     6,a                             ;[c967]
    jr      z,label_c96f                    ;[c969]
    set     5,d                             ;[c96b]
    set     6,d                             ;[c96d]
label_c96f:
    ld      a,d                             ;[c96f]
    ld      ($ffd3),a                       ;[c970]
    ld      b,$0a                           ;[c973]
    ld      c,a                             ;[c975]
    call    $c916                           ;[c976] crtc_write_register()
    ld      a,($c870)                       ;[c979]
    ld      c,a                             ;[c97c]
    ld      b,$0b                           ;[c97d]
    call    $c916                           ;[c97f] crtc_write_register()
    xor     a                               ;[c982]
    ret                                     ;[c983]

    ; execute command
label_c984:
    ; set bit [5:6] of $ffd3, accordingly to passed C command
    ld      a,($ffd3)                       ;[c984]
    and     $9f                             ;[c987]
    or      c                               ;[c989]
    ld      ($ffd3),a                       ;[c98a]

    ; set cursor blink and cycle parameters
    ld      c,a                             ;[c98d]
    ld      b,$0a                           ;[c98e]
    call    $c916                           ;[c990] crtc_write_register()
    xor     a                               ;[c993] return 0
    ret                                     ;[c994]

    ; SUBROUTINE C995
    ; set magenta:0 => enable text attribute "invert"
    ld      hl,$ffd1                        ;[c995]
    set     0,(hl)                          ;[c998]
    xor     a                               ;[c99a]
    ret                                     ;[c99b]

    ; SUBROUTINE C99C
    ; reset magenta:0 => disable text attribute "invert"
    ld      hl,$ffd1                        ;[c99c] 21 d1 ff
    res     0,(hl)                          ;[c99f] cb 86
    xor     a                               ;[c9a1] af
    ret                                     ;[c9a2] c9

    ; SUBROUTINE C9A3
    ; set magenta:2
    ld      hl,$ffd1                        ;[c9a3]
    set     2,(hl)                          ;[c9a6]
    xor     a                               ;[c9a8]
    ret                                     ;[c9a9]

    ; SUBROUTINE C9AA
    ; reset magenta:2
    ld      hl,$ffd1                        ;[c9aa]
    res     2,(hl)                          ;[c9ad]
    xor     a                               ;[c9af]
    ret                                     ;[c9b0]

    ; SUBROUTINE C9B1
    ; set magenta 1 => enable text attribute "blink"
    ld      hl,$ffd1                        ;[c9b1]
    set     1,(hl)                          ;[c9b4]
    xor     a                               ;[c9b6]
    ret                                     ;[c9b7]

    ; SUBROUTINE C9B8
    ; reset magenta 1 => disable text attribute "blink"
    ld      hl,$ffd1                        ;[c9b8]
    res     1,(hl)                          ;[c9bb]
    xor     a                               ;[c9bd]
    ret                                     ;[c9be]

    ; SUBROUTINE C9BF
    ; set magenta:4 => enable text attribute "underline"
    ld      a,($ffd1)                       ;[c9bf]
    and     $8f                             ;[c9c2]
    or      $10                             ;[c9c4]
    ld      ($ffd1),a                       ;[c9c6]
    xor     a                               ;[c9c9]
    ret                                     ;[c9ca]

    ; SUBROUTINE C9CB
    ; reset magenta[4:6] => disable text attribute "blink, underline and hide" ?
    ld      a,($ffd1)                       ;[c9cb]
    and     $8f                             ;[c9ce]
    or      $00                             ;[c9d0]
    ld      ($ffd1),a                       ;[c9d2]
    xor     a                               ;[c9d5]
    ret                                     ;[c9d6]

    ; SUBROUTINE C9D7
    ; set magenta:5 => enable text attribute "blink and underline"
    ld      a,($ffd1)                       ;[c9d7]
    and     $8f                             ;[c9da]
    or      $20                             ;[c9dc]
    ld      ($ffd1),a                       ;[c9de]
    xor     a                               ;[c9e1]
    ret                                     ;[c9e2]

    ; Handle second stage of escaping sequence
label_c9e3:
    call    $ca01                           ;[c9e3] where does this go?

    cp      $01                             ;[c9e6]
    jr      nz,label_c9eb                   ;[c9e8]
    ld      a,c                             ;[c9ea] C (hopefully) is the char we want to print
label_c9eb:
    ld      ($ffd8),a                       ;[c9eb] write C to "ongoing escape"

    ; if ("ongoing escape" < $31 || "ongoing escape" >= $60), then
    ;   terminate escaping
    cp      $60                             ;[c9ee]
    jp      nc,label_ca70                   ;[c9f0] jump if A >= $60
    sub     $31                             ;[c9f3]
    jp      c,label_ca70                    ;[c9f5] jump if A < $31

    ; ... else, if $31 <= "ongoing escape" < $60,
    ;       "ongoing escape" -= $31 (from above),
    ;       and finally perform escape
    ; The value is clamped in this range because it will be used to index a jump table.
    call    $ca05                           ;[c9f8]

    or      a                               ;[c9fb]
    jr      z,label_ca70                    ;[c9fc] if (A == 0), terminate escape sequence, else...
    jp      $c6a3                           ;[c9fe] ... save_index_restore_registers_and_ret(), and continue escaping next time

    ; SUBROUTINE:
    ld      hl,($bffa)                      ;[ca01] 2a fa bf
    jp      (hl)                            ;[ca04] e9

    ; Perform escape.
    ; Extract an address from the following address table, and jump there
    ;   first compute index based on A
    add     a                               ;[ca05]
    ld      hl,$ca12                        ;[ca06]
    ld      d,$00                           ;[ca09]
    ld      e,a                             ;[ca0b]
    add     hl,de                           ;[ca0c] HL = $CA12 + 2 * A
    ;   read address
    ld      e,(hl)                          ;[ca0d]
    inc     hl                              ;[ca0e]
    ld      d,(hl)                          ;[ca0f]
    ex      de,hl                           ;[ca10]
    ;   jump there
    jp      (hl)                            ;[ca11]

    ; Second stage escape address table     ;[ca12]
    WORD $cd42  ; use 25 rows
    WORD $cd46  ; use 24 rows
    WORD $ca7a  ; do nothing
    WORD $ca7a  ; do nothing
    WORD $ca7a  ; do nothing
    WORD $ca7c
    WORD $c9bf  ; set magenta:4
    WORD $cc7f
    WORD $ca7a  ; do nothing
    WORD $cad4
    WORD $caf2
    WORD $cb1c
    WORD $cb6a
    WORD $cb9f
    WORD $cbbb
    WORD $ca7c
    WORD $c875  ; set magenta:3, and some other stuff
    WORD $c8ac  ; clear magenta:3
    WORD $ca7a  ; do nothing
    WORD $c942
    WORD $c942
    WORD $c942
    WORD $c942
    WORD $c995  ; set magenta:0
    WORD $c99c  ; reset magenta:0
    WORD $c9a3  ; set magenta:2
    WORD $c9aa  ; reset magenta:2
    WORD $c9b1  ; set magenta:1
    WORD $c9b8  ; reset magenta:1
    WORD $cc45
    WORD $ca7a  ; do nothing
    WORD $ccab
    WORD $ccdf
    WORD $ca7a  ; do nothing
    WORD $cbda
    WORD $cc04
    WORD $cc1b
    WORD $cc33  ; clear display ?
    WORD $c9bf  ; set magenta:4
    WORD $c9cb  ; reset magenta[4:6]
    WORD $c9d7  ; set magenta:5
    WORD $c9bf  ; set magenta:4
    WORD $cc7f
    WORD $c8df
    WORD $c8fc  ; reset all bits of magenta
    WORD $cc95
    WORD $cd27

    ; Terminate escape.
    ; This routine resets the "ongoing escape" status,
    ; then restores user's registers and returns.
label_ca70:
    xor     a                               ;[ca70]
    ld      ($ffd8),a                       ;[ca71] set "no ongoing escaping"
    ld      ($ffd9),a                       ;[ca74] "blues" = 0
    jp      $c6a3                           ;[ca77] save_index_restore_registers_and_ret()

    ; SUBMONSTER CA7A: return 0.
    ; can be reached with a call and with a jmp
    xor     a                               ;[ca7a]
    ret                                     ;[ca7b] return 0

    call    $cdd7                           ;[ca7c] increment_blues_if_zero() ; if (blues == 0), return to $C9FB

    cp      $01                             ;[ca7f] fe 01
    jr      nz,label_ca8c                   ;[ca81] 20 09
    ld      a,c                             ;[ca83] 79
    cp      $31                             ;[ca84] fe 31
    jr      c,label_cab0                    ;[ca86] 38 28
    cp      $36                             ;[ca88] fe 36
    jr      nc,label_cab0                   ;[ca8a] 30 24
label_ca8c:
    call    $cab5                           ;[ca8c] cd b5 ca
    or      a                               ;[ca8f] b7
    ret     nz                              ;[ca90] c0
    ld      a,($ffda)                       ;[ca91] 3a da ff
    and     $0f                             ;[ca94] e6 0f
    dec     a                               ;[ca96] 3d
    add     a                               ;[ca97] 87
    ld      b,a                             ;[ca98] 47
    add     a                               ;[ca99] 87
    ld      c,a                             ;[ca9a] 4f
    add     a                               ;[ca9b] 87
    add     b                               ;[ca9c] 80
    add     c                               ;[ca9d] 81
    add     $04                             ;[ca9e] c6 04
    ld      hl,($bff4)                      ;[caa0] 2a f4 bf
    ld      d,$00                           ;[caa3] 16 00
    ld      e,a                             ;[caa5] 5f
    add     hl,de                           ;[caa6] 19
    ex      de,hl                           ;[caa7] eb
    ld      hl,$ffdb                        ;[caa8] 21 db ff
    ld      bc,$0009                        ;[caab] 01 09 00
    ldir                                    ;[caae] ed b0
label_cab0:
    call    $cd51                           ;[cab0] cd 51 cd
    xor     a                               ;[cab3] af
    ret                                     ;[cab4] c9

    call    $c901                           ;[cab5] cd 01 c9
    ld      (hl),c                          ;[cab8] 71
    cp      $0a                             ;[cab9] fe 0a
    ret     nz                              ;[cabb] c0
    ld      hl,$ffdb                        ;[cabc] 21 db ff
    ld      b,$08                           ;[cabf] 06 08
label_cac1:
    ld      a,(hl)                          ;[cac1] 7e
    inc     hl                              ;[cac2] 23
    cp      $7f                             ;[cac3] fe 7f
    jr      z,label_cacd                    ;[cac5] 28 06
    djnz    label_cac1                      ;[cac7] 10 f8
    ld      (hl),$7f                        ;[cac9] 36 7f
    jr      label_cad2                      ;[cacb] 18 05
label_cacd:
    ld      hl,$ffe3                        ;[cacd] 21 e3 ff
    ld      (hl),$20                        ;[cad0] 36 20
label_cad2:
    xor     a                               ;[cad2] af
    ret                                     ;[cad3] c9

    call    $cdd7                           ;[cad4] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    cp      $04                             ;[cad7] if ("blues" == $04)
    jr      z,label_cadf                    ;[cad9]     jump to $cadf
                                            ;       else
    call    $c901                           ;[cadb]     call to $c901
    ret                                     ;[cade]
label_cadf:
    ld      a,c                             ;[cadf]
    sub     $20                             ;[cae0]
    ld      e,a                             ;[cae2] E = C - 0x20
    ld      hl,$ffda                        ;[cae3]
    ld      b,(hl)                          ;[cae6] B = cyan[0]
    inc     hl                              ;[cae7]
    ld      c,(hl)                          ;[cae8] C = cyan[1]
    inc     hl                              ;[cae9]
    ld      d,(hl)                          ;[caea] D = cyan[2]
    ld      a,$01                           ;[caeb] A = 0x01
    call    $c91d                           ;[caed] display_mangle_some_banked_memory()
    xor     a                               ;[caf0]
    ret                                     ;[caf1] return 0

    call    $cdd7                           ;[caf2] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    cp      $02                             ;[caf5] fe 02
    jr      z,label_cafd                    ;[caf7] 28 04
    call    $c901                           ;[caf9] cd 01 c9
    ret                                     ;[cafc] c9

label_cafd:
    ld      a,c                             ;[cafd]
    sub     $20                             ;[cafe]
    ld      e,a                             ;[cb00]
    ld      a,($ffda)                       ;[cb01]
    ld      d,a                             ;[cb04]
    ld      a,($ffd3)                       ;[cb05]
    and     $60                             ;[cb08]
    or      d                               ;[cb0a]
    ld      ($ffd3),a                       ;[cb0b]
    ld      c,a                             ;[cb0e]
    ld      b,$0a                           ;[cb0f]
    call    $c916                           ;[cb11] crtc_write_register()
    ld      c,e                             ;[cb14]
    ld      b,$0b                           ;[cb15]
    call    $c916                           ;[cb17] crtc_write_register()
    xor     a                               ;[cb1a]
    ret                                     ;[cb1b]

    call    $cdd7                           ;[cb1c] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    cp      $04                             ;[cb1f] if ("blues" == $04)
    jr      z,label_cb27                    ;[cb21]     goto $CB27
                                            ;       else
    call    $c901                           ;[cb23]     call to $c901
    ret                                     ;[cb26]

label_cb27:
    ld      a,c                             ;[cb27]
    sub     $20                             ;[cb28]
    ld      e,a                             ;[cb2a]
    ld      a,$4f                           ;[cb2b] A = 79
    cp      e                               ;[cb2d]
    jr      c,label_cb68                    ;[cb2e] if (E > 79), return 0
    ld      hl,$ffda                        ;[cb30]
    ld      b,(hl)                          ;[cb33] B = cyan[0]
    inc     hl                              ;[cb34]
    ld      a,(hl)                          ;[cb35] A = cyan[1]
    cp      $18                             ;[cb36]
    jr      nc,label_cb68                   ;[cb38] if (A >= 24), return 0
    ld      c,a                             ;[cb3a] C = cyan[1]
    inc     hl                              ;[cb3b]
    ld      d,(hl)                          ;[cb3c] D = cyan[2]
    ld      a,c                             ;[cb3d]
    cp      b                               ;[cb3e]
    jr      c,label_cb68                    ;[cb3f] if (B > cyan[1]), return 0
    ld      a,e                             ;[cb41]
    cp      d                               ;[cb42]
    jr      c,label_cb68                    ;[cb43] if (D > E), return 0

    ld      hl,$ffcd                        ;[cb45]
    ld      (hl),c                          ;[cb48] write "number of rows" of display (at $ffcd)
    inc     hl                              ;[cb49]
    ld      (hl),b                          ;[cb4a] at $ffce
    inc     hl                              ;[cb4b]
    ld      (hl),e                          ;[cb4c] at $ffcf
    inc     hl                              ;[cb4d]
    ld      (hl),d                          ;[cb4e] at $ffd0
    ld      a,$01                           ;[cb4f]
    ld      ($ffc9),a                       ;[cb51]

    ld      a,$50                           ;[cb54] A = 80
    sub     e                               ;[cb56]
    ld      e,a                             ;[cb57]
    ld      a,d                             ;[cb58]
    add     e                               ;[cb59]

    ; if magenta:3 == 0, jump label_cb62
    ld      hl,$ffd1                        ;[cb5a]
    bit     3,(hl)                          ;[cb5d]
    jr      z,label_cb62                    ;[cb5f]

    add     a                               ;[cb61]
label_cb62:
    ld      ($ffc8),a                       ;[cb62]
    call    $cc1b                           ;[cb65]
label_cb68:
    xor     a                               ;[cb68]
    ret                                     ;[cb69]

    ; SUBROUTINE CB6A
    call    $cdd7                           ;[cb6a] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    cp      $02                             ;[cb6d] if ("blues" == $02),
    jr      z,label_cb75                    ;[cb6f]     goto $CB75
                                            ;       else
    call    $c901                           ;[cb71]     call to $C901
    ret                                     ;[cb74]
label_cb75:
    ld      a,c                             ;[cb75]
    sub     $20                             ;[cb76]
    ld      c,a                             ;[cb78] C -= 32
    ld      a,$4f                           ;[cb79] A = 79 (80 columns - 1)
    cp      c                               ;[cb7b]
    jr      c,label_cb9d                    ;[cb7c] if A >= C
    ld      a,($ffd1)                       ;[cb7e]
    bit     3,a                             ;[cb81]
    jr      z,label_cb88                    ;[cb83]     if (magenta:3)
    ld      a,c                             ;[cb85]
    add     a                               ;[cb86]
    ld      c,a                             ;[cb87]         C *= 2
label_cb88:
    ld      a,($ffda)                       ;[cb88]     read cyan[0]
    cp      $19                             ;[cb8b]     compare cyan[0] with 25 (number of display rows + 1)
    jr      nc,label_cb9d                   ;[cb8d]     if cyan[0] <= 25, then
    ld      b,a                             ;[cb8f]         current_row = cyan[0]
    ld      ($ffcb),a                       ;[cb90]         store current_row in var$FFCB
    ld      a,c                             ;[cb93]
    ld      ($ffca),a                       ;[cb94]         store current_column in var$FFCA
    call    $c6f1                           ;[cb97]         display_add_row_column(current_row, current_column)
    call    $c71c                           ;[cb9a]         crtc_update_cursor_position()
label_cb9d:
    xor     a                               ;[cb9d] A = 0 (return "ok")
    ret                                     ;[cb9e]

    call    $cdd7                           ;[cb9f] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    ld      a,c                             ;[cba2]
    sub     $20                             ;[cba3]
    ld      c,a                             ;[cba5]
    ld      a,$4f                           ;[cba6]
    cp      c                               ;[cba8]
    jr      c,label_cbb9                    ;[cba9]
    ld      a,($ffcb)                       ;[cbab] write "current_row"
    ld      b,a                             ;[cbae]
    ld      a,c                             ;[cbaf]
    ld      ($ffca),a                       ;[cbb0] load "current_column"
    call    $c6f1                           ;[cbb3] display_add_row_column()
    call    $c71c                           ;[cbb6] crtc_update_cursor_position()
label_cbb9:
    xor     a                               ;[cbb9] af
    ret                                     ;[cbba] c9

    call    $cdd7                           ;[cbbb] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    cp      $04                             ;[cbbe] if ("blues" == $04)
    jr      z,label_cbc6                    ;[cbc0]     goto CBC6
                                            ;       else
    call    $c901                           ;[cbc2]     call to $c901
    ret                                     ;[cbc5]

label_cbc6:
    ld      a,c                             ;[cbc6]
    sub     $20                             ;[cbc7]
    ld      e,a                             ;[cbc9]
    ld      hl,$ffda                        ;[cbca]
    ld      b,(hl)                          ;[cbcd] B = cyan[0]
    inc     hl                              ;[cbce]
    ld      c,(hl)                          ;[cbcf] C = cyan[1]
    inc     hl                              ;[cbd0]
    ld      d,(hl)                          ;[cbd1] D = cyan[2]
    ld      a,($ffd2)                       ;[cbd2] A = *($ffd2)
    call    $c91d                           ;[cbd5] display_mangle_some_banked_memory()
    xor     a                               ;[cbd8]
    ret                                     ;[cbd9]

    ; some display-related routine
    ld      bc,$0780                        ;[cbda]
    push    ix                              ;[cbdd]
    pop     hl                              ;[cbdf]
    call    $c795                           ;[cbe0] bank_video_attribute_memory()
    ld      a,($ffd2)                       ;[cbe3]
    ld      d,a                             ;[cbe6]
    ld      e,$20                           ;[cbe7]
label_cbe9:
    call    $c715                           ;[cbe9] display_cursor_to_video_mem_ptr()
    ld      a,(hl)                          ;[cbec]
    and     d                               ;[cbed]
    jr      nz,label_cbf9                   ;[cbee]
    ld      (hl),$00                        ;[cbf0]
    call    $c795                           ;[cbf2] bank_video_attribute_memory()
    ld      (hl),e                          ;[cbf5]
    call    $c795                           ;[cbf6] bank_video_attribute_memory()
label_cbf9:
    inc     hl                              ;[cbf9]
    dec     bc                              ;[cbfa]
    ld      a,b                             ;[cbfb]
    or      c                               ;[cbfc]
    jr      nz,label_cbe9                   ;[cbfd]
    call    $c79e                           ;[cbff] bank_video_char_memory()
    xor     a                               ;[cc02]
    ret                                     ;[cc03]

    ; some display-related routine
    ld      a,($ffd0)                       ;[cc04]
    ld      c,a                             ;[cc07]
    ld      a,($ffce)                       ;[cc08]
    ld      b,a                             ;[cc0b]
    ld      a,($ffcf)                       ;[cc0c]
    ld      e,a                             ;[cc0f]
    ld      a,($ffcd)                       ;[cc10] read "number of rows" of display
    ld      d,a                             ;[cc13]
    call    $c805                           ;[cc14]
    call    $cc1b                           ;[cc17]
    ret                                     ;[cc1a]

    ; some display-related routine
    ld      a,($ffce)                       ;[cc1b]
    ld      b,a                             ;[cc1e]
    ld      a,($ffd0)                       ;[cc1f]
    ld      c,a                             ;[cc22]
    call    $c6f1                           ;[cc23] display_add_row_column()
    call    $c71c                           ;[cc26] crtc_update_cursor_position()
    ld      a,b                             ;[cc29]
    ld      ($ffcb),a                       ;[cc2a] write "current_row"
    ld      a,c                             ;[cc2d]
    ld      ($ffca),a                       ;[cc2e] write "current_column"
    xor     a                               ;[cc31]
    ret                                     ;[cc32]

    ; some display-related routine
    ; reset display?
    call    $c764                           ;[cc33] display_clear()
    ld      a,$01                           ;[cc36]
    ld      ($ffc8),a                       ;[cc38] var$ffc8 = 1
    ld      a,$4f                           ;[cc3b]
    ld      ($ffcf),a                       ;[cc3d] var$ffcf = 79
    call    $c8bf                           ;[cc40] display_init_variables()
    xor     a                               ;[cc43]
    ret                                     ;[cc44] return 0

    ; some display-related routine
    ld      b,$00                           ;[cc45]
label_cc47:
    ld      c,$00                           ;[cc47]
label_cc49:
    push    bc                              ;[cc49] c5
    call    $cdf4                           ;[cc4a] cd f4 cd
    ld      c,d                             ;[cc4d] 4a
    push    de                              ;[cc4e] d5
    call    $ffa0                           ;[cc4f] cd a0 ff
    pop     de                              ;[cc52] d1
    pop     bc                              ;[cc53] c1
    bit     3,e                             ;[cc54] cb 5b
    jr      z,label_cc65                    ;[cc56] 28 0d
    inc     c                               ;[cc58] 0c
    ld      a,c                             ;[cc59] 79
    cp      $50                             ;[cc5a] fe 50
    jr      z,label_cc6b                    ;[cc5c] 28 0d
    push    bc                              ;[cc5e] c5
    ld      c,$20                           ;[cc5f] 0e 20
    call    $ffa0                           ;[cc61] cd a0 ff
    pop     bc                              ;[cc64] c1
label_cc65:
    inc     c                               ;[cc65] 0c
    ld      a,c                             ;[cc66] 79
    cp      $50                             ;[cc67] fe 50
    jr      nz,label_cc49                   ;[cc69] 20 de
label_cc6b:
    push    bc                              ;[cc6b] c5
    ld      c,$0d                           ;[cc6c] 0e 0d
    call    $ffa0                           ;[cc6e] cd a0 ff
    ld      c,$0a                           ;[cc71] 0e 0a
    call    $ffa0                           ;[cc73] cd a0 ff
    pop     bc                              ;[cc76] c1
    inc     b                               ;[cc77] 04
    ld      a,b                             ;[cc78] 78
    cp      $18                             ;[cc79] fe 18
    jr      nz,label_cc47                   ;[cc7b] 20 ca
    xor     a                               ;[cc7d] af
    ret                                     ;[cc7e] c9

    call    $cdd7                           ;[cc7f] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    ld      a,c                             ;[cc82]
    and     $0f                             ;[cc83]
    rlca                                    ;[cc85]
    rlca                                    ;[cc86]
    rlca                                    ;[cc87]
    rlca                                    ;[cc88]
    ld      b,a                             ;[cc89]
    ld      a,($ffd1)                       ;[cc8a] set text attributes from magenta
    and     $0f                             ;[cc8d]
    or      b                               ;[cc8f]
    ld      ($ffd1),a                       ;[cc90]
    xor     a                               ;[cc93]
    ret                                     ;[cc94]

    call    $cdd7                           ;[cc95] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    ld      a,c                             ;[cc98] 79
    cp      $30                             ;[cc99] fe 30
    jr      z,label_ccab                    ;[cc9b] 28 0e
    cp      $31                             ;[cc9d] fe 31
    jr      z,label_ccbd                    ;[cc9f] 28 1c
    cp      $32                             ;[cca1] fe 32
    jr      z,label_ccdf                    ;[cca3] 28 3a
    cp      $33                             ;[cca5] fe 33
    jr      z,label_ccf4                    ;[cca7] 28 4b
    xor     a                               ;[cca9] af
    ret                                     ;[ccaa] c9

label_ccab:
    ld      a,($ffcb)                       ;[ccab] read "current_row"
    ld      b,a                             ;[ccae]
    ld      d,a                             ;[ccaf]
    ld      a,($ffca)                       ;[ccb0] read "current_column"
    ld      c,a                             ;[ccb3]
    ld      a,($ffcf)                       ;[ccb4]
    ld      e,a                             ;[ccb7]
    call    $c805                           ;[ccb8]
    xor     a                               ;[ccbb]
    ret                                     ;[ccbc]

label_ccbd:
    ld      a,($ffce)                       ;[ccbd]
    ld      b,a                             ;[ccc0]
    ld      a,($ffcb)                       ;[ccc1] read "current_row"
    ld      ($ffce),a                       ;[ccc4]
    ld      a,($ffc9)                       ;[ccc7]
    ld      c,a                             ;[ccca]
    ld      a,$01                           ;[cccb]
    ld      ($ffc9),a                       ;[cccd] var$ffc9 = 1
    push    bc                              ;[ccd0]
    call    $c62e                           ;[ccd1]
    pop     bc                              ;[ccd4]
    ld      a,b                             ;[ccd5]
    ld      ($ffce),a                       ;[ccd6]
    ld      a,c                             ;[ccd9]
    ld      ($ffc9),a                       ;[ccda]
    xor     a                               ;[ccdd]
    ret                                     ;[ccde]

label_ccdf:
    ld      a,($ffcb)                       ;[ccdf] read "current_row"
    ld      b,a                             ;[cce2]
    ld      a,($ffca)                       ;[cce3] read "current_column"
    ld      c,a                             ;[cce6]
    ld      a,($ffcd)                       ;[cce7] read "number of rows" of display
    ld      d,a                             ;[ccea]
    ld      a,($ffcf)                       ;[cceb]
    ld      e,a                             ;[ccee]
    call    $c805                           ;[ccef]
    xor     a                               ;[ccf2]
    ret                                     ;[ccf3]

label_ccf4:
    ld      a,($ffce)                       ;[ccf4]
    ld      b,a                             ;[ccf7]
    ld      a,($ffcb)                       ;[ccf8] read "current_row"
    ld      c,a                             ;[ccfb]
    ld      a,($ffcd)                       ;[ccfc] read "number of rows" of display
    cp      c                               ;[ccff]
    jr      z,label_cd18                    ;[cd00]
    ld      a,c                             ;[cd02]
    ld      ($ffce),a                       ;[cd03]
    push    bc                              ;[cd06]
    call    $c830                           ;[cd07]
    pop     bc                              ;[cd0a]
    ld      a,b                             ;[cd0b]
    ld      ($ffce),a                       ;[cd0c]
label_cd0f:
    ld      a,($ffd0)                       ;[cd0f] 3a d0 ff
    ld      c,a                             ;[cd12] 4f
    call    $cb9f                           ;[cd13] cd 9f cb
    xor     a                               ;[cd16] af
    ret                                     ;[cd17] c9

label_cd18:
    ld      b,a                             ;[cd18] 47
    ld      d,a                             ;[cd19] 57
    ld      a,($ffcf)                       ;[cd1a] 3a cf ff
    ld      e,a                             ;[cd1d] 5f
    ld      a,($ffd0)                       ;[cd1e] 3a d0 ff
    ld      c,a                             ;[cd21] 4f
    call    $c805                           ;[cd22] cd 05 c8
    jr      label_cd0f                      ;[cd25] 18 e8

    call    $cdd7                           ;[cd27] increment_blues_if_zero() ; if (blues == 0), return to $C9FB
    cp      $02                             ;[cd2a] fe 02
    jp      nc,$cd8a                        ;[cd2c] d2 8a cd
    ld      a,c                             ;[cd2f] 79
    cp      $30                             ;[cd30] fe 30
    jr      z,label_cd42                    ;[cd32] 28 0e
    cp      $31                             ;[cd34] fe 31
    jr      z,label_cd46                    ;[cd36] 28 0e
    cp      $34                             ;[cd38] fe 34
    jr      z,label_cd51                    ;[cd3a] 28 15
    cp      $35                             ;[cd3c] fe 35
    jr      z,label_cd8a                    ;[cd3e] 28 4a
    xor     a                               ;[cd40] af
    ret                                     ;[cd41] c9

    ; use 25 rows
label_cd42:
    ld      b,$19                           ;[cd42] B = 25
    jr      label_cd48                      ;[cd44]
    ; use 24 rows
label_cd46:
    ld      b,$18                           ;[cd46] B = 24
label_cd48:
    ; update number of vertical row displayed by CRTC
    ld      a,$06                           ;[cd48]
    out     ($a0),a                         ;[cd4a]
    ld      a,b                             ;[cd4c]
    out     ($a1),a                         ;[cd4d]
    xor     a                               ;[cd4f]
    ret                                     ;[cd50] return 0


label_cd51:
    ld      hl,($bff4)                      ;[cd51]
    ex      de,hl                           ;[cd54]
    ld      b,$18                           ;[cd55] row = 24
    ld      c,$00                           ;[cd57] column = 0
    call    $c6f1                           ;[cd59] display_add_row_column()
    ld      a,($bfea)                       ;[cd5c]
    ld      c,a                             ;[cd5f]
    ld      b,$46                           ;[cd60]
    ld      a,b                             ;[cd62]
    ld      ($ffda),a                       ;[cd63]
label_cd66:
    call    $c715                           ;[cd66] display_cursor_to_video_mem_ptr()
    ld      a,(de)                          ;[cd69]
    ld      (hl),a                          ;[cd6a]
    call    $c795                           ;[cd6b] bank_video_attribute_memory()
    ld      (hl),c                          ;[cd6e]
    call    $c79e                           ;[cd6f] bank_video_char_memory()
    inc     de                              ;[cd72]
    inc     hl                              ;[cd73]
    djnz    label_cd66                      ;[cd74]
    ld      a,($ffda)                       ;[cd76]
    or      a                               ;[cd79]
    jr      z,label_cd88                    ;[cd7a]
    ld      b,$0a                           ;[cd7c]
    ld      a,($bfeb)                       ;[cd7e]
    ld      c,a                             ;[cd81]
    xor     a                               ;[cd82]
    ld      ($ffda),a                       ;[cd83]
    jr      label_cd66                      ;[cd86]
label_cd88:
    xor     a                               ;[cd88]
    ret                                     ;[cd89]

label_cd8a:
    ld      a,c                             ;[cd8a]
    cp      $0d                             ;[cd8b]
    jr      z,label_cdb5                    ;[cd8d]
    ld      a,($ffd9)                       ;[cd8f] read "blues"
    cp      $01                             ;[cd92]
    jr      z,label_cd9a                    ;[cd94]
    call    $cdb7                           ;[cd96]
    ret                                     ;[cd99]

label_cd9a:
    ld      b,$18                           ;[cd9a]
    ld      c,$00                           ;[cd9c]
    call    $c6f1                           ;[cd9e] display_add_row_column()
    ld      ($ffda),hl                      ;[cda1]
    ld      a,$02                           ;[cda4]
    ld      ($ffd9),a                       ;[cda6] read "blues"
    ld      b,$46                           ;[cda9]
    ld      c,$20                           ;[cdab]
label_cdad:
    call    $c715                           ;[cdad] display_cursor_to_video_mem_ptr()
    ld      (hl),c                          ;[cdb0]
    inc     hl                              ;[cdb1]
    djnz    label_cdad                      ;[cdb2]
    ret                                     ;[cdb4]

label_cdb5:
    xor     a                               ;[cdb5]
    ret                                     ;[cdb6]

    ld      b,a                             ;[cdb7]
    inc     a                               ;[cdb8]
    ld      ($ffd9),a                       ;[cdb9] unmatched "blues": this is, probably, where it is set
    ld      hl,($ffda)                      ;[cdbc]
    call    $c715                           ;[cdbf] display_cursor_to_video_mem_ptr()
    ld      (hl),c                          ;[cdc2]
    ld      a,($bfeb)                       ;[cdc3]
    call    $c795                           ;[cdc6] bank_video_attribute_memory()
    ld      (hl),a                          ;[cdc9]
    call    $c79e                           ;[cdca] bank_video_char_memory()
    inc     hl                              ;[cdcd]
    ld      ($ffda),hl                      ;[cdce]
    ld      a,b                             ;[cdd1]
    cp      $47                             ;[cdd2]
    ret     nz                              ;[cdd4]
    xor     a                               ;[cdd5]
    ret                                     ;[cdd6]

    ; SUBROUTINE CDD7: increment_blues_if_zero()
    ; $ffd9 = "blues" (I needed some mnemonic name)
    ; if (blues == 0)
    ; {
    ;   blues = 1;
    ;   A = 1;
    ;   return "1" to $C9FB
    ; }
    ; else
    ; {
    ;   return "blues", normally;
    ; }
    ld      a,($ffd9)                       ;[cdd7]
    or      a                               ;[cdda]
    ret     nz                              ;[cddb] if ("blues" != 0), return "blues"
    inc     a                               ;[cddc] ++A
    ld      ($ffd9),a                       ;[cddd]
    pop     hl                              ;[cde0] remove word from stack, and return
    ret                                     ;[cde1] this is only called at one point, and will always return to $C9FB (are we sure?)

    ; SUBROUTINE CDE2
    call    $c69a                           ;[cde2] bios_load_ix_iy()
    call    $c6f1                           ;[cde5] display_add_row_column()
    call    $c715                           ;[cde8] display_cursor_to_video_mem_ptr()
    ld      (hl),d                          ;[cdeb] put D in video memory
    call    $c795                           ;[cdec] bank_video_attribute_memory()
    ld      (hl),e                          ;[cdef] put E in shadow video memory (?)
    call    $c79e                           ;[cdf0] bank_video_char_memory()
    ret                                     ;[cdf3]

    call    $c69a                           ;[cdf4] bios_load_ix_iy()
    call    $c6f1                           ;[cdf7] display_add_row_column()
    call    $c715                           ;[cdfa] display_cursor_to_video_mem_ptr()
    ld      d,(hl)                          ;[cdfd]
    call    $c795                           ;[cdfe] bank_video_attribute_memory()
    ld      e,(hl)                          ;[ce01]
    call    $c79e                           ;[ce02] bank_video_char_memory()
    ret                                     ;[ce05]

    ; [ce06]
    REPT 502
    nop
    ENDR

    ; Splash screen string
    ; "1.01"
    BYTE $31                                ;[cffc]
    BYTE $2e
    BYTE $30
    BYTE $31

    ; In the original ROM, here starts a perfect replica of all the above program.
    ; Except for the "splash screen", which is $31 $2e $30 $ff

