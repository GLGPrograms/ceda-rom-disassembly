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
    di                                      ;[c027]
    ld      a,$10                           ;[c028]
    out     ($b1),a                         ;[c02a]
    out     ($b3),a                         ;[c02c]
    jr      $c040                           ;[c02e]

    ; main entrypoint, after reset
    ld      a,$89                           ;[c030] ???
    out     ($83),a                         ;[c032] ???
    di                                      ;[c034] disable interrupts
    ld      a,$10                           ;[c035] ???
    out     ($81),a                         ;[c037] ???

    ; delay, measured oscilloscope 208 ms
    ld      h,$7d                           ;[c039] hl = $7d
    dec     hl                              ;[c03b]
    ld      a,h                             ;[c03c]
    or      l                               ;[c03d] check for hl == 0
    jr      nz,$c03b                        ;[c03e]

    ld      sp,$0080                        ;[c040] setup stack pointer
    call    $c0c2                           ;[c043]
    call    $c6af                           ;[c046]
    call    $c14e                           ;[c049]
    ld      a,$12                           ;[c04c]
    out     ($b2),a                         ;[c04e]
    in      a,($b3)                         ;[c050]
    bit     0,a                             ;[c052]
    jr      z,$c050                         ;[c054]
    in      a,($b2)                         ;[c056]
    out     ($da),a                         ;[c058]
    ld      c,$56                           ;[c05a]
    call    $c45e                           ;[c05c]
    ld      hl,$cffc                        ;[c05f]
    ld      b,$04                           ;[c062]
    ld      c,(hl)                          ;[c064]
    inc     hl                              ;[c065]
    call    $c45e                           ;[c066]
    djnz    $c064                           ;[c069]
    call    $c0a7                           ;[c06b]
    ld      a,b                             ;[c06e]
    cp      $4d                             ;[c06f]
    jr      z,$c088                         ;[c071]
    cp      $5c                             ;[c073]
    jr      nz,$c06b                        ;[c075]
    ld      a,($8000)                       ;[c077]
    cpl                                     ;[c07a]
    ld      ($8000),a                       ;[c07b]
    ld      a,($8000)                       ;[c07e]
    cp      $c3                             ;[c081]
    jr      nz,$c027                        ;[c083]
    jp      $8000                           ;[c085]
    ld      de,$0000                        ;[c088]
    ld      bc,$4000                        ;[c08b]
    ld      hl,$0080                        ;[c08e]
    ld      a,$01                           ;[c091]
    call    $c19d                           ;[c093]
    cp      $ff                             ;[c096]
    jr      nz,$c09e                        ;[c098]
    out     ($da),a                         ;[c09a]
    jr      $c088                           ;[c09c]
    ld      a,$06                           ;[c09e]
    out     ($b2),a                         ;[c0a0]
    out     ($da),a                         ;[c0a2]
    jp      $0080                           ;[c0a4]

    ; Current idle loop
    ; At the moment, the PC hangs in this loop, reading 0x44 from $b3 IO
    in      a,($b3)                         ;[c0a7]
    bit     0,a                             ;[c0a9]
    jr      z,$c0a7                         ;[c0ab]

    in      a,($b2)                         ;[c0ad]
    ld      b,a                             ;[c0af]
    bit     7,a                             ;[c0b0]
    jr      nz,$c0a7                        ;[c0b2]
    in      a,($b3)                         ;[c0b4]
    bit     0,a                             ;[c0b6]
    jr      z,$c0b4                         ;[c0b8]
    in      a,($b2)                         ;[c0ba]
    ld      c,a                             ;[c0bc]
    bit     7,a                             ;[c0bd]
    jr      z,$c0b4                         ;[c0bf]
    ret                                     ;[c0c1]

    ; SUBROUTINE C0C2
    im      2                               ;[c0c2] set interrupt mode 2
    call    $c0d1                           ;[c0c4] initialize timer
    call    $c43f                           ;[c0c7]
    call    $c108                           ;[c0ca]
    call    $c88d                           ;[c0cd]
    ret                                     ;[c0d0]

    ; SUBROUTINE C0D1; initialize timer (base ioaddr(0xE0))
    ld      hl,$c0f1                        ;[c0d1] ; initialization table base address
    ld      a,(hl)                          ;[c0d4]
    inc     hl                              ;[c0d5]
    cp      $ff                             ;[c0d6] check for initialization table end
    jr      z,$c0e1                         ;[c0d8] if table is ended, go on
    ld      c,a                             ;[c0da]
    ld      a,(hl)                          ;[c0db]
    inc     hl                              ;[c0dc]
    out     (c),a                           ;[c0dd]
    jr      $c0d4                           ;[c0df] loop table

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
    ;[c0f1] e2 05 ; timer 2: configuration
    ;[c0f3] e2 10 ; timer 2: time constant
    ;[c0f5] e2 41 ; timer 2: select counter mode
    ;[c0f7] e3 05 ; timer 3: configuration
    ;[c0f9] e3 01 ; timer 3: time constant
    ;[c0fb] e3 41 ; timer 3: select counter mode
    ;[c0fd] e1 05 ; timer 1: configuration
    ;[c0ff] ff

    ; probably another table
    ; len = 8, deduced from what happens at C0E3
    ; this could be some prescaler for timer1
    ;[c100] ae
    ;[c101] 40
    ;[c102] 20
    ;[c103] 10
    ;[c104] 08
    ;[c105] 04
    ;[c106] 02
    ;[c107] 01

    ;[c108] 21 34 ???
    pop     bc                              ;[c10a] c1
    ld      a,(hl)                          ;[c10b] 7e
    inc     hl                              ;[c10c] 23
    cp      $ff                             ;[c10d] fe ff
    jr      z,$c119                         ;[c10f] 28 08
    out     ($b1),a                         ;[c111] d3 b1
    ld      a,(hl)                          ;[c113] 7e
    out     ($b1),a                         ;[c114] d3 b1
    inc     hl                              ;[c116] 23
    jr      $c10b                           ;[c117] 18 f2
    ld      a,(hl)                          ;[c119] 7e
    cp      $ff                             ;[c11a] fe ff
    jr      z,$c127                         ;[c11c] 28 09
    out     ($b3),a                         ;[c11e] d3 b3
    inc     hl                              ;[c120] 23
    ld      a,(hl)                          ;[c121] 7e
    out     ($b3),a                         ;[c122] d3 b3
    inc     hl                              ;[c124] 23
    jr      $c119                           ;[c125] 18 f2
    in      a,($b0)                         ;[c127] db b0
    in      a,($b2)                         ;[c129] db b2
    in      a,($b0)                         ;[c12b] db b0
    in      a,($b2)                         ;[c12d] db b2
    in      a,($b0)                         ;[c12f] db b0
    in      a,($b2)                         ;[c131] db b2
    ret                                     ;[c133] c9

    nop                                     ;[c134] 00
    djnz    $c137                           ;[c135] 10 00
    djnz    $c13d                           ;[c137] 10 04
    ld      b,h                             ;[c139] 44
    ld      bc,$0300                        ;[c13a] 01 00 03
    pop     bc                              ;[c13d] c1
    dec     b                               ;[c13e] 05
    jp      pe,$00ff                        ;[c13f] ea ff 00
    djnz    $c144                           ;[c142] 10 00
    djnz    $c14a                           ;[c144] 10 04
    ld      b,h                             ;[c146] 44
    ld      bc,$0300                        ;[c147] 01 00 03
    pop     bc                              ;[c14a] c1
    dec     b                               ;[c14b] 05
    jp      pe,$21ff                        ;[c14c] ea ff 21
    ld      h,l                             ;[c14f] 65
    pop     bc                              ;[c150] c1
    ld      de,$0010                        ;[c151] 11 10 00
    ld      bc,$000f                        ;[c154] 01 0f 00
    ldir                                    ;[c157] ed b0
    ld      hl,$0000                        ;[c159] 21 00 00
    ld      de,$0000                        ;[c15c] 11 00 00
    ld      bc,$0000                        ;[c15f] 01 00 00
    jp      $0010                           ;[c162] c3 10 00
    in      a,($81)                         ;[c165] db 81
    set     0,a                             ;[c167] cb c7
    out     ($81),a                         ;[c169] d3 81
    ldir                                    ;[c16b] ed b0
    res     0,a                             ;[c16d] cb 87
    out     ($81),a                         ;[c16f] d3 81
    out     ($de),a                         ;[c171] d3 de
    ret                                     ;[c173] c9

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
    ld      a,(hl)                          ;[c190] 7e
    inc     hl                              ;[c191] 23
    or      a                               ;[c192] b7
    jr      z,$c19b                         ;[c193] 28 06
    ld      c,a                             ;[c195] 4f
    call    $c45e                           ;[c196] cd 5e c4
    jr      $c190                           ;[c199] 18 f5
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
    jr      $c1f0                           ;[c1da] 18 14
    call    $c24a                           ;[c1dc] cd 4a c2
    jr      $c1f0                           ;[c1df] 18 0f
    call    $c3a9                           ;[c1e1] cd a9 c3
    jr      $c1f0                           ;[c1e4] 18 0a
    call    $c391                           ;[c1e6] cd 91 c3
    jr      $c1f0                           ;[c1e9] 18 05
    call    $c2e3                           ;[c1eb] cd e3 c2
    jr      $c1f0                           ;[c1ee] 18 00
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
    jr      nz,$c208                        ;[c204] 20 02
    res     6,c                             ;[c206] cb b1
    call    $c415                           ;[c208] cd 15 c4
    di                                      ;[c20b] f3
    call    $c34e                           ;[c20c] cd 4e c3
    pop     de                              ;[c20f] d1
    ld      c,$c1                           ;[c210] 0e c1
    ld      b,e                             ;[c212] 43
    ld      hl,($ffbd)                      ;[c213] 2a bd ff
    in      a,($82)                         ;[c216] db 82
    bit     2,a                             ;[c218] cb 57
    jr      z,$c216                         ;[c21a] 28 fa
    in      a,($c0)                         ;[c21c] db c0
    bit     5,a                             ;[c21e] cb 6f
    jr      z,$c229                         ;[c220] 28 07
    outi                                    ;[c222] ed a3
    jr      nz,$c216                        ;[c224] 20 f0
    dec     d                               ;[c226] 15
    jr      nz,$c216                        ;[c227] 20 ed
    out     ($dc),a                         ;[c229] d3 dc
    ei                                      ;[c22b] fb
    call    $c3f4                           ;[c22c] cd f4 c3
    ld      a,($ffc0)                       ;[c22f] 3a c0 ff
    and     $c0                             ;[c232] e6 c0
    cp      $40                             ;[c234] fe 40
    jr      nz,$c248                        ;[c236] 20 10
    call    $c2a0                           ;[c238] cd a0 c2
    ld      a,($ffbf)                       ;[c23b] 3a bf ff
    dec     a                               ;[c23e] 3d
    ld      ($ffbf),a                       ;[c23f] 32 bf ff
    jp      nz,$c1f7                        ;[c242] c2 f7 c1
    ld      a,$ff                           ;[c245] 3e ff
    ret                                     ;[c247] c9

    xor     a                               ;[c248] af
    ret                                     ;[c249] c9

    call    $c3a9                           ;[c24a] cd a9 c3
    call    $c2b7                           ;[c24d] cd b7 c2
    push    de                              ;[c250] d5
    call    $c41c                           ;[c251] cd 1c c4
    ld      c,$c6                           ;[c254] 0e c6
    ld      a,($ffb8)                       ;[c256] 3a b8 ff
    or      a                               ;[c259] b7
    jr      nz,$c25e                        ;[c25a] 20 02
    res     6,c                             ;[c25c] cb b1
    call    $c415                           ;[c25e] cd 15 c4
    di                                      ;[c261] f3
    call    $c34e                           ;[c262] cd 4e c3
    pop     de                              ;[c265] d1
    ld      c,$c1                           ;[c266] 0e c1
    ld      b,e                             ;[c268] 43
    ld      hl,($ffbd)                      ;[c269] 2a bd ff
    in      a,($82)                         ;[c26c] db 82
    bit     2,a                             ;[c26e] cb 57
    jr      z,$c26c                         ;[c270] 28 fa
    in      a,($c0)                         ;[c272] db c0
    bit     5,a                             ;[c274] cb 6f
    jr      z,$c27f                         ;[c276] 28 07
    ini                                     ;[c278] ed a2
    jr      nz,$c26c                        ;[c27a] 20 f0
    dec     d                               ;[c27c] 15
    jr      nz,$c26c                        ;[c27d] 20 ed
    out     ($dc),a                         ;[c27f] d3 dc
    ei                                      ;[c281] fb
    call    $c3f4                           ;[c282] cd f4 c3
    ld      a,($ffc0)                       ;[c285] 3a c0 ff
    and     $c0                             ;[c288] e6 c0
    cp      $40                             ;[c28a] fe 40
    jr      nz,$c29e                        ;[c28c] 20 10
    call    $c2a0                           ;[c28e] cd a0 c2
    ld      a,($ffbf)                       ;[c291] 3a bf ff
    dec     a                               ;[c294] 3d
    ld      ($ffbf),a                       ;[c295] 32 bf ff
    jp      nz,$c24d                        ;[c298] c2 4d c2
    ld      a,$ff                           ;[c29b] 3e ff
    ret                                     ;[c29d] c9

    xor     a                               ;[c29e] af
    ret                                     ;[c29f] c9

    ld      a,($ffc2)                       ;[c2a0] 3a c2 ff
    bit     4,a                             ;[c2a3] cb 67
    jr      z,$c2ab                         ;[c2a5] 28 04
    call    $c391                           ;[c2a7] cd 91 c3
    ret                                     ;[c2aa] c9

    ld      a,($ffc1)                       ;[c2ab] 3a c1 ff
    bit     0,a                             ;[c2ae] cb 47
    jr      z,$c2b6                         ;[c2b0] 28 04
    call    $c391                           ;[c2b2] cd 91 c3
    ret                                     ;[c2b5] c9

    ret                                     ;[c2b6] c9

    ld      e,$00                           ;[c2b7] 1e 00
    ld      a,($ffb8)                       ;[c2b9] 3a b8 ff
    cp      $03                             ;[c2bc] fe 03
    jr      nz,$c2d4                        ;[c2be] 20 14
    ld      d,$04                           ;[c2c0] 16 04
    ld      a,($ffbb)                       ;[c2c2] 3a bb ff
    bit     7,a                             ;[c2c5] cb 7f
    jr      z,$c2e2                         ;[c2c7] 28 19
    ld      a,($ffba)                       ;[c2c9] 3a ba ff
    and     $0f                             ;[c2cc] e6 0f
    rlca                                    ;[c2ce] 07
    rlca                                    ;[c2cf] 07
    add     d                               ;[c2d0] 82
    ld      d,a                             ;[c2d1] 57
    jr      $c2e2                           ;[c2d2] 18 0e
    or      a                               ;[c2d4] b7
    jr      nz,$c2d9                        ;[c2d5] 20 02
    ld      e,$80                           ;[c2d7] 1e 80
    ld      a,($ffba)                       ;[c2d9] 3a ba ff
    and     $0f                             ;[c2dc] e6 0f
    ld      d,$01                           ;[c2de] 16 01
    add     d                               ;[c2e0] 82
    ld      d,a                             ;[c2e1] 57
    ret                                     ;[c2e2] c9

    call    $c3a9                           ;[c2e3] cd a9 c3
    cp      $ff                             ;[c2e6] fe ff
    ret     z                               ;[c2e8] c8
    ld      b,$14                           ;[c2e9] 06 14
    ld      a,($ffb8)                       ;[c2eb] 3a b8 ff
    cp      $03                             ;[c2ee] fe 03
    jr      z,$c2f4                         ;[c2f0] 28 02
    ld      b,$40                           ;[c2f2] 06 40
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
    jr      z,$c316                         ;[c312] 28 02
    ld      c,$10                           ;[c314] 0e 10
    call    $c415                           ;[c316] cd 15 c4
    ld      c,$28                           ;[c319] 0e 28
    call    $c415                           ;[c31b] cd 15 c4
    di                                      ;[c31e] f3
    ld      c,$e5                           ;[c31f] 0e e5
    call    $c415                           ;[c321] cd 15 c4
    pop     bc                              ;[c324] c1
    ld      c,$c1                           ;[c325] 0e c1
    ld      hl,($ffbd)                      ;[c327] 2a bd ff
    in      a,($82)                         ;[c32a] db 82
    bit     2,a                             ;[c32c] cb 57
    jr      z,$c32a                         ;[c32e] 28 fa
    in      a,($c0)                         ;[c330] db c0
    bit     5,a                             ;[c332] cb 6f
    jr      z,$c33a                         ;[c334] 28 04
    outi                                    ;[c336] ed a3
    jr      nz,$c32a                        ;[c338] 20 f0
    out     ($dc),a                         ;[c33a] d3 dc
    ei                                      ;[c33c] fb
    call    $c3f4                           ;[c33d] cd f4 c3
    ld      a,($ffc0)                       ;[c340] 3a c0 ff
    and     $c0                             ;[c343] e6 c0
    cp      $40                             ;[c345] fe 40
    jr      nz,$c34c                        ;[c347] 20 03
    ld      a,$ff                           ;[c349] 3e ff
    ret                                     ;[c34b] c9

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
    jr      z,$c383                         ;[c37f] 28 02
    ld      c,$10                           ;[c381] 0e 10
    call    $c415                           ;[c383] cd 15 c4
    ld      c,$28                           ;[c386] 0e 28
    call    $c415                           ;[c388] cd 15 c4
    ld      c,$ff                           ;[c38b] 0e ff
    call    $c415                           ;[c38d] cd 15 c4
    ret                                     ;[c390] c9

    call    $c41c                           ;[c391] cd 1c c4
    ld      c,$07                           ;[c394] 0e 07
    call    $c415                           ;[c396] cd 15 c4
    ld      bc,($ffb9)                      ;[c399] ed 4b b9 ff
    res     2,c                             ;[c39d] cb 91
    call    $c415                           ;[c39f] cd 15 c4
    call    $c3d2                           ;[c3a2] cd d2 c3
    jr      z,$c391                         ;[c3a5] 28 ea
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
    jr      nz,$c3d0                        ;[c3c8] 20 06
    call    $c391                           ;[c3ca] cd 91 c3
    jp      $c3a9                           ;[c3cd] c3 a9 c3
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
    call    $c40c                           ;[c3fb] cd 0c c4
    ini                                     ;[c3fe] ed a2
    jr      nz,$c3fb                        ;[c400] 20 f9
    ret                                     ;[c402] c9

    ; SUBROUTINE C403 ; wait for ioaddr(0xc0) to become "0b10xxxxxx"
    in      a,($c0)                         ;[c403]
    rlca                                    ;[c405]
    jr      nc,$c403                        ;[c406] while (bit7 == 0), try again
    rlca                                    ;[c408]
    jr      c,$c403                         ;[c409] while (bit7 == 1) && (bit6 == 1), try again
    ret                                     ;[c40b]

    ; SUBROUTINE C40C ; wait for ioaddr(0xc0) to become "0b11xxxxxx"
    in      a,($c0)                         ;[c40c]
    rlca                                    ;[c40e]
    jr      nc,$c40c                        ;[c40f] while (bit7 == 0), try again
    rlca                                    ;[c411]
    jr      nc,$c40c                        ;[c412] while (bit7 == 1) && (bit6 == 0), try again
    ret                                     ;[c414]

    ; SUBROUTINE C415
    call    $c403                           ;[c415]
    ld      a,c                             ;[c418]
    out     ($c1),a                         ;[c419]
    ret                                     ;[c41b]

    ; FUNCTION C41C ; while( ioaddr(0xc0).4 == 1 ), wait
    in      a,($c0)                         ;[c41c]
    bit     4,a                             ;[c41e]
    jr      nz,$c41c                        ;[c420]
    ret                                     ;[c422]

    ld      b,$01                           ;[c423] 06 01
    ld      a,c                             ;[c425] 79
    and     $03                             ;[c426] e6 03
    or      a                               ;[c428] b7
    jr      z,$c430                         ;[c429] 28 05
    rlc     b                               ;[c42b] cb 00
    dec     a                               ;[c42d] 3d
    jr      nz,$c42b                        ;[c42e] 20 fb
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
    ;[c45c] 6f 1b
    push    af                              ;[c45e] f5
    push    bc                              ;[c45f] c5
    push    de                              ;[c460] d5
    push    hl                              ;[c461] e5
    push    ix                              ;[c462] dd e5
    push    iy                              ;[c464] fd e5
    call    $c69a                           ;[c466] cd 9a c6
    ld      a,($ffd8)                       ;[c469] 3a d8 ff
    or      a                               ;[c46c] b7
    jp      nz,$c9e3                        ;[c46d] c2 e3 c9
    ld      a,($ffcc)                       ;[c470] 3a cc ff
    cp      $ff                             ;[c473] fe ff
    jp      z,$c6a3                         ;[c475] ca a3 c6
    or      a                               ;[c478] b7
    jp      nz,$c4be                        ;[c479] c2 be c4
    ld      a,c                             ;[c47c] 79
    cp      $1b                             ;[c47d] fe 1b
    jr      z,$c4b6                         ;[c47f] 28 35
    cp      $20                             ;[c481] fe 20
    jp      nc,$c4be                        ;[c483] d2 be c4
    cp      $0d                             ;[c486] fe 0d
    jp      z,$c524                         ;[c488] ca 24 c5
    cp      $0a                             ;[c48b] fe 0a
    jp      z,$c532                         ;[c48d] ca 32 c5
    cp      $0b                             ;[c490] fe 0b
    jp      z,$c558                         ;[c492] ca 58 c5
    cp      $0c                             ;[c495] fe 0c
    jp      z,$c56f                         ;[c497] ca 6f c5
    cp      $08                             ;[c49a] fe 08
    jp      z,$c59b                         ;[c49c] ca 9b c5
    cp      $1e                             ;[c49f] fe 1e
    jp      z,$c5db                         ;[c4a1] ca db c5
    cp      $1a                             ;[c4a4] fe 1a
    jp      z,$c5ee                         ;[c4a6] ca ee c5
    cp      $07                             ;[c4a9] fe 07
    call    z,$c5f4                         ;[c4ab] cc f4 c5
    cp      $00                             ;[c4ae] fe 00
    jp      z,$c6a3                         ;[c4b0] ca a3 c6
    jp      $c4be                           ;[c4b3] c3 be c4
    ld      a,$01                           ;[c4b6] 3e 01
    ld      ($ffd8),a                       ;[c4b8] 32 d8 ff
    jp      $c6a3                           ;[c4bb] c3 a3 c6
    push    iy                              ;[c4be] fd e5
    pop     hl                              ;[c4c0] e1
    call    $c715                           ;[c4c1] cd 15 c7
    ld      (hl),c                          ;[c4c4] 71
    call    $c795                           ;[c4c5] cd 95 c7
    ld      a,($ffd1)                       ;[c4c8] 3a d1 ff
    ld      b,a                             ;[c4cb] 47
    ld      a,($ffd2)                       ;[c4cc] 3a d2 ff
    and     (hl)                            ;[c4cf] a6
    or      b                               ;[c4d0] b0
    ld      (hl),a                          ;[c4d1] 77
    call    $c79e                           ;[c4d2] cd 9e c7
    call    $c5f8                           ;[c4d5] cd f8 c5
    jr      c,$c4e0                         ;[c4d8] 38 06
    call    $c613                           ;[c4da] cd 13 c6
    jp      $c6a3                           ;[c4dd] c3 a3 c6
    ld      a,($ffcb)                       ;[c4e0] 3a cb ff
    ld      b,a                             ;[c4e3] 47
    ld      a,($ffcd)                       ;[c4e4] 3a cd ff
    cp      b                               ;[c4e7] b8
    jr      z,$c501                         ;[c4e8] 28 17
    inc     b                               ;[c4ea] 04
    ld      a,b                             ;[c4eb] 78
    ld      ($ffcb),a                       ;[c4ec] 32 cb ff
    ld      a,($ffc9)                       ;[c4ef] 3a c9 ff
    or      a                               ;[c4f2] b7
    jr      nz,$c4fb                        ;[c4f3] 20 06
    call    $c613                           ;[c4f5] cd 13 c6
    jp      $c6a3                           ;[c4f8] c3 a3 c6
    call    $c620                           ;[c4fb] cd 20 c6
    jp      $c6a3                           ;[c4fe] c3 a3 c6
    ld      a,($ffc9)                       ;[c501] 3a c9 ff
    or      a                               ;[c504] b7
    jr      nz,$c510                        ;[c505] 20 09
    call    $c613                           ;[c507] cd 13 c6
    call    $c62e                           ;[c50a] cd 2e c6
    jp      $c6a3                           ;[c50d] c3 a3 c6
    ld      a,($ffcd)                       ;[c510] 3a cd ff
    ld      b,a                             ;[c513] 47
    ld      a,($ffd0)                       ;[c514] 3a d0 ff
    ld      c,a                             ;[c517] 4f
    call    $c6f1                           ;[c518] cd f1 c6
    call    $c71c                           ;[c51b] cd 1c c7
    call    $c62e                           ;[c51e] cd 2e c6
    jp      $c6a3                           ;[c521] c3 a3 c6
    ld      a,($ffd0)                       ;[c524] 3a d0 ff
    ld      ($ffca),a                       ;[c527] 32 ca ff
    ld      c,a                             ;[c52a] 4f
    ld      a,($ffcb)                       ;[c52b] 3a cb ff
    ld      b,a                             ;[c52e] 47
    jp      $c5e5                           ;[c52f] c3 e5 c5
    ld      a,($ffcb)                       ;[c532] 3a cb ff
    ld      b,a                             ;[c535] 47
    ld      a,($ffcd)                       ;[c536] 3a cd ff
    cp      b                               ;[c539] b8
    jr      z,$c54b                         ;[c53a] 28 0f
    inc     b                               ;[c53c] 04
    ld      a,b                             ;[c53d] 78
    ld      ($ffcb),a                       ;[c53e] 32 cb ff
    push    iy                              ;[c541] fd e5
    pop     hl                              ;[c543] e1
    ld      de,$0050                        ;[c544] 11 50 00
    add     hl,de                           ;[c547] 19
    jp      $c5e8                           ;[c548] c3 e8 c5
    call    $c62e                           ;[c54b] cd 2e c6
    ld      a,($ffcb)                       ;[c54e] 3a cb ff
    ld      b,a                             ;[c551] 47
    ld      a,($ffca)                       ;[c552] 3a ca ff
    ld      c,a                             ;[c555] 4f
    jr      $c541                           ;[c556] 18 e9
    ld      a,($ffcb)                       ;[c558] 3a cb ff
    ld      b,a                             ;[c55b] 47
    ld      a,($ffce)                       ;[c55c] 3a ce ff
    cp      b                               ;[c55f] b8
    jp      z,$c6a3                         ;[c560] ca a3 c6
    dec     b                               ;[c563] 05
    ld      a,b                             ;[c564] 78
    ld      ($ffcb),a                       ;[c565] 32 cb ff
    ld      a,($ffca)                       ;[c568] 3a ca ff
    ld      c,a                             ;[c56b] 4f
    jp      $c5e5                           ;[c56c] c3 e5 c5
    call    $c5f8                           ;[c56f] cd f8 c5
    ld      a,($ffcb)                       ;[c572] 3a cb ff
    ld      b,a                             ;[c575] 47
    jr      c,$c57b                         ;[c576] 38 03
    jp      $c5e5                           ;[c578] c3 e5 c5
    ld      a,($ffd0)                       ;[c57b] 3a d0 ff
    ld      ($ffca),a                       ;[c57e] 32 ca ff
    ld      c,a                             ;[c581] 4f
    ld      a,($ffcb)                       ;[c582] 3a cb ff
    ld      b,a                             ;[c585] 47
    ld      a,($ffcd)                       ;[c586] 3a cd ff
    cp      b                               ;[c589] b8
    jr      z,$c594                         ;[c58a] 28 08
    inc     b                               ;[c58c] 04
    ld      a,b                             ;[c58d] 78
    ld      ($ffcb),a                       ;[c58e] 32 cb ff
    jp      $c5e5                           ;[c591] c3 e5 c5
    push    bc                              ;[c594] c5
    call    $c62e                           ;[c595] cd 2e c6
    pop     bc                              ;[c598] c1
    jr      $c5e5                           ;[c599] 18 4a
    ld      a,($ffca)                       ;[c59b] 3a ca ff
    ld      c,a                             ;[c59e] 4f
    ld      a,($ffd0)                       ;[c59f] 3a d0 ff
    cp      c                               ;[c5a2] b9
    jr      z,$c5b8                         ;[c5a3] 28 13
    dec     c                               ;[c5a5] 0d
    ld      a,($ffd1)                       ;[c5a6] 3a d1 ff
    bit     3,a                             ;[c5a9] cb 5f
    jr      z,$c5ae                         ;[c5ab] 28 01
    dec     c                               ;[c5ad] 0d
    ld      a,c                             ;[c5ae] 79
    ld      ($ffca),a                       ;[c5af] 32 ca ff
    ld      a,($ffcb)                       ;[c5b2] 3a cb ff
    ld      b,a                             ;[c5b5] 47
    jr      $c5e5                           ;[c5b6] 18 2d
    ld      a,($ffcf)                       ;[c5b8] 3a cf ff
    ld      b,a                             ;[c5bb] 47
    ld      a,($ffd1)                       ;[c5bc] 3a d1 ff
    bit     3,a                             ;[c5bf] cb 5f
    jr      z,$c5c4                         ;[c5c1] 28 01
    dec     b                               ;[c5c3] 05
    ld      a,b                             ;[c5c4] 78
    ld      ($ffca),a                       ;[c5c5] 32 ca ff
    ld      c,a                             ;[c5c8] 4f
    ld      a,($ffcb)                       ;[c5c9] 3a cb ff
    ld      b,a                             ;[c5cc] 47
    ld      a,($ffce)                       ;[c5cd] 3a ce ff
    cp      b                               ;[c5d0] b8
    jp      z,$c6a3                         ;[c5d1] ca a3 c6
    dec     b                               ;[c5d4] 05
    ld      a,b                             ;[c5d5] 78
    ld      ($ffcb),a                       ;[c5d6] 32 cb ff
    jr      $c5e5                           ;[c5d9] 18 0a
    xor     a                               ;[c5db] af
    ld      ($ffcb),a                       ;[c5dc] 32 cb ff
    ld      ($ffca),a                       ;[c5df] 32 ca ff
    ld      bc,$0000                        ;[c5e2] 01 00 00
    call    $c6f1                           ;[c5e5] cd f1 c6
    call    $c71c                           ;[c5e8] cd 1c c7
    jp      $c6a3                           ;[c5eb] c3 a3 c6
    call    $c764                           ;[c5ee] cd 64 c7
    jp      $c6a3                           ;[c5f1] c3 a3 c6
    xor     a                               ;[c5f4] af
    out     ($da),a                         ;[c5f5] d3 da
    ret                                     ;[c5f7] c9

    ld      a,($ffca)                       ;[c5f8] 3a ca ff
    ld      c,a                             ;[c5fb] 4f
    inc     c                               ;[c5fc] 0c
    ld      a,($ffd1)                       ;[c5fd] 3a d1 ff
    bit     3,a                             ;[c600] cb 5f
    jr      z,$c605                         ;[c602] 28 01
    inc     c                               ;[c604] 0c
    ld      a,($ffcf)                       ;[c605] 3a cf ff
    cp      c                               ;[c608] b9
    ld      a,c                             ;[c609] 79
    jr      nc,$c60f                        ;[c60a] 30 03
    ld      a,($ffd0)                       ;[c60c] 3a d0 ff
    ld      ($ffca),a                       ;[c60f] 32 ca ff
    ret                                     ;[c612] c9

    inc     hl                              ;[c613] 23
    ld      a,($ffd1)                       ;[c614] 3a d1 ff
    bit     3,a                             ;[c617] cb 5f
    jr      z,$c61c                         ;[c619] 28 01
    inc     hl                              ;[c61b] 23
    call    $c71c                           ;[c61c] cd 1c c7
    ret                                     ;[c61f] c9

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
    jr      nz,$c647                        ;[c632] 20 13
    push    ix                              ;[c634] dd e5
    pop     hl                              ;[c636] e1
    ld      de,$0050                        ;[c637] 11 50 00
    add     hl,de                           ;[c63a] 19
    call    $c742                           ;[c63b] cd 42 c7
    ld      b,$17                           ;[c63e] 06 17
    call    $c7fa                           ;[c640] cd fa c7
    call    $c670                           ;[c643] cd 70 c6
    ret                                     ;[c646] c9

    ld      a,($ffd0)                       ;[c647] 3a d0 ff
    ld      c,a                             ;[c64a] 4f
    ld      a,($ffce)                       ;[c64b] 3a ce ff
    ld      b,a                             ;[c64e] 47
    ld      a,($ffce)                       ;[c64f] 3a ce ff
    ld      d,a                             ;[c652] 57
    ld      a,($ffcd)                       ;[c653] 3a cd ff
    sub     d                               ;[c656] 92
    jr      z,$c664                         ;[c657] 28 0b
    ld      d,a                             ;[c659] 57
    inc     b                               ;[c65a] 04
    call    $c6f1                           ;[c65b] cd f1 c6
    call    $c7a7                           ;[c65e] cd a7 c7
    dec     d                               ;[c661] 15
    jr      nz,$c65a                        ;[c662] 20 f6
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
    ld      (hl),e                          ;[c690] 73
    inc     hl                              ;[c691] 23
    bit     3,h                             ;[c692] cb 5c
    call    z,$c715                         ;[c694] cc 15 c7
    djnz    $c690                           ;[c697] 10 f7
    ret                                     ;[c699] c9

    ld      ix,($ffd4)                      ;[c69a] dd 2a d4 ff
    ld      iy,($ffd6)                      ;[c69e] fd 2a d6 ff
    ret                                     ;[c6a2] c9

    call    $c6e8                           ;[c6a3] cd e8 c6
    pop     iy                              ;[c6a6] fd e1
    pop     ix                              ;[c6a8] dd e1
    pop     hl                              ;[c6aa] e1
    pop     de                              ;[c6ab] d1
    pop     bc                              ;[c6ac] c1
    pop     af                              ;[c6ad] f1
    ret                                     ;[c6ae] c9

    ld      hl,$ffc9                        ;[c6af] 21 c9 ff
    xor     a                               ;[c6b2] af
    ld      (hl),a                          ;[c6b3] 77
    inc     hl                              ;[c6b4] 23
    ld      (hl),a                          ;[c6b5] 77
    inc     hl                              ;[c6b6] 23
    ld      (hl),a                          ;[c6b7] 77
    inc     hl                              ;[c6b8] 23
    ld      (hl),a                          ;[c6b9] 77
    inc     hl                              ;[c6ba] 23
    ld      (hl),$17                        ;[c6bb] 36 17
    inc     hl                              ;[c6bd] 23
    ld      (hl),a                          ;[c6be] 77
    inc     hl                              ;[c6bf] 23
    ld      (hl),$4f                        ;[c6c0] 36 4f
    inc     hl                              ;[c6c2] 23
    ld      (hl),a                          ;[c6c3] 77
    inc     hl                              ;[c6c4] 23
    ld      (hl),a                          ;[c6c5] 77
    inc     hl                              ;[c6c6] 23
    ld      (hl),$80                        ;[c6c7] 36 80
    inc     hl                              ;[c6c9] 23
    ld      a,($c86f)                       ;[c6ca] 3a 6f c8
    ld      d,a                             ;[c6cd] 57
    in      a,($d6)                         ;[c6ce] db d6
    bit     5,a                             ;[c6d0] cb 6f
    jr      z,$c6d6                         ;[c6d2] 28 02
    ld      d,$03                           ;[c6d4] 16 03
    bit     6,a                             ;[c6d6] cb 77
    jr      z,$c6de                         ;[c6d8] 28 04
    set     5,d                             ;[c6da] cb ea
    set     6,d                             ;[c6dc] cb f2
    ld      (hl),d                          ;[c6de] 72
    xor     a                               ;[c6df] af
    inc     hl                              ;[c6e0] 23
    ld      b,$15                           ;[c6e1] 06 15
    ld      (hl),a                          ;[c6e3] 77
    inc     hl                              ;[c6e4] 23
    djnz    $c6e3                           ;[c6e5] 10 fc
    ret                                     ;[c6e7] c9

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
    rra                                     ;[c6fd] 1f
    jr      nc,$c701                        ;[c6fe] 30 01
    add     hl,de                           ;[c700] 19
    or      a                               ;[c701] b7
    rl      e                               ;[c702] cb 13
    rl      d                               ;[c704] cb 12
    dec     b                               ;[c706] 05
    jr      nz,$c6fd                        ;[c707] 20 f4
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

    ld      a,h                             ;[c715] 7c
    and     $07                             ;[c716] e6 07
    or      $d0                             ;[c718] f6 d0
    ld      h,a                             ;[c71a] 67
    ret                                     ;[c71b] c9

    ld      a,h                             ;[c71c] 7c
    and     $07                             ;[c71d] e6 07
    ld      h,a                             ;[c71f] 67
    push    ix                              ;[c720] dd e5
    pop     de                              ;[c722] d1
    ex      de,hl                           ;[c723] eb
    or      a                               ;[c724] b7
    sbc     hl,de                           ;[c725] ed 52
    jr      c,$c730                         ;[c727] 38 07
    jr      z,$c730                         ;[c729] 28 05
    ld      hl,$0800                        ;[c72b] 21 00 08
    add     hl,de                           ;[c72e] 19
    ex      de,hl                           ;[c72f] eb
    ld      a,$0e                           ;[c730] 3e 0e
    out     ($a0),a                         ;[c732] d3 a0
    ld      a,d                             ;[c734] 7a
    out     ($a1),a                         ;[c735] d3 a1
    ld      a,$0f                           ;[c737] 3e 0f
    out     ($a0),a                         ;[c739] d3 a0
    ld      a,e                             ;[c73b] 7b
    out     ($a1),a                         ;[c73c] d3 a1
    push    de                              ;[c73e] d5
    pop     iy                              ;[c73f] fd e1
    ret                                     ;[c741] c9

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
    in      a,($82)                         ;[c75d] db 82
    bit     1,a                             ;[c75f] cb 4f
    jr      z,$c75d                         ;[c761] 28 fa
    ret                                     ;[c763] c9

    ld      bc,$0780                        ;[c764] 01 80 07
    push    ix                              ;[c767] dd e5
    pop     hl                              ;[c769] e1
    ld      de,$2000                        ;[c76a] 11 00 20
    call    $c715                           ;[c76d] cd 15 c7
    ld      (hl),d                          ;[c770] 72
    in      a,($81)                         ;[c771] db 81
    set     7,a                             ;[c773] cb ff
    out     ($81),a                         ;[c775] d3 81
    ld      (hl),e                          ;[c777] 73
    res     7,a                             ;[c778] cb bf
    out     ($81),a                         ;[c77a] d3 81
    inc     hl                              ;[c77c] 23
    bit     3,h                             ;[c77d] cb 5c
    call    z,$c715                         ;[c77f] cc 15 c7
    dec     bc                              ;[c782] 0b
    ld      a,b                             ;[c783] 78
    or      c                               ;[c784] b1
    jr      nz,$c770                        ;[c785] 20 e9
    push    ix                              ;[c787] dd e5
    pop     hl                              ;[c789] e1
    call    $c71c                           ;[c78a] cd 1c c7
    xor     a                               ;[c78d] af
    ld      ($ffca),a                       ;[c78e] 32 ca ff
    ld      ($ffcb),a                       ;[c791] 32 cb ff
    ret                                     ;[c794] c9

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
    djnz    $c7d8                           ;[c7e7] 10 ef
    dec     c                               ;[c7e9] 0d
    jr      z,$c7f6                         ;[c7ea] 28 0a
    ld      a,c                             ;[c7ec] 79
    pop     hl                              ;[c7ed] e1
    pop     de                              ;[c7ee] d1
    pop     bc                              ;[c7ef] c1
    ld      c,a                             ;[c7f0] 4f
    call    $c795                           ;[c7f1] cd 95 c7
    jr      $c7d8                           ;[c7f4] 18 e2
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
    call    $c6f1                           ;[c80d] cd f1 c6
    call    $c715                           ;[c810] cd 15 c7
    ld      (hl),$20                        ;[c813] 36 20
    call    $c795                           ;[c815] cd 95 c7
    ld      (hl),$00                        ;[c818] 36 00
    call    $c79e                           ;[c81a] cd 9e c7
    inc     hl                              ;[c81d] 23
    dec     e                               ;[c81e] 1d
    jr      nz,$c810                        ;[c81f] 20 ef
    inc     b                               ;[c821] 04
    ld      a,($ffd0)                       ;[c822] 3a d0 ff
    ld      c,a                             ;[c825] 4f
    ld      a,($ffcf)                       ;[c826] 3a cf ff
    sub     c                               ;[c829] 91
    inc     a                               ;[c82a] 3c
    ld      e,a                             ;[c82b] 5f
    dec     d                               ;[c82c] 15
    jr      nz,$c80d                        ;[c82d] 20 de
    ret                                     ;[c82f] c9

    ld      a,($ffcd)                       ;[c830] 3a cd ff
    ld      b,a                             ;[c833] 47
    ld      a,($ffce)                       ;[c834] 3a ce ff
    cp      b                               ;[c837] b8
    jr      z,$c845                         ;[c838] 28 0b
    ld      d,a                             ;[c83a] 57
    ld      a,b                             ;[c83b] 78
    sub     d                               ;[c83c] 92
    ld      d,a                             ;[c83d] 57
    dec     b                               ;[c83e] 05
    call    $c7fa                           ;[c83f] cd fa c7
    dec     d                               ;[c842] 15
    jr      nz,$c83e                        ;[c843] 20 f9
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

    ld      h,e                             ;[c865] 63
    ld      d,b                             ;[c866] 50
    ld      d,h                             ;[c867] 54
    xor     d                               ;[c868] aa
    add     hl,de                           ;[c869] 19
    ld      b,$19                           ;[c86a] 06 19
    add     hl,de                           ;[c86c] 19
    nop                                     ;[c86d] 00
    dec     c                               ;[c86e] 0d
    dec     c                               ;[c86f] 0d
    dec     c                               ;[c870] 0d
    nop                                     ;[c871] 00
    nop                                     ;[c872] 00
    nop                                     ;[c873] 00
    nop                                     ;[c874] 00
    ld      a,($ffd1)                       ;[c875] 3a d1 ff
    set     3,a                             ;[c878] cb df
    ld      ($ffd1),a                       ;[c87a] 32 d1 ff
    ld      a,($ffca)                       ;[c87d] 3a ca ff
    ld      c,a                             ;[c880] 4f
    rra                                     ;[c881] 1f
    jr      nc,$c88b                        ;[c882] 30 07
    inc     iy                              ;[c884] fd 23
    inc     c                               ;[c886] 0c
    ld      a,c                             ;[c887] 79
    ld      ($ffca),a                       ;[c888] 32 ca ff
    xor     a                               ;[c88b] af
    ret                                     ;[c88c] c9

    ld      hl,$c865                        ;[c88d] 21 65 c8
    ld      b,$10                           ;[c890] 06 10
    ld      c,$a1                           ;[c892] 0e a1
    xor     a                               ;[c894] af
    out     ($a0),a                         ;[c895] d3 a0
    inc     a                               ;[c897] 3c
    outi                                    ;[c898] ed a3
    jr      nz,$c895                        ;[c89a] 20 f9
    ld      ix,$0000                        ;[c89c] dd 21 00 00
    call    $c764                           ;[c8a0] cd 64 c7
    call    $c8b6                           ;[c8a3] cd b6 c8
    ld      hl,$0000                        ;[c8a6] 21 00 00
    call    $c71c                           ;[c8a9] cd 1c c7
    ld      a,($ffd1)                       ;[c8ac] 3a d1 ff
    res     3,a                             ;[c8af] cb 9f
    ld      ($ffd1),a                       ;[c8b1] 32 d1 ff
    xor     a                               ;[c8b4] af
    ret                                     ;[c8b5] c9

    ld      a,$06                           ;[c8b6] 3e 06
    out     ($a0),a                         ;[c8b8] d3 a0
    ld      a,$18                           ;[c8ba] 3e 18
    out     ($a1),a                         ;[c8bc] d3 a1
    ret                                     ;[c8be] c9

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
    out     ($a0),a                         ;[c8d7] d3 a0
    inc     a                               ;[c8d9] 3c
    outi                                    ;[c8da] ed a3
    jr      nz,$c8d7                        ;[c8dc] 20 f9
    ret                                     ;[c8de] c9

    ld      a,($ffd9)                       ;[c8df] 3a d9 ff
    or      a                               ;[c8e2] b7
    jr      nz,$c8ea                        ;[c8e3] 20 05
    inc     a                               ;[c8e5] 3c
    ld      ($ffd9),a                       ;[c8e6] 32 d9 ff
    ret                                     ;[c8e9] c9

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
    call    $c715                           ;[c932] cd 15 c7
    ld      a,(hl)                          ;[c935] 7e
    or      b                               ;[c936] b0
    ld      (hl),a                          ;[c937] 77
    inc     hl                              ;[c938] 23
    dec     de                              ;[c939] 1b
    ld      a,d                             ;[c93a] 7a
    or      e                               ;[c93b] b3
    jr      nz,$c932                        ;[c93c] 20 f4
    call    $c79e                           ;[c93e] cd 9e c7
    ret                                     ;[c941] c9

    ld      a,c                             ;[c942] 79
    cp      $44                             ;[c943] fe 44
    jr      nz,$c94b                        ;[c945] 20 04
    ld      c,$40                           ;[c947] 0e 40
    jr      $c984                           ;[c949] 18 39
    cp      $45                             ;[c94b] fe 45
    jr      nz,$c953                        ;[c94d] 20 04
    ld      c,$60                           ;[c94f] 0e 60
    jr      $c984                           ;[c951] 18 31
    cp      $46                             ;[c953] fe 46
    jr      nz,$c95b                        ;[c955] 20 04
    ld      c,$20                           ;[c957] 0e 20
    jr      $c984                           ;[c959] 18 29
    ld      a,($c86f)                       ;[c95b] 3a 6f c8
    ld      d,a                             ;[c95e] 57
    in      a,($d6)                         ;[c95f] db d6
    bit     5,a                             ;[c961] cb 6f
    jr      z,$c967                         ;[c963] 28 02
    ld      d,$03                           ;[c965] 16 03
    bit     6,a                             ;[c967] cb 77
    jr      z,$c96f                         ;[c969] 28 04
    set     5,d                             ;[c96b] cb ea
    set     6,d                             ;[c96d] cb f2
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

    call    $ca01                           ;[c9e3] cd 01 ca
    cp      $01                             ;[c9e6] fe 01
    jr      nz,$c9eb                        ;[c9e8] 20 01
    ld      a,c                             ;[c9ea] 79
    ld      ($ffd8),a                       ;[c9eb] 32 d8 ff
    cp      $60                             ;[c9ee] fe 60
    jp      nc,$ca70                        ;[c9f0] d2 70 ca
    sub     $31                             ;[c9f3] d6 31
    jp      c,$ca70                         ;[c9f5] da 70 ca
    call    $ca05                           ;[c9f8] cd 05 ca
    or      a                               ;[c9fb] b7
    jr      z,$ca70                         ;[c9fc] 28 72
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
    xor     a                               ;[ca70] af
    ld      ($ffd8),a                       ;[ca71] 32 d8 ff
    ld      ($ffd9),a                       ;[ca74] 32 d9 ff
    jp      $c6a3                           ;[ca77] c3 a3 c6
    xor     a                               ;[ca7a] af
    ret                                     ;[ca7b] c9

    call    $cdd7                           ;[ca7c] cd d7 cd
    cp      $01                             ;[ca7f] fe 01
    jr      nz,$ca8c                        ;[ca81] 20 09
    ld      a,c                             ;[ca83] 79
    cp      $31                             ;[ca84] fe 31
    jr      c,$cab0                         ;[ca86] 38 28
    cp      $36                             ;[ca88] fe 36
    jr      nc,$cab0                        ;[ca8a] 30 24
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
    call    $cd51                           ;[cab0] cd 51 cd
    xor     a                               ;[cab3] af
    ret                                     ;[cab4] c9

    call    $c901                           ;[cab5] cd 01 c9
    ld      (hl),c                          ;[cab8] 71
    cp      $0a                             ;[cab9] fe 0a
    ret     nz                              ;[cabb] c0
    ld      hl,$ffdb                        ;[cabc] 21 db ff
    ld      b,$08                           ;[cabf] 06 08
    ld      a,(hl)                          ;[cac1] 7e
    inc     hl                              ;[cac2] 23
    cp      $7f                             ;[cac3] fe 7f
    jr      z,$cacd                         ;[cac5] 28 06
    djnz    $cac1                           ;[cac7] 10 f8
    ld      (hl),$7f                        ;[cac9] 36 7f
    jr      $cad2                           ;[cacb] 18 05
    ld      hl,$ffe3                        ;[cacd] 21 e3 ff
    ld      (hl),$20                        ;[cad0] 36 20
    xor     a                               ;[cad2] af
    ret                                     ;[cad3] c9

    call    $cdd7                           ;[cad4] cd d7 cd
    cp      $04                             ;[cad7] fe 04
    jr      z,$cadf                         ;[cad9] 28 04
    call    $c901                           ;[cadb] cd 01 c9
    ret                                     ;[cade] c9

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
    jr      z,$cafd                         ;[caf7] 28 04
    call    $c901                           ;[caf9] cd 01 c9
    ret                                     ;[cafc] c9

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
    jr      z,$cb27                         ;[cb21] 28 04
    call    $c901                           ;[cb23] cd 01 c9
    ret                                     ;[cb26] c9

    ld      a,c                             ;[cb27] 79
    sub     $20                             ;[cb28] d6 20
    ld      e,a                             ;[cb2a] 5f
    ld      a,$4f                           ;[cb2b] 3e 4f
    cp      e                               ;[cb2d] bb
    jr      c,$cb68                         ;[cb2e] 38 38
    ld      hl,$ffda                        ;[cb30] 21 da ff
    ld      b,(hl)                          ;[cb33] 46
    inc     hl                              ;[cb34] 23
    ld      a,(hl)                          ;[cb35] 7e
    cp      $18                             ;[cb36] fe 18
    jr      nc,$cb68                        ;[cb38] 30 2e
    ld      c,a                             ;[cb3a] 4f
    inc     hl                              ;[cb3b] 23
    ld      d,(hl)                          ;[cb3c] 56
    ld      a,c                             ;[cb3d] 79
    cp      b                               ;[cb3e] b8
    jr      c,$cb68                         ;[cb3f] 38 27
    ld      a,e                             ;[cb41] 7b
    cp      d                               ;[cb42] ba
    jr      c,$cb68                         ;[cb43] 38 23
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
    jr      z,$cb62                         ;[cb5f] 28 01
    add     a                               ;[cb61] 87
    ld      ($ffc8),a                       ;[cb62] 32 c8 ff
    call    $cc1b                           ;[cb65] cd 1b cc
    xor     a                               ;[cb68] af
    ret                                     ;[cb69] c9

    call    $cdd7                           ;[cb6a] cd d7 cd
    cp      $02                             ;[cb6d] fe 02
    jr      z,$cb75                         ;[cb6f] 28 04
    call    $c901                           ;[cb71] cd 01 c9
    ret                                     ;[cb74] c9

    ld      a,c                             ;[cb75] 79
    sub     $20                             ;[cb76] d6 20
    ld      c,a                             ;[cb78] 4f
    ld      a,$4f                           ;[cb79] 3e 4f
    cp      c                               ;[cb7b] b9
    jr      c,$cb9d                         ;[cb7c] 38 1f
    ld      a,($ffd1)                       ;[cb7e] 3a d1 ff
    bit     3,a                             ;[cb81] cb 5f
    jr      z,$cb88                         ;[cb83] 28 03
    ld      a,c                             ;[cb85] 79
    add     a                               ;[cb86] 87
    ld      c,a                             ;[cb87] 4f
    ld      a,($ffda)                       ;[cb88] 3a da ff
    cp      $19                             ;[cb8b] fe 19
    jr      nc,$cb9d                        ;[cb8d] 30 0e
    ld      b,a                             ;[cb8f] 47
    ld      ($ffcb),a                       ;[cb90] 32 cb ff
    ld      a,c                             ;[cb93] 79
    ld      ($ffca),a                       ;[cb94] 32 ca ff
    call    $c6f1                           ;[cb97] cd f1 c6
    call    $c71c                           ;[cb9a] cd 1c c7
    xor     a                               ;[cb9d] af
    ret                                     ;[cb9e] c9

    call    $cdd7                           ;[cb9f] cd d7 cd
    ld      a,c                             ;[cba2] 79
    sub     $20                             ;[cba3] d6 20
    ld      c,a                             ;[cba5] 4f
    ld      a,$4f                           ;[cba6] 3e 4f
    cp      c                               ;[cba8] b9
    jr      c,$cbb9                         ;[cba9] 38 0e
    ld      a,($ffcb)                       ;[cbab] 3a cb ff
    ld      b,a                             ;[cbae] 47
    ld      a,c                             ;[cbaf] 79
    ld      ($ffca),a                       ;[cbb0] 32 ca ff
    call    $c6f1                           ;[cbb3] cd f1 c6
    call    $c71c                           ;[cbb6] cd 1c c7
    xor     a                               ;[cbb9] af
    ret                                     ;[cbba] c9

    call    $cdd7                           ;[cbbb] cd d7 cd
    cp      $04                             ;[cbbe] fe 04
    jr      z,$cbc6                         ;[cbc0] 28 04
    call    $c901                           ;[cbc2] cd 01 c9
    ret                                     ;[cbc5] c9

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
    call    $c715                           ;[cbe9] cd 15 c7
    ld      a,(hl)                          ;[cbec] 7e
    and     d                               ;[cbed] a2
    jr      nz,$cbf9                        ;[cbee] 20 09
    ld      (hl),$00                        ;[cbf0] 36 00
    call    $c795                           ;[cbf2] cd 95 c7
    ld      (hl),e                          ;[cbf5] 73
    call    $c795                           ;[cbf6] cd 95 c7
    inc     hl                              ;[cbf9] 23
    dec     bc                              ;[cbfa] 0b
    ld      a,b                             ;[cbfb] 78
    or      c                               ;[cbfc] b1
    jr      nz,$cbe9                        ;[cbfd] 20 ea
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
    ld      c,$00                           ;[cc47] 0e 00
    push    bc                              ;[cc49] c5
    call    $cdf4                           ;[cc4a] cd f4 cd
    ld      c,d                             ;[cc4d] 4a
    push    de                              ;[cc4e] d5
    call    $ffa0                           ;[cc4f] cd a0 ff
    pop     de                              ;[cc52] d1
    pop     bc                              ;[cc53] c1
    bit     3,e                             ;[cc54] cb 5b
    jr      z,$cc65                         ;[cc56] 28 0d
    inc     c                               ;[cc58] 0c
    ld      a,c                             ;[cc59] 79
    cp      $50                             ;[cc5a] fe 50
    jr      z,$cc6b                         ;[cc5c] 28 0d
    push    bc                              ;[cc5e] c5
    ld      c,$20                           ;[cc5f] 0e 20
    call    $ffa0                           ;[cc61] cd a0 ff
    pop     bc                              ;[cc64] c1
    inc     c                               ;[cc65] 0c
    ld      a,c                             ;[cc66] 79
    cp      $50                             ;[cc67] fe 50
    jr      nz,$cc49                        ;[cc69] 20 de
    push    bc                              ;[cc6b] c5
    ld      c,$0d                           ;[cc6c] 0e 0d
    call    $ffa0                           ;[cc6e] cd a0 ff
    ld      c,$0a                           ;[cc71] 0e 0a
    call    $ffa0                           ;[cc73] cd a0 ff
    pop     bc                              ;[cc76] c1
    inc     b                               ;[cc77] 04
    ld      a,b                             ;[cc78] 78
    cp      $18                             ;[cc79] fe 18
    jr      nz,$cc47                        ;[cc7b] 20 ca
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
    jr      z,$ccab                         ;[cc9b] 28 0e
    cp      $31                             ;[cc9d] fe 31
    jr      z,$ccbd                         ;[cc9f] 28 1c
    cp      $32                             ;[cca1] fe 32
    jr      z,$ccdf                         ;[cca3] 28 3a
    cp      $33                             ;[cca5] fe 33
    jr      z,$ccf4                         ;[cca7] 28 4b
    xor     a                               ;[cca9] af
    ret                                     ;[ccaa] c9

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

    ld      a,($ffce)                       ;[ccf4] 3a ce ff
    ld      b,a                             ;[ccf7] 47
    ld      a,($ffcb)                       ;[ccf8] 3a cb ff
    ld      c,a                             ;[ccfb] 4f
    ld      a,($ffcd)                       ;[ccfc] 3a cd ff
    cp      c                               ;[ccff] b9
    jr      z,$cd18                         ;[cd00] 28 16
    ld      a,c                             ;[cd02] 79
    ld      ($ffce),a                       ;[cd03] 32 ce ff
    push    bc                              ;[cd06] c5
    call    $c830                           ;[cd07] cd 30 c8
    pop     bc                              ;[cd0a] c1
    ld      a,b                             ;[cd0b] 78
    ld      ($ffce),a                       ;[cd0c] 32 ce ff
    ld      a,($ffd0)                       ;[cd0f] 3a d0 ff
    ld      c,a                             ;[cd12] 4f
    call    $cb9f                           ;[cd13] cd 9f cb
    xor     a                               ;[cd16] af
    ret                                     ;[cd17] c9

    ld      b,a                             ;[cd18] 47
    ld      d,a                             ;[cd19] 57
    ld      a,($ffcf)                       ;[cd1a] 3a cf ff
    ld      e,a                             ;[cd1d] 5f
    ld      a,($ffd0)                       ;[cd1e] 3a d0 ff
    ld      c,a                             ;[cd21] 4f
    call    $c805                           ;[cd22] cd 05 c8
    jr      $cd0f                           ;[cd25] 18 e8
    call    $cdd7                           ;[cd27] cd d7 cd
    cp      $02                             ;[cd2a] fe 02
    jp      nc,$cd8a                        ;[cd2c] d2 8a cd
    ld      a,c                             ;[cd2f] 79
    cp      $30                             ;[cd30] fe 30
    jr      z,$cd42                         ;[cd32] 28 0e
    cp      $31                             ;[cd34] fe 31
    jr      z,$cd46                         ;[cd36] 28 0e
    cp      $34                             ;[cd38] fe 34
    jr      z,$cd51                         ;[cd3a] 28 15
    cp      $35                             ;[cd3c] fe 35
    jr      z,$cd8a                         ;[cd3e] 28 4a
    xor     a                               ;[cd40] af
    ret                                     ;[cd41] c9

    ld      b,$19                           ;[cd42] 06 19
    jr      $cd48                           ;[cd44] 18 02
    ld      b,$18                           ;[cd46] 06 18
    ld      a,$06                           ;[cd48] 3e 06
    out     ($a0),a                         ;[cd4a] d3 a0
    ld      a,b                             ;[cd4c] 78
    out     ($a1),a                         ;[cd4d] d3 a1
    xor     a                               ;[cd4f] af
    ret                                     ;[cd50] c9

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
    call    $c715                           ;[cd66] cd 15 c7
    ld      a,(de)                          ;[cd69] 1a
    ld      (hl),a                          ;[cd6a] 77
    call    $c795                           ;[cd6b] cd 95 c7
    ld      (hl),c                          ;[cd6e] 71
    call    $c79e                           ;[cd6f] cd 9e c7
    inc     de                              ;[cd72] 13
    inc     hl                              ;[cd73] 23
    djnz    $cd66                           ;[cd74] 10 f0
    ld      a,($ffda)                       ;[cd76] 3a da ff
    or      a                               ;[cd79] b7
    jr      z,$cd88                         ;[cd7a] 28 0c
    ld      b,$0a                           ;[cd7c] 06 0a
    ld      a,($bfeb)                       ;[cd7e] 3a eb bf
    ld      c,a                             ;[cd81] 4f
    xor     a                               ;[cd82] af
    ld      ($ffda),a                       ;[cd83] 32 da ff
    jr      $cd66                           ;[cd86] 18 de
    xor     a                               ;[cd88] af
    ret                                     ;[cd89] c9

    ld      a,c                             ;[cd8a] 79
    cp      $0d                             ;[cd8b] fe 0d
    jr      z,$cdb5                         ;[cd8d] 28 26
    ld      a,($ffd9)                       ;[cd8f] 3a d9 ff
    cp      $01                             ;[cd92] fe 01
    jr      z,$cd9a                         ;[cd94] 28 04
    call    $cdb7                           ;[cd96] cd b7 cd
    ret                                     ;[cd99] c9

    ld      b,$18                           ;[cd9a] 06 18
    ld      c,$00                           ;[cd9c] 0e 00
    call    $c6f1                           ;[cd9e] cd f1 c6
    ld      ($ffda),hl                      ;[cda1] 22 da ff
    ld      a,$02                           ;[cda4] 3e 02
    ld      ($ffd9),a                       ;[cda6] 32 d9 ff
    ld      b,$46                           ;[cda9] 06 46
    ld      c,$20                           ;[cdab] 0e 20
    call    $c715                           ;[cdad] cd 15 c7
    ld      (hl),c                          ;[cdb0] 71
    inc     hl                              ;[cdb1] 23
    djnz    $cdad                           ;[cdb2] 10 f9
    ret                                     ;[cdb4] c9

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
    ld      sp,$302e                        ;[cffc] 31 2e 30
    ld      sp,$30c3                        ;[cfff] 31 c3 30
    ret     nz                              ;[d002] c0
    jp      $c027                           ;[d003] c3 27 c0
    jp      $c027                           ;[d006] c3 27 c0
    jp      $c45e                           ;[d009] c3 5e c4
    jp      $c027                           ;[d00c] c3 27 c0
    jp      $c027                           ;[d00f] c3 27 c0
    jp      $c027                           ;[d012] c3 27 c0
    jp      $c027                           ;[d015] c3 27 c0
    jp      $c19d                           ;[d018] c3 9d c1
    jp      $c18f                           ;[d01b] c3 8f c1
    jp      $c174                           ;[d01e] c3 74 c1
    jp      $cde2                           ;[d021] c3 e2 cd
    jp      $cdf4                           ;[d024] c3 f4 cd
    di                                      ;[d027] f3
    ld      a,$10                           ;[d028] 3e 10
    out     ($b1),a                         ;[d02a] d3 b1
    out     ($b3),a                         ;[d02c] d3 b3
    jr      $d040                           ;[d02e] 18 10
    ld      a,$89                           ;[d030] 3e 89
    out     ($83),a                         ;[d032] d3 83
    di                                      ;[d034] f3
    ld      a,$10                           ;[d035] 3e 10
    out     ($81),a                         ;[d037] d3 81
    ld      h,$7d                           ;[d039] 26 7d
    dec     hl                              ;[d03b] 2b
    ld      a,h                             ;[d03c] 7c
    or      l                               ;[d03d] b5
    jr      nz,$d03b                        ;[d03e] 20 fb
    ld      sp,$0080                        ;[d040] 31 80 00
    call    $c0c2                           ;[d043] cd c2 c0
    call    $c6af                           ;[d046] cd af c6
    call    $c14e                           ;[d049] cd 4e c1
    ld      a,$12                           ;[d04c] 3e 12
    out     ($b2),a                         ;[d04e] d3 b2
    in      a,($b3)                         ;[d050] db b3
    bit     0,a                             ;[d052] cb 47
    jr      z,$d050                         ;[d054] 28 fa
    in      a,($b2)                         ;[d056] db b2
    out     ($da),a                         ;[d058] d3 da
    ld      c,$56                           ;[d05a] 0e 56
    call    $c45e                           ;[d05c] cd 5e c4
    ld      hl,$cffc                        ;[d05f] 21 fc cf
    ld      b,$04                           ;[d062] 06 04
    ld      c,(hl)                          ;[d064] 4e
    inc     hl                              ;[d065] 23
    call    $c45e                           ;[d066] cd 5e c4
    djnz    $d064                           ;[d069] 10 f9
    call    $c0a7                           ;[d06b] cd a7 c0
    ld      a,b                             ;[d06e] 78
    cp      $4d                             ;[d06f] fe 4d
    jr      z,$d088                         ;[d071] 28 15
    cp      $5c                             ;[d073] fe 5c
    jr      nz,$d06b                        ;[d075] 20 f4
    ld      a,($8000)                       ;[d077] 3a 00 80
    cpl                                     ;[d07a] 2f
    ld      ($8000),a                       ;[d07b] 32 00 80
    ld      a,($8000)                       ;[d07e] 3a 00 80
    cp      $c3                             ;[d081] fe c3
    jr      nz,$d027                        ;[d083] 20 a2
    jp      $8000                           ;[d085] c3 00 80
    ld      de,$0000                        ;[d088] 11 00 00
    ld      bc,$4000                        ;[d08b] 01 00 40
    ld      hl,$0080                        ;[d08e] 21 80 00
    ld      a,$01                           ;[d091] 3e 01
    call    $c19d                           ;[d093] cd 9d c1
    cp      $ff                             ;[d096] fe ff
    jr      nz,$d09e                        ;[d098] 20 04
    out     ($da),a                         ;[d09a] d3 da
    jr      $d088                           ;[d09c] 18 ea
    ld      a,$06                           ;[d09e] 3e 06
    out     ($b2),a                         ;[d0a0] d3 b2
    out     ($da),a                         ;[d0a2] d3 da
    jp      $0080                           ;[d0a4] c3 80 00
    in      a,($b3)                         ;[d0a7] db b3
    bit     0,a                             ;[d0a9] cb 47
    jr      z,$d0a7                         ;[d0ab] 28 fa
    in      a,($b2)                         ;[d0ad] db b2
    ld      b,a                             ;[d0af] 47
    bit     7,a                             ;[d0b0] cb 7f
    jr      nz,$d0a7                        ;[d0b2] 20 f3
    in      a,($b3)                         ;[d0b4] db b3
    bit     0,a                             ;[d0b6] cb 47
    jr      z,$d0b4                         ;[d0b8] 28 fa
    in      a,($b2)                         ;[d0ba] db b2
    ld      c,a                             ;[d0bc] 4f
    bit     7,a                             ;[d0bd] cb 7f
    jr      z,$d0b4                         ;[d0bf] 28 f3
    ret                                     ;[d0c1] c9

    im      2                               ;[d0c2] ed 5e
    call    $c0d1                           ;[d0c4] cd d1 c0
    call    $c43f                           ;[d0c7] cd 3f c4
    call    $c108                           ;[d0ca] cd 08 c1
    call    $c88d                           ;[d0cd] cd 8d c8
    ret                                     ;[d0d0] c9

    ld      hl,$c0f1                        ;[d0d1] 21 f1 c0
    ld      a,(hl)                          ;[d0d4] 7e
    inc     hl                              ;[d0d5] 23
    cp      $ff                             ;[d0d6] fe ff
    jr      z,$d0e1                         ;[d0d8] 28 07
    ld      c,a                             ;[d0da] 4f
    ld      a,(hl)                          ;[d0db] 7e
    inc     hl                              ;[d0dc] 23
    out     (c),a                           ;[d0dd] ed 79
    jr      $d0d4                           ;[d0df] 18 f3
    in      a,($d6)                         ;[d0e1] db d6
    and     $07                             ;[d0e3] e6 07
    ld      d,$00                           ;[d0e5] 16 00
    ld      e,a                             ;[d0e7] 5f
    add     hl,de                           ;[d0e8] 19
    ld      a,(hl)                          ;[d0e9] 7e
    out     ($e1),a                         ;[d0ea] d3 e1
    ld      a,$41                           ;[d0ec] 3e 41
    out     ($e1),a                         ;[d0ee] d3 e1
    ret                                     ;[d0f0] c9

    jp      po,$e205                        ;[d0f1] e2 05 e2
    djnz    $d0d8                           ;[d0f4] 10 e2
    ld      b,c                             ;[d0f6] 41
    ex      (sp),hl                         ;[d0f7] e3
    dec     b                               ;[d0f8] 05
    ex      (sp),hl                         ;[d0f9] e3
    ld      bc,$41e3                        ;[d0fa] 01 e3 41
    pop     hl                              ;[d0fd] e1
    dec     b                               ;[d0fe] 05
    rst     $38                             ;[d0ff] ff
    xor     (hl)                            ;[d100] ae
    ld      b,b                             ;[d101] 40
    jr      nz,$d114                        ;[d102] 20 10
    ex      af,af'                          ;[d104] 08
    inc     b                               ;[d105] 04
    ld      (bc),a                          ;[d106] 02
    ld      bc,$3421                        ;[d107] 01 21 34
    pop     bc                              ;[d10a] c1
    ld      a,(hl)                          ;[d10b] 7e
    inc     hl                              ;[d10c] 23
    cp      $ff                             ;[d10d] fe ff
    jr      z,$d119                         ;[d10f] 28 08
    out     ($b1),a                         ;[d111] d3 b1
    ld      a,(hl)                          ;[d113] 7e
    out     ($b1),a                         ;[d114] d3 b1
    inc     hl                              ;[d116] 23
    jr      $d10b                           ;[d117] 18 f2
    ld      a,(hl)                          ;[d119] 7e
    cp      $ff                             ;[d11a] fe ff
    jr      z,$d127                         ;[d11c] 28 09
    out     ($b3),a                         ;[d11e] d3 b3
    inc     hl                              ;[d120] 23
    ld      a,(hl)                          ;[d121] 7e
    out     ($b3),a                         ;[d122] d3 b3
    inc     hl                              ;[d124] 23
    jr      $d119                           ;[d125] 18 f2
    in      a,($b0)                         ;[d127] db b0
    in      a,($b2)                         ;[d129] db b2
    in      a,($b0)                         ;[d12b] db b0
    in      a,($b2)                         ;[d12d] db b2
    in      a,($b0)                         ;[d12f] db b0
    in      a,($b2)                         ;[d131] db b2
    ret                                     ;[d133] c9

    nop                                     ;[d134] 00
    djnz    $d137                           ;[d135] 10 00
    djnz    $d13d                           ;[d137] 10 04
    ld      b,h                             ;[d139] 44
    ld      bc,$0300                        ;[d13a] 01 00 03
    pop     bc                              ;[d13d] c1
    dec     b                               ;[d13e] 05
    jp      pe,$00ff                        ;[d13f] ea ff 00
    djnz    $d144                           ;[d142] 10 00
    djnz    $d14a                           ;[d144] 10 04
    ld      b,h                             ;[d146] 44
    ld      bc,$0300                        ;[d147] 01 00 03
    pop     bc                              ;[d14a] c1
    dec     b                               ;[d14b] 05
    jp      pe,$21ff                        ;[d14c] ea ff 21
    ld      h,l                             ;[d14f] 65
    pop     bc                              ;[d150] c1
    ld      de,$0010                        ;[d151] 11 10 00
    ld      bc,$000f                        ;[d154] 01 0f 00
    ldir                                    ;[d157] ed b0
    ld      hl,$0000                        ;[d159] 21 00 00
    ld      de,$0000                        ;[d15c] 11 00 00
    ld      bc,$0000                        ;[d15f] 01 00 00
    jp      $0010                           ;[d162] c3 10 00
    in      a,($81)                         ;[d165] db 81
    set     0,a                             ;[d167] cb c7
    out     ($81),a                         ;[d169] d3 81
    ldir                                    ;[d16b] ed b0
    res     0,a                             ;[d16d] cb 87
    out     ($81),a                         ;[d16f] d3 81
    out     ($de),a                         ;[d171] d3 de
    ret                                     ;[d173] c9

    push    af                              ;[d174] f5
    rrca                                    ;[d175] 0f
    rrca                                    ;[d176] 0f
    rrca                                    ;[d177] 0f
    rrca                                    ;[d178] 0f
    and     $0f                             ;[d179] e6 0f
    call    $c181                           ;[d17b] cd 81 c1
    pop     af                              ;[d17e] f1
    and     $0f                             ;[d17f] e6 0f
    call    $c187                           ;[d181] cd 87 c1
    jp      $c45e                           ;[d184] c3 5e c4
    add     $90                             ;[d187] c6 90
    daa                                     ;[d189] 27
    adc     $40                             ;[d18a] ce 40
    daa                                     ;[d18c] 27
    ld      c,a                             ;[d18d] 4f
    ret                                     ;[d18e] c9

    ex      (sp),hl                         ;[d18f] e3
    ld      a,(hl)                          ;[d190] 7e
    inc     hl                              ;[d191] 23
    or      a                               ;[d192] b7
    jr      z,$d19b                         ;[d193] 28 06
    ld      c,a                             ;[d195] 4f
    call    $c45e                           ;[d196] cd 5e c4
    jr      $d190                           ;[d199] 18 f5
    ex      (sp),hl                         ;[d19b] e3
    ret                                     ;[d19c] c9

    push    bc                              ;[d19d] c5
    push    de                              ;[d19e] d5
    push    hl                              ;[d19f] e5
    ld      ($ffb8),a                       ;[d1a0] 32 b8 ff
    ld      a,$0a                           ;[d1a3] 3e 0a
    ld      ($ffbf),a                       ;[d1a5] 32 bf ff
    ld      ($ffb9),bc                      ;[d1a8] ed 43 b9 ff
    ld      ($ffbb),de                      ;[d1ac] ed 53 bb ff
    ld      ($ffbd),hl                      ;[d1b0] 22 bd ff
    call    $c423                           ;[d1b3] cd 23 c4
    ld      a,($ffba)                       ;[d1b6] 3a ba ff
    and     $f0                             ;[d1b9] e6 f0
    jp      z,$c1e6                         ;[d1bb] ca e6 c1
    cp      $40                             ;[d1be] fe 40
    jp      z,$c1dc                         ;[d1c0] ca dc c1
    cp      $80                             ;[d1c3] fe 80
    jp      z,$c1d7                         ;[d1c5] ca d7 c1
    cp      $20                             ;[d1c8] fe 20
    jp      z,$c1e1                         ;[d1ca] ca e1 c1
    cp      $f0                             ;[d1cd] fe f0
    jp      z,$c1eb                         ;[d1cf] ca eb c1
    ld      a,$ff                           ;[d1d2] 3e ff
    jp      $c1f0                           ;[d1d4] c3 f0 c1
    call    $c1f4                           ;[d1d7] cd f4 c1
    jr      $d1f0                           ;[d1da] 18 14
    call    $c24a                           ;[d1dc] cd 4a c2
    jr      $d1f0                           ;[d1df] 18 0f
    call    $c3a9                           ;[d1e1] cd a9 c3
    jr      $d1f0                           ;[d1e4] 18 0a
    call    $c391                           ;[d1e6] cd 91 c3
    jr      $d1f0                           ;[d1e9] 18 05
    call    $c2e3                           ;[d1eb] cd e3 c2
    jr      $d1f0                           ;[d1ee] 18 00
    pop     hl                              ;[d1f0] e1
    pop     de                              ;[d1f1] d1
    pop     bc                              ;[d1f2] c1
    ret                                     ;[d1f3] c9

    call    $c3a9                           ;[d1f4] cd a9 c3
    call    $c2b7                           ;[d1f7] cd b7 c2
    push    de                              ;[d1fa] d5
    call    $c41c                           ;[d1fb] cd 1c c4
    ld      c,$c5                           ;[d1fe] 0e c5
    ld      a,($ffb8)                       ;[d200] 3a b8 ff
    or      a                               ;[d203] b7
    jr      nz,$d208                        ;[d204] 20 02
    res     6,c                             ;[d206] cb b1
    call    $c415                           ;[d208] cd 15 c4
    di                                      ;[d20b] f3
    call    $c34e                           ;[d20c] cd 4e c3
    pop     de                              ;[d20f] d1
    ld      c,$c1                           ;[d210] 0e c1
    ld      b,e                             ;[d212] 43
    ld      hl,($ffbd)                      ;[d213] 2a bd ff
    in      a,($82)                         ;[d216] db 82
    bit     2,a                             ;[d218] cb 57
    jr      z,$d216                         ;[d21a] 28 fa
    in      a,($c0)                         ;[d21c] db c0
    bit     5,a                             ;[d21e] cb 6f
    jr      z,$d229                         ;[d220] 28 07
    outi                                    ;[d222] ed a3
    jr      nz,$d216                        ;[d224] 20 f0
    dec     d                               ;[d226] 15
    jr      nz,$d216                        ;[d227] 20 ed
    out     ($dc),a                         ;[d229] d3 dc
    ei                                      ;[d22b] fb
    call    $c3f4                           ;[d22c] cd f4 c3
    ld      a,($ffc0)                       ;[d22f] 3a c0 ff
    and     $c0                             ;[d232] e6 c0
    cp      $40                             ;[d234] fe 40
    jr      nz,$d248                        ;[d236] 20 10
    call    $c2a0                           ;[d238] cd a0 c2
    ld      a,($ffbf)                       ;[d23b] 3a bf ff
    dec     a                               ;[d23e] 3d
    ld      ($ffbf),a                       ;[d23f] 32 bf ff
    jp      nz,$c1f7                        ;[d242] c2 f7 c1
    ld      a,$ff                           ;[d245] 3e ff
    ret                                     ;[d247] c9

    xor     a                               ;[d248] af
    ret                                     ;[d249] c9

    call    $c3a9                           ;[d24a] cd a9 c3
    call    $c2b7                           ;[d24d] cd b7 c2
    push    de                              ;[d250] d5
    call    $c41c                           ;[d251] cd 1c c4
    ld      c,$c6                           ;[d254] 0e c6
    ld      a,($ffb8)                       ;[d256] 3a b8 ff
    or      a                               ;[d259] b7
    jr      nz,$d25e                        ;[d25a] 20 02
    res     6,c                             ;[d25c] cb b1
    call    $c415                           ;[d25e] cd 15 c4
    di                                      ;[d261] f3
    call    $c34e                           ;[d262] cd 4e c3
    pop     de                              ;[d265] d1
    ld      c,$c1                           ;[d266] 0e c1
    ld      b,e                             ;[d268] 43
    ld      hl,($ffbd)                      ;[d269] 2a bd ff
    in      a,($82)                         ;[d26c] db 82
    bit     2,a                             ;[d26e] cb 57
    jr      z,$d26c                         ;[d270] 28 fa
    in      a,($c0)                         ;[d272] db c0
    bit     5,a                             ;[d274] cb 6f
    jr      z,$d27f                         ;[d276] 28 07
    ini                                     ;[d278] ed a2
    jr      nz,$d26c                        ;[d27a] 20 f0
    dec     d                               ;[d27c] 15
    jr      nz,$d26c                        ;[d27d] 20 ed
    out     ($dc),a                         ;[d27f] d3 dc
    ei                                      ;[d281] fb
    call    $c3f4                           ;[d282] cd f4 c3
    ld      a,($ffc0)                       ;[d285] 3a c0 ff
    and     $c0                             ;[d288] e6 c0
    cp      $40                             ;[d28a] fe 40
    jr      nz,$d29e                        ;[d28c] 20 10
    call    $c2a0                           ;[d28e] cd a0 c2
    ld      a,($ffbf)                       ;[d291] 3a bf ff
    dec     a                               ;[d294] 3d
    ld      ($ffbf),a                       ;[d295] 32 bf ff
    jp      nz,$c24d                        ;[d298] c2 4d c2
    ld      a,$ff                           ;[d29b] 3e ff
    ret                                     ;[d29d] c9

    xor     a                               ;[d29e] af
    ret                                     ;[d29f] c9

    ld      a,($ffc2)                       ;[d2a0] 3a c2 ff
    bit     4,a                             ;[d2a3] cb 67
    jr      z,$d2ab                         ;[d2a5] 28 04
    call    $c391                           ;[d2a7] cd 91 c3
    ret                                     ;[d2aa] c9

    ld      a,($ffc1)                       ;[d2ab] 3a c1 ff
    bit     0,a                             ;[d2ae] cb 47
    jr      z,$d2b6                         ;[d2b0] 28 04
    call    $c391                           ;[d2b2] cd 91 c3
    ret                                     ;[d2b5] c9

    ret                                     ;[d2b6] c9

    ld      e,$00                           ;[d2b7] 1e 00
    ld      a,($ffb8)                       ;[d2b9] 3a b8 ff
    cp      $03                             ;[d2bc] fe 03
    jr      nz,$d2d4                        ;[d2be] 20 14
    ld      d,$04                           ;[d2c0] 16 04
    ld      a,($ffbb)                       ;[d2c2] 3a bb ff
    bit     7,a                             ;[d2c5] cb 7f
    jr      z,$d2e2                         ;[d2c7] 28 19
    ld      a,($ffba)                       ;[d2c9] 3a ba ff
    and     $0f                             ;[d2cc] e6 0f
    rlca                                    ;[d2ce] 07
    rlca                                    ;[d2cf] 07
    add     d                               ;[d2d0] 82
    ld      d,a                             ;[d2d1] 57
    jr      $d2e2                           ;[d2d2] 18 0e
    or      a                               ;[d2d4] b7
    jr      nz,$d2d9                        ;[d2d5] 20 02
    ld      e,$80                           ;[d2d7] 1e 80
    ld      a,($ffba)                       ;[d2d9] 3a ba ff
    and     $0f                             ;[d2dc] e6 0f
    ld      d,$01                           ;[d2de] 16 01
    add     d                               ;[d2e0] 82
    ld      d,a                             ;[d2e1] 57
    ret                                     ;[d2e2] c9

    call    $c3a9                           ;[d2e3] cd a9 c3
    cp      $ff                             ;[d2e6] fe ff
    ret     z                               ;[d2e8] c8
    ld      b,$14                           ;[d2e9] 06 14
    ld      a,($ffb8)                       ;[d2eb] 3a b8 ff
    cp      $03                             ;[d2ee] fe 03
    jr      z,$d2f4                         ;[d2f0] 28 02
    ld      b,$40                           ;[d2f2] 06 40
    push    bc                              ;[d2f4] c5
    call    $c41c                           ;[d2f5] cd 1c c4
    ld      c,$4d                           ;[d2f8] 0e 4d
    call    $c415                           ;[d2fa] cd 15 c4
    ld      bc,($ffb9)                      ;[d2fd] ed 4b b9 ff
    call    $c415                           ;[d301] cd 15 c4
    ld      a,($ffb8)                       ;[d304] 3a b8 ff
    ld      c,a                             ;[d307] 4f
    call    $c415                           ;[d308] cd 15 c4
    ld      c,$05                           ;[d30b] 0e 05
    ld      a,($ffb8)                       ;[d30d] 3a b8 ff
    cp      $03                             ;[d310] fe 03
    jr      z,$d316                         ;[d312] 28 02
    ld      c,$10                           ;[d314] 0e 10
    call    $c415                           ;[d316] cd 15 c4
    ld      c,$28                           ;[d319] 0e 28
    call    $c415                           ;[d31b] cd 15 c4
    di                                      ;[d31e] f3
    ld      c,$e5                           ;[d31f] 0e e5
    call    $c415                           ;[d321] cd 15 c4
    pop     bc                              ;[d324] c1
    ld      c,$c1                           ;[d325] 0e c1
    ld      hl,($ffbd)                      ;[d327] 2a bd ff
    in      a,($82)                         ;[d32a] db 82
    bit     2,a                             ;[d32c] cb 57
    jr      z,$d32a                         ;[d32e] 28 fa
    in      a,($c0)                         ;[d330] db c0
    bit     5,a                             ;[d332] cb 6f
    jr      z,$d33a                         ;[d334] 28 04
    outi                                    ;[d336] ed a3
    jr      nz,$d32a                        ;[d338] 20 f0
    out     ($dc),a                         ;[d33a] d3 dc
    ei                                      ;[d33c] fb
    call    $c3f4                           ;[d33d] cd f4 c3
    ld      a,($ffc0)                       ;[d340] 3a c0 ff
    and     $c0                             ;[d343] e6 c0
    cp      $40                             ;[d345] fe 40
    jr      nz,$d34c                        ;[d347] 20 03
    ld      a,$ff                           ;[d349] 3e ff
    ret                                     ;[d34b] c9

    xor     a                               ;[d34c] af
    ret                                     ;[d34d] c9

    ld      bc,($ffb9)                      ;[d34e] ed 4b b9 ff
    call    $c415                           ;[d352] cd 15 c4
    ld      de,($ffbb)                      ;[d355] ed 5b bb ff
    ld      c,d                             ;[d359] 4a
    call    $c415                           ;[d35a] cd 15 c4
    ld      bc,($ffb9)                      ;[d35d] ed 4b b9 ff
    ld      a,c                             ;[d361] 79
    and     $04                             ;[d362] e6 04
    rrca                                    ;[d364] 0f
    rrca                                    ;[d365] 0f
    ld      c,a                             ;[d366] 4f
    call    $c415                           ;[d367] cd 15 c4
    res     7,e                             ;[d36a] cb bb
    ld      c,e                             ;[d36c] 4b
    inc     c                               ;[d36d] 0c
    call    $c415                           ;[d36e] cd 15 c4
    ld      a,($ffb8)                       ;[d371] 3a b8 ff
    ld      c,a                             ;[d374] 4f
    call    $c415                           ;[d375] cd 15 c4
    ld      c,$05                           ;[d378] 0e 05
    ld      a,($ffb8)                       ;[d37a] 3a b8 ff
    cp      $03                             ;[d37d] fe 03
    jr      z,$d383                         ;[d37f] 28 02
    ld      c,$10                           ;[d381] 0e 10
    call    $c415                           ;[d383] cd 15 c4
    ld      c,$28                           ;[d386] 0e 28
    call    $c415                           ;[d388] cd 15 c4
    ld      c,$ff                           ;[d38b] 0e ff
    call    $c415                           ;[d38d] cd 15 c4
    ret                                     ;[d390] c9

    call    $c41c                           ;[d391] cd 1c c4
    ld      c,$07                           ;[d394] 0e 07
    call    $c415                           ;[d396] cd 15 c4
    ld      bc,($ffb9)                      ;[d399] ed 4b b9 ff
    res     2,c                             ;[d39d] cb 91
    call    $c415                           ;[d39f] cd 15 c4
    call    $c3d2                           ;[d3a2] cd d2 c3
    jr      z,$d391                         ;[d3a5] 28 ea
    xor     a                               ;[d3a7] af
    ret                                     ;[d3a8] c9

    ld      de,($ffbb)                      ;[d3a9] ed 5b bb ff
    ld      a,d                             ;[d3ad] 7a
    or      a                               ;[d3ae] b7
    jp      z,$c391                         ;[d3af] ca 91 c3
    call    $c41c                           ;[d3b2] cd 1c c4
    ld      c,$0f                           ;[d3b5] 0e 0f
    call    $c415                           ;[d3b7] cd 15 c4
    ld      bc,($ffb9)                      ;[d3ba] ed 4b b9 ff
    call    $c415                           ;[d3be] cd 15 c4
    ld      c,d                             ;[d3c1] 4a
    call    $c415                           ;[d3c2] cd 15 c4
    call    $c3d2                           ;[d3c5] cd d2 c3
    jr      nz,$d3d0                        ;[d3c8] 20 06
    call    $c391                           ;[d3ca] cd 91 c3
    jp      $c3a9                           ;[d3cd] c3 a9 c3
    xor     a                               ;[d3d0] af
    ret                                     ;[d3d1] c9

    in      a,($82)                         ;[d3d2] db 82
    bit     2,a                             ;[d3d4] cb 57
    jp      z,$c3d2                         ;[d3d6] ca d2 c3
    call    $c41c                           ;[d3d9] cd 1c c4
    call    $c403                           ;[d3dc] cd 03 c4
    ld      a,$08                           ;[d3df] 3e 08
    out     ($c1),a                         ;[d3e1] d3 c1
    call    $c40c                           ;[d3e3] cd 0c c4
    in      a,($c1)                         ;[d3e6] db c1
    ld      b,a                             ;[d3e8] 47
    call    $c40c                           ;[d3e9] cd 0c c4
    in      a,($c1)                         ;[d3ec] db c1
    ld      a,b                             ;[d3ee] 78
    and     $c0                             ;[d3ef] e6 c0
    cp      $40                             ;[d3f1] fe 40
    ret                                     ;[d3f3] c9

    ld      hl,$ffc0                        ;[d3f4] 21 c0 ff
    ld      b,$07                           ;[d3f7] 06 07
    ld      c,$c1                           ;[d3f9] 0e c1
    call    $c40c                           ;[d3fb] cd 0c c4
    ini                                     ;[d3fe] ed a2
    jr      nz,$d3fb                        ;[d400] 20 f9
    ret                                     ;[d402] c9

    in      a,($c0)                         ;[d403] db c0
    rlca                                    ;[d405] 07
    jr      nc,$d403                        ;[d406] 30 fb
    rlca                                    ;[d408] 07
    jr      c,$d403                         ;[d409] 38 f8
    ret                                     ;[d40b] c9

    in      a,($c0)                         ;[d40c] db c0
    rlca                                    ;[d40e] 07
    jr      nc,$d40c                        ;[d40f] 30 fb
    rlca                                    ;[d411] 07
    jr      nc,$d40c                        ;[d412] 30 f8
    ret                                     ;[d414] c9

    call    $c403                           ;[d415] cd 03 c4
    ld      a,c                             ;[d418] 79
    out     ($c1),a                         ;[d419] d3 c1
    ret                                     ;[d41b] c9

    in      a,($c0)                         ;[d41c] db c0
    bit     4,a                             ;[d41e] cb 67
    jr      nz,$d41c                        ;[d420] 20 fa
    ret                                     ;[d422] c9

    ld      b,$01                           ;[d423] 06 01
    ld      a,c                             ;[d425] 79
    and     $03                             ;[d426] e6 03
    or      a                               ;[d428] b7
    jr      z,$d430                         ;[d429] 28 05
    rlc     b                               ;[d42b] cb 00
    dec     a                               ;[d42d] 3d
    jr      nz,$d42b                        ;[d42e] 20 fb
    ld      a,($ffc7)                       ;[d430] 3a c7 ff
    ld      c,a                             ;[d433] 4f
    and     b                               ;[d434] a0
    ret     nz                              ;[d435] c0
    ld      a,c                             ;[d436] 79
    or      b                               ;[d437] b0
    ld      ($ffc7),a                       ;[d438] 32 c7 ff
    call    $c391                           ;[d43b] cd 91 c3
    ret                                     ;[d43e] c9

    push    bc                              ;[d43f] c5
    push    hl                              ;[d440] e5
    ld      hl,$c45c                        ;[d441] 21 5c c4
    call    $c41c                           ;[d444] cd 1c c4
    ld      c,$03                           ;[d447] 0e 03
    call    $c415                           ;[d449] cd 15 c4
    ld      c,(hl)                          ;[d44c] 4e
    inc     hl                              ;[d44d] 23
    call    $c415                           ;[d44e] cd 15 c4
    ld      c,(hl)                          ;[d451] 4e
    call    $c415                           ;[d452] cd 15 c4
    xor     a                               ;[d455] af
    ld      ($ffc7),a                       ;[d456] 32 c7 ff
    pop     hl                              ;[d459] e1
    pop     bc                              ;[d45a] c1
    ret                                     ;[d45b] c9

    ld      l,a                             ;[d45c] 6f
    dec     de                              ;[d45d] 1b
    push    af                              ;[d45e] f5
    push    bc                              ;[d45f] c5
    push    de                              ;[d460] d5
    push    hl                              ;[d461] e5
    push    ix                              ;[d462] dd e5
    push    iy                              ;[d464] fd e5
    call    $c69a                           ;[d466] cd 9a c6
    ld      a,($ffd8)                       ;[d469] 3a d8 ff
    or      a                               ;[d46c] b7
    jp      nz,$c9e3                        ;[d46d] c2 e3 c9
    ld      a,($ffcc)                       ;[d470] 3a cc ff
    cp      $ff                             ;[d473] fe ff
    jp      z,$c6a3                         ;[d475] ca a3 c6
    or      a                               ;[d478] b7
    jp      nz,$c4be                        ;[d479] c2 be c4
    ld      a,c                             ;[d47c] 79
    cp      $1b                             ;[d47d] fe 1b
    jr      z,$d4b6                         ;[d47f] 28 35
    cp      $20                             ;[d481] fe 20
    jp      nc,$c4be                        ;[d483] d2 be c4
    cp      $0d                             ;[d486] fe 0d
    jp      z,$c524                         ;[d488] ca 24 c5
    cp      $0a                             ;[d48b] fe 0a
    jp      z,$c532                         ;[d48d] ca 32 c5
    cp      $0b                             ;[d490] fe 0b
    jp      z,$c558                         ;[d492] ca 58 c5
    cp      $0c                             ;[d495] fe 0c
    jp      z,$c56f                         ;[d497] ca 6f c5
    cp      $08                             ;[d49a] fe 08
    jp      z,$c59b                         ;[d49c] ca 9b c5
    cp      $1e                             ;[d49f] fe 1e
    jp      z,$c5db                         ;[d4a1] ca db c5
    cp      $1a                             ;[d4a4] fe 1a
    jp      z,$c5ee                         ;[d4a6] ca ee c5
    cp      $07                             ;[d4a9] fe 07
    call    z,$c5f4                         ;[d4ab] cc f4 c5
    cp      $00                             ;[d4ae] fe 00
    jp      z,$c6a3                         ;[d4b0] ca a3 c6
    jp      $c4be                           ;[d4b3] c3 be c4
    ld      a,$01                           ;[d4b6] 3e 01
    ld      ($ffd8),a                       ;[d4b8] 32 d8 ff
    jp      $c6a3                           ;[d4bb] c3 a3 c6
    push    iy                              ;[d4be] fd e5
    pop     hl                              ;[d4c0] e1
    call    $c715                           ;[d4c1] cd 15 c7
    ld      (hl),c                          ;[d4c4] 71
    call    $c795                           ;[d4c5] cd 95 c7
    ld      a,($ffd1)                       ;[d4c8] 3a d1 ff
    ld      b,a                             ;[d4cb] 47
    ld      a,($ffd2)                       ;[d4cc] 3a d2 ff
    and     (hl)                            ;[d4cf] a6
    or      b                               ;[d4d0] b0
    ld      (hl),a                          ;[d4d1] 77
    call    $c79e                           ;[d4d2] cd 9e c7
    call    $c5f8                           ;[d4d5] cd f8 c5
    jr      c,$d4e0                         ;[d4d8] 38 06
    call    $c613                           ;[d4da] cd 13 c6
    jp      $c6a3                           ;[d4dd] c3 a3 c6
    ld      a,($ffcb)                       ;[d4e0] 3a cb ff
    ld      b,a                             ;[d4e3] 47
    ld      a,($ffcd)                       ;[d4e4] 3a cd ff
    cp      b                               ;[d4e7] b8
    jr      z,$d501                         ;[d4e8] 28 17
    inc     b                               ;[d4ea] 04
    ld      a,b                             ;[d4eb] 78
    ld      ($ffcb),a                       ;[d4ec] 32 cb ff
    ld      a,($ffc9)                       ;[d4ef] 3a c9 ff
    or      a                               ;[d4f2] b7
    jr      nz,$d4fb                        ;[d4f3] 20 06
    call    $c613                           ;[d4f5] cd 13 c6
    jp      $c6a3                           ;[d4f8] c3 a3 c6
    call    $c620                           ;[d4fb] cd 20 c6
    jp      $c6a3                           ;[d4fe] c3 a3 c6
    ld      a,($ffc9)                       ;[d501] 3a c9 ff
    or      a                               ;[d504] b7
    jr      nz,$d510                        ;[d505] 20 09
    call    $c613                           ;[d507] cd 13 c6
    call    $c62e                           ;[d50a] cd 2e c6
    jp      $c6a3                           ;[d50d] c3 a3 c6
    ld      a,($ffcd)                       ;[d510] 3a cd ff
    ld      b,a                             ;[d513] 47
    ld      a,($ffd0)                       ;[d514] 3a d0 ff
    ld      c,a                             ;[d517] 4f
    call    $c6f1                           ;[d518] cd f1 c6
    call    $c71c                           ;[d51b] cd 1c c7
    call    $c62e                           ;[d51e] cd 2e c6
    jp      $c6a3                           ;[d521] c3 a3 c6
    ld      a,($ffd0)                       ;[d524] 3a d0 ff
    ld      ($ffca),a                       ;[d527] 32 ca ff
    ld      c,a                             ;[d52a] 4f
    ld      a,($ffcb)                       ;[d52b] 3a cb ff
    ld      b,a                             ;[d52e] 47
    jp      $c5e5                           ;[d52f] c3 e5 c5
    ld      a,($ffcb)                       ;[d532] 3a cb ff
    ld      b,a                             ;[d535] 47
    ld      a,($ffcd)                       ;[d536] 3a cd ff
    cp      b                               ;[d539] b8
    jr      z,$d54b                         ;[d53a] 28 0f
    inc     b                               ;[d53c] 04
    ld      a,b                             ;[d53d] 78
    ld      ($ffcb),a                       ;[d53e] 32 cb ff
    push    iy                              ;[d541] fd e5
    pop     hl                              ;[d543] e1
    ld      de,$0050                        ;[d544] 11 50 00
    add     hl,de                           ;[d547] 19
    jp      $c5e8                           ;[d548] c3 e8 c5
    call    $c62e                           ;[d54b] cd 2e c6
    ld      a,($ffcb)                       ;[d54e] 3a cb ff
    ld      b,a                             ;[d551] 47
    ld      a,($ffca)                       ;[d552] 3a ca ff
    ld      c,a                             ;[d555] 4f
    jr      $d541                           ;[d556] 18 e9
    ld      a,($ffcb)                       ;[d558] 3a cb ff
    ld      b,a                             ;[d55b] 47
    ld      a,($ffce)                       ;[d55c] 3a ce ff
    cp      b                               ;[d55f] b8
    jp      z,$c6a3                         ;[d560] ca a3 c6
    dec     b                               ;[d563] 05
    ld      a,b                             ;[d564] 78
    ld      ($ffcb),a                       ;[d565] 32 cb ff
    ld      a,($ffca)                       ;[d568] 3a ca ff
    ld      c,a                             ;[d56b] 4f
    jp      $c5e5                           ;[d56c] c3 e5 c5
    call    $c5f8                           ;[d56f] cd f8 c5
    ld      a,($ffcb)                       ;[d572] 3a cb ff
    ld      b,a                             ;[d575] 47
    jr      c,$d57b                         ;[d576] 38 03
    jp      $c5e5                           ;[d578] c3 e5 c5
    ld      a,($ffd0)                       ;[d57b] 3a d0 ff
    ld      ($ffca),a                       ;[d57e] 32 ca ff
    ld      c,a                             ;[d581] 4f
    ld      a,($ffcb)                       ;[d582] 3a cb ff
    ld      b,a                             ;[d585] 47
    ld      a,($ffcd)                       ;[d586] 3a cd ff
    cp      b                               ;[d589] b8
    jr      z,$d594                         ;[d58a] 28 08
    inc     b                               ;[d58c] 04
    ld      a,b                             ;[d58d] 78
    ld      ($ffcb),a                       ;[d58e] 32 cb ff
    jp      $c5e5                           ;[d591] c3 e5 c5
    push    bc                              ;[d594] c5
    call    $c62e                           ;[d595] cd 2e c6
    pop     bc                              ;[d598] c1
    jr      $d5e5                           ;[d599] 18 4a
    ld      a,($ffca)                       ;[d59b] 3a ca ff
    ld      c,a                             ;[d59e] 4f
    ld      a,($ffd0)                       ;[d59f] 3a d0 ff
    cp      c                               ;[d5a2] b9
    jr      z,$d5b8                         ;[d5a3] 28 13
    dec     c                               ;[d5a5] 0d
    ld      a,($ffd1)                       ;[d5a6] 3a d1 ff
    bit     3,a                             ;[d5a9] cb 5f
    jr      z,$d5ae                         ;[d5ab] 28 01
    dec     c                               ;[d5ad] 0d
    ld      a,c                             ;[d5ae] 79
    ld      ($ffca),a                       ;[d5af] 32 ca ff
    ld      a,($ffcb)                       ;[d5b2] 3a cb ff
    ld      b,a                             ;[d5b5] 47
    jr      $d5e5                           ;[d5b6] 18 2d
    ld      a,($ffcf)                       ;[d5b8] 3a cf ff
    ld      b,a                             ;[d5bb] 47
    ld      a,($ffd1)                       ;[d5bc] 3a d1 ff
    bit     3,a                             ;[d5bf] cb 5f
    jr      z,$d5c4                         ;[d5c1] 28 01
    dec     b                               ;[d5c3] 05
    ld      a,b                             ;[d5c4] 78
    ld      ($ffca),a                       ;[d5c5] 32 ca ff
    ld      c,a                             ;[d5c8] 4f
    ld      a,($ffcb)                       ;[d5c9] 3a cb ff
    ld      b,a                             ;[d5cc] 47
    ld      a,($ffce)                       ;[d5cd] 3a ce ff
    cp      b                               ;[d5d0] b8
    jp      z,$c6a3                         ;[d5d1] ca a3 c6
    dec     b                               ;[d5d4] 05
    ld      a,b                             ;[d5d5] 78
    ld      ($ffcb),a                       ;[d5d6] 32 cb ff
    jr      $d5e5                           ;[d5d9] 18 0a
    xor     a                               ;[d5db] af
    ld      ($ffcb),a                       ;[d5dc] 32 cb ff
    ld      ($ffca),a                       ;[d5df] 32 ca ff
    ld      bc,$0000                        ;[d5e2] 01 00 00
    call    $c6f1                           ;[d5e5] cd f1 c6
    call    $c71c                           ;[d5e8] cd 1c c7
    jp      $c6a3                           ;[d5eb] c3 a3 c6
    call    $c764                           ;[d5ee] cd 64 c7
    jp      $c6a3                           ;[d5f1] c3 a3 c6
    xor     a                               ;[d5f4] af
    out     ($da),a                         ;[d5f5] d3 da
    ret                                     ;[d5f7] c9

    ld      a,($ffca)                       ;[d5f8] 3a ca ff
    ld      c,a                             ;[d5fb] 4f
    inc     c                               ;[d5fc] 0c
    ld      a,($ffd1)                       ;[d5fd] 3a d1 ff
    bit     3,a                             ;[d600] cb 5f
    jr      z,$d605                         ;[d602] 28 01
    inc     c                               ;[d604] 0c
    ld      a,($ffcf)                       ;[d605] 3a cf ff
    cp      c                               ;[d608] b9
    ld      a,c                             ;[d609] 79
    jr      nc,$d60f                        ;[d60a] 30 03
    ld      a,($ffd0)                       ;[d60c] 3a d0 ff
    ld      ($ffca),a                       ;[d60f] 32 ca ff
    ret                                     ;[d612] c9

    inc     hl                              ;[d613] 23
    ld      a,($ffd1)                       ;[d614] 3a d1 ff
    bit     3,a                             ;[d617] cb 5f
    jr      z,$d61c                         ;[d619] 28 01
    inc     hl                              ;[d61b] 23
    call    $c71c                           ;[d61c] cd 1c c7
    ret                                     ;[d61f] c9

    ld      a,($ffc8)                       ;[d620] 3a c8 ff
    ld      e,a                             ;[d623] 5f
    ld      d,$00                           ;[d624] 16 00
    push    iy                              ;[d626] fd e5
    pop     hl                              ;[d628] e1
    add     hl,de                           ;[d629] 19
    call    $c71c                           ;[d62a] cd 1c c7
    ret                                     ;[d62d] c9

    ld      a,($ffc9)                       ;[d62e] 3a c9 ff
    or      a                               ;[d631] b7
    jr      nz,$d647                        ;[d632] 20 13
    push    ix                              ;[d634] dd e5
    pop     hl                              ;[d636] e1
    ld      de,$0050                        ;[d637] 11 50 00
    add     hl,de                           ;[d63a] 19
    call    $c742                           ;[d63b] cd 42 c7
    ld      b,$17                           ;[d63e] 06 17
    call    $c7fa                           ;[d640] cd fa c7
    call    $c670                           ;[d643] cd 70 c6
    ret                                     ;[d646] c9

    ld      a,($ffd0)                       ;[d647] 3a d0 ff
    ld      c,a                             ;[d64a] 4f
    ld      a,($ffce)                       ;[d64b] 3a ce ff
    ld      b,a                             ;[d64e] 47
    ld      a,($ffce)                       ;[d64f] 3a ce ff
    ld      d,a                             ;[d652] 57
    ld      a,($ffcd)                       ;[d653] 3a cd ff
    sub     d                               ;[d656] 92
    jr      z,$d664                         ;[d657] 28 0b
    ld      d,a                             ;[d659] 57
    inc     b                               ;[d65a] 04
    call    $c6f1                           ;[d65b] cd f1 c6
    call    $c7a7                           ;[d65e] cd a7 c7
    dec     d                               ;[d661] 15
    jr      nz,$d65a                        ;[d662] 20 f6
    ld      a,($ffcd)                       ;[d664] 3a cd ff
    ld      d,a                             ;[d667] 57
    ld      a,($ffcf)                       ;[d668] 3a cf ff
    ld      e,a                             ;[d66b] 5f
    call    $c805                           ;[d66c] cd 05 c8
    ret                                     ;[d66f] c9

    push    ix                              ;[d670] dd e5
    pop     hl                              ;[d672] e1
    ld      de,$0730                        ;[d673] 11 30 07
    ld      b,$50                           ;[d676] 06 50
    add     hl,de                           ;[d678] 19
    ld      de,$2000                        ;[d679] 11 00 20
    call    $c795                           ;[d67c] cd 95 c7
    call    $c715                           ;[d67f] cd 15 c7
    push    hl                              ;[d682] e5
    push    bc                              ;[d683] c5
    ld      e,$00                           ;[d684] 1e 00
    call    $c690                           ;[d686] cd 90 c6
    pop     bc                              ;[d689] c1
    pop     hl                              ;[d68a] e1
    call    $c79e                           ;[d68b] cd 9e c7
    ld      e,$20                           ;[d68e] 1e 20
    ld      (hl),e                          ;[d690] 73
    inc     hl                              ;[d691] 23
    bit     3,h                             ;[d692] cb 5c
    call    z,$c715                         ;[d694] cc 15 c7
    djnz    $d690                           ;[d697] 10 f7
    ret                                     ;[d699] c9

    ld      ix,($ffd4)                      ;[d69a] dd 2a d4 ff
    ld      iy,($ffd6)                      ;[d69e] fd 2a d6 ff
    ret                                     ;[d6a2] c9

    call    $c6e8                           ;[d6a3] cd e8 c6
    pop     iy                              ;[d6a6] fd e1
    pop     ix                              ;[d6a8] dd e1
    pop     hl                              ;[d6aa] e1
    pop     de                              ;[d6ab] d1
    pop     bc                              ;[d6ac] c1
    pop     af                              ;[d6ad] f1
    ret                                     ;[d6ae] c9

    ld      hl,$ffc9                        ;[d6af] 21 c9 ff
    xor     a                               ;[d6b2] af
    ld      (hl),a                          ;[d6b3] 77
    inc     hl                              ;[d6b4] 23
    ld      (hl),a                          ;[d6b5] 77
    inc     hl                              ;[d6b6] 23
    ld      (hl),a                          ;[d6b7] 77
    inc     hl                              ;[d6b8] 23
    ld      (hl),a                          ;[d6b9] 77
    inc     hl                              ;[d6ba] 23
    ld      (hl),$17                        ;[d6bb] 36 17
    inc     hl                              ;[d6bd] 23
    ld      (hl),a                          ;[d6be] 77
    inc     hl                              ;[d6bf] 23
    ld      (hl),$4f                        ;[d6c0] 36 4f
    inc     hl                              ;[d6c2] 23
    ld      (hl),a                          ;[d6c3] 77
    inc     hl                              ;[d6c4] 23
    ld      (hl),a                          ;[d6c5] 77
    inc     hl                              ;[d6c6] 23
    ld      (hl),$80                        ;[d6c7] 36 80
    inc     hl                              ;[d6c9] 23
    ld      a,($c86f)                       ;[d6ca] 3a 6f c8
    ld      d,a                             ;[d6cd] 57
    in      a,($d6)                         ;[d6ce] db d6
    bit     5,a                             ;[d6d0] cb 6f
    jr      z,$d6d6                         ;[d6d2] 28 02
    ld      d,$03                           ;[d6d4] 16 03
    bit     6,a                             ;[d6d6] cb 77
    jr      z,$d6de                         ;[d6d8] 28 04
    set     5,d                             ;[d6da] cb ea
    set     6,d                             ;[d6dc] cb f2
    ld      (hl),d                          ;[d6de] 72
    xor     a                               ;[d6df] af
    inc     hl                              ;[d6e0] 23
    ld      b,$15                           ;[d6e1] 06 15
    ld      (hl),a                          ;[d6e3] 77
    inc     hl                              ;[d6e4] 23
    djnz    $d6e3                           ;[d6e5] 10 fc
    ret                                     ;[d6e7] c9

    ld      ($ffd4),ix                      ;[d6e8] dd 22 d4 ff
    ld      ($ffd6),iy                      ;[d6ec] fd 22 d6 ff
    ret                                     ;[d6f0] c9

    push    af                              ;[d6f1] f5
    push    bc                              ;[d6f2] c5
    push    de                              ;[d6f3] d5
    push    ix                              ;[d6f4] dd e5
    pop     hl                              ;[d6f6] e1
    ld      de,$0050                        ;[d6f7] 11 50 00
    ld      a,b                             ;[d6fa] 78
    ld      b,$05                           ;[d6fb] 06 05
    rra                                     ;[d6fd] 1f
    jr      nc,$d701                        ;[d6fe] 30 01
    add     hl,de                           ;[d700] 19
    or      a                               ;[d701] b7
    rl      e                               ;[d702] cb 13
    rl      d                               ;[d704] cb 12
    dec     b                               ;[d706] 05
    jr      nz,$d6fd                        ;[d707] 20 f4
    ld      d,$00                           ;[d709] 16 00
    ld      e,c                             ;[d70b] 59
    add     hl,de                           ;[d70c] 19
    ld      a,h                             ;[d70d] 7c
    and     $0f                             ;[d70e] e6 0f
    ld      h,a                             ;[d710] 67
    pop     de                              ;[d711] d1
    pop     bc                              ;[d712] c1
    pop     af                              ;[d713] f1
    ret                                     ;[d714] c9

    ld      a,h                             ;[d715] 7c
    and     $07                             ;[d716] e6 07
    or      $d0                             ;[d718] f6 d0
    ld      h,a                             ;[d71a] 67
    ret                                     ;[d71b] c9

    ld      a,h                             ;[d71c] 7c
    and     $07                             ;[d71d] e6 07
    ld      h,a                             ;[d71f] 67
    push    ix                              ;[d720] dd e5
    pop     de                              ;[d722] d1
    ex      de,hl                           ;[d723] eb
    or      a                               ;[d724] b7
    sbc     hl,de                           ;[d725] ed 52
    jr      c,$d730                         ;[d727] 38 07
    jr      z,$d730                         ;[d729] 28 05
    ld      hl,$0800                        ;[d72b] 21 00 08
    add     hl,de                           ;[d72e] 19
    ex      de,hl                           ;[d72f] eb
    ld      a,$0e                           ;[d730] 3e 0e
    out     ($a0),a                         ;[d732] d3 a0
    ld      a,d                             ;[d734] 7a
    out     ($a1),a                         ;[d735] d3 a1
    ld      a,$0f                           ;[d737] 3e 0f
    out     ($a0),a                         ;[d739] d3 a0
    ld      a,e                             ;[d73b] 7b
    out     ($a1),a                         ;[d73c] d3 a1
    push    de                              ;[d73e] d5
    pop     iy                              ;[d73f] fd e1
    ret                                     ;[d741] c9

    ld      a,h                             ;[d742] 7c
    and     $07                             ;[d743] e6 07
    ld      h,a                             ;[d745] 67
    call    $c75b                           ;[d746] cd 5b c7
    ld      a,$0c                           ;[d749] 3e 0c
    out     ($a0),a                         ;[d74b] d3 a0
    ld      a,h                             ;[d74d] 7c
    out     ($a1),a                         ;[d74e] d3 a1
    ld      a,$0d                           ;[d750] 3e 0d
    out     ($a0),a                         ;[d752] d3 a0
    ld      a,l                             ;[d754] 7d
    out     ($a1),a                         ;[d755] d3 a1
    push    hl                              ;[d757] e5
    pop     ix                              ;[d758] dd e1
    ret                                     ;[d75a] c9

    in      a,($a0)                         ;[d75b] db a0
    in      a,($82)                         ;[d75d] db 82
    bit     1,a                             ;[d75f] cb 4f
    jr      z,$d75d                         ;[d761] 28 fa
    ret                                     ;[d763] c9

    ld      bc,$0780                        ;[d764] 01 80 07
    push    ix                              ;[d767] dd e5
    pop     hl                              ;[d769] e1
    ld      de,$2000                        ;[d76a] 11 00 20
    call    $c715                           ;[d76d] cd 15 c7
    ld      (hl),d                          ;[d770] 72
    in      a,($81)                         ;[d771] db 81
    set     7,a                             ;[d773] cb ff
    out     ($81),a                         ;[d775] d3 81
    ld      (hl),e                          ;[d777] 73
    res     7,a                             ;[d778] cb bf
    out     ($81),a                         ;[d77a] d3 81
    inc     hl                              ;[d77c] 23
    bit     3,h                             ;[d77d] cb 5c
    call    z,$c715                         ;[d77f] cc 15 c7
    dec     bc                              ;[d782] 0b
    ld      a,b                             ;[d783] 78
    or      c                               ;[d784] b1
    jr      nz,$d770                        ;[d785] 20 e9
    push    ix                              ;[d787] dd e5
    pop     hl                              ;[d789] e1
    call    $c71c                           ;[d78a] cd 1c c7
    xor     a                               ;[d78d] af
    ld      ($ffca),a                       ;[d78e] 32 ca ff
    ld      ($ffcb),a                       ;[d791] 32 cb ff
    ret                                     ;[d794] c9

    push    af                              ;[d795] f5
    in      a,($81)                         ;[d796] db 81
    set     7,a                             ;[d798] cb ff
    out     ($81),a                         ;[d79a] d3 81
    pop     af                              ;[d79c] f1
    ret                                     ;[d79d] c9

    push    af                              ;[d79e] f5
    in      a,($81)                         ;[d79f] db 81
    res     7,a                             ;[d7a1] cb bf
    out     ($81),a                         ;[d7a3] d3 81
    pop     af                              ;[d7a5] f1
    ret                                     ;[d7a6] c9

    push    de                              ;[d7a7] d5
    push    bc                              ;[d7a8] c5
    ld      a,$50                           ;[d7a9] 3e 50
    cpl                                     ;[d7ab] 2f
    ld      d,$ff                           ;[d7ac] 16 ff
    ld      e,a                             ;[d7ae] 5f
    inc     de                              ;[d7af] 13
    call    $c7b6                           ;[d7b0] cd b6 c7
    pop     bc                              ;[d7b3] c1
    pop     de                              ;[d7b4] d1
    ret                                     ;[d7b5] c9

    ld      a,($ffd0)                       ;[d7b6] 3a d0 ff
    ld      c,a                             ;[d7b9] 4f
    call    $c6f1                           ;[d7ba] cd f1 c6
    push    hl                              ;[d7bd] e5
    add     hl,de                           ;[d7be] 19
    ex      de,hl                           ;[d7bf] eb
    pop     hl                              ;[d7c0] e1
    ld      a,($ffd0)                       ;[d7c1] 3a d0 ff
    ld      b,a                             ;[d7c4] 47
    ld      a,($ffcf)                       ;[d7c5] 3a cf ff
    sub     b                               ;[d7c8] 90
    inc     a                               ;[d7c9] 3c
    ld      b,a                             ;[d7ca] 47
    call    $c715                           ;[d7cb] cd 15 c7
    ex      de,hl                           ;[d7ce] eb
    call    $c715                           ;[d7cf] cd 15 c7
    ex      de,hl                           ;[d7d2] eb
    push    bc                              ;[d7d3] c5
    push    de                              ;[d7d4] d5
    push    hl                              ;[d7d5] e5
    ld      c,$02                           ;[d7d6] 0e 02
    ld      a,(hl)                          ;[d7d8] 7e
    ld      (de),a                          ;[d7d9] 12
    inc     de                              ;[d7da] 13
    ld      a,d                             ;[d7db] 7a
    and     $07                             ;[d7dc] e6 07
    or      $d0                             ;[d7de] f6 d0
    ld      d,a                             ;[d7e0] 57
    inc     hl                              ;[d7e1] 23
    bit     3,h                             ;[d7e2] cb 5c
    call    z,$c715                         ;[d7e4] cc 15 c7
    djnz    $d7d8                           ;[d7e7] 10 ef
    dec     c                               ;[d7e9] 0d
    jr      z,$d7f6                         ;[d7ea] 28 0a
    ld      a,c                             ;[d7ec] 79
    pop     hl                              ;[d7ed] e1
    pop     de                              ;[d7ee] d1
    pop     bc                              ;[d7ef] c1
    ld      c,a                             ;[d7f0] 4f
    call    $c795                           ;[d7f1] cd 95 c7
    jr      $d7d8                           ;[d7f4] 18 e2
    call    $c79e                           ;[d7f6] cd 9e c7
    ret                                     ;[d7f9] c9

    push    de                              ;[d7fa] d5
    push    bc                              ;[d7fb] c5
    ld      de,$0050                        ;[d7fc] 11 50 00
    call    $c7b6                           ;[d7ff] cd b6 c7
    pop     bc                              ;[d802] c1
    pop     de                              ;[d803] d1
    ret                                     ;[d804] c9

    ld      a,e                             ;[d805] 7b
    sub     c                               ;[d806] 91
    inc     a                               ;[d807] 3c
    ld      e,a                             ;[d808] 5f
    ld      a,d                             ;[d809] 7a
    sub     b                               ;[d80a] 90
    inc     a                               ;[d80b] 3c
    ld      d,a                             ;[d80c] 57
    call    $c6f1                           ;[d80d] cd f1 c6
    call    $c715                           ;[d810] cd 15 c7
    ld      (hl),$20                        ;[d813] 36 20
    call    $c795                           ;[d815] cd 95 c7
    ld      (hl),$00                        ;[d818] 36 00
    call    $c79e                           ;[d81a] cd 9e c7
    inc     hl                              ;[d81d] 23
    dec     e                               ;[d81e] 1d
    jr      nz,$d810                        ;[d81f] 20 ef
    inc     b                               ;[d821] 04
    ld      a,($ffd0)                       ;[d822] 3a d0 ff
    ld      c,a                             ;[d825] 4f
    ld      a,($ffcf)                       ;[d826] 3a cf ff
    sub     c                               ;[d829] 91
    inc     a                               ;[d82a] 3c
    ld      e,a                             ;[d82b] 5f
    dec     d                               ;[d82c] 15
    jr      nz,$d80d                        ;[d82d] 20 de
    ret                                     ;[d82f] c9

    ld      a,($ffcd)                       ;[d830] 3a cd ff
    ld      b,a                             ;[d833] 47
    ld      a,($ffce)                       ;[d834] 3a ce ff
    cp      b                               ;[d837] b8
    jr      z,$d845                         ;[d838] 28 0b
    ld      d,a                             ;[d83a] 57
    ld      a,b                             ;[d83b] 78
    sub     d                               ;[d83c] 92
    ld      d,a                             ;[d83d] 57
    dec     b                               ;[d83e] 05
    call    $c7fa                           ;[d83f] cd fa c7
    dec     d                               ;[d842] 15
    jr      nz,$d83e                        ;[d843] 20 f9
    ld      a,($ffce)                       ;[d845] 3a ce ff
    ld      b,a                             ;[d848] 47
    ld      d,a                             ;[d849] 57
    ld      a,($ffd0)                       ;[d84a] 3a d0 ff
    ld      c,a                             ;[d84d] 4f
    ld      a,($ffcf)                       ;[d84e] 3a cf ff
    ld      e,a                             ;[d851] 5f
    call    $c805                           ;[d852] cd 05 c8
    ret                                     ;[d855] c9

    push    bc                              ;[d856] c5
    ld      b,$1e                           ;[d857] 06 1e
    ld      c,$0f                           ;[d859] 0e 0f
    dec     c                               ;[d85b] 0d
    jp      nz,$c85b                        ;[d85c] c2 5b c8
    dec     b                               ;[d85f] 05
    jp      nz,$c859                        ;[d860] c2 59 c8
    pop     bc                              ;[d863] c1
    ret                                     ;[d864] c9

    ld      h,e                             ;[d865] 63
    ld      d,b                             ;[d866] 50
    ld      d,h                             ;[d867] 54
    xor     d                               ;[d868] aa
    add     hl,de                           ;[d869] 19
    ld      b,$19                           ;[d86a] 06 19
    add     hl,de                           ;[d86c] 19
    nop                                     ;[d86d] 00
    dec     c                               ;[d86e] 0d
    dec     c                               ;[d86f] 0d
    dec     c                               ;[d870] 0d
    nop                                     ;[d871] 00
    nop                                     ;[d872] 00
    nop                                     ;[d873] 00
    nop                                     ;[d874] 00
    ld      a,($ffd1)                       ;[d875] 3a d1 ff
    set     3,a                             ;[d878] cb df
    ld      ($ffd1),a                       ;[d87a] 32 d1 ff
    ld      a,($ffca)                       ;[d87d] 3a ca ff
    ld      c,a                             ;[d880] 4f
    rra                                     ;[d881] 1f
    jr      nc,$d88b                        ;[d882] 30 07
    inc     iy                              ;[d884] fd 23
    inc     c                               ;[d886] 0c
    ld      a,c                             ;[d887] 79
    ld      ($ffca),a                       ;[d888] 32 ca ff
    xor     a                               ;[d88b] af
    ret                                     ;[d88c] c9

    ld      hl,$c865                        ;[d88d] 21 65 c8
    ld      b,$10                           ;[d890] 06 10
    ld      c,$a1                           ;[d892] 0e a1
    xor     a                               ;[d894] af
    out     ($a0),a                         ;[d895] d3 a0
    inc     a                               ;[d897] 3c
    outi                                    ;[d898] ed a3
    jr      nz,$d895                        ;[d89a] 20 f9
    ld      ix,$0000                        ;[d89c] dd 21 00 00
    call    $c764                           ;[d8a0] cd 64 c7
    call    $c8b6                           ;[d8a3] cd b6 c8
    ld      hl,$0000                        ;[d8a6] 21 00 00
    call    $c71c                           ;[d8a9] cd 1c c7
    ld      a,($ffd1)                       ;[d8ac] 3a d1 ff
    res     3,a                             ;[d8af] cb 9f
    ld      ($ffd1),a                       ;[d8b1] 32 d1 ff
    xor     a                               ;[d8b4] af
    ret                                     ;[d8b5] c9

    ld      a,$06                           ;[d8b6] 3e 06
    out     ($a0),a                         ;[d8b8] d3 a0
    ld      a,$18                           ;[d8ba] 3e 18
    out     ($a1),a                         ;[d8bc] d3 a1
    ret                                     ;[d8be] c9

    xor     a                               ;[d8bf] af
    ld      ($ffce),a                       ;[d8c0] 32 ce ff
    ld      ($ffd0),a                       ;[d8c3] 32 d0 ff
    ld      ($ffc9),a                       ;[d8c6] 32 c9 ff
    ld      a,$17                           ;[d8c9] 3e 17
    ld      ($ffcd),a                       ;[d8cb] 32 cd ff
    ret                                     ;[d8ce] c9

    ld      b,$04                           ;[d8cf] 06 04
    call    $c75b                           ;[d8d1] cd 5b c7
    xor     a                               ;[d8d4] af
    ld      c,$a1                           ;[d8d5] 0e a1
    out     ($a0),a                         ;[d8d7] d3 a0
    inc     a                               ;[d8d9] 3c
    outi                                    ;[d8da] ed a3
    jr      nz,$d8d7                        ;[d8dc] 20 f9
    ret                                     ;[d8de] c9

    ld      a,($ffd9)                       ;[d8df] 3a d9 ff
    or      a                               ;[d8e2] b7
    jr      nz,$d8ea                        ;[d8e3] 20 05
    inc     a                               ;[d8e5] 3c
    ld      ($ffd9),a                       ;[d8e6] 32 d9 ff
    ret                                     ;[d8e9] c9

    ld      a,c                             ;[d8ea] 79
    and     $0f                             ;[d8eb] e6 0f
    rlca                                    ;[d8ed] 07
    rlca                                    ;[d8ee] 07
    rlca                                    ;[d8ef] 07
    rlca                                    ;[d8f0] 07
    cpl                                     ;[d8f1] 2f
    ld      b,a                             ;[d8f2] 47
    ld      a,($ffd1)                       ;[d8f3] 3a d1 ff
    and     b                               ;[d8f6] a0
    ld      ($ffd1),a                       ;[d8f7] 32 d1 ff
    xor     a                               ;[d8fa] af
    ret                                     ;[d8fb] c9

    xor     a                               ;[d8fc] af
    ld      ($ffd1),a                       ;[d8fd] 32 d1 ff
    ret                                     ;[d900] c9

    ld      a,($ffd9)                       ;[d901] 3a d9 ff
    ld      b,a                             ;[d904] 47
    ld      d,$00                           ;[d905] 16 00
    ld      e,a                             ;[d907] 5f
    ld      hl,$ffd9                        ;[d908] 21 d9 ff
    add     hl,de                           ;[d90b] 19
    ld      a,c                             ;[d90c] 79
    sub     $20                             ;[d90d] d6 20
    ld      (hl),a                          ;[d90f] 77
    ld      a,b                             ;[d910] 78
    inc     a                               ;[d911] 3c
    ld      ($ffd9),a                       ;[d912] 32 d9 ff
    ret                                     ;[d915] c9

    ld      a,b                             ;[d916] 78
    out     ($a0),a                         ;[d917] d3 a0
    ld      a,c                             ;[d919] 79
    out     ($a1),a                         ;[d91a] d3 a1
    ret                                     ;[d91c] c9

    call    $c6f1                           ;[d91d] cd f1 c6
    push    hl                              ;[d920] e5
    ld      b,d                             ;[d921] 42
    ld      c,e                             ;[d922] 4b
    call    $c6f1                           ;[d923] cd f1 c6
    pop     de                              ;[d926] d1
    push    de                              ;[d927] d5
    or      a                               ;[d928] b7
    sbc     hl,de                           ;[d929] ed 52
    inc     hl                              ;[d92b] 23
    ex      de,hl                           ;[d92c] eb
    pop     hl                              ;[d92d] e1
    ld      b,a                             ;[d92e] 47
    call    $c795                           ;[d92f] cd 95 c7
    call    $c715                           ;[d932] cd 15 c7
    ld      a,(hl)                          ;[d935] 7e
    or      b                               ;[d936] b0
    ld      (hl),a                          ;[d937] 77
    inc     hl                              ;[d938] 23
    dec     de                              ;[d939] 1b
    ld      a,d                             ;[d93a] 7a
    or      e                               ;[d93b] b3
    jr      nz,$d932                        ;[d93c] 20 f4
    call    $c79e                           ;[d93e] cd 9e c7
    ret                                     ;[d941] c9

    ld      a,c                             ;[d942] 79
    cp      $44                             ;[d943] fe 44
    jr      nz,$d94b                        ;[d945] 20 04
    ld      c,$40                           ;[d947] 0e 40
    jr      $d984                           ;[d949] 18 39
    cp      $45                             ;[d94b] fe 45
    jr      nz,$d953                        ;[d94d] 20 04
    ld      c,$60                           ;[d94f] 0e 60
    jr      $d984                           ;[d951] 18 31
    cp      $46                             ;[d953] fe 46
    jr      nz,$d95b                        ;[d955] 20 04
    ld      c,$20                           ;[d957] 0e 20
    jr      $d984                           ;[d959] 18 29
    ld      a,($c86f)                       ;[d95b] 3a 6f c8
    ld      d,a                             ;[d95e] 57
    in      a,($d6)                         ;[d95f] db d6
    bit     5,a                             ;[d961] cb 6f
    jr      z,$d967                         ;[d963] 28 02
    ld      d,$03                           ;[d965] 16 03
    bit     6,a                             ;[d967] cb 77
    jr      z,$d96f                         ;[d969] 28 04
    set     5,d                             ;[d96b] cb ea
    set     6,d                             ;[d96d] cb f2
    ld      a,d                             ;[d96f] 7a
    ld      ($ffd3),a                       ;[d970] 32 d3 ff
    ld      b,$0a                           ;[d973] 06 0a
    ld      c,a                             ;[d975] 4f
    call    $c916                           ;[d976] cd 16 c9
    ld      a,($c870)                       ;[d979] 3a 70 c8
    ld      c,a                             ;[d97c] 4f
    ld      b,$0b                           ;[d97d] 06 0b
    call    $c916                           ;[d97f] cd 16 c9
    xor     a                               ;[d982] af
    ret                                     ;[d983] c9

    ld      a,($ffd3)                       ;[d984] 3a d3 ff
    and     $9f                             ;[d987] e6 9f
    or      c                               ;[d989] b1
    ld      ($ffd3),a                       ;[d98a] 32 d3 ff
    ld      c,a                             ;[d98d] 4f
    ld      b,$0a                           ;[d98e] 06 0a
    call    $c916                           ;[d990] cd 16 c9
    xor     a                               ;[d993] af
    ret                                     ;[d994] c9

    ld      hl,$ffd1                        ;[d995] 21 d1 ff
    set     0,(hl)                          ;[d998] cb c6
    xor     a                               ;[d99a] af
    ret                                     ;[d99b] c9

    ld      hl,$ffd1                        ;[d99c] 21 d1 ff
    res     0,(hl)                          ;[d99f] cb 86
    xor     a                               ;[d9a1] af
    ret                                     ;[d9a2] c9

    ld      hl,$ffd1                        ;[d9a3] 21 d1 ff
    set     2,(hl)                          ;[d9a6] cb d6
    xor     a                               ;[d9a8] af
    ret                                     ;[d9a9] c9

    ld      hl,$ffd1                        ;[d9aa] 21 d1 ff
    res     2,(hl)                          ;[d9ad] cb 96
    xor     a                               ;[d9af] af
    ret                                     ;[d9b0] c9

    ld      hl,$ffd1                        ;[d9b1] 21 d1 ff
    set     1,(hl)                          ;[d9b4] cb ce
    xor     a                               ;[d9b6] af
    ret                                     ;[d9b7] c9

    ld      hl,$ffd1                        ;[d9b8] 21 d1 ff
    res     1,(hl)                          ;[d9bb] cb 8e
    xor     a                               ;[d9bd] af
    ret                                     ;[d9be] c9

    ld      a,($ffd1)                       ;[d9bf] 3a d1 ff
    and     $8f                             ;[d9c2] e6 8f
    or      $10                             ;[d9c4] f6 10
    ld      ($ffd1),a                       ;[d9c6] 32 d1 ff
    xor     a                               ;[d9c9] af
    ret                                     ;[d9ca] c9

    ld      a,($ffd1)                       ;[d9cb] 3a d1 ff
    and     $8f                             ;[d9ce] e6 8f
    or      $00                             ;[d9d0] f6 00
    ld      ($ffd1),a                       ;[d9d2] 32 d1 ff
    xor     a                               ;[d9d5] af
    ret                                     ;[d9d6] c9

    ld      a,($ffd1)                       ;[d9d7] 3a d1 ff
    and     $8f                             ;[d9da] e6 8f
    or      $20                             ;[d9dc] f6 20
    ld      ($ffd1),a                       ;[d9de] 32 d1 ff
    xor     a                               ;[d9e1] af
    ret                                     ;[d9e2] c9

    call    $ca01                           ;[d9e3] cd 01 ca
    cp      $01                             ;[d9e6] fe 01
    jr      nz,$d9eb                        ;[d9e8] 20 01
    ld      a,c                             ;[d9ea] 79
    ld      ($ffd8),a                       ;[d9eb] 32 d8 ff
    cp      $60                             ;[d9ee] fe 60
    jp      nc,$ca70                        ;[d9f0] d2 70 ca
    sub     $31                             ;[d9f3] d6 31
    jp      c,$ca70                         ;[d9f5] da 70 ca
    call    $ca05                           ;[d9f8] cd 05 ca
    or      a                               ;[d9fb] b7
    jr      z,$da70                         ;[d9fc] 28 72
    jp      $c6a3                           ;[d9fe] c3 a3 c6
    ld      hl,($bffa)                      ;[da01] 2a fa bf
    jp      (hl)                            ;[da04] e9
    add     a                               ;[da05] 87
    ld      hl,$ca12                        ;[da06] 21 12 ca
    ld      d,$00                           ;[da09] 16 00
    ld      e,a                             ;[da0b] 5f
    add     hl,de                           ;[da0c] 19
    ld      e,(hl)                          ;[da0d] 5e
    inc     hl                              ;[da0e] 23
    ld      d,(hl)                          ;[da0f] 56
    ex      de,hl                           ;[da10] eb
    jp      (hl)                            ;[da11] e9
    ld      b,d                             ;[da12] 42
    call    $cd46                           ;[da13] cd 46 cd
    ld      a,d                             ;[da16] 7a
    jp      z,$ca7a                         ;[da17] ca 7a ca
    ld      a,d                             ;[da1a] 7a
    jp      z,$ca7c                         ;[da1b] ca 7c ca
    cp      a                               ;[da1e] bf
    ret                                     ;[da1f] c9

    ld      a,a                             ;[da20] 7f
    call    z,$ca7a                         ;[da21] cc 7a ca
    call    nc,$f2ca                        ;[da24] d4 ca f2
    jp      z,$cb1c                         ;[da27] ca 1c cb
    ld      l,d                             ;[da2a] 6a
    res     3,a                             ;[da2b] cb 9f
    res     7,e                             ;[da2d] cb bb
    bit     7,h                             ;[da2f] cb 7c
    jp      z,$c875                         ;[da31] ca 75 c8
    xor     h                               ;[da34] ac
    ret     z                               ;[da35] c8
    ld      a,d                             ;[da36] 7a
    jp      z,$c942                         ;[da37] ca 42 c9
    ld      b,d                             ;[da3a] 42
    ret                                     ;[da3b] c9

    ld      b,d                             ;[da3c] 42
    ret                                     ;[da3d] c9

    ld      b,d                             ;[da3e] 42
    ret                                     ;[da3f] c9

    sub     l                               ;[da40] 95
    ret                                     ;[da41] c9

    sbc     h                               ;[da42] 9c
    ret                                     ;[da43] c9

    and     e                               ;[da44] a3
    ret                                     ;[da45] c9

    xor     d                               ;[da46] aa
    ret                                     ;[da47] c9

    or      c                               ;[da48] b1
    ret                                     ;[da49] c9

    cp      b                               ;[da4a] b8
    ret                                     ;[da4b] c9

    ld      b,l                             ;[da4c] 45
    call    z,$ca7a                         ;[da4d] cc 7a ca
    xor     e                               ;[da50] ab
    call    z,$ccdf                         ;[da51] cc df cc
    ld      a,d                             ;[da54] 7a
    jp      z,$cbda                         ;[da55] ca da cb
    inc     b                               ;[da58] 04
    call    z,$cc1b                         ;[da59] cc 1b cc
    inc     sp                              ;[da5c] 33
    call    z,$c9bf                         ;[da5d] cc bf c9
    set     1,c                             ;[da60] cb c9
    rst     $10                             ;[da62] d7
    ret                                     ;[da63] c9

    cp      a                               ;[da64] bf
    ret                                     ;[da65] c9

    ld      a,a                             ;[da66] 7f
    call    z,$c8df                         ;[da67] cc df c8
    call    m,$95c8                         ;[da6a] fc c8 95
    call    z,$cd27                         ;[da6d] cc 27 cd
    xor     a                               ;[da70] af
    ld      ($ffd8),a                       ;[da71] 32 d8 ff
    ld      ($ffd9),a                       ;[da74] 32 d9 ff
    jp      $c6a3                           ;[da77] c3 a3 c6
    xor     a                               ;[da7a] af
    ret                                     ;[da7b] c9

    call    $cdd7                           ;[da7c] cd d7 cd
    cp      $01                             ;[da7f] fe 01
    jr      nz,$da8c                        ;[da81] 20 09
    ld      a,c                             ;[da83] 79
    cp      $31                             ;[da84] fe 31
    jr      c,$dab0                         ;[da86] 38 28
    cp      $36                             ;[da88] fe 36
    jr      nc,$dab0                        ;[da8a] 30 24
    call    $cab5                           ;[da8c] cd b5 ca
    or      a                               ;[da8f] b7
    ret     nz                              ;[da90] c0
    ld      a,($ffda)                       ;[da91] 3a da ff
    and     $0f                             ;[da94] e6 0f
    dec     a                               ;[da96] 3d
    add     a                               ;[da97] 87
    ld      b,a                             ;[da98] 47
    add     a                               ;[da99] 87
    ld      c,a                             ;[da9a] 4f
    add     a                               ;[da9b] 87
    add     b                               ;[da9c] 80
    add     c                               ;[da9d] 81
    add     $04                             ;[da9e] c6 04
    ld      hl,($bff4)                      ;[daa0] 2a f4 bf
    ld      d,$00                           ;[daa3] 16 00
    ld      e,a                             ;[daa5] 5f
    add     hl,de                           ;[daa6] 19
    ex      de,hl                           ;[daa7] eb
    ld      hl,$ffdb                        ;[daa8] 21 db ff
    ld      bc,$0009                        ;[daab] 01 09 00
    ldir                                    ;[daae] ed b0
    call    $cd51                           ;[dab0] cd 51 cd
    xor     a                               ;[dab3] af
    ret                                     ;[dab4] c9

    call    $c901                           ;[dab5] cd 01 c9
    ld      (hl),c                          ;[dab8] 71
    cp      $0a                             ;[dab9] fe 0a
    ret     nz                              ;[dabb] c0
    ld      hl,$ffdb                        ;[dabc] 21 db ff
    ld      b,$08                           ;[dabf] 06 08
    ld      a,(hl)                          ;[dac1] 7e
    inc     hl                              ;[dac2] 23
    cp      $7f                             ;[dac3] fe 7f
    jr      z,$dacd                         ;[dac5] 28 06
    djnz    $dac1                           ;[dac7] 10 f8
    ld      (hl),$7f                        ;[dac9] 36 7f
    jr      $dad2                           ;[dacb] 18 05
    ld      hl,$ffe3                        ;[dacd] 21 e3 ff
    ld      (hl),$20                        ;[dad0] 36 20
    xor     a                               ;[dad2] af
    ret                                     ;[dad3] c9

    call    $cdd7                           ;[dad4] cd d7 cd
    cp      $04                             ;[dad7] fe 04
    jr      z,$dadf                         ;[dad9] 28 04
    call    $c901                           ;[dadb] cd 01 c9
    ret                                     ;[dade] c9

    ld      a,c                             ;[dadf] 79
    sub     $20                             ;[dae0] d6 20
    ld      e,a                             ;[dae2] 5f
    ld      hl,$ffda                        ;[dae3] 21 da ff
    ld      b,(hl)                          ;[dae6] 46
    inc     hl                              ;[dae7] 23
    ld      c,(hl)                          ;[dae8] 4e
    inc     hl                              ;[dae9] 23
    ld      d,(hl)                          ;[daea] 56
    ld      a,$01                           ;[daeb] 3e 01
    call    $c91d                           ;[daed] cd 1d c9
    xor     a                               ;[daf0] af
    ret                                     ;[daf1] c9

    call    $cdd7                           ;[daf2] cd d7 cd
    cp      $02                             ;[daf5] fe 02
    jr      z,$dafd                         ;[daf7] 28 04
    call    $c901                           ;[daf9] cd 01 c9
    ret                                     ;[dafc] c9

    ld      a,c                             ;[dafd] 79
    sub     $20                             ;[dafe] d6 20
    ld      e,a                             ;[db00] 5f
    ld      a,($ffda)                       ;[db01] 3a da ff
    ld      d,a                             ;[db04] 57
    ld      a,($ffd3)                       ;[db05] 3a d3 ff
    and     $60                             ;[db08] e6 60
    or      d                               ;[db0a] b2
    ld      ($ffd3),a                       ;[db0b] 32 d3 ff
    ld      c,a                             ;[db0e] 4f
    ld      b,$0a                           ;[db0f] 06 0a
    call    $c916                           ;[db11] cd 16 c9
    ld      c,e                             ;[db14] 4b
    ld      b,$0b                           ;[db15] 06 0b
    call    $c916                           ;[db17] cd 16 c9
    xor     a                               ;[db1a] af
    ret                                     ;[db1b] c9

    call    $cdd7                           ;[db1c] cd d7 cd
    cp      $04                             ;[db1f] fe 04
    jr      z,$db27                         ;[db21] 28 04
    call    $c901                           ;[db23] cd 01 c9
    ret                                     ;[db26] c9

    ld      a,c                             ;[db27] 79
    sub     $20                             ;[db28] d6 20
    ld      e,a                             ;[db2a] 5f
    ld      a,$4f                           ;[db2b] 3e 4f
    cp      e                               ;[db2d] bb
    jr      c,$db68                         ;[db2e] 38 38
    ld      hl,$ffda                        ;[db30] 21 da ff
    ld      b,(hl)                          ;[db33] 46
    inc     hl                              ;[db34] 23
    ld      a,(hl)                          ;[db35] 7e
    cp      $18                             ;[db36] fe 18
    jr      nc,$db68                        ;[db38] 30 2e
    ld      c,a                             ;[db3a] 4f
    inc     hl                              ;[db3b] 23
    ld      d,(hl)                          ;[db3c] 56
    ld      a,c                             ;[db3d] 79
    cp      b                               ;[db3e] b8
    jr      c,$db68                         ;[db3f] 38 27
    ld      a,e                             ;[db41] 7b
    cp      d                               ;[db42] ba
    jr      c,$db68                         ;[db43] 38 23
    ld      hl,$ffcd                        ;[db45] 21 cd ff
    ld      (hl),c                          ;[db48] 71
    inc     hl                              ;[db49] 23
    ld      (hl),b                          ;[db4a] 70
    inc     hl                              ;[db4b] 23
    ld      (hl),e                          ;[db4c] 73
    inc     hl                              ;[db4d] 23
    ld      (hl),d                          ;[db4e] 72
    ld      a,$01                           ;[db4f] 3e 01
    ld      ($ffc9),a                       ;[db51] 32 c9 ff
    ld      a,$50                           ;[db54] 3e 50
    sub     e                               ;[db56] 93
    ld      e,a                             ;[db57] 5f
    ld      a,d                             ;[db58] 7a
    add     e                               ;[db59] 83
    ld      hl,$ffd1                        ;[db5a] 21 d1 ff
    bit     3,(hl)                          ;[db5d] cb 5e
    jr      z,$db62                         ;[db5f] 28 01
    add     a                               ;[db61] 87
    ld      ($ffc8),a                       ;[db62] 32 c8 ff
    call    $cc1b                           ;[db65] cd 1b cc
    xor     a                               ;[db68] af
    ret                                     ;[db69] c9

    call    $cdd7                           ;[db6a] cd d7 cd
    cp      $02                             ;[db6d] fe 02
    jr      z,$db75                         ;[db6f] 28 04
    call    $c901                           ;[db71] cd 01 c9
    ret                                     ;[db74] c9

    ld      a,c                             ;[db75] 79
    sub     $20                             ;[db76] d6 20
    ld      c,a                             ;[db78] 4f
    ld      a,$4f                           ;[db79] 3e 4f
    cp      c                               ;[db7b] b9
    jr      c,$db9d                         ;[db7c] 38 1f
    ld      a,($ffd1)                       ;[db7e] 3a d1 ff
    bit     3,a                             ;[db81] cb 5f
    jr      z,$db88                         ;[db83] 28 03
    ld      a,c                             ;[db85] 79
    add     a                               ;[db86] 87
    ld      c,a                             ;[db87] 4f
    ld      a,($ffda)                       ;[db88] 3a da ff
    cp      $19                             ;[db8b] fe 19
    jr      nc,$db9d                        ;[db8d] 30 0e
    ld      b,a                             ;[db8f] 47
    ld      ($ffcb),a                       ;[db90] 32 cb ff
    ld      a,c                             ;[db93] 79
    ld      ($ffca),a                       ;[db94] 32 ca ff
    call    $c6f1                           ;[db97] cd f1 c6
    call    $c71c                           ;[db9a] cd 1c c7
    xor     a                               ;[db9d] af
    ret                                     ;[db9e] c9

    call    $cdd7                           ;[db9f] cd d7 cd
    ld      a,c                             ;[dba2] 79
    sub     $20                             ;[dba3] d6 20
    ld      c,a                             ;[dba5] 4f
    ld      a,$4f                           ;[dba6] 3e 4f
    cp      c                               ;[dba8] b9
    jr      c,$dbb9                         ;[dba9] 38 0e
    ld      a,($ffcb)                       ;[dbab] 3a cb ff
    ld      b,a                             ;[dbae] 47
    ld      a,c                             ;[dbaf] 79
    ld      ($ffca),a                       ;[dbb0] 32 ca ff
    call    $c6f1                           ;[dbb3] cd f1 c6
    call    $c71c                           ;[dbb6] cd 1c c7
    xor     a                               ;[dbb9] af
    ret                                     ;[dbba] c9

    call    $cdd7                           ;[dbbb] cd d7 cd
    cp      $04                             ;[dbbe] fe 04
    jr      z,$dbc6                         ;[dbc0] 28 04
    call    $c901                           ;[dbc2] cd 01 c9
    ret                                     ;[dbc5] c9

    ld      a,c                             ;[dbc6] 79
    sub     $20                             ;[dbc7] d6 20
    ld      e,a                             ;[dbc9] 5f
    ld      hl,$ffda                        ;[dbca] 21 da ff
    ld      b,(hl)                          ;[dbcd] 46
    inc     hl                              ;[dbce] 23
    ld      c,(hl)                          ;[dbcf] 4e
    inc     hl                              ;[dbd0] 23
    ld      d,(hl)                          ;[dbd1] 56
    ld      a,($ffd2)                       ;[dbd2] 3a d2 ff
    call    $c91d                           ;[dbd5] cd 1d c9
    xor     a                               ;[dbd8] af
    ret                                     ;[dbd9] c9

    ld      bc,$0780                        ;[dbda] 01 80 07
    push    ix                              ;[dbdd] dd e5
    pop     hl                              ;[dbdf] e1
    call    $c795                           ;[dbe0] cd 95 c7
    ld      a,($ffd2)                       ;[dbe3] 3a d2 ff
    ld      d,a                             ;[dbe6] 57
    ld      e,$20                           ;[dbe7] 1e 20
    call    $c715                           ;[dbe9] cd 15 c7
    ld      a,(hl)                          ;[dbec] 7e
    and     d                               ;[dbed] a2
    jr      nz,$dbf9                        ;[dbee] 20 09
    ld      (hl),$00                        ;[dbf0] 36 00
    call    $c795                           ;[dbf2] cd 95 c7
    ld      (hl),e                          ;[dbf5] 73
    call    $c795                           ;[dbf6] cd 95 c7
    inc     hl                              ;[dbf9] 23
    dec     bc                              ;[dbfa] 0b
    ld      a,b                             ;[dbfb] 78
    or      c                               ;[dbfc] b1
    jr      nz,$dbe9                        ;[dbfd] 20 ea
    call    $c79e                           ;[dbff] cd 9e c7
    xor     a                               ;[dc02] af
    ret                                     ;[dc03] c9

    ld      a,($ffd0)                       ;[dc04] 3a d0 ff
    ld      c,a                             ;[dc07] 4f
    ld      a,($ffce)                       ;[dc08] 3a ce ff
    ld      b,a                             ;[dc0b] 47
    ld      a,($ffcf)                       ;[dc0c] 3a cf ff
    ld      e,a                             ;[dc0f] 5f
    ld      a,($ffcd)                       ;[dc10] 3a cd ff
    ld      d,a                             ;[dc13] 57
    call    $c805                           ;[dc14] cd 05 c8
    call    $cc1b                           ;[dc17] cd 1b cc
    ret                                     ;[dc1a] c9

    ld      a,($ffce)                       ;[dc1b] 3a ce ff
    ld      b,a                             ;[dc1e] 47
    ld      a,($ffd0)                       ;[dc1f] 3a d0 ff
    ld      c,a                             ;[dc22] 4f
    call    $c6f1                           ;[dc23] cd f1 c6
    call    $c71c                           ;[dc26] cd 1c c7
    ld      a,b                             ;[dc29] 78
    ld      ($ffcb),a                       ;[dc2a] 32 cb ff
    ld      a,c                             ;[dc2d] 79
    ld      ($ffca),a                       ;[dc2e] 32 ca ff
    xor     a                               ;[dc31] af
    ret                                     ;[dc32] c9

    call    $c764                           ;[dc33] cd 64 c7
    ld      a,$01                           ;[dc36] 3e 01
    ld      ($ffc8),a                       ;[dc38] 32 c8 ff
    ld      a,$4f                           ;[dc3b] 3e 4f
    ld      ($ffcf),a                       ;[dc3d] 32 cf ff
    call    $c8bf                           ;[dc40] cd bf c8
    xor     a                               ;[dc43] af
    ret                                     ;[dc44] c9

    ld      b,$00                           ;[dc45] 06 00
    ld      c,$00                           ;[dc47] 0e 00
    push    bc                              ;[dc49] c5
    call    $cdf4                           ;[dc4a] cd f4 cd
    ld      c,d                             ;[dc4d] 4a
    push    de                              ;[dc4e] d5
    call    $ffa0                           ;[dc4f] cd a0 ff
    pop     de                              ;[dc52] d1
    pop     bc                              ;[dc53] c1
    bit     3,e                             ;[dc54] cb 5b
    jr      z,$dc65                         ;[dc56] 28 0d
    inc     c                               ;[dc58] 0c
    ld      a,c                             ;[dc59] 79
    cp      $50                             ;[dc5a] fe 50
    jr      z,$dc6b                         ;[dc5c] 28 0d
    push    bc                              ;[dc5e] c5
    ld      c,$20                           ;[dc5f] 0e 20
    call    $ffa0                           ;[dc61] cd a0 ff
    pop     bc                              ;[dc64] c1
    inc     c                               ;[dc65] 0c
    ld      a,c                             ;[dc66] 79
    cp      $50                             ;[dc67] fe 50
    jr      nz,$dc49                        ;[dc69] 20 de
    push    bc                              ;[dc6b] c5
    ld      c,$0d                           ;[dc6c] 0e 0d
    call    $ffa0                           ;[dc6e] cd a0 ff
    ld      c,$0a                           ;[dc71] 0e 0a
    call    $ffa0                           ;[dc73] cd a0 ff
    pop     bc                              ;[dc76] c1
    inc     b                               ;[dc77] 04
    ld      a,b                             ;[dc78] 78
    cp      $18                             ;[dc79] fe 18
    jr      nz,$dc47                        ;[dc7b] 20 ca
    xor     a                               ;[dc7d] af
    ret                                     ;[dc7e] c9

    call    $cdd7                           ;[dc7f] cd d7 cd
    ld      a,c                             ;[dc82] 79
    and     $0f                             ;[dc83] e6 0f
    rlca                                    ;[dc85] 07
    rlca                                    ;[dc86] 07
    rlca                                    ;[dc87] 07
    rlca                                    ;[dc88] 07
    ld      b,a                             ;[dc89] 47
    ld      a,($ffd1)                       ;[dc8a] 3a d1 ff
    and     $0f                             ;[dc8d] e6 0f
    or      b                               ;[dc8f] b0
    ld      ($ffd1),a                       ;[dc90] 32 d1 ff
    xor     a                               ;[dc93] af
    ret                                     ;[dc94] c9

    call    $cdd7                           ;[dc95] cd d7 cd
    ld      a,c                             ;[dc98] 79
    cp      $30                             ;[dc99] fe 30
    jr      z,$dcab                         ;[dc9b] 28 0e
    cp      $31                             ;[dc9d] fe 31
    jr      z,$dcbd                         ;[dc9f] 28 1c
    cp      $32                             ;[dca1] fe 32
    jr      z,$dcdf                         ;[dca3] 28 3a
    cp      $33                             ;[dca5] fe 33
    jr      z,$dcf4                         ;[dca7] 28 4b
    xor     a                               ;[dca9] af
    ret                                     ;[dcaa] c9

    ld      a,($ffcb)                       ;[dcab] 3a cb ff
    ld      b,a                             ;[dcae] 47
    ld      d,a                             ;[dcaf] 57
    ld      a,($ffca)                       ;[dcb0] 3a ca ff
    ld      c,a                             ;[dcb3] 4f
    ld      a,($ffcf)                       ;[dcb4] 3a cf ff
    ld      e,a                             ;[dcb7] 5f
    call    $c805                           ;[dcb8] cd 05 c8
    xor     a                               ;[dcbb] af
    ret                                     ;[dcbc] c9

    ld      a,($ffce)                       ;[dcbd] 3a ce ff
    ld      b,a                             ;[dcc0] 47
    ld      a,($ffcb)                       ;[dcc1] 3a cb ff
    ld      ($ffce),a                       ;[dcc4] 32 ce ff
    ld      a,($ffc9)                       ;[dcc7] 3a c9 ff
    ld      c,a                             ;[dcca] 4f
    ld      a,$01                           ;[dccb] 3e 01
    ld      ($ffc9),a                       ;[dccd] 32 c9 ff
    push    bc                              ;[dcd0] c5
    call    $c62e                           ;[dcd1] cd 2e c6
    pop     bc                              ;[dcd4] c1
    ld      a,b                             ;[dcd5] 78
    ld      ($ffce),a                       ;[dcd6] 32 ce ff
    ld      a,c                             ;[dcd9] 79
    ld      ($ffc9),a                       ;[dcda] 32 c9 ff
    xor     a                               ;[dcdd] af
    ret                                     ;[dcde] c9

    ld      a,($ffcb)                       ;[dcdf] 3a cb ff
    ld      b,a                             ;[dce2] 47
    ld      a,($ffca)                       ;[dce3] 3a ca ff
    ld      c,a                             ;[dce6] 4f
    ld      a,($ffcd)                       ;[dce7] 3a cd ff
    ld      d,a                             ;[dcea] 57
    ld      a,($ffcf)                       ;[dceb] 3a cf ff
    ld      e,a                             ;[dcee] 5f
    call    $c805                           ;[dcef] cd 05 c8
    xor     a                               ;[dcf2] af
    ret                                     ;[dcf3] c9

    ld      a,($ffce)                       ;[dcf4] 3a ce ff
    ld      b,a                             ;[dcf7] 47
    ld      a,($ffcb)                       ;[dcf8] 3a cb ff
    ld      c,a                             ;[dcfb] 4f
    ld      a,($ffcd)                       ;[dcfc] 3a cd ff
    cp      c                               ;[dcff] b9
    jr      z,$dd18                         ;[dd00] 28 16
    ld      a,c                             ;[dd02] 79
    ld      ($ffce),a                       ;[dd03] 32 ce ff
    push    bc                              ;[dd06] c5
    call    $c830                           ;[dd07] cd 30 c8
    pop     bc                              ;[dd0a] c1
    ld      a,b                             ;[dd0b] 78
    ld      ($ffce),a                       ;[dd0c] 32 ce ff
    ld      a,($ffd0)                       ;[dd0f] 3a d0 ff
    ld      c,a                             ;[dd12] 4f
    call    $cb9f                           ;[dd13] cd 9f cb
    xor     a                               ;[dd16] af
    ret                                     ;[dd17] c9

    ld      b,a                             ;[dd18] 47
    ld      d,a                             ;[dd19] 57
    ld      a,($ffcf)                       ;[dd1a] 3a cf ff
    ld      e,a                             ;[dd1d] 5f
    ld      a,($ffd0)                       ;[dd1e] 3a d0 ff
    ld      c,a                             ;[dd21] 4f
    call    $c805                           ;[dd22] cd 05 c8
    jr      $dd0f                           ;[dd25] 18 e8
    call    $cdd7                           ;[dd27] cd d7 cd
    cp      $02                             ;[dd2a] fe 02
    jp      nc,$cd8a                        ;[dd2c] d2 8a cd
    ld      a,c                             ;[dd2f] 79
    cp      $30                             ;[dd30] fe 30
    jr      z,$dd42                         ;[dd32] 28 0e
    cp      $31                             ;[dd34] fe 31
    jr      z,$dd46                         ;[dd36] 28 0e
    cp      $34                             ;[dd38] fe 34
    jr      z,$dd51                         ;[dd3a] 28 15
    cp      $35                             ;[dd3c] fe 35
    jr      z,$dd8a                         ;[dd3e] 28 4a
    xor     a                               ;[dd40] af
    ret                                     ;[dd41] c9

    ld      b,$19                           ;[dd42] 06 19
    jr      $dd48                           ;[dd44] 18 02
    ld      b,$18                           ;[dd46] 06 18
    ld      a,$06                           ;[dd48] 3e 06
    out     ($a0),a                         ;[dd4a] d3 a0
    ld      a,b                             ;[dd4c] 78
    out     ($a1),a                         ;[dd4d] d3 a1
    xor     a                               ;[dd4f] af
    ret                                     ;[dd50] c9

    ld      hl,($bff4)                      ;[dd51] 2a f4 bf
    ex      de,hl                           ;[dd54] eb
    ld      b,$18                           ;[dd55] 06 18
    ld      c,$00                           ;[dd57] 0e 00
    call    $c6f1                           ;[dd59] cd f1 c6
    ld      a,($bfea)                       ;[dd5c] 3a ea bf
    ld      c,a                             ;[dd5f] 4f
    ld      b,$46                           ;[dd60] 06 46
    ld      a,b                             ;[dd62] 78
    ld      ($ffda),a                       ;[dd63] 32 da ff
    call    $c715                           ;[dd66] cd 15 c7
    ld      a,(de)                          ;[dd69] 1a
    ld      (hl),a                          ;[dd6a] 77
    call    $c795                           ;[dd6b] cd 95 c7
    ld      (hl),c                          ;[dd6e] 71
    call    $c79e                           ;[dd6f] cd 9e c7
    inc     de                              ;[dd72] 13
    inc     hl                              ;[dd73] 23
    djnz    $dd66                           ;[dd74] 10 f0
    ld      a,($ffda)                       ;[dd76] 3a da ff
    or      a                               ;[dd79] b7
    jr      z,$dd88                         ;[dd7a] 28 0c
    ld      b,$0a                           ;[dd7c] 06 0a
    ld      a,($bfeb)                       ;[dd7e] 3a eb bf
    ld      c,a                             ;[dd81] 4f
    xor     a                               ;[dd82] af
    ld      ($ffda),a                       ;[dd83] 32 da ff
    jr      $dd66                           ;[dd86] 18 de
    xor     a                               ;[dd88] af
    ret                                     ;[dd89] c9

    ld      a,c                             ;[dd8a] 79
    cp      $0d                             ;[dd8b] fe 0d
    jr      z,$ddb5                         ;[dd8d] 28 26
    ld      a,($ffd9)                       ;[dd8f] 3a d9 ff
    cp      $01                             ;[dd92] fe 01
    jr      z,$dd9a                         ;[dd94] 28 04
    call    $cdb7                           ;[dd96] cd b7 cd
    ret                                     ;[dd99] c9

    ld      b,$18                           ;[dd9a] 06 18
    ld      c,$00                           ;[dd9c] 0e 00
    call    $c6f1                           ;[dd9e] cd f1 c6
    ld      ($ffda),hl                      ;[dda1] 22 da ff
    ld      a,$02                           ;[dda4] 3e 02
    ld      ($ffd9),a                       ;[dda6] 32 d9 ff
    ld      b,$46                           ;[dda9] 06 46
    ld      c,$20                           ;[ddab] 0e 20
    call    $c715                           ;[ddad] cd 15 c7
    ld      (hl),c                          ;[ddb0] 71
    inc     hl                              ;[ddb1] 23
    djnz    $ddad                           ;[ddb2] 10 f9
    ret                                     ;[ddb4] c9

    xor     a                               ;[ddb5] af
    ret                                     ;[ddb6] c9

    ld      b,a                             ;[ddb7] 47
    inc     a                               ;[ddb8] 3c
    ld      ($ffd9),a                       ;[ddb9] 32 d9 ff
    ld      hl,($ffda)                      ;[ddbc] 2a da ff
    call    $c715                           ;[ddbf] cd 15 c7
    ld      (hl),c                          ;[ddc2] 71
    ld      a,($bfeb)                       ;[ddc3] 3a eb bf
    call    $c795                           ;[ddc6] cd 95 c7
    ld      (hl),a                          ;[ddc9] 77
    call    $c79e                           ;[ddca] cd 9e c7
    inc     hl                              ;[ddcd] 23
    ld      ($ffda),hl                      ;[ddce] 22 da ff
    ld      a,b                             ;[ddd1] 78
    cp      $47                             ;[ddd2] fe 47
    ret     nz                              ;[ddd4] c0
    xor     a                               ;[ddd5] af
    ret                                     ;[ddd6] c9

    ld      a,($ffd9)                       ;[ddd7] 3a d9 ff
    or      a                               ;[ddda] b7
    ret     nz                              ;[dddb] c0
    inc     a                               ;[dddc] 3c
    ld      ($ffd9),a                       ;[dddd] 32 d9 ff
    pop     hl                              ;[dde0] e1
    ret                                     ;[dde1] c9

    call    $c69a                           ;[dde2] cd 9a c6
    call    $c6f1                           ;[dde5] cd f1 c6
    call    $c715                           ;[dde8] cd 15 c7
    ld      (hl),d                          ;[ddeb] 72
    call    $c795                           ;[ddec] cd 95 c7
    ld      (hl),e                          ;[ddef] 73
    call    $c79e                           ;[ddf0] cd 9e c7
    ret                                     ;[ddf3] c9

    call    $c69a                           ;[ddf4] cd 9a c6
    call    $c6f1                           ;[ddf7] cd f1 c6
    call    $c715                           ;[ddfa] cd 15 c7
    ld      d,(hl)                          ;[ddfd] 56
    call    $c795                           ;[ddfe] cd 95 c7
    ld      e,(hl)                          ;[de01] 5e
    call    $c79e                           ;[de02] cd 9e c7
    ret                                     ;[de05] c9

    nop                                     ;[de06] 00
    nop                                     ;[de07] 00
    nop                                     ;[de08] 00
    nop                                     ;[de09] 00
    nop                                     ;[de0a] 00
    nop                                     ;[de0b] 00
    nop                                     ;[de0c] 00
    nop                                     ;[de0d] 00
    nop                                     ;[de0e] 00
    nop                                     ;[de0f] 00
    nop                                     ;[de10] 00
    nop                                     ;[de11] 00
    nop                                     ;[de12] 00
    nop                                     ;[de13] 00
    nop                                     ;[de14] 00
    nop                                     ;[de15] 00
    nop                                     ;[de16] 00
    nop                                     ;[de17] 00
    nop                                     ;[de18] 00
    nop                                     ;[de19] 00
    nop                                     ;[de1a] 00
    nop                                     ;[de1b] 00
    nop                                     ;[de1c] 00
    nop                                     ;[de1d] 00
    nop                                     ;[de1e] 00
    nop                                     ;[de1f] 00
    nop                                     ;[de20] 00
    nop                                     ;[de21] 00
    nop                                     ;[de22] 00
    nop                                     ;[de23] 00
    nop                                     ;[de24] 00
    nop                                     ;[de25] 00
    nop                                     ;[de26] 00
    nop                                     ;[de27] 00
    nop                                     ;[de28] 00
    nop                                     ;[de29] 00
    nop                                     ;[de2a] 00
    nop                                     ;[de2b] 00
    nop                                     ;[de2c] 00
    nop                                     ;[de2d] 00
    nop                                     ;[de2e] 00
    nop                                     ;[de2f] 00
    nop                                     ;[de30] 00
    nop                                     ;[de31] 00
    nop                                     ;[de32] 00
    nop                                     ;[de33] 00
    nop                                     ;[de34] 00
    nop                                     ;[de35] 00
    nop                                     ;[de36] 00
    nop                                     ;[de37] 00
    nop                                     ;[de38] 00
    nop                                     ;[de39] 00
    nop                                     ;[de3a] 00
    nop                                     ;[de3b] 00
    nop                                     ;[de3c] 00
    nop                                     ;[de3d] 00
    nop                                     ;[de3e] 00
    nop                                     ;[de3f] 00
    nop                                     ;[de40] 00
    nop                                     ;[de41] 00
    nop                                     ;[de42] 00
    nop                                     ;[de43] 00
    nop                                     ;[de44] 00
    nop                                     ;[de45] 00
    nop                                     ;[de46] 00
    nop                                     ;[de47] 00
    nop                                     ;[de48] 00
    nop                                     ;[de49] 00
    nop                                     ;[de4a] 00
    nop                                     ;[de4b] 00
    nop                                     ;[de4c] 00
    nop                                     ;[de4d] 00
    nop                                     ;[de4e] 00
    nop                                     ;[de4f] 00
    nop                                     ;[de50] 00
    nop                                     ;[de51] 00
    nop                                     ;[de52] 00
    nop                                     ;[de53] 00
    nop                                     ;[de54] 00
    nop                                     ;[de55] 00
    nop                                     ;[de56] 00
    nop                                     ;[de57] 00
    nop                                     ;[de58] 00
    nop                                     ;[de59] 00
    nop                                     ;[de5a] 00
    nop                                     ;[de5b] 00
    nop                                     ;[de5c] 00
    nop                                     ;[de5d] 00
    nop                                     ;[de5e] 00
    nop                                     ;[de5f] 00
    nop                                     ;[de60] 00
    nop                                     ;[de61] 00
    nop                                     ;[de62] 00
    nop                                     ;[de63] 00
    nop                                     ;[de64] 00
    nop                                     ;[de65] 00
    nop                                     ;[de66] 00
    nop                                     ;[de67] 00
    nop                                     ;[de68] 00
    nop                                     ;[de69] 00
    nop                                     ;[de6a] 00
    nop                                     ;[de6b] 00
    nop                                     ;[de6c] 00
    nop                                     ;[de6d] 00
    nop                                     ;[de6e] 00
    nop                                     ;[de6f] 00
    nop                                     ;[de70] 00
    nop                                     ;[de71] 00
    nop                                     ;[de72] 00
    nop                                     ;[de73] 00
    nop                                     ;[de74] 00
    nop                                     ;[de75] 00
    nop                                     ;[de76] 00
    nop                                     ;[de77] 00
    nop                                     ;[de78] 00
    nop                                     ;[de79] 00
    nop                                     ;[de7a] 00
    nop                                     ;[de7b] 00
    nop                                     ;[de7c] 00
    nop                                     ;[de7d] 00
    nop                                     ;[de7e] 00
    nop                                     ;[de7f] 00
    nop                                     ;[de80] 00
    nop                                     ;[de81] 00
    nop                                     ;[de82] 00
    nop                                     ;[de83] 00
    nop                                     ;[de84] 00
    nop                                     ;[de85] 00
    nop                                     ;[de86] 00
    nop                                     ;[de87] 00
    nop                                     ;[de88] 00
    nop                                     ;[de89] 00
    nop                                     ;[de8a] 00
    nop                                     ;[de8b] 00
    nop                                     ;[de8c] 00
    nop                                     ;[de8d] 00
    nop                                     ;[de8e] 00
    nop                                     ;[de8f] 00
    nop                                     ;[de90] 00
    nop                                     ;[de91] 00
    nop                                     ;[de92] 00
    nop                                     ;[de93] 00
    nop                                     ;[de94] 00
    nop                                     ;[de95] 00
    nop                                     ;[de96] 00
    nop                                     ;[de97] 00
    nop                                     ;[de98] 00
    nop                                     ;[de99] 00
    nop                                     ;[de9a] 00
    nop                                     ;[de9b] 00
    nop                                     ;[de9c] 00
    nop                                     ;[de9d] 00
    nop                                     ;[de9e] 00
    nop                                     ;[de9f] 00
    nop                                     ;[dea0] 00
    nop                                     ;[dea1] 00
    nop                                     ;[dea2] 00
    nop                                     ;[dea3] 00
    nop                                     ;[dea4] 00
    nop                                     ;[dea5] 00
    nop                                     ;[dea6] 00
    nop                                     ;[dea7] 00
    nop                                     ;[dea8] 00
    nop                                     ;[dea9] 00
    nop                                     ;[deaa] 00
    nop                                     ;[deab] 00
    nop                                     ;[deac] 00
    nop                                     ;[dead] 00
    nop                                     ;[deae] 00
    nop                                     ;[deaf] 00
    nop                                     ;[deb0] 00
    nop                                     ;[deb1] 00
    nop                                     ;[deb2] 00
    nop                                     ;[deb3] 00
    nop                                     ;[deb4] 00
    nop                                     ;[deb5] 00
    nop                                     ;[deb6] 00
    nop                                     ;[deb7] 00
    nop                                     ;[deb8] 00
    nop                                     ;[deb9] 00
    nop                                     ;[deba] 00
    nop                                     ;[debb] 00
    nop                                     ;[debc] 00
    nop                                     ;[debd] 00
    nop                                     ;[debe] 00
    nop                                     ;[debf] 00
    nop                                     ;[dec0] 00
    nop                                     ;[dec1] 00
    nop                                     ;[dec2] 00
    nop                                     ;[dec3] 00
    nop                                     ;[dec4] 00
    nop                                     ;[dec5] 00
    nop                                     ;[dec6] 00
    nop                                     ;[dec7] 00
    nop                                     ;[dec8] 00
    nop                                     ;[dec9] 00
    nop                                     ;[deca] 00
    nop                                     ;[decb] 00
    nop                                     ;[decc] 00
    nop                                     ;[decd] 00
    nop                                     ;[dece] 00
    nop                                     ;[decf] 00
    nop                                     ;[ded0] 00
    nop                                     ;[ded1] 00
    nop                                     ;[ded2] 00
    nop                                     ;[ded3] 00
    nop                                     ;[ded4] 00
    nop                                     ;[ded5] 00
    nop                                     ;[ded6] 00
    nop                                     ;[ded7] 00
    nop                                     ;[ded8] 00
    nop                                     ;[ded9] 00
    nop                                     ;[deda] 00
    nop                                     ;[dedb] 00
    nop                                     ;[dedc] 00
    nop                                     ;[dedd] 00
    nop                                     ;[dede] 00
    nop                                     ;[dedf] 00
    nop                                     ;[dee0] 00
    nop                                     ;[dee1] 00
    nop                                     ;[dee2] 00
    nop                                     ;[dee3] 00
    nop                                     ;[dee4] 00
    nop                                     ;[dee5] 00
    nop                                     ;[dee6] 00
    nop                                     ;[dee7] 00
    nop                                     ;[dee8] 00
    nop                                     ;[dee9] 00
    nop                                     ;[deea] 00
    nop                                     ;[deeb] 00
    nop                                     ;[deec] 00
    nop                                     ;[deed] 00
    nop                                     ;[deee] 00
    nop                                     ;[deef] 00
    nop                                     ;[def0] 00
    nop                                     ;[def1] 00
    nop                                     ;[def2] 00
    nop                                     ;[def3] 00
    nop                                     ;[def4] 00
    nop                                     ;[def5] 00
    nop                                     ;[def6] 00
    nop                                     ;[def7] 00
    nop                                     ;[def8] 00
    nop                                     ;[def9] 00
    nop                                     ;[defa] 00
    nop                                     ;[defb] 00
    nop                                     ;[defc] 00
    nop                                     ;[defd] 00
    nop                                     ;[defe] 00
    nop                                     ;[deff] 00
    nop                                     ;[df00] 00
    nop                                     ;[df01] 00
    nop                                     ;[df02] 00
    nop                                     ;[df03] 00
    nop                                     ;[df04] 00
    nop                                     ;[df05] 00
    nop                                     ;[df06] 00
    nop                                     ;[df07] 00
    nop                                     ;[df08] 00
    nop                                     ;[df09] 00
    nop                                     ;[df0a] 00
    nop                                     ;[df0b] 00
    nop                                     ;[df0c] 00
    nop                                     ;[df0d] 00
    nop                                     ;[df0e] 00
    nop                                     ;[df0f] 00
    nop                                     ;[df10] 00
    nop                                     ;[df11] 00
    nop                                     ;[df12] 00
    nop                                     ;[df13] 00
    nop                                     ;[df14] 00
    nop                                     ;[df15] 00
    nop                                     ;[df16] 00
    nop                                     ;[df17] 00
    nop                                     ;[df18] 00
    nop                                     ;[df19] 00
    nop                                     ;[df1a] 00
    nop                                     ;[df1b] 00
    nop                                     ;[df1c] 00
    nop                                     ;[df1d] 00
    nop                                     ;[df1e] 00
    nop                                     ;[df1f] 00
    nop                                     ;[df20] 00
    nop                                     ;[df21] 00
    nop                                     ;[df22] 00
    nop                                     ;[df23] 00
    nop                                     ;[df24] 00
    nop                                     ;[df25] 00
    nop                                     ;[df26] 00
    nop                                     ;[df27] 00
    nop                                     ;[df28] 00
    nop                                     ;[df29] 00
    nop                                     ;[df2a] 00
    nop                                     ;[df2b] 00
    nop                                     ;[df2c] 00
    nop                                     ;[df2d] 00
    nop                                     ;[df2e] 00
    nop                                     ;[df2f] 00
    nop                                     ;[df30] 00
    nop                                     ;[df31] 00
    nop                                     ;[df32] 00
    nop                                     ;[df33] 00
    nop                                     ;[df34] 00
    nop                                     ;[df35] 00
    nop                                     ;[df36] 00
    nop                                     ;[df37] 00
    nop                                     ;[df38] 00
    nop                                     ;[df39] 00
    nop                                     ;[df3a] 00
    nop                                     ;[df3b] 00
    nop                                     ;[df3c] 00
    nop                                     ;[df3d] 00
    nop                                     ;[df3e] 00
    nop                                     ;[df3f] 00
    nop                                     ;[df40] 00
    nop                                     ;[df41] 00
    nop                                     ;[df42] 00
    nop                                     ;[df43] 00
    nop                                     ;[df44] 00
    nop                                     ;[df45] 00
    nop                                     ;[df46] 00
    nop                                     ;[df47] 00
    nop                                     ;[df48] 00
    nop                                     ;[df49] 00
    nop                                     ;[df4a] 00
    nop                                     ;[df4b] 00
    nop                                     ;[df4c] 00
    nop                                     ;[df4d] 00
    nop                                     ;[df4e] 00
    nop                                     ;[df4f] 00
    nop                                     ;[df50] 00
    nop                                     ;[df51] 00
    nop                                     ;[df52] 00
    nop                                     ;[df53] 00
    nop                                     ;[df54] 00
    nop                                     ;[df55] 00
    nop                                     ;[df56] 00
    nop                                     ;[df57] 00
    nop                                     ;[df58] 00
    nop                                     ;[df59] 00
    nop                                     ;[df5a] 00
    nop                                     ;[df5b] 00
    nop                                     ;[df5c] 00
    nop                                     ;[df5d] 00
    nop                                     ;[df5e] 00
    nop                                     ;[df5f] 00
    nop                                     ;[df60] 00
    nop                                     ;[df61] 00
    nop                                     ;[df62] 00
    nop                                     ;[df63] 00
    nop                                     ;[df64] 00
    nop                                     ;[df65] 00
    nop                                     ;[df66] 00
    nop                                     ;[df67] 00
    nop                                     ;[df68] 00
    nop                                     ;[df69] 00
    nop                                     ;[df6a] 00
    nop                                     ;[df6b] 00
    nop                                     ;[df6c] 00
    nop                                     ;[df6d] 00
    nop                                     ;[df6e] 00
    nop                                     ;[df6f] 00
    nop                                     ;[df70] 00
    nop                                     ;[df71] 00
    nop                                     ;[df72] 00
    nop                                     ;[df73] 00
    nop                                     ;[df74] 00
    nop                                     ;[df75] 00
    nop                                     ;[df76] 00
    nop                                     ;[df77] 00
    nop                                     ;[df78] 00
    nop                                     ;[df79] 00
    nop                                     ;[df7a] 00
    nop                                     ;[df7b] 00
    nop                                     ;[df7c] 00
    nop                                     ;[df7d] 00
    nop                                     ;[df7e] 00
    nop                                     ;[df7f] 00
    nop                                     ;[df80] 00
    nop                                     ;[df81] 00
    nop                                     ;[df82] 00
    nop                                     ;[df83] 00
    nop                                     ;[df84] 00
    nop                                     ;[df85] 00
    nop                                     ;[df86] 00
    nop                                     ;[df87] 00
    nop                                     ;[df88] 00
    nop                                     ;[df89] 00
    nop                                     ;[df8a] 00
    nop                                     ;[df8b] 00
    nop                                     ;[df8c] 00
    nop                                     ;[df8d] 00
    nop                                     ;[df8e] 00
    nop                                     ;[df8f] 00
    nop                                     ;[df90] 00
    nop                                     ;[df91] 00
    nop                                     ;[df92] 00
    nop                                     ;[df93] 00
    nop                                     ;[df94] 00
    nop                                     ;[df95] 00
    nop                                     ;[df96] 00
    nop                                     ;[df97] 00
    nop                                     ;[df98] 00
    nop                                     ;[df99] 00
    nop                                     ;[df9a] 00
    nop                                     ;[df9b] 00
    nop                                     ;[df9c] 00
    nop                                     ;[df9d] 00
    nop                                     ;[df9e] 00
    nop                                     ;[df9f] 00
    nop                                     ;[dfa0] 00
    nop                                     ;[dfa1] 00
    nop                                     ;[dfa2] 00
    nop                                     ;[dfa3] 00
    nop                                     ;[dfa4] 00
    nop                                     ;[dfa5] 00
    nop                                     ;[dfa6] 00
    nop                                     ;[dfa7] 00
    nop                                     ;[dfa8] 00
    nop                                     ;[dfa9] 00
    nop                                     ;[dfaa] 00
    nop                                     ;[dfab] 00
    nop                                     ;[dfac] 00
    nop                                     ;[dfad] 00
    nop                                     ;[dfae] 00
    nop                                     ;[dfaf] 00
    nop                                     ;[dfb0] 00
    nop                                     ;[dfb1] 00
    nop                                     ;[dfb2] 00
    nop                                     ;[dfb3] 00
    nop                                     ;[dfb4] 00
    nop                                     ;[dfb5] 00
    nop                                     ;[dfb6] 00
    nop                                     ;[dfb7] 00
    nop                                     ;[dfb8] 00
    nop                                     ;[dfb9] 00
    nop                                     ;[dfba] 00
    nop                                     ;[dfbb] 00
    nop                                     ;[dfbc] 00
    nop                                     ;[dfbd] 00
    nop                                     ;[dfbe] 00
    nop                                     ;[dfbf] 00
    nop                                     ;[dfc0] 00
    nop                                     ;[dfc1] 00
    nop                                     ;[dfc2] 00
    nop                                     ;[dfc3] 00
    nop                                     ;[dfc4] 00
    nop                                     ;[dfc5] 00
    nop                                     ;[dfc6] 00
    nop                                     ;[dfc7] 00
    nop                                     ;[dfc8] 00
    nop                                     ;[dfc9] 00
    nop                                     ;[dfca] 00
    nop                                     ;[dfcb] 00
    nop                                     ;[dfcc] 00
    nop                                     ;[dfcd] 00
    nop                                     ;[dfce] 00
    nop                                     ;[dfcf] 00
    nop                                     ;[dfd0] 00
    nop                                     ;[dfd1] 00
    nop                                     ;[dfd2] 00
    nop                                     ;[dfd3] 00
    nop                                     ;[dfd4] 00
    nop                                     ;[dfd5] 00
    nop                                     ;[dfd6] 00
    nop                                     ;[dfd7] 00
    nop                                     ;[dfd8] 00
    nop                                     ;[dfd9] 00
    nop                                     ;[dfda] 00
    nop                                     ;[dfdb] 00
    nop                                     ;[dfdc] 00
    nop                                     ;[dfdd] 00
    nop                                     ;[dfde] 00
    nop                                     ;[dfdf] 00
    nop                                     ;[dfe0] 00
    nop                                     ;[dfe1] 00
    nop                                     ;[dfe2] 00
    nop                                     ;[dfe3] 00
    nop                                     ;[dfe4] 00
    nop                                     ;[dfe5] 00
    nop                                     ;[dfe6] 00
    nop                                     ;[dfe7] 00
    nop                                     ;[dfe8] 00
    nop                                     ;[dfe9] 00
    nop                                     ;[dfea] 00
    nop                                     ;[dfeb] 00
    nop                                     ;[dfec] 00
    nop                                     ;[dfed] 00
    nop                                     ;[dfee] 00
    nop                                     ;[dfef] 00
    nop                                     ;[dff0] 00
    nop                                     ;[dff1] 00
    nop                                     ;[dff2] 00
    nop                                     ;[dff3] 00
    nop                                     ;[dff4] 00
    nop                                     ;[dff5] 00
    nop                                     ;[dff6] 00
    nop                                     ;[dff7] 00
    nop                                     ;[dff8] 00
    nop                                     ;[dff9] 00
    nop                                     ;[dffa] 00
    nop                                     ;[dffb] 00
    ld      sp,$302e                        ;[dffc] 31 2e 30
    rst     $38                             ;[dfff] ff
