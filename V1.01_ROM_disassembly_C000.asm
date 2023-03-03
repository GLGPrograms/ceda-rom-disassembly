    org 0xc000

PUBLIC _main
    ; Interrupt Vector Table (?)
    ; This looks like one
_main:
    jp      $c030                           ;[c000] reset vector
    jp      $c027                           ;[c003] reset SIO interrupts
    jp      $c027                           ;[c006] reset SIO interrupts
    jp      $c45e                           ;[c009]
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
    call    $c14e                           ;[c049]
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
    ld      c,(hl)                          ;[c064]
    inc     hl                              ;[c065]
    call    $c45e                           ;[c066] putchar()
    djnz    label_c064                      ;[c069]

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

    ; SUBROUTINE C14E;
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
    ; into the same location. Apparently, it has no sense, but it is confirmed
    ; by oscilloscope bus acquisitions.
    ; Time lost by doing this: about 344ms.

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
; String is passed as a pointer pushed onto the stack.
; The argument pointer is altered, function will always return it pointing to first location after string terminator.
putstr:
    ex      (sp),hl                         ;[c18f] load the argument from the stack in hl
label_c190:
    ld      a,(hl)                          ;[c190]
    inc     hl                              ;[c191] a = *(hl++)
    or      a                               ;[c192]
    jr      z,label_c19b                    ;[c193] return if a == '\0'
    ld      c,a                             ;[c195]
    call    $c45e                           ;[c196] putchar(a)
    jr      label_c190                      ;[c199] repeat again
label_c19b:
    ex      (sp),hl                         ;[c19b] reload altered hl onto the stack
    ret                                     ;[c19c]

    ; FDC Read Write Format Seek routine.
    ; Arguments:
    ; - a: bytes per sector "shift factor", bps = 0x80 << a - found here: https://www.cpcwiki.eu/index.php/765_FDC
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
    jp      z,fdc_sw_format                 ;[c1cf] case $f0: seek to desired track
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
    and     $c0                             ;[c232]
    cp      $40                             ;[c234] TODO check for error
    jr      nz,label_c248                   ;[c236] TODO jump if ok or fail?
    call    fdc_err_check_c2a0              ;[c238] after-write error checking (common with "read data")
    ld      a,($ffbf)                       ;[c23b] TODO
    dec     a                               ;[c23e] TODO may be an error retry counter
    ld      ($ffbf),a                       ;[c23f] TODO
    jp      nz,fdc_write_retry_c1f7         ;[c242] may be a write retry, after 256 iterations it gives up
    ld      a,$ff                           ;[c245]
    ret                                     ;[c247] return -1?
label_c248:
    xor     a                               ;[c248]
    ret                                     ;[c249] return 0?

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
    and     $c0                             ;[c288]
    cp      $40                             ;[c28a] TODO check for error
    jr      nz,label_c29e                   ;[c28c] TODO jump if ok or fail?
    call    fdc_err_check_c2a0              ;[c28e] after-read error checking
    ld      a,($ffbf)                       ;[c291] TODO
    dec     a                               ;[c294] TODO may be an error retry counter
    ld      ($ffbf),a                       ;[c295] TODO
    jp      nz,fdc_read_retry_c24d          ;[c298] may be a write retry, after 256 iterations it gives up
    ld      a,$ff                           ;[c29b]
    ret                                     ;[c29d] return -1?
label_c29e:
    xor     a                               ;[c29e]
    ret                                     ;[c29f] return 0?

    ; TODO this is a FDC routine related to error checking after read/write
fdc_err_check_c2a0:
    ld      a,($ffc2)                       ;[c2a0] read 3rd status byte after cmd execution (ST2)
    bit     4,a                             ;[c2a3]
    jr      z,label_c2ab                    ;[c2a5]
    call    fdc_track0_c391                 ;[c2a7] reset head position if bit 4 is set
    ret                                     ;[c2aa]
label_c2ab:
    ld      a,($ffc1)                       ;[c2ab] read 2nd status byte after cmd execution (ST1)
    bit     0,a                             ;[c2ae]
    jr      z,label_c2b6                    ;[c2b0]
    call    fdc_track0_c391                 ;[c2b2] reset head position if bit 0 is set
    ret                                     ;[c2b5]
label_c2b6:
    ret                                     ;[c2b6]

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
    ld      a,($ffc0)                       ;[c340]
    and     $c0                             ;[c343]
    cp      $40                             ;[c345] TODO check for error
    jr      nz,label_c34c                   ;[c347] TODO jump if ok or fail?
    ld      a,$ff                           ;[c349] return -1?
    ret                                     ;[c34b]
label_c34c:
    xor     a                               ;[c34c] return 0
    ret                                     ;[c34d]

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
    call    fdc_sis_c3d2                    ;[c3a2] Sends command Sense Interrupt Status and gets the two bytes answer (ST0 - PCN)
    jr      z,fdc_track0_c391               ;[c3a5] Waits until byte ST0 = 0b01xxxxxx. Probably meaning that recalibration is completed?
    xor     a                               ;[c3a7] Clear a
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
    call    fdc_sis_c3d2                    ;[c3c5]
    jr      nz,label_c3d0                   ;[c3c8] (i think) wait until completion. On failure:
    call    fdc_track0_c391                 ;[c3ca] ...move head to track 0...
    jp      fdc_seek_c3a9                   ;[c3cd] ...and try again
label_c3d0:
    xor     a                               ;[c3d0] On success, a=0 and return
    ret                                     ;[c3d1]

    ; FDC utility function: send "Sense Interrupt Status" command and read the two bytes (STO, PCN)
fdc_sis_c3d2:
    in      a,($82)                         ;[c3d2] read PORTC
    bit     2,a                             ;[c3d4]
    jp      z,fdc_sis_c3d2                  ;[c3d6]
    call    fdc_wait_busy                   ;[c3d9]
    call    fdc_wait_rqm_wr                 ;[c3dc]
    ld      a,$08                           ;[c3df]
    out     ($c1),a                         ;[c3e1]
    call    fdc_wait_rqm_rd                 ;[c3e3]
    in      a,($c1)                         ;[c3e6]
    ld      b,a                             ;[c3e8]
    call    fdc_wait_rqm_rd                 ;[c3e9]
    in      a,($c1)                         ;[c3ec]
    ld      a,b                             ;[c3ee]
    and     $c0                             ;[c3ef]
    cp      $40                             ;[c3f1]
    ret                                     ;[c3f3]

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

    ; SUBROUTINE C45E
bios_putchar_c45e:
    ; arguments:
    ; - c: character to be printed
    push    af                              ;[c45e] save all registers
    push    bc                              ;[c45f]
    push    de                              ;[c460]
    push    hl                              ;[c461]
    push    ix                              ;[c462]
    push    iy                              ;[c464]
    call    $c69a                           ;[c466] load ix and iy (?? and cursor position)

    ld      a,($ffd8)                       ;[c469]
    or      a                               ;[c46c] if *$ffd8 != 0...
    jp      nz,$c9e3                        ;[c46d] TODO

    ; check if should override character switch behaviour
    ld      a,($ffcc)                       ;[c470]
    cp      $ff                             ;[c473] if *$ffcc is == $ff...
    jp      z,$c6a3                         ;[c475] treat c as NUL character
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
    call    z,$c5f4                         ;[c4ab]
    cp      $00                             ;[c4ae] jump if NUL
    jp      z,label_c6a3                    ;[c4b0]
    jp      label_c4be                      ;[c4b3] jump if any other not printable character

    ; Handle ESC
label_c4b6:
    ld      a,$01                           ;[c4b6]
    ld      ($ffd8),a                       ;[c4b8]
    jp      label_c6a3                      ;[c4bb]

    ; Handle all, but special characters
label_c4be:
    push    iy                              ;[c4be]
    pop     hl                              ;[c4c0] hl <- iy (copy of cursor position)
    call    $c715                           ;[c4c1] compute cursor position in video memory
    ld      (hl),c                          ;[c4c4] put character in $d000-$d7ff (video memory)
    call    $c795                           ;[c4c5] set MSB in $81
    ld      a,($ffd1)                       ;[c4c8]
    ld      b,a                             ;[c4cb]
    ld      a,($ffd2)                       ;[c4cc]
    and     (hl)                            ;[c4cf] a = *(0xffd2) & character in video memory
    or      b                               ;[c4d0] a |= *(0xffd1)
    ld      (hl),a                          ;[c4d1] write again in video memory
    call    $c79e                           ;[c4d2] clear MSB in $81
    call    $c5f8                           ;[c4d5] increment cursor column position
    jr      c,label_c4e0                    ;[c4d8] if posx > "max column width", must do something else before the end
    call    $c613                           ;[c4da] increments hl counter and update cursor position in CRTC
    jp      label_c6a3                      ;[c4dd] the end, go to putchar epilogue

label_c4e0:
    ld      a,($ffcb)                       ;[c4e0] load current cursor posy?
    ld      b,a                             ;[c4e3]
    ld      a,($ffcd)                       ;[c4e4] load "max rows height - 1"
    cp      b                               ;[c4e7]
    jr      z,label_c501                    ;[c4e8] jump if posy reached last row
    inc     b                               ;[c4ea] increment cursor posy?
    ld      a,b                             ;[c4eb]
    ld      ($ffcb),a                       ;[c4ec] save current cursor posy
    ld      a,($ffc9)                       ;[c4ef]
    or      a                               ;[c4f2]
    jr      nz,label_c4fb                   ;[c4f3] jump if *$ffc9 != 0
    call    $c613                           ;[c4f5] increments hl counter and update cursor position in CRTC
    jp      label_c6a3                      ;[c4f8] the end, go to putchar epilogue

    ; SUBROUTINE 0xC4FB; called by c4e0 if *$ffc9 == 0
label_c4fb:
    call    $c620                           ;[c4fb]
    jp      label_c6a3                      ;[c4fe] the end, go to putchar epilogue

    ; SUBROUTINE 0xC501; called by c4e0 if posy reached last row
label_c501:
    ld      a,($ffc9)                       ;[c501]
    or      a                               ;[c504]
    jr      nz,label_c510                   ;[c505]
    call    $c613                           ;[c507]
    call    $c62e                           ;[c50a]
    jp      label_c6a3                      ;[c50d] the end, go to putchar epilogue

label_c510:
    ld      a,($ffcd)                       ;[c510]
    ld      b,a                             ;[c513]
    ld      a,($ffd0)                       ;[c514]
    ld      c,a                             ;[c517]
    call    $c6f1                           ;[c518]
    call    $c71c                           ;[c51b]
    call    $c62e                           ;[c51e]
    jp      label_c6a3                      ;[c521]
label_c524:
    ld      a,($ffd0)                       ;[c524]
    ld      ($ffca),a                       ;[c527]
    ld      c,a                             ;[c52a]
    ld      a,($ffcb)                       ;[c52b]
    ld      b,a                             ;[c52e]
    jp      label_c5e5                      ;[c52f]
label_c532:
    ld      a,($ffcb)                       ;[c532]
    ld      b,a                             ;[c535]
    ld      a,($ffcd)                       ;[c536]
    cp      b                               ;[c539]
    jr      z,label_c54b                    ;[c53a]
    inc     b                               ;[c53c]
    ld      a,b                             ;[c53d]
    ld      ($ffcb),a                       ;[c53e]
label_c541:
    push    iy                              ;[c541]
    pop     hl                              ;[c543]
    ld      de,$0050                        ;[c544]
    add     hl,de                           ;[c547]
    jp      label_c5e8                      ;[c548]
label_c54b:
    call    $c62e                           ;[c54b]
    ld      a,($ffcb)                       ;[c54e]
    ld      b,a                             ;[c551]
    ld      a,($ffca)                       ;[c552]
    ld      c,a                             ;[c555]
    jr      label_c541                      ;[c556]
label_c558:
    ld      a,($ffcb)                       ;[c558]
    ld      b,a                             ;[c55b]
    ld      a,($ffce)                       ;[c55c]
    cp      b                               ;[c55f]
    jp      z,label_c6a3                    ;[c560]
    dec     b                               ;[c563]
    ld      a,b                             ;[c564]
    ld      ($ffcb),a                       ;[c565]
    ld      a,($ffca)                       ;[c568]
    ld      c,a                             ;[c56b]
    jp      label_c5e5                      ;[c56c]
label_c56f:
    call    $c5f8                           ;[c56f]
    ld      a,($ffcb)                       ;[c572]
    ld      b,a                             ;[c575]
    jr      c,label_c57b                    ;[c576]
    jp      label_c5e5                      ;[c578]
label_c57b:
    ld      a,($ffd0)                       ;[c57b]
    ld      ($ffca),a                       ;[c57e]
    ld      c,a                             ;[c581]
    ld      a,($ffcb)                       ;[c582]
    ld      b,a                             ;[c585]
    ld      a,($ffcd)                       ;[c586]
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
    ld      a,($ffca)                       ;[c59b]
    ld      c,a                             ;[c59e]
    ld      a,($ffd0)                       ;[c59f]
    cp      c                               ;[c5a2]
    jr      z,label_c5b8                    ;[c5a3]
    dec     c                               ;[c5a5]
    ld      a,($ffd1)                       ;[c5a6]
    bit     3,a                             ;[c5a9]
    jr      z,label_c5ae                    ;[c5ab]
    dec     c                               ;[c5ad]
label_c5ae:
    ld      a,c                             ;[c5ae]
    ld      ($ffca),a                       ;[c5af]
    ld      a,($ffcb)                       ;[c5b2]
    ld      b,a                             ;[c5b5]
    jr      label_c5e5                      ;[c5b6]
label_c5b8:
    ld      a,($ffcf)                       ;[c5b8]
    ld      b,a                             ;[c5bb]
    ld      a,($ffd1)                       ;[c5bc]
    bit     3,a                             ;[c5bf]
    jr      z,label_c5c4                    ;[c5c1]
    dec     b                               ;[c5c3]
label_c5c4:
    ld      a,b                             ;[c5c4]
    ld      ($ffca),a                       ;[c5c5]
    ld      c,a                             ;[c5c8]
    ld      a,($ffcb)                       ;[c5c9]
    ld      b,a                             ;[c5cc]
    ld      a,($ffce)                       ;[c5cd]
    cp      b                               ;[c5d0]
    jp      z,label_c6a3                    ;[c5d1]
    dec     b                               ;[c5d4]
    ld      a,b                             ;[c5d5]
    ld      ($ffcb),a                       ;[c5d6]
    jr      label_c5e5                      ;[c5d9]
label_c5db:
    xor     a                               ;[c5db]
    ld      ($ffcb),a                       ;[c5dc]
    ld      ($ffca),a                       ;[c5df]
    ld      bc,$0000                        ;[c5e2]
label_c5e5:
    call    $c6f1                           ;[c5e5]
label_c5e8:
    call    $c71c                           ;[c5e8]
    jp      label_c6a3                      ;[c5eb]
label_c5ee:
    call    $c764                           ;[c5ee]
    jp      label_c6a3                      ;[c5f1]
    xor     a                               ;[c5f4]
    out     ($da),a                         ;[c5f5] sound speaker beep
    ret                                     ;[c5f7]

    ; SUBROUTINE 0xC5F8
    ; this subroutine seems to handle the column/line cursor position.
    ; to be verified
    ld      a,($ffca)                       ;[c5f8] load cursor posx
    ld      c,a                             ;[c5fb]
    inc     c                               ;[c5fc] increment posx by one
    ld      a,($ffd1)                       ;[c5fd]
    bit     3,a                             ;[c600]
    jr      z,label_c605                    ;[c602] if bit 3 of $ffd1 is set...
    inc     c                               ;[c604] do another increment on posx
label_c605:
    ld      a,($ffcf)                       ;[c605] load "maximum column width - 1" value
    cp      c                               ;[c608]
    ld      a,c                             ;[c609]
    jr      nc,label_c60f                   ;[c60a] if posx > *$ffcf...
    ld      a,($ffd0)                       ;[c60c] put posx to "column 0"
label_c60f:
    ld      ($ffca),a                       ;[c60f] save new posx
    ret                                     ;[c612]

    ; SUBROUTINE $C613
    inc     hl                              ;[c613] increment hl by one
    ld      a,($ffd1)                       ;[c614]
    bit     3,a                             ;[c617]
    jr      z,label_c61c                    ;[c619] if bit 3 of $ffd1 is set...
    inc     hl                              ;[c61b] do another increment on hl
label_c61c:
    call    crtc_foo_c71c                   ;[c61c] crtc_foo_c71c(hl, ix)
    ret                                     ;[c61f]

    ld      a,($ffc8)                       ;[c620] 3a c8 ff
    ld      e,a                             ;[c623] 5f
    ld      d,$00                           ;[c624] 16 00
    push    iy                              ;[c626] fd e5
    pop     hl                              ;[c628] e1
    add     hl,de                           ;[c629] 19
    call    $c71c                           ;[c62a] cd 1c c7
    ret                                     ;[c62d] c9

    ld      a,($ffc9)                       ;[c62e] 3a c9 ff
    or      a                               ;[c631] b7
    jr      nz,label_c647                   ;[c632] 20 13
    push    ix                              ;[c634] dd e5
    pop     hl                              ;[c636] e1
    ld      de,$0050                        ;[c637] 11 50 00
    add     hl,de                           ;[c63a] 19
    call    $c742                           ;[c63b] cd 42 c7
    ld      b,$17                           ;[c63e] 06 17
    call    $c7fa                           ;[c640] cd fa c7
    call    $c670                           ;[c643] cd 70 c6
    ret                                     ;[c646] c9

label_c647:
    ld      a,($ffd0)                       ;[c647] 3a d0 ff
    ld      c,a                             ;[c64a] 4f
    ld      a,($ffce)                       ;[c64b] 3a ce ff
    ld      b,a                             ;[c64e] 47
    ld      a,($ffce)                       ;[c64f] 3a ce ff
    ld      d,a                             ;[c652] 57
    ld      a,($ffcd)                       ;[c653] 3a cd ff
    sub     d                               ;[c656] 92
    jr      z,label_c664                    ;[c657] 28 0b
    ld      d,a                             ;[c659] 57
label_c65a:
    inc     b                               ;[c65a] 04
    call    $c6f1                           ;[c65b] cd f1 c6
    call    $c7a7                           ;[c65e] cd a7 c7
    dec     d                               ;[c661] 15
    jr      nz,label_c65a                   ;[c662] 20 f6
label_c664:
    ld      a,($ffcd)                       ;[c664] 3a cd ff
    ld      d,a                             ;[c667] 57
    ld      a,($ffcf)                       ;[c668] 3a cf ff
    ld      e,a                             ;[c66b] 5f
    call    $c805                           ;[c66c] cd 05 c8
    ret                                     ;[c66f] c9

    push    ix                              ;[c670] dd e5
    pop     hl                              ;[c672] e1
    ld      de,$0730                        ;[c673] 11 30 07
    ld      b,$50                           ;[c676] 06 50
    add     hl,de                           ;[c678] 19
    ld      de,$2000                        ;[c679] 11 00 20
    call    $c795                           ;[c67c] cd 95 c7
    call    $c715                           ;[c67f] cd 15 c7
    push    hl                              ;[c682] e5
    push    bc                              ;[c683] c5
    ld      e,$00                           ;[c684] 1e 00
    call    $c690                           ;[c686] cd 90 c6
    pop     bc                              ;[c689] c1
    pop     hl                              ;[c68a] e1
    call    $c79e                           ;[c68b] cd 9e c7
    ld      e,$20                           ;[c68e] 1e 20
label_c690:
    ld      (hl),e                          ;[c690] 73
    inc     hl                              ;[c691] 23
    bit     3,h                             ;[c692] cb 5c
    call    z,$c715                         ;[c694] cc 15 c7
    djnz    label_c690                      ;[c697] 10 f7
    ret                                     ;[c699] c9

    ; SUBROUTINE C69A ; load cursor position (?)
    ld      ix,($ffd4)                      ;[c69a]
    ld      iy,($ffd6)                      ;[c69e] Load current cursor position as in CRTC R14:R15 registers
    ret                                     ;[c6a2]

label_c6a3:
    call    $c6e8                           ;[c6a3] save ix and iy in memory
    pop     iy                              ;[c6a6] function epilogue
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
    ld      (hl),a                          ;[c6b5] *$ffca = 0
    inc     hl                              ;[c6b6]
    ld      (hl),a                          ;[c6b7] *$ffcb = 0
    inc     hl                              ;[c6b8]
    ld      (hl),a                          ;[c6b9] *$ffcc = 0
    inc     hl                              ;[c6ba]
    ld      (hl),$17                        ;[c6bb] *$ffce = "23" (rows(?)-1)
    inc     hl                              ;[c6bd]
    ld      (hl),a                          ;[c6be] *$ffcf = 0
    inc     hl                              ;[c6bf]
    ld      (hl),$4f                        ;[c6c0] *$ffd0 = "79" (columns-1)
    inc     hl                              ;[c6c2]
    ld      (hl),a                          ;[c6c3] *$ffd1 = 0
    inc     hl                              ;[c6c4]
    ld      (hl),a                          ;[c6c5] *$ffd2 = 0
    inc     hl                              ;[c6c6]
    ld      (hl),$80                        ;[c6c7] *$ffd3 = 0
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

    ; SUBROUTINE C6E8; save ix and iy
    ld      ($ffd4),ix                      ;[c6e8]
    ld      ($ffd6),iy                      ;[c6ec]
    ret                                     ;[c6f0]

    ; SUBROUTINE C6F1; display_add_row_column()
    ; Linearize row and column coordinates, and add to IX
    ; Input:
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
                                            ;       Maximum number of row is 25, which stays on 5 bits,
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

    ; SUBROUTINE 0xC715; compute current video memory pointer from current cursor
    ; arguments:
    ; - hl: cursor position
    ; return:
    ; - hl: video memory pointer
    ; Memento: video memory is mapped to 0xd000:0xd7ff
    ld      a,h                             ;[c715]
    and     $07                             ;[c716] hl &= 0x07ff
    or      $d0                             ;[c718] hl += 0xd000
    ld      h,a                             ;[c71a]
    ret                                     ;[c71b]

    ; SUBROUTINE C71C; CRTC TODO; crtc_foo_c71c(hl: value, ix)
crtc_foo_c71c:
    ld      a,h                             ;[c71c]
    and     $07                             ;[c71d]
    ld      h,a                             ;[c71f] value &= 0x07FF
    push    ix                              ;[c720]
    pop     de                              ;[c722]
    ex      de,hl                           ;[c723] de <- value; hl <- ix
    or      a                               ;[c724] clear carry
    sbc     hl,de                           ;[c725] hl <- ix - value
    jr      c,label_c730                    ;[c727] skip next if ix <= value
    jr      z,label_c730                    ;[c729]
    ld      hl,$0800                        ;[c72b]
    add     hl,de                           ;[c72e] hl <- $0800 + value
    ex      de,hl                           ;[c72f] de <- $0800 + value; hl <- $0800
label_c730:
    ; Write cursor position, that is value or ($0800 + value)
    ld      a,$0e                           ;[c730] CRTC R14: cursor position HI
    out     ($a0),a                         ;[c732]
    ld      a,d                             ;[c734]
    out     ($a1),a                         ;[c735]
    ld      a,$0f                           ;[c737] CRTC R15: cursor position LO
    out     ($a0),a                         ;[c739]
    ld      a,e                             ;[c73b]
    out     ($a1),a                         ;[c73c]
    push    de                              ;[c73e]
    pop     iy                              ;[c73f] iy <- value or $0800 + value
    ret                                     ;[c741]

    ld      a,h                             ;[c742] 7c
    and     $07                             ;[c743] e6 07
    ld      h,a                             ;[c745] 67
    call    $c75b                           ;[c746] cd 5b c7
    ld      a,$0c                           ;[c749] 3e 0c
    out     ($a0),a                         ;[c74b] d3 a0
    ld      a,h                             ;[c74d] 7c
    out     ($a1),a                         ;[c74e] d3 a1
    ld      a,$0d                           ;[c750] 3e 0d
    out     ($a0),a                         ;[c752] d3 a0
    ld      a,l                             ;[c754] 7d
    out     ($a1),a                         ;[c755] d3 a1
    push    hl                              ;[c757] e5
    pop     ix                              ;[c758] dd e1
    ret                                     ;[c75a] c9

    in      a,($a0)                         ;[c75b] db a0
label_c75d:
    in      a,($82)                         ;[c75d] read PORTC
    bit     1,a                             ;[c75f]
    jr      z,label_c75d                    ;[c761]
    ret                                     ;[c763]

    ; SUBROUTINE C764; CRTC TODO (ix: ...)
    ld      bc,$0780                        ;[c764] 24*80 = "1920"
    push    ix                              ;[c767]
    pop     hl                              ;[c769] hl <- ix
    ld      de,$2000                        ;[c76a]
    call    $c715                           ;[c76d] hl <- current cursor position in video memory
label_c770:
    ld      (hl),d                          ;[c770] write $20 in video memory: " "
    in      a,($81)                         ;[c771] set MSB in $81
    set     7,a                             ;[c773]
    out     ($81),a                         ;[c775] PORTB |= 0x80 (bank 7 in)
    ld      (hl),e                          ;[c777] write 0 in bank switched video memory (?)
    res     7,a                             ;[c778] PORTB &= ~0x80 (bank 7 out)
    out     ($81),a                         ;[c77a]
    inc     hl                              ;[c77c] move to next video memory address
    bit     3,h                             ;[c77d] ???
    call    z,$c715                         ;[c77f] ???
    dec     bc                              ;[c782]
    ld      a,b                             ;[c783]
    or      c                               ;[c784]
    jr      nz,label_c770                   ;[c785] repeat from $c770 while bc > 0
    push    ix                              ;[c787]
    pop     hl                              ;[c789] hl <- ix
    call    $c71c                           ;[c78a]
    xor     a                               ;[c78d]
    ld      ($ffca),a                       ;[c78e] $ffca <- 0
    ld      ($ffcb),a                       ;[c791] $ffcb <- 0
    ret                                     ;[c794]

    ; SUBROUTINE C795: enable memory Bank 7
    push    af                              ;[c795]
    in      a,($81)                         ;[c796]
    set     7,a                             ;[c798]
    out     ($81),a                         ;[c79a] PORTB |= 0x80 (bank 7 in)
    pop     af                              ;[c79c]
    ret                                     ;[c79d]

    ; SUBROUTINE C79E: disable memory Bank 7
    push    af                              ;[c79e]
    in      a,($81)                         ;[c79f]
    res     7,a                             ;[c7a1]
    out     ($81),a                         ;[c7a3] PORTB &= ~0x80 (bank 7 out)
    pop     af                              ;[c7a5]
    ret                                     ;[c7a6]

    push    de                              ;[c7a7] d5
    push    bc                              ;[c7a8] c5
    ld      a,$50                           ;[c7a9] 3e 50
    cpl                                     ;[c7ab] 2f
    ld      d,$ff                           ;[c7ac] 16 ff
    ld      e,a                             ;[c7ae] 5f
    inc     de                              ;[c7af] 13
    call    $c7b6                           ;[c7b0] cd b6 c7
    pop     bc                              ;[c7b3] c1
    pop     de                              ;[c7b4] d1
    ret                                     ;[c7b5] c9

    ld      a,($ffd0)                       ;[c7b6] 3a d0 ff
    ld      c,a                             ;[c7b9] 4f
    call    $c6f1                           ;[c7ba] cd f1 c6
    push    hl                              ;[c7bd] e5
    add     hl,de                           ;[c7be] 19
    ex      de,hl                           ;[c7bf] eb
    pop     hl                              ;[c7c0] e1
    ld      a,($ffd0)                       ;[c7c1] 3a d0 ff
    ld      b,a                             ;[c7c4] 47
    ld      a,($ffcf)                       ;[c7c5] 3a cf ff
    sub     b                               ;[c7c8] 90
    inc     a                               ;[c7c9] 3c
    ld      b,a                             ;[c7ca] 47
    call    $c715                           ;[c7cb] cd 15 c7
    ex      de,hl                           ;[c7ce] eb
    call    $c715                           ;[c7cf] cd 15 c7
    ex      de,hl                           ;[c7d2] eb
    push    bc                              ;[c7d3] c5
    push    de                              ;[c7d4] d5
    push    hl                              ;[c7d5] e5
    ld      c,$02                           ;[c7d6] 0e 02
label_c7d8:
    ld      a,(hl)                          ;[c7d8] 7e
    ld      (de),a                          ;[c7d9] 12
    inc     de                              ;[c7da] 13
    ld      a,d                             ;[c7db] 7a
    and     $07                             ;[c7dc] e6 07
    or      $d0                             ;[c7de] f6 d0
    ld      d,a                             ;[c7e0] 57
    inc     hl                              ;[c7e1] 23
    bit     3,h                             ;[c7e2] cb 5c
    call    z,$c715                         ;[c7e4] cc 15 c7
    djnz    label_c7d8                      ;[c7e7] 10 ef
    dec     c                               ;[c7e9] 0d
    jr      z,label_c7f6                    ;[c7ea] 28 0a
    ld      a,c                             ;[c7ec] 79
    pop     hl                              ;[c7ed] e1
    pop     de                              ;[c7ee] d1
    pop     bc                              ;[c7ef] c1
    ld      c,a                             ;[c7f0] 4f
    call    $c795                           ;[c7f1] cd 95 c7
    jr      label_c7d8                      ;[c7f4] 18 e2
label_c7f6:
    call    $c79e                           ;[c7f6] cd 9e c7
    ret                                     ;[c7f9] c9

    push    de                              ;[c7fa] d5
    push    bc                              ;[c7fb] c5
    ld      de,$0050                        ;[c7fc] 11 50 00
    call    $c7b6                           ;[c7ff] cd b6 c7
    pop     bc                              ;[c802] c1
    pop     de                              ;[c803] d1
    ret                                     ;[c804] c9

    ld      a,e                             ;[c805] 7b
    sub     c                               ;[c806] 91
    inc     a                               ;[c807] 3c
    ld      e,a                             ;[c808] 5f
    ld      a,d                             ;[c809] 7a
    sub     b                               ;[c80a] 90
    inc     a                               ;[c80b] 3c
    ld      d,a                             ;[c80c] 57
label_c80d:
    call    $c6f1                           ;[c80d] cd f1 c6
label_c810:
    call    $c715                           ;[c810] cd 15 c7
    ld      (hl),$20                        ;[c813] 36 20
    call    $c795                           ;[c815] cd 95 c7
    ld      (hl),$00                        ;[c818] 36 00
    call    $c79e                           ;[c81a] cd 9e c7
    inc     hl                              ;[c81d] 23
    dec     e                               ;[c81e] 1d
    jr      nz,label_c810                   ;[c81f] 20 ef
    inc     b                               ;[c821] 04
    ld      a,($ffd0)                       ;[c822] 3a d0 ff
    ld      c,a                             ;[c825] 4f
    ld      a,($ffcf)                       ;[c826] 3a cf ff
    sub     c                               ;[c829] 91
    inc     a                               ;[c82a] 3c
    ld      e,a                             ;[c82b] 5f
    dec     d                               ;[c82c] 15
    jr      nz,label_c80d                   ;[c82d] 20 de
    ret                                     ;[c82f] c9

    ld      a,($ffcd)                       ;[c830] 3a cd ff
    ld      b,a                             ;[c833] 47
    ld      a,($ffce)                       ;[c834] 3a ce ff
    cp      b                               ;[c837] b8
    jr      z,label_c845                    ;[c838] 28 0b
    ld      d,a                             ;[c83a] 57
    ld      a,b                             ;[c83b] 78
    sub     d                               ;[c83c] 92
    ld      d,a                             ;[c83d] 57
label_c83e:
    dec     b                               ;[c83e] 05
    call    $c7fa                           ;[c83f] cd fa c7
    dec     d                               ;[c842] 15
    jr      nz,label_c83e                   ;[c843] 20 f9
label_c845:
    ld      a,($ffce)                       ;[c845] 3a ce ff
    ld      b,a                             ;[c848] 47
    ld      d,a                             ;[c849] 57
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


    ld      a,($ffd1)                       ;[c875] 3a d1 ff
    set     3,a                             ;[c878] cb df
    ld      ($ffd1),a                       ;[c87a] 32 d1 ff
    ld      a,($ffca)                       ;[c87d] 3a ca ff
    ld      c,a                             ;[c880] 4f
    rra                                     ;[c881] 1f
    jr      nc,label_c88b                   ;[c882] 30 07
    inc     iy                              ;[c884] fd 23
    inc     c                               ;[c886] 0c
    ld      a,c                             ;[c887] 79
    ld      ($ffca),a                       ;[c888] 32 ca ff
label_c88b:
    xor     a                               ;[c88b] af
    ret                                     ;[c88c] c9

    ; SUBROUTINE C88D; CRTC initialization
    ; return:
    ; a = 0
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
    ld      ix,$0000                        ;[c89c] initialize ix (TODO)
    call    $c764                           ;[c8a0] clear screen, initialize some variables
    call    $c8b6                           ;[c8a3] configure display height to 24 lines instead of 25 (WTF?)
    ld      hl,$0000                        ;[c8a6]
    call    $c71c                           ;[c8a9] crtc_foo_c71c: initialize cursor position in CRTC registers
    ld      a,($ffd1)                       ;[c8ac]
    res     3,a                             ;[c8af]
    ld      ($ffd1),a                       ;[c8b1] clear bit 3 in $ffd1
    xor     a                               ;[c8b4] clear a when return
    ret                                     ;[c8b5]

    ; SUBROUTINE C8B6; configure CRTC vertical displayed characters
    ld      a,$06                           ;[c8b6]
    out     ($a0),a                         ;[c8b8] Select R6 CRTC register
    ld      a,$18                           ;[c8ba]
    out     ($a1),a                         ;[c8bc] Set 24 character lines
    ret                                     ;[c8be]

    xor     a                               ;[c8bf] af
    ld      ($ffce),a                       ;[c8c0] 32 ce ff
    ld      ($ffd0),a                       ;[c8c3] 32 d0 ff
    ld      ($ffc9),a                       ;[c8c6] 32 c9 ff
    ld      a,$17                           ;[c8c9] 3e 17
    ld      ($ffcd),a                       ;[c8cb] 32 cd ff
    ret                                     ;[c8ce] c9

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

    ld      a,($ffd9)                       ;[c8df] 3a d9 ff
    or      a                               ;[c8e2] b7
    jr      nz,label_c8ea                   ;[c8e3] 20 05
    inc     a                               ;[c8e5] 3c
    ld      ($ffd9),a                       ;[c8e6] 32 d9 ff
    ret                                     ;[c8e9] c9

label_c8ea:
    ld      a,c                             ;[c8ea] 79
    and     $0f                             ;[c8eb] e6 0f
    rlca                                    ;[c8ed] 07
    rlca                                    ;[c8ee] 07
    rlca                                    ;[c8ef] 07
    rlca                                    ;[c8f0] 07
    cpl                                     ;[c8f1] 2f
    ld      b,a                             ;[c8f2] 47
    ld      a,($ffd1)                       ;[c8f3] 3a d1 ff
    and     b                               ;[c8f6] a0
    ld      ($ffd1),a                       ;[c8f7] 32 d1 ff
    xor     a                               ;[c8fa] af
    ret                                     ;[c8fb] c9

    xor     a                               ;[c8fc] af
    ld      ($ffd1),a                       ;[c8fd] 32 d1 ff
    ret                                     ;[c900] c9

    ld      a,($ffd9)                       ;[c901] 3a d9 ff
    ld      b,a                             ;[c904] 47
    ld      d,$00                           ;[c905] 16 00
    ld      e,a                             ;[c907] 5f
    ld      hl,$ffd9                        ;[c908] 21 d9 ff
    add     hl,de                           ;[c90b] 19
    ld      a,c                             ;[c90c] 79
    sub     $20                             ;[c90d] d6 20
    ld      (hl),a                          ;[c90f] 77
    ld      a,b                             ;[c910] 78
    inc     a                               ;[c911] 3c
    ld      ($ffd9),a                       ;[c912] 32 d9 ff
    ret                                     ;[c915] c9

    ld      a,b                             ;[c916] 78
    out     ($a0),a                         ;[c917] d3 a0
    ld      a,c                             ;[c919] 79
    out     ($a1),a                         ;[c91a] d3 a1
    ret                                     ;[c91c] c9

    call    $c6f1                           ;[c91d] cd f1 c6
    push    hl                              ;[c920] e5
    ld      b,d                             ;[c921] 42
    ld      c,e                             ;[c922] 4b
    call    $c6f1                           ;[c923] cd f1 c6
    pop     de                              ;[c926] d1
    push    de                              ;[c927] d5
    or      a                               ;[c928] b7
    sbc     hl,de                           ;[c929] ed 52
    inc     hl                              ;[c92b] 23
    ex      de,hl                           ;[c92c] eb
    pop     hl                              ;[c92d] e1
    ld      b,a                             ;[c92e] 47
    call    $c795                           ;[c92f] cd 95 c7
label_c932:
    call    $c715                           ;[c932] cd 15 c7
    ld      a,(hl)                          ;[c935] 7e
    or      b                               ;[c936] b0
    ld      (hl),a                          ;[c937] 77
    inc     hl                              ;[c938] 23
    dec     de                              ;[c939] 1b
    ld      a,d                             ;[c93a] 7a
    or      e                               ;[c93b] b3
    jr      nz,label_c932                   ;[c93c] 20 f4
    call    $c79e                           ;[c93e] cd 9e c7
    ret                                     ;[c941] c9

    ld      a,c                             ;[c942] 79
    cp      $44                             ;[c943] fe 44
    jr      nz,label_c94b                   ;[c945] 20 04
    ld      c,$40                           ;[c947] 0e 40
    jr      label_c984                      ;[c949] 18 39
label_c94b:
    cp      $45                             ;[c94b] fe 45
    jr      nz,label_c953                   ;[c94d] 20 04
    ld      c,$60                           ;[c94f] 0e 60
    jr      label_c984                      ;[c951] 18 31
label_c953:
    cp      $46                             ;[c953] fe 46
    jr      nz,label_c95b                   ;[c955] 20 04
    ld      c,$20                           ;[c957] 0e 20
    jr      label_c984                      ;[c959] 18 29
label_c95b:
    ld      a,($c86f)                       ;[c95b] 3a 6f c8
    ld      d,a                             ;[c95e] 57
    in      a,($d6)                         ;[c95f] db d6
    bit     5,a                             ;[c961] cb 6f
    jr      z,label_c967                    ;[c963] 28 02
    ld      d,$03                           ;[c965] 16 03
label_c967:
    bit     6,a                             ;[c967] cb 77
    jr      z,label_c96f                    ;[c969] 28 04
    set     5,d                             ;[c96b] cb ea
    set     6,d                             ;[c96d] cb f2
label_c96f:
    ld      a,d                             ;[c96f] 7a
    ld      ($ffd3),a                       ;[c970] 32 d3 ff
    ld      b,$0a                           ;[c973] 06 0a
    ld      c,a                             ;[c975] 4f
    call    $c916                           ;[c976] cd 16 c9
    ld      a,($c870)                       ;[c979] 3a 70 c8
    ld      c,a                             ;[c97c] 4f
    ld      b,$0b                           ;[c97d] 06 0b
    call    $c916                           ;[c97f] cd 16 c9
    xor     a                               ;[c982] af
    ret                                     ;[c983] c9

label_c984:
    ld      a,($ffd3)                       ;[c984] 3a d3 ff
    and     $9f                             ;[c987] e6 9f
    or      c                               ;[c989] b1
    ld      ($ffd3),a                       ;[c98a] 32 d3 ff
    ld      c,a                             ;[c98d] 4f
    ld      b,$0a                           ;[c98e] 06 0a
    call    $c916                           ;[c990] cd 16 c9
    xor     a                               ;[c993] af
    ret                                     ;[c994] c9

    ld      hl,$ffd1                        ;[c995] 21 d1 ff
    set     0,(hl)                          ;[c998] cb c6
    xor     a                               ;[c99a] af
    ret                                     ;[c99b] c9

    ld      hl,$ffd1                        ;[c99c] 21 d1 ff
    res     0,(hl)                          ;[c99f] cb 86
    xor     a                               ;[c9a1] af
    ret                                     ;[c9a2] c9

    ld      hl,$ffd1                        ;[c9a3] 21 d1 ff
    set     2,(hl)                          ;[c9a6] cb d6
    xor     a                               ;[c9a8] af
    ret                                     ;[c9a9] c9

    ld      hl,$ffd1                        ;[c9aa] 21 d1 ff
    res     2,(hl)                          ;[c9ad] cb 96
    xor     a                               ;[c9af] af
    ret                                     ;[c9b0] c9

    ld      hl,$ffd1                        ;[c9b1] 21 d1 ff
    set     1,(hl)                          ;[c9b4] cb ce
    xor     a                               ;[c9b6] af
    ret                                     ;[c9b7] c9

    ld      hl,$ffd1                        ;[c9b8] 21 d1 ff
    res     1,(hl)                          ;[c9bb] cb 8e
    xor     a                               ;[c9bd] af
    ret                                     ;[c9be] c9

    ld      a,($ffd1)                       ;[c9bf] 3a d1 ff
    and     $8f                             ;[c9c2] e6 8f
    or      $10                             ;[c9c4] f6 10
    ld      ($ffd1),a                       ;[c9c6] 32 d1 ff
    xor     a                               ;[c9c9] af
    ret                                     ;[c9ca] c9

    ld      a,($ffd1)                       ;[c9cb] 3a d1 ff
    and     $8f                             ;[c9ce] e6 8f
    or      $00                             ;[c9d0] f6 00
    ld      ($ffd1),a                       ;[c9d2] 32 d1 ff
    xor     a                               ;[c9d5] af
    ret                                     ;[c9d6] c9

    ld      a,($ffd1)                       ;[c9d7] 3a d1 ff
    and     $8f                             ;[c9da] e6 8f
    or      $20                             ;[c9dc] f6 20
    ld      ($ffd1),a                       ;[c9de] 32 d1 ff
    xor     a                               ;[c9e1] af
    ret                                     ;[c9e2] c9

label_c9e3:
    call    $ca01                           ;[c9e3] cd 01 ca
    cp      $01                             ;[c9e6] fe 01
    jr      nz,label_c9eb                   ;[c9e8] 20 01
    ld      a,c                             ;[c9ea] 79
label_c9eb:
    ld      ($ffd8),a                       ;[c9eb] 32 d8 ff
    cp      $60                             ;[c9ee] fe 60
    jp      nc,$ca70                        ;[c9f0] d2 70 ca
    sub     $31                             ;[c9f3] d6 31
    jp      c,$ca70                         ;[c9f5] da 70 ca
    call    $ca05                           ;[c9f8] cd 05 ca
    or      a                               ;[c9fb] b7
    jr      z,label_ca70                    ;[c9fc] 28 72
    jp      $c6a3                           ;[c9fe] c3 a3 c6
    ld      hl,($bffa)                      ;[ca01] 2a fa bf
    jp      (hl)                            ;[ca04] e9
    add     a                               ;[ca05] 87
    ld      hl,$ca12                        ;[ca06] 21 12 ca
    ld      d,$00                           ;[ca09] 16 00
    ld      e,a                             ;[ca0b] 5f
    add     hl,de                           ;[ca0c] 19
    ld      e,(hl)                          ;[ca0d] 5e
    inc     hl                              ;[ca0e] 23
    ld      d,(hl)                          ;[ca0f] 56
    ex      de,hl                           ;[ca10] eb
    jp      (hl)                            ;[ca11] e9
    ld      b,d                             ;[ca12] 42
    call    $cd46                           ;[ca13] cd 46 cd
    ld      a,d                             ;[ca16] 7a
    jp      z,$ca7a                         ;[ca17] ca 7a ca
    ld      a,d                             ;[ca1a] 7a
    jp      z,$ca7c                         ;[ca1b] ca 7c ca
    cp      a                               ;[ca1e] bf
    ret                                     ;[ca1f] c9

    ld      a,a                             ;[ca20] 7f
    call    z,$ca7a                         ;[ca21] cc 7a ca
    call    nc,$f2ca                        ;[ca24] d4 ca f2
    jp      z,$cb1c                         ;[ca27] ca 1c cb
    ld      l,d                             ;[ca2a] 6a
    res     3,a                             ;[ca2b] cb 9f
    res     7,e                             ;[ca2d] cb bb
    bit     7,h                             ;[ca2f] cb 7c
    jp      z,$c875                         ;[ca31] ca 75 c8
    xor     h                               ;[ca34] ac
    ret     z                               ;[ca35] c8
    ld      a,d                             ;[ca36] 7a
    jp      z,$c942                         ;[ca37] ca 42 c9
    ld      b,d                             ;[ca3a] 42
    ret                                     ;[ca3b] c9

    ld      b,d                             ;[ca3c] 42
    ret                                     ;[ca3d] c9

    ld      b,d                             ;[ca3e] 42
    ret                                     ;[ca3f] c9

    sub     l                               ;[ca40] 95
    ret                                     ;[ca41] c9

    sbc     h                               ;[ca42] 9c
    ret                                     ;[ca43] c9

    and     e                               ;[ca44] a3
    ret                                     ;[ca45] c9

    xor     d                               ;[ca46] aa
    ret                                     ;[ca47] c9

    or      c                               ;[ca48] b1
    ret                                     ;[ca49] c9

    cp      b                               ;[ca4a] b8
    ret                                     ;[ca4b] c9

    ld      b,l                             ;[ca4c] 45
    call    z,$ca7a                         ;[ca4d] cc 7a ca
    xor     e                               ;[ca50] ab
    call    z,$ccdf                         ;[ca51] cc df cc
    ld      a,d                             ;[ca54] 7a
    jp      z,$cbda                         ;[ca55] ca da cb
    inc     b                               ;[ca58] 04
    call    z,$cc1b                         ;[ca59] cc 1b cc
    inc     sp                              ;[ca5c] 33
    call    z,$c9bf                         ;[ca5d] cc bf c9
    set     1,c                             ;[ca60] cb c9
    rst     $10                             ;[ca62] d7
    ret                                     ;[ca63] c9

    cp      a                               ;[ca64] bf
    ret                                     ;[ca65] c9

    ld      a,a                             ;[ca66] 7f
    call    z,$c8df                         ;[ca67] cc df c8
    call    m,$95c8                         ;[ca6a] fc c8 95
    call    z,$cd27                         ;[ca6d] cc 27 cd
label_ca70:
    xor     a                               ;[ca70] af
    ld      ($ffd8),a                       ;[ca71] 32 d8 ff
    ld      ($ffd9),a                       ;[ca74] 32 d9 ff
    jp      $c6a3                           ;[ca77] c3 a3 c6
    xor     a                               ;[ca7a] af
    ret                                     ;[ca7b] c9

    call    $cdd7                           ;[ca7c] cd d7 cd
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

    call    $cdd7                           ;[cad4] cd d7 cd
    cp      $04                             ;[cad7] fe 04
    jr      z,label_cadf                    ;[cad9] 28 04
    call    $c901                           ;[cadb] cd 01 c9
    ret                                     ;[cade] c9

label_cadf:
    ld      a,c                             ;[cadf] 79
    sub     $20                             ;[cae0] d6 20
    ld      e,a                             ;[cae2] 5f
    ld      hl,$ffda                        ;[cae3] 21 da ff
    ld      b,(hl)                          ;[cae6] 46
    inc     hl                              ;[cae7] 23
    ld      c,(hl)                          ;[cae8] 4e
    inc     hl                              ;[cae9] 23
    ld      d,(hl)                          ;[caea] 56
    ld      a,$01                           ;[caeb] 3e 01
    call    $c91d                           ;[caed] cd 1d c9
    xor     a                               ;[caf0] af
    ret                                     ;[caf1] c9

    call    $cdd7                           ;[caf2] cd d7 cd
    cp      $02                             ;[caf5] fe 02
    jr      z,label_cafd                    ;[caf7] 28 04
    call    $c901                           ;[caf9] cd 01 c9
    ret                                     ;[cafc] c9

label_cafd:
    ld      a,c                             ;[cafd] 79
    sub     $20                             ;[cafe] d6 20
    ld      e,a                             ;[cb00] 5f
    ld      a,($ffda)                       ;[cb01] 3a da ff
    ld      d,a                             ;[cb04] 57
    ld      a,($ffd3)                       ;[cb05] 3a d3 ff
    and     $60                             ;[cb08] e6 60
    or      d                               ;[cb0a] b2
    ld      ($ffd3),a                       ;[cb0b] 32 d3 ff
    ld      c,a                             ;[cb0e] 4f
    ld      b,$0a                           ;[cb0f] 06 0a
    call    $c916                           ;[cb11] cd 16 c9
    ld      c,e                             ;[cb14] 4b
    ld      b,$0b                           ;[cb15] 06 0b
    call    $c916                           ;[cb17] cd 16 c9
    xor     a                               ;[cb1a] af
    ret                                     ;[cb1b] c9

    call    $cdd7                           ;[cb1c] cd d7 cd
    cp      $04                             ;[cb1f] fe 04
    jr      z,label_cb27                    ;[cb21] 28 04
    call    $c901                           ;[cb23] cd 01 c9
    ret                                     ;[cb26] c9

label_cb27:
    ld      a,c                             ;[cb27] 79
    sub     $20                             ;[cb28] d6 20
    ld      e,a                             ;[cb2a] 5f
    ld      a,$4f                           ;[cb2b] 3e 4f
    cp      e                               ;[cb2d] bb
    jr      c,label_cb68                    ;[cb2e] 38 38
    ld      hl,$ffda                        ;[cb30] 21 da ff
    ld      b,(hl)                          ;[cb33] 46
    inc     hl                              ;[cb34] 23
    ld      a,(hl)                          ;[cb35] 7e
    cp      $18                             ;[cb36] fe 18
    jr      nc,label_cb68                   ;[cb38] 30 2e
    ld      c,a                             ;[cb3a] 4f
    inc     hl                              ;[cb3b] 23
    ld      d,(hl)                          ;[cb3c] 56
    ld      a,c                             ;[cb3d] 79
    cp      b                               ;[cb3e] b8
    jr      c,label_cb68                    ;[cb3f] 38 27
    ld      a,e                             ;[cb41] 7b
    cp      d                               ;[cb42] ba
    jr      c,label_cb68                    ;[cb43] 38 23
    ld      hl,$ffcd                        ;[cb45] 21 cd ff
    ld      (hl),c                          ;[cb48] 71
    inc     hl                              ;[cb49] 23
    ld      (hl),b                          ;[cb4a] 70
    inc     hl                              ;[cb4b] 23
    ld      (hl),e                          ;[cb4c] 73
    inc     hl                              ;[cb4d] 23
    ld      (hl),d                          ;[cb4e] 72
    ld      a,$01                           ;[cb4f] 3e 01
    ld      ($ffc9),a                       ;[cb51] 32 c9 ff
    ld      a,$50                           ;[cb54] 3e 50
    sub     e                               ;[cb56] 93
    ld      e,a                             ;[cb57] 5f
    ld      a,d                             ;[cb58] 7a
    add     e                               ;[cb59] 83
    ld      hl,$ffd1                        ;[cb5a] 21 d1 ff
    bit     3,(hl)                          ;[cb5d] cb 5e
    jr      z,label_cb62                    ;[cb5f] 28 01
    add     a                               ;[cb61] 87
label_cb62:
    ld      ($ffc8),a                       ;[cb62] 32 c8 ff
    call    $cc1b                           ;[cb65] cd 1b cc
label_cb68:
    xor     a                               ;[cb68] af
    ret                                     ;[cb69] c9

    call    $cdd7                           ;[cb6a] cd d7 cd
    cp      $02                             ;[cb6d] fe 02
    jr      z,label_cb75                    ;[cb6f] 28 04
    call    $c901                           ;[cb71] cd 01 c9
    ret                                     ;[cb74] c9

label_cb75:
    ld      a,c                             ;[cb75] 79
    sub     $20                             ;[cb76] d6 20
    ld      c,a                             ;[cb78] 4f
    ld      a,$4f                           ;[cb79] 3e 4f
    cp      c                               ;[cb7b] b9
    jr      c,label_cb9d                    ;[cb7c] 38 1f
    ld      a,($ffd1)                       ;[cb7e] 3a d1 ff
    bit     3,a                             ;[cb81] cb 5f
    jr      z,label_cb88                    ;[cb83] 28 03
    ld      a,c                             ;[cb85] 79
    add     a                               ;[cb86] 87
    ld      c,a                             ;[cb87] 4f
label_cb88:
    ld      a,($ffda)                       ;[cb88] 3a da ff
    cp      $19                             ;[cb8b] fe 19
    jr      nc,label_cb9d                   ;[cb8d] 30 0e
    ld      b,a                             ;[cb8f] 47
    ld      ($ffcb),a                       ;[cb90] 32 cb ff
    ld      a,c                             ;[cb93] 79
    ld      ($ffca),a                       ;[cb94] 32 ca ff
    call    $c6f1                           ;[cb97] cd f1 c6
    call    $c71c                           ;[cb9a] cd 1c c7
label_cb9d:
    xor     a                               ;[cb9d] af
    ret                                     ;[cb9e] c9

    call    $cdd7                           ;[cb9f] cd d7 cd
    ld      a,c                             ;[cba2] 79
    sub     $20                             ;[cba3] d6 20
    ld      c,a                             ;[cba5] 4f
    ld      a,$4f                           ;[cba6] 3e 4f
    cp      c                               ;[cba8] b9
    jr      c,label_cbb9                    ;[cba9] 38 0e
    ld      a,($ffcb)                       ;[cbab] 3a cb ff
    ld      b,a                             ;[cbae] 47
    ld      a,c                             ;[cbaf] 79
    ld      ($ffca),a                       ;[cbb0] 32 ca ff
    call    $c6f1                           ;[cbb3] cd f1 c6
    call    $c71c                           ;[cbb6] cd 1c c7
label_cbb9:
    xor     a                               ;[cbb9] af
    ret                                     ;[cbba] c9

    call    $cdd7                           ;[cbbb] cd d7 cd
    cp      $04                             ;[cbbe] fe 04
    jr      z,label_cbc6                    ;[cbc0] 28 04
    call    $c901                           ;[cbc2] cd 01 c9
    ret                                     ;[cbc5] c9

label_cbc6:
    ld      a,c                             ;[cbc6] 79
    sub     $20                             ;[cbc7] d6 20
    ld      e,a                             ;[cbc9] 5f
    ld      hl,$ffda                        ;[cbca] 21 da ff
    ld      b,(hl)                          ;[cbcd] 46
    inc     hl                              ;[cbce] 23
    ld      c,(hl)                          ;[cbcf] 4e
    inc     hl                              ;[cbd0] 23
    ld      d,(hl)                          ;[cbd1] 56
    ld      a,($ffd2)                       ;[cbd2] 3a d2 ff
    call    $c91d                           ;[cbd5] cd 1d c9
    xor     a                               ;[cbd8] af
    ret                                     ;[cbd9] c9

    ld      bc,$0780                        ;[cbda] 01 80 07
    push    ix                              ;[cbdd] dd e5
    pop     hl                              ;[cbdf] e1
    call    $c795                           ;[cbe0] cd 95 c7
    ld      a,($ffd2)                       ;[cbe3] 3a d2 ff
    ld      d,a                             ;[cbe6] 57
    ld      e,$20                           ;[cbe7] 1e 20
label_cbe9:
    call    $c715                           ;[cbe9] cd 15 c7
    ld      a,(hl)                          ;[cbec] 7e
    and     d                               ;[cbed] a2
    jr      nz,label_cbf9                   ;[cbee] 20 09
    ld      (hl),$00                        ;[cbf0] 36 00
    call    $c795                           ;[cbf2] cd 95 c7
    ld      (hl),e                          ;[cbf5] 73
    call    $c795                           ;[cbf6] cd 95 c7
label_cbf9:
    inc     hl                              ;[cbf9] 23
    dec     bc                              ;[cbfa] 0b
    ld      a,b                             ;[cbfb] 78
    or      c                               ;[cbfc] b1
    jr      nz,label_cbe9                   ;[cbfd] 20 ea
    call    $c79e                           ;[cbff] cd 9e c7
    xor     a                               ;[cc02] af
    ret                                     ;[cc03] c9

    ld      a,($ffd0)                       ;[cc04] 3a d0 ff
    ld      c,a                             ;[cc07] 4f
    ld      a,($ffce)                       ;[cc08] 3a ce ff
    ld      b,a                             ;[cc0b] 47
    ld      a,($ffcf)                       ;[cc0c] 3a cf ff
    ld      e,a                             ;[cc0f] 5f
    ld      a,($ffcd)                       ;[cc10] 3a cd ff
    ld      d,a                             ;[cc13] 57
    call    $c805                           ;[cc14] cd 05 c8
    call    $cc1b                           ;[cc17] cd 1b cc
    ret                                     ;[cc1a] c9

    ld      a,($ffce)                       ;[cc1b] 3a ce ff
    ld      b,a                             ;[cc1e] 47
    ld      a,($ffd0)                       ;[cc1f] 3a d0 ff
    ld      c,a                             ;[cc22] 4f
    call    $c6f1                           ;[cc23] cd f1 c6
    call    $c71c                           ;[cc26] cd 1c c7
    ld      a,b                             ;[cc29] 78
    ld      ($ffcb),a                       ;[cc2a] 32 cb ff
    ld      a,c                             ;[cc2d] 79
    ld      ($ffca),a                       ;[cc2e] 32 ca ff
    xor     a                               ;[cc31] af
    ret                                     ;[cc32] c9

    call    $c764                           ;[cc33] cd 64 c7
    ld      a,$01                           ;[cc36] 3e 01
    ld      ($ffc8),a                       ;[cc38] 32 c8 ff
    ld      a,$4f                           ;[cc3b] 3e 4f
    ld      ($ffcf),a                       ;[cc3d] 32 cf ff
    call    $c8bf                           ;[cc40] cd bf c8
    xor     a                               ;[cc43] af
    ret                                     ;[cc44] c9

    ld      b,$00                           ;[cc45] 06 00
label_cc47:
    ld      c,$00                           ;[cc47] 0e 00
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

    call    $cdd7                           ;[cc7f] cd d7 cd
    ld      a,c                             ;[cc82] 79
    and     $0f                             ;[cc83] e6 0f
    rlca                                    ;[cc85] 07
    rlca                                    ;[cc86] 07
    rlca                                    ;[cc87] 07
    rlca                                    ;[cc88] 07
    ld      b,a                             ;[cc89] 47
    ld      a,($ffd1)                       ;[cc8a] 3a d1 ff
    and     $0f                             ;[cc8d] e6 0f
    or      b                               ;[cc8f] b0
    ld      ($ffd1),a                       ;[cc90] 32 d1 ff
    xor     a                               ;[cc93] af
    ret                                     ;[cc94] c9

    call    $cdd7                           ;[cc95] cd d7 cd
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
    ld      a,($ffcb)                       ;[ccab] 3a cb ff
    ld      b,a                             ;[ccae] 47
    ld      d,a                             ;[ccaf] 57
    ld      a,($ffca)                       ;[ccb0] 3a ca ff
    ld      c,a                             ;[ccb3] 4f
    ld      a,($ffcf)                       ;[ccb4] 3a cf ff
    ld      e,a                             ;[ccb7] 5f
    call    $c805                           ;[ccb8] cd 05 c8
    xor     a                               ;[ccbb] af
    ret                                     ;[ccbc] c9

label_ccbd:
    ld      a,($ffce)                       ;[ccbd] 3a ce ff
    ld      b,a                             ;[ccc0] 47
    ld      a,($ffcb)                       ;[ccc1] 3a cb ff
    ld      ($ffce),a                       ;[ccc4] 32 ce ff
    ld      a,($ffc9)                       ;[ccc7] 3a c9 ff
    ld      c,a                             ;[ccca] 4f
    ld      a,$01                           ;[cccb] 3e 01
    ld      ($ffc9),a                       ;[cccd] 32 c9 ff
    push    bc                              ;[ccd0] c5
    call    $c62e                           ;[ccd1] cd 2e c6
    pop     bc                              ;[ccd4] c1
    ld      a,b                             ;[ccd5] 78
    ld      ($ffce),a                       ;[ccd6] 32 ce ff
    ld      a,c                             ;[ccd9] 79
    ld      ($ffc9),a                       ;[ccda] 32 c9 ff
    xor     a                               ;[ccdd] af
    ret                                     ;[ccde] c9

label_ccdf:
    ld      a,($ffcb)                       ;[ccdf] 3a cb ff
    ld      b,a                             ;[cce2] 47
    ld      a,($ffca)                       ;[cce3] 3a ca ff
    ld      c,a                             ;[cce6] 4f
    ld      a,($ffcd)                       ;[cce7] 3a cd ff
    ld      d,a                             ;[ccea] 57
    ld      a,($ffcf)                       ;[cceb] 3a cf ff
    ld      e,a                             ;[ccee] 5f
    call    $c805                           ;[ccef] cd 05 c8
    xor     a                               ;[ccf2] af
    ret                                     ;[ccf3] c9

label_ccf4:
    ld      a,($ffce)                       ;[ccf4] 3a ce ff
    ld      b,a                             ;[ccf7] 47
    ld      a,($ffcb)                       ;[ccf8] 3a cb ff
    ld      c,a                             ;[ccfb] 4f
    ld      a,($ffcd)                       ;[ccfc] 3a cd ff
    cp      c                               ;[ccff] b9
    jr      z,label_cd18                    ;[cd00] 28 16
    ld      a,c                             ;[cd02] 79
    ld      ($ffce),a                       ;[cd03] 32 ce ff
    push    bc                              ;[cd06] c5
    call    $c830                           ;[cd07] cd 30 c8
    pop     bc                              ;[cd0a] c1
    ld      a,b                             ;[cd0b] 78
    ld      ($ffce),a                       ;[cd0c] 32 ce ff
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
    call    $cdd7                           ;[cd27] cd d7 cd
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

label_cd42:
    ld      b,$19                           ;[cd42] 06 19
    jr      label_cd48                      ;[cd44] 18 02
label_cd46:
    ld      b,$18                           ;[cd46] 06 18
label_cd48:
    ld      a,$06                           ;[cd48] 3e 06
    out     ($a0),a                         ;[cd4a] d3 a0
    ld      a,b                             ;[cd4c] 78
    out     ($a1),a                         ;[cd4d] d3 a1
    xor     a                               ;[cd4f] af
    ret                                     ;[cd50] c9

label_cd51:
    ld      hl,($bff4)                      ;[cd51] 2a f4 bf
    ex      de,hl                           ;[cd54] eb
    ld      b,$18                           ;[cd55] 06 18
    ld      c,$00                           ;[cd57] 0e 00
    call    $c6f1                           ;[cd59] cd f1 c6
    ld      a,($bfea)                       ;[cd5c] 3a ea bf
    ld      c,a                             ;[cd5f] 4f
    ld      b,$46                           ;[cd60] 06 46
    ld      a,b                             ;[cd62] 78
    ld      ($ffda),a                       ;[cd63] 32 da ff
label_cd66:
    call    $c715                           ;[cd66] cd 15 c7
    ld      a,(de)                          ;[cd69] 1a
    ld      (hl),a                          ;[cd6a] 77
    call    $c795                           ;[cd6b] cd 95 c7
    ld      (hl),c                          ;[cd6e] 71
    call    $c79e                           ;[cd6f] cd 9e c7
    inc     de                              ;[cd72] 13
    inc     hl                              ;[cd73] 23
    djnz    label_cd66                      ;[cd74] 10 f0
    ld      a,($ffda)                       ;[cd76] 3a da ff
    or      a                               ;[cd79] b7
    jr      z,label_cd88                    ;[cd7a] 28 0c
    ld      b,$0a                           ;[cd7c] 06 0a
    ld      a,($bfeb)                       ;[cd7e] 3a eb bf
    ld      c,a                             ;[cd81] 4f
    xor     a                               ;[cd82] af
    ld      ($ffda),a                       ;[cd83] 32 da ff
    jr      label_cd66                      ;[cd86] 18 de
label_cd88:
    xor     a                               ;[cd88] af
    ret                                     ;[cd89] c9

label_cd8a:
    ld      a,c                             ;[cd8a] 79
    cp      $0d                             ;[cd8b] fe 0d
    jr      z,label_cdb5                    ;[cd8d] 28 26
    ld      a,($ffd9)                       ;[cd8f] 3a d9 ff
    cp      $01                             ;[cd92] fe 01
    jr      z,label_cd9a                    ;[cd94] 28 04
    call    $cdb7                           ;[cd96] cd b7 cd
    ret                                     ;[cd99] c9

label_cd9a:
    ld      b,$18                           ;[cd9a] 06 18
    ld      c,$00                           ;[cd9c] 0e 00
    call    $c6f1                           ;[cd9e] cd f1 c6
    ld      ($ffda),hl                      ;[cda1] 22 da ff
    ld      a,$02                           ;[cda4] 3e 02
    ld      ($ffd9),a                       ;[cda6] 32 d9 ff
    ld      b,$46                           ;[cda9] 06 46
    ld      c,$20                           ;[cdab] 0e 20
label_cdad:
    call    $c715                           ;[cdad] cd 15 c7
    ld      (hl),c                          ;[cdb0] 71
    inc     hl                              ;[cdb1] 23
    djnz    label_cdad                      ;[cdb2] 10 f9
    ret                                     ;[cdb4] c9

label_cdb5:
    xor     a                               ;[cdb5] af
    ret                                     ;[cdb6] c9

    ld      b,a                             ;[cdb7] 47
    inc     a                               ;[cdb8] 3c
    ld      ($ffd9),a                       ;[cdb9] 32 d9 ff
    ld      hl,($ffda)                      ;[cdbc] 2a da ff
    call    $c715                           ;[cdbf] cd 15 c7
    ld      (hl),c                          ;[cdc2] 71
    ld      a,($bfeb)                       ;[cdc3] 3a eb bf
    call    $c795                           ;[cdc6] cd 95 c7
    ld      (hl),a                          ;[cdc9] 77
    call    $c79e                           ;[cdca] cd 9e c7
    inc     hl                              ;[cdcd] 23
    ld      ($ffda),hl                      ;[cdce] 22 da ff
    ld      a,b                             ;[cdd1] 78
    cp      $47                             ;[cdd2] fe 47
    ret     nz                              ;[cdd4] c0
    xor     a                               ;[cdd5] af
    ret                                     ;[cdd6] c9

    ld      a,($ffd9)                       ;[cdd7] 3a d9 ff
    or      a                               ;[cdda] b7
    ret     nz                              ;[cddb] c0
    inc     a                               ;[cddc] 3c
    ld      ($ffd9),a                       ;[cddd] 32 d9 ff
    pop     hl                              ;[cde0] e1
    ret                                     ;[cde1] c9

    call    $c69a                           ;[cde2] load ix and iy
    call    $c6f1                           ;[cde5] cd f1 c6
    call    $c715                           ;[cde8] cd 15 c7
    ld      (hl),d                          ;[cdeb] 72
    call    $c795                           ;[cdec] cd 95 c7
    ld      (hl),e                          ;[cdef] 73
    call    $c79e                           ;[cdf0] cd 9e c7
    ret                                     ;[cdf3] c9

    call    $c69a                           ;[cdf4] load ix and iy
    call    $c6f1                           ;[cdf7] cd f1 c6
    call    $c715                           ;[cdfa] cd 15 c7
    ld      d,(hl)                          ;[cdfd] 56
    call    $c795                           ;[cdfe] cd 95 c7
    ld      e,(hl)                          ;[ce01] 5e
    call    $c79e                           ;[ce02] cd 9e c7
    ret                                     ;[ce05] c9

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

