; z80dasm 1.1.5
; command line: z80dasm -g 0xc000 -t /home/giomba/Retrofficina/Sanco/ROM/V1.01_ROM.bin

	org	0c000h

	jp 0c030h		;c000	c3 30 c0 	. 0 .
	jp 0c027h		;c003	c3 27 c0 	. ' .
	jp 0c027h		;c006	c3 27 c0 	. ' .
	jp 0c45eh		;c009	c3 5e c4 	. ^ .
	jp 0c027h		;c00c	c3 27 c0 	. ' .
	jp 0c027h		;c00f	c3 27 c0 	. ' .
	jp 0c027h		;c012	c3 27 c0 	. ' .
	jp 0c027h		;c015	c3 27 c0 	. ' .
	jp 0c19dh		;c018	c3 9d c1 	. . .
	jp 0c18fh		;c01b	c3 8f c1 	. . .
	jp 0c174h		;c01e	c3 74 c1 	. t .
	jp 0cde2h		;c021	c3 e2 cd 	. . .
	jp 0cdf4h		;c024	c3 f4 cd 	. . .
	di			;c027	f3 	.
	ld a,010h		;c028	3e 10 	> .
	out (0b1h),a		;c02a	d3 b1 	. .
	out (0b3h),a		;c02c	d3 b3 	. .
	jr $+18		;c02e	18 10 	. .


	ld a,089h		;c030	3e 89 	> .
	out (083h),a		;c032	d3 83 	. .

	di			;c034	f3 	.

	; some delay
	ld a,010h		;c035	3e 10 	> .
	out (081h),a		;c037	d3 81 	. .

	; delay
	; load hl with 0x7d
	ld h,07dh		;c039	26 7d 	& }
	dec hl			;c03b	2b 	+
	ld a,h			;c03c	7c 	|
	or l			;c03d	b5 	.
	jr nz,$-3		;c03e	20 fb 	  .

	; initialize stack pointer
	ld sp,00080h		;c040	31 80 00 	1 . .

	; call C0C2
	call 0c0c2h		;c043	cd c2 c0 	. . .

	call 0c6afh		;c046	cd af c6 	. . .
	call 0c14eh		;c049	cd 4e c1 	. N .
	ld a,012h		;c04c	3e 12 	> .
	out (0b2h),a		;c04e	d3 b2 	. .
	in a,(0b3h)		;c050	db b3 	. .
	bit 0,a		;c052	cb 47 	. G
	jr z,$-4		;c054	28 fa 	( .
	in a,(0b2h)		;c056	db b2 	. .
	out (0dah),a		;c058	d3 da 	. .
	ld c,056h		;c05a	0e 56 	. V
	call 0c45eh		;c05c	cd 5e c4 	. ^ .
	ld hl,0cffch		;c05f	21 fc cf 	! . .
	ld b,004h		;c062	06 04 	. .
	ld c,(hl)			;c064	4e 	N
	inc hl			;c065	23 	#
	call 0c45eh		;c066	cd 5e c4 	. ^ .
	djnz $-5		;c069	10 f9 	. .
	call 0c0a7h		;c06b	cd a7 c0 	. . .
	ld a,b			;c06e	78 	x
	cp 04dh		;c06f	fe 4d 	. M
	jr z,$+23		;c071	28 15 	( .
	cp 05ch		;c073	fe 5c 	. \
	jr nz,$-10		;c075	20 f4 	  .
	ld a,(08000h)		;c077	3a 00 80 	: . .
	cpl			;c07a	2f 	/
	ld (08000h),a		;c07b	32 00 80 	2 . .
	ld a,(08000h)		;c07e	3a 00 80 	: . .
	cp 0c3h		;c081	fe c3 	. .
	jr nz,$-92		;c083	20 a2 	  .
	jp 08000h		;c085	c3 00 80 	. . .
	ld de,00000h		;c088	11 00 00 	. . .
	ld bc,04000h		;c08b	01 00 40 	. . @
	ld hl,00080h		;c08e	21 80 00 	! . .
	ld a,001h		;c091	3e 01 	> .
	call 0c19dh		;c093	cd 9d c1 	. . .
	cp 0ffh		;c096	fe ff 	. .
	jr nz,$+6		;c098	20 04 	  .
	out (0dah),a		;c09a	d3 da 	. .
	jr $-20		;c09c	18 ea 	. .
	ld a,006h		;c09e	3e 06 	> .
	out (0b2h),a		;c0a0	d3 b2 	. .
	out (0dah),a		;c0a2	d3 da 	. .
	jp 00080h		;c0a4	c3 80 00 	. . .
	in a,(0b3h)		;c0a7	db b3 	. .
	bit 0,a		;c0a9	cb 47 	. G
	jr z,$-4		;c0ab	28 fa 	( .
	in a,(0b2h)		;c0ad	db b2 	. .
	ld b,a			;c0af	47 	G
	bit 7,a		;c0b0	cb 7f 	. 
	jr nz,$-11		;c0b2	20 f3 	  .
	in a,(0b3h)		;c0b4	db b3 	. .
	bit 0,a		;c0b6	cb 47 	. G
	jr z,$-4		;c0b8	28 fa 	( .
	in a,(0b2h)		;c0ba	db b2 	. .
	ld c,a			;c0bc	4f 	O
	bit 7,a		;c0bd	cb 7f 	. 
	jr z,$-11		;c0bf	28 f3 	( .
	ret			;c0c1	c9 	.

	; FUNCTION C0C2
	im 2			;c0c2	; set interrupt mode 2
	call 0c0d1h		;c0c4	; initialize something in I/O
	call 0c43fh		;c0c7
	call 0c108h		;c0ca
	call 0c88dh		;c0cd
	ret				;c0d0

	; FUNCTION C0D1	; initialize timer (base ioaddr(0xE0))
	ld hl,0c0f1h	;c0d1	; table [ {ioaddr, data}, ... ]
	ld a,(hl)		;c0d4
	inc hl			;c0d5
	cp 0ffh			;c0d6	; check for end of table
	jr z,$+9		;c0d8	; if table is ended, go on
	ld c,a			;c0da
	ld a,(hl)		;c0db
	inc hl			;c0dc
	out (c),a		;c0dd
	jr $-11			;c0df

	in a,(0d6h)		;c0e1	; read index (gives 6)
	and 007h		;c0e3
	ld d,000h		;c0e5
	ld e,a			;c0e7
	add hl,de		;c0e8
	ld a,(hl)		;c0e9	; timer 1: time constant ("02")
	out (0e1h),a	;c0ea
	ld a,041h		;c0ec	; timer 1: select counter mode
	out (0e1h),a	;c0ee
	ret				;c0f0

	; STATIC DATA of C0D1
	; this table contains: [ { ioaddr, data }, ... ]
	; e2 05	; timer 2: configuration
	; e2 10	; timer 2: time constant
	; e2 41	; timer 2: select counter mode
	; e3 05	; timer 3: configuration
	; e3 01	; timer 3: time constant
	; e3 41	; timer 3: select counter mode
	; e1 05
	; ff

	; probably another table
	;c100	ae 	.
	;c101	40
	;c102	20
	;c103	10
	;c104	08 	.
	;c105	04
	;c106	02
	;c107	01

	; 21 34
	pop bc			;c10a	c1 	.
	ld a,(hl)			;c10b	7e 	~
	inc hl			;c10c	23 	#
	cp 0ffh		;c10d	fe ff 	. .
	jr z,$+10		;c10f	28 08 	( .
	out (0b1h),a		;c111	d3 b1 	. .
	ld a,(hl)			;c113	7e 	~
	out (0b1h),a		;c114	d3 b1 	. .
	inc hl			;c116	23 	#
	jr $-12		;c117	18 f2 	. .
	ld a,(hl)			;c119	7e 	~
	cp 0ffh		;c11a	fe ff 	. .
	jr z,$+11		;c11c	28 09 	( .
	out (0b3h),a		;c11e	d3 b3 	. .
	inc hl			;c120	23 	#
	ld a,(hl)			;c121	7e 	~
	out (0b3h),a		;c122	d3 b3 	. .
	inc hl			;c124	23 	#
	jr $-12		;c125	18 f2 	. .
	in a,(0b0h)		;c127	db b0 	. .
	in a,(0b2h)		;c129	db b2 	. .
	in a,(0b0h)		;c12b	db b0 	. .
	in a,(0b2h)		;c12d	db b2 	. .
	in a,(0b0h)		;c12f	db b0 	. .
	in a,(0b2h)		;c131	db b2 	. .
	ret			;c133	c9 	.
	nop			;c134	00 	.
	djnz $+2		;c135	10 00 	. .
	djnz $+6		;c137	10 04 	. .
	ld b,h			;c139	44 	D
	ld bc,00300h		;c13a	01 00 03 	. . .
	pop bc			;c13d	c1 	.
	dec b			;c13e	05 	.
	jp pe,000ffh		;c13f	ea ff 00 	. . .
	djnz $+2		;c142	10 00 	. .
	djnz $+6		;c144	10 04 	. .
	ld b,h			;c146	44 	D
	ld bc,00300h		;c147	01 00 03 	. . .
	pop bc			;c14a	c1 	.
	dec b			;c14b	05 	.
	jp pe,021ffh		;c14c	ea ff 21 	. . !
	ld h,l			;c14f	65 	e
	pop bc			;c150	c1 	.
	ld de,00010h		;c151	11 10 00 	. . .
	ld bc,0000fh		;c154	01 0f 00 	. . .
	ldir		;c157	ed b0 	. .
	ld hl,00000h		;c159	21 00 00 	! . .
	ld de,00000h		;c15c	11 00 00 	. . .
	ld bc,00000h		;c15f	01 00 00 	. . .
	jp 00010h		;c162	c3 10 00 	. . .
	in a,(081h)		;c165	db 81 	. .
	set 0,a		;c167	cb c7 	. .
	out (081h),a		;c169	d3 81 	. .
	ldir		;c16b	ed b0 	. .
	res 0,a		;c16d	cb 87 	. .
	out (081h),a		;c16f	d3 81 	. .
	out (0deh),a		;c171	d3 de 	. .
	ret			;c173	c9 	.
	push af			;c174	f5 	.
	rrca			;c175	0f 	.
	rrca			;c176	0f 	.
	rrca			;c177	0f 	.
	rrca			;c178	0f 	.
	and 00fh		;c179	e6 0f 	. .
	call 0c181h		;c17b	cd 81 c1 	. . .
	pop af			;c17e	f1 	.
	and 00fh		;c17f	e6 0f 	. .
	call 0c187h		;c181	cd 87 c1 	. . .
	jp 0c45eh		;c184	c3 5e c4 	. ^ .
	add a,090h		;c187	c6 90 	. .
	daa			;c189	27 	'
	adc a,040h		;c18a	ce 40 	. @
	daa			;c18c	27 	'
	ld c,a			;c18d	4f 	O
	ret			;c18e	c9 	.
	ex (sp),hl			;c18f	e3 	.
	ld a,(hl)			;c190	7e 	~
	inc hl			;c191	23 	#
	or a			;c192	b7 	.
	jr z,$+8		;c193	28 06 	( .
	ld c,a			;c195	4f 	O
	call 0c45eh		;c196	cd 5e c4 	. ^ .
	jr $-9		;c199	18 f5 	. .
	ex (sp),hl			;c19b	e3 	.
	ret			;c19c	c9 	.
	push bc			;c19d	c5 	.
	push de			;c19e	d5 	.
	push hl			;c19f	e5 	.
	ld (0ffb8h),a		;c1a0	32 b8 ff 	2 . .
	ld a,00ah		;c1a3	3e 0a 	> .
	ld (0ffbfh),a		;c1a5	32 bf ff 	2 . .
	ld (0ffb9h),bc		;c1a8	ed 43 b9 ff 	. C . .
	ld (0ffbbh),de		;c1ac	ed 53 bb ff 	. S . .
	ld (0ffbdh),hl		;c1b0	22 bd ff 	" . .
	call 0c423h		;c1b3	cd 23 c4 	. # .
	ld a,(0ffbah)		;c1b6	3a ba ff 	: . .
	and 0f0h		;c1b9	e6 f0 	. .
	jp z,0c1e6h		;c1bb	ca e6 c1 	. . .
	cp 040h		;c1be	fe 40 	. @
	jp z,0c1dch		;c1c0	ca dc c1 	. . .
	cp 080h		;c1c3	fe 80 	. .
	jp z,0c1d7h		;c1c5	ca d7 c1 	. . .
	cp 020h		;c1c8	fe 20 	.
	jp z,0c1e1h		;c1ca	ca e1 c1 	. . .
	cp 0f0h		;c1cd	fe f0 	. .
	jp z,0c1ebh		;c1cf	ca eb c1 	. . .
	ld a,0ffh		;c1d2	3e ff 	> .
	jp 0c1f0h		;c1d4	c3 f0 c1 	. . .
	call 0c1f4h		;c1d7	cd f4 c1 	. . .
	jr $+22		;c1da	18 14 	. .
	call 0c24ah		;c1dc	cd 4a c2 	. J .
	jr $+17		;c1df	18 0f 	. .
	call 0c3a9h		;c1e1	cd a9 c3 	. . .
	jr $+12		;c1e4	18 0a 	. .
	call 0c391h		;c1e6	cd 91 c3 	. . .
	jr $+7		;c1e9	18 05 	. .
	call 0c2e3h		;c1eb	cd e3 c2 	. . .
	jr $+2		;c1ee	18 00 	. .
	pop hl			;c1f0	e1 	.
	pop de			;c1f1	d1 	.
	pop bc			;c1f2	c1 	.
	ret			;c1f3	c9 	.
	call 0c3a9h		;c1f4	cd a9 c3 	. . .
	call 0c2b7h		;c1f7	cd b7 c2 	. . .
	push de			;c1fa	d5 	.
	call 0c41ch		;c1fb	cd 1c c4 	. . .
	ld c,0c5h		;c1fe	0e c5 	. .
	ld a,(0ffb8h)		;c200	3a b8 ff 	: . .
	or a			;c203	b7 	.
	jr nz,$+4		;c204	20 02 	  .
	res 6,c		;c206	cb b1 	. .
	call 0c415h		;c208	cd 15 c4 	. . .
	di			;c20b	f3 	.
	call 0c34eh		;c20c	cd 4e c3 	. N .
	pop de			;c20f	d1 	.
	ld c,0c1h		;c210	0e c1 	. .
	ld b,e			;c212	43 	C
	ld hl,(0ffbdh)		;c213	2a bd ff 	* . .
	in a,(082h)		;c216	db 82 	. .
	bit 2,a		;c218	cb 57 	. W
	jr z,$-4		;c21a	28 fa 	( .
	in a,(0c0h)		;c21c	db c0 	. .
	bit 5,a		;c21e	cb 6f 	. o
	jr z,$+9		;c220	28 07 	( .
	outi		;c222	ed a3 	. .
	jr nz,$-14		;c224	20 f0 	  .
	dec d			;c226	15 	.
	jr nz,$-17		;c227	20 ed 	  .
	out (0dch),a		;c229	d3 dc 	. .
	ei			;c22b	fb 	.
	call 0c3f4h		;c22c	cd f4 c3 	. . .
	ld a,(0ffc0h)		;c22f	3a c0 ff 	: . .
	and 0c0h		;c232	e6 c0 	. .
	cp 040h		;c234	fe 40 	. @
	jr nz,$+18		;c236	20 10 	  .
	call 0c2a0h		;c238	cd a0 c2 	. . .
	ld a,(0ffbfh)		;c23b	3a bf ff 	: . .
	dec a			;c23e	3d 	=
	ld (0ffbfh),a		;c23f	32 bf ff 	2 . .
	jp nz,0c1f7h		;c242	c2 f7 c1 	. . .
	ld a,0ffh		;c245	3e ff 	> .
	ret			;c247	c9 	.
	xor a			;c248	af 	.
	ret			;c249	c9 	.
	call 0c3a9h		;c24a	cd a9 c3 	. . .
	call 0c2b7h		;c24d	cd b7 c2 	. . .
	push de			;c250	d5 	.
	call 0c41ch		;c251	cd 1c c4 	. . .
	ld c,0c6h		;c254	0e c6 	. .
	ld a,(0ffb8h)		;c256	3a b8 ff 	: . .
	or a			;c259	b7 	.
	jr nz,$+4		;c25a	20 02 	  .
	res 6,c		;c25c	cb b1 	. .
	call 0c415h		;c25e	cd 15 c4 	. . .
	di			;c261	f3 	.
	call 0c34eh		;c262	cd 4e c3 	. N .
	pop de			;c265	d1 	.
	ld c,0c1h		;c266	0e c1 	. .
	ld b,e			;c268	43 	C
	ld hl,(0ffbdh)		;c269	2a bd ff 	* . .
	in a,(082h)		;c26c	db 82 	. .
	bit 2,a		;c26e	cb 57 	. W
	jr z,$-4		;c270	28 fa 	( .
	in a,(0c0h)		;c272	db c0 	. .
	bit 5,a		;c274	cb 6f 	. o
	jr z,$+9		;c276	28 07 	( .
	ini		;c278	ed a2 	. .
	jr nz,$-14		;c27a	20 f0 	  .
	dec d			;c27c	15 	.
	jr nz,$-17		;c27d	20 ed 	  .
	out (0dch),a		;c27f	d3 dc 	. .
	ei			;c281	fb 	.
	call 0c3f4h		;c282	cd f4 c3 	. . .
	ld a,(0ffc0h)		;c285	3a c0 ff 	: . .
	and 0c0h		;c288	e6 c0 	. .
	cp 040h		;c28a	fe 40 	. @
	jr nz,$+18		;c28c	20 10 	  .
	call 0c2a0h		;c28e	cd a0 c2 	. . .
	ld a,(0ffbfh)		;c291	3a bf ff 	: . .
	dec a			;c294	3d 	=
	ld (0ffbfh),a		;c295	32 bf ff 	2 . .
	jp nz,0c24dh		;c298	c2 4d c2 	. M .
	ld a,0ffh		;c29b	3e ff 	> .
	ret			;c29d	c9 	.
	xor a			;c29e	af 	.
	ret			;c29f	c9 	.
	ld a,(0ffc2h)		;c2a0	3a c2 ff 	: . .
	bit 4,a		;c2a3	cb 67 	. g
	jr z,$+6		;c2a5	28 04 	( .
	call 0c391h		;c2a7	cd 91 c3 	. . .
	ret			;c2aa	c9 	.
	ld a,(0ffc1h)		;c2ab	3a c1 ff 	: . .
	bit 0,a		;c2ae	cb 47 	. G
	jr z,$+6		;c2b0	28 04 	( .
	call 0c391h		;c2b2	cd 91 c3 	. . .
	ret			;c2b5	c9 	.
	ret			;c2b6	c9 	.
	ld e,000h		;c2b7	1e 00 	. .
	ld a,(0ffb8h)		;c2b9	3a b8 ff 	: . .
	cp 003h		;c2bc	fe 03 	. .
	jr nz,$+22		;c2be	20 14 	  .
	ld d,004h		;c2c0	16 04 	. .
	ld a,(0ffbbh)		;c2c2	3a bb ff 	: . .
	bit 7,a		;c2c5	cb 7f 	. 
	jr z,$+27		;c2c7	28 19 	( .
	ld a,(0ffbah)		;c2c9	3a ba ff 	: . .
	and 00fh		;c2cc	e6 0f 	. .
	rlca			;c2ce	07 	.
	rlca			;c2cf	07 	.
	add a,d			;c2d0	82 	.
	ld d,a			;c2d1	57 	W
	jr $+16		;c2d2	18 0e 	. .
	or a			;c2d4	b7 	.
	jr nz,$+4		;c2d5	20 02 	  .
	ld e,080h		;c2d7	1e 80 	. .
	ld a,(0ffbah)		;c2d9	3a ba ff 	: . .
	and 00fh		;c2dc	e6 0f 	. .
	ld d,001h		;c2de	16 01 	. .
	add a,d			;c2e0	82 	.
	ld d,a			;c2e1	57 	W
	ret			;c2e2	c9 	.
	call 0c3a9h		;c2e3	cd a9 c3 	. . .
	cp 0ffh		;c2e6	fe ff 	. .
	ret z			;c2e8	c8 	.
	ld b,014h		;c2e9	06 14 	. .
	ld a,(0ffb8h)		;c2eb	3a b8 ff 	: . .
	cp 003h		;c2ee	fe 03 	. .
	jr z,$+4		;c2f0	28 02 	( .
	ld b,040h		;c2f2	06 40 	. @
	push bc			;c2f4	c5 	.
	call 0c41ch		;c2f5	cd 1c c4 	. . .
	ld c,04dh		;c2f8	0e 4d 	. M
	call 0c415h		;c2fa	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;c2fd	ed 4b b9 ff 	. K . .
	call 0c415h		;c301	cd 15 c4 	. . .
	ld a,(0ffb8h)		;c304	3a b8 ff 	: . .
	ld c,a			;c307	4f 	O
	call 0c415h		;c308	cd 15 c4 	. . .
	ld c,005h		;c30b	0e 05 	. .
	ld a,(0ffb8h)		;c30d	3a b8 ff 	: . .
	cp 003h		;c310	fe 03 	. .
	jr z,$+4		;c312	28 02 	( .
	ld c,010h		;c314	0e 10 	. .
	call 0c415h		;c316	cd 15 c4 	. . .
	ld c,028h		;c319	0e 28 	. (
	call 0c415h		;c31b	cd 15 c4 	. . .
	di			;c31e	f3 	.
	ld c,0e5h		;c31f	0e e5 	. .
	call 0c415h		;c321	cd 15 c4 	. . .
	pop bc			;c324	c1 	.
	ld c,0c1h		;c325	0e c1 	. .
	ld hl,(0ffbdh)		;c327	2a bd ff 	* . .
	in a,(082h)		;c32a	db 82 	. .
	bit 2,a		;c32c	cb 57 	. W
	jr z,$-4		;c32e	28 fa 	( .
	in a,(0c0h)		;c330	db c0 	. .
	bit 5,a		;c332	cb 6f 	. o
	jr z,$+6		;c334	28 04 	( .
	outi		;c336	ed a3 	. .
	jr nz,$-14		;c338	20 f0 	  .
	out (0dch),a		;c33a	d3 dc 	. .
	ei			;c33c	fb 	.
	call 0c3f4h		;c33d	cd f4 c3 	. . .
	ld a,(0ffc0h)		;c340	3a c0 ff 	: . .
	and 0c0h		;c343	e6 c0 	. .
	cp 040h		;c345	fe 40 	. @
	jr nz,$+5		;c347	20 03 	  .
	ld a,0ffh		;c349	3e ff 	> .
	ret			;c34b	c9 	.
	xor a			;c34c	af 	.
	ret			;c34d	c9 	.
	ld bc,(0ffb9h)		;c34e	ed 4b b9 ff 	. K . .
	call 0c415h		;c352	cd 15 c4 	. . .
	ld de,(0ffbbh)		;c355	ed 5b bb ff 	. [ . .
	ld c,d			;c359	4a 	J
	call 0c415h		;c35a	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;c35d	ed 4b b9 ff 	. K . .
	ld a,c			;c361	79 	y
	and 004h		;c362	e6 04 	. .
	rrca			;c364	0f 	.
	rrca			;c365	0f 	.
	ld c,a			;c366	4f 	O
	call 0c415h		;c367	cd 15 c4 	. . .
	res 7,e		;c36a	cb bb 	. .
	ld c,e			;c36c	4b 	K
	inc c			;c36d	0c 	.
	call 0c415h		;c36e	cd 15 c4 	. . .
	ld a,(0ffb8h)		;c371	3a b8 ff 	: . .
	ld c,a			;c374	4f 	O
	call 0c415h		;c375	cd 15 c4 	. . .
	ld c,005h		;c378	0e 05 	. .
	ld a,(0ffb8h)		;c37a	3a b8 ff 	: . .
	cp 003h		;c37d	fe 03 	. .
	jr z,$+4		;c37f	28 02 	( .
	ld c,010h		;c381	0e 10 	. .
	call 0c415h		;c383	cd 15 c4 	. . .
	ld c,028h		;c386	0e 28 	. (
	call 0c415h		;c388	cd 15 c4 	. . .
	ld c,0ffh		;c38b	0e ff 	. .
	call 0c415h		;c38d	cd 15 c4 	. . .
	ret			;c390	c9 	.
	call 0c41ch		;c391	cd 1c c4 	. . .
	ld c,007h		;c394	0e 07 	. .
	call 0c415h		;c396	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;c399	ed 4b b9 ff 	. K . .
	res 2,c		;c39d	cb 91 	. .
	call 0c415h		;c39f	cd 15 c4 	. . .
	call 0c3d2h		;c3a2	cd d2 c3 	. . .
	jr z,$-20		;c3a5	28 ea 	( .
	xor a			;c3a7	af 	.
	ret			;c3a8	c9 	.
	ld de,(0ffbbh)		;c3a9	ed 5b bb ff 	. [ . .
	ld a,d			;c3ad	7a 	z
	or a			;c3ae	b7 	.
	jp z,0c391h		;c3af	ca 91 c3 	. . .
	call 0c41ch		;c3b2	cd 1c c4 	. . .
	ld c,00fh		;c3b5	0e 0f 	. .
	call 0c415h		;c3b7	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;c3ba	ed 4b b9 ff 	. K . .
	call 0c415h		;c3be	cd 15 c4 	. . .
	ld c,d			;c3c1	4a 	J
	call 0c415h		;c3c2	cd 15 c4 	. . .
	call 0c3d2h		;c3c5	cd d2 c3 	. . .
	jr nz,$+8		;c3c8	20 06 	  .
	call 0c391h		;c3ca	cd 91 c3 	. . .
	jp 0c3a9h		;c3cd	c3 a9 c3 	. . .
	xor a			;c3d0	af 	.
	ret			;c3d1	c9 	.
	in a,(082h)		;c3d2	db 82 	. .
	bit 2,a		;c3d4	cb 57 	. W
	jp z,0c3d2h		;c3d6	ca d2 c3 	. . .
	call 0c41ch		;c3d9	cd 1c c4 	. . .
	call 0c403h		;c3dc	cd 03 c4 	. . .
	ld a,008h		;c3df	3e 08 	> .
	out (0c1h),a		;c3e1	d3 c1 	. .
	call 0c40ch		;c3e3	cd 0c c4 	. . .
	in a,(0c1h)		;c3e6	db c1 	. .
	ld b,a			;c3e8	47 	G
	call 0c40ch		;c3e9	cd 0c c4 	. . .
	in a,(0c1h)		;c3ec	db c1 	. .
	ld a,b			;c3ee	78 	x
	and 0c0h		;c3ef	e6 c0 	. .
	cp 040h		;c3f1	fe 40 	. @
	ret			;c3f3	c9 	.
	ld hl,0ffc0h		;c3f4	21 c0 ff 	! . .
	ld b,007h		;c3f7	06 07 	. .
	ld c,0c1h		;c3f9	0e c1 	. .
	call 0c40ch		;c3fb	cd 0c c4 	. . .
	ini		;c3fe	ed a2 	. .
	jr nz,$-5		;c400	20 f9 	  .
	ret			;c402	c9

	; FUNCTION C403 -- wait for ioaddr(0xc0) to become "10xxxxxx"
	in a,(0c0h)		;c403
	rlca			;c405
	jr nc,$-3		;c406	; while (bit7 == 0), try again
	rlca			;c408
	jr c,$-6		;c409	; while (bit7 == 1) && (bit6 == 1), try again
	ret				;c40b

	; FUNCTION C40C
	in a,(0c0h)		;c40c	db c0 	. .
	rlca			;c40e	07 	.
	jr nc,$-3		;c40f	30 fb 	0 .
	rlca			;c411	07 	.
	jr nc,$-6		;c412	30 f8 	0 .
	ret			;c414	c9

	; FUNCTION C415
	call 0c403h		;c415
	ld a,c			;c418
	out (0c1h),a	;c419
	ret				;c41b

	; FUNCTION  C41C -- wait for something
	in a,(0c0h)		;c41c
	bit 4,a			;c41e
	jr nz,$-4		;c420	; loop until io(0xc0).4 is not 0
	ret				;c422

	ld b,001h		;c423	06 01 	. .
	ld a,c			;c425	79 	y
	and 003h		;c426	e6 03 	. .
	or a			;c428	b7 	.
	jr z,$+7		;c429	28 05 	( .
	rlc b		;c42b	cb 00 	. .
	dec a			;c42d	3d 	=
	jr nz,$-3		;c42e	20 fb 	  .
	ld a,(0ffc7h)		;c430	3a c7 ff 	: . .
	ld c,a			;c433	4f 	O
	and b			;c434	a0 	.
	ret nz			;c435	c0 	.
	ld a,c			;c436	79 	y
	or b			;c437	b0 	.
	ld (0ffc7h),a		;c438	32 c7 ff 	2 . .
	call 0c391h		;c43b	cd 91 c3 	. . .
	ret			;c43e	c9 	.

	; FUNCTION C43F
	push bc			;c43f
	push hl			;c440
	ld hl,0c45ch	;c441	; prepare HL for later
	call 0c41ch		;c444	; wait for something
	ld c,003h		;c447
	call 0c415h		;c449
	ld c,(hl)		;c44c
	inc hl			;c44d	23 	#
	call 0c415h		;c44e	cd 15 c4 	. . .
	ld c,(hl)			;c451	4e 	N
	call 0c415h		;c452	cd 15 c4 	. . .
	xor a			;c455	af 	.
	ld (0ffc7h),a		;c456	32 c7 ff 	2 . .
	pop hl			;c459	e1 	.
	pop bc			;c45a	c1 	.
	ret			;c45b	c9 	.

	; static data for C43F
	ld l,a			;c45c	6f
	dec de			;c45d	1b
	push af			;c45e	f5
	push bc			;c45f	c5
	push de			;c460	d5
	push hl			;c461	e5
	push ix		;c462	dd e5 	. .
	push iy		;c464	fd e5 	. .
	call 0c69ah		;c466	cd 9a c6 	. . .
	ld a,(0ffd8h)		;c469	3a d8 ff 	: . .
	or a			;c46c	b7 	.
	jp nz,0c9e3h		;c46d	c2 e3 c9 	. . .
	ld a,(0ffcch)		;c470	3a cc ff 	: . .
	cp 0ffh		;c473	fe ff 	. .
	jp z,0c6a3h		;c475	ca a3 c6 	. . .
	or a			;c478	b7 	.
	jp nz,0c4beh		;c479	c2 be c4 	. . .
	ld a,c			;c47c	79 	y
	cp 01bh		;c47d	fe 1b 	. .
	jr z,$+55		;c47f	28 35 	( 5
	cp 020h		;c481	fe 20 	.
	jp nc,0c4beh		;c483	d2 be c4 	. . .
	cp 00dh		;c486	fe 0d 	. .
	jp z,0c524h		;c488	ca 24 c5 	. $ .
	cp 00ah		;c48b	fe 0a 	. .
	jp z,0c532h		;c48d	ca 32 c5 	. 2 .
	cp 00bh		;c490	fe 0b 	. .
	jp z,0c558h		;c492	ca 58 c5 	. X .
	cp 00ch		;c495	fe 0c 	. .
	jp z,0c56fh		;c497	ca 6f c5 	. o .
	cp 008h		;c49a	fe 08 	. .
	jp z,0c59bh		;c49c	ca 9b c5 	. . .
	cp 01eh		;c49f	fe 1e 	. .
	jp z,0c5dbh		;c4a1	ca db c5 	. . .
	cp 01ah		;c4a4	fe 1a 	. .
	jp z,0c5eeh		;c4a6	ca ee c5 	. . .
	cp 007h		;c4a9	fe 07 	. .
	call z,0c5f4h		;c4ab	cc f4 c5 	. . .
	cp 000h		;c4ae	fe 00 	. .
	jp z,0c6a3h		;c4b0	ca a3 c6 	. . .
	jp 0c4beh		;c4b3	c3 be c4 	. . .
	ld a,001h		;c4b6	3e 01 	> .
	ld (0ffd8h),a		;c4b8	32 d8 ff 	2 . .
	jp 0c6a3h		;c4bb	c3 a3 c6 	. . .
	push iy		;c4be	fd e5 	. .
	pop hl			;c4c0	e1 	.
	call 0c715h		;c4c1	cd 15 c7 	. . .
	ld (hl),c			;c4c4	71 	q
	call 0c795h		;c4c5	cd 95 c7 	. . .
	ld a,(0ffd1h)		;c4c8	3a d1 ff 	: . .
	ld b,a			;c4cb	47 	G
	ld a,(0ffd2h)		;c4cc	3a d2 ff 	: . .
	and (hl)			;c4cf	a6 	.
	or b			;c4d0	b0 	.
	ld (hl),a			;c4d1	77 	w
	call 0c79eh		;c4d2	cd 9e c7 	. . .
	call 0c5f8h		;c4d5	cd f8 c5 	. . .
	jr c,$+8		;c4d8	38 06 	8 .
	call 0c613h		;c4da	cd 13 c6 	. . .
	jp 0c6a3h		;c4dd	c3 a3 c6 	. . .
	ld a,(0ffcbh)		;c4e0	3a cb ff 	: . .
	ld b,a			;c4e3	47 	G
	ld a,(0ffcdh)		;c4e4	3a cd ff 	: . .
	cp b			;c4e7	b8 	.
	jr z,$+25		;c4e8	28 17 	( .
	inc b			;c4ea	04 	.
	ld a,b			;c4eb	78 	x
	ld (0ffcbh),a		;c4ec	32 cb ff 	2 . .
	ld a,(0ffc9h)		;c4ef	3a c9 ff 	: . .
	or a			;c4f2	b7 	.
	jr nz,$+8		;c4f3	20 06 	  .
	call 0c613h		;c4f5	cd 13 c6 	. . .
	jp 0c6a3h		;c4f8	c3 a3 c6 	. . .
	call 0c620h		;c4fb	cd 20 c6 	.   .
	jp 0c6a3h		;c4fe	c3 a3 c6 	. . .
	ld a,(0ffc9h)		;c501	3a c9 ff 	: . .
	or a			;c504	b7 	.
	jr nz,$+11		;c505	20 09 	  .
	call 0c613h		;c507	cd 13 c6 	. . .
	call 0c62eh		;c50a	cd 2e c6 	. . .
	jp 0c6a3h		;c50d	c3 a3 c6 	. . .
	ld a,(0ffcdh)		;c510	3a cd ff 	: . .
	ld b,a			;c513	47 	G
	ld a,(0ffd0h)		;c514	3a d0 ff 	: . .
	ld c,a			;c517	4f 	O
	call 0c6f1h		;c518	cd f1 c6 	. . .
	call 0c71ch		;c51b	cd 1c c7 	. . .
	call 0c62eh		;c51e	cd 2e c6 	. . .
	jp 0c6a3h		;c521	c3 a3 c6 	. . .
	ld a,(0ffd0h)		;c524	3a d0 ff 	: . .
	ld (0ffcah),a		;c527	32 ca ff 	2 . .
	ld c,a			;c52a	4f 	O
	ld a,(0ffcbh)		;c52b	3a cb ff 	: . .
	ld b,a			;c52e	47 	G
	jp 0c5e5h		;c52f	c3 e5 c5 	. . .
	ld a,(0ffcbh)		;c532	3a cb ff 	: . .
	ld b,a			;c535	47 	G
	ld a,(0ffcdh)		;c536	3a cd ff 	: . .
	cp b			;c539	b8 	.
	jr z,$+17		;c53a	28 0f 	( .
	inc b			;c53c	04 	.
	ld a,b			;c53d	78 	x
	ld (0ffcbh),a		;c53e	32 cb ff 	2 . .
	push iy		;c541	fd e5 	. .
	pop hl			;c543	e1 	.
	ld de,00050h		;c544	11 50 00 	. P .
	add hl,de			;c547	19 	.
	jp 0c5e8h		;c548	c3 e8 c5 	. . .
	call 0c62eh		;c54b	cd 2e c6 	. . .
	ld a,(0ffcbh)		;c54e	3a cb ff 	: . .
	ld b,a			;c551	47 	G
	ld a,(0ffcah)		;c552	3a ca ff 	: . .
	ld c,a			;c555	4f 	O
	jr $-21		;c556	18 e9 	. .
	ld a,(0ffcbh)		;c558	3a cb ff 	: . .
	ld b,a			;c55b	47 	G
	ld a,(0ffceh)		;c55c	3a ce ff 	: . .
	cp b			;c55f	b8 	.
	jp z,0c6a3h		;c560	ca a3 c6 	. . .
	dec b			;c563	05 	.
	ld a,b			;c564	78 	x
	ld (0ffcbh),a		;c565	32 cb ff 	2 . .
	ld a,(0ffcah)		;c568	3a ca ff 	: . .
	ld c,a			;c56b	4f 	O
	jp 0c5e5h		;c56c	c3 e5 c5 	. . .
	call 0c5f8h		;c56f	cd f8 c5 	. . .
	ld a,(0ffcbh)		;c572	3a cb ff 	: . .
	ld b,a			;c575	47 	G
	jr c,$+5		;c576	38 03 	8 .
	jp 0c5e5h		;c578	c3 e5 c5 	. . .
	ld a,(0ffd0h)		;c57b	3a d0 ff 	: . .
	ld (0ffcah),a		;c57e	32 ca ff 	2 . .
	ld c,a			;c581	4f 	O
	ld a,(0ffcbh)		;c582	3a cb ff 	: . .
	ld b,a			;c585	47 	G
	ld a,(0ffcdh)		;c586	3a cd ff 	: . .
	cp b			;c589	b8 	.
	jr z,$+10		;c58a	28 08 	( .
	inc b			;c58c	04 	.
	ld a,b			;c58d	78 	x
	ld (0ffcbh),a		;c58e	32 cb ff 	2 . .
	jp 0c5e5h		;c591	c3 e5 c5 	. . .
	push bc			;c594	c5 	.
	call 0c62eh		;c595	cd 2e c6 	. . .
	pop bc			;c598	c1 	.
	jr $+76		;c599	18 4a 	. J
	ld a,(0ffcah)		;c59b	3a ca ff 	: . .
	ld c,a			;c59e	4f 	O
	ld a,(0ffd0h)		;c59f	3a d0 ff 	: . .
	cp c			;c5a2	b9 	.
	jr z,$+21		;c5a3	28 13 	( .
	dec c			;c5a5	0d 	.
	ld a,(0ffd1h)		;c5a6	3a d1 ff 	: . .
	bit 3,a		;c5a9	cb 5f 	. _
	jr z,$+3		;c5ab	28 01 	( .
	dec c			;c5ad	0d 	.
	ld a,c			;c5ae	79 	y
	ld (0ffcah),a		;c5af	32 ca ff 	2 . .
	ld a,(0ffcbh)		;c5b2	3a cb ff 	: . .
	ld b,a			;c5b5	47 	G
	jr $+47		;c5b6	18 2d 	. -
	ld a,(0ffcfh)		;c5b8	3a cf ff 	: . .
	ld b,a			;c5bb	47 	G
	ld a,(0ffd1h)		;c5bc	3a d1 ff 	: . .
	bit 3,a		;c5bf	cb 5f 	. _
	jr z,$+3		;c5c1	28 01 	( .
	dec b			;c5c3	05 	.
	ld a,b			;c5c4	78 	x
	ld (0ffcah),a		;c5c5	32 ca ff 	2 . .
	ld c,a			;c5c8	4f 	O
	ld a,(0ffcbh)		;c5c9	3a cb ff 	: . .
	ld b,a			;c5cc	47 	G
	ld a,(0ffceh)		;c5cd	3a ce ff 	: . .
	cp b			;c5d0	b8 	.
	jp z,0c6a3h		;c5d1	ca a3 c6 	. . .
	dec b			;c5d4	05 	.
	ld a,b			;c5d5	78 	x
	ld (0ffcbh),a		;c5d6	32 cb ff 	2 . .
	jr $+12		;c5d9	18 0a 	. .
	xor a			;c5db	af 	.
	ld (0ffcbh),a		;c5dc	32 cb ff 	2 . .
	ld (0ffcah),a		;c5df	32 ca ff 	2 . .
	ld bc,00000h		;c5e2	01 00 00 	. . .
	call 0c6f1h		;c5e5	cd f1 c6 	. . .
	call 0c71ch		;c5e8	cd 1c c7 	. . .
	jp 0c6a3h		;c5eb	c3 a3 c6 	. . .
	call 0c764h		;c5ee	cd 64 c7 	. d .
	jp 0c6a3h		;c5f1	c3 a3 c6 	. . .
	xor a			;c5f4	af 	.
	out (0dah),a		;c5f5	d3 da 	. .
	ret			;c5f7	c9 	.
	ld a,(0ffcah)		;c5f8	3a ca ff 	: . .
	ld c,a			;c5fb	4f 	O
	inc c			;c5fc	0c 	.
	ld a,(0ffd1h)		;c5fd	3a d1 ff 	: . .
	bit 3,a		;c600	cb 5f 	. _
	jr z,$+3		;c602	28 01 	( .
	inc c			;c604	0c 	.
	ld a,(0ffcfh)		;c605	3a cf ff 	: . .
	cp c			;c608	b9 	.
	ld a,c			;c609	79 	y
	jr nc,$+5		;c60a	30 03 	0 .
	ld a,(0ffd0h)		;c60c	3a d0 ff 	: . .
	ld (0ffcah),a		;c60f	32 ca ff 	2 . .
	ret			;c612	c9 	.
	inc hl			;c613	23 	#
	ld a,(0ffd1h)		;c614	3a d1 ff 	: . .
	bit 3,a		;c617	cb 5f 	. _
	jr z,$+3		;c619	28 01 	( .
	inc hl			;c61b	23 	#
	call 0c71ch		;c61c	cd 1c c7 	. . .
	ret			;c61f	c9 	.
	ld a,(0ffc8h)		;c620	3a c8 ff 	: . .
	ld e,a			;c623	5f 	_
	ld d,000h		;c624	16 00 	. .
	push iy		;c626	fd e5 	. .
	pop hl			;c628	e1 	.
	add hl,de			;c629	19 	.
	call 0c71ch		;c62a	cd 1c c7 	. . .
	ret			;c62d	c9 	.
	ld a,(0ffc9h)		;c62e	3a c9 ff 	: . .
	or a			;c631	b7 	.
	jr nz,$+21		;c632	20 13 	  .
	push ix		;c634	dd e5 	. .
	pop hl			;c636	e1 	.
	ld de,00050h		;c637	11 50 00 	. P .
	add hl,de			;c63a	19 	.
	call 0c742h		;c63b	cd 42 c7 	. B .
	ld b,017h		;c63e	06 17 	. .
	call 0c7fah		;c640	cd fa c7 	. . .
	call 0c670h		;c643	cd 70 c6 	. p .
	ret			;c646	c9 	.
	ld a,(0ffd0h)		;c647	3a d0 ff 	: . .
	ld c,a			;c64a	4f 	O
	ld a,(0ffceh)		;c64b	3a ce ff 	: . .
	ld b,a			;c64e	47 	G
	ld a,(0ffceh)		;c64f	3a ce ff 	: . .
	ld d,a			;c652	57 	W
	ld a,(0ffcdh)		;c653	3a cd ff 	: . .
	sub d			;c656	92 	.
	jr z,$+13		;c657	28 0b 	( .
	ld d,a			;c659	57 	W
	inc b			;c65a	04 	.
	call 0c6f1h		;c65b	cd f1 c6 	. . .
	call 0c7a7h		;c65e	cd a7 c7 	. . .
	dec d			;c661	15 	.
	jr nz,$-8		;c662	20 f6 	  .
	ld a,(0ffcdh)		;c664	3a cd ff 	: . .
	ld d,a			;c667	57 	W
	ld a,(0ffcfh)		;c668	3a cf ff 	: . .
	ld e,a			;c66b	5f 	_
	call 0c805h		;c66c	cd 05 c8 	. . .
	ret			;c66f	c9 	.
	push ix		;c670	dd e5 	. .
	pop hl			;c672	e1 	.
	ld de,00730h		;c673	11 30 07 	. 0 .
	ld b,050h		;c676	06 50 	. P
	add hl,de			;c678	19 	.
	ld de,02000h		;c679	11 00 20 	. .
	call 0c795h		;c67c	cd 95 c7 	. . .
	call 0c715h		;c67f	cd 15 c7 	. . .
	push hl			;c682	e5 	.
	push bc			;c683	c5 	.
	ld e,000h		;c684	1e 00 	. .
	call 0c690h		;c686	cd 90 c6 	. . .
	pop bc			;c689	c1 	.
	pop hl			;c68a	e1 	.
	call 0c79eh		;c68b	cd 9e c7 	. . .
	ld e,020h		;c68e	1e 20 	.
	ld (hl),e			;c690	73 	s
	inc hl			;c691	23 	#
	bit 3,h		;c692	cb 5c 	. \
	call z,0c715h		;c694	cc 15 c7 	. . .
	djnz $-7		;c697	10 f7 	. .
	ret			;c699	c9 	.
	ld ix,(0ffd4h)		;c69a	dd 2a d4 ff 	. * . .
	ld iy,(0ffd6h)		;c69e	fd 2a d6 ff 	. * . .
	ret			;c6a2	c9 	.
	call 0c6e8h		;c6a3	cd e8 c6 	. . .
	pop iy		;c6a6	fd e1 	. .
	pop ix		;c6a8	dd e1 	. .
	pop hl			;c6aa	e1 	.
	pop de			;c6ab	d1 	.
	pop bc			;c6ac	c1 	.
	pop af			;c6ad	f1 	.
	ret			;c6ae	c9 	.
	ld hl,0ffc9h		;c6af	21 c9 ff 	! . .
	xor a			;c6b2	af 	.
	ld (hl),a			;c6b3	77 	w
	inc hl			;c6b4	23 	#
	ld (hl),a			;c6b5	77 	w
	inc hl			;c6b6	23 	#
	ld (hl),a			;c6b7	77 	w
	inc hl			;c6b8	23 	#
	ld (hl),a			;c6b9	77 	w
	inc hl			;c6ba	23 	#
	ld (hl),017h		;c6bb	36 17 	6 .
	inc hl			;c6bd	23 	#
	ld (hl),a			;c6be	77 	w
	inc hl			;c6bf	23 	#
	ld (hl),04fh		;c6c0	36 4f 	6 O
	inc hl			;c6c2	23 	#
	ld (hl),a			;c6c3	77 	w
	inc hl			;c6c4	23 	#
	ld (hl),a			;c6c5	77 	w
	inc hl			;c6c6	23 	#
	ld (hl),080h		;c6c7	36 80 	6 .
	inc hl			;c6c9	23 	#
	ld a,(0c86fh)		;c6ca	3a 6f c8 	: o .
	ld d,a			;c6cd	57 	W
	in a,(0d6h)		;c6ce	db d6 	. .
	bit 5,a		;c6d0	cb 6f 	. o
	jr z,$+4		;c6d2	28 02 	( .
	ld d,003h		;c6d4	16 03 	. .
	bit 6,a		;c6d6	cb 77 	. w
	jr z,$+6		;c6d8	28 04 	( .
	set 5,d		;c6da	cb ea 	. .
	set 6,d		;c6dc	cb f2 	. .
	ld (hl),d			;c6de	72 	r
	xor a			;c6df	af 	.
	inc hl			;c6e0	23 	#
	ld b,015h		;c6e1	06 15 	. .
	ld (hl),a			;c6e3	77 	w
	inc hl			;c6e4	23 	#
	djnz $-2		;c6e5	10 fc 	. .
	ret			;c6e7	c9 	.
	ld (0ffd4h),ix		;c6e8	dd 22 d4 ff 	. " . .
	ld (0ffd6h),iy		;c6ec	fd 22 d6 ff 	. " . .
	ret			;c6f0	c9 	.
	push af			;c6f1	f5 	.
	push bc			;c6f2	c5 	.
	push de			;c6f3	d5 	.
	push ix		;c6f4	dd e5 	. .
	pop hl			;c6f6	e1 	.
	ld de,00050h		;c6f7	11 50 00 	. P .
	ld a,b			;c6fa	78 	x
	ld b,005h		;c6fb	06 05 	. .
	rra			;c6fd	1f 	.
	jr nc,$+3		;c6fe	30 01 	0 .
	add hl,de			;c700	19 	.
	or a			;c701	b7 	.
	rl e		;c702	cb 13 	. .
	rl d		;c704	cb 12 	. .
	dec b			;c706	05 	.
	jr nz,$-10		;c707	20 f4 	  .
	ld d,000h		;c709	16 00 	. .
	ld e,c			;c70b	59 	Y
	add hl,de			;c70c	19 	.
	ld a,h			;c70d	7c 	|
	and 00fh		;c70e	e6 0f 	. .
	ld h,a			;c710	67 	g
	pop de			;c711	d1 	.
	pop bc			;c712	c1 	.
	pop af			;c713	f1 	.
	ret			;c714	c9 	.
	ld a,h			;c715	7c 	|
	and 007h		;c716	e6 07 	. .
	or 0d0h		;c718	f6 d0 	. .
	ld h,a			;c71a	67 	g
	ret			;c71b	c9 	.
	ld a,h			;c71c	7c 	|
	and 007h		;c71d	e6 07 	. .
	ld h,a			;c71f	67 	g
	push ix		;c720	dd e5 	. .
	pop de			;c722	d1 	.
	ex de,hl			;c723	eb 	.
	or a			;c724	b7 	.
	sbc hl,de		;c725	ed 52 	. R
	jr c,$+9		;c727	38 07 	8 .
	jr z,$+7		;c729	28 05 	( .
	ld hl,00800h		;c72b	21 00 08 	! . .
	add hl,de			;c72e	19 	.
	ex de,hl			;c72f	eb 	.
	ld a,00eh		;c730	3e 0e 	> .
	out (0a0h),a		;c732	d3 a0 	. .
	ld a,d			;c734	7a 	z
	out (0a1h),a		;c735	d3 a1 	. .
	ld a,00fh		;c737	3e 0f 	> .
	out (0a0h),a		;c739	d3 a0 	. .
	ld a,e			;c73b	7b 	{
	out (0a1h),a		;c73c	d3 a1 	. .
	push de			;c73e	d5 	.
	pop iy		;c73f	fd e1 	. .
	ret			;c741	c9 	.
	ld a,h			;c742	7c 	|
	and 007h		;c743	e6 07 	. .
	ld h,a			;c745	67 	g
	call 0c75bh		;c746	cd 5b c7 	. [ .
	ld a,00ch		;c749	3e 0c 	> .
	out (0a0h),a		;c74b	d3 a0 	. .
	ld a,h			;c74d	7c 	|
	out (0a1h),a		;c74e	d3 a1 	. .
	ld a,00dh		;c750	3e 0d 	> .
	out (0a0h),a		;c752	d3 a0 	. .
	ld a,l			;c754	7d 	}
	out (0a1h),a		;c755	d3 a1 	. .
	push hl			;c757	e5 	.
	pop ix		;c758	dd e1 	. .
	ret			;c75a	c9 	.
	in a,(0a0h)		;c75b	db a0 	. .
	in a,(082h)		;c75d	db 82 	. .
	bit 1,a		;c75f	cb 4f 	. O
	jr z,$-4		;c761	28 fa 	( .
	ret			;c763	c9 	.
	ld bc,00780h		;c764	01 80 07 	. . .
	push ix		;c767	dd e5 	. .
	pop hl			;c769	e1 	.
	ld de,02000h		;c76a	11 00 20 	. .
	call 0c715h		;c76d	cd 15 c7 	. . .
	ld (hl),d			;c770	72 	r
	in a,(081h)		;c771	db 81 	. .
	set 7,a		;c773	cb ff 	. .
	out (081h),a		;c775	d3 81 	. .
	ld (hl),e			;c777	73 	s
	res 7,a		;c778	cb bf 	. .
	out (081h),a		;c77a	d3 81 	. .
	inc hl			;c77c	23 	#
	bit 3,h		;c77d	cb 5c 	. \
	call z,0c715h		;c77f	cc 15 c7 	. . .
	dec bc			;c782	0b 	.
	ld a,b			;c783	78 	x
	or c			;c784	b1 	.
	jr nz,$-21		;c785	20 e9 	  .
	push ix		;c787	dd e5 	. .
	pop hl			;c789	e1 	.
	call 0c71ch		;c78a	cd 1c c7 	. . .
	xor a			;c78d	af 	.
	ld (0ffcah),a		;c78e	32 ca ff 	2 . .
	ld (0ffcbh),a		;c791	32 cb ff 	2 . .
	ret			;c794	c9 	.
	push af			;c795	f5 	.
	in a,(081h)		;c796	db 81 	. .
	set 7,a		;c798	cb ff 	. .
	out (081h),a		;c79a	d3 81 	. .
	pop af			;c79c	f1 	.
	ret			;c79d	c9 	.
	push af			;c79e	f5 	.
	in a,(081h)		;c79f	db 81 	. .
	res 7,a		;c7a1	cb bf 	. .
	out (081h),a		;c7a3	d3 81 	. .
	pop af			;c7a5	f1 	.
	ret			;c7a6	c9 	.
	push de			;c7a7	d5 	.
	push bc			;c7a8	c5 	.
	ld a,050h		;c7a9	3e 50 	> P
	cpl			;c7ab	2f 	/
	ld d,0ffh		;c7ac	16 ff 	. .
	ld e,a			;c7ae	5f 	_
	inc de			;c7af	13 	.
	call 0c7b6h		;c7b0	cd b6 c7 	. . .
	pop bc			;c7b3	c1 	.
	pop de			;c7b4	d1 	.
	ret			;c7b5	c9 	.
	ld a,(0ffd0h)		;c7b6	3a d0 ff 	: . .
	ld c,a			;c7b9	4f 	O
	call 0c6f1h		;c7ba	cd f1 c6 	. . .
	push hl			;c7bd	e5 	.
	add hl,de			;c7be	19 	.
	ex de,hl			;c7bf	eb 	.
	pop hl			;c7c0	e1 	.
	ld a,(0ffd0h)		;c7c1	3a d0 ff 	: . .
	ld b,a			;c7c4	47 	G
	ld a,(0ffcfh)		;c7c5	3a cf ff 	: . .
	sub b			;c7c8	90 	.
	inc a			;c7c9	3c 	<
	ld b,a			;c7ca	47 	G
	call 0c715h		;c7cb	cd 15 c7 	. . .
	ex de,hl			;c7ce	eb 	.
	call 0c715h		;c7cf	cd 15 c7 	. . .
	ex de,hl			;c7d2	eb 	.
	push bc			;c7d3	c5 	.
	push de			;c7d4	d5 	.
	push hl			;c7d5	e5 	.
	ld c,002h		;c7d6	0e 02 	. .
	ld a,(hl)			;c7d8	7e 	~
	ld (de),a			;c7d9	12 	.
	inc de			;c7da	13 	.
	ld a,d			;c7db	7a 	z
	and 007h		;c7dc	e6 07 	. .
	or 0d0h		;c7de	f6 d0 	. .
	ld d,a			;c7e0	57 	W
	inc hl			;c7e1	23 	#
	bit 3,h		;c7e2	cb 5c 	. \
	call z,0c715h		;c7e4	cc 15 c7 	. . .
	djnz $-15		;c7e7	10 ef 	. .
	dec c			;c7e9	0d 	.
	jr z,$+12		;c7ea	28 0a 	( .
	ld a,c			;c7ec	79 	y
	pop hl			;c7ed	e1 	.
	pop de			;c7ee	d1 	.
	pop bc			;c7ef	c1 	.
	ld c,a			;c7f0	4f 	O
	call 0c795h		;c7f1	cd 95 c7 	. . .
	jr $-28		;c7f4	18 e2 	. .
	call 0c79eh		;c7f6	cd 9e c7 	. . .
	ret			;c7f9	c9 	.
	push de			;c7fa	d5 	.
	push bc			;c7fb	c5 	.
	ld de,00050h		;c7fc	11 50 00 	. P .
	call 0c7b6h		;c7ff	cd b6 c7 	. . .
	pop bc			;c802	c1 	.
	pop de			;c803	d1 	.
	ret			;c804	c9 	.
	ld a,e			;c805	7b 	{
	sub c			;c806	91 	.
	inc a			;c807	3c 	<
	ld e,a			;c808	5f 	_
	ld a,d			;c809	7a 	z
	sub b			;c80a	90 	.
	inc a			;c80b	3c 	<
	ld d,a			;c80c	57 	W
	call 0c6f1h		;c80d	cd f1 c6 	. . .
	call 0c715h		;c810	cd 15 c7 	. . .
	ld (hl),020h		;c813	36 20 	6
	call 0c795h		;c815	cd 95 c7 	. . .
	ld (hl),000h		;c818	36 00 	6 .
	call 0c79eh		;c81a	cd 9e c7 	. . .
	inc hl			;c81d	23 	#
	dec e			;c81e	1d 	.
	jr nz,$-15		;c81f	20 ef 	  .
	inc b			;c821	04 	.
	ld a,(0ffd0h)		;c822	3a d0 ff 	: . .
	ld c,a			;c825	4f 	O
	ld a,(0ffcfh)		;c826	3a cf ff 	: . .
	sub c			;c829	91 	.
	inc a			;c82a	3c 	<
	ld e,a			;c82b	5f 	_
	dec d			;c82c	15 	.
	jr nz,$-32		;c82d	20 de 	  .
	ret			;c82f	c9 	.
	ld a,(0ffcdh)		;c830	3a cd ff 	: . .
	ld b,a			;c833	47 	G
	ld a,(0ffceh)		;c834	3a ce ff 	: . .
	cp b			;c837	b8 	.
	jr z,$+13		;c838	28 0b 	( .
	ld d,a			;c83a	57 	W
	ld a,b			;c83b	78 	x
	sub d			;c83c	92 	.
	ld d,a			;c83d	57 	W
	dec b			;c83e	05 	.
	call 0c7fah		;c83f	cd fa c7 	. . .
	dec d			;c842	15 	.
	jr nz,$-5		;c843	20 f9 	  .
	ld a,(0ffceh)		;c845	3a ce ff 	: . .
	ld b,a			;c848	47 	G
	ld d,a			;c849	57 	W
	ld a,(0ffd0h)		;c84a	3a d0 ff 	: . .
	ld c,a			;c84d	4f 	O
	ld a,(0ffcfh)		;c84e	3a cf ff 	: . .
	ld e,a			;c851	5f 	_
	call 0c805h		;c852	cd 05 c8 	. . .
	ret			;c855	c9 	.
	push bc			;c856	c5 	.
	ld b,01eh		;c857	06 1e 	. .
	ld c,00fh		;c859	0e 0f 	. .
	dec c			;c85b	0d 	.
	jp nz,0c85bh		;c85c	c2 5b c8 	. [ .
	dec b			;c85f	05 	.
	jp nz,0c859h		;c860	c2 59 c8 	. Y .
	pop bc			;c863	c1 	.
	ret			;c864	c9 	.
	ld h,e			;c865	63 	c
	ld d,b			;c866	50 	P
	ld d,h			;c867	54 	T
	xor d			;c868	aa 	.
	add hl,de			;c869	19 	.
	ld b,019h		;c86a	06 19 	. .
	add hl,de			;c86c	19 	.
	nop			;c86d	00 	.
	dec c			;c86e	0d 	.
	dec c			;c86f	0d 	.
	dec c			;c870	0d 	.
	nop			;c871	00 	.
	nop			;c872	00 	.
	nop			;c873	00 	.
	nop			;c874	00 	.
	ld a,(0ffd1h)		;c875	3a d1 ff 	: . .
	set 3,a		;c878	cb df 	. .
	ld (0ffd1h),a		;c87a	32 d1 ff 	2 . .
	ld a,(0ffcah)		;c87d	3a ca ff 	: . .
	ld c,a			;c880	4f 	O
	rra			;c881	1f 	.
	jr nc,$+9		;c882	30 07 	0 .
	inc iy		;c884	fd 23 	. #
	inc c			;c886	0c 	.
	ld a,c			;c887	79 	y
	ld (0ffcah),a		;c888	32 ca ff 	2 . .
	xor a			;c88b	af 	.
	ret			;c88c	c9 	.
	ld hl,0c865h		;c88d	21 65 c8 	! e .
	ld b,010h		;c890	06 10 	. .
	ld c,0a1h		;c892	0e a1 	. .
	xor a			;c894	af 	.
	out (0a0h),a		;c895	d3 a0 	. .
	inc a			;c897	3c 	<
	outi		;c898	ed a3 	. .
	jr nz,$-5		;c89a	20 f9 	  .
	ld ix,00000h		;c89c	dd 21 00 00 	. ! . .
	call 0c764h		;c8a0	cd 64 c7 	. d .
	call 0c8b6h		;c8a3	cd b6 c8 	. . .
	ld hl,00000h		;c8a6	21 00 00 	! . .
	call 0c71ch		;c8a9	cd 1c c7 	. . .
	ld a,(0ffd1h)		;c8ac	3a d1 ff 	: . .
	res 3,a		;c8af	cb 9f 	. .
	ld (0ffd1h),a		;c8b1	32 d1 ff 	2 . .
	xor a			;c8b4	af 	.
	ret			;c8b5	c9 	.
	ld a,006h		;c8b6	3e 06 	> .
	out (0a0h),a		;c8b8	d3 a0 	. .
	ld a,018h		;c8ba	3e 18 	> .
	out (0a1h),a		;c8bc	d3 a1 	. .
	ret			;c8be	c9 	.
	xor a			;c8bf	af 	.
	ld (0ffceh),a		;c8c0	32 ce ff 	2 . .
	ld (0ffd0h),a		;c8c3	32 d0 ff 	2 . .
	ld (0ffc9h),a		;c8c6	32 c9 ff 	2 . .
	ld a,017h		;c8c9	3e 17 	> .
	ld (0ffcdh),a		;c8cb	32 cd ff 	2 . .
	ret			;c8ce	c9 	.
	ld b,004h		;c8cf	06 04 	. .
	call 0c75bh		;c8d1	cd 5b c7 	. [ .
	xor a			;c8d4	af 	.
	ld c,0a1h		;c8d5	0e a1 	. .
	out (0a0h),a		;c8d7	d3 a0 	. .
	inc a			;c8d9	3c 	<
	outi		;c8da	ed a3 	. .
	jr nz,$-5		;c8dc	20 f9 	  .
	ret			;c8de	c9 	.
	ld a,(0ffd9h)		;c8df	3a d9 ff 	: . .
	or a			;c8e2	b7 	.
	jr nz,$+7		;c8e3	20 05 	  .
	inc a			;c8e5	3c 	<
	ld (0ffd9h),a		;c8e6	32 d9 ff 	2 . .
	ret			;c8e9	c9 	.
	ld a,c			;c8ea	79 	y
	and 00fh		;c8eb	e6 0f 	. .
	rlca			;c8ed	07 	.
	rlca			;c8ee	07 	.
	rlca			;c8ef	07 	.
	rlca			;c8f0	07 	.
	cpl			;c8f1	2f 	/
	ld b,a			;c8f2	47 	G
	ld a,(0ffd1h)		;c8f3	3a d1 ff 	: . .
	and b			;c8f6	a0 	.
	ld (0ffd1h),a		;c8f7	32 d1 ff 	2 . .
	xor a			;c8fa	af 	.
	ret			;c8fb	c9 	.
	xor a			;c8fc	af 	.
	ld (0ffd1h),a		;c8fd	32 d1 ff 	2 . .
	ret			;c900	c9 	.
	ld a,(0ffd9h)		;c901	3a d9 ff 	: . .
	ld b,a			;c904	47 	G
	ld d,000h		;c905	16 00 	. .
	ld e,a			;c907	5f 	_
	ld hl,0ffd9h		;c908	21 d9 ff 	! . .
	add hl,de			;c90b	19 	.
	ld a,c			;c90c	79 	y
	sub 020h		;c90d	d6 20 	.
	ld (hl),a			;c90f	77 	w
	ld a,b			;c910	78 	x
	inc a			;c911	3c 	<
	ld (0ffd9h),a		;c912	32 d9 ff 	2 . .
	ret			;c915	c9 	.
	ld a,b			;c916	78 	x
	out (0a0h),a		;c917	d3 a0 	. .
	ld a,c			;c919	79 	y
	out (0a1h),a		;c91a	d3 a1 	. .
	ret			;c91c	c9 	.
	call 0c6f1h		;c91d	cd f1 c6 	. . .
	push hl			;c920	e5 	.
	ld b,d			;c921	42 	B
	ld c,e			;c922	4b 	K
	call 0c6f1h		;c923	cd f1 c6 	. . .
	pop de			;c926	d1 	.
	push de			;c927	d5 	.
	or a			;c928	b7 	.
	sbc hl,de		;c929	ed 52 	. R
	inc hl			;c92b	23 	#
	ex de,hl			;c92c	eb 	.
	pop hl			;c92d	e1 	.
	ld b,a			;c92e	47 	G
	call 0c795h		;c92f	cd 95 c7 	. . .
	call 0c715h		;c932	cd 15 c7 	. . .
	ld a,(hl)			;c935	7e 	~
	or b			;c936	b0 	.
	ld (hl),a			;c937	77 	w
	inc hl			;c938	23 	#
	dec de			;c939	1b 	.
	ld a,d			;c93a	7a 	z
	or e			;c93b	b3 	.
	jr nz,$-10		;c93c	20 f4 	  .
	call 0c79eh		;c93e	cd 9e c7 	. . .
	ret			;c941	c9 	.
	ld a,c			;c942	79 	y
	cp 044h		;c943	fe 44 	. D
	jr nz,$+6		;c945	20 04 	  .
	ld c,040h		;c947	0e 40 	. @
	jr $+59		;c949	18 39 	. 9
	cp 045h		;c94b	fe 45 	. E
	jr nz,$+6		;c94d	20 04 	  .
	ld c,060h		;c94f	0e 60 	. `
	jr $+51		;c951	18 31 	. 1
	cp 046h		;c953	fe 46 	. F
	jr nz,$+6		;c955	20 04 	  .
	ld c,020h		;c957	0e 20 	.
	jr $+43		;c959	18 29 	. )
	ld a,(0c86fh)		;c95b	3a 6f c8 	: o .
	ld d,a			;c95e	57 	W
	in a,(0d6h)		;c95f	db d6 	. .
	bit 5,a		;c961	cb 6f 	. o
	jr z,$+4		;c963	28 02 	( .
	ld d,003h		;c965	16 03 	. .
	bit 6,a		;c967	cb 77 	. w
	jr z,$+6		;c969	28 04 	( .
	set 5,d		;c96b	cb ea 	. .
	set 6,d		;c96d	cb f2 	. .
	ld a,d			;c96f	7a 	z
	ld (0ffd3h),a		;c970	32 d3 ff 	2 . .
	ld b,00ah		;c973	06 0a 	. .
	ld c,a			;c975	4f 	O
	call 0c916h		;c976	cd 16 c9 	. . .
	ld a,(0c870h)		;c979	3a 70 c8 	: p .
	ld c,a			;c97c	4f 	O
	ld b,00bh		;c97d	06 0b 	. .
	call 0c916h		;c97f	cd 16 c9 	. . .
	xor a			;c982	af 	.
	ret			;c983	c9 	.
	ld a,(0ffd3h)		;c984	3a d3 ff 	: . .
	and 09fh		;c987	e6 9f 	. .
	or c			;c989	b1 	.
	ld (0ffd3h),a		;c98a	32 d3 ff 	2 . .
	ld c,a			;c98d	4f 	O
	ld b,00ah		;c98e	06 0a 	. .
	call 0c916h		;c990	cd 16 c9 	. . .
	xor a			;c993	af 	.
	ret			;c994	c9 	.
	ld hl,0ffd1h		;c995	21 d1 ff 	! . .
	set 0,(hl)		;c998	cb c6 	. .
	xor a			;c99a	af 	.
	ret			;c99b	c9 	.
	ld hl,0ffd1h		;c99c	21 d1 ff 	! . .
	res 0,(hl)		;c99f	cb 86 	. .
	xor a			;c9a1	af 	.
	ret			;c9a2	c9 	.
	ld hl,0ffd1h		;c9a3	21 d1 ff 	! . .
	set 2,(hl)		;c9a6	cb d6 	. .
	xor a			;c9a8	af 	.
	ret			;c9a9	c9 	.
	ld hl,0ffd1h		;c9aa	21 d1 ff 	! . .
	res 2,(hl)		;c9ad	cb 96 	. .
	xor a			;c9af	af 	.
	ret			;c9b0	c9 	.
	ld hl,0ffd1h		;c9b1	21 d1 ff 	! . .
	set 1,(hl)		;c9b4	cb ce 	. .
	xor a			;c9b6	af 	.
	ret			;c9b7	c9 	.
	ld hl,0ffd1h		;c9b8	21 d1 ff 	! . .
	res 1,(hl)		;c9bb	cb 8e 	. .
	xor a			;c9bd	af 	.
	ret			;c9be	c9 	.
	ld a,(0ffd1h)		;c9bf	3a d1 ff 	: . .
	and 08fh		;c9c2	e6 8f 	. .
	or 010h		;c9c4	f6 10 	. .
	ld (0ffd1h),a		;c9c6	32 d1 ff 	2 . .
	xor a			;c9c9	af 	.
	ret			;c9ca	c9 	.
	ld a,(0ffd1h)		;c9cb	3a d1 ff 	: . .
	and 08fh		;c9ce	e6 8f 	. .
	or 000h		;c9d0	f6 00 	. .
	ld (0ffd1h),a		;c9d2	32 d1 ff 	2 . .
	xor a			;c9d5	af 	.
	ret			;c9d6	c9 	.
	ld a,(0ffd1h)		;c9d7	3a d1 ff 	: . .
	and 08fh		;c9da	e6 8f 	. .
	or 020h		;c9dc	f6 20 	.
	ld (0ffd1h),a		;c9de	32 d1 ff 	2 . .
	xor a			;c9e1	af 	.
	ret			;c9e2	c9 	.
	call 0ca01h		;c9e3	cd 01 ca 	. . .
	cp 001h		;c9e6	fe 01 	. .
	jr nz,$+3		;c9e8	20 01 	  .
	ld a,c			;c9ea	79 	y
	ld (0ffd8h),a		;c9eb	32 d8 ff 	2 . .
	cp 060h		;c9ee	fe 60 	. `
	jp nc,0ca70h		;c9f0	d2 70 ca 	. p .
	sub 031h		;c9f3	d6 31 	. 1
	jp c,0ca70h		;c9f5	da 70 ca 	. p .
	call 0ca05h		;c9f8	cd 05 ca 	. . .
	or a			;c9fb	b7 	.
	jr z,$+116		;c9fc	28 72 	( r
	jp 0c6a3h		;c9fe	c3 a3 c6 	. . .
	ld hl,(0bffah)		;ca01	2a fa bf 	* . .
	jp (hl)			;ca04	e9 	.
	add a,a			;ca05	87 	.
	ld hl,0ca12h		;ca06	21 12 ca 	! . .
	ld d,000h		;ca09	16 00 	. .
	ld e,a			;ca0b	5f 	_
	add hl,de			;ca0c	19 	.
	ld e,(hl)			;ca0d	5e 	^
	inc hl			;ca0e	23 	#
	ld d,(hl)			;ca0f	56 	V
	ex de,hl			;ca10	eb 	.
	jp (hl)			;ca11	e9 	.
	ld b,d			;ca12	42 	B
	call 0cd46h		;ca13	cd 46 cd 	. F .
	ld a,d			;ca16	7a 	z
	jp z,0ca7ah		;ca17	ca 7a ca 	. z .
	ld a,d			;ca1a	7a 	z
	jp z,0ca7ch		;ca1b	ca 7c ca 	. | .
	cp a			;ca1e	bf 	.
	ret			;ca1f	c9 	.
	ld a,a			;ca20	7f 	
	call z,0ca7ah		;ca21	cc 7a ca 	. z .
	call nc,0f2cah		;ca24	d4 ca f2 	. . .
	jp z,0cb1ch		;ca27	ca 1c cb 	. . .
	ld l,d			;ca2a	6a 	j
	res 3,a		;ca2b	cb 9f 	. .
	res 7,e		;ca2d	cb bb 	. .
	bit 7,h		;ca2f	cb 7c 	. |
	jp z,0c875h		;ca31	ca 75 c8 	. u .
	xor h			;ca34	ac 	.
	ret z			;ca35	c8 	.
	ld a,d			;ca36	7a 	z
	jp z,0c942h		;ca37	ca 42 c9 	. B .
	ld b,d			;ca3a	42 	B
	ret			;ca3b	c9 	.
	ld b,d			;ca3c	42 	B
	ret			;ca3d	c9 	.
	ld b,d			;ca3e	42 	B
	ret			;ca3f	c9 	.
	sub l			;ca40	95 	.
	ret			;ca41	c9 	.
	sbc a,h			;ca42	9c 	.
	ret			;ca43	c9 	.
	and e			;ca44	a3 	.
	ret			;ca45	c9 	.
	xor d			;ca46	aa 	.
	ret			;ca47	c9 	.
	or c			;ca48	b1 	.
	ret			;ca49	c9 	.
	cp b			;ca4a	b8 	.
	ret			;ca4b	c9 	.
	ld b,l			;ca4c	45 	E
	call z,0ca7ah		;ca4d	cc 7a ca 	. z .
	xor e			;ca50	ab 	.
	call z,0ccdfh		;ca51	cc df cc 	. . .
	ld a,d			;ca54	7a 	z
	jp z,0cbdah		;ca55	ca da cb 	. . .
	inc b			;ca58	04 	.
	call z,0cc1bh		;ca59	cc 1b cc 	. . .
	inc sp			;ca5c	33 	3
	call z,0c9bfh		;ca5d	cc bf c9 	. . .
	set 1,c		;ca60	cb c9 	. .
	rst 10h			;ca62	d7 	.
	ret			;ca63	c9 	.
	cp a			;ca64	bf 	.
	ret			;ca65	c9 	.
	ld a,a			;ca66	7f 	
	call z,0c8dfh		;ca67	cc df c8 	. . .
	call m,095c8h		;ca6a	fc c8 95 	. . .
	call z,0cd27h		;ca6d	cc 27 cd 	. ' .
	xor a			;ca70	af 	.
	ld (0ffd8h),a		;ca71	32 d8 ff 	2 . .
	ld (0ffd9h),a		;ca74	32 d9 ff 	2 . .
	jp 0c6a3h		;ca77	c3 a3 c6 	. . .
	xor a			;ca7a	af 	.
	ret			;ca7b	c9 	.
	call 0cdd7h		;ca7c	cd d7 cd 	. . .
	cp 001h		;ca7f	fe 01 	. .
	jr nz,$+11		;ca81	20 09 	  .
	ld a,c			;ca83	79 	y
	cp 031h		;ca84	fe 31 	. 1
	jr c,$+42		;ca86	38 28 	8 (
	cp 036h		;ca88	fe 36 	. 6
	jr nc,$+38		;ca8a	30 24 	0 $
	call 0cab5h		;ca8c	cd b5 ca 	. . .
	or a			;ca8f	b7 	.
	ret nz			;ca90	c0 	.
	ld a,(0ffdah)		;ca91	3a da ff 	: . .
	and 00fh		;ca94	e6 0f 	. .
	dec a			;ca96	3d 	=
	add a,a			;ca97	87 	.
	ld b,a			;ca98	47 	G
	add a,a			;ca99	87 	.
	ld c,a			;ca9a	4f 	O
	add a,a			;ca9b	87 	.
	add a,b			;ca9c	80 	.
	add a,c			;ca9d	81 	.
	add a,004h		;ca9e	c6 04 	. .
	ld hl,(0bff4h)		;caa0	2a f4 bf 	* . .
	ld d,000h		;caa3	16 00 	. .
	ld e,a			;caa5	5f 	_
	add hl,de			;caa6	19 	.
	ex de,hl			;caa7	eb 	.
	ld hl,0ffdbh		;caa8	21 db ff 	! . .
	ld bc,00009h		;caab	01 09 00 	. . .
	ldir		;caae	ed b0 	. .
	call 0cd51h		;cab0	cd 51 cd 	. Q .
	xor a			;cab3	af 	.
	ret			;cab4	c9 	.
	call 0c901h		;cab5	cd 01 c9 	. . .
	ld (hl),c			;cab8	71 	q
	cp 00ah		;cab9	fe 0a 	. .
	ret nz			;cabb	c0 	.
	ld hl,0ffdbh		;cabc	21 db ff 	! . .
	ld b,008h		;cabf	06 08 	. .
	ld a,(hl)			;cac1	7e 	~
	inc hl			;cac2	23 	#
	cp 07fh		;cac3	fe 7f 	. 
	jr z,$+8		;cac5	28 06 	( .
	djnz $-6		;cac7	10 f8 	. .
	ld (hl),07fh		;cac9	36 7f 	6 
	jr $+7		;cacb	18 05 	. .
	ld hl,0ffe3h		;cacd	21 e3 ff 	! . .
	ld (hl),020h		;cad0	36 20 	6
	xor a			;cad2	af 	.
	ret			;cad3	c9 	.
	call 0cdd7h		;cad4	cd d7 cd 	. . .
	cp 004h		;cad7	fe 04 	. .
	jr z,$+6		;cad9	28 04 	( .
	call 0c901h		;cadb	cd 01 c9 	. . .
	ret			;cade	c9 	.
	ld a,c			;cadf	79 	y
	sub 020h		;cae0	d6 20 	.
	ld e,a			;cae2	5f 	_
	ld hl,0ffdah		;cae3	21 da ff 	! . .
	ld b,(hl)			;cae6	46 	F
	inc hl			;cae7	23 	#
	ld c,(hl)			;cae8	4e 	N
	inc hl			;cae9	23 	#
	ld d,(hl)			;caea	56 	V
	ld a,001h		;caeb	3e 01 	> .
	call 0c91dh		;caed	cd 1d c9 	. . .
	xor a			;caf0	af 	.
	ret			;caf1	c9 	.
	call 0cdd7h		;caf2	cd d7 cd 	. . .
	cp 002h		;caf5	fe 02 	. .
	jr z,$+6		;caf7	28 04 	( .
	call 0c901h		;caf9	cd 01 c9 	. . .
	ret			;cafc	c9 	.
	ld a,c			;cafd	79 	y
	sub 020h		;cafe	d6 20 	.
	ld e,a			;cb00	5f 	_
	ld a,(0ffdah)		;cb01	3a da ff 	: . .
	ld d,a			;cb04	57 	W
	ld a,(0ffd3h)		;cb05	3a d3 ff 	: . .
	and 060h		;cb08	e6 60 	. `
	or d			;cb0a	b2 	.
	ld (0ffd3h),a		;cb0b	32 d3 ff 	2 . .
	ld c,a			;cb0e	4f 	O
	ld b,00ah		;cb0f	06 0a 	. .
	call 0c916h		;cb11	cd 16 c9 	. . .
	ld c,e			;cb14	4b 	K
	ld b,00bh		;cb15	06 0b 	. .
	call 0c916h		;cb17	cd 16 c9 	. . .
	xor a			;cb1a	af 	.
	ret			;cb1b	c9 	.
	call 0cdd7h		;cb1c	cd d7 cd 	. . .
	cp 004h		;cb1f	fe 04 	. .
	jr z,$+6		;cb21	28 04 	( .
	call 0c901h		;cb23	cd 01 c9 	. . .
	ret			;cb26	c9 	.
	ld a,c			;cb27	79 	y
	sub 020h		;cb28	d6 20 	.
	ld e,a			;cb2a	5f 	_
	ld a,04fh		;cb2b	3e 4f 	> O
	cp e			;cb2d	bb 	.
	jr c,$+58		;cb2e	38 38 	8 8
	ld hl,0ffdah		;cb30	21 da ff 	! . .
	ld b,(hl)			;cb33	46 	F
	inc hl			;cb34	23 	#
	ld a,(hl)			;cb35	7e 	~
	cp 018h		;cb36	fe 18 	. .
	jr nc,$+48		;cb38	30 2e 	0 .
	ld c,a			;cb3a	4f 	O
	inc hl			;cb3b	23 	#
	ld d,(hl)			;cb3c	56 	V
	ld a,c			;cb3d	79 	y
	cp b			;cb3e	b8 	.
	jr c,$+41		;cb3f	38 27 	8 '
	ld a,e			;cb41	7b 	{
	cp d			;cb42	ba 	.
	jr c,$+37		;cb43	38 23 	8 #
	ld hl,0ffcdh		;cb45	21 cd ff 	! . .
	ld (hl),c			;cb48	71 	q
	inc hl			;cb49	23 	#
	ld (hl),b			;cb4a	70 	p
	inc hl			;cb4b	23 	#
	ld (hl),e			;cb4c	73 	s
	inc hl			;cb4d	23 	#
	ld (hl),d			;cb4e	72 	r
	ld a,001h		;cb4f	3e 01 	> .
	ld (0ffc9h),a		;cb51	32 c9 ff 	2 . .
	ld a,050h		;cb54	3e 50 	> P
	sub e			;cb56	93 	.
	ld e,a			;cb57	5f 	_
	ld a,d			;cb58	7a 	z
	add a,e			;cb59	83 	.
	ld hl,0ffd1h		;cb5a	21 d1 ff 	! . .
	bit 3,(hl)		;cb5d	cb 5e 	. ^
	jr z,$+3		;cb5f	28 01 	( .
	add a,a			;cb61	87 	.
	ld (0ffc8h),a		;cb62	32 c8 ff 	2 . .
	call 0cc1bh		;cb65	cd 1b cc 	. . .
	xor a			;cb68	af 	.
	ret			;cb69	c9 	.
	call 0cdd7h		;cb6a	cd d7 cd 	. . .
	cp 002h		;cb6d	fe 02 	. .
	jr z,$+6		;cb6f	28 04 	( .
	call 0c901h		;cb71	cd 01 c9 	. . .
	ret			;cb74	c9 	.
	ld a,c			;cb75	79 	y
	sub 020h		;cb76	d6 20 	.
	ld c,a			;cb78	4f 	O
	ld a,04fh		;cb79	3e 4f 	> O
	cp c			;cb7b	b9 	.
	jr c,$+33		;cb7c	38 1f 	8 .
	ld a,(0ffd1h)		;cb7e	3a d1 ff 	: . .
	bit 3,a		;cb81	cb 5f 	. _
	jr z,$+5		;cb83	28 03 	( .
	ld a,c			;cb85	79 	y
	add a,a			;cb86	87 	.
	ld c,a			;cb87	4f 	O
	ld a,(0ffdah)		;cb88	3a da ff 	: . .
	cp 019h		;cb8b	fe 19 	. .
	jr nc,$+16		;cb8d	30 0e 	0 .
	ld b,a			;cb8f	47 	G
	ld (0ffcbh),a		;cb90	32 cb ff 	2 . .
	ld a,c			;cb93	79 	y
	ld (0ffcah),a		;cb94	32 ca ff 	2 . .
	call 0c6f1h		;cb97	cd f1 c6 	. . .
	call 0c71ch		;cb9a	cd 1c c7 	. . .
	xor a			;cb9d	af 	.
	ret			;cb9e	c9 	.
	call 0cdd7h		;cb9f	cd d7 cd 	. . .
	ld a,c			;cba2	79 	y
	sub 020h		;cba3	d6 20 	.
	ld c,a			;cba5	4f 	O
	ld a,04fh		;cba6	3e 4f 	> O
	cp c			;cba8	b9 	.
	jr c,$+16		;cba9	38 0e 	8 .
	ld a,(0ffcbh)		;cbab	3a cb ff 	: . .
	ld b,a			;cbae	47 	G
	ld a,c			;cbaf	79 	y
	ld (0ffcah),a		;cbb0	32 ca ff 	2 . .
	call 0c6f1h		;cbb3	cd f1 c6 	. . .
	call 0c71ch		;cbb6	cd 1c c7 	. . .
	xor a			;cbb9	af 	.
	ret			;cbba	c9 	.
	call 0cdd7h		;cbbb	cd d7 cd 	. . .
	cp 004h		;cbbe	fe 04 	. .
	jr z,$+6		;cbc0	28 04 	( .
	call 0c901h		;cbc2	cd 01 c9 	. . .
	ret			;cbc5	c9 	.
	ld a,c			;cbc6	79 	y
	sub 020h		;cbc7	d6 20 	.
	ld e,a			;cbc9	5f 	_
	ld hl,0ffdah		;cbca	21 da ff 	! . .
	ld b,(hl)			;cbcd	46 	F
	inc hl			;cbce	23 	#
	ld c,(hl)			;cbcf	4e 	N
	inc hl			;cbd0	23 	#
	ld d,(hl)			;cbd1	56 	V
	ld a,(0ffd2h)		;cbd2	3a d2 ff 	: . .
	call 0c91dh		;cbd5	cd 1d c9 	. . .
	xor a			;cbd8	af 	.
	ret			;cbd9	c9 	.
	ld bc,00780h		;cbda	01 80 07 	. . .
	push ix		;cbdd	dd e5 	. .
	pop hl			;cbdf	e1 	.
	call 0c795h		;cbe0	cd 95 c7 	. . .
	ld a,(0ffd2h)		;cbe3	3a d2 ff 	: . .
	ld d,a			;cbe6	57 	W
	ld e,020h		;cbe7	1e 20 	.
	call 0c715h		;cbe9	cd 15 c7 	. . .
	ld a,(hl)			;cbec	7e 	~
	and d			;cbed	a2 	.
	jr nz,$+11		;cbee	20 09 	  .
	ld (hl),000h		;cbf0	36 00 	6 .
	call 0c795h		;cbf2	cd 95 c7 	. . .
	ld (hl),e			;cbf5	73 	s
	call 0c795h		;cbf6	cd 95 c7 	. . .
	inc hl			;cbf9	23 	#
	dec bc			;cbfa	0b 	.
	ld a,b			;cbfb	78 	x
	or c			;cbfc	b1 	.
	jr nz,$-20		;cbfd	20 ea 	  .
	call 0c79eh		;cbff	cd 9e c7 	. . .
	xor a			;cc02	af 	.
	ret			;cc03	c9 	.
	ld a,(0ffd0h)		;cc04	3a d0 ff 	: . .
	ld c,a			;cc07	4f 	O
	ld a,(0ffceh)		;cc08	3a ce ff 	: . .
	ld b,a			;cc0b	47 	G
	ld a,(0ffcfh)		;cc0c	3a cf ff 	: . .
	ld e,a			;cc0f	5f 	_
	ld a,(0ffcdh)		;cc10	3a cd ff 	: . .
	ld d,a			;cc13	57 	W
	call 0c805h		;cc14	cd 05 c8 	. . .
	call 0cc1bh		;cc17	cd 1b cc 	. . .
	ret			;cc1a	c9 	.
	ld a,(0ffceh)		;cc1b	3a ce ff 	: . .
	ld b,a			;cc1e	47 	G
	ld a,(0ffd0h)		;cc1f	3a d0 ff 	: . .
	ld c,a			;cc22	4f 	O
	call 0c6f1h		;cc23	cd f1 c6 	. . .
	call 0c71ch		;cc26	cd 1c c7 	. . .
	ld a,b			;cc29	78 	x
	ld (0ffcbh),a		;cc2a	32 cb ff 	2 . .
	ld a,c			;cc2d	79 	y
	ld (0ffcah),a		;cc2e	32 ca ff 	2 . .
	xor a			;cc31	af 	.
	ret			;cc32	c9 	.
	call 0c764h		;cc33	cd 64 c7 	. d .
	ld a,001h		;cc36	3e 01 	> .
	ld (0ffc8h),a		;cc38	32 c8 ff 	2 . .
	ld a,04fh		;cc3b	3e 4f 	> O
	ld (0ffcfh),a		;cc3d	32 cf ff 	2 . .
	call 0c8bfh		;cc40	cd bf c8 	. . .
	xor a			;cc43	af 	.
	ret			;cc44	c9 	.
	ld b,000h		;cc45	06 00 	. .
	ld c,000h		;cc47	0e 00 	. .
	push bc			;cc49	c5 	.
	call 0cdf4h		;cc4a	cd f4 cd 	. . .
	ld c,d			;cc4d	4a 	J
	push de			;cc4e	d5 	.
	call 0ffa0h		;cc4f	cd a0 ff 	. . .
	pop de			;cc52	d1 	.
	pop bc			;cc53	c1 	.
	bit 3,e		;cc54	cb 5b 	. [
	jr z,$+15		;cc56	28 0d 	( .
	inc c			;cc58	0c 	.
	ld a,c			;cc59	79 	y
	cp 050h		;cc5a	fe 50 	. P
	jr z,$+15		;cc5c	28 0d 	( .
	push bc			;cc5e	c5 	.
	ld c,020h		;cc5f	0e 20 	.
	call 0ffa0h		;cc61	cd a0 ff 	. . .
	pop bc			;cc64	c1 	.
	inc c			;cc65	0c 	.
	ld a,c			;cc66	79 	y
	cp 050h		;cc67	fe 50 	. P
	jr nz,$-32		;cc69	20 de 	  .
	push bc			;cc6b	c5 	.
	ld c,00dh		;cc6c	0e 0d 	. .
	call 0ffa0h		;cc6e	cd a0 ff 	. . .
	ld c,00ah		;cc71	0e 0a 	. .
	call 0ffa0h		;cc73	cd a0 ff 	. . .
	pop bc			;cc76	c1 	.
	inc b			;cc77	04 	.
	ld a,b			;cc78	78 	x
	cp 018h		;cc79	fe 18 	. .
	jr nz,$-52		;cc7b	20 ca 	  .
	xor a			;cc7d	af 	.
	ret			;cc7e	c9 	.
	call 0cdd7h		;cc7f	cd d7 cd 	. . .
	ld a,c			;cc82	79 	y
	and 00fh		;cc83	e6 0f 	. .
	rlca			;cc85	07 	.
	rlca			;cc86	07 	.
	rlca			;cc87	07 	.
	rlca			;cc88	07 	.
	ld b,a			;cc89	47 	G
	ld a,(0ffd1h)		;cc8a	3a d1 ff 	: . .
	and 00fh		;cc8d	e6 0f 	. .
	or b			;cc8f	b0 	.
	ld (0ffd1h),a		;cc90	32 d1 ff 	2 . .
	xor a			;cc93	af 	.
	ret			;cc94	c9 	.
	call 0cdd7h		;cc95	cd d7 cd 	. . .
	ld a,c			;cc98	79 	y
	cp 030h		;cc99	fe 30 	. 0
	jr z,$+16		;cc9b	28 0e 	( .
	cp 031h		;cc9d	fe 31 	. 1
	jr z,$+30		;cc9f	28 1c 	( .
	cp 032h		;cca1	fe 32 	. 2
	jr z,$+60		;cca3	28 3a 	( :
	cp 033h		;cca5	fe 33 	. 3
	jr z,$+77		;cca7	28 4b 	( K
	xor a			;cca9	af 	.
	ret			;ccaa	c9 	.
	ld a,(0ffcbh)		;ccab	3a cb ff 	: . .
	ld b,a			;ccae	47 	G
	ld d,a			;ccaf	57 	W
	ld a,(0ffcah)		;ccb0	3a ca ff 	: . .
	ld c,a			;ccb3	4f 	O
	ld a,(0ffcfh)		;ccb4	3a cf ff 	: . .
	ld e,a			;ccb7	5f 	_
	call 0c805h		;ccb8	cd 05 c8 	. . .
	xor a			;ccbb	af 	.
	ret			;ccbc	c9 	.
	ld a,(0ffceh)		;ccbd	3a ce ff 	: . .
	ld b,a			;ccc0	47 	G
	ld a,(0ffcbh)		;ccc1	3a cb ff 	: . .
	ld (0ffceh),a		;ccc4	32 ce ff 	2 . .
	ld a,(0ffc9h)		;ccc7	3a c9 ff 	: . .
	ld c,a			;ccca	4f 	O
	ld a,001h		;cccb	3e 01 	> .
	ld (0ffc9h),a		;cccd	32 c9 ff 	2 . .
	push bc			;ccd0	c5 	.
	call 0c62eh		;ccd1	cd 2e c6 	. . .
	pop bc			;ccd4	c1 	.
	ld a,b			;ccd5	78 	x
	ld (0ffceh),a		;ccd6	32 ce ff 	2 . .
	ld a,c			;ccd9	79 	y
	ld (0ffc9h),a		;ccda	32 c9 ff 	2 . .
	xor a			;ccdd	af 	.
	ret			;ccde	c9 	.
	ld a,(0ffcbh)		;ccdf	3a cb ff 	: . .
	ld b,a			;cce2	47 	G
	ld a,(0ffcah)		;cce3	3a ca ff 	: . .
	ld c,a			;cce6	4f 	O
	ld a,(0ffcdh)		;cce7	3a cd ff 	: . .
	ld d,a			;ccea	57 	W
	ld a,(0ffcfh)		;cceb	3a cf ff 	: . .
	ld e,a			;ccee	5f 	_
	call 0c805h		;ccef	cd 05 c8 	. . .
	xor a			;ccf2	af 	.
	ret			;ccf3	c9 	.
	ld a,(0ffceh)		;ccf4	3a ce ff 	: . .
	ld b,a			;ccf7	47 	G
	ld a,(0ffcbh)		;ccf8	3a cb ff 	: . .
	ld c,a			;ccfb	4f 	O
	ld a,(0ffcdh)		;ccfc	3a cd ff 	: . .
	cp c			;ccff	b9 	.
	jr z,$+24		;cd00	28 16 	( .
	ld a,c			;cd02	79 	y
	ld (0ffceh),a		;cd03	32 ce ff 	2 . .
	push bc			;cd06	c5 	.
	call 0c830h		;cd07	cd 30 c8 	. 0 .
	pop bc			;cd0a	c1 	.
	ld a,b			;cd0b	78 	x
	ld (0ffceh),a		;cd0c	32 ce ff 	2 . .
	ld a,(0ffd0h)		;cd0f	3a d0 ff 	: . .
	ld c,a			;cd12	4f 	O
	call 0cb9fh		;cd13	cd 9f cb 	. . .
	xor a			;cd16	af 	.
	ret			;cd17	c9 	.
	ld b,a			;cd18	47 	G
	ld d,a			;cd19	57 	W
	ld a,(0ffcfh)		;cd1a	3a cf ff 	: . .
	ld e,a			;cd1d	5f 	_
	ld a,(0ffd0h)		;cd1e	3a d0 ff 	: . .
	ld c,a			;cd21	4f 	O
	call 0c805h		;cd22	cd 05 c8 	. . .
	jr $-22		;cd25	18 e8 	. .
	call 0cdd7h		;cd27	cd d7 cd 	. . .
	cp 002h		;cd2a	fe 02 	. .
	jp nc,0cd8ah		;cd2c	d2 8a cd 	. . .
	ld a,c			;cd2f	79 	y
	cp 030h		;cd30	fe 30 	. 0
	jr z,$+16		;cd32	28 0e 	( .
	cp 031h		;cd34	fe 31 	. 1
	jr z,$+16		;cd36	28 0e 	( .
	cp 034h		;cd38	fe 34 	. 4
	jr z,$+23		;cd3a	28 15 	( .
	cp 035h		;cd3c	fe 35 	. 5
	jr z,$+76		;cd3e	28 4a 	( J
	xor a			;cd40	af 	.
	ret			;cd41	c9 	.
	ld b,019h		;cd42	06 19 	. .
	jr $+4		;cd44	18 02 	. .
	ld b,018h		;cd46	06 18 	. .
	ld a,006h		;cd48	3e 06 	> .
	out (0a0h),a		;cd4a	d3 a0 	. .
	ld a,b			;cd4c	78 	x
	out (0a1h),a		;cd4d	d3 a1 	. .
	xor a			;cd4f	af 	.
	ret			;cd50	c9 	.
	ld hl,(0bff4h)		;cd51	2a f4 bf 	* . .
	ex de,hl			;cd54	eb 	.
	ld b,018h		;cd55	06 18 	. .
	ld c,000h		;cd57	0e 00 	. .
	call 0c6f1h		;cd59	cd f1 c6 	. . .
	ld a,(0bfeah)		;cd5c	3a ea bf 	: . .
	ld c,a			;cd5f	4f 	O
	ld b,046h		;cd60	06 46 	. F
	ld a,b			;cd62	78 	x
	ld (0ffdah),a		;cd63	32 da ff 	2 . .
	call 0c715h		;cd66	cd 15 c7 	. . .
	ld a,(de)			;cd69	1a 	.
	ld (hl),a			;cd6a	77 	w
	call 0c795h		;cd6b	cd 95 c7 	. . .
	ld (hl),c			;cd6e	71 	q
	call 0c79eh		;cd6f	cd 9e c7 	. . .
	inc de			;cd72	13 	.
	inc hl			;cd73	23 	#
	djnz $-14		;cd74	10 f0 	. .
	ld a,(0ffdah)		;cd76	3a da ff 	: . .
	or a			;cd79	b7 	.
	jr z,$+14		;cd7a	28 0c 	( .
	ld b,00ah		;cd7c	06 0a 	. .
	ld a,(0bfebh)		;cd7e	3a eb bf 	: . .
	ld c,a			;cd81	4f 	O
	xor a			;cd82	af 	.
	ld (0ffdah),a		;cd83	32 da ff 	2 . .
	jr $-32		;cd86	18 de 	. .
	xor a			;cd88	af 	.
	ret			;cd89	c9 	.
	ld a,c			;cd8a	79 	y
	cp 00dh		;cd8b	fe 0d 	. .
	jr z,$+40		;cd8d	28 26 	( &
	ld a,(0ffd9h)		;cd8f	3a d9 ff 	: . .
	cp 001h		;cd92	fe 01 	. .
	jr z,$+6		;cd94	28 04 	( .
	call 0cdb7h		;cd96	cd b7 cd 	. . .
	ret			;cd99	c9 	.
	ld b,018h		;cd9a	06 18 	. .
	ld c,000h		;cd9c	0e 00 	. .
	call 0c6f1h		;cd9e	cd f1 c6 	. . .
	ld (0ffdah),hl		;cda1	22 da ff 	" . .
	ld a,002h		;cda4	3e 02 	> .
	ld (0ffd9h),a		;cda6	32 d9 ff 	2 . .
	ld b,046h		;cda9	06 46 	. F
	ld c,020h		;cdab	0e 20 	.
	call 0c715h		;cdad	cd 15 c7 	. . .
	ld (hl),c			;cdb0	71 	q
	inc hl			;cdb1	23 	#
	djnz $-5		;cdb2	10 f9 	. .
	ret			;cdb4	c9 	.
	xor a			;cdb5	af 	.
	ret			;cdb6	c9 	.
	ld b,a			;cdb7	47 	G
	inc a			;cdb8	3c 	<
	ld (0ffd9h),a		;cdb9	32 d9 ff 	2 . .
	ld hl,(0ffdah)		;cdbc	2a da ff 	* . .
	call 0c715h		;cdbf	cd 15 c7 	. . .
	ld (hl),c			;cdc2	71 	q
	ld a,(0bfebh)		;cdc3	3a eb bf 	: . .
	call 0c795h		;cdc6	cd 95 c7 	. . .
	ld (hl),a			;cdc9	77 	w
	call 0c79eh		;cdca	cd 9e c7 	. . .
	inc hl			;cdcd	23 	#
	ld (0ffdah),hl		;cdce	22 da ff 	" . .
	ld a,b			;cdd1	78 	x
	cp 047h		;cdd2	fe 47 	. G
	ret nz			;cdd4	c0 	.
	xor a			;cdd5	af 	.
	ret			;cdd6	c9 	.
	ld a,(0ffd9h)		;cdd7	3a d9 ff 	: . .
	or a			;cdda	b7 	.
	ret nz			;cddb	c0 	.
	inc a			;cddc	3c 	<
	ld (0ffd9h),a		;cddd	32 d9 ff 	2 . .
	pop hl			;cde0	e1 	.
	ret			;cde1	c9 	.
	call 0c69ah		;cde2	cd 9a c6 	. . .
	call 0c6f1h		;cde5	cd f1 c6 	. . .
	call 0c715h		;cde8	cd 15 c7 	. . .
	ld (hl),d			;cdeb	72 	r
	call 0c795h		;cdec	cd 95 c7 	. . .
	ld (hl),e			;cdef	73 	s
	call 0c79eh		;cdf0	cd 9e c7 	. . .
	ret			;cdf3	c9 	.
	call 0c69ah		;cdf4	cd 9a c6 	. . .
	call 0c6f1h		;cdf7	cd f1 c6 	. . .
	call 0c715h		;cdfa	cd 15 c7 	. . .
	ld d,(hl)			;cdfd	56 	V
	call 0c795h		;cdfe	cd 95 c7 	. . .
	ld e,(hl)			;ce01	5e 	^
	call 0c79eh		;ce02	cd 9e c7 	. . .
	ret			;ce05	c9 	.
	nop			;ce06	00 	.
	nop			;ce07	00 	.
	nop			;ce08	00 	.
	nop			;ce09	00 	.
	nop			;ce0a	00 	.
	nop			;ce0b	00 	.
	nop			;ce0c	00 	.
	nop			;ce0d	00 	.
	nop			;ce0e	00 	.
	nop			;ce0f	00 	.
	nop			;ce10	00 	.
	nop			;ce11	00 	.
	nop			;ce12	00 	.
	nop			;ce13	00 	.
	nop			;ce14	00 	.
	nop			;ce15	00 	.
	nop			;ce16	00 	.
	nop			;ce17	00 	.
	nop			;ce18	00 	.
	nop			;ce19	00 	.
	nop			;ce1a	00 	.
	nop			;ce1b	00 	.
	nop			;ce1c	00 	.
	nop			;ce1d	00 	.
	nop			;ce1e	00 	.
	nop			;ce1f	00 	.
	nop			;ce20	00 	.
	nop			;ce21	00 	.
	nop			;ce22	00 	.
	nop			;ce23	00 	.
	nop			;ce24	00 	.
	nop			;ce25	00 	.
	nop			;ce26	00 	.
	nop			;ce27	00 	.
	nop			;ce28	00 	.
	nop			;ce29	00 	.
	nop			;ce2a	00 	.
	nop			;ce2b	00 	.
	nop			;ce2c	00 	.
	nop			;ce2d	00 	.
	nop			;ce2e	00 	.
	nop			;ce2f	00 	.
	nop			;ce30	00 	.
	nop			;ce31	00 	.
	nop			;ce32	00 	.
	nop			;ce33	00 	.
	nop			;ce34	00 	.
	nop			;ce35	00 	.
	nop			;ce36	00 	.
	nop			;ce37	00 	.
	nop			;ce38	00 	.
	nop			;ce39	00 	.
	nop			;ce3a	00 	.
	nop			;ce3b	00 	.
	nop			;ce3c	00 	.
	nop			;ce3d	00 	.
	nop			;ce3e	00 	.
	nop			;ce3f	00 	.
	nop			;ce40	00 	.
	nop			;ce41	00 	.
	nop			;ce42	00 	.
	nop			;ce43	00 	.
	nop			;ce44	00 	.
	nop			;ce45	00 	.
	nop			;ce46	00 	.
	nop			;ce47	00 	.
	nop			;ce48	00 	.
	nop			;ce49	00 	.
	nop			;ce4a	00 	.
	nop			;ce4b	00 	.
	nop			;ce4c	00 	.
	nop			;ce4d	00 	.
	nop			;ce4e	00 	.
	nop			;ce4f	00 	.
	nop			;ce50	00 	.
	nop			;ce51	00 	.
	nop			;ce52	00 	.
	nop			;ce53	00 	.
	nop			;ce54	00 	.
	nop			;ce55	00 	.
	nop			;ce56	00 	.
	nop			;ce57	00 	.
	nop			;ce58	00 	.
	nop			;ce59	00 	.
	nop			;ce5a	00 	.
	nop			;ce5b	00 	.
	nop			;ce5c	00 	.
	nop			;ce5d	00 	.
	nop			;ce5e	00 	.
	nop			;ce5f	00 	.
	nop			;ce60	00 	.
	nop			;ce61	00 	.
	nop			;ce62	00 	.
	nop			;ce63	00 	.
	nop			;ce64	00 	.
	nop			;ce65	00 	.
	nop			;ce66	00 	.
	nop			;ce67	00 	.
	nop			;ce68	00 	.
	nop			;ce69	00 	.
	nop			;ce6a	00 	.
	nop			;ce6b	00 	.
	nop			;ce6c	00 	.
	nop			;ce6d	00 	.
	nop			;ce6e	00 	.
	nop			;ce6f	00 	.
	nop			;ce70	00 	.
	nop			;ce71	00 	.
	nop			;ce72	00 	.
	nop			;ce73	00 	.
	nop			;ce74	00 	.
	nop			;ce75	00 	.
	nop			;ce76	00 	.
	nop			;ce77	00 	.
	nop			;ce78	00 	.
	nop			;ce79	00 	.
	nop			;ce7a	00 	.
	nop			;ce7b	00 	.
	nop			;ce7c	00 	.
	nop			;ce7d	00 	.
	nop			;ce7e	00 	.
	nop			;ce7f	00 	.
	nop			;ce80	00 	.
	nop			;ce81	00 	.
	nop			;ce82	00 	.
	nop			;ce83	00 	.
	nop			;ce84	00 	.
	nop			;ce85	00 	.
	nop			;ce86	00 	.
	nop			;ce87	00 	.
	nop			;ce88	00 	.
	nop			;ce89	00 	.
	nop			;ce8a	00 	.
	nop			;ce8b	00 	.
	nop			;ce8c	00 	.
	nop			;ce8d	00 	.
	nop			;ce8e	00 	.
	nop			;ce8f	00 	.
	nop			;ce90	00 	.
	nop			;ce91	00 	.
	nop			;ce92	00 	.
	nop			;ce93	00 	.
	nop			;ce94	00 	.
	nop			;ce95	00 	.
	nop			;ce96	00 	.
	nop			;ce97	00 	.
	nop			;ce98	00 	.
	nop			;ce99	00 	.
	nop			;ce9a	00 	.
	nop			;ce9b	00 	.
	nop			;ce9c	00 	.
	nop			;ce9d	00 	.
	nop			;ce9e	00 	.
	nop			;ce9f	00 	.
	nop			;cea0	00 	.
	nop			;cea1	00 	.
	nop			;cea2	00 	.
	nop			;cea3	00 	.
	nop			;cea4	00 	.
	nop			;cea5	00 	.
	nop			;cea6	00 	.
	nop			;cea7	00 	.
	nop			;cea8	00 	.
	nop			;cea9	00 	.
	nop			;ceaa	00 	.
	nop			;ceab	00 	.
	nop			;ceac	00 	.
	nop			;cead	00 	.
	nop			;ceae	00 	.
	nop			;ceaf	00 	.
	nop			;ceb0	00 	.
	nop			;ceb1	00 	.
	nop			;ceb2	00 	.
	nop			;ceb3	00 	.
	nop			;ceb4	00 	.
	nop			;ceb5	00 	.
	nop			;ceb6	00 	.
	nop			;ceb7	00 	.
	nop			;ceb8	00 	.
	nop			;ceb9	00 	.
	nop			;ceba	00 	.
	nop			;cebb	00 	.
	nop			;cebc	00 	.
	nop			;cebd	00 	.
	nop			;cebe	00 	.
	nop			;cebf	00 	.
	nop			;cec0	00 	.
	nop			;cec1	00 	.
	nop			;cec2	00 	.
	nop			;cec3	00 	.
	nop			;cec4	00 	.
	nop			;cec5	00 	.
	nop			;cec6	00 	.
	nop			;cec7	00 	.
	nop			;cec8	00 	.
	nop			;cec9	00 	.
	nop			;ceca	00 	.
	nop			;cecb	00 	.
	nop			;cecc	00 	.
	nop			;cecd	00 	.
	nop			;cece	00 	.
	nop			;cecf	00 	.
	nop			;ced0	00 	.
	nop			;ced1	00 	.
	nop			;ced2	00 	.
	nop			;ced3	00 	.
	nop			;ced4	00 	.
	nop			;ced5	00 	.
	nop			;ced6	00 	.
	nop			;ced7	00 	.
	nop			;ced8	00 	.
	nop			;ced9	00 	.
	nop			;ceda	00 	.
	nop			;cedb	00 	.
	nop			;cedc	00 	.
	nop			;cedd	00 	.
	nop			;cede	00 	.
	nop			;cedf	00 	.
	nop			;cee0	00 	.
	nop			;cee1	00 	.
	nop			;cee2	00 	.
	nop			;cee3	00 	.
	nop			;cee4	00 	.
	nop			;cee5	00 	.
	nop			;cee6	00 	.
	nop			;cee7	00 	.
	nop			;cee8	00 	.
	nop			;cee9	00 	.
	nop			;ceea	00 	.
	nop			;ceeb	00 	.
	nop			;ceec	00 	.
	nop			;ceed	00 	.
	nop			;ceee	00 	.
	nop			;ceef	00 	.
	nop			;cef0	00 	.
	nop			;cef1	00 	.
	nop			;cef2	00 	.
	nop			;cef3	00 	.
	nop			;cef4	00 	.
	nop			;cef5	00 	.
	nop			;cef6	00 	.
	nop			;cef7	00 	.
	nop			;cef8	00 	.
	nop			;cef9	00 	.
	nop			;cefa	00 	.
	nop			;cefb	00 	.
	nop			;cefc	00 	.
	nop			;cefd	00 	.
	nop			;cefe	00 	.
	nop			;ceff	00 	.
	nop			;cf00	00 	.
	nop			;cf01	00 	.
	nop			;cf02	00 	.
	nop			;cf03	00 	.
	nop			;cf04	00 	.
	nop			;cf05	00 	.
	nop			;cf06	00 	.
	nop			;cf07	00 	.
	nop			;cf08	00 	.
	nop			;cf09	00 	.
	nop			;cf0a	00 	.
	nop			;cf0b	00 	.
	nop			;cf0c	00 	.
	nop			;cf0d	00 	.
	nop			;cf0e	00 	.
	nop			;cf0f	00 	.
	nop			;cf10	00 	.
	nop			;cf11	00 	.
	nop			;cf12	00 	.
	nop			;cf13	00 	.
	nop			;cf14	00 	.
	nop			;cf15	00 	.
	nop			;cf16	00 	.
	nop			;cf17	00 	.
	nop			;cf18	00 	.
	nop			;cf19	00 	.
	nop			;cf1a	00 	.
	nop			;cf1b	00 	.
	nop			;cf1c	00 	.
	nop			;cf1d	00 	.
	nop			;cf1e	00 	.
	nop			;cf1f	00 	.
	nop			;cf20	00 	.
	nop			;cf21	00 	.
	nop			;cf22	00 	.
	nop			;cf23	00 	.
	nop			;cf24	00 	.
	nop			;cf25	00 	.
	nop			;cf26	00 	.
	nop			;cf27	00 	.
	nop			;cf28	00 	.
	nop			;cf29	00 	.
	nop			;cf2a	00 	.
	nop			;cf2b	00 	.
	nop			;cf2c	00 	.
	nop			;cf2d	00 	.
	nop			;cf2e	00 	.
	nop			;cf2f	00 	.
	nop			;cf30	00 	.
	nop			;cf31	00 	.
	nop			;cf32	00 	.
	nop			;cf33	00 	.
	nop			;cf34	00 	.
	nop			;cf35	00 	.
	nop			;cf36	00 	.
	nop			;cf37	00 	.
	nop			;cf38	00 	.
	nop			;cf39	00 	.
	nop			;cf3a	00 	.
	nop			;cf3b	00 	.
	nop			;cf3c	00 	.
	nop			;cf3d	00 	.
	nop			;cf3e	00 	.
	nop			;cf3f	00 	.
	nop			;cf40	00 	.
	nop			;cf41	00 	.
	nop			;cf42	00 	.
	nop			;cf43	00 	.
	nop			;cf44	00 	.
	nop			;cf45	00 	.
	nop			;cf46	00 	.
	nop			;cf47	00 	.
	nop			;cf48	00 	.
	nop			;cf49	00 	.
	nop			;cf4a	00 	.
	nop			;cf4b	00 	.
	nop			;cf4c	00 	.
	nop			;cf4d	00 	.
	nop			;cf4e	00 	.
	nop			;cf4f	00 	.
	nop			;cf50	00 	.
	nop			;cf51	00 	.
	nop			;cf52	00 	.
	nop			;cf53	00 	.
	nop			;cf54	00 	.
	nop			;cf55	00 	.
	nop			;cf56	00 	.
	nop			;cf57	00 	.
	nop			;cf58	00 	.
	nop			;cf59	00 	.
	nop			;cf5a	00 	.
	nop			;cf5b	00 	.
	nop			;cf5c	00 	.
	nop			;cf5d	00 	.
	nop			;cf5e	00 	.
	nop			;cf5f	00 	.
	nop			;cf60	00 	.
	nop			;cf61	00 	.
	nop			;cf62	00 	.
	nop			;cf63	00 	.
	nop			;cf64	00 	.
	nop			;cf65	00 	.
	nop			;cf66	00 	.
	nop			;cf67	00 	.
	nop			;cf68	00 	.
	nop			;cf69	00 	.
	nop			;cf6a	00 	.
	nop			;cf6b	00 	.
	nop			;cf6c	00 	.
	nop			;cf6d	00 	.
	nop			;cf6e	00 	.
	nop			;cf6f	00 	.
	nop			;cf70	00 	.
	nop			;cf71	00 	.
	nop			;cf72	00 	.
	nop			;cf73	00 	.
	nop			;cf74	00 	.
	nop			;cf75	00 	.
	nop			;cf76	00 	.
	nop			;cf77	00 	.
	nop			;cf78	00 	.
	nop			;cf79	00 	.
	nop			;cf7a	00 	.
	nop			;cf7b	00 	.
	nop			;cf7c	00 	.
	nop			;cf7d	00 	.
	nop			;cf7e	00 	.
	nop			;cf7f	00 	.
	nop			;cf80	00 	.
	nop			;cf81	00 	.
	nop			;cf82	00 	.
	nop			;cf83	00 	.
	nop			;cf84	00 	.
	nop			;cf85	00 	.
	nop			;cf86	00 	.
	nop			;cf87	00 	.
	nop			;cf88	00 	.
	nop			;cf89	00 	.
	nop			;cf8a	00 	.
	nop			;cf8b	00 	.
	nop			;cf8c	00 	.
	nop			;cf8d	00 	.
	nop			;cf8e	00 	.
	nop			;cf8f	00 	.
	nop			;cf90	00 	.
	nop			;cf91	00 	.
	nop			;cf92	00 	.
	nop			;cf93	00 	.
	nop			;cf94	00 	.
	nop			;cf95	00 	.
	nop			;cf96	00 	.
	nop			;cf97	00 	.
	nop			;cf98	00 	.
	nop			;cf99	00 	.
	nop			;cf9a	00 	.
	nop			;cf9b	00 	.
	nop			;cf9c	00 	.
	nop			;cf9d	00 	.
	nop			;cf9e	00 	.
	nop			;cf9f	00 	.
	nop			;cfa0	00 	.
	nop			;cfa1	00 	.
	nop			;cfa2	00 	.
	nop			;cfa3	00 	.
	nop			;cfa4	00 	.
	nop			;cfa5	00 	.
	nop			;cfa6	00 	.
	nop			;cfa7	00 	.
	nop			;cfa8	00 	.
	nop			;cfa9	00 	.
	nop			;cfaa	00 	.
	nop			;cfab	00 	.
	nop			;cfac	00 	.
	nop			;cfad	00 	.
	nop			;cfae	00 	.
	nop			;cfaf	00 	.
	nop			;cfb0	00 	.
	nop			;cfb1	00 	.
	nop			;cfb2	00 	.
	nop			;cfb3	00 	.
	nop			;cfb4	00 	.
	nop			;cfb5	00 	.
	nop			;cfb6	00 	.
	nop			;cfb7	00 	.
	nop			;cfb8	00 	.
	nop			;cfb9	00 	.
	nop			;cfba	00 	.
	nop			;cfbb	00 	.
	nop			;cfbc	00 	.
	nop			;cfbd	00 	.
	nop			;cfbe	00 	.
	nop			;cfbf	00 	.
	nop			;cfc0	00 	.
	nop			;cfc1	00 	.
	nop			;cfc2	00 	.
	nop			;cfc3	00 	.
	nop			;cfc4	00 	.
	nop			;cfc5	00 	.
	nop			;cfc6	00 	.
	nop			;cfc7	00 	.
	nop			;cfc8	00 	.
	nop			;cfc9	00 	.
	nop			;cfca	00 	.
	nop			;cfcb	00 	.
	nop			;cfcc	00 	.
	nop			;cfcd	00 	.
	nop			;cfce	00 	.
	nop			;cfcf	00 	.
	nop			;cfd0	00 	.
	nop			;cfd1	00 	.
	nop			;cfd2	00 	.
	nop			;cfd3	00 	.
	nop			;cfd4	00 	.
	nop			;cfd5	00 	.
	nop			;cfd6	00 	.
	nop			;cfd7	00 	.
	nop			;cfd8	00 	.
	nop			;cfd9	00 	.
	nop			;cfda	00 	.
	nop			;cfdb	00 	.
	nop			;cfdc	00 	.
	nop			;cfdd	00 	.
	nop			;cfde	00 	.
	nop			;cfdf	00 	.
	nop			;cfe0	00 	.
	nop			;cfe1	00 	.
	nop			;cfe2	00 	.
	nop			;cfe3	00 	.
	nop			;cfe4	00 	.
	nop			;cfe5	00 	.
	nop			;cfe6	00 	.
	nop			;cfe7	00 	.
	nop			;cfe8	00 	.
	nop			;cfe9	00 	.
	nop			;cfea	00 	.
	nop			;cfeb	00 	.
	nop			;cfec	00 	.
	nop			;cfed	00 	.
	nop			;cfee	00 	.
	nop			;cfef	00 	.
	nop			;cff0	00 	.
	nop			;cff1	00 	.
	nop			;cff2	00 	.
	nop			;cff3	00 	.
	nop			;cff4	00 	.
	nop			;cff5	00 	.
	nop			;cff6	00 	.
	nop			;cff7	00 	.
	nop			;cff8	00 	.
	nop			;cff9	00 	.
	nop			;cffa	00 	.
	nop			;cffb	00 	.
	ld sp,0302eh		;cffc	31 2e 30 	1 . 0
	ld sp,030c3h		;cfff	31 c3 30 	1 . 0
	ret nz			;d002	c0 	.
	jp 0c027h		;d003	c3 27 c0 	. ' .
	jp 0c027h		;d006	c3 27 c0 	. ' .
	jp 0c45eh		;d009	c3 5e c4 	. ^ .
	jp 0c027h		;d00c	c3 27 c0 	. ' .
	jp 0c027h		;d00f	c3 27 c0 	. ' .
	jp 0c027h		;d012	c3 27 c0 	. ' .
	jp 0c027h		;d015	c3 27 c0 	. ' .
	jp 0c19dh		;d018	c3 9d c1 	. . .
	jp 0c18fh		;d01b	c3 8f c1 	. . .
	jp 0c174h		;d01e	c3 74 c1 	. t .
	jp 0cde2h		;d021	c3 e2 cd 	. . .
	jp 0cdf4h		;d024	c3 f4 cd 	. . .
	di			;d027	f3 	.
	ld a,010h		;d028	3e 10 	> .
	out (0b1h),a		;d02a	d3 b1 	. .
	out (0b3h),a		;d02c	d3 b3 	. .
	jr $+18		;d02e	18 10 	. .
	ld a,089h		;d030	3e 89 	> .
	out (083h),a		;d032	d3 83 	. .
	di			;d034	f3 	.
	ld a,010h		;d035	3e 10 	> .
	out (081h),a		;d037	d3 81 	. .
	ld h,07dh		;d039	26 7d 	& }
	dec hl			;d03b	2b 	+
	ld a,h			;d03c	7c 	|
	or l			;d03d	b5 	.
	jr nz,$-3		;d03e	20 fb 	  .
	ld sp,00080h		;d040	31 80 00 	1 . .
	call 0c0c2h		;d043	cd c2 c0 	. . .
	call 0c6afh		;d046	cd af c6 	. . .
	call 0c14eh		;d049	cd 4e c1 	. N .
	ld a,012h		;d04c	3e 12 	> .
	out (0b2h),a		;d04e	d3 b2 	. .
	in a,(0b3h)		;d050	db b3 	. .
	bit 0,a		;d052	cb 47 	. G
	jr z,$-4		;d054	28 fa 	( .
	in a,(0b2h)		;d056	db b2 	. .
	out (0dah),a		;d058	d3 da 	. .
	ld c,056h		;d05a	0e 56 	. V
	call 0c45eh		;d05c	cd 5e c4 	. ^ .
	ld hl,0cffch		;d05f	21 fc cf 	! . .
	ld b,004h		;d062	06 04 	. .
	ld c,(hl)			;d064	4e 	N
	inc hl			;d065	23 	#
	call 0c45eh		;d066	cd 5e c4 	. ^ .
	djnz $-5		;d069	10 f9 	. .
	call 0c0a7h		;d06b	cd a7 c0 	. . .
	ld a,b			;d06e	78 	x
	cp 04dh		;d06f	fe 4d 	. M
	jr z,$+23		;d071	28 15 	( .
	cp 05ch		;d073	fe 5c 	. \
	jr nz,$-10		;d075	20 f4 	  .
	ld a,(08000h)		;d077	3a 00 80 	: . .
	cpl			;d07a	2f 	/
	ld (08000h),a		;d07b	32 00 80 	2 . .
	ld a,(08000h)		;d07e	3a 00 80 	: . .
	cp 0c3h		;d081	fe c3 	. .
	jr nz,$-92		;d083	20 a2 	  .
	jp 08000h		;d085	c3 00 80 	. . .
	ld de,00000h		;d088	11 00 00 	. . .
	ld bc,04000h		;d08b	01 00 40 	. . @
	ld hl,00080h		;d08e	21 80 00 	! . .
	ld a,001h		;d091	3e 01 	> .
	call 0c19dh		;d093	cd 9d c1 	. . .
	cp 0ffh		;d096	fe ff 	. .
	jr nz,$+6		;d098	20 04 	  .
	out (0dah),a		;d09a	d3 da 	. .
	jr $-20		;d09c	18 ea 	. .
	ld a,006h		;d09e	3e 06 	> .
	out (0b2h),a		;d0a0	d3 b2 	. .
	out (0dah),a		;d0a2	d3 da 	. .
	jp 00080h		;d0a4	c3 80 00 	. . .
	in a,(0b3h)		;d0a7	db b3 	. .
	bit 0,a		;d0a9	cb 47 	. G
	jr z,$-4		;d0ab	28 fa 	( .
	in a,(0b2h)		;d0ad	db b2 	. .
	ld b,a			;d0af	47 	G
	bit 7,a		;d0b0	cb 7f 	. 
	jr nz,$-11		;d0b2	20 f3 	  .
	in a,(0b3h)		;d0b4	db b3 	. .
	bit 0,a		;d0b6	cb 47 	. G
	jr z,$-4		;d0b8	28 fa 	( .
	in a,(0b2h)		;d0ba	db b2 	. .
	ld c,a			;d0bc	4f 	O
	bit 7,a		;d0bd	cb 7f 	. 
	jr z,$-11		;d0bf	28 f3 	( .
	ret			;d0c1	c9 	.
	im 2		;d0c2	ed 5e 	. ^
	call 0c0d1h		;d0c4	cd d1 c0 	. . .
	call 0c43fh		;d0c7	cd 3f c4 	. ? .
	call 0c108h		;d0ca	cd 08 c1 	. . .
	call 0c88dh		;d0cd	cd 8d c8 	. . .
	ret			;d0d0	c9 	.
	ld hl,0c0f1h		;d0d1	21 f1 c0 	! . .
	ld a,(hl)			;d0d4	7e 	~
	inc hl			;d0d5	23 	#
	cp 0ffh		;d0d6	fe ff 	. .
	jr z,$+9		;d0d8	28 07 	( .
	ld c,a			;d0da	4f 	O
	ld a,(hl)			;d0db	7e 	~
	inc hl			;d0dc	23 	#
	out (c),a		;d0dd	ed 79 	. y
	jr $-11		;d0df	18 f3 	. .
	in a,(0d6h)		;d0e1	db d6 	. .
	and 007h		;d0e3	e6 07 	. .
	ld d,000h		;d0e5	16 00 	. .
	ld e,a			;d0e7	5f 	_
	add hl,de			;d0e8	19 	.
	ld a,(hl)			;d0e9	7e 	~
	out (0e1h),a		;d0ea	d3 e1 	. .
	ld a,041h		;d0ec	3e 41 	> A
	out (0e1h),a		;d0ee	d3 e1 	. .
	ret			;d0f0	c9 	.
	jp po,0e205h		;d0f1	e2 05 e2 	. . .
	djnz $-28		;d0f4	10 e2 	. .
	ld b,c			;d0f6	41 	A
	ex (sp),hl			;d0f7	e3 	.
	dec b			;d0f8	05 	.
	ex (sp),hl			;d0f9	e3 	.
	ld bc,041e3h		;d0fa	01 e3 41 	. . A
	pop hl			;d0fd	e1 	.
	dec b			;d0fe	05 	.
	rst 38h			;d0ff	ff 	.
	xor (hl)			;d100	ae 	.
	ld b,b			;d101	40 	@
	jr nz,$+18		;d102	20 10 	  .
	ex af,af'			;d104	08 	.
	inc b			;d105	04 	.
	ld (bc),a			;d106	02 	.
	ld bc,03421h		;d107	01 21 34 	. ! 4
	pop bc			;d10a	c1 	.
	ld a,(hl)			;d10b	7e 	~
	inc hl			;d10c	23 	#
	cp 0ffh		;d10d	fe ff 	. .
	jr z,$+10		;d10f	28 08 	( .
	out (0b1h),a		;d111	d3 b1 	. .
	ld a,(hl)			;d113	7e 	~
	out (0b1h),a		;d114	d3 b1 	. .
	inc hl			;d116	23 	#
	jr $-12		;d117	18 f2 	. .
	ld a,(hl)			;d119	7e 	~
	cp 0ffh		;d11a	fe ff 	. .
	jr z,$+11		;d11c	28 09 	( .
	out (0b3h),a		;d11e	d3 b3 	. .
	inc hl			;d120	23 	#
	ld a,(hl)			;d121	7e 	~
	out (0b3h),a		;d122	d3 b3 	. .
	inc hl			;d124	23 	#
	jr $-12		;d125	18 f2 	. .
	in a,(0b0h)		;d127	db b0 	. .
	in a,(0b2h)		;d129	db b2 	. .
	in a,(0b0h)		;d12b	db b0 	. .
	in a,(0b2h)		;d12d	db b2 	. .
	in a,(0b0h)		;d12f	db b0 	. .
	in a,(0b2h)		;d131	db b2 	. .
	ret			;d133	c9 	.
	nop			;d134	00 	.
	djnz $+2		;d135	10 00 	. .
	djnz $+6		;d137	10 04 	. .
	ld b,h			;d139	44 	D
	ld bc,00300h		;d13a	01 00 03 	. . .
	pop bc			;d13d	c1 	.
	dec b			;d13e	05 	.
	jp pe,000ffh		;d13f	ea ff 00 	. . .
	djnz $+2		;d142	10 00 	. .
	djnz $+6		;d144	10 04 	. .
	ld b,h			;d146	44 	D
	ld bc,00300h		;d147	01 00 03 	. . .
	pop bc			;d14a	c1 	.
	dec b			;d14b	05 	.
	jp pe,021ffh		;d14c	ea ff 21 	. . !
	ld h,l			;d14f	65 	e
	pop bc			;d150	c1 	.
	ld de,00010h		;d151	11 10 00 	. . .
	ld bc,0000fh		;d154	01 0f 00 	. . .
	ldir		;d157	ed b0 	. .
	ld hl,00000h		;d159	21 00 00 	! . .
	ld de,00000h		;d15c	11 00 00 	. . .
	ld bc,00000h		;d15f	01 00 00 	. . .
	jp 00010h		;d162	c3 10 00 	. . .
	in a,(081h)		;d165	db 81 	. .
	set 0,a		;d167	cb c7 	. .
	out (081h),a		;d169	d3 81 	. .
	ldir		;d16b	ed b0 	. .
	res 0,a		;d16d	cb 87 	. .
	out (081h),a		;d16f	d3 81 	. .
	out (0deh),a		;d171	d3 de 	. .
	ret			;d173	c9 	.
	push af			;d174	f5 	.
	rrca			;d175	0f 	.
	rrca			;d176	0f 	.
	rrca			;d177	0f 	.
	rrca			;d178	0f 	.
	and 00fh		;d179	e6 0f 	. .
	call 0c181h		;d17b	cd 81 c1 	. . .
	pop af			;d17e	f1 	.
	and 00fh		;d17f	e6 0f 	. .
	call 0c187h		;d181	cd 87 c1 	. . .
	jp 0c45eh		;d184	c3 5e c4 	. ^ .
	add a,090h		;d187	c6 90 	. .
	daa			;d189	27 	'
	adc a,040h		;d18a	ce 40 	. @
	daa			;d18c	27 	'
	ld c,a			;d18d	4f 	O
	ret			;d18e	c9 	.
	ex (sp),hl			;d18f	e3 	.
	ld a,(hl)			;d190	7e 	~
	inc hl			;d191	23 	#
	or a			;d192	b7 	.
	jr z,$+8		;d193	28 06 	( .
	ld c,a			;d195	4f 	O
	call 0c45eh		;d196	cd 5e c4 	. ^ .
	jr $-9		;d199	18 f5 	. .
	ex (sp),hl			;d19b	e3 	.
	ret			;d19c	c9 	.
	push bc			;d19d	c5 	.
	push de			;d19e	d5 	.
	push hl			;d19f	e5 	.
	ld (0ffb8h),a		;d1a0	32 b8 ff 	2 . .
	ld a,00ah		;d1a3	3e 0a 	> .
	ld (0ffbfh),a		;d1a5	32 bf ff 	2 . .
	ld (0ffb9h),bc		;d1a8	ed 43 b9 ff 	. C . .
	ld (0ffbbh),de		;d1ac	ed 53 bb ff 	. S . .
	ld (0ffbdh),hl		;d1b0	22 bd ff 	" . .
	call 0c423h		;d1b3	cd 23 c4 	. # .
	ld a,(0ffbah)		;d1b6	3a ba ff 	: . .
	and 0f0h		;d1b9	e6 f0 	. .
	jp z,0c1e6h		;d1bb	ca e6 c1 	. . .
	cp 040h		;d1be	fe 40 	. @
	jp z,0c1dch		;d1c0	ca dc c1 	. . .
	cp 080h		;d1c3	fe 80 	. .
	jp z,0c1d7h		;d1c5	ca d7 c1 	. . .
	cp 020h		;d1c8	fe 20 	.
	jp z,0c1e1h		;d1ca	ca e1 c1 	. . .
	cp 0f0h		;d1cd	fe f0 	. .
	jp z,0c1ebh		;d1cf	ca eb c1 	. . .
	ld a,0ffh		;d1d2	3e ff 	> .
	jp 0c1f0h		;d1d4	c3 f0 c1 	. . .
	call 0c1f4h		;d1d7	cd f4 c1 	. . .
	jr $+22		;d1da	18 14 	. .
	call 0c24ah		;d1dc	cd 4a c2 	. J .
	jr $+17		;d1df	18 0f 	. .
	call 0c3a9h		;d1e1	cd a9 c3 	. . .
	jr $+12		;d1e4	18 0a 	. .
	call 0c391h		;d1e6	cd 91 c3 	. . .
	jr $+7		;d1e9	18 05 	. .
	call 0c2e3h		;d1eb	cd e3 c2 	. . .
	jr $+2		;d1ee	18 00 	. .
	pop hl			;d1f0	e1 	.
	pop de			;d1f1	d1 	.
	pop bc			;d1f2	c1 	.
	ret			;d1f3	c9 	.
	call 0c3a9h		;d1f4	cd a9 c3 	. . .
	call 0c2b7h		;d1f7	cd b7 c2 	. . .
	push de			;d1fa	d5 	.
	call 0c41ch		;d1fb	cd 1c c4 	. . .
	ld c,0c5h		;d1fe	0e c5 	. .
	ld a,(0ffb8h)		;d200	3a b8 ff 	: . .
	or a			;d203	b7 	.
	jr nz,$+4		;d204	20 02 	  .
	res 6,c		;d206	cb b1 	. .
	call 0c415h		;d208	cd 15 c4 	. . .
	di			;d20b	f3 	.
	call 0c34eh		;d20c	cd 4e c3 	. N .
	pop de			;d20f	d1 	.
	ld c,0c1h		;d210	0e c1 	. .
	ld b,e			;d212	43 	C
	ld hl,(0ffbdh)		;d213	2a bd ff 	* . .
	in a,(082h)		;d216	db 82 	. .
	bit 2,a		;d218	cb 57 	. W
	jr z,$-4		;d21a	28 fa 	( .
	in a,(0c0h)		;d21c	db c0 	. .
	bit 5,a		;d21e	cb 6f 	. o
	jr z,$+9		;d220	28 07 	( .
	outi		;d222	ed a3 	. .
	jr nz,$-14		;d224	20 f0 	  .
	dec d			;d226	15 	.
	jr nz,$-17		;d227	20 ed 	  .
	out (0dch),a		;d229	d3 dc 	. .
	ei			;d22b	fb 	.
	call 0c3f4h		;d22c	cd f4 c3 	. . .
	ld a,(0ffc0h)		;d22f	3a c0 ff 	: . .
	and 0c0h		;d232	e6 c0 	. .
	cp 040h		;d234	fe 40 	. @
	jr nz,$+18		;d236	20 10 	  .
	call 0c2a0h		;d238	cd a0 c2 	. . .
	ld a,(0ffbfh)		;d23b	3a bf ff 	: . .
	dec a			;d23e	3d 	=
	ld (0ffbfh),a		;d23f	32 bf ff 	2 . .
	jp nz,0c1f7h		;d242	c2 f7 c1 	. . .
	ld a,0ffh		;d245	3e ff 	> .
	ret			;d247	c9 	.
	xor a			;d248	af 	.
	ret			;d249	c9 	.
	call 0c3a9h		;d24a	cd a9 c3 	. . .
	call 0c2b7h		;d24d	cd b7 c2 	. . .
	push de			;d250	d5 	.
	call 0c41ch		;d251	cd 1c c4 	. . .
	ld c,0c6h		;d254	0e c6 	. .
	ld a,(0ffb8h)		;d256	3a b8 ff 	: . .
	or a			;d259	b7 	.
	jr nz,$+4		;d25a	20 02 	  .
	res 6,c		;d25c	cb b1 	. .
	call 0c415h		;d25e	cd 15 c4 	. . .
	di			;d261	f3 	.
	call 0c34eh		;d262	cd 4e c3 	. N .
	pop de			;d265	d1 	.
	ld c,0c1h		;d266	0e c1 	. .
	ld b,e			;d268	43 	C
	ld hl,(0ffbdh)		;d269	2a bd ff 	* . .
	in a,(082h)		;d26c	db 82 	. .
	bit 2,a		;d26e	cb 57 	. W
	jr z,$-4		;d270	28 fa 	( .
	in a,(0c0h)		;d272	db c0 	. .
	bit 5,a		;d274	cb 6f 	. o
	jr z,$+9		;d276	28 07 	( .
	ini		;d278	ed a2 	. .
	jr nz,$-14		;d27a	20 f0 	  .
	dec d			;d27c	15 	.
	jr nz,$-17		;d27d	20 ed 	  .
	out (0dch),a		;d27f	d3 dc 	. .
	ei			;d281	fb 	.
	call 0c3f4h		;d282	cd f4 c3 	. . .
	ld a,(0ffc0h)		;d285	3a c0 ff 	: . .
	and 0c0h		;d288	e6 c0 	. .
	cp 040h		;d28a	fe 40 	. @
	jr nz,$+18		;d28c	20 10 	  .
	call 0c2a0h		;d28e	cd a0 c2 	. . .
	ld a,(0ffbfh)		;d291	3a bf ff 	: . .
	dec a			;d294	3d 	=
	ld (0ffbfh),a		;d295	32 bf ff 	2 . .
	jp nz,0c24dh		;d298	c2 4d c2 	. M .
	ld a,0ffh		;d29b	3e ff 	> .
	ret			;d29d	c9 	.
	xor a			;d29e	af 	.
	ret			;d29f	c9 	.
	ld a,(0ffc2h)		;d2a0	3a c2 ff 	: . .
	bit 4,a		;d2a3	cb 67 	. g
	jr z,$+6		;d2a5	28 04 	( .
	call 0c391h		;d2a7	cd 91 c3 	. . .
	ret			;d2aa	c9 	.
	ld a,(0ffc1h)		;d2ab	3a c1 ff 	: . .
	bit 0,a		;d2ae	cb 47 	. G
	jr z,$+6		;d2b0	28 04 	( .
	call 0c391h		;d2b2	cd 91 c3 	. . .
	ret			;d2b5	c9 	.
	ret			;d2b6	c9 	.
	ld e,000h		;d2b7	1e 00 	. .
	ld a,(0ffb8h)		;d2b9	3a b8 ff 	: . .
	cp 003h		;d2bc	fe 03 	. .
	jr nz,$+22		;d2be	20 14 	  .
	ld d,004h		;d2c0	16 04 	. .
	ld a,(0ffbbh)		;d2c2	3a bb ff 	: . .
	bit 7,a		;d2c5	cb 7f 	. 
	jr z,$+27		;d2c7	28 19 	( .
	ld a,(0ffbah)		;d2c9	3a ba ff 	: . .
	and 00fh		;d2cc	e6 0f 	. .
	rlca			;d2ce	07 	.
	rlca			;d2cf	07 	.
	add a,d			;d2d0	82 	.
	ld d,a			;d2d1	57 	W
	jr $+16		;d2d2	18 0e 	. .
	or a			;d2d4	b7 	.
	jr nz,$+4		;d2d5	20 02 	  .
	ld e,080h		;d2d7	1e 80 	. .
	ld a,(0ffbah)		;d2d9	3a ba ff 	: . .
	and 00fh		;d2dc	e6 0f 	. .
	ld d,001h		;d2de	16 01 	. .
	add a,d			;d2e0	82 	.
	ld d,a			;d2e1	57 	W
	ret			;d2e2	c9 	.
	call 0c3a9h		;d2e3	cd a9 c3 	. . .
	cp 0ffh		;d2e6	fe ff 	. .
	ret z			;d2e8	c8 	.
	ld b,014h		;d2e9	06 14 	. .
	ld a,(0ffb8h)		;d2eb	3a b8 ff 	: . .
	cp 003h		;d2ee	fe 03 	. .
	jr z,$+4		;d2f0	28 02 	( .
	ld b,040h		;d2f2	06 40 	. @
	push bc			;d2f4	c5 	.
	call 0c41ch		;d2f5	cd 1c c4 	. . .
	ld c,04dh		;d2f8	0e 4d 	. M
	call 0c415h		;d2fa	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;d2fd	ed 4b b9 ff 	. K . .
	call 0c415h		;d301	cd 15 c4 	. . .
	ld a,(0ffb8h)		;d304	3a b8 ff 	: . .
	ld c,a			;d307	4f 	O
	call 0c415h		;d308	cd 15 c4 	. . .
	ld c,005h		;d30b	0e 05 	. .
	ld a,(0ffb8h)		;d30d	3a b8 ff 	: . .
	cp 003h		;d310	fe 03 	. .
	jr z,$+4		;d312	28 02 	( .
	ld c,010h		;d314	0e 10 	. .
	call 0c415h		;d316	cd 15 c4 	. . .
	ld c,028h		;d319	0e 28 	. (
	call 0c415h		;d31b	cd 15 c4 	. . .
	di			;d31e	f3 	.
	ld c,0e5h		;d31f	0e e5 	. .
	call 0c415h		;d321	cd 15 c4 	. . .
	pop bc			;d324	c1 	.
	ld c,0c1h		;d325	0e c1 	. .
	ld hl,(0ffbdh)		;d327	2a bd ff 	* . .
	in a,(082h)		;d32a	db 82 	. .
	bit 2,a		;d32c	cb 57 	. W
	jr z,$-4		;d32e	28 fa 	( .
	in a,(0c0h)		;d330	db c0 	. .
	bit 5,a		;d332	cb 6f 	. o
	jr z,$+6		;d334	28 04 	( .
	outi		;d336	ed a3 	. .
	jr nz,$-14		;d338	20 f0 	  .
	out (0dch),a		;d33a	d3 dc 	. .
	ei			;d33c	fb 	.
	call 0c3f4h		;d33d	cd f4 c3 	. . .
	ld a,(0ffc0h)		;d340	3a c0 ff 	: . .
	and 0c0h		;d343	e6 c0 	. .
	cp 040h		;d345	fe 40 	. @
	jr nz,$+5		;d347	20 03 	  .
	ld a,0ffh		;d349	3e ff 	> .
	ret			;d34b	c9 	.
	xor a			;d34c	af 	.
	ret			;d34d	c9 	.
	ld bc,(0ffb9h)		;d34e	ed 4b b9 ff 	. K . .
	call 0c415h		;d352	cd 15 c4 	. . .
	ld de,(0ffbbh)		;d355	ed 5b bb ff 	. [ . .
	ld c,d			;d359	4a 	J
	call 0c415h		;d35a	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;d35d	ed 4b b9 ff 	. K . .
	ld a,c			;d361	79 	y
	and 004h		;d362	e6 04 	. .
	rrca			;d364	0f 	.
	rrca			;d365	0f 	.
	ld c,a			;d366	4f 	O
	call 0c415h		;d367	cd 15 c4 	. . .
	res 7,e		;d36a	cb bb 	. .
	ld c,e			;d36c	4b 	K
	inc c			;d36d	0c 	.
	call 0c415h		;d36e	cd 15 c4 	. . .
	ld a,(0ffb8h)		;d371	3a b8 ff 	: . .
	ld c,a			;d374	4f 	O
	call 0c415h		;d375	cd 15 c4 	. . .
	ld c,005h		;d378	0e 05 	. .
	ld a,(0ffb8h)		;d37a	3a b8 ff 	: . .
	cp 003h		;d37d	fe 03 	. .
	jr z,$+4		;d37f	28 02 	( .
	ld c,010h		;d381	0e 10 	. .
	call 0c415h		;d383	cd 15 c4 	. . .
	ld c,028h		;d386	0e 28 	. (
	call 0c415h		;d388	cd 15 c4 	. . .
	ld c,0ffh		;d38b	0e ff 	. .
	call 0c415h		;d38d	cd 15 c4 	. . .
	ret			;d390	c9 	.
	call 0c41ch		;d391	cd 1c c4 	. . .
	ld c,007h		;d394	0e 07 	. .
	call 0c415h		;d396	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;d399	ed 4b b9 ff 	. K . .
	res 2,c		;d39d	cb 91 	. .
	call 0c415h		;d39f	cd 15 c4 	. . .
	call 0c3d2h		;d3a2	cd d2 c3 	. . .
	jr z,$-20		;d3a5	28 ea 	( .
	xor a			;d3a7	af 	.
	ret			;d3a8	c9 	.
	ld de,(0ffbbh)		;d3a9	ed 5b bb ff 	. [ . .
	ld a,d			;d3ad	7a 	z
	or a			;d3ae	b7 	.
	jp z,0c391h		;d3af	ca 91 c3 	. . .
	call 0c41ch		;d3b2	cd 1c c4 	. . .
	ld c,00fh		;d3b5	0e 0f 	. .
	call 0c415h		;d3b7	cd 15 c4 	. . .
	ld bc,(0ffb9h)		;d3ba	ed 4b b9 ff 	. K . .
	call 0c415h		;d3be	cd 15 c4 	. . .
	ld c,d			;d3c1	4a 	J
	call 0c415h		;d3c2	cd 15 c4 	. . .
	call 0c3d2h		;d3c5	cd d2 c3 	. . .
	jr nz,$+8		;d3c8	20 06 	  .
	call 0c391h		;d3ca	cd 91 c3 	. . .
	jp 0c3a9h		;d3cd	c3 a9 c3 	. . .
	xor a			;d3d0	af 	.
	ret			;d3d1	c9 	.
	in a,(082h)		;d3d2	db 82 	. .
	bit 2,a		;d3d4	cb 57 	. W
	jp z,0c3d2h		;d3d6	ca d2 c3 	. . .
	call 0c41ch		;d3d9	cd 1c c4 	. . .
	call 0c403h		;d3dc	cd 03 c4 	. . .
	ld a,008h		;d3df	3e 08 	> .
	out (0c1h),a		;d3e1	d3 c1 	. .
	call 0c40ch		;d3e3	cd 0c c4 	. . .
	in a,(0c1h)		;d3e6	db c1 	. .
	ld b,a			;d3e8	47 	G
	call 0c40ch		;d3e9	cd 0c c4 	. . .
	in a,(0c1h)		;d3ec	db c1 	. .
	ld a,b			;d3ee	78 	x
	and 0c0h		;d3ef	e6 c0 	. .
	cp 040h		;d3f1	fe 40 	. @
	ret			;d3f3	c9 	.
	ld hl,0ffc0h		;d3f4	21 c0 ff 	! . .
	ld b,007h		;d3f7	06 07 	. .
	ld c,0c1h		;d3f9	0e c1 	. .
	call 0c40ch		;d3fb	cd 0c c4 	. . .
	ini		;d3fe	ed a2 	. .
	jr nz,$-5		;d400	20 f9 	  .
	ret			;d402	c9 	.
	in a,(0c0h)		;d403	db c0 	. .
	rlca			;d405	07 	.
	jr nc,$-3		;d406	30 fb 	0 .
	rlca			;d408	07 	.
	jr c,$-6		;d409	38 f8 	8 .
	ret			;d40b	c9 	.
	in a,(0c0h)		;d40c	db c0 	. .
	rlca			;d40e	07 	.
	jr nc,$-3		;d40f	30 fb 	0 .
	rlca			;d411	07 	.
	jr nc,$-6		;d412	30 f8 	0 .
	ret			;d414	c9 	.
	call 0c403h		;d415	cd 03 c4 	. . .
	ld a,c			;d418	79 	y
	out (0c1h),a		;d419	d3 c1 	. .
	ret			;d41b	c9 	.
	in a,(0c0h)		;d41c	db c0 	. .
	bit 4,a		;d41e	cb 67 	. g
	jr nz,$-4		;d420	20 fa 	  .
	ret			;d422	c9 	.
	ld b,001h		;d423	06 01 	. .
	ld a,c			;d425	79 	y
	and 003h		;d426	e6 03 	. .
	or a			;d428	b7 	.
	jr z,$+7		;d429	28 05 	( .
	rlc b		;d42b	cb 00 	. .
	dec a			;d42d	3d 	=
	jr nz,$-3		;d42e	20 fb 	  .
	ld a,(0ffc7h)		;d430	3a c7 ff 	: . .
	ld c,a			;d433	4f 	O
	and b			;d434	a0 	.
	ret nz			;d435	c0 	.
	ld a,c			;d436	79 	y
	or b			;d437	b0 	.
	ld (0ffc7h),a		;d438	32 c7 ff 	2 . .
	call 0c391h		;d43b	cd 91 c3 	. . .
	ret			;d43e	c9 	.
	push bc			;d43f	c5 	.
	push hl			;d440	e5 	.
	ld hl,0c45ch		;d441	21 5c c4 	! \ .
	call 0c41ch		;d444	cd 1c c4 	. . .
	ld c,003h		;d447	0e 03 	. .
	call 0c415h		;d449	cd 15 c4 	. . .
	ld c,(hl)			;d44c	4e 	N
	inc hl			;d44d	23 	#
	call 0c415h		;d44e	cd 15 c4 	. . .
	ld c,(hl)			;d451	4e 	N
	call 0c415h		;d452	cd 15 c4 	. . .
	xor a			;d455	af 	.
	ld (0ffc7h),a		;d456	32 c7 ff 	2 . .
	pop hl			;d459	e1 	.
	pop bc			;d45a	c1 	.
	ret			;d45b	c9 	.
	ld l,a			;d45c	6f 	o
	dec de			;d45d	1b 	.
	push af			;d45e	f5 	.
	push bc			;d45f	c5 	.
	push de			;d460	d5 	.
	push hl			;d461	e5 	.
	push ix		;d462	dd e5 	. .
	push iy		;d464	fd e5 	. .
	call 0c69ah		;d466	cd 9a c6 	. . .
	ld a,(0ffd8h)		;d469	3a d8 ff 	: . .
	or a			;d46c	b7 	.
	jp nz,0c9e3h		;d46d	c2 e3 c9 	. . .
	ld a,(0ffcch)		;d470	3a cc ff 	: . .
	cp 0ffh		;d473	fe ff 	. .
	jp z,0c6a3h		;d475	ca a3 c6 	. . .
	or a			;d478	b7 	.
	jp nz,0c4beh		;d479	c2 be c4 	. . .
	ld a,c			;d47c	79 	y
	cp 01bh		;d47d	fe 1b 	. .
	jr z,$+55		;d47f	28 35 	( 5
	cp 020h		;d481	fe 20 	.
	jp nc,0c4beh		;d483	d2 be c4 	. . .
	cp 00dh		;d486	fe 0d 	. .
	jp z,0c524h		;d488	ca 24 c5 	. $ .
	cp 00ah		;d48b	fe 0a 	. .
	jp z,0c532h		;d48d	ca 32 c5 	. 2 .
	cp 00bh		;d490	fe 0b 	. .
	jp z,0c558h		;d492	ca 58 c5 	. X .
	cp 00ch		;d495	fe 0c 	. .
	jp z,0c56fh		;d497	ca 6f c5 	. o .
	cp 008h		;d49a	fe 08 	. .
	jp z,0c59bh		;d49c	ca 9b c5 	. . .
	cp 01eh		;d49f	fe 1e 	. .
	jp z,0c5dbh		;d4a1	ca db c5 	. . .
	cp 01ah		;d4a4	fe 1a 	. .
	jp z,0c5eeh		;d4a6	ca ee c5 	. . .
	cp 007h		;d4a9	fe 07 	. .
	call z,0c5f4h		;d4ab	cc f4 c5 	. . .
	cp 000h		;d4ae	fe 00 	. .
	jp z,0c6a3h		;d4b0	ca a3 c6 	. . .
	jp 0c4beh		;d4b3	c3 be c4 	. . .
	ld a,001h		;d4b6	3e 01 	> .
	ld (0ffd8h),a		;d4b8	32 d8 ff 	2 . .
	jp 0c6a3h		;d4bb	c3 a3 c6 	. . .
	push iy		;d4be	fd e5 	. .
	pop hl			;d4c0	e1 	.
	call 0c715h		;d4c1	cd 15 c7 	. . .
	ld (hl),c			;d4c4	71 	q
	call 0c795h		;d4c5	cd 95 c7 	. . .
	ld a,(0ffd1h)		;d4c8	3a d1 ff 	: . .
	ld b,a			;d4cb	47 	G
	ld a,(0ffd2h)		;d4cc	3a d2 ff 	: . .
	and (hl)			;d4cf	a6 	.
	or b			;d4d0	b0 	.
	ld (hl),a			;d4d1	77 	w
	call 0c79eh		;d4d2	cd 9e c7 	. . .
	call 0c5f8h		;d4d5	cd f8 c5 	. . .
	jr c,$+8		;d4d8	38 06 	8 .
	call 0c613h		;d4da	cd 13 c6 	. . .
	jp 0c6a3h		;d4dd	c3 a3 c6 	. . .
	ld a,(0ffcbh)		;d4e0	3a cb ff 	: . .
	ld b,a			;d4e3	47 	G
	ld a,(0ffcdh)		;d4e4	3a cd ff 	: . .
	cp b			;d4e7	b8 	.
	jr z,$+25		;d4e8	28 17 	( .
	inc b			;d4ea	04 	.
	ld a,b			;d4eb	78 	x
	ld (0ffcbh),a		;d4ec	32 cb ff 	2 . .
	ld a,(0ffc9h)		;d4ef	3a c9 ff 	: . .
	or a			;d4f2	b7 	.
	jr nz,$+8		;d4f3	20 06 	  .
	call 0c613h		;d4f5	cd 13 c6 	. . .
	jp 0c6a3h		;d4f8	c3 a3 c6 	. . .
	call 0c620h		;d4fb	cd 20 c6 	.   .
	jp 0c6a3h		;d4fe	c3 a3 c6 	. . .
	ld a,(0ffc9h)		;d501	3a c9 ff 	: . .
	or a			;d504	b7 	.
	jr nz,$+11		;d505	20 09 	  .
	call 0c613h		;d507	cd 13 c6 	. . .
	call 0c62eh		;d50a	cd 2e c6 	. . .
	jp 0c6a3h		;d50d	c3 a3 c6 	. . .
	ld a,(0ffcdh)		;d510	3a cd ff 	: . .
	ld b,a			;d513	47 	G
	ld a,(0ffd0h)		;d514	3a d0 ff 	: . .
	ld c,a			;d517	4f 	O
	call 0c6f1h		;d518	cd f1 c6 	. . .
	call 0c71ch		;d51b	cd 1c c7 	. . .
	call 0c62eh		;d51e	cd 2e c6 	. . .
	jp 0c6a3h		;d521	c3 a3 c6 	. . .
	ld a,(0ffd0h)		;d524	3a d0 ff 	: . .
	ld (0ffcah),a		;d527	32 ca ff 	2 . .
	ld c,a			;d52a	4f 	O
	ld a,(0ffcbh)		;d52b	3a cb ff 	: . .
	ld b,a			;d52e	47 	G
	jp 0c5e5h		;d52f	c3 e5 c5 	. . .
	ld a,(0ffcbh)		;d532	3a cb ff 	: . .
	ld b,a			;d535	47 	G
	ld a,(0ffcdh)		;d536	3a cd ff 	: . .
	cp b			;d539	b8 	.
	jr z,$+17		;d53a	28 0f 	( .
	inc b			;d53c	04 	.
	ld a,b			;d53d	78 	x
	ld (0ffcbh),a		;d53e	32 cb ff 	2 . .
	push iy		;d541	fd e5 	. .
	pop hl			;d543	e1 	.
	ld de,00050h		;d544	11 50 00 	. P .
	add hl,de			;d547	19 	.
	jp 0c5e8h		;d548	c3 e8 c5 	. . .
	call 0c62eh		;d54b	cd 2e c6 	. . .
	ld a,(0ffcbh)		;d54e	3a cb ff 	: . .
	ld b,a			;d551	47 	G
	ld a,(0ffcah)		;d552	3a ca ff 	: . .
	ld c,a			;d555	4f 	O
	jr $-21		;d556	18 e9 	. .
	ld a,(0ffcbh)		;d558	3a cb ff 	: . .
	ld b,a			;d55b	47 	G
	ld a,(0ffceh)		;d55c	3a ce ff 	: . .
	cp b			;d55f	b8 	.
	jp z,0c6a3h		;d560	ca a3 c6 	. . .
	dec b			;d563	05 	.
	ld a,b			;d564	78 	x
	ld (0ffcbh),a		;d565	32 cb ff 	2 . .
	ld a,(0ffcah)		;d568	3a ca ff 	: . .
	ld c,a			;d56b	4f 	O
	jp 0c5e5h		;d56c	c3 e5 c5 	. . .
	call 0c5f8h		;d56f	cd f8 c5 	. . .
	ld a,(0ffcbh)		;d572	3a cb ff 	: . .
	ld b,a			;d575	47 	G
	jr c,$+5		;d576	38 03 	8 .
	jp 0c5e5h		;d578	c3 e5 c5 	. . .
	ld a,(0ffd0h)		;d57b	3a d0 ff 	: . .
	ld (0ffcah),a		;d57e	32 ca ff 	2 . .
	ld c,a			;d581	4f 	O
	ld a,(0ffcbh)		;d582	3a cb ff 	: . .
	ld b,a			;d585	47 	G
	ld a,(0ffcdh)		;d586	3a cd ff 	: . .
	cp b			;d589	b8 	.
	jr z,$+10		;d58a	28 08 	( .
	inc b			;d58c	04 	.
	ld a,b			;d58d	78 	x
	ld (0ffcbh),a		;d58e	32 cb ff 	2 . .
	jp 0c5e5h		;d591	c3 e5 c5 	. . .
	push bc			;d594	c5 	.
	call 0c62eh		;d595	cd 2e c6 	. . .
	pop bc			;d598	c1 	.
	jr $+76		;d599	18 4a 	. J
	ld a,(0ffcah)		;d59b	3a ca ff 	: . .
	ld c,a			;d59e	4f 	O
	ld a,(0ffd0h)		;d59f	3a d0 ff 	: . .
	cp c			;d5a2	b9 	.
	jr z,$+21		;d5a3	28 13 	( .
	dec c			;d5a5	0d 	.
	ld a,(0ffd1h)		;d5a6	3a d1 ff 	: . .
	bit 3,a		;d5a9	cb 5f 	. _
	jr z,$+3		;d5ab	28 01 	( .
	dec c			;d5ad	0d 	.
	ld a,c			;d5ae	79 	y
	ld (0ffcah),a		;d5af	32 ca ff 	2 . .
	ld a,(0ffcbh)		;d5b2	3a cb ff 	: . .
	ld b,a			;d5b5	47 	G
	jr $+47		;d5b6	18 2d 	. -
	ld a,(0ffcfh)		;d5b8	3a cf ff 	: . .
	ld b,a			;d5bb	47 	G
	ld a,(0ffd1h)		;d5bc	3a d1 ff 	: . .
	bit 3,a		;d5bf	cb 5f 	. _
	jr z,$+3		;d5c1	28 01 	( .
	dec b			;d5c3	05 	.
	ld a,b			;d5c4	78 	x
	ld (0ffcah),a		;d5c5	32 ca ff 	2 . .
	ld c,a			;d5c8	4f 	O
	ld a,(0ffcbh)		;d5c9	3a cb ff 	: . .
	ld b,a			;d5cc	47 	G
	ld a,(0ffceh)		;d5cd	3a ce ff 	: . .
	cp b			;d5d0	b8 	.
	jp z,0c6a3h		;d5d1	ca a3 c6 	. . .
	dec b			;d5d4	05 	.
	ld a,b			;d5d5	78 	x
	ld (0ffcbh),a		;d5d6	32 cb ff 	2 . .
	jr $+12		;d5d9	18 0a 	. .
	xor a			;d5db	af 	.
	ld (0ffcbh),a		;d5dc	32 cb ff 	2 . .
	ld (0ffcah),a		;d5df	32 ca ff 	2 . .
	ld bc,00000h		;d5e2	01 00 00 	. . .
	call 0c6f1h		;d5e5	cd f1 c6 	. . .
	call 0c71ch		;d5e8	cd 1c c7 	. . .
	jp 0c6a3h		;d5eb	c3 a3 c6 	. . .
	call 0c764h		;d5ee	cd 64 c7 	. d .
	jp 0c6a3h		;d5f1	c3 a3 c6 	. . .
	xor a			;d5f4	af 	.
	out (0dah),a		;d5f5	d3 da 	. .
	ret			;d5f7	c9 	.
	ld a,(0ffcah)		;d5f8	3a ca ff 	: . .
	ld c,a			;d5fb	4f 	O
	inc c			;d5fc	0c 	.
	ld a,(0ffd1h)		;d5fd	3a d1 ff 	: . .
	bit 3,a		;d600	cb 5f 	. _
	jr z,$+3		;d602	28 01 	( .
	inc c			;d604	0c 	.
	ld a,(0ffcfh)		;d605	3a cf ff 	: . .
	cp c			;d608	b9 	.
	ld a,c			;d609	79 	y
	jr nc,$+5		;d60a	30 03 	0 .
	ld a,(0ffd0h)		;d60c	3a d0 ff 	: . .
	ld (0ffcah),a		;d60f	32 ca ff 	2 . .
	ret			;d612	c9 	.
	inc hl			;d613	23 	#
	ld a,(0ffd1h)		;d614	3a d1 ff 	: . .
	bit 3,a		;d617	cb 5f 	. _
	jr z,$+3		;d619	28 01 	( .
	inc hl			;d61b	23 	#
	call 0c71ch		;d61c	cd 1c c7 	. . .
	ret			;d61f	c9 	.
	ld a,(0ffc8h)		;d620	3a c8 ff 	: . .
	ld e,a			;d623	5f 	_
	ld d,000h		;d624	16 00 	. .
	push iy		;d626	fd e5 	. .
	pop hl			;d628	e1 	.
	add hl,de			;d629	19 	.
	call 0c71ch		;d62a	cd 1c c7 	. . .
	ret			;d62d	c9 	.
	ld a,(0ffc9h)		;d62e	3a c9 ff 	: . .
	or a			;d631	b7 	.
	jr nz,$+21		;d632	20 13 	  .
	push ix		;d634	dd e5 	. .
	pop hl			;d636	e1 	.
	ld de,00050h		;d637	11 50 00 	. P .
	add hl,de			;d63a	19 	.
	call 0c742h		;d63b	cd 42 c7 	. B .
	ld b,017h		;d63e	06 17 	. .
	call 0c7fah		;d640	cd fa c7 	. . .
	call 0c670h		;d643	cd 70 c6 	. p .
	ret			;d646	c9 	.
	ld a,(0ffd0h)		;d647	3a d0 ff 	: . .
	ld c,a			;d64a	4f 	O
	ld a,(0ffceh)		;d64b	3a ce ff 	: . .
	ld b,a			;d64e	47 	G
	ld a,(0ffceh)		;d64f	3a ce ff 	: . .
	ld d,a			;d652	57 	W
	ld a,(0ffcdh)		;d653	3a cd ff 	: . .
	sub d			;d656	92 	.
	jr z,$+13		;d657	28 0b 	( .
	ld d,a			;d659	57 	W
	inc b			;d65a	04 	.
	call 0c6f1h		;d65b	cd f1 c6 	. . .
	call 0c7a7h		;d65e	cd a7 c7 	. . .
	dec d			;d661	15 	.
	jr nz,$-8		;d662	20 f6 	  .
	ld a,(0ffcdh)		;d664	3a cd ff 	: . .
	ld d,a			;d667	57 	W
	ld a,(0ffcfh)		;d668	3a cf ff 	: . .
	ld e,a			;d66b	5f 	_
	call 0c805h		;d66c	cd 05 c8 	. . .
	ret			;d66f	c9 	.
	push ix		;d670	dd e5 	. .
	pop hl			;d672	e1 	.
	ld de,00730h		;d673	11 30 07 	. 0 .
	ld b,050h		;d676	06 50 	. P
	add hl,de			;d678	19 	.
	ld de,02000h		;d679	11 00 20 	. .
	call 0c795h		;d67c	cd 95 c7 	. . .
	call 0c715h		;d67f	cd 15 c7 	. . .
	push hl			;d682	e5 	.
	push bc			;d683	c5 	.
	ld e,000h		;d684	1e 00 	. .
	call 0c690h		;d686	cd 90 c6 	. . .
	pop bc			;d689	c1 	.
	pop hl			;d68a	e1 	.
	call 0c79eh		;d68b	cd 9e c7 	. . .
	ld e,020h		;d68e	1e 20 	.
	ld (hl),e			;d690	73 	s
	inc hl			;d691	23 	#
	bit 3,h		;d692	cb 5c 	. \
	call z,0c715h		;d694	cc 15 c7 	. . .
	djnz $-7		;d697	10 f7 	. .
	ret			;d699	c9 	.
	ld ix,(0ffd4h)		;d69a	dd 2a d4 ff 	. * . .
	ld iy,(0ffd6h)		;d69e	fd 2a d6 ff 	. * . .
	ret			;d6a2	c9 	.
	call 0c6e8h		;d6a3	cd e8 c6 	. . .
	pop iy		;d6a6	fd e1 	. .
	pop ix		;d6a8	dd e1 	. .
	pop hl			;d6aa	e1 	.
	pop de			;d6ab	d1 	.
	pop bc			;d6ac	c1 	.
	pop af			;d6ad	f1 	.
	ret			;d6ae	c9 	.
	ld hl,0ffc9h		;d6af	21 c9 ff 	! . .
	xor a			;d6b2	af 	.
	ld (hl),a			;d6b3	77 	w
	inc hl			;d6b4	23 	#
	ld (hl),a			;d6b5	77 	w
	inc hl			;d6b6	23 	#
	ld (hl),a			;d6b7	77 	w
	inc hl			;d6b8	23 	#
	ld (hl),a			;d6b9	77 	w
	inc hl			;d6ba	23 	#
	ld (hl),017h		;d6bb	36 17 	6 .
	inc hl			;d6bd	23 	#
	ld (hl),a			;d6be	77 	w
	inc hl			;d6bf	23 	#
	ld (hl),04fh		;d6c0	36 4f 	6 O
	inc hl			;d6c2	23 	#
	ld (hl),a			;d6c3	77 	w
	inc hl			;d6c4	23 	#
	ld (hl),a			;d6c5	77 	w
	inc hl			;d6c6	23 	#
	ld (hl),080h		;d6c7	36 80 	6 .
	inc hl			;d6c9	23 	#
	ld a,(0c86fh)		;d6ca	3a 6f c8 	: o .
	ld d,a			;d6cd	57 	W
	in a,(0d6h)		;d6ce	db d6 	. .
	bit 5,a		;d6d0	cb 6f 	. o
	jr z,$+4		;d6d2	28 02 	( .
	ld d,003h		;d6d4	16 03 	. .
	bit 6,a		;d6d6	cb 77 	. w
	jr z,$+6		;d6d8	28 04 	( .
	set 5,d		;d6da	cb ea 	. .
	set 6,d		;d6dc	cb f2 	. .
	ld (hl),d			;d6de	72 	r
	xor a			;d6df	af 	.
	inc hl			;d6e0	23 	#
	ld b,015h		;d6e1	06 15 	. .
	ld (hl),a			;d6e3	77 	w
	inc hl			;d6e4	23 	#
	djnz $-2		;d6e5	10 fc 	. .
	ret			;d6e7	c9 	.
	ld (0ffd4h),ix		;d6e8	dd 22 d4 ff 	. " . .
	ld (0ffd6h),iy		;d6ec	fd 22 d6 ff 	. " . .
	ret			;d6f0	c9 	.
	push af			;d6f1	f5 	.
	push bc			;d6f2	c5 	.
	push de			;d6f3	d5 	.
	push ix		;d6f4	dd e5 	. .
	pop hl			;d6f6	e1 	.
	ld de,00050h		;d6f7	11 50 00 	. P .
	ld a,b			;d6fa	78 	x
	ld b,005h		;d6fb	06 05 	. .
	rra			;d6fd	1f 	.
	jr nc,$+3		;d6fe	30 01 	0 .
	add hl,de			;d700	19 	.
	or a			;d701	b7 	.
	rl e		;d702	cb 13 	. .
	rl d		;d704	cb 12 	. .
	dec b			;d706	05 	.
	jr nz,$-10		;d707	20 f4 	  .
	ld d,000h		;d709	16 00 	. .
	ld e,c			;d70b	59 	Y
	add hl,de			;d70c	19 	.
	ld a,h			;d70d	7c 	|
	and 00fh		;d70e	e6 0f 	. .
	ld h,a			;d710	67 	g
	pop de			;d711	d1 	.
	pop bc			;d712	c1 	.
	pop af			;d713	f1 	.
	ret			;d714	c9 	.
	ld a,h			;d715	7c 	|
	and 007h		;d716	e6 07 	. .
	or 0d0h		;d718	f6 d0 	. .
	ld h,a			;d71a	67 	g
	ret			;d71b	c9 	.
	ld a,h			;d71c	7c 	|
	and 007h		;d71d	e6 07 	. .
	ld h,a			;d71f	67 	g
	push ix		;d720	dd e5 	. .
	pop de			;d722	d1 	.
	ex de,hl			;d723	eb 	.
	or a			;d724	b7 	.
	sbc hl,de		;d725	ed 52 	. R
	jr c,$+9		;d727	38 07 	8 .
	jr z,$+7		;d729	28 05 	( .
	ld hl,00800h		;d72b	21 00 08 	! . .
	add hl,de			;d72e	19 	.
	ex de,hl			;d72f	eb 	.
	ld a,00eh		;d730	3e 0e 	> .
	out (0a0h),a		;d732	d3 a0 	. .
	ld a,d			;d734	7a 	z
	out (0a1h),a		;d735	d3 a1 	. .
	ld a,00fh		;d737	3e 0f 	> .
	out (0a0h),a		;d739	d3 a0 	. .
	ld a,e			;d73b	7b 	{
	out (0a1h),a		;d73c	d3 a1 	. .
	push de			;d73e	d5 	.
	pop iy		;d73f	fd e1 	. .
	ret			;d741	c9 	.
	ld a,h			;d742	7c 	|
	and 007h		;d743	e6 07 	. .
	ld h,a			;d745	67 	g
	call 0c75bh		;d746	cd 5b c7 	. [ .
	ld a,00ch		;d749	3e 0c 	> .
	out (0a0h),a		;d74b	d3 a0 	. .
	ld a,h			;d74d	7c 	|
	out (0a1h),a		;d74e	d3 a1 	. .
	ld a,00dh		;d750	3e 0d 	> .
	out (0a0h),a		;d752	d3 a0 	. .
	ld a,l			;d754	7d 	}
	out (0a1h),a		;d755	d3 a1 	. .
	push hl			;d757	e5 	.
	pop ix		;d758	dd e1 	. .
	ret			;d75a	c9 	.
	in a,(0a0h)		;d75b	db a0 	. .
	in a,(082h)		;d75d	db 82 	. .
	bit 1,a		;d75f	cb 4f 	. O
	jr z,$-4		;d761	28 fa 	( .
	ret			;d763	c9 	.
	ld bc,00780h		;d764	01 80 07 	. . .
	push ix		;d767	dd e5 	. .
	pop hl			;d769	e1 	.
	ld de,02000h		;d76a	11 00 20 	. .
	call 0c715h		;d76d	cd 15 c7 	. . .
	ld (hl),d			;d770	72 	r
	in a,(081h)		;d771	db 81 	. .
	set 7,a		;d773	cb ff 	. .
	out (081h),a		;d775	d3 81 	. .
	ld (hl),e			;d777	73 	s
	res 7,a		;d778	cb bf 	. .
	out (081h),a		;d77a	d3 81 	. .
	inc hl			;d77c	23 	#
	bit 3,h		;d77d	cb 5c 	. \
	call z,0c715h		;d77f	cc 15 c7 	. . .
	dec bc			;d782	0b 	.
	ld a,b			;d783	78 	x
	or c			;d784	b1 	.
	jr nz,$-21		;d785	20 e9 	  .
	push ix		;d787	dd e5 	. .
	pop hl			;d789	e1 	.
	call 0c71ch		;d78a	cd 1c c7 	. . .
	xor a			;d78d	af 	.
	ld (0ffcah),a		;d78e	32 ca ff 	2 . .
	ld (0ffcbh),a		;d791	32 cb ff 	2 . .
	ret			;d794	c9 	.
	push af			;d795	f5 	.
	in a,(081h)		;d796	db 81 	. .
	set 7,a		;d798	cb ff 	. .
	out (081h),a		;d79a	d3 81 	. .
	pop af			;d79c	f1 	.
	ret			;d79d	c9 	.
	push af			;d79e	f5 	.
	in a,(081h)		;d79f	db 81 	. .
	res 7,a		;d7a1	cb bf 	. .
	out (081h),a		;d7a3	d3 81 	. .
	pop af			;d7a5	f1 	.
	ret			;d7a6	c9 	.
	push de			;d7a7	d5 	.
	push bc			;d7a8	c5 	.
	ld a,050h		;d7a9	3e 50 	> P
	cpl			;d7ab	2f 	/
	ld d,0ffh		;d7ac	16 ff 	. .
	ld e,a			;d7ae	5f 	_
	inc de			;d7af	13 	.
	call 0c7b6h		;d7b0	cd b6 c7 	. . .
	pop bc			;d7b3	c1 	.
	pop de			;d7b4	d1 	.
	ret			;d7b5	c9 	.
	ld a,(0ffd0h)		;d7b6	3a d0 ff 	: . .
	ld c,a			;d7b9	4f 	O
	call 0c6f1h		;d7ba	cd f1 c6 	. . .
	push hl			;d7bd	e5 	.
	add hl,de			;d7be	19 	.
	ex de,hl			;d7bf	eb 	.
	pop hl			;d7c0	e1 	.
	ld a,(0ffd0h)		;d7c1	3a d0 ff 	: . .
	ld b,a			;d7c4	47 	G
	ld a,(0ffcfh)		;d7c5	3a cf ff 	: . .
	sub b			;d7c8	90 	.
	inc a			;d7c9	3c 	<
	ld b,a			;d7ca	47 	G
	call 0c715h		;d7cb	cd 15 c7 	. . .
	ex de,hl			;d7ce	eb 	.
	call 0c715h		;d7cf	cd 15 c7 	. . .
	ex de,hl			;d7d2	eb 	.
	push bc			;d7d3	c5 	.
	push de			;d7d4	d5 	.
	push hl			;d7d5	e5 	.
	ld c,002h		;d7d6	0e 02 	. .
	ld a,(hl)			;d7d8	7e 	~
	ld (de),a			;d7d9	12 	.
	inc de			;d7da	13 	.
	ld a,d			;d7db	7a 	z
	and 007h		;d7dc	e6 07 	. .
	or 0d0h		;d7de	f6 d0 	. .
	ld d,a			;d7e0	57 	W
	inc hl			;d7e1	23 	#
	bit 3,h		;d7e2	cb 5c 	. \
	call z,0c715h		;d7e4	cc 15 c7 	. . .
	djnz $-15		;d7e7	10 ef 	. .
	dec c			;d7e9	0d 	.
	jr z,$+12		;d7ea	28 0a 	( .
	ld a,c			;d7ec	79 	y
	pop hl			;d7ed	e1 	.
	pop de			;d7ee	d1 	.
	pop bc			;d7ef	c1 	.
	ld c,a			;d7f0	4f 	O
	call 0c795h		;d7f1	cd 95 c7 	. . .
	jr $-28		;d7f4	18 e2 	. .
	call 0c79eh		;d7f6	cd 9e c7 	. . .
	ret			;d7f9	c9 	.
	push de			;d7fa	d5 	.
	push bc			;d7fb	c5 	.
	ld de,00050h		;d7fc	11 50 00 	. P .
	call 0c7b6h		;d7ff	cd b6 c7 	. . .
	pop bc			;d802	c1 	.
	pop de			;d803	d1 	.
	ret			;d804	c9 	.
	ld a,e			;d805	7b 	{
	sub c			;d806	91 	.
	inc a			;d807	3c 	<
	ld e,a			;d808	5f 	_
	ld a,d			;d809	7a 	z
	sub b			;d80a	90 	.
	inc a			;d80b	3c 	<
	ld d,a			;d80c	57 	W
	call 0c6f1h		;d80d	cd f1 c6 	. . .
	call 0c715h		;d810	cd 15 c7 	. . .
	ld (hl),020h		;d813	36 20 	6
	call 0c795h		;d815	cd 95 c7 	. . .
	ld (hl),000h		;d818	36 00 	6 .
	call 0c79eh		;d81a	cd 9e c7 	. . .
	inc hl			;d81d	23 	#
	dec e			;d81e	1d 	.
	jr nz,$-15		;d81f	20 ef 	  .
	inc b			;d821	04 	.
	ld a,(0ffd0h)		;d822	3a d0 ff 	: . .
	ld c,a			;d825	4f 	O
	ld a,(0ffcfh)		;d826	3a cf ff 	: . .
	sub c			;d829	91 	.
	inc a			;d82a	3c 	<
	ld e,a			;d82b	5f 	_
	dec d			;d82c	15 	.
	jr nz,$-32		;d82d	20 de 	  .
	ret			;d82f	c9 	.
	ld a,(0ffcdh)		;d830	3a cd ff 	: . .
	ld b,a			;d833	47 	G
	ld a,(0ffceh)		;d834	3a ce ff 	: . .
	cp b			;d837	b8 	.
	jr z,$+13		;d838	28 0b 	( .
	ld d,a			;d83a	57 	W
	ld a,b			;d83b	78 	x
	sub d			;d83c	92 	.
	ld d,a			;d83d	57 	W
	dec b			;d83e	05 	.
	call 0c7fah		;d83f	cd fa c7 	. . .
	dec d			;d842	15 	.
	jr nz,$-5		;d843	20 f9 	  .
	ld a,(0ffceh)		;d845	3a ce ff 	: . .
	ld b,a			;d848	47 	G
	ld d,a			;d849	57 	W
	ld a,(0ffd0h)		;d84a	3a d0 ff 	: . .
	ld c,a			;d84d	4f 	O
	ld a,(0ffcfh)		;d84e	3a cf ff 	: . .
	ld e,a			;d851	5f 	_
	call 0c805h		;d852	cd 05 c8 	. . .
	ret			;d855	c9 	.
	push bc			;d856	c5 	.
	ld b,01eh		;d857	06 1e 	. .
	ld c,00fh		;d859	0e 0f 	. .
	dec c			;d85b	0d 	.
	jp nz,0c85bh		;d85c	c2 5b c8 	. [ .
	dec b			;d85f	05 	.
	jp nz,0c859h		;d860	c2 59 c8 	. Y .
	pop bc			;d863	c1 	.
	ret			;d864	c9 	.
	ld h,e			;d865	63 	c
	ld d,b			;d866	50 	P
	ld d,h			;d867	54 	T
	xor d			;d868	aa 	.
	add hl,de			;d869	19 	.
	ld b,019h		;d86a	06 19 	. .
	add hl,de			;d86c	19 	.
	nop			;d86d	00 	.
	dec c			;d86e	0d 	.
	dec c			;d86f	0d 	.
	dec c			;d870	0d 	.
	nop			;d871	00 	.
	nop			;d872	00 	.
	nop			;d873	00 	.
	nop			;d874	00 	.
	ld a,(0ffd1h)		;d875	3a d1 ff 	: . .
	set 3,a		;d878	cb df 	. .
	ld (0ffd1h),a		;d87a	32 d1 ff 	2 . .
	ld a,(0ffcah)		;d87d	3a ca ff 	: . .
	ld c,a			;d880	4f 	O
	rra			;d881	1f 	.
	jr nc,$+9		;d882	30 07 	0 .
	inc iy		;d884	fd 23 	. #
	inc c			;d886	0c 	.
	ld a,c			;d887	79 	y
	ld (0ffcah),a		;d888	32 ca ff 	2 . .
	xor a			;d88b	af 	.
	ret			;d88c	c9 	.
	ld hl,0c865h		;d88d	21 65 c8 	! e .
	ld b,010h		;d890	06 10 	. .
	ld c,0a1h		;d892	0e a1 	. .
	xor a			;d894	af 	.
	out (0a0h),a		;d895	d3 a0 	. .
	inc a			;d897	3c 	<
	outi		;d898	ed a3 	. .
	jr nz,$-5		;d89a	20 f9 	  .
	ld ix,00000h		;d89c	dd 21 00 00 	. ! . .
	call 0c764h		;d8a0	cd 64 c7 	. d .
	call 0c8b6h		;d8a3	cd b6 c8 	. . .
	ld hl,00000h		;d8a6	21 00 00 	! . .
	call 0c71ch		;d8a9	cd 1c c7 	. . .
	ld a,(0ffd1h)		;d8ac	3a d1 ff 	: . .
	res 3,a		;d8af	cb 9f 	. .
	ld (0ffd1h),a		;d8b1	32 d1 ff 	2 . .
	xor a			;d8b4	af 	.
	ret			;d8b5	c9 	.
	ld a,006h		;d8b6	3e 06 	> .
	out (0a0h),a		;d8b8	d3 a0 	. .
	ld a,018h		;d8ba	3e 18 	> .
	out (0a1h),a		;d8bc	d3 a1 	. .
	ret			;d8be	c9 	.
	xor a			;d8bf	af 	.
	ld (0ffceh),a		;d8c0	32 ce ff 	2 . .
	ld (0ffd0h),a		;d8c3	32 d0 ff 	2 . .
	ld (0ffc9h),a		;d8c6	32 c9 ff 	2 . .
	ld a,017h		;d8c9	3e 17 	> .
	ld (0ffcdh),a		;d8cb	32 cd ff 	2 . .
	ret			;d8ce	c9 	.
	ld b,004h		;d8cf	06 04 	. .
	call 0c75bh		;d8d1	cd 5b c7 	. [ .
	xor a			;d8d4	af 	.
	ld c,0a1h		;d8d5	0e a1 	. .
	out (0a0h),a		;d8d7	d3 a0 	. .
	inc a			;d8d9	3c 	<
	outi		;d8da	ed a3 	. .
	jr nz,$-5		;d8dc	20 f9 	  .
	ret			;d8de	c9 	.
	ld a,(0ffd9h)		;d8df	3a d9 ff 	: . .
	or a			;d8e2	b7 	.
	jr nz,$+7		;d8e3	20 05 	  .
	inc a			;d8e5	3c 	<
	ld (0ffd9h),a		;d8e6	32 d9 ff 	2 . .
	ret			;d8e9	c9 	.
	ld a,c			;d8ea	79 	y
	and 00fh		;d8eb	e6 0f 	. .
	rlca			;d8ed	07 	.
	rlca			;d8ee	07 	.
	rlca			;d8ef	07 	.
	rlca			;d8f0	07 	.
	cpl			;d8f1	2f 	/
	ld b,a			;d8f2	47 	G
	ld a,(0ffd1h)		;d8f3	3a d1 ff 	: . .
	and b			;d8f6	a0 	.
	ld (0ffd1h),a		;d8f7	32 d1 ff 	2 . .
	xor a			;d8fa	af 	.
	ret			;d8fb	c9 	.
	xor a			;d8fc	af 	.
	ld (0ffd1h),a		;d8fd	32 d1 ff 	2 . .
	ret			;d900	c9 	.
	ld a,(0ffd9h)		;d901	3a d9 ff 	: . .
	ld b,a			;d904	47 	G
	ld d,000h		;d905	16 00 	. .
	ld e,a			;d907	5f 	_
	ld hl,0ffd9h		;d908	21 d9 ff 	! . .
	add hl,de			;d90b	19 	.
	ld a,c			;d90c	79 	y
	sub 020h		;d90d	d6 20 	.
	ld (hl),a			;d90f	77 	w
	ld a,b			;d910	78 	x
	inc a			;d911	3c 	<
	ld (0ffd9h),a		;d912	32 d9 ff 	2 . .
	ret			;d915	c9 	.
	ld a,b			;d916	78 	x
	out (0a0h),a		;d917	d3 a0 	. .
	ld a,c			;d919	79 	y
	out (0a1h),a		;d91a	d3 a1 	. .
	ret			;d91c	c9 	.
	call 0c6f1h		;d91d	cd f1 c6 	. . .
	push hl			;d920	e5 	.
	ld b,d			;d921	42 	B
	ld c,e			;d922	4b 	K
	call 0c6f1h		;d923	cd f1 c6 	. . .
	pop de			;d926	d1 	.
	push de			;d927	d5 	.
	or a			;d928	b7 	.
	sbc hl,de		;d929	ed 52 	. R
	inc hl			;d92b	23 	#
	ex de,hl			;d92c	eb 	.
	pop hl			;d92d	e1 	.
	ld b,a			;d92e	47 	G
	call 0c795h		;d92f	cd 95 c7 	. . .
	call 0c715h		;d932	cd 15 c7 	. . .
	ld a,(hl)			;d935	7e 	~
	or b			;d936	b0 	.
	ld (hl),a			;d937	77 	w
	inc hl			;d938	23 	#
	dec de			;d939	1b 	.
	ld a,d			;d93a	7a 	z
	or e			;d93b	b3 	.
	jr nz,$-10		;d93c	20 f4 	  .
	call 0c79eh		;d93e	cd 9e c7 	. . .
	ret			;d941	c9 	.
	ld a,c			;d942	79 	y
	cp 044h		;d943	fe 44 	. D
	jr nz,$+6		;d945	20 04 	  .
	ld c,040h		;d947	0e 40 	. @
	jr $+59		;d949	18 39 	. 9
	cp 045h		;d94b	fe 45 	. E
	jr nz,$+6		;d94d	20 04 	  .
	ld c,060h		;d94f	0e 60 	. `
	jr $+51		;d951	18 31 	. 1
	cp 046h		;d953	fe 46 	. F
	jr nz,$+6		;d955	20 04 	  .
	ld c,020h		;d957	0e 20 	.
	jr $+43		;d959	18 29 	. )
	ld a,(0c86fh)		;d95b	3a 6f c8 	: o .
	ld d,a			;d95e	57 	W
	in a,(0d6h)		;d95f	db d6 	. .
	bit 5,a		;d961	cb 6f 	. o
	jr z,$+4		;d963	28 02 	( .
	ld d,003h		;d965	16 03 	. .
	bit 6,a		;d967	cb 77 	. w
	jr z,$+6		;d969	28 04 	( .
	set 5,d		;d96b	cb ea 	. .
	set 6,d		;d96d	cb f2 	. .
	ld a,d			;d96f	7a 	z
	ld (0ffd3h),a		;d970	32 d3 ff 	2 . .
	ld b,00ah		;d973	06 0a 	. .
	ld c,a			;d975	4f 	O
	call 0c916h		;d976	cd 16 c9 	. . .
	ld a,(0c870h)		;d979	3a 70 c8 	: p .
	ld c,a			;d97c	4f 	O
	ld b,00bh		;d97d	06 0b 	. .
	call 0c916h		;d97f	cd 16 c9 	. . .
	xor a			;d982	af 	.
	ret			;d983	c9 	.
	ld a,(0ffd3h)		;d984	3a d3 ff 	: . .
	and 09fh		;d987	e6 9f 	. .
	or c			;d989	b1 	.
	ld (0ffd3h),a		;d98a	32 d3 ff 	2 . .
	ld c,a			;d98d	4f 	O
	ld b,00ah		;d98e	06 0a 	. .
	call 0c916h		;d990	cd 16 c9 	. . .
	xor a			;d993	af 	.
	ret			;d994	c9 	.
	ld hl,0ffd1h		;d995	21 d1 ff 	! . .
	set 0,(hl)		;d998	cb c6 	. .
	xor a			;d99a	af 	.
	ret			;d99b	c9 	.
	ld hl,0ffd1h		;d99c	21 d1 ff 	! . .
	res 0,(hl)		;d99f	cb 86 	. .
	xor a			;d9a1	af 	.
	ret			;d9a2	c9 	.
	ld hl,0ffd1h		;d9a3	21 d1 ff 	! . .
	set 2,(hl)		;d9a6	cb d6 	. .
	xor a			;d9a8	af 	.
	ret			;d9a9	c9 	.
	ld hl,0ffd1h		;d9aa	21 d1 ff 	! . .
	res 2,(hl)		;d9ad	cb 96 	. .
	xor a			;d9af	af 	.
	ret			;d9b0	c9 	.
	ld hl,0ffd1h		;d9b1	21 d1 ff 	! . .
	set 1,(hl)		;d9b4	cb ce 	. .
	xor a			;d9b6	af 	.
	ret			;d9b7	c9 	.
	ld hl,0ffd1h		;d9b8	21 d1 ff 	! . .
	res 1,(hl)		;d9bb	cb 8e 	. .
	xor a			;d9bd	af 	.
	ret			;d9be	c9 	.
	ld a,(0ffd1h)		;d9bf	3a d1 ff 	: . .
	and 08fh		;d9c2	e6 8f 	. .
	or 010h		;d9c4	f6 10 	. .
	ld (0ffd1h),a		;d9c6	32 d1 ff 	2 . .
	xor a			;d9c9	af 	.
	ret			;d9ca	c9 	.
	ld a,(0ffd1h)		;d9cb	3a d1 ff 	: . .
	and 08fh		;d9ce	e6 8f 	. .
	or 000h		;d9d0	f6 00 	. .
	ld (0ffd1h),a		;d9d2	32 d1 ff 	2 . .
	xor a			;d9d5	af 	.
	ret			;d9d6	c9 	.
	ld a,(0ffd1h)		;d9d7	3a d1 ff 	: . .
	and 08fh		;d9da	e6 8f 	. .
	or 020h		;d9dc	f6 20 	.
	ld (0ffd1h),a		;d9de	32 d1 ff 	2 . .
	xor a			;d9e1	af 	.
	ret			;d9e2	c9 	.
	call 0ca01h		;d9e3	cd 01 ca 	. . .
	cp 001h		;d9e6	fe 01 	. .
	jr nz,$+3		;d9e8	20 01 	  .
	ld a,c			;d9ea	79 	y
	ld (0ffd8h),a		;d9eb	32 d8 ff 	2 . .
	cp 060h		;d9ee	fe 60 	. `
	jp nc,0ca70h		;d9f0	d2 70 ca 	. p .
	sub 031h		;d9f3	d6 31 	. 1
	jp c,0ca70h		;d9f5	da 70 ca 	. p .
	call 0ca05h		;d9f8	cd 05 ca 	. . .
	or a			;d9fb	b7 	.
	jr z,$+116		;d9fc	28 72 	( r
	jp 0c6a3h		;d9fe	c3 a3 c6 	. . .
	ld hl,(0bffah)		;da01	2a fa bf 	* . .
	jp (hl)			;da04	e9 	.
	add a,a			;da05	87 	.
	ld hl,0ca12h		;da06	21 12 ca 	! . .
	ld d,000h		;da09	16 00 	. .
	ld e,a			;da0b	5f 	_
	add hl,de			;da0c	19 	.
	ld e,(hl)			;da0d	5e 	^
	inc hl			;da0e	23 	#
	ld d,(hl)			;da0f	56 	V
	ex de,hl			;da10	eb 	.
	jp (hl)			;da11	e9 	.
	ld b,d			;da12	42 	B
	call 0cd46h		;da13	cd 46 cd 	. F .
	ld a,d			;da16	7a 	z
	jp z,0ca7ah		;da17	ca 7a ca 	. z .
	ld a,d			;da1a	7a 	z
	jp z,0ca7ch		;da1b	ca 7c ca 	. | .
	cp a			;da1e	bf 	.
	ret			;da1f	c9 	.
	ld a,a			;da20	7f 	
	call z,0ca7ah		;da21	cc 7a ca 	. z .
	call nc,0f2cah		;da24	d4 ca f2 	. . .
	jp z,0cb1ch		;da27	ca 1c cb 	. . .
	ld l,d			;da2a	6a 	j
	res 3,a		;da2b	cb 9f 	. .
	res 7,e		;da2d	cb bb 	. .
	bit 7,h		;da2f	cb 7c 	. |
	jp z,0c875h		;da31	ca 75 c8 	. u .
	xor h			;da34	ac 	.
	ret z			;da35	c8 	.
	ld a,d			;da36	7a 	z
	jp z,0c942h		;da37	ca 42 c9 	. B .
	ld b,d			;da3a	42 	B
	ret			;da3b	c9 	.
	ld b,d			;da3c	42 	B
	ret			;da3d	c9 	.
	ld b,d			;da3e	42 	B
	ret			;da3f	c9 	.
	sub l			;da40	95 	.
	ret			;da41	c9 	.
	sbc a,h			;da42	9c 	.
	ret			;da43	c9 	.
	and e			;da44	a3 	.
	ret			;da45	c9 	.
	xor d			;da46	aa 	.
	ret			;da47	c9 	.
	or c			;da48	b1 	.
	ret			;da49	c9 	.
	cp b			;da4a	b8 	.
	ret			;da4b	c9 	.
	ld b,l			;da4c	45 	E
	call z,0ca7ah		;da4d	cc 7a ca 	. z .
	xor e			;da50	ab 	.
	call z,0ccdfh		;da51	cc df cc 	. . .
	ld a,d			;da54	7a 	z
	jp z,0cbdah		;da55	ca da cb 	. . .
	inc b			;da58	04 	.
	call z,0cc1bh		;da59	cc 1b cc 	. . .
	inc sp			;da5c	33 	3
	call z,0c9bfh		;da5d	cc bf c9 	. . .
	set 1,c		;da60	cb c9 	. .
	rst 10h			;da62	d7 	.
	ret			;da63	c9 	.
	cp a			;da64	bf 	.
	ret			;da65	c9 	.
	ld a,a			;da66	7f 	
	call z,0c8dfh		;da67	cc df c8 	. . .
	call m,095c8h		;da6a	fc c8 95 	. . .
	call z,0cd27h		;da6d	cc 27 cd 	. ' .
	xor a			;da70	af 	.
	ld (0ffd8h),a		;da71	32 d8 ff 	2 . .
	ld (0ffd9h),a		;da74	32 d9 ff 	2 . .
	jp 0c6a3h		;da77	c3 a3 c6 	. . .
	xor a			;da7a	af 	.
	ret			;da7b	c9 	.
	call 0cdd7h		;da7c	cd d7 cd 	. . .
	cp 001h		;da7f	fe 01 	. .
	jr nz,$+11		;da81	20 09 	  .
	ld a,c			;da83	79 	y
	cp 031h		;da84	fe 31 	. 1
	jr c,$+42		;da86	38 28 	8 (
	cp 036h		;da88	fe 36 	. 6
	jr nc,$+38		;da8a	30 24 	0 $
	call 0cab5h		;da8c	cd b5 ca 	. . .
	or a			;da8f	b7 	.
	ret nz			;da90	c0 	.
	ld a,(0ffdah)		;da91	3a da ff 	: . .
	and 00fh		;da94	e6 0f 	. .
	dec a			;da96	3d 	=
	add a,a			;da97	87 	.
	ld b,a			;da98	47 	G
	add a,a			;da99	87 	.
	ld c,a			;da9a	4f 	O
	add a,a			;da9b	87 	.
	add a,b			;da9c	80 	.
	add a,c			;da9d	81 	.
	add a,004h		;da9e	c6 04 	. .
	ld hl,(0bff4h)		;daa0	2a f4 bf 	* . .
	ld d,000h		;daa3	16 00 	. .
	ld e,a			;daa5	5f 	_
	add hl,de			;daa6	19 	.
	ex de,hl			;daa7	eb 	.
	ld hl,0ffdbh		;daa8	21 db ff 	! . .
	ld bc,00009h		;daab	01 09 00 	. . .
	ldir		;daae	ed b0 	. .
	call 0cd51h		;dab0	cd 51 cd 	. Q .
	xor a			;dab3	af 	.
	ret			;dab4	c9 	.
	call 0c901h		;dab5	cd 01 c9 	. . .
	ld (hl),c			;dab8	71 	q
	cp 00ah		;dab9	fe 0a 	. .
	ret nz			;dabb	c0 	.
	ld hl,0ffdbh		;dabc	21 db ff 	! . .
	ld b,008h		;dabf	06 08 	. .
	ld a,(hl)			;dac1	7e 	~
	inc hl			;dac2	23 	#
	cp 07fh		;dac3	fe 7f 	. 
	jr z,$+8		;dac5	28 06 	( .
	djnz $-6		;dac7	10 f8 	. .
	ld (hl),07fh		;dac9	36 7f 	6 
	jr $+7		;dacb	18 05 	. .
	ld hl,0ffe3h		;dacd	21 e3 ff 	! . .
	ld (hl),020h		;dad0	36 20 	6
	xor a			;dad2	af 	.
	ret			;dad3	c9 	.
	call 0cdd7h		;dad4	cd d7 cd 	. . .
	cp 004h		;dad7	fe 04 	. .
	jr z,$+6		;dad9	28 04 	( .
	call 0c901h		;dadb	cd 01 c9 	. . .
	ret			;dade	c9 	.
	ld a,c			;dadf	79 	y
	sub 020h		;dae0	d6 20 	.
	ld e,a			;dae2	5f 	_
	ld hl,0ffdah		;dae3	21 da ff 	! . .
	ld b,(hl)			;dae6	46 	F
	inc hl			;dae7	23 	#
	ld c,(hl)			;dae8	4e 	N
	inc hl			;dae9	23 	#
	ld d,(hl)			;daea	56 	V
	ld a,001h		;daeb	3e 01 	> .
	call 0c91dh		;daed	cd 1d c9 	. . .
	xor a			;daf0	af 	.
	ret			;daf1	c9 	.
	call 0cdd7h		;daf2	cd d7 cd 	. . .
	cp 002h		;daf5	fe 02 	. .
	jr z,$+6		;daf7	28 04 	( .
	call 0c901h		;daf9	cd 01 c9 	. . .
	ret			;dafc	c9 	.
	ld a,c			;dafd	79 	y
	sub 020h		;dafe	d6 20 	.
	ld e,a			;db00	5f 	_
	ld a,(0ffdah)		;db01	3a da ff 	: . .
	ld d,a			;db04	57 	W
	ld a,(0ffd3h)		;db05	3a d3 ff 	: . .
	and 060h		;db08	e6 60 	. `
	or d			;db0a	b2 	.
	ld (0ffd3h),a		;db0b	32 d3 ff 	2 . .
	ld c,a			;db0e	4f 	O
	ld b,00ah		;db0f	06 0a 	. .
	call 0c916h		;db11	cd 16 c9 	. . .
	ld c,e			;db14	4b 	K
	ld b,00bh		;db15	06 0b 	. .
	call 0c916h		;db17	cd 16 c9 	. . .
	xor a			;db1a	af 	.
	ret			;db1b	c9 	.
	call 0cdd7h		;db1c	cd d7 cd 	. . .
	cp 004h		;db1f	fe 04 	. .
	jr z,$+6		;db21	28 04 	( .
	call 0c901h		;db23	cd 01 c9 	. . .
	ret			;db26	c9 	.
	ld a,c			;db27	79 	y
	sub 020h		;db28	d6 20 	.
	ld e,a			;db2a	5f 	_
	ld a,04fh		;db2b	3e 4f 	> O
	cp e			;db2d	bb 	.
	jr c,$+58		;db2e	38 38 	8 8
	ld hl,0ffdah		;db30	21 da ff 	! . .
	ld b,(hl)			;db33	46 	F
	inc hl			;db34	23 	#
	ld a,(hl)			;db35	7e 	~
	cp 018h		;db36	fe 18 	. .
	jr nc,$+48		;db38	30 2e 	0 .
	ld c,a			;db3a	4f 	O
	inc hl			;db3b	23 	#
	ld d,(hl)			;db3c	56 	V
	ld a,c			;db3d	79 	y
	cp b			;db3e	b8 	.
	jr c,$+41		;db3f	38 27 	8 '
	ld a,e			;db41	7b 	{
	cp d			;db42	ba 	.
	jr c,$+37		;db43	38 23 	8 #
	ld hl,0ffcdh		;db45	21 cd ff 	! . .
	ld (hl),c			;db48	71 	q
	inc hl			;db49	23 	#
	ld (hl),b			;db4a	70 	p
	inc hl			;db4b	23 	#
	ld (hl),e			;db4c	73 	s
	inc hl			;db4d	23 	#
	ld (hl),d			;db4e	72 	r
	ld a,001h		;db4f	3e 01 	> .
	ld (0ffc9h),a		;db51	32 c9 ff 	2 . .
	ld a,050h		;db54	3e 50 	> P
	sub e			;db56	93 	.
	ld e,a			;db57	5f 	_
	ld a,d			;db58	7a 	z
	add a,e			;db59	83 	.
	ld hl,0ffd1h		;db5a	21 d1 ff 	! . .
	bit 3,(hl)		;db5d	cb 5e 	. ^
	jr z,$+3		;db5f	28 01 	( .
	add a,a			;db61	87 	.
	ld (0ffc8h),a		;db62	32 c8 ff 	2 . .
	call 0cc1bh		;db65	cd 1b cc 	. . .
	xor a			;db68	af 	.
	ret			;db69	c9 	.
	call 0cdd7h		;db6a	cd d7 cd 	. . .
	cp 002h		;db6d	fe 02 	. .
	jr z,$+6		;db6f	28 04 	( .
	call 0c901h		;db71	cd 01 c9 	. . .
	ret			;db74	c9 	.
	ld a,c			;db75	79 	y
	sub 020h		;db76	d6 20 	.
	ld c,a			;db78	4f 	O
	ld a,04fh		;db79	3e 4f 	> O
	cp c			;db7b	b9 	.
	jr c,$+33		;db7c	38 1f 	8 .
	ld a,(0ffd1h)		;db7e	3a d1 ff 	: . .
	bit 3,a		;db81	cb 5f 	. _
	jr z,$+5		;db83	28 03 	( .
	ld a,c			;db85	79 	y
	add a,a			;db86	87 	.
	ld c,a			;db87	4f 	O
	ld a,(0ffdah)		;db88	3a da ff 	: . .
	cp 019h		;db8b	fe 19 	. .
	jr nc,$+16		;db8d	30 0e 	0 .
	ld b,a			;db8f	47 	G
	ld (0ffcbh),a		;db90	32 cb ff 	2 . .
	ld a,c			;db93	79 	y
	ld (0ffcah),a		;db94	32 ca ff 	2 . .
	call 0c6f1h		;db97	cd f1 c6 	. . .
	call 0c71ch		;db9a	cd 1c c7 	. . .
	xor a			;db9d	af 	.
	ret			;db9e	c9 	.
	call 0cdd7h		;db9f	cd d7 cd 	. . .
	ld a,c			;dba2	79 	y
	sub 020h		;dba3	d6 20 	.
	ld c,a			;dba5	4f 	O
	ld a,04fh		;dba6	3e 4f 	> O
	cp c			;dba8	b9 	.
	jr c,$+16		;dba9	38 0e 	8 .
	ld a,(0ffcbh)		;dbab	3a cb ff 	: . .
	ld b,a			;dbae	47 	G
	ld a,c			;dbaf	79 	y
	ld (0ffcah),a		;dbb0	32 ca ff 	2 . .
	call 0c6f1h		;dbb3	cd f1 c6 	. . .
	call 0c71ch		;dbb6	cd 1c c7 	. . .
	xor a			;dbb9	af 	.
	ret			;dbba	c9 	.
	call 0cdd7h		;dbbb	cd d7 cd 	. . .
	cp 004h		;dbbe	fe 04 	. .
	jr z,$+6		;dbc0	28 04 	( .
	call 0c901h		;dbc2	cd 01 c9 	. . .
	ret			;dbc5	c9 	.
	ld a,c			;dbc6	79 	y
	sub 020h		;dbc7	d6 20 	.
	ld e,a			;dbc9	5f 	_
	ld hl,0ffdah		;dbca	21 da ff 	! . .
	ld b,(hl)			;dbcd	46 	F
	inc hl			;dbce	23 	#
	ld c,(hl)			;dbcf	4e 	N
	inc hl			;dbd0	23 	#
	ld d,(hl)			;dbd1	56 	V
	ld a,(0ffd2h)		;dbd2	3a d2 ff 	: . .
	call 0c91dh		;dbd5	cd 1d c9 	. . .
	xor a			;dbd8	af 	.
	ret			;dbd9	c9 	.
	ld bc,00780h		;dbda	01 80 07 	. . .
	push ix		;dbdd	dd e5 	. .
	pop hl			;dbdf	e1 	.
	call 0c795h		;dbe0	cd 95 c7 	. . .
	ld a,(0ffd2h)		;dbe3	3a d2 ff 	: . .
	ld d,a			;dbe6	57 	W
	ld e,020h		;dbe7	1e 20 	.
	call 0c715h		;dbe9	cd 15 c7 	. . .
	ld a,(hl)			;dbec	7e 	~
	and d			;dbed	a2 	.
	jr nz,$+11		;dbee	20 09 	  .
	ld (hl),000h		;dbf0	36 00 	6 .
	call 0c795h		;dbf2	cd 95 c7 	. . .
	ld (hl),e			;dbf5	73 	s
	call 0c795h		;dbf6	cd 95 c7 	. . .
	inc hl			;dbf9	23 	#
	dec bc			;dbfa	0b 	.
	ld a,b			;dbfb	78 	x
	or c			;dbfc	b1 	.
	jr nz,$-20		;dbfd	20 ea 	  .
	call 0c79eh		;dbff	cd 9e c7 	. . .
	xor a			;dc02	af 	.
	ret			;dc03	c9 	.
	ld a,(0ffd0h)		;dc04	3a d0 ff 	: . .
	ld c,a			;dc07	4f 	O
	ld a,(0ffceh)		;dc08	3a ce ff 	: . .
	ld b,a			;dc0b	47 	G
	ld a,(0ffcfh)		;dc0c	3a cf ff 	: . .
	ld e,a			;dc0f	5f 	_
	ld a,(0ffcdh)		;dc10	3a cd ff 	: . .
	ld d,a			;dc13	57 	W
	call 0c805h		;dc14	cd 05 c8 	. . .
	call 0cc1bh		;dc17	cd 1b cc 	. . .
	ret			;dc1a	c9 	.
	ld a,(0ffceh)		;dc1b	3a ce ff 	: . .
	ld b,a			;dc1e	47 	G
	ld a,(0ffd0h)		;dc1f	3a d0 ff 	: . .
	ld c,a			;dc22	4f 	O
	call 0c6f1h		;dc23	cd f1 c6 	. . .
	call 0c71ch		;dc26	cd 1c c7 	. . .
	ld a,b			;dc29	78 	x
	ld (0ffcbh),a		;dc2a	32 cb ff 	2 . .
	ld a,c			;dc2d	79 	y
	ld (0ffcah),a		;dc2e	32 ca ff 	2 . .
	xor a			;dc31	af 	.
	ret			;dc32	c9 	.
	call 0c764h		;dc33	cd 64 c7 	. d .
	ld a,001h		;dc36	3e 01 	> .
	ld (0ffc8h),a		;dc38	32 c8 ff 	2 . .
	ld a,04fh		;dc3b	3e 4f 	> O
	ld (0ffcfh),a		;dc3d	32 cf ff 	2 . .
	call 0c8bfh		;dc40	cd bf c8 	. . .
	xor a			;dc43	af 	.
	ret			;dc44	c9 	.
	ld b,000h		;dc45	06 00 	. .
	ld c,000h		;dc47	0e 00 	. .
	push bc			;dc49	c5 	.
	call 0cdf4h		;dc4a	cd f4 cd 	. . .
	ld c,d			;dc4d	4a 	J
	push de			;dc4e	d5 	.
	call 0ffa0h		;dc4f	cd a0 ff 	. . .
	pop de			;dc52	d1 	.
	pop bc			;dc53	c1 	.
	bit 3,e		;dc54	cb 5b 	. [
	jr z,$+15		;dc56	28 0d 	( .
	inc c			;dc58	0c 	.
	ld a,c			;dc59	79 	y
	cp 050h		;dc5a	fe 50 	. P
	jr z,$+15		;dc5c	28 0d 	( .
	push bc			;dc5e	c5 	.
	ld c,020h		;dc5f	0e 20 	.
	call 0ffa0h		;dc61	cd a0 ff 	. . .
	pop bc			;dc64	c1 	.
	inc c			;dc65	0c 	.
	ld a,c			;dc66	79 	y
	cp 050h		;dc67	fe 50 	. P
	jr nz,$-32		;dc69	20 de 	  .
	push bc			;dc6b	c5 	.
	ld c,00dh		;dc6c	0e 0d 	. .
	call 0ffa0h		;dc6e	cd a0 ff 	. . .
	ld c,00ah		;dc71	0e 0a 	. .
	call 0ffa0h		;dc73	cd a0 ff 	. . .
	pop bc			;dc76	c1 	.
	inc b			;dc77	04 	.
	ld a,b			;dc78	78 	x
	cp 018h		;dc79	fe 18 	. .
	jr nz,$-52		;dc7b	20 ca 	  .
	xor a			;dc7d	af 	.
	ret			;dc7e	c9 	.
	call 0cdd7h		;dc7f	cd d7 cd 	. . .
	ld a,c			;dc82	79 	y
	and 00fh		;dc83	e6 0f 	. .
	rlca			;dc85	07 	.
	rlca			;dc86	07 	.
	rlca			;dc87	07 	.
	rlca			;dc88	07 	.
	ld b,a			;dc89	47 	G
	ld a,(0ffd1h)		;dc8a	3a d1 ff 	: . .
	and 00fh		;dc8d	e6 0f 	. .
	or b			;dc8f	b0 	.
	ld (0ffd1h),a		;dc90	32 d1 ff 	2 . .
	xor a			;dc93	af 	.
	ret			;dc94	c9 	.
	call 0cdd7h		;dc95	cd d7 cd 	. . .
	ld a,c			;dc98	79 	y
	cp 030h		;dc99	fe 30 	. 0
	jr z,$+16		;dc9b	28 0e 	( .
	cp 031h		;dc9d	fe 31 	. 1
	jr z,$+30		;dc9f	28 1c 	( .
	cp 032h		;dca1	fe 32 	. 2
	jr z,$+60		;dca3	28 3a 	( :
	cp 033h		;dca5	fe 33 	. 3
	jr z,$+77		;dca7	28 4b 	( K
	xor a			;dca9	af 	.
	ret			;dcaa	c9 	.
	ld a,(0ffcbh)		;dcab	3a cb ff 	: . .
	ld b,a			;dcae	47 	G
	ld d,a			;dcaf	57 	W
	ld a,(0ffcah)		;dcb0	3a ca ff 	: . .
	ld c,a			;dcb3	4f 	O
	ld a,(0ffcfh)		;dcb4	3a cf ff 	: . .
	ld e,a			;dcb7	5f 	_
	call 0c805h		;dcb8	cd 05 c8 	. . .
	xor a			;dcbb	af 	.
	ret			;dcbc	c9 	.
	ld a,(0ffceh)		;dcbd	3a ce ff 	: . .
	ld b,a			;dcc0	47 	G
	ld a,(0ffcbh)		;dcc1	3a cb ff 	: . .
	ld (0ffceh),a		;dcc4	32 ce ff 	2 . .
	ld a,(0ffc9h)		;dcc7	3a c9 ff 	: . .
	ld c,a			;dcca	4f 	O
	ld a,001h		;dccb	3e 01 	> .
	ld (0ffc9h),a		;dccd	32 c9 ff 	2 . .
	push bc			;dcd0	c5 	.
	call 0c62eh		;dcd1	cd 2e c6 	. . .
	pop bc			;dcd4	c1 	.
	ld a,b			;dcd5	78 	x
	ld (0ffceh),a		;dcd6	32 ce ff 	2 . .
	ld a,c			;dcd9	79 	y
	ld (0ffc9h),a		;dcda	32 c9 ff 	2 . .
	xor a			;dcdd	af 	.
	ret			;dcde	c9 	.
	ld a,(0ffcbh)		;dcdf	3a cb ff 	: . .
	ld b,a			;dce2	47 	G
	ld a,(0ffcah)		;dce3	3a ca ff 	: . .
	ld c,a			;dce6	4f 	O
	ld a,(0ffcdh)		;dce7	3a cd ff 	: . .
	ld d,a			;dcea	57 	W
	ld a,(0ffcfh)		;dceb	3a cf ff 	: . .
	ld e,a			;dcee	5f 	_
	call 0c805h		;dcef	cd 05 c8 	. . .
	xor a			;dcf2	af 	.
	ret			;dcf3	c9 	.
	ld a,(0ffceh)		;dcf4	3a ce ff 	: . .
	ld b,a			;dcf7	47 	G
	ld a,(0ffcbh)		;dcf8	3a cb ff 	: . .
	ld c,a			;dcfb	4f 	O
	ld a,(0ffcdh)		;dcfc	3a cd ff 	: . .
	cp c			;dcff	b9 	.
	jr z,$+24		;dd00	28 16 	( .
	ld a,c			;dd02	79 	y
	ld (0ffceh),a		;dd03	32 ce ff 	2 . .
	push bc			;dd06	c5 	.
	call 0c830h		;dd07	cd 30 c8 	. 0 .
	pop bc			;dd0a	c1 	.
	ld a,b			;dd0b	78 	x
	ld (0ffceh),a		;dd0c	32 ce ff 	2 . .
	ld a,(0ffd0h)		;dd0f	3a d0 ff 	: . .
	ld c,a			;dd12	4f 	O
	call 0cb9fh		;dd13	cd 9f cb 	. . .
	xor a			;dd16	af 	.
	ret			;dd17	c9 	.
	ld b,a			;dd18	47 	G
	ld d,a			;dd19	57 	W
	ld a,(0ffcfh)		;dd1a	3a cf ff 	: . .
	ld e,a			;dd1d	5f 	_
	ld a,(0ffd0h)		;dd1e	3a d0 ff 	: . .
	ld c,a			;dd21	4f 	O
	call 0c805h		;dd22	cd 05 c8 	. . .
	jr $-22		;dd25	18 e8 	. .
	call 0cdd7h		;dd27	cd d7 cd 	. . .
	cp 002h		;dd2a	fe 02 	. .
	jp nc,0cd8ah		;dd2c	d2 8a cd 	. . .
	ld a,c			;dd2f	79 	y
	cp 030h		;dd30	fe 30 	. 0
	jr z,$+16		;dd32	28 0e 	( .
	cp 031h		;dd34	fe 31 	. 1
	jr z,$+16		;dd36	28 0e 	( .
	cp 034h		;dd38	fe 34 	. 4
	jr z,$+23		;dd3a	28 15 	( .
	cp 035h		;dd3c	fe 35 	. 5
	jr z,$+76		;dd3e	28 4a 	( J
	xor a			;dd40	af 	.
	ret			;dd41	c9 	.
	ld b,019h		;dd42	06 19 	. .
	jr $+4		;dd44	18 02 	. .
	ld b,018h		;dd46	06 18 	. .
	ld a,006h		;dd48	3e 06 	> .
	out (0a0h),a		;dd4a	d3 a0 	. .
	ld a,b			;dd4c	78 	x
	out (0a1h),a		;dd4d	d3 a1 	. .
	xor a			;dd4f	af 	.
	ret			;dd50	c9 	.
	ld hl,(0bff4h)		;dd51	2a f4 bf 	* . .
	ex de,hl			;dd54	eb 	.
	ld b,018h		;dd55	06 18 	. .
	ld c,000h		;dd57	0e 00 	. .
	call 0c6f1h		;dd59	cd f1 c6 	. . .
	ld a,(0bfeah)		;dd5c	3a ea bf 	: . .
	ld c,a			;dd5f	4f 	O
	ld b,046h		;dd60	06 46 	. F
	ld a,b			;dd62	78 	x
	ld (0ffdah),a		;dd63	32 da ff 	2 . .
	call 0c715h		;dd66	cd 15 c7 	. . .
	ld a,(de)			;dd69	1a 	.
	ld (hl),a			;dd6a	77 	w
	call 0c795h		;dd6b	cd 95 c7 	. . .
	ld (hl),c			;dd6e	71 	q
	call 0c79eh		;dd6f	cd 9e c7 	. . .
	inc de			;dd72	13 	.
	inc hl			;dd73	23 	#
	djnz $-14		;dd74	10 f0 	. .
	ld a,(0ffdah)		;dd76	3a da ff 	: . .
	or a			;dd79	b7 	.
	jr z,$+14		;dd7a	28 0c 	( .
	ld b,00ah		;dd7c	06 0a 	. .
	ld a,(0bfebh)		;dd7e	3a eb bf 	: . .
	ld c,a			;dd81	4f 	O
	xor a			;dd82	af 	.
	ld (0ffdah),a		;dd83	32 da ff 	2 . .
	jr $-32		;dd86	18 de 	. .
	xor a			;dd88	af 	.
	ret			;dd89	c9 	.
	ld a,c			;dd8a	79 	y
	cp 00dh		;dd8b	fe 0d 	. .
	jr z,$+40		;dd8d	28 26 	( &
	ld a,(0ffd9h)		;dd8f	3a d9 ff 	: . .
	cp 001h		;dd92	fe 01 	. .
	jr z,$+6		;dd94	28 04 	( .
	call 0cdb7h		;dd96	cd b7 cd 	. . .
	ret			;dd99	c9 	.
	ld b,018h		;dd9a	06 18 	. .
	ld c,000h		;dd9c	0e 00 	. .
	call 0c6f1h		;dd9e	cd f1 c6 	. . .
	ld (0ffdah),hl		;dda1	22 da ff 	" . .
	ld a,002h		;dda4	3e 02 	> .
	ld (0ffd9h),a		;dda6	32 d9 ff 	2 . .
	ld b,046h		;dda9	06 46 	. F
	ld c,020h		;ddab	0e 20 	.
	call 0c715h		;ddad	cd 15 c7 	. . .
	ld (hl),c			;ddb0	71 	q
	inc hl			;ddb1	23 	#
	djnz $-5		;ddb2	10 f9 	. .
	ret			;ddb4	c9 	.
	xor a			;ddb5	af 	.
	ret			;ddb6	c9 	.
	ld b,a			;ddb7	47 	G
	inc a			;ddb8	3c 	<
	ld (0ffd9h),a		;ddb9	32 d9 ff 	2 . .
	ld hl,(0ffdah)		;ddbc	2a da ff 	* . .
	call 0c715h		;ddbf	cd 15 c7 	. . .
	ld (hl),c			;ddc2	71 	q
	ld a,(0bfebh)		;ddc3	3a eb bf 	: . .
	call 0c795h		;ddc6	cd 95 c7 	. . .
	ld (hl),a			;ddc9	77 	w
	call 0c79eh		;ddca	cd 9e c7 	. . .
	inc hl			;ddcd	23 	#
	ld (0ffdah),hl		;ddce	22 da ff 	" . .
	ld a,b			;ddd1	78 	x
	cp 047h		;ddd2	fe 47 	. G
	ret nz			;ddd4	c0 	.
	xor a			;ddd5	af 	.
	ret			;ddd6	c9 	.
	ld a,(0ffd9h)		;ddd7	3a d9 ff 	: . .
	or a			;ddda	b7 	.
	ret nz			;dddb	c0 	.
	inc a			;dddc	3c 	<
	ld (0ffd9h),a		;dddd	32 d9 ff 	2 . .
	pop hl			;dde0	e1 	.
	ret			;dde1	c9 	.
	call 0c69ah		;dde2	cd 9a c6 	. . .
	call 0c6f1h		;dde5	cd f1 c6 	. . .
	call 0c715h		;dde8	cd 15 c7 	. . .
	ld (hl),d			;ddeb	72 	r
	call 0c795h		;ddec	cd 95 c7 	. . .
	ld (hl),e			;ddef	73 	s
	call 0c79eh		;ddf0	cd 9e c7 	. . .
	ret			;ddf3	c9 	.
	call 0c69ah		;ddf4	cd 9a c6 	. . .
	call 0c6f1h		;ddf7	cd f1 c6 	. . .
	call 0c715h		;ddfa	cd 15 c7 	. . .
	ld d,(hl)			;ddfd	56 	V
	call 0c795h		;ddfe	cd 95 c7 	. . .
	ld e,(hl)			;de01	5e 	^
	call 0c79eh		;de02	cd 9e c7 	. . .
	ret			;de05	c9 	.
	nop			;de06	00 	.
	nop			;de07	00 	.
	nop			;de08	00 	.
	nop			;de09	00 	.
	nop			;de0a	00 	.
	nop			;de0b	00 	.
	nop			;de0c	00 	.
	nop			;de0d	00 	.
	nop			;de0e	00 	.
	nop			;de0f	00 	.
	nop			;de10	00 	.
	nop			;de11	00 	.
	nop			;de12	00 	.
	nop			;de13	00 	.
	nop			;de14	00 	.
	nop			;de15	00 	.
	nop			;de16	00 	.
	nop			;de17	00 	.
	nop			;de18	00 	.
	nop			;de19	00 	.
	nop			;de1a	00 	.
	nop			;de1b	00 	.
	nop			;de1c	00 	.
	nop			;de1d	00 	.
	nop			;de1e	00 	.
	nop			;de1f	00 	.
	nop			;de20	00 	.
	nop			;de21	00 	.
	nop			;de22	00 	.
	nop			;de23	00 	.
	nop			;de24	00 	.
	nop			;de25	00 	.
	nop			;de26	00 	.
	nop			;de27	00 	.
	nop			;de28	00 	.
	nop			;de29	00 	.
	nop			;de2a	00 	.
	nop			;de2b	00 	.
	nop			;de2c	00 	.
	nop			;de2d	00 	.
	nop			;de2e	00 	.
	nop			;de2f	00 	.
	nop			;de30	00 	.
	nop			;de31	00 	.
	nop			;de32	00 	.
	nop			;de33	00 	.
	nop			;de34	00 	.
	nop			;de35	00 	.
	nop			;de36	00 	.
	nop			;de37	00 	.
	nop			;de38	00 	.
	nop			;de39	00 	.
	nop			;de3a	00 	.
	nop			;de3b	00 	.
	nop			;de3c	00 	.
	nop			;de3d	00 	.
	nop			;de3e	00 	.
	nop			;de3f	00 	.
	nop			;de40	00 	.
	nop			;de41	00 	.
	nop			;de42	00 	.
	nop			;de43	00 	.
	nop			;de44	00 	.
	nop			;de45	00 	.
	nop			;de46	00 	.
	nop			;de47	00 	.
	nop			;de48	00 	.
	nop			;de49	00 	.
	nop			;de4a	00 	.
	nop			;de4b	00 	.
	nop			;de4c	00 	.
	nop			;de4d	00 	.
	nop			;de4e	00 	.
	nop			;de4f	00 	.
	nop			;de50	00 	.
	nop			;de51	00 	.
	nop			;de52	00 	.
	nop			;de53	00 	.
	nop			;de54	00 	.
	nop			;de55	00 	.
	nop			;de56	00 	.
	nop			;de57	00 	.
	nop			;de58	00 	.
	nop			;de59	00 	.
	nop			;de5a	00 	.
	nop			;de5b	00 	.
	nop			;de5c	00 	.
	nop			;de5d	00 	.
	nop			;de5e	00 	.
	nop			;de5f	00 	.
	nop			;de60	00 	.
	nop			;de61	00 	.
	nop			;de62	00 	.
	nop			;de63	00 	.
	nop			;de64	00 	.
	nop			;de65	00 	.
	nop			;de66	00 	.
	nop			;de67	00 	.
	nop			;de68	00 	.
	nop			;de69	00 	.
	nop			;de6a	00 	.
	nop			;de6b	00 	.
	nop			;de6c	00 	.
	nop			;de6d	00 	.
	nop			;de6e	00 	.
	nop			;de6f	00 	.
	nop			;de70	00 	.
	nop			;de71	00 	.
	nop			;de72	00 	.
	nop			;de73	00 	.
	nop			;de74	00 	.
	nop			;de75	00 	.
	nop			;de76	00 	.
	nop			;de77	00 	.
	nop			;de78	00 	.
	nop			;de79	00 	.
	nop			;de7a	00 	.
	nop			;de7b	00 	.
	nop			;de7c	00 	.
	nop			;de7d	00 	.
	nop			;de7e	00 	.
	nop			;de7f	00 	.
	nop			;de80	00 	.
	nop			;de81	00 	.
	nop			;de82	00 	.
	nop			;de83	00 	.
	nop			;de84	00 	.
	nop			;de85	00 	.
	nop			;de86	00 	.
	nop			;de87	00 	.
	nop			;de88	00 	.
	nop			;de89	00 	.
	nop			;de8a	00 	.
	nop			;de8b	00 	.
	nop			;de8c	00 	.
	nop			;de8d	00 	.
	nop			;de8e	00 	.
	nop			;de8f	00 	.
	nop			;de90	00 	.
	nop			;de91	00 	.
	nop			;de92	00 	.
	nop			;de93	00 	.
	nop			;de94	00 	.
	nop			;de95	00 	.
	nop			;de96	00 	.
	nop			;de97	00 	.
	nop			;de98	00 	.
	nop			;de99	00 	.
	nop			;de9a	00 	.
	nop			;de9b	00 	.
	nop			;de9c	00 	.
	nop			;de9d	00 	.
	nop			;de9e	00 	.
	nop			;de9f	00 	.
	nop			;dea0	00 	.
	nop			;dea1	00 	.
	nop			;dea2	00 	.
	nop			;dea3	00 	.
	nop			;dea4	00 	.
	nop			;dea5	00 	.
	nop			;dea6	00 	.
	nop			;dea7	00 	.
	nop			;dea8	00 	.
	nop			;dea9	00 	.
	nop			;deaa	00 	.
	nop			;deab	00 	.
	nop			;deac	00 	.
	nop			;dead	00 	.
	nop			;deae	00 	.
	nop			;deaf	00 	.
	nop			;deb0	00 	.
	nop			;deb1	00 	.
	nop			;deb2	00 	.
	nop			;deb3	00 	.
	nop			;deb4	00 	.
	nop			;deb5	00 	.
	nop			;deb6	00 	.
	nop			;deb7	00 	.
	nop			;deb8	00 	.
	nop			;deb9	00 	.
	nop			;deba	00 	.
	nop			;debb	00 	.
	nop			;debc	00 	.
	nop			;debd	00 	.
	nop			;debe	00 	.
	nop			;debf	00 	.
	nop			;dec0	00 	.
	nop			;dec1	00 	.
	nop			;dec2	00 	.
	nop			;dec3	00 	.
	nop			;dec4	00 	.
	nop			;dec5	00 	.
	nop			;dec6	00 	.
	nop			;dec7	00 	.
	nop			;dec8	00 	.
	nop			;dec9	00 	.
	nop			;deca	00 	.
	nop			;decb	00 	.
	nop			;decc	00 	.
	nop			;decd	00 	.
	nop			;dece	00 	.
	nop			;decf	00 	.
	nop			;ded0	00 	.
	nop			;ded1	00 	.
	nop			;ded2	00 	.
	nop			;ded3	00 	.
	nop			;ded4	00 	.
	nop			;ded5	00 	.
	nop			;ded6	00 	.
	nop			;ded7	00 	.
	nop			;ded8	00 	.
	nop			;ded9	00 	.
	nop			;deda	00 	.
	nop			;dedb	00 	.
	nop			;dedc	00 	.
	nop			;dedd	00 	.
	nop			;dede	00 	.
	nop			;dedf	00 	.
	nop			;dee0	00 	.
	nop			;dee1	00 	.
	nop			;dee2	00 	.
	nop			;dee3	00 	.
	nop			;dee4	00 	.
	nop			;dee5	00 	.
	nop			;dee6	00 	.
	nop			;dee7	00 	.
	nop			;dee8	00 	.
	nop			;dee9	00 	.
	nop			;deea	00 	.
	nop			;deeb	00 	.
	nop			;deec	00 	.
	nop			;deed	00 	.
	nop			;deee	00 	.
	nop			;deef	00 	.
	nop			;def0	00 	.
	nop			;def1	00 	.
	nop			;def2	00 	.
	nop			;def3	00 	.
	nop			;def4	00 	.
	nop			;def5	00 	.
	nop			;def6	00 	.
	nop			;def7	00 	.
	nop			;def8	00 	.
	nop			;def9	00 	.
	nop			;defa	00 	.
	nop			;defb	00 	.
	nop			;defc	00 	.
	nop			;defd	00 	.
	nop			;defe	00 	.
	nop			;deff	00 	.
	nop			;df00	00 	.
	nop			;df01	00 	.
	nop			;df02	00 	.
	nop			;df03	00 	.
	nop			;df04	00 	.
	nop			;df05	00 	.
	nop			;df06	00 	.
	nop			;df07	00 	.
	nop			;df08	00 	.
	nop			;df09	00 	.
	nop			;df0a	00 	.
	nop			;df0b	00 	.
	nop			;df0c	00 	.
	nop			;df0d	00 	.
	nop			;df0e	00 	.
	nop			;df0f	00 	.
	nop			;df10	00 	.
	nop			;df11	00 	.
	nop			;df12	00 	.
	nop			;df13	00 	.
	nop			;df14	00 	.
	nop			;df15	00 	.
	nop			;df16	00 	.
	nop			;df17	00 	.
	nop			;df18	00 	.
	nop			;df19	00 	.
	nop			;df1a	00 	.
	nop			;df1b	00 	.
	nop			;df1c	00 	.
	nop			;df1d	00 	.
	nop			;df1e	00 	.
	nop			;df1f	00 	.
	nop			;df20	00 	.
	nop			;df21	00 	.
	nop			;df22	00 	.
	nop			;df23	00 	.
	nop			;df24	00 	.
	nop			;df25	00 	.
	nop			;df26	00 	.
	nop			;df27	00 	.
	nop			;df28	00 	.
	nop			;df29	00 	.
	nop			;df2a	00 	.
	nop			;df2b	00 	.
	nop			;df2c	00 	.
	nop			;df2d	00 	.
	nop			;df2e	00 	.
	nop			;df2f	00 	.
	nop			;df30	00 	.
	nop			;df31	00 	.
	nop			;df32	00 	.
	nop			;df33	00 	.
	nop			;df34	00 	.
	nop			;df35	00 	.
	nop			;df36	00 	.
	nop			;df37	00 	.
	nop			;df38	00 	.
	nop			;df39	00 	.
	nop			;df3a	00 	.
	nop			;df3b	00 	.
	nop			;df3c	00 	.
	nop			;df3d	00 	.
	nop			;df3e	00 	.
	nop			;df3f	00 	.
	nop			;df40	00 	.
	nop			;df41	00 	.
	nop			;df42	00 	.
	nop			;df43	00 	.
	nop			;df44	00 	.
	nop			;df45	00 	.
	nop			;df46	00 	.
	nop			;df47	00 	.
	nop			;df48	00 	.
	nop			;df49	00 	.
	nop			;df4a	00 	.
	nop			;df4b	00 	.
	nop			;df4c	00 	.
	nop			;df4d	00 	.
	nop			;df4e	00 	.
	nop			;df4f	00 	.
	nop			;df50	00 	.
	nop			;df51	00 	.
	nop			;df52	00 	.
	nop			;df53	00 	.
	nop			;df54	00 	.
	nop			;df55	00 	.
	nop			;df56	00 	.
	nop			;df57	00 	.
	nop			;df58	00 	.
	nop			;df59	00 	.
	nop			;df5a	00 	.
	nop			;df5b	00 	.
	nop			;df5c	00 	.
	nop			;df5d	00 	.
	nop			;df5e	00 	.
	nop			;df5f	00 	.
	nop			;df60	00 	.
	nop			;df61	00 	.
	nop			;df62	00 	.
	nop			;df63	00 	.
	nop			;df64	00 	.
	nop			;df65	00 	.
	nop			;df66	00 	.
	nop			;df67	00 	.
	nop			;df68	00 	.
	nop			;df69	00 	.
	nop			;df6a	00 	.
	nop			;df6b	00 	.
	nop			;df6c	00 	.
	nop			;df6d	00 	.
	nop			;df6e	00 	.
	nop			;df6f	00 	.
	nop			;df70	00 	.
	nop			;df71	00 	.
	nop			;df72	00 	.
	nop			;df73	00 	.
	nop			;df74	00 	.
	nop			;df75	00 	.
	nop			;df76	00 	.
	nop			;df77	00 	.
	nop			;df78	00 	.
	nop			;df79	00 	.
	nop			;df7a	00 	.
	nop			;df7b	00 	.
	nop			;df7c	00 	.
	nop			;df7d	00 	.
	nop			;df7e	00 	.
	nop			;df7f	00 	.
	nop			;df80	00 	.
	nop			;df81	00 	.
	nop			;df82	00 	.
	nop			;df83	00 	.
	nop			;df84	00 	.
	nop			;df85	00 	.
	nop			;df86	00 	.
	nop			;df87	00 	.
	nop			;df88	00 	.
	nop			;df89	00 	.
	nop			;df8a	00 	.
	nop			;df8b	00 	.
	nop			;df8c	00 	.
	nop			;df8d	00 	.
	nop			;df8e	00 	.
	nop			;df8f	00 	.
	nop			;df90	00 	.
	nop			;df91	00 	.
	nop			;df92	00 	.
	nop			;df93	00 	.
	nop			;df94	00 	.
	nop			;df95	00 	.
	nop			;df96	00 	.
	nop			;df97	00 	.
	nop			;df98	00 	.
	nop			;df99	00 	.
	nop			;df9a	00 	.
	nop			;df9b	00 	.
	nop			;df9c	00 	.
	nop			;df9d	00 	.
	nop			;df9e	00 	.
	nop			;df9f	00 	.
	nop			;dfa0	00 	.
	nop			;dfa1	00 	.
	nop			;dfa2	00 	.
	nop			;dfa3	00 	.
	nop			;dfa4	00 	.
	nop			;dfa5	00 	.
	nop			;dfa6	00 	.
	nop			;dfa7	00 	.
	nop			;dfa8	00 	.
	nop			;dfa9	00 	.
	nop			;dfaa	00 	.
	nop			;dfab	00 	.
	nop			;dfac	00 	.
	nop			;dfad	00 	.
	nop			;dfae	00 	.
	nop			;dfaf	00 	.
	nop			;dfb0	00 	.
	nop			;dfb1	00 	.
	nop			;dfb2	00 	.
	nop			;dfb3	00 	.
	nop			;dfb4	00 	.
	nop			;dfb5	00 	.
	nop			;dfb6	00 	.
	nop			;dfb7	00 	.
	nop			;dfb8	00 	.
	nop			;dfb9	00 	.
	nop			;dfba	00 	.
	nop			;dfbb	00 	.
	nop			;dfbc	00 	.
	nop			;dfbd	00 	.
	nop			;dfbe	00 	.
	nop			;dfbf	00 	.
	nop			;dfc0	00 	.
	nop			;dfc1	00 	.
	nop			;dfc2	00 	.
	nop			;dfc3	00 	.
	nop			;dfc4	00 	.
	nop			;dfc5	00 	.
	nop			;dfc6	00 	.
	nop			;dfc7	00 	.
	nop			;dfc8	00 	.
	nop			;dfc9	00 	.
	nop			;dfca	00 	.
	nop			;dfcb	00 	.
	nop			;dfcc	00 	.
	nop			;dfcd	00 	.
	nop			;dfce	00 	.
	nop			;dfcf	00 	.
	nop			;dfd0	00 	.
	nop			;dfd1	00 	.
	nop			;dfd2	00 	.
	nop			;dfd3	00 	.
	nop			;dfd4	00 	.
	nop			;dfd5	00 	.
	nop			;dfd6	00 	.
	nop			;dfd7	00 	.
	nop			;dfd8	00 	.
	nop			;dfd9	00 	.
	nop			;dfda	00 	.
	nop			;dfdb	00 	.
	nop			;dfdc	00 	.
	nop			;dfdd	00 	.
	nop			;dfde	00 	.
	nop			;dfdf	00 	.
	nop			;dfe0	00 	.
	nop			;dfe1	00 	.
	nop			;dfe2	00 	.
	nop			;dfe3	00 	.
	nop			;dfe4	00 	.
	nop			;dfe5	00 	.
	nop			;dfe6	00 	.
	nop			;dfe7	00 	.
	nop			;dfe8	00 	.
	nop			;dfe9	00 	.
	nop			;dfea	00 	.
	nop			;dfeb	00 	.
	nop			;dfec	00 	.
	nop			;dfed	00 	.
	nop			;dfee	00 	.
	nop			;dfef	00 	.
	nop			;dff0	00 	.
	nop			;dff1	00 	.
	nop			;dff2	00 	.
	nop			;dff3	00 	.
	nop			;dff4	00 	.
	nop			;dff5	00 	.
	nop			;dff6	00 	.
	nop			;dff7	00 	.
	nop			;dff8	00 	.
	nop			;dff9	00 	.
	nop			;dffa	00 	.
	nop			;dffb	00 	.
	ld sp,0302eh		;dffc	31 2e 30 	1 . 0
	rst 38h			;dfff	ff 	.
