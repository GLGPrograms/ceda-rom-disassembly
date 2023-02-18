    org 0xc000

PUBLIC _main
_main:
    jp      $c030                           ;[c000] reset vector
    jp      $c027                           ;[c003]
    jp      $c027                           ;[c006]
    jp      $c45e                           ;[c009]
    jp      $c027                           ;[c00c]
    jp      $c027                           ;[c00f]
    jp      $c027                           ;[c012]
    jp      $c027                           ;[c015]
    jp      $c19d                           ;[c018]
    jp      $c18f                           ;[c01b]
    jp      $c174                           ;[c01e]
    jp      $cde2                           ;[c021]
    jp      $cdf4                           ;[c024]
label_c027:
    di                                      ;[c027]
    ld      a,$10                           ;[c028]
    out     ($b1),a                         ;[c02a]
    out     ($b3),a                         ;[c02c]
    jr      label_c040                      ;[c02e]

    ; main entrypoint, after reset
    ld      a,$89                           ;[c030] ???
    out     ($83),a                         ;[c032] ???
    di                                      ;[c034] disable interrupts
    ld      a,$10                           ;[c035] ???
    out     ($81),a                         ;[c037] ???

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
    ld      a,$12                           ;[c04c]
    out     ($b2),a                         ;[c04e]
label_c050:
    in      a,($b3)                         ;[c050]
    bit     0,a                             ;[c052]
    jr      z,label_c050                    ;[c054]
    in      a,($b2)                         ;[c056]
    out     ($da),a                         ;[c058]
    ld      c,$56                           ;[c05a] hardcoded 'V' for splash screen
    call    $c45e                           ;[c05c] putchar()
    ld      hl,$cffc                        ;[c05f] "Splash screen" string pointer
    ld      b,$04                           ;[c062]
label_c064:
    ld      c,(hl)                          ;[c064]
    inc     hl                              ;[c065]
    call    $c45e                           ;[c066] putchar()
    djnz    label_c064                      ;[c069]

label_c06b:
    call    $c0a7                           ;[c06b] getchar?
    ld      a,b                             ;[c06e]
    cp      $4d                             ;[c06f]
    jr      z,label_c088                    ;[c071] jump if getchar() == $4D (BOOT key)
    cp      $5c                             ;[c073]
    jr      nz,label_c06b                   ;[c075] repeat if getchar() != $5C (F15)

    ld      a,($8000)                       ;[c077]
    cpl                                     ;[c07a]
    ld      ($8000),a                       ;[c07b]
    ld      a,($8000)                       ;[c07e]
    cp      $c3                             ;[c081]
    jr      nz,label_c027                   ;[c083]
    jp      $8000                           ;[c085]
label_c088:
    ld      de,$0000                        ;[c088]
    ld      bc,$4000                        ;[c08b]
    ld      hl,$0080                        ;[c08e]
    ld      a,$01                           ;[c091]
    call    $c19d                           ;[c093]
    cp      $ff                             ;[c096]
    jr      nz,label_c09e                   ;[c098]
    out     ($da),a                         ;[c09a]
    jr      label_c088                      ;[c09c]
label_c09e:
    ld      a,$06                           ;[c09e]
    out     ($b2),a                         ;[c0a0]
    out     ($da),a                         ;[c0a2]
    jp      $0080                           ;[c0a4]

    ; Current idle loop
    ; At the moment, the PC hangs in this loop, reading 0x44 from $b3 IO
    ; getchar?
    ;    |-----------------------|
    ; BC | 0xxx xxxx | 1xxx xxxx |
    ;    |-----------------------|
    ;
label_c0a7:
    in      a,($b3)                         ;[c0a7]
    bit     0,a                             ;[c0a9]
    jr      z,label_c0a7                    ;[c0ab]
    in      a,($b2)                         ;[c0ad]
    ld      b,a                             ;[c0af]
    bit     7,a                             ;[c0b0]
    jr      nz,label_c0a7                   ;[c0b2] Repeat if MSb is 1
label_c0b4:
    in      a,($b3)                         ;[c0b4]
    bit     0,a                             ;[c0b6]
    jr      z,label_c0b4                    ;[c0b8]
    in      a,($b2)                         ;[c0ba]
    ld      c,a                             ;[c0bc]
    bit     7,a                             ;[c0bd]
    jr      z,label_c0b4                    ;[c0bf] Repeat if MSb is 0
    ret                                     ;[c0c1]

    ; SUBROUTINE C0C2
    im      2                               ;[c0c2] set interrupt mode 2
    call    $c0d1                           ;[c0c4] initialize timer ($e0)
    call    $c43f                           ;[c0c7] setup $c0 peripheral?
    call    $c108                           ;[c0ca] setup $b0 peripheral?
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

    BYTE $21 ; ???
    BYTE $34 ; ???

    pop     bc                              ;[c10a] c1
label_c10b:
    ld      a,(hl)                          ;[c10b] 7e
    inc     hl                              ;[c10c] 23
    cp      $ff                             ;[c10d] fe ff
    jr      z,label_c119                    ;[c10f] 28 08
    out     ($b1),a                         ;[c111] d3 b1
    ld      a,(hl)                          ;[c113] 7e
    out     ($b1),a                         ;[c114] d3 b1
    inc     hl                              ;[c116] 23
    jr      label_c10b                      ;[c117] 18 f2
label_c119:
    ld      a,(hl)                          ;[c119] 7e
    cp      $ff                             ;[c11a] fe ff
    jr      z,label_c127                    ;[c11c] 28 09
    out     ($b3),a                         ;[c11e] d3 b3
    inc     hl                              ;[c120] 23
    ld      a,(hl)                          ;[c121] 7e
    out     ($b3),a                         ;[c122] d3 b3
    inc     hl                              ;[c124] 23
    jr      label_c119                      ;[c125] 18 f2
label_c127:
    in      a,($b0)                         ;[c127] db b0
    in      a,($b2)                         ;[c129] db b2
    in      a,($b0)                         ;[c12b] db b0
    in      a,($b2)                         ;[c12d] db b2
    in      a,($b0)                         ;[c12f] db b0
    in      a,($b2)                         ;[c131] db b2
    ret                                     ;[c133] c9

    nop                                     ;[c134] 00
    djnz    label_c137                      ;[c135] 10 00
label_c137:
    djnz    label_c13d                      ;[c137] 10 04
    ld      b,h                             ;[c139] 44
    ld      bc,$0300                        ;[c13a] 01 00 03
label_c13d:
    pop     bc                              ;[c13d] c1
    dec     b                               ;[c13e] 05
    jp      pe,$00ff                        ;[c13f] ea ff 00
    djnz    label_c144                      ;[c142] 10 00
label_c144:
    djnz    label_c14a                      ;[c144] 10 04
    ld      b,h                             ;[c146] 44
    ld      bc,$0300                        ;[c147] 01 00 03
label_c14a:
    pop     bc                              ;[c14a] c1
    dec     b                               ;[c14b] 05
    ; WORK IN PROGRESS
    ; Original disassembled code was misaligned at this point.
    ; Manually fixed by removing the next instruction and splitting
    ; it in raw bytes and partial next opcode.
    ; jp      pe,$21ff                        ;[c14c] ea ff
    BYTE $ea
    BYTE $ff

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
    in      a,($81)                         ;[c165]/[0010] set bit 0 in $81
    set     0,a                             ;[c167]/[0012]
    out     ($81),a                         ;[c169]/[0014]
    ldir                                    ;[c16b]/[0016] do the memcpy
    res     0,a                             ;[c16d]/[0018] reset bit 0 in $81
    out     ($81),a                         ;[c16f]/[001a]
    out     ($de),a                         ;[c171]/[001c] and copy same value in $de
    ret                                     ;[c173]/[001e]

    push    af                              ;[c174] f5
    rrca                                    ;[c175] 0f
    rrca                                    ;[c176] 0f
    rrca                                    ;[c177] 0f
    rrca                                    ;[c178] 0f
    and     $0f                             ;[c179] e6 0f
    call    $c181                           ;[c17b] cd 81 c1
    pop     af                              ;[c17e] f1
    and     $0f                             ;[c17f] e6 0f
    call    $c187                           ;[c181] cd 87 c1
    jp      $c45e                           ;[c184] c3 5e c4
    add     $90                             ;[c187] c6 90
    daa                                     ;[c189] 27
    adc     $40                             ;[c18a] ce 40
    daa                                     ;[c18c] 27
    ld      c,a                             ;[c18d] 4f
    ret                                     ;[c18e] c9

    ex      (sp),hl                         ;[c18f] e3
label_c190:
    ld      a,(hl)                          ;[c190] 7e
    inc     hl                              ;[c191] 23
    or      a                               ;[c192] b7
    jr      z,label_c19b                    ;[c193] 28 06
    ld      c,a                             ;[c195] 4f
    call    $c45e                           ;[c196] cd 5e c4
    jr      label_c190                      ;[c199] 18 f5
label_c19b:
    ex      (sp),hl                         ;[c19b] e3
    ret                                     ;[c19c] c9

    push    bc                              ;[c19d] c5
    push    de                              ;[c19e] d5
    push    hl                              ;[c19f] e5
    ld      ($ffb8),a                       ;[c1a0] 32 b8 ff
    ld      a,$0a                           ;[c1a3] 3e 0a
    ld      ($ffbf),a                       ;[c1a5] 32 bf ff
    ld      ($ffb9),bc                      ;[c1a8] ed 43 b9 ff
    ld      ($ffbb),de                      ;[c1ac] ed 53 bb ff
    ld      ($ffbd),hl                      ;[c1b0] 22 bd ff
    call    $c423                           ;[c1b3] cd 23 c4
    ld      a,($ffba)                       ;[c1b6] 3a ba ff
    and     $f0                             ;[c1b9] e6 f0
    jp      z,$c1e6                         ;[c1bb] ca e6 c1
    cp      $40                             ;[c1be] fe 40
    jp      z,$c1dc                         ;[c1c0] ca dc c1
    cp      $80                             ;[c1c3] fe 80
    jp      z,$c1d7                         ;[c1c5] ca d7 c1
    cp      $20                             ;[c1c8] fe 20
    jp      z,$c1e1                         ;[c1ca] ca e1 c1
    cp      $f0                             ;[c1cd] fe f0
    jp      z,$c1eb                         ;[c1cf] ca eb c1
    ld      a,$ff                           ;[c1d2] 3e ff
    jp      $c1f0                           ;[c1d4] c3 f0 c1
    call    $c1f4                           ;[c1d7] cd f4 c1
    jr      label_c1f0                      ;[c1da] 18 14
    call    $c24a                           ;[c1dc] cd 4a c2
    jr      label_c1f0                      ;[c1df] 18 0f
    call    $c3a9                           ;[c1e1] cd a9 c3
    jr      label_c1f0                      ;[c1e4] 18 0a
    call    $c391                           ;[c1e6] cd 91 c3
    jr      label_c1f0                      ;[c1e9] 18 05
    call    $c2e3                           ;[c1eb] cd e3 c2
    jr      label_c1f0                      ;[c1ee] 18 00
label_c1f0:
    pop     hl                              ;[c1f0] e1
    pop     de                              ;[c1f1] d1
    pop     bc                              ;[c1f2] c1
    ret                                     ;[c1f3] c9

    call    $c3a9                           ;[c1f4] cd a9 c3
    call    $c2b7                           ;[c1f7] cd b7 c2
    push    de                              ;[c1fa] d5
    call    $c41c                           ;[c1fb] cd 1c c4
    ld      c,$c5                           ;[c1fe] 0e c5
    ld      a,($ffb8)                       ;[c200] 3a b8 ff
    or      a                               ;[c203] b7
    jr      nz,label_c208                   ;[c204] 20 02
    res     6,c                             ;[c206] cb b1
label_c208:
    call    $c415                           ;[c208] cd 15 c4
    di                                      ;[c20b] f3
    call    $c34e                           ;[c20c] cd 4e c3
    pop     de                              ;[c20f] d1
    ld      c,$c1                           ;[c210] 0e c1
    ld      b,e                             ;[c212] 43
    ld      hl,($ffbd)                      ;[c213] 2a bd ff
label_c216:
    in      a,($82)                         ;[c216] db 82
    bit     2,a                             ;[c218] cb 57
    jr      z,label_c216                    ;[c21a] 28 fa
    in      a,($c0)                         ;[c21c] db c0
    bit     5,a                             ;[c21e] cb 6f
    jr      z,label_c229                    ;[c220] 28 07
    outi                                    ;[c222] ed a3
    jr      nz,label_c216                   ;[c224] 20 f0
    dec     d                               ;[c226] 15
    jr      nz,label_c216                   ;[c227] 20 ed
label_c229:
    out     ($dc),a                         ;[c229] d3 dc
    ei                                      ;[c22b] fb
    call    $c3f4                           ;[c22c] cd f4 c3
    ld      a,($ffc0)                       ;[c22f] 3a c0 ff
    and     $c0                             ;[c232] e6 c0
    cp      $40                             ;[c234] fe 40
    jr      nz,label_c248                   ;[c236] 20 10
    call    $c2a0                           ;[c238] cd a0 c2
    ld      a,($ffbf)                       ;[c23b] 3a bf ff
    dec     a                               ;[c23e] 3d
    ld      ($ffbf),a                       ;[c23f] 32 bf ff
    jp      nz,$c1f7                        ;[c242] c2 f7 c1
    ld      a,$ff                           ;[c245] 3e ff
    ret                                     ;[c247] c9

label_c248:
    xor     a                               ;[c248] af
    ret                                     ;[c249] c9

    call    $c3a9                           ;[c24a] cd a9 c3
    call    $c2b7                           ;[c24d] cd b7 c2
    push    de                              ;[c250] d5
    call    $c41c                           ;[c251] cd 1c c4
    ld      c,$c6                           ;[c254] 0e c6
    ld      a,($ffb8)                       ;[c256] 3a b8 ff
    or      a                               ;[c259] b7
    jr      nz,label_c25e                   ;[c25a] 20 02
    res     6,c                             ;[c25c] cb b1
label_c25e:
    call    $c415                           ;[c25e] cd 15 c4
    di                                      ;[c261] f3
    call    $c34e                           ;[c262] cd 4e c3
    pop     de                              ;[c265] d1
    ld      c,$c1                           ;[c266] 0e c1
    ld      b,e                             ;[c268] 43
    ld      hl,($ffbd)                      ;[c269] 2a bd ff
label_c26c:
    in      a,($82)                         ;[c26c] db 82
    bit     2,a                             ;[c26e] cb 57
    jr      z,label_c26c                    ;[c270] 28 fa
    in      a,($c0)                         ;[c272] db c0
    bit     5,a                             ;[c274] cb 6f
    jr      z,label_c27f                    ;[c276] 28 07
    ini                                     ;[c278] ed a2
    jr      nz,label_c26c                   ;[c27a] 20 f0
    dec     d                               ;[c27c] 15
    jr      nz,label_c26c                   ;[c27d] 20 ed
label_c27f:
    out     ($dc),a                         ;[c27f] d3 dc
    ei                                      ;[c281] fb
    call    $c3f4                           ;[c282] cd f4 c3
    ld      a,($ffc0)                       ;[c285] 3a c0 ff
    and     $c0                             ;[c288] e6 c0
    cp      $40                             ;[c28a] fe 40
    jr      nz,label_c29e                   ;[c28c] 20 10
    call    $c2a0                           ;[c28e] cd a0 c2
    ld      a,($ffbf)                       ;[c291] 3a bf ff
    dec     a                               ;[c294] 3d
    ld      ($ffbf),a                       ;[c295] 32 bf ff
    jp      nz,$c24d                        ;[c298] c2 4d c2
    ld      a,$ff                           ;[c29b] 3e ff
    ret                                     ;[c29d] c9

label_c29e:
    xor     a                               ;[c29e] af
    ret                                     ;[c29f] c9

    ld      a,($ffc2)                       ;[c2a0] 3a c2 ff
    bit     4,a                             ;[c2a3] cb 67
    jr      z,label_c2ab                    ;[c2a5] 28 04
    call    $c391                           ;[c2a7] cd 91 c3
    ret                                     ;[c2aa] c9

label_c2ab:
    ld      a,($ffc1)                       ;[c2ab] 3a c1 ff
    bit     0,a                             ;[c2ae] cb 47
    jr      z,label_c2b6                    ;[c2b0] 28 04
    call    $c391                           ;[c2b2] cd 91 c3
    ret                                     ;[c2b5] c9

label_c2b6:
    ret                                     ;[c2b6] c9

    ld      e,$00                           ;[c2b7] 1e 00
    ld      a,($ffb8)                       ;[c2b9] 3a b8 ff
    cp      $03                             ;[c2bc] fe 03
    jr      nz,label_c2d4                   ;[c2be] 20 14
    ld      d,$04                           ;[c2c0] 16 04
    ld      a,($ffbb)                       ;[c2c2] 3a bb ff
    bit     7,a                             ;[c2c5] cb 7f
    jr      z,label_c2e2                    ;[c2c7] 28 19
    ld      a,($ffba)                       ;[c2c9] 3a ba ff
    and     $0f                             ;[c2cc] e6 0f
    rlca                                    ;[c2ce] 07
    rlca                                    ;[c2cf] 07
    add     d                               ;[c2d0] 82
    ld      d,a                             ;[c2d1] 57
    jr      label_c2e2                      ;[c2d2] 18 0e
label_c2d4:
    or      a                               ;[c2d4] b7
    jr      nz,label_c2d9                   ;[c2d5] 20 02
    ld      e,$80                           ;[c2d7] 1e 80
label_c2d9:
    ld      a,($ffba)                       ;[c2d9] 3a ba ff
    and     $0f                             ;[c2dc] e6 0f
    ld      d,$01                           ;[c2de] 16 01
    add     d                               ;[c2e0] 82
    ld      d,a                             ;[c2e1] 57
label_c2e2:
    ret                                     ;[c2e2] c9

    call    $c3a9                           ;[c2e3] cd a9 c3
    cp      $ff                             ;[c2e6] fe ff
    ret     z                               ;[c2e8] c8
    ld      b,$14                           ;[c2e9] 06 14
    ld      a,($ffb8)                       ;[c2eb] 3a b8 ff
    cp      $03                             ;[c2ee] fe 03
    jr      z,label_c2f4                    ;[c2f0] 28 02
    ld      b,$40                           ;[c2f2] 06 40
label_c2f4:
    push    bc                              ;[c2f4] c5
    call    $c41c                           ;[c2f5] cd 1c c4
    ld      c,$4d                           ;[c2f8] 0e 4d
    call    $c415                           ;[c2fa] cd 15 c4
    ld      bc,($ffb9)                      ;[c2fd] ed 4b b9 ff
    call    $c415                           ;[c301] cd 15 c4
    ld      a,($ffb8)                       ;[c304] 3a b8 ff
    ld      c,a                             ;[c307] 4f
    call    $c415                           ;[c308] cd 15 c4
    ld      c,$05                           ;[c30b] 0e 05
    ld      a,($ffb8)                       ;[c30d] 3a b8 ff
    cp      $03                             ;[c310] fe 03
    jr      z,label_c316                    ;[c312] 28 02
    ld      c,$10                           ;[c314] 0e 10
label_c316:
    call    $c415                           ;[c316] cd 15 c4
    ld      c,$28                           ;[c319] 0e 28
    call    $c415                           ;[c31b] cd 15 c4
    di                                      ;[c31e] f3
    ld      c,$e5                           ;[c31f] 0e e5
    call    $c415                           ;[c321] cd 15 c4
    pop     bc                              ;[c324] c1
    ld      c,$c1                           ;[c325] 0e c1
    ld      hl,($ffbd)                      ;[c327] 2a bd ff
label_c32a:
    in      a,($82)                         ;[c32a] db 82
    bit     2,a                             ;[c32c] cb 57
    jr      z,label_c32a                    ;[c32e] 28 fa
    in      a,($c0)                         ;[c330] db c0
    bit     5,a                             ;[c332] cb 6f
    jr      z,label_c33a                    ;[c334] 28 04
    outi                                    ;[c336] ed a3
    jr      nz,label_c32a                   ;[c338] 20 f0
label_c33a:
    out     ($dc),a                         ;[c33a] d3 dc
    ei                                      ;[c33c] fb
    call    $c3f4                           ;[c33d] cd f4 c3
    ld      a,($ffc0)                       ;[c340] 3a c0 ff
    and     $c0                             ;[c343] e6 c0
    cp      $40                             ;[c345] fe 40
    jr      nz,label_c34c                   ;[c347] 20 03
    ld      a,$ff                           ;[c349] 3e ff
    ret                                     ;[c34b] c9

label_c34c:
    xor     a                               ;[c34c] af
    ret                                     ;[c34d] c9

    ld      bc,($ffb9)                      ;[c34e] ed 4b b9 ff
    call    $c415                           ;[c352] cd 15 c4
    ld      de,($ffbb)                      ;[c355] ed 5b bb ff
    ld      c,d                             ;[c359] 4a
    call    $c415                           ;[c35a] cd 15 c4
    ld      bc,($ffb9)                      ;[c35d] ed 4b b9 ff
    ld      a,c                             ;[c361] 79
    and     $04                             ;[c362] e6 04
    rrca                                    ;[c364] 0f
    rrca                                    ;[c365] 0f
    ld      c,a                             ;[c366] 4f
    call    $c415                           ;[c367] cd 15 c4
    res     7,e                             ;[c36a] cb bb
    ld      c,e                             ;[c36c] 4b
    inc     c                               ;[c36d] 0c
    call    $c415                           ;[c36e] cd 15 c4
    ld      a,($ffb8)                       ;[c371] 3a b8 ff
    ld      c,a                             ;[c374] 4f
    call    $c415                           ;[c375] cd 15 c4
    ld      c,$05                           ;[c378] 0e 05
    ld      a,($ffb8)                       ;[c37a] 3a b8 ff
    cp      $03                             ;[c37d] fe 03
    jr      z,label_c383                    ;[c37f] 28 02
    ld      c,$10                           ;[c381] 0e 10
label_c383:
    call    $c415                           ;[c383] cd 15 c4
    ld      c,$28                           ;[c386] 0e 28
    call    $c415                           ;[c388] cd 15 c4
    ld      c,$ff                           ;[c38b] 0e ff
    call    $c415                           ;[c38d] cd 15 c4
    ret                                     ;[c390] c9

label_c391:
    call    $c41c                           ;[c391] cd 1c c4
    ld      c,$07                           ;[c394] 0e 07
    call    $c415                           ;[c396] cd 15 c4
    ld      bc,($ffb9)                      ;[c399] ed 4b b9 ff
    res     2,c                             ;[c39d] cb 91
    call    $c415                           ;[c39f] cd 15 c4
    call    $c3d2                           ;[c3a2] cd d2 c3
    jr      z,label_c391                    ;[c3a5] 28 ea
    xor     a                               ;[c3a7] af
    ret                                     ;[c3a8] c9

    ld      de,($ffbb)                      ;[c3a9] ed 5b bb ff
    ld      a,d                             ;[c3ad] 7a
    or      a                               ;[c3ae] b7
    jp      z,$c391                         ;[c3af] ca 91 c3
    call    $c41c                           ;[c3b2] cd 1c c4
    ld      c,$0f                           ;[c3b5] 0e 0f
    call    $c415                           ;[c3b7] cd 15 c4
    ld      bc,($ffb9)                      ;[c3ba] ed 4b b9 ff
    call    $c415                           ;[c3be] cd 15 c4
    ld      c,d                             ;[c3c1] 4a
    call    $c415                           ;[c3c2] cd 15 c4
    call    $c3d2                           ;[c3c5] cd d2 c3
    jr      nz,label_c3d0                   ;[c3c8] 20 06
    call    $c391                           ;[c3ca] cd 91 c3
    jp      $c3a9                           ;[c3cd] c3 a9 c3
label_c3d0:
    xor     a                               ;[c3d0] af
    ret                                     ;[c3d1] c9

    in      a,($82)                         ;[c3d2] db 82
    bit     2,a                             ;[c3d4] cb 57
    jp      z,$c3d2                         ;[c3d6] ca d2 c3
    call    $c41c                           ;[c3d9] cd 1c c4
    call    $c403                           ;[c3dc] cd 03 c4
    ld      a,$08                           ;[c3df] 3e 08
    out     ($c1),a                         ;[c3e1] d3 c1
    call    $c40c                           ;[c3e3] cd 0c c4
    in      a,($c1)                         ;[c3e6] db c1
    ld      b,a                             ;[c3e8] 47
    call    $c40c                           ;[c3e9] cd 0c c4
    in      a,($c1)                         ;[c3ec] db c1
    ld      a,b                             ;[c3ee] 78
    and     $c0                             ;[c3ef] e6 c0
    cp      $40                             ;[c3f1] fe 40
    ret                                     ;[c3f3] c9

    ld      hl,$ffc0                        ;[c3f4] 21 c0 ff
    ld      b,$07                           ;[c3f7] 06 07
    ld      c,$c1                           ;[c3f9] 0e c1
label_c3fb:
    call    $c40c                           ;[c3fb] cd 0c c4
    ini                                     ;[c3fe] ed a2
    jr      nz,label_c3fb                   ;[c400] 20 f9
    ret                                     ;[c402] c9

    ; SUBROUTINE C403 ; wait for ioaddr(0xc0) to become "0b10xxxxxx"
label_c403:
    in      a,($c0)                         ;[c403]
    rlca                                    ;[c405]
    jr      nc,label_c403                   ;[c406] while (bit7 == 0), try again
    rlca                                    ;[c408]
    jr      c,label_c403                    ;[c409] while (bit7 == 1) && (bit6 == 1), try again
    ret                                     ;[c40b]

    ; SUBROUTINE C40C ; wait for ioaddr(0xc0) to become "0b11xxxxxx"
label_c40c:
    in      a,($c0)                         ;[c40c]
    rlca                                    ;[c40e]
    jr      nc,label_c40c                   ;[c40f] while (bit7 == 0), try again
    rlca                                    ;[c411]
    jr      nc,label_c40c                   ;[c412] while (bit7 == 1) && (bit6 == 0), try again
    ret                                     ;[c414]

    ; SUBROUTINE C415
    call    $c403                           ;[c415]
    ld      a,c                             ;[c418]
    out     ($c1),a                         ;[c419]
    ret                                     ;[c41b]

    ; SUBROUTINE C41C ; while( ioaddr(0xc0).4 == 1 ), wait
label_c41c:
    in      a,($c0)                         ;[c41c]
    bit     4,a                             ;[c41e]
    jr      nz,label_c41c                   ;[c420]
    ret                                     ;[c422]

    ld      b,$01                           ;[c423] 06 01
    ld      a,c                             ;[c425] 79
    and     $03                             ;[c426] e6 03
    or      a                               ;[c428] b7
    jr      z,label_c430                    ;[c429] 28 05
label_c42b:
    rlc     b                               ;[c42b] cb 00
    dec     a                               ;[c42d] 3d
    jr      nz,label_c42b                   ;[c42e] 20 fb
label_c430:
    ld      a,($ffc7)                       ;[c430] 3a c7 ff
    ld      c,a                             ;[c433] 4f
    and     b                               ;[c434] a0
    ret     nz                              ;[c435] c0
    ld      a,c                             ;[c436] 79
    or      b                               ;[c437] b0
    ld      ($ffc7),a                       ;[c438] 32 c7 ff
    call    $c391                           ;[c43b] cd 91 c3
    ret                                     ;[c43e] c9

    ; SUBROUTINE C43F
    push    bc                              ;[c43f]
    push    hl                              ;[c440]
    ld      hl,$c45c                        ;[c441] prepare HL for later
    call    $c41c                           ;[c444] while( ioaddr(0xc0).4 == 1 ), wait
    ld      c,$03                           ;[c447]
    call    $c415                           ;[c449]
    ld      c,(hl)                          ;[c44c]
    inc     hl                              ;[c44d]
    call    $c415                           ;[c44e]
    ld      c,(hl)                          ;[c451]
    call    $c415                           ;[c452]
    xor     a                               ;[c455]
    ld      ($ffc7),a                       ;[c456]
    pop     hl                              ;[c459]
    pop     bc                              ;[c45a]
    ret                                     ;[c45b]

    ; STATIC DATA for C43F
    BYTE $6f
    BYTE $1b

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
    out     ($da),a                         ;[c5f5]
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

    ld      ($ffd4),ix                      ;[c6e8] dd 22 d4 ff
    ld      ($ffd6),iy                      ;[c6ec] fd 22 d6 ff
    ret                                     ;[c6f0] c9

    push    af                              ;[c6f1] f5
    push    bc                              ;[c6f2] c5
    push    de                              ;[c6f3] d5
    push    ix                              ;[c6f4] dd e5
    pop     hl                              ;[c6f6] e1
    ld      de,$0050                        ;[c6f7] 11 50 00
    ld      a,b                             ;[c6fa] 78
    ld      b,$05                           ;[c6fb] 06 05
label_c6fd:
    rra                                     ;[c6fd] 1f
    jr      nc,label_c701                   ;[c6fe] 30 01
    add     hl,de                           ;[c700] 19
label_c701:
    or      a                               ;[c701] b7
    rl      e                               ;[c702] cb 13
    rl      d                               ;[c704] cb 12
    dec     b                               ;[c706] 05
    jr      nz,label_c6fd                   ;[c707] 20 f4
    ld      d,$00                           ;[c709] 16 00
    ld      e,c                             ;[c70b] 59
    add     hl,de                           ;[c70c] 19
    ld      a,h                             ;[c70d] 7c
    and     $0f                             ;[c70e] e6 0f
    ld      h,a                             ;[c710] 67
    pop     de                              ;[c711] d1
    pop     bc                              ;[c712] c1
    pop     af                              ;[c713] f1
    ret                                     ;[c714] c9

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
    in      a,($82)                         ;[c75d] db 82
    bit     1,a                             ;[c75f] cb 4f
    jr      z,label_c75d                    ;[c761] 28 fa
    ret                                     ;[c763] c9

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
    out     ($81),a                         ;[c775]
    ld      (hl),e                          ;[c777] write 0 in bank switched video memory (?)
    res     7,a                             ;[c778] reset MSB in $81
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

    push    af                              ;[c795] f5
    in      a,($81)                         ;[c796] db 81
    set     7,a                             ;[c798] cb ff
    out     ($81),a                         ;[c79a] d3 81
    pop     af                              ;[c79c] f1
    ret                                     ;[c79d] c9

    push    af                              ;[c79e] f5
    in      a,($81)                         ;[c79f] db 81
    res     7,a                             ;[c7a1] cb bf
    out     ($81),a                         ;[c7a3] d3 81
    pop     af                              ;[c7a5] f1
    ret                                     ;[c7a6] c9

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

    call    $c69a                           ;[cde2] cd 9a c6
    call    $c6f1                           ;[cde5] cd f1 c6
    call    $c715                           ;[cde8] cd 15 c7
    ld      (hl),d                          ;[cdeb] 72
    call    $c795                           ;[cdec] cd 95 c7
    ld      (hl),e                          ;[cdef] 73
    call    $c79e                           ;[cdf0] cd 9e c7
    ret                                     ;[cdf3] c9

    call    $c69a                           ;[cdf4] cd 9a c6
    call    $c6f1                           ;[cdf7] cd f1 c6
    call    $c715                           ;[cdfa] cd 15 c7
    ld      d,(hl)                          ;[cdfd] 56
    call    $c795                           ;[cdfe] cd 95 c7
    ld      e,(hl)                          ;[ce01] 5e
    call    $c79e                           ;[ce02] cd 9e c7
    ret                                     ;[ce05] c9

    nop                                     ;[ce06] 00
    nop                                     ;[ce07] 00
    nop                                     ;[ce08] 00
    nop                                     ;[ce09] 00
    nop                                     ;[ce0a] 00
    nop                                     ;[ce0b] 00
    nop                                     ;[ce0c] 00
    nop                                     ;[ce0d] 00
    nop                                     ;[ce0e] 00
    nop                                     ;[ce0f] 00
    nop                                     ;[ce10] 00
    nop                                     ;[ce11] 00
    nop                                     ;[ce12] 00
    nop                                     ;[ce13] 00
    nop                                     ;[ce14] 00
    nop                                     ;[ce15] 00
    nop                                     ;[ce16] 00
    nop                                     ;[ce17] 00
    nop                                     ;[ce18] 00
    nop                                     ;[ce19] 00
    nop                                     ;[ce1a] 00
    nop                                     ;[ce1b] 00
    nop                                     ;[ce1c] 00
    nop                                     ;[ce1d] 00
    nop                                     ;[ce1e] 00
    nop                                     ;[ce1f] 00
    nop                                     ;[ce20] 00
    nop                                     ;[ce21] 00
    nop                                     ;[ce22] 00
    nop                                     ;[ce23] 00
    nop                                     ;[ce24] 00
    nop                                     ;[ce25] 00
    nop                                     ;[ce26] 00
    nop                                     ;[ce27] 00
    nop                                     ;[ce28] 00
    nop                                     ;[ce29] 00
    nop                                     ;[ce2a] 00
    nop                                     ;[ce2b] 00
    nop                                     ;[ce2c] 00
    nop                                     ;[ce2d] 00
    nop                                     ;[ce2e] 00
    nop                                     ;[ce2f] 00
    nop                                     ;[ce30] 00
    nop                                     ;[ce31] 00
    nop                                     ;[ce32] 00
    nop                                     ;[ce33] 00
    nop                                     ;[ce34] 00
    nop                                     ;[ce35] 00
    nop                                     ;[ce36] 00
    nop                                     ;[ce37] 00
    nop                                     ;[ce38] 00
    nop                                     ;[ce39] 00
    nop                                     ;[ce3a] 00
    nop                                     ;[ce3b] 00
    nop                                     ;[ce3c] 00
    nop                                     ;[ce3d] 00
    nop                                     ;[ce3e] 00
    nop                                     ;[ce3f] 00
    nop                                     ;[ce40] 00
    nop                                     ;[ce41] 00
    nop                                     ;[ce42] 00
    nop                                     ;[ce43] 00
    nop                                     ;[ce44] 00
    nop                                     ;[ce45] 00
    nop                                     ;[ce46] 00
    nop                                     ;[ce47] 00
    nop                                     ;[ce48] 00
    nop                                     ;[ce49] 00
    nop                                     ;[ce4a] 00
    nop                                     ;[ce4b] 00
    nop                                     ;[ce4c] 00
    nop                                     ;[ce4d] 00
    nop                                     ;[ce4e] 00
    nop                                     ;[ce4f] 00
    nop                                     ;[ce50] 00
    nop                                     ;[ce51] 00
    nop                                     ;[ce52] 00
    nop                                     ;[ce53] 00
    nop                                     ;[ce54] 00
    nop                                     ;[ce55] 00
    nop                                     ;[ce56] 00
    nop                                     ;[ce57] 00
    nop                                     ;[ce58] 00
    nop                                     ;[ce59] 00
    nop                                     ;[ce5a] 00
    nop                                     ;[ce5b] 00
    nop                                     ;[ce5c] 00
    nop                                     ;[ce5d] 00
    nop                                     ;[ce5e] 00
    nop                                     ;[ce5f] 00
    nop                                     ;[ce60] 00
    nop                                     ;[ce61] 00
    nop                                     ;[ce62] 00
    nop                                     ;[ce63] 00
    nop                                     ;[ce64] 00
    nop                                     ;[ce65] 00
    nop                                     ;[ce66] 00
    nop                                     ;[ce67] 00
    nop                                     ;[ce68] 00
    nop                                     ;[ce69] 00
    nop                                     ;[ce6a] 00
    nop                                     ;[ce6b] 00
    nop                                     ;[ce6c] 00
    nop                                     ;[ce6d] 00
    nop                                     ;[ce6e] 00
    nop                                     ;[ce6f] 00
    nop                                     ;[ce70] 00
    nop                                     ;[ce71] 00
    nop                                     ;[ce72] 00
    nop                                     ;[ce73] 00
    nop                                     ;[ce74] 00
    nop                                     ;[ce75] 00
    nop                                     ;[ce76] 00
    nop                                     ;[ce77] 00
    nop                                     ;[ce78] 00
    nop                                     ;[ce79] 00
    nop                                     ;[ce7a] 00
    nop                                     ;[ce7b] 00
    nop                                     ;[ce7c] 00
    nop                                     ;[ce7d] 00
    nop                                     ;[ce7e] 00
    nop                                     ;[ce7f] 00
    nop                                     ;[ce80] 00
    nop                                     ;[ce81] 00
    nop                                     ;[ce82] 00
    nop                                     ;[ce83] 00
    nop                                     ;[ce84] 00
    nop                                     ;[ce85] 00
    nop                                     ;[ce86] 00
    nop                                     ;[ce87] 00
    nop                                     ;[ce88] 00
    nop                                     ;[ce89] 00
    nop                                     ;[ce8a] 00
    nop                                     ;[ce8b] 00
    nop                                     ;[ce8c] 00
    nop                                     ;[ce8d] 00
    nop                                     ;[ce8e] 00
    nop                                     ;[ce8f] 00
    nop                                     ;[ce90] 00
    nop                                     ;[ce91] 00
    nop                                     ;[ce92] 00
    nop                                     ;[ce93] 00
    nop                                     ;[ce94] 00
    nop                                     ;[ce95] 00
    nop                                     ;[ce96] 00
    nop                                     ;[ce97] 00
    nop                                     ;[ce98] 00
    nop                                     ;[ce99] 00
    nop                                     ;[ce9a] 00
    nop                                     ;[ce9b] 00
    nop                                     ;[ce9c] 00
    nop                                     ;[ce9d] 00
    nop                                     ;[ce9e] 00
    nop                                     ;[ce9f] 00
    nop                                     ;[cea0] 00
    nop                                     ;[cea1] 00
    nop                                     ;[cea2] 00
    nop                                     ;[cea3] 00
    nop                                     ;[cea4] 00
    nop                                     ;[cea5] 00
    nop                                     ;[cea6] 00
    nop                                     ;[cea7] 00
    nop                                     ;[cea8] 00
    nop                                     ;[cea9] 00
    nop                                     ;[ceaa] 00
    nop                                     ;[ceab] 00
    nop                                     ;[ceac] 00
    nop                                     ;[cead] 00
    nop                                     ;[ceae] 00
    nop                                     ;[ceaf] 00
    nop                                     ;[ceb0] 00
    nop                                     ;[ceb1] 00
    nop                                     ;[ceb2] 00
    nop                                     ;[ceb3] 00
    nop                                     ;[ceb4] 00
    nop                                     ;[ceb5] 00
    nop                                     ;[ceb6] 00
    nop                                     ;[ceb7] 00
    nop                                     ;[ceb8] 00
    nop                                     ;[ceb9] 00
    nop                                     ;[ceba] 00
    nop                                     ;[cebb] 00
    nop                                     ;[cebc] 00
    nop                                     ;[cebd] 00
    nop                                     ;[cebe] 00
    nop                                     ;[cebf] 00
    nop                                     ;[cec0] 00
    nop                                     ;[cec1] 00
    nop                                     ;[cec2] 00
    nop                                     ;[cec3] 00
    nop                                     ;[cec4] 00
    nop                                     ;[cec5] 00
    nop                                     ;[cec6] 00
    nop                                     ;[cec7] 00
    nop                                     ;[cec8] 00
    nop                                     ;[cec9] 00
    nop                                     ;[ceca] 00
    nop                                     ;[cecb] 00
    nop                                     ;[cecc] 00
    nop                                     ;[cecd] 00
    nop                                     ;[cece] 00
    nop                                     ;[cecf] 00
    nop                                     ;[ced0] 00
    nop                                     ;[ced1] 00
    nop                                     ;[ced2] 00
    nop                                     ;[ced3] 00
    nop                                     ;[ced4] 00
    nop                                     ;[ced5] 00
    nop                                     ;[ced6] 00
    nop                                     ;[ced7] 00
    nop                                     ;[ced8] 00
    nop                                     ;[ced9] 00
    nop                                     ;[ceda] 00
    nop                                     ;[cedb] 00
    nop                                     ;[cedc] 00
    nop                                     ;[cedd] 00
    nop                                     ;[cede] 00
    nop                                     ;[cedf] 00
    nop                                     ;[cee0] 00
    nop                                     ;[cee1] 00
    nop                                     ;[cee2] 00
    nop                                     ;[cee3] 00
    nop                                     ;[cee4] 00
    nop                                     ;[cee5] 00
    nop                                     ;[cee6] 00
    nop                                     ;[cee7] 00
    nop                                     ;[cee8] 00
    nop                                     ;[cee9] 00
    nop                                     ;[ceea] 00
    nop                                     ;[ceeb] 00
    nop                                     ;[ceec] 00
    nop                                     ;[ceed] 00
    nop                                     ;[ceee] 00
    nop                                     ;[ceef] 00
    nop                                     ;[cef0] 00
    nop                                     ;[cef1] 00
    nop                                     ;[cef2] 00
    nop                                     ;[cef3] 00
    nop                                     ;[cef4] 00
    nop                                     ;[cef5] 00
    nop                                     ;[cef6] 00
    nop                                     ;[cef7] 00
    nop                                     ;[cef8] 00
    nop                                     ;[cef9] 00
    nop                                     ;[cefa] 00
    nop                                     ;[cefb] 00
    nop                                     ;[cefc] 00
    nop                                     ;[cefd] 00
    nop                                     ;[cefe] 00
    nop                                     ;[ceff] 00
    nop                                     ;[cf00] 00
    nop                                     ;[cf01] 00
    nop                                     ;[cf02] 00
    nop                                     ;[cf03] 00
    nop                                     ;[cf04] 00
    nop                                     ;[cf05] 00
    nop                                     ;[cf06] 00
    nop                                     ;[cf07] 00
    nop                                     ;[cf08] 00
    nop                                     ;[cf09] 00
    nop                                     ;[cf0a] 00
    nop                                     ;[cf0b] 00
    nop                                     ;[cf0c] 00
    nop                                     ;[cf0d] 00
    nop                                     ;[cf0e] 00
    nop                                     ;[cf0f] 00
    nop                                     ;[cf10] 00
    nop                                     ;[cf11] 00
    nop                                     ;[cf12] 00
    nop                                     ;[cf13] 00
    nop                                     ;[cf14] 00
    nop                                     ;[cf15] 00
    nop                                     ;[cf16] 00
    nop                                     ;[cf17] 00
    nop                                     ;[cf18] 00
    nop                                     ;[cf19] 00
    nop                                     ;[cf1a] 00
    nop                                     ;[cf1b] 00
    nop                                     ;[cf1c] 00
    nop                                     ;[cf1d] 00
    nop                                     ;[cf1e] 00
    nop                                     ;[cf1f] 00
    nop                                     ;[cf20] 00
    nop                                     ;[cf21] 00
    nop                                     ;[cf22] 00
    nop                                     ;[cf23] 00
    nop                                     ;[cf24] 00
    nop                                     ;[cf25] 00
    nop                                     ;[cf26] 00
    nop                                     ;[cf27] 00
    nop                                     ;[cf28] 00
    nop                                     ;[cf29] 00
    nop                                     ;[cf2a] 00
    nop                                     ;[cf2b] 00
    nop                                     ;[cf2c] 00
    nop                                     ;[cf2d] 00
    nop                                     ;[cf2e] 00
    nop                                     ;[cf2f] 00
    nop                                     ;[cf30] 00
    nop                                     ;[cf31] 00
    nop                                     ;[cf32] 00
    nop                                     ;[cf33] 00
    nop                                     ;[cf34] 00
    nop                                     ;[cf35] 00
    nop                                     ;[cf36] 00
    nop                                     ;[cf37] 00
    nop                                     ;[cf38] 00
    nop                                     ;[cf39] 00
    nop                                     ;[cf3a] 00
    nop                                     ;[cf3b] 00
    nop                                     ;[cf3c] 00
    nop                                     ;[cf3d] 00
    nop                                     ;[cf3e] 00
    nop                                     ;[cf3f] 00
    nop                                     ;[cf40] 00
    nop                                     ;[cf41] 00
    nop                                     ;[cf42] 00
    nop                                     ;[cf43] 00
    nop                                     ;[cf44] 00
    nop                                     ;[cf45] 00
    nop                                     ;[cf46] 00
    nop                                     ;[cf47] 00
    nop                                     ;[cf48] 00
    nop                                     ;[cf49] 00
    nop                                     ;[cf4a] 00
    nop                                     ;[cf4b] 00
    nop                                     ;[cf4c] 00
    nop                                     ;[cf4d] 00
    nop                                     ;[cf4e] 00
    nop                                     ;[cf4f] 00
    nop                                     ;[cf50] 00
    nop                                     ;[cf51] 00
    nop                                     ;[cf52] 00
    nop                                     ;[cf53] 00
    nop                                     ;[cf54] 00
    nop                                     ;[cf55] 00
    nop                                     ;[cf56] 00
    nop                                     ;[cf57] 00
    nop                                     ;[cf58] 00
    nop                                     ;[cf59] 00
    nop                                     ;[cf5a] 00
    nop                                     ;[cf5b] 00
    nop                                     ;[cf5c] 00
    nop                                     ;[cf5d] 00
    nop                                     ;[cf5e] 00
    nop                                     ;[cf5f] 00
    nop                                     ;[cf60] 00
    nop                                     ;[cf61] 00
    nop                                     ;[cf62] 00
    nop                                     ;[cf63] 00
    nop                                     ;[cf64] 00
    nop                                     ;[cf65] 00
    nop                                     ;[cf66] 00
    nop                                     ;[cf67] 00
    nop                                     ;[cf68] 00
    nop                                     ;[cf69] 00
    nop                                     ;[cf6a] 00
    nop                                     ;[cf6b] 00
    nop                                     ;[cf6c] 00
    nop                                     ;[cf6d] 00
    nop                                     ;[cf6e] 00
    nop                                     ;[cf6f] 00
    nop                                     ;[cf70] 00
    nop                                     ;[cf71] 00
    nop                                     ;[cf72] 00
    nop                                     ;[cf73] 00
    nop                                     ;[cf74] 00
    nop                                     ;[cf75] 00
    nop                                     ;[cf76] 00
    nop                                     ;[cf77] 00
    nop                                     ;[cf78] 00
    nop                                     ;[cf79] 00
    nop                                     ;[cf7a] 00
    nop                                     ;[cf7b] 00
    nop                                     ;[cf7c] 00
    nop                                     ;[cf7d] 00
    nop                                     ;[cf7e] 00
    nop                                     ;[cf7f] 00
    nop                                     ;[cf80] 00
    nop                                     ;[cf81] 00
    nop                                     ;[cf82] 00
    nop                                     ;[cf83] 00
    nop                                     ;[cf84] 00
    nop                                     ;[cf85] 00
    nop                                     ;[cf86] 00
    nop                                     ;[cf87] 00
    nop                                     ;[cf88] 00
    nop                                     ;[cf89] 00
    nop                                     ;[cf8a] 00
    nop                                     ;[cf8b] 00
    nop                                     ;[cf8c] 00
    nop                                     ;[cf8d] 00
    nop                                     ;[cf8e] 00
    nop                                     ;[cf8f] 00
    nop                                     ;[cf90] 00
    nop                                     ;[cf91] 00
    nop                                     ;[cf92] 00
    nop                                     ;[cf93] 00
    nop                                     ;[cf94] 00
    nop                                     ;[cf95] 00
    nop                                     ;[cf96] 00
    nop                                     ;[cf97] 00
    nop                                     ;[cf98] 00
    nop                                     ;[cf99] 00
    nop                                     ;[cf9a] 00
    nop                                     ;[cf9b] 00
    nop                                     ;[cf9c] 00
    nop                                     ;[cf9d] 00
    nop                                     ;[cf9e] 00
    nop                                     ;[cf9f] 00
    nop                                     ;[cfa0] 00
    nop                                     ;[cfa1] 00
    nop                                     ;[cfa2] 00
    nop                                     ;[cfa3] 00
    nop                                     ;[cfa4] 00
    nop                                     ;[cfa5] 00
    nop                                     ;[cfa6] 00
    nop                                     ;[cfa7] 00
    nop                                     ;[cfa8] 00
    nop                                     ;[cfa9] 00
    nop                                     ;[cfaa] 00
    nop                                     ;[cfab] 00
    nop                                     ;[cfac] 00
    nop                                     ;[cfad] 00
    nop                                     ;[cfae] 00
    nop                                     ;[cfaf] 00
    nop                                     ;[cfb0] 00
    nop                                     ;[cfb1] 00
    nop                                     ;[cfb2] 00
    nop                                     ;[cfb3] 00
    nop                                     ;[cfb4] 00
    nop                                     ;[cfb5] 00
    nop                                     ;[cfb6] 00
    nop                                     ;[cfb7] 00
    nop                                     ;[cfb8] 00
    nop                                     ;[cfb9] 00
    nop                                     ;[cfba] 00
    nop                                     ;[cfbb] 00
    nop                                     ;[cfbc] 00
    nop                                     ;[cfbd] 00
    nop                                     ;[cfbe] 00
    nop                                     ;[cfbf] 00
    nop                                     ;[cfc0] 00
    nop                                     ;[cfc1] 00
    nop                                     ;[cfc2] 00
    nop                                     ;[cfc3] 00
    nop                                     ;[cfc4] 00
    nop                                     ;[cfc5] 00
    nop                                     ;[cfc6] 00
    nop                                     ;[cfc7] 00
    nop                                     ;[cfc8] 00
    nop                                     ;[cfc9] 00
    nop                                     ;[cfca] 00
    nop                                     ;[cfcb] 00
    nop                                     ;[cfcc] 00
    nop                                     ;[cfcd] 00
    nop                                     ;[cfce] 00
    nop                                     ;[cfcf] 00
    nop                                     ;[cfd0] 00
    nop                                     ;[cfd1] 00
    nop                                     ;[cfd2] 00
    nop                                     ;[cfd3] 00
    nop                                     ;[cfd4] 00
    nop                                     ;[cfd5] 00
    nop                                     ;[cfd6] 00
    nop                                     ;[cfd7] 00
    nop                                     ;[cfd8] 00
    nop                                     ;[cfd9] 00
    nop                                     ;[cfda] 00
    nop                                     ;[cfdb] 00
    nop                                     ;[cfdc] 00
    nop                                     ;[cfdd] 00
    nop                                     ;[cfde] 00
    nop                                     ;[cfdf] 00
    nop                                     ;[cfe0] 00
    nop                                     ;[cfe1] 00
    nop                                     ;[cfe2] 00
    nop                                     ;[cfe3] 00
    nop                                     ;[cfe4] 00
    nop                                     ;[cfe5] 00
    nop                                     ;[cfe6] 00
    nop                                     ;[cfe7] 00
    nop                                     ;[cfe8] 00
    nop                                     ;[cfe9] 00
    nop                                     ;[cfea] 00
    nop                                     ;[cfeb] 00
    nop                                     ;[cfec] 00
    nop                                     ;[cfed] 00
    nop                                     ;[cfee] 00
    nop                                     ;[cfef] 00
    nop                                     ;[cff0] 00
    nop                                     ;[cff1] 00
    nop                                     ;[cff2] 00
    nop                                     ;[cff3] 00
    nop                                     ;[cff4] 00
    nop                                     ;[cff5] 00
    nop                                     ;[cff6] 00
    nop                                     ;[cff7] 00
    nop                                     ;[cff8] 00
    nop                                     ;[cff9] 00
    nop                                     ;[cffa] 00
    nop                                     ;[cffb] 00

    ; "Splash screen" string ; 1.01
    BYTE $31
    BYTE $2e
    BYTE $30
    BYTE $31

    ; In the original ROM, here starts a perfect replica of all the above program.
    ; Except for the "splash screen", which is $31 $2e $30 $ff