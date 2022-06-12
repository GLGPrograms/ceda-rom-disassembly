; z80dasm 1.1.5
; command line: z80dasm -g 0 -t V1.01_ROM.bin

	org	00000h

	jp 0c030h		;0000	c3 30 c0 	. 0 . 
	jp 0c027h		;0003	c3 27 c0 	. ' . 
	jp 0c027h		;0006	c3 27 c0 	. ' . 
	jp 0c45eh		;0009	c3 5e c4 	. ^ . 
	jp 0c027h		;000c	c3 27 c0 	. ' . 
	jp 0c027h		;000f	c3 27 c0 	. ' . 
	jp 0c027h		;0012	c3 27 c0 	. ' . 
	jp 0c027h		;0015	c3 27 c0 	. ' . 
	jp 0c19dh		;0018	c3 9d c1 	. . . 
	jp 0c18fh		;001b	c3 8f c1 	. . . 
	jp 0c174h		;001e	c3 74 c1 	. t . 
	jp 0cde2h		;0021	c3 e2 cd 	. . . 
	jp 0cdf4h		;0024	c3 f4 cd 	. . . 
	di			;0027	f3 	. 
	ld a,010h		;0028	3e 10 	> . 
	out (0b1h),a		;002a	d3 b1 	. . 
	out (0b3h),a		;002c	d3 b3 	. . 
	jr $+18		;002e	18 10 	. . 
	ld a,089h		;0030	3e 89 	> . 
	out (083h),a		;0032	d3 83 	. . 
	di			;0034	f3 	. 
	ld a,010h		;0035	3e 10 	> . 
	out (081h),a		;0037	d3 81 	. . 
	ld h,07dh		;0039	26 7d 	& } 
	dec hl			;003b	2b 	+ 
	ld a,h			;003c	7c 	| 
	or l			;003d	b5 	. 
	jr nz,$-3		;003e	20 fb 	  . 
	ld sp,00080h		;0040	31 80 00 	1 . . 
	call 0c0c2h		;0043	cd c2 c0 	. . . 
	call 0c6afh		;0046	cd af c6 	. . . 
	call 0c14eh		;0049	cd 4e c1 	. N . 
	ld a,012h		;004c	3e 12 	> . 
	out (0b2h),a		;004e	d3 b2 	. . 
	in a,(0b3h)		;0050	db b3 	. . 
	bit 0,a		;0052	cb 47 	. G 
	jr z,$-4		;0054	28 fa 	( . 
	in a,(0b2h)		;0056	db b2 	. . 
	out (0dah),a		;0058	d3 da 	. . 
	ld c,056h		;005a	0e 56 	. V 
	call 0c45eh		;005c	cd 5e c4 	. ^ . 
	ld hl,0cffch		;005f	21 fc cf 	! . . 
	ld b,004h		;0062	06 04 	. . 
	ld c,(hl)			;0064	4e 	N 
	inc hl			;0065	23 	# 
	call 0c45eh		;0066	cd 5e c4 	. ^ . 
	djnz $-5		;0069	10 f9 	. . 
	call 0c0a7h		;006b	cd a7 c0 	. . . 
	ld a,b			;006e	78 	x 
	cp 04dh		;006f	fe 4d 	. M 
	jr z,$+23		;0071	28 15 	( . 
	cp 05ch		;0073	fe 5c 	. \ 
	jr nz,$-10		;0075	20 f4 	  . 
	ld a,(08000h)		;0077	3a 00 80 	: . . 
	cpl			;007a	2f 	/ 
	ld (08000h),a		;007b	32 00 80 	2 . . 
	ld a,(08000h)		;007e	3a 00 80 	: . . 
	cp 0c3h		;0081	fe c3 	. . 
	jr nz,$-92		;0083	20 a2 	  . 
	jp 08000h		;0085	c3 00 80 	. . . 
	ld de,00000h		;0088	11 00 00 	. . . 
	ld bc,04000h		;008b	01 00 40 	. . @ 
	ld hl,00080h		;008e	21 80 00 	! . . 
	ld a,001h		;0091	3e 01 	> . 
	call 0c19dh		;0093	cd 9d c1 	. . . 
	cp 0ffh		;0096	fe ff 	. . 
	jr nz,$+6		;0098	20 04 	  . 
	out (0dah),a		;009a	d3 da 	. . 
	jr $-20		;009c	18 ea 	. . 
	ld a,006h		;009e	3e 06 	> . 
	out (0b2h),a		;00a0	d3 b2 	. . 
	out (0dah),a		;00a2	d3 da 	. . 
	jp 00080h		;00a4	c3 80 00 	. . . 
	in a,(0b3h)		;00a7	db b3 	. . 
	bit 0,a		;00a9	cb 47 	. G 
	jr z,$-4		;00ab	28 fa 	( . 
	in a,(0b2h)		;00ad	db b2 	. . 
	ld b,a			;00af	47 	G 
	bit 7,a		;00b0	cb 7f 	.  
	jr nz,$-11		;00b2	20 f3 	  . 
	in a,(0b3h)		;00b4	db b3 	. . 
	bit 0,a		;00b6	cb 47 	. G 
	jr z,$-4		;00b8	28 fa 	( . 
	in a,(0b2h)		;00ba	db b2 	. . 
	ld c,a			;00bc	4f 	O 
	bit 7,a		;00bd	cb 7f 	.  
	jr z,$-11		;00bf	28 f3 	( . 
	ret			;00c1	c9 	. 
	im 2		;00c2	ed 5e 	. ^ 
	call 0c0d1h		;00c4	cd d1 c0 	. . . 
	call 0c43fh		;00c7	cd 3f c4 	. ? . 
	call 0c108h		;00ca	cd 08 c1 	. . . 
	call 0c88dh		;00cd	cd 8d c8 	. . . 
	ret			;00d0	c9 	. 
	ld hl,0c0f1h		;00d1	21 f1 c0 	! . . 
	ld a,(hl)			;00d4	7e 	~ 
	inc hl			;00d5	23 	# 
	cp 0ffh		;00d6	fe ff 	. . 
	jr z,$+9		;00d8	28 07 	( . 
	ld c,a			;00da	4f 	O 
	ld a,(hl)			;00db	7e 	~ 
	inc hl			;00dc	23 	# 
	out (c),a		;00dd	ed 79 	. y 
	jr $-11		;00df	18 f3 	. . 
	in a,(0d6h)		;00e1	db d6 	. . 
	and 007h		;00e3	e6 07 	. . 
	ld d,000h		;00e5	16 00 	. . 
	ld e,a			;00e7	5f 	_ 
	add hl,de			;00e8	19 	. 
	ld a,(hl)			;00e9	7e 	~ 
	out (0e1h),a		;00ea	d3 e1 	. . 
	ld a,041h		;00ec	3e 41 	> A 
	out (0e1h),a		;00ee	d3 e1 	. . 
	ret			;00f0	c9 	. 
	jp po,0e205h		;00f1	e2 05 e2 	. . . 
	djnz $-28		;00f4	10 e2 	. . 
	ld b,c			;00f6	41 	A 
	ex (sp),hl			;00f7	e3 	. 
	dec b			;00f8	05 	. 
	ex (sp),hl			;00f9	e3 	. 
	ld bc,041e3h		;00fa	01 e3 41 	. . A 
	pop hl			;00fd	e1 	. 
	dec b			;00fe	05 	. 
	rst 38h			;00ff	ff 	. 
	xor (hl)			;0100	ae 	. 
	ld b,b			;0101	40 	@ 
	jr nz,$+18		;0102	20 10 	  . 
	ex af,af'			;0104	08 	. 
	inc b			;0105	04 	. 
	ld (bc),a			;0106	02 	. 
	ld bc,03421h		;0107	01 21 34 	. ! 4 
	pop bc			;010a	c1 	. 
	ld a,(hl)			;010b	7e 	~ 
	inc hl			;010c	23 	# 
	cp 0ffh		;010d	fe ff 	. . 
	jr z,$+10		;010f	28 08 	( . 
	out (0b1h),a		;0111	d3 b1 	. . 
	ld a,(hl)			;0113	7e 	~ 
	out (0b1h),a		;0114	d3 b1 	. . 
	inc hl			;0116	23 	# 
	jr $-12		;0117	18 f2 	. . 
	ld a,(hl)			;0119	7e 	~ 
	cp 0ffh		;011a	fe ff 	. . 
	jr z,$+11		;011c	28 09 	( . 
	out (0b3h),a		;011e	d3 b3 	. . 
	inc hl			;0120	23 	# 
	ld a,(hl)			;0121	7e 	~ 
	out (0b3h),a		;0122	d3 b3 	. . 
	inc hl			;0124	23 	# 
	jr $-12		;0125	18 f2 	. . 
	in a,(0b0h)		;0127	db b0 	. . 
	in a,(0b2h)		;0129	db b2 	. . 
	in a,(0b0h)		;012b	db b0 	. . 
	in a,(0b2h)		;012d	db b2 	. . 
	in a,(0b0h)		;012f	db b0 	. . 
	in a,(0b2h)		;0131	db b2 	. . 
	ret			;0133	c9 	. 
	nop			;0134	00 	. 
	djnz $+2		;0135	10 00 	. . 
	djnz $+6		;0137	10 04 	. . 
	ld b,h			;0139	44 	D 
	ld bc,00300h		;013a	01 00 03 	. . . 
	pop bc			;013d	c1 	. 
	dec b			;013e	05 	. 
	jp pe,000ffh		;013f	ea ff 00 	. . . 
	djnz $+2		;0142	10 00 	. . 
	djnz $+6		;0144	10 04 	. . 
	ld b,h			;0146	44 	D 
	ld bc,00300h		;0147	01 00 03 	. . . 
	pop bc			;014a	c1 	. 
	dec b			;014b	05 	. 
	jp pe,021ffh		;014c	ea ff 21 	. . ! 
	ld h,l			;014f	65 	e 
	pop bc			;0150	c1 	. 
	ld de,00010h		;0151	11 10 00 	. . . 
	ld bc,0000fh		;0154	01 0f 00 	. . . 
	ldir		;0157	ed b0 	. . 
	ld hl,00000h		;0159	21 00 00 	! . . 
	ld de,00000h		;015c	11 00 00 	. . . 
	ld bc,00000h		;015f	01 00 00 	. . . 
	jp 00010h		;0162	c3 10 00 	. . . 
	in a,(081h)		;0165	db 81 	. . 
	set 0,a		;0167	cb c7 	. . 
	out (081h),a		;0169	d3 81 	. . 
	ldir		;016b	ed b0 	. . 
	res 0,a		;016d	cb 87 	. . 
	out (081h),a		;016f	d3 81 	. . 
	out (0deh),a		;0171	d3 de 	. . 
	ret			;0173	c9 	. 
	push af			;0174	f5 	. 
	rrca			;0175	0f 	. 
	rrca			;0176	0f 	. 
	rrca			;0177	0f 	. 
	rrca			;0178	0f 	. 
	and 00fh		;0179	e6 0f 	. . 
	call 0c181h		;017b	cd 81 c1 	. . . 
	pop af			;017e	f1 	. 
	and 00fh		;017f	e6 0f 	. . 
	call 0c187h		;0181	cd 87 c1 	. . . 
	jp 0c45eh		;0184	c3 5e c4 	. ^ . 
	add a,090h		;0187	c6 90 	. . 
	daa			;0189	27 	' 
	adc a,040h		;018a	ce 40 	. @ 
	daa			;018c	27 	' 
	ld c,a			;018d	4f 	O 
	ret			;018e	c9 	. 
	ex (sp),hl			;018f	e3 	. 
	ld a,(hl)			;0190	7e 	~ 
	inc hl			;0191	23 	# 
	or a			;0192	b7 	. 
	jr z,$+8		;0193	28 06 	( . 
	ld c,a			;0195	4f 	O 
	call 0c45eh		;0196	cd 5e c4 	. ^ . 
	jr $-9		;0199	18 f5 	. . 
	ex (sp),hl			;019b	e3 	. 
	ret			;019c	c9 	. 
	push bc			;019d	c5 	. 
	push de			;019e	d5 	. 
	push hl			;019f	e5 	. 
	ld (0ffb8h),a		;01a0	32 b8 ff 	2 . . 
	ld a,00ah		;01a3	3e 0a 	> . 
	ld (0ffbfh),a		;01a5	32 bf ff 	2 . . 
	ld (0ffb9h),bc		;01a8	ed 43 b9 ff 	. C . . 
	ld (0ffbbh),de		;01ac	ed 53 bb ff 	. S . . 
	ld (0ffbdh),hl		;01b0	22 bd ff 	" . . 
	call 0c423h		;01b3	cd 23 c4 	. # . 
	ld a,(0ffbah)		;01b6	3a ba ff 	: . . 
	and 0f0h		;01b9	e6 f0 	. . 
	jp z,0c1e6h		;01bb	ca e6 c1 	. . . 
	cp 040h		;01be	fe 40 	. @ 
	jp z,0c1dch		;01c0	ca dc c1 	. . . 
	cp 080h		;01c3	fe 80 	. . 
	jp z,0c1d7h		;01c5	ca d7 c1 	. . . 
	cp 020h		;01c8	fe 20 	.   
	jp z,0c1e1h		;01ca	ca e1 c1 	. . . 
	cp 0f0h		;01cd	fe f0 	. . 
	jp z,0c1ebh		;01cf	ca eb c1 	. . . 
	ld a,0ffh		;01d2	3e ff 	> . 
	jp 0c1f0h		;01d4	c3 f0 c1 	. . . 
	call 0c1f4h		;01d7	cd f4 c1 	. . . 
	jr $+22		;01da	18 14 	. . 
	call 0c24ah		;01dc	cd 4a c2 	. J . 
	jr $+17		;01df	18 0f 	. . 
	call 0c3a9h		;01e1	cd a9 c3 	. . . 
	jr $+12		;01e4	18 0a 	. . 
	call 0c391h		;01e6	cd 91 c3 	. . . 
	jr $+7		;01e9	18 05 	. . 
	call 0c2e3h		;01eb	cd e3 c2 	. . . 
	jr $+2		;01ee	18 00 	. . 
	pop hl			;01f0	e1 	. 
	pop de			;01f1	d1 	. 
	pop bc			;01f2	c1 	. 
	ret			;01f3	c9 	. 
	call 0c3a9h		;01f4	cd a9 c3 	. . . 
	call 0c2b7h		;01f7	cd b7 c2 	. . . 
	push de			;01fa	d5 	. 
	call 0c41ch		;01fb	cd 1c c4 	. . . 
	ld c,0c5h		;01fe	0e c5 	. . 
	ld a,(0ffb8h)		;0200	3a b8 ff 	: . . 
	or a			;0203	b7 	. 
	jr nz,$+4		;0204	20 02 	  . 
	res 6,c		;0206	cb b1 	. . 
	call 0c415h		;0208	cd 15 c4 	. . . 
	di			;020b	f3 	. 
	call 0c34eh		;020c	cd 4e c3 	. N . 
	pop de			;020f	d1 	. 
	ld c,0c1h		;0210	0e c1 	. . 
	ld b,e			;0212	43 	C 
	ld hl,(0ffbdh)		;0213	2a bd ff 	* . . 
	in a,(082h)		;0216	db 82 	. . 
	bit 2,a		;0218	cb 57 	. W 
	jr z,$-4		;021a	28 fa 	( . 
	in a,(0c0h)		;021c	db c0 	. . 
	bit 5,a		;021e	cb 6f 	. o 
	jr z,$+9		;0220	28 07 	( . 
	outi		;0222	ed a3 	. . 
	jr nz,$-14		;0224	20 f0 	  . 
	dec d			;0226	15 	. 
	jr nz,$-17		;0227	20 ed 	  . 
	out (0dch),a		;0229	d3 dc 	. . 
	ei			;022b	fb 	. 
	call 0c3f4h		;022c	cd f4 c3 	. . . 
	ld a,(0ffc0h)		;022f	3a c0 ff 	: . . 
	and 0c0h		;0232	e6 c0 	. . 
	cp 040h		;0234	fe 40 	. @ 
	jr nz,$+18		;0236	20 10 	  . 
	call 0c2a0h		;0238	cd a0 c2 	. . . 
	ld a,(0ffbfh)		;023b	3a bf ff 	: . . 
	dec a			;023e	3d 	= 
	ld (0ffbfh),a		;023f	32 bf ff 	2 . . 
	jp nz,0c1f7h		;0242	c2 f7 c1 	. . . 
	ld a,0ffh		;0245	3e ff 	> . 
	ret			;0247	c9 	. 
	xor a			;0248	af 	. 
	ret			;0249	c9 	. 
	call 0c3a9h		;024a	cd a9 c3 	. . . 
	call 0c2b7h		;024d	cd b7 c2 	. . . 
	push de			;0250	d5 	. 
	call 0c41ch		;0251	cd 1c c4 	. . . 
	ld c,0c6h		;0254	0e c6 	. . 
	ld a,(0ffb8h)		;0256	3a b8 ff 	: . . 
	or a			;0259	b7 	. 
	jr nz,$+4		;025a	20 02 	  . 
	res 6,c		;025c	cb b1 	. . 
	call 0c415h		;025e	cd 15 c4 	. . . 
	di			;0261	f3 	. 
	call 0c34eh		;0262	cd 4e c3 	. N . 
	pop de			;0265	d1 	. 
	ld c,0c1h		;0266	0e c1 	. . 
	ld b,e			;0268	43 	C 
	ld hl,(0ffbdh)		;0269	2a bd ff 	* . . 
	in a,(082h)		;026c	db 82 	. . 
	bit 2,a		;026e	cb 57 	. W 
	jr z,$-4		;0270	28 fa 	( . 
	in a,(0c0h)		;0272	db c0 	. . 
	bit 5,a		;0274	cb 6f 	. o 
	jr z,$+9		;0276	28 07 	( . 
	ini		;0278	ed a2 	. . 
	jr nz,$-14		;027a	20 f0 	  . 
	dec d			;027c	15 	. 
	jr nz,$-17		;027d	20 ed 	  . 
	out (0dch),a		;027f	d3 dc 	. . 
	ei			;0281	fb 	. 
	call 0c3f4h		;0282	cd f4 c3 	. . . 
	ld a,(0ffc0h)		;0285	3a c0 ff 	: . . 
	and 0c0h		;0288	e6 c0 	. . 
	cp 040h		;028a	fe 40 	. @ 
	jr nz,$+18		;028c	20 10 	  . 
	call 0c2a0h		;028e	cd a0 c2 	. . . 
	ld a,(0ffbfh)		;0291	3a bf ff 	: . . 
	dec a			;0294	3d 	= 
	ld (0ffbfh),a		;0295	32 bf ff 	2 . . 
	jp nz,0c24dh		;0298	c2 4d c2 	. M . 
	ld a,0ffh		;029b	3e ff 	> . 
	ret			;029d	c9 	. 
	xor a			;029e	af 	. 
	ret			;029f	c9 	. 
	ld a,(0ffc2h)		;02a0	3a c2 ff 	: . . 
	bit 4,a		;02a3	cb 67 	. g 
	jr z,$+6		;02a5	28 04 	( . 
	call 0c391h		;02a7	cd 91 c3 	. . . 
	ret			;02aa	c9 	. 
	ld a,(0ffc1h)		;02ab	3a c1 ff 	: . . 
	bit 0,a		;02ae	cb 47 	. G 
	jr z,$+6		;02b0	28 04 	( . 
	call 0c391h		;02b2	cd 91 c3 	. . . 
	ret			;02b5	c9 	. 
	ret			;02b6	c9 	. 
	ld e,000h		;02b7	1e 00 	. . 
	ld a,(0ffb8h)		;02b9	3a b8 ff 	: . . 
	cp 003h		;02bc	fe 03 	. . 
	jr nz,$+22		;02be	20 14 	  . 
	ld d,004h		;02c0	16 04 	. . 
	ld a,(0ffbbh)		;02c2	3a bb ff 	: . . 
	bit 7,a		;02c5	cb 7f 	.  
	jr z,$+27		;02c7	28 19 	( . 
	ld a,(0ffbah)		;02c9	3a ba ff 	: . . 
	and 00fh		;02cc	e6 0f 	. . 
	rlca			;02ce	07 	. 
	rlca			;02cf	07 	. 
	add a,d			;02d0	82 	. 
	ld d,a			;02d1	57 	W 
	jr $+16		;02d2	18 0e 	. . 
	or a			;02d4	b7 	. 
	jr nz,$+4		;02d5	20 02 	  . 
	ld e,080h		;02d7	1e 80 	. . 
	ld a,(0ffbah)		;02d9	3a ba ff 	: . . 
	and 00fh		;02dc	e6 0f 	. . 
	ld d,001h		;02de	16 01 	. . 
	add a,d			;02e0	82 	. 
	ld d,a			;02e1	57 	W 
	ret			;02e2	c9 	. 
	call 0c3a9h		;02e3	cd a9 c3 	. . . 
	cp 0ffh		;02e6	fe ff 	. . 
	ret z			;02e8	c8 	. 
	ld b,014h		;02e9	06 14 	. . 
	ld a,(0ffb8h)		;02eb	3a b8 ff 	: . . 
	cp 003h		;02ee	fe 03 	. . 
	jr z,$+4		;02f0	28 02 	( . 
	ld b,040h		;02f2	06 40 	. @ 
	push bc			;02f4	c5 	. 
	call 0c41ch		;02f5	cd 1c c4 	. . . 
	ld c,04dh		;02f8	0e 4d 	. M 
	call 0c415h		;02fa	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;02fd	ed 4b b9 ff 	. K . . 
	call 0c415h		;0301	cd 15 c4 	. . . 
	ld a,(0ffb8h)		;0304	3a b8 ff 	: . . 
	ld c,a			;0307	4f 	O 
	call 0c415h		;0308	cd 15 c4 	. . . 
	ld c,005h		;030b	0e 05 	. . 
	ld a,(0ffb8h)		;030d	3a b8 ff 	: . . 
	cp 003h		;0310	fe 03 	. . 
	jr z,$+4		;0312	28 02 	( . 
	ld c,010h		;0314	0e 10 	. . 
	call 0c415h		;0316	cd 15 c4 	. . . 
	ld c,028h		;0319	0e 28 	. ( 
	call 0c415h		;031b	cd 15 c4 	. . . 
	di			;031e	f3 	. 
	ld c,0e5h		;031f	0e e5 	. . 
	call 0c415h		;0321	cd 15 c4 	. . . 
	pop bc			;0324	c1 	. 
	ld c,0c1h		;0325	0e c1 	. . 
	ld hl,(0ffbdh)		;0327	2a bd ff 	* . . 
	in a,(082h)		;032a	db 82 	. . 
	bit 2,a		;032c	cb 57 	. W 
	jr z,$-4		;032e	28 fa 	( . 
	in a,(0c0h)		;0330	db c0 	. . 
	bit 5,a		;0332	cb 6f 	. o 
	jr z,$+6		;0334	28 04 	( . 
	outi		;0336	ed a3 	. . 
	jr nz,$-14		;0338	20 f0 	  . 
	out (0dch),a		;033a	d3 dc 	. . 
	ei			;033c	fb 	. 
	call 0c3f4h		;033d	cd f4 c3 	. . . 
	ld a,(0ffc0h)		;0340	3a c0 ff 	: . . 
	and 0c0h		;0343	e6 c0 	. . 
	cp 040h		;0345	fe 40 	. @ 
	jr nz,$+5		;0347	20 03 	  . 
	ld a,0ffh		;0349	3e ff 	> . 
	ret			;034b	c9 	. 
	xor a			;034c	af 	. 
	ret			;034d	c9 	. 
	ld bc,(0ffb9h)		;034e	ed 4b b9 ff 	. K . . 
	call 0c415h		;0352	cd 15 c4 	. . . 
	ld de,(0ffbbh)		;0355	ed 5b bb ff 	. [ . . 
	ld c,d			;0359	4a 	J 
	call 0c415h		;035a	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;035d	ed 4b b9 ff 	. K . . 
	ld a,c			;0361	79 	y 
	and 004h		;0362	e6 04 	. . 
	rrca			;0364	0f 	. 
	rrca			;0365	0f 	. 
	ld c,a			;0366	4f 	O 
	call 0c415h		;0367	cd 15 c4 	. . . 
	res 7,e		;036a	cb bb 	. . 
	ld c,e			;036c	4b 	K 
	inc c			;036d	0c 	. 
	call 0c415h		;036e	cd 15 c4 	. . . 
	ld a,(0ffb8h)		;0371	3a b8 ff 	: . . 
	ld c,a			;0374	4f 	O 
	call 0c415h		;0375	cd 15 c4 	. . . 
	ld c,005h		;0378	0e 05 	. . 
	ld a,(0ffb8h)		;037a	3a b8 ff 	: . . 
	cp 003h		;037d	fe 03 	. . 
	jr z,$+4		;037f	28 02 	( . 
	ld c,010h		;0381	0e 10 	. . 
	call 0c415h		;0383	cd 15 c4 	. . . 
	ld c,028h		;0386	0e 28 	. ( 
	call 0c415h		;0388	cd 15 c4 	. . . 
	ld c,0ffh		;038b	0e ff 	. . 
	call 0c415h		;038d	cd 15 c4 	. . . 
	ret			;0390	c9 	. 
	call 0c41ch		;0391	cd 1c c4 	. . . 
	ld c,007h		;0394	0e 07 	. . 
	call 0c415h		;0396	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;0399	ed 4b b9 ff 	. K . . 
	res 2,c		;039d	cb 91 	. . 
	call 0c415h		;039f	cd 15 c4 	. . . 
	call 0c3d2h		;03a2	cd d2 c3 	. . . 
	jr z,$-20		;03a5	28 ea 	( . 
	xor a			;03a7	af 	. 
	ret			;03a8	c9 	. 
	ld de,(0ffbbh)		;03a9	ed 5b bb ff 	. [ . . 
	ld a,d			;03ad	7a 	z 
	or a			;03ae	b7 	. 
	jp z,0c391h		;03af	ca 91 c3 	. . . 
	call 0c41ch		;03b2	cd 1c c4 	. . . 
	ld c,00fh		;03b5	0e 0f 	. . 
	call 0c415h		;03b7	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;03ba	ed 4b b9 ff 	. K . . 
	call 0c415h		;03be	cd 15 c4 	. . . 
	ld c,d			;03c1	4a 	J 
	call 0c415h		;03c2	cd 15 c4 	. . . 
	call 0c3d2h		;03c5	cd d2 c3 	. . . 
	jr nz,$+8		;03c8	20 06 	  . 
	call 0c391h		;03ca	cd 91 c3 	. . . 
	jp 0c3a9h		;03cd	c3 a9 c3 	. . . 
	xor a			;03d0	af 	. 
	ret			;03d1	c9 	. 
	in a,(082h)		;03d2	db 82 	. . 
	bit 2,a		;03d4	cb 57 	. W 
	jp z,0c3d2h		;03d6	ca d2 c3 	. . . 
	call 0c41ch		;03d9	cd 1c c4 	. . . 
	call 0c403h		;03dc	cd 03 c4 	. . . 
	ld a,008h		;03df	3e 08 	> . 
	out (0c1h),a		;03e1	d3 c1 	. . 
	call 0c40ch		;03e3	cd 0c c4 	. . . 
	in a,(0c1h)		;03e6	db c1 	. . 
	ld b,a			;03e8	47 	G 
	call 0c40ch		;03e9	cd 0c c4 	. . . 
	in a,(0c1h)		;03ec	db c1 	. . 
	ld a,b			;03ee	78 	x 
	and 0c0h		;03ef	e6 c0 	. . 
	cp 040h		;03f1	fe 40 	. @ 
	ret			;03f3	c9 	. 
	ld hl,0ffc0h		;03f4	21 c0 ff 	! . . 
	ld b,007h		;03f7	06 07 	. . 
	ld c,0c1h		;03f9	0e c1 	. . 
	call 0c40ch		;03fb	cd 0c c4 	. . . 
	ini		;03fe	ed a2 	. . 
	jr nz,$-5		;0400	20 f9 	  . 
	ret			;0402	c9 	. 
	in a,(0c0h)		;0403	db c0 	. . 
	rlca			;0405	07 	. 
	jr nc,$-3		;0406	30 fb 	0 . 
	rlca			;0408	07 	. 
	jr c,$-6		;0409	38 f8 	8 . 
	ret			;040b	c9 	. 
	in a,(0c0h)		;040c	db c0 	. . 
	rlca			;040e	07 	. 
	jr nc,$-3		;040f	30 fb 	0 . 
	rlca			;0411	07 	. 
	jr nc,$-6		;0412	30 f8 	0 . 
	ret			;0414	c9 	. 
	call 0c403h		;0415	cd 03 c4 	. . . 
	ld a,c			;0418	79 	y 
	out (0c1h),a		;0419	d3 c1 	. . 
	ret			;041b	c9 	. 
	in a,(0c0h)		;041c	db c0 	. . 
	bit 4,a		;041e	cb 67 	. g 
	jr nz,$-4		;0420	20 fa 	  . 
	ret			;0422	c9 	. 
	ld b,001h		;0423	06 01 	. . 
	ld a,c			;0425	79 	y 
	and 003h		;0426	e6 03 	. . 
	or a			;0428	b7 	. 
	jr z,$+7		;0429	28 05 	( . 
	rlc b		;042b	cb 00 	. . 
	dec a			;042d	3d 	= 
	jr nz,$-3		;042e	20 fb 	  . 
	ld a,(0ffc7h)		;0430	3a c7 ff 	: . . 
	ld c,a			;0433	4f 	O 
	and b			;0434	a0 	. 
	ret nz			;0435	c0 	. 
	ld a,c			;0436	79 	y 
	or b			;0437	b0 	. 
	ld (0ffc7h),a		;0438	32 c7 ff 	2 . . 
	call 0c391h		;043b	cd 91 c3 	. . . 
	ret			;043e	c9 	. 
	push bc			;043f	c5 	. 
	push hl			;0440	e5 	. 
	ld hl,0c45ch		;0441	21 5c c4 	! \ . 
	call 0c41ch		;0444	cd 1c c4 	. . . 
	ld c,003h		;0447	0e 03 	. . 
	call 0c415h		;0449	cd 15 c4 	. . . 
	ld c,(hl)			;044c	4e 	N 
	inc hl			;044d	23 	# 
	call 0c415h		;044e	cd 15 c4 	. . . 
	ld c,(hl)			;0451	4e 	N 
	call 0c415h		;0452	cd 15 c4 	. . . 
	xor a			;0455	af 	. 
	ld (0ffc7h),a		;0456	32 c7 ff 	2 . . 
	pop hl			;0459	e1 	. 
	pop bc			;045a	c1 	. 
	ret			;045b	c9 	. 
	ld l,a			;045c	6f 	o 
	dec de			;045d	1b 	. 
	push af			;045e	f5 	. 
	push bc			;045f	c5 	. 
	push de			;0460	d5 	. 
	push hl			;0461	e5 	. 
	push ix		;0462	dd e5 	. . 
	push iy		;0464	fd e5 	. . 
	call 0c69ah		;0466	cd 9a c6 	. . . 
	ld a,(0ffd8h)		;0469	3a d8 ff 	: . . 
	or a			;046c	b7 	. 
	jp nz,0c9e3h		;046d	c2 e3 c9 	. . . 
	ld a,(0ffcch)		;0470	3a cc ff 	: . . 
	cp 0ffh		;0473	fe ff 	. . 
	jp z,0c6a3h		;0475	ca a3 c6 	. . . 
	or a			;0478	b7 	. 
	jp nz,0c4beh		;0479	c2 be c4 	. . . 
	ld a,c			;047c	79 	y 
	cp 01bh		;047d	fe 1b 	. . 
	jr z,$+55		;047f	28 35 	( 5 
	cp 020h		;0481	fe 20 	.   
	jp nc,0c4beh		;0483	d2 be c4 	. . . 
	cp 00dh		;0486	fe 0d 	. . 
	jp z,0c524h		;0488	ca 24 c5 	. $ . 
	cp 00ah		;048b	fe 0a 	. . 
	jp z,0c532h		;048d	ca 32 c5 	. 2 . 
	cp 00bh		;0490	fe 0b 	. . 
	jp z,0c558h		;0492	ca 58 c5 	. X . 
	cp 00ch		;0495	fe 0c 	. . 
	jp z,0c56fh		;0497	ca 6f c5 	. o . 
	cp 008h		;049a	fe 08 	. . 
	jp z,0c59bh		;049c	ca 9b c5 	. . . 
	cp 01eh		;049f	fe 1e 	. . 
	jp z,0c5dbh		;04a1	ca db c5 	. . . 
	cp 01ah		;04a4	fe 1a 	. . 
	jp z,0c5eeh		;04a6	ca ee c5 	. . . 
	cp 007h		;04a9	fe 07 	. . 
	call z,0c5f4h		;04ab	cc f4 c5 	. . . 
	cp 000h		;04ae	fe 00 	. . 
	jp z,0c6a3h		;04b0	ca a3 c6 	. . . 
	jp 0c4beh		;04b3	c3 be c4 	. . . 
	ld a,001h		;04b6	3e 01 	> . 
	ld (0ffd8h),a		;04b8	32 d8 ff 	2 . . 
	jp 0c6a3h		;04bb	c3 a3 c6 	. . . 
	push iy		;04be	fd e5 	. . 
	pop hl			;04c0	e1 	. 
	call 0c715h		;04c1	cd 15 c7 	. . . 
	ld (hl),c			;04c4	71 	q 
	call 0c795h		;04c5	cd 95 c7 	. . . 
	ld a,(0ffd1h)		;04c8	3a d1 ff 	: . . 
	ld b,a			;04cb	47 	G 
	ld a,(0ffd2h)		;04cc	3a d2 ff 	: . . 
	and (hl)			;04cf	a6 	. 
	or b			;04d0	b0 	. 
	ld (hl),a			;04d1	77 	w 
	call 0c79eh		;04d2	cd 9e c7 	. . . 
	call 0c5f8h		;04d5	cd f8 c5 	. . . 
	jr c,$+8		;04d8	38 06 	8 . 
	call 0c613h		;04da	cd 13 c6 	. . . 
	jp 0c6a3h		;04dd	c3 a3 c6 	. . . 
	ld a,(0ffcbh)		;04e0	3a cb ff 	: . . 
	ld b,a			;04e3	47 	G 
	ld a,(0ffcdh)		;04e4	3a cd ff 	: . . 
	cp b			;04e7	b8 	. 
	jr z,$+25		;04e8	28 17 	( . 
	inc b			;04ea	04 	. 
	ld a,b			;04eb	78 	x 
	ld (0ffcbh),a		;04ec	32 cb ff 	2 . . 
	ld a,(0ffc9h)		;04ef	3a c9 ff 	: . . 
	or a			;04f2	b7 	. 
	jr nz,$+8		;04f3	20 06 	  . 
	call 0c613h		;04f5	cd 13 c6 	. . . 
	jp 0c6a3h		;04f8	c3 a3 c6 	. . . 
	call 0c620h		;04fb	cd 20 c6 	.   . 
	jp 0c6a3h		;04fe	c3 a3 c6 	. . . 
	ld a,(0ffc9h)		;0501	3a c9 ff 	: . . 
	or a			;0504	b7 	. 
	jr nz,$+11		;0505	20 09 	  . 
	call 0c613h		;0507	cd 13 c6 	. . . 
	call 0c62eh		;050a	cd 2e c6 	. . . 
	jp 0c6a3h		;050d	c3 a3 c6 	. . . 
	ld a,(0ffcdh)		;0510	3a cd ff 	: . . 
	ld b,a			;0513	47 	G 
	ld a,(0ffd0h)		;0514	3a d0 ff 	: . . 
	ld c,a			;0517	4f 	O 
	call 0c6f1h		;0518	cd f1 c6 	. . . 
	call 0c71ch		;051b	cd 1c c7 	. . . 
	call 0c62eh		;051e	cd 2e c6 	. . . 
	jp 0c6a3h		;0521	c3 a3 c6 	. . . 
	ld a,(0ffd0h)		;0524	3a d0 ff 	: . . 
	ld (0ffcah),a		;0527	32 ca ff 	2 . . 
	ld c,a			;052a	4f 	O 
	ld a,(0ffcbh)		;052b	3a cb ff 	: . . 
	ld b,a			;052e	47 	G 
	jp 0c5e5h		;052f	c3 e5 c5 	. . . 
	ld a,(0ffcbh)		;0532	3a cb ff 	: . . 
	ld b,a			;0535	47 	G 
	ld a,(0ffcdh)		;0536	3a cd ff 	: . . 
	cp b			;0539	b8 	. 
	jr z,$+17		;053a	28 0f 	( . 
	inc b			;053c	04 	. 
	ld a,b			;053d	78 	x 
	ld (0ffcbh),a		;053e	32 cb ff 	2 . . 
	push iy		;0541	fd e5 	. . 
	pop hl			;0543	e1 	. 
	ld de,00050h		;0544	11 50 00 	. P . 
	add hl,de			;0547	19 	. 
	jp 0c5e8h		;0548	c3 e8 c5 	. . . 
	call 0c62eh		;054b	cd 2e c6 	. . . 
	ld a,(0ffcbh)		;054e	3a cb ff 	: . . 
	ld b,a			;0551	47 	G 
	ld a,(0ffcah)		;0552	3a ca ff 	: . . 
	ld c,a			;0555	4f 	O 
	jr $-21		;0556	18 e9 	. . 
	ld a,(0ffcbh)		;0558	3a cb ff 	: . . 
	ld b,a			;055b	47 	G 
	ld a,(0ffceh)		;055c	3a ce ff 	: . . 
	cp b			;055f	b8 	. 
	jp z,0c6a3h		;0560	ca a3 c6 	. . . 
	dec b			;0563	05 	. 
	ld a,b			;0564	78 	x 
	ld (0ffcbh),a		;0565	32 cb ff 	2 . . 
	ld a,(0ffcah)		;0568	3a ca ff 	: . . 
	ld c,a			;056b	4f 	O 
	jp 0c5e5h		;056c	c3 e5 c5 	. . . 
	call 0c5f8h		;056f	cd f8 c5 	. . . 
	ld a,(0ffcbh)		;0572	3a cb ff 	: . . 
	ld b,a			;0575	47 	G 
	jr c,$+5		;0576	38 03 	8 . 
	jp 0c5e5h		;0578	c3 e5 c5 	. . . 
	ld a,(0ffd0h)		;057b	3a d0 ff 	: . . 
	ld (0ffcah),a		;057e	32 ca ff 	2 . . 
	ld c,a			;0581	4f 	O 
	ld a,(0ffcbh)		;0582	3a cb ff 	: . . 
	ld b,a			;0585	47 	G 
	ld a,(0ffcdh)		;0586	3a cd ff 	: . . 
	cp b			;0589	b8 	. 
	jr z,$+10		;058a	28 08 	( . 
	inc b			;058c	04 	. 
	ld a,b			;058d	78 	x 
	ld (0ffcbh),a		;058e	32 cb ff 	2 . . 
	jp 0c5e5h		;0591	c3 e5 c5 	. . . 
	push bc			;0594	c5 	. 
	call 0c62eh		;0595	cd 2e c6 	. . . 
	pop bc			;0598	c1 	. 
	jr $+76		;0599	18 4a 	. J 
	ld a,(0ffcah)		;059b	3a ca ff 	: . . 
	ld c,a			;059e	4f 	O 
	ld a,(0ffd0h)		;059f	3a d0 ff 	: . . 
	cp c			;05a2	b9 	. 
	jr z,$+21		;05a3	28 13 	( . 
	dec c			;05a5	0d 	. 
	ld a,(0ffd1h)		;05a6	3a d1 ff 	: . . 
	bit 3,a		;05a9	cb 5f 	. _ 
	jr z,$+3		;05ab	28 01 	( . 
	dec c			;05ad	0d 	. 
	ld a,c			;05ae	79 	y 
	ld (0ffcah),a		;05af	32 ca ff 	2 . . 
	ld a,(0ffcbh)		;05b2	3a cb ff 	: . . 
	ld b,a			;05b5	47 	G 
	jr $+47		;05b6	18 2d 	. - 
	ld a,(0ffcfh)		;05b8	3a cf ff 	: . . 
	ld b,a			;05bb	47 	G 
	ld a,(0ffd1h)		;05bc	3a d1 ff 	: . . 
	bit 3,a		;05bf	cb 5f 	. _ 
	jr z,$+3		;05c1	28 01 	( . 
	dec b			;05c3	05 	. 
	ld a,b			;05c4	78 	x 
	ld (0ffcah),a		;05c5	32 ca ff 	2 . . 
	ld c,a			;05c8	4f 	O 
	ld a,(0ffcbh)		;05c9	3a cb ff 	: . . 
	ld b,a			;05cc	47 	G 
	ld a,(0ffceh)		;05cd	3a ce ff 	: . . 
	cp b			;05d0	b8 	. 
	jp z,0c6a3h		;05d1	ca a3 c6 	. . . 
	dec b			;05d4	05 	. 
	ld a,b			;05d5	78 	x 
	ld (0ffcbh),a		;05d6	32 cb ff 	2 . . 
	jr $+12		;05d9	18 0a 	. . 
	xor a			;05db	af 	. 
	ld (0ffcbh),a		;05dc	32 cb ff 	2 . . 
	ld (0ffcah),a		;05df	32 ca ff 	2 . . 
	ld bc,00000h		;05e2	01 00 00 	. . . 
	call 0c6f1h		;05e5	cd f1 c6 	. . . 
	call 0c71ch		;05e8	cd 1c c7 	. . . 
	jp 0c6a3h		;05eb	c3 a3 c6 	. . . 
	call 0c764h		;05ee	cd 64 c7 	. d . 
	jp 0c6a3h		;05f1	c3 a3 c6 	. . . 
	xor a			;05f4	af 	. 
	out (0dah),a		;05f5	d3 da 	. . 
	ret			;05f7	c9 	. 
	ld a,(0ffcah)		;05f8	3a ca ff 	: . . 
	ld c,a			;05fb	4f 	O 
	inc c			;05fc	0c 	. 
	ld a,(0ffd1h)		;05fd	3a d1 ff 	: . . 
	bit 3,a		;0600	cb 5f 	. _ 
	jr z,$+3		;0602	28 01 	( . 
	inc c			;0604	0c 	. 
	ld a,(0ffcfh)		;0605	3a cf ff 	: . . 
	cp c			;0608	b9 	. 
	ld a,c			;0609	79 	y 
	jr nc,$+5		;060a	30 03 	0 . 
	ld a,(0ffd0h)		;060c	3a d0 ff 	: . . 
	ld (0ffcah),a		;060f	32 ca ff 	2 . . 
	ret			;0612	c9 	. 
	inc hl			;0613	23 	# 
	ld a,(0ffd1h)		;0614	3a d1 ff 	: . . 
	bit 3,a		;0617	cb 5f 	. _ 
	jr z,$+3		;0619	28 01 	( . 
	inc hl			;061b	23 	# 
	call 0c71ch		;061c	cd 1c c7 	. . . 
	ret			;061f	c9 	. 
	ld a,(0ffc8h)		;0620	3a c8 ff 	: . . 
	ld e,a			;0623	5f 	_ 
	ld d,000h		;0624	16 00 	. . 
	push iy		;0626	fd e5 	. . 
	pop hl			;0628	e1 	. 
	add hl,de			;0629	19 	. 
	call 0c71ch		;062a	cd 1c c7 	. . . 
	ret			;062d	c9 	. 
	ld a,(0ffc9h)		;062e	3a c9 ff 	: . . 
	or a			;0631	b7 	. 
	jr nz,$+21		;0632	20 13 	  . 
	push ix		;0634	dd e5 	. . 
	pop hl			;0636	e1 	. 
	ld de,00050h		;0637	11 50 00 	. P . 
	add hl,de			;063a	19 	. 
	call 0c742h		;063b	cd 42 c7 	. B . 
	ld b,017h		;063e	06 17 	. . 
	call 0c7fah		;0640	cd fa c7 	. . . 
	call 0c670h		;0643	cd 70 c6 	. p . 
	ret			;0646	c9 	. 
	ld a,(0ffd0h)		;0647	3a d0 ff 	: . . 
	ld c,a			;064a	4f 	O 
	ld a,(0ffceh)		;064b	3a ce ff 	: . . 
	ld b,a			;064e	47 	G 
	ld a,(0ffceh)		;064f	3a ce ff 	: . . 
	ld d,a			;0652	57 	W 
	ld a,(0ffcdh)		;0653	3a cd ff 	: . . 
	sub d			;0656	92 	. 
	jr z,$+13		;0657	28 0b 	( . 
	ld d,a			;0659	57 	W 
	inc b			;065a	04 	. 
	call 0c6f1h		;065b	cd f1 c6 	. . . 
	call 0c7a7h		;065e	cd a7 c7 	. . . 
	dec d			;0661	15 	. 
	jr nz,$-8		;0662	20 f6 	  . 
	ld a,(0ffcdh)		;0664	3a cd ff 	: . . 
	ld d,a			;0667	57 	W 
	ld a,(0ffcfh)		;0668	3a cf ff 	: . . 
	ld e,a			;066b	5f 	_ 
	call 0c805h		;066c	cd 05 c8 	. . . 
	ret			;066f	c9 	. 
	push ix		;0670	dd e5 	. . 
	pop hl			;0672	e1 	. 
	ld de,00730h		;0673	11 30 07 	. 0 . 
	ld b,050h		;0676	06 50 	. P 
	add hl,de			;0678	19 	. 
	ld de,02000h		;0679	11 00 20 	. .   
	call 0c795h		;067c	cd 95 c7 	. . . 
	call 0c715h		;067f	cd 15 c7 	. . . 
	push hl			;0682	e5 	. 
	push bc			;0683	c5 	. 
	ld e,000h		;0684	1e 00 	. . 
	call 0c690h		;0686	cd 90 c6 	. . . 
	pop bc			;0689	c1 	. 
	pop hl			;068a	e1 	. 
	call 0c79eh		;068b	cd 9e c7 	. . . 
	ld e,020h		;068e	1e 20 	.   
	ld (hl),e			;0690	73 	s 
	inc hl			;0691	23 	# 
	bit 3,h		;0692	cb 5c 	. \ 
	call z,0c715h		;0694	cc 15 c7 	. . . 
	djnz $-7		;0697	10 f7 	. . 
	ret			;0699	c9 	. 
	ld ix,(0ffd4h)		;069a	dd 2a d4 ff 	. * . . 
	ld iy,(0ffd6h)		;069e	fd 2a d6 ff 	. * . . 
	ret			;06a2	c9 	. 
	call 0c6e8h		;06a3	cd e8 c6 	. . . 
	pop iy		;06a6	fd e1 	. . 
	pop ix		;06a8	dd e1 	. . 
	pop hl			;06aa	e1 	. 
	pop de			;06ab	d1 	. 
	pop bc			;06ac	c1 	. 
	pop af			;06ad	f1 	. 
	ret			;06ae	c9 	. 
	ld hl,0ffc9h		;06af	21 c9 ff 	! . . 
	xor a			;06b2	af 	. 
	ld (hl),a			;06b3	77 	w 
	inc hl			;06b4	23 	# 
	ld (hl),a			;06b5	77 	w 
	inc hl			;06b6	23 	# 
	ld (hl),a			;06b7	77 	w 
	inc hl			;06b8	23 	# 
	ld (hl),a			;06b9	77 	w 
	inc hl			;06ba	23 	# 
	ld (hl),017h		;06bb	36 17 	6 . 
	inc hl			;06bd	23 	# 
	ld (hl),a			;06be	77 	w 
	inc hl			;06bf	23 	# 
	ld (hl),04fh		;06c0	36 4f 	6 O 
	inc hl			;06c2	23 	# 
	ld (hl),a			;06c3	77 	w 
	inc hl			;06c4	23 	# 
	ld (hl),a			;06c5	77 	w 
	inc hl			;06c6	23 	# 
	ld (hl),080h		;06c7	36 80 	6 . 
	inc hl			;06c9	23 	# 
	ld a,(0c86fh)		;06ca	3a 6f c8 	: o . 
	ld d,a			;06cd	57 	W 
	in a,(0d6h)		;06ce	db d6 	. . 
	bit 5,a		;06d0	cb 6f 	. o 
	jr z,$+4		;06d2	28 02 	( . 
	ld d,003h		;06d4	16 03 	. . 
	bit 6,a		;06d6	cb 77 	. w 
	jr z,$+6		;06d8	28 04 	( . 
	set 5,d		;06da	cb ea 	. . 
	set 6,d		;06dc	cb f2 	. . 
	ld (hl),d			;06de	72 	r 
	xor a			;06df	af 	. 
	inc hl			;06e0	23 	# 
	ld b,015h		;06e1	06 15 	. . 
	ld (hl),a			;06e3	77 	w 
	inc hl			;06e4	23 	# 
	djnz $-2		;06e5	10 fc 	. . 
	ret			;06e7	c9 	. 
	ld (0ffd4h),ix		;06e8	dd 22 d4 ff 	. " . . 
	ld (0ffd6h),iy		;06ec	fd 22 d6 ff 	. " . . 
	ret			;06f0	c9 	. 
	push af			;06f1	f5 	. 
	push bc			;06f2	c5 	. 
	push de			;06f3	d5 	. 
	push ix		;06f4	dd e5 	. . 
	pop hl			;06f6	e1 	. 
	ld de,00050h		;06f7	11 50 00 	. P . 
	ld a,b			;06fa	78 	x 
	ld b,005h		;06fb	06 05 	. . 
	rra			;06fd	1f 	. 
	jr nc,$+3		;06fe	30 01 	0 . 
	add hl,de			;0700	19 	. 
	or a			;0701	b7 	. 
	rl e		;0702	cb 13 	. . 
	rl d		;0704	cb 12 	. . 
	dec b			;0706	05 	. 
	jr nz,$-10		;0707	20 f4 	  . 
	ld d,000h		;0709	16 00 	. . 
	ld e,c			;070b	59 	Y 
	add hl,de			;070c	19 	. 
	ld a,h			;070d	7c 	| 
	and 00fh		;070e	e6 0f 	. . 
	ld h,a			;0710	67 	g 
	pop de			;0711	d1 	. 
	pop bc			;0712	c1 	. 
	pop af			;0713	f1 	. 
	ret			;0714	c9 	. 
	ld a,h			;0715	7c 	| 
	and 007h		;0716	e6 07 	. . 
	or 0d0h		;0718	f6 d0 	. . 
	ld h,a			;071a	67 	g 
	ret			;071b	c9 	. 
	ld a,h			;071c	7c 	| 
	and 007h		;071d	e6 07 	. . 
	ld h,a			;071f	67 	g 
	push ix		;0720	dd e5 	. . 
	pop de			;0722	d1 	. 
	ex de,hl			;0723	eb 	. 
	or a			;0724	b7 	. 
	sbc hl,de		;0725	ed 52 	. R 
	jr c,$+9		;0727	38 07 	8 . 
	jr z,$+7		;0729	28 05 	( . 
	ld hl,00800h		;072b	21 00 08 	! . . 
	add hl,de			;072e	19 	. 
	ex de,hl			;072f	eb 	. 
	ld a,00eh		;0730	3e 0e 	> . 
	out (0a0h),a		;0732	d3 a0 	. . 
	ld a,d			;0734	7a 	z 
	out (0a1h),a		;0735	d3 a1 	. . 
	ld a,00fh		;0737	3e 0f 	> . 
	out (0a0h),a		;0739	d3 a0 	. . 
	ld a,e			;073b	7b 	{ 
	out (0a1h),a		;073c	d3 a1 	. . 
	push de			;073e	d5 	. 
	pop iy		;073f	fd e1 	. . 
	ret			;0741	c9 	. 
	ld a,h			;0742	7c 	| 
	and 007h		;0743	e6 07 	. . 
	ld h,a			;0745	67 	g 
	call 0c75bh		;0746	cd 5b c7 	. [ . 
	ld a,00ch		;0749	3e 0c 	> . 
	out (0a0h),a		;074b	d3 a0 	. . 
	ld a,h			;074d	7c 	| 
	out (0a1h),a		;074e	d3 a1 	. . 
	ld a,00dh		;0750	3e 0d 	> . 
	out (0a0h),a		;0752	d3 a0 	. . 
	ld a,l			;0754	7d 	} 
	out (0a1h),a		;0755	d3 a1 	. . 
	push hl			;0757	e5 	. 
	pop ix		;0758	dd e1 	. . 
	ret			;075a	c9 	. 
	in a,(0a0h)		;075b	db a0 	. . 
	in a,(082h)		;075d	db 82 	. . 
	bit 1,a		;075f	cb 4f 	. O 
	jr z,$-4		;0761	28 fa 	( . 
	ret			;0763	c9 	. 
	ld bc,00780h		;0764	01 80 07 	. . . 
	push ix		;0767	dd e5 	. . 
	pop hl			;0769	e1 	. 
	ld de,02000h		;076a	11 00 20 	. .   
	call 0c715h		;076d	cd 15 c7 	. . . 
	ld (hl),d			;0770	72 	r 
	in a,(081h)		;0771	db 81 	. . 
	set 7,a		;0773	cb ff 	. . 
	out (081h),a		;0775	d3 81 	. . 
	ld (hl),e			;0777	73 	s 
	res 7,a		;0778	cb bf 	. . 
	out (081h),a		;077a	d3 81 	. . 
	inc hl			;077c	23 	# 
	bit 3,h		;077d	cb 5c 	. \ 
	call z,0c715h		;077f	cc 15 c7 	. . . 
	dec bc			;0782	0b 	. 
	ld a,b			;0783	78 	x 
	or c			;0784	b1 	. 
	jr nz,$-21		;0785	20 e9 	  . 
	push ix		;0787	dd e5 	. . 
	pop hl			;0789	e1 	. 
	call 0c71ch		;078a	cd 1c c7 	. . . 
	xor a			;078d	af 	. 
	ld (0ffcah),a		;078e	32 ca ff 	2 . . 
	ld (0ffcbh),a		;0791	32 cb ff 	2 . . 
	ret			;0794	c9 	. 
	push af			;0795	f5 	. 
	in a,(081h)		;0796	db 81 	. . 
	set 7,a		;0798	cb ff 	. . 
	out (081h),a		;079a	d3 81 	. . 
	pop af			;079c	f1 	. 
	ret			;079d	c9 	. 
	push af			;079e	f5 	. 
	in a,(081h)		;079f	db 81 	. . 
	res 7,a		;07a1	cb bf 	. . 
	out (081h),a		;07a3	d3 81 	. . 
	pop af			;07a5	f1 	. 
	ret			;07a6	c9 	. 
	push de			;07a7	d5 	. 
	push bc			;07a8	c5 	. 
	ld a,050h		;07a9	3e 50 	> P 
	cpl			;07ab	2f 	/ 
	ld d,0ffh		;07ac	16 ff 	. . 
	ld e,a			;07ae	5f 	_ 
	inc de			;07af	13 	. 
	call 0c7b6h		;07b0	cd b6 c7 	. . . 
	pop bc			;07b3	c1 	. 
	pop de			;07b4	d1 	. 
	ret			;07b5	c9 	. 
	ld a,(0ffd0h)		;07b6	3a d0 ff 	: . . 
	ld c,a			;07b9	4f 	O 
	call 0c6f1h		;07ba	cd f1 c6 	. . . 
	push hl			;07bd	e5 	. 
	add hl,de			;07be	19 	. 
	ex de,hl			;07bf	eb 	. 
	pop hl			;07c0	e1 	. 
	ld a,(0ffd0h)		;07c1	3a d0 ff 	: . . 
	ld b,a			;07c4	47 	G 
	ld a,(0ffcfh)		;07c5	3a cf ff 	: . . 
	sub b			;07c8	90 	. 
	inc a			;07c9	3c 	< 
	ld b,a			;07ca	47 	G 
	call 0c715h		;07cb	cd 15 c7 	. . . 
	ex de,hl			;07ce	eb 	. 
	call 0c715h		;07cf	cd 15 c7 	. . . 
	ex de,hl			;07d2	eb 	. 
	push bc			;07d3	c5 	. 
	push de			;07d4	d5 	. 
	push hl			;07d5	e5 	. 
	ld c,002h		;07d6	0e 02 	. . 
	ld a,(hl)			;07d8	7e 	~ 
	ld (de),a			;07d9	12 	. 
	inc de			;07da	13 	. 
	ld a,d			;07db	7a 	z 
	and 007h		;07dc	e6 07 	. . 
	or 0d0h		;07de	f6 d0 	. . 
	ld d,a			;07e0	57 	W 
	inc hl			;07e1	23 	# 
	bit 3,h		;07e2	cb 5c 	. \ 
	call z,0c715h		;07e4	cc 15 c7 	. . . 
	djnz $-15		;07e7	10 ef 	. . 
	dec c			;07e9	0d 	. 
	jr z,$+12		;07ea	28 0a 	( . 
	ld a,c			;07ec	79 	y 
	pop hl			;07ed	e1 	. 
	pop de			;07ee	d1 	. 
	pop bc			;07ef	c1 	. 
	ld c,a			;07f0	4f 	O 
	call 0c795h		;07f1	cd 95 c7 	. . . 
	jr $-28		;07f4	18 e2 	. . 
	call 0c79eh		;07f6	cd 9e c7 	. . . 
	ret			;07f9	c9 	. 
	push de			;07fa	d5 	. 
	push bc			;07fb	c5 	. 
	ld de,00050h		;07fc	11 50 00 	. P . 
	call 0c7b6h		;07ff	cd b6 c7 	. . . 
	pop bc			;0802	c1 	. 
	pop de			;0803	d1 	. 
	ret			;0804	c9 	. 
	ld a,e			;0805	7b 	{ 
	sub c			;0806	91 	. 
	inc a			;0807	3c 	< 
	ld e,a			;0808	5f 	_ 
	ld a,d			;0809	7a 	z 
	sub b			;080a	90 	. 
	inc a			;080b	3c 	< 
	ld d,a			;080c	57 	W 
	call 0c6f1h		;080d	cd f1 c6 	. . . 
	call 0c715h		;0810	cd 15 c7 	. . . 
	ld (hl),020h		;0813	36 20 	6   
	call 0c795h		;0815	cd 95 c7 	. . . 
	ld (hl),000h		;0818	36 00 	6 . 
	call 0c79eh		;081a	cd 9e c7 	. . . 
	inc hl			;081d	23 	# 
	dec e			;081e	1d 	. 
	jr nz,$-15		;081f	20 ef 	  . 
	inc b			;0821	04 	. 
	ld a,(0ffd0h)		;0822	3a d0 ff 	: . . 
	ld c,a			;0825	4f 	O 
	ld a,(0ffcfh)		;0826	3a cf ff 	: . . 
	sub c			;0829	91 	. 
	inc a			;082a	3c 	< 
	ld e,a			;082b	5f 	_ 
	dec d			;082c	15 	. 
	jr nz,$-32		;082d	20 de 	  . 
	ret			;082f	c9 	. 
	ld a,(0ffcdh)		;0830	3a cd ff 	: . . 
	ld b,a			;0833	47 	G 
	ld a,(0ffceh)		;0834	3a ce ff 	: . . 
	cp b			;0837	b8 	. 
	jr z,$+13		;0838	28 0b 	( . 
	ld d,a			;083a	57 	W 
	ld a,b			;083b	78 	x 
	sub d			;083c	92 	. 
	ld d,a			;083d	57 	W 
	dec b			;083e	05 	. 
	call 0c7fah		;083f	cd fa c7 	. . . 
	dec d			;0842	15 	. 
	jr nz,$-5		;0843	20 f9 	  . 
	ld a,(0ffceh)		;0845	3a ce ff 	: . . 
	ld b,a			;0848	47 	G 
	ld d,a			;0849	57 	W 
	ld a,(0ffd0h)		;084a	3a d0 ff 	: . . 
	ld c,a			;084d	4f 	O 
	ld a,(0ffcfh)		;084e	3a cf ff 	: . . 
	ld e,a			;0851	5f 	_ 
	call 0c805h		;0852	cd 05 c8 	. . . 
	ret			;0855	c9 	. 
	push bc			;0856	c5 	. 
	ld b,01eh		;0857	06 1e 	. . 
	ld c,00fh		;0859	0e 0f 	. . 
	dec c			;085b	0d 	. 
	jp nz,0c85bh		;085c	c2 5b c8 	. [ . 
	dec b			;085f	05 	. 
	jp nz,0c859h		;0860	c2 59 c8 	. Y . 
	pop bc			;0863	c1 	. 
	ret			;0864	c9 	. 
	ld h,e			;0865	63 	c 
	ld d,b			;0866	50 	P 
	ld d,h			;0867	54 	T 
	xor d			;0868	aa 	. 
	add hl,de			;0869	19 	. 
	ld b,019h		;086a	06 19 	. . 
	add hl,de			;086c	19 	. 
	nop			;086d	00 	. 
	dec c			;086e	0d 	. 
	dec c			;086f	0d 	. 
	dec c			;0870	0d 	. 
	nop			;0871	00 	. 
	nop			;0872	00 	. 
	nop			;0873	00 	. 
	nop			;0874	00 	. 
	ld a,(0ffd1h)		;0875	3a d1 ff 	: . . 
	set 3,a		;0878	cb df 	. . 
	ld (0ffd1h),a		;087a	32 d1 ff 	2 . . 
	ld a,(0ffcah)		;087d	3a ca ff 	: . . 
	ld c,a			;0880	4f 	O 
	rra			;0881	1f 	. 
	jr nc,$+9		;0882	30 07 	0 . 
	inc iy		;0884	fd 23 	. # 
	inc c			;0886	0c 	. 
	ld a,c			;0887	79 	y 
	ld (0ffcah),a		;0888	32 ca ff 	2 . . 
	xor a			;088b	af 	. 
	ret			;088c	c9 	. 
	ld hl,0c865h		;088d	21 65 c8 	! e . 
	ld b,010h		;0890	06 10 	. . 
	ld c,0a1h		;0892	0e a1 	. . 
	xor a			;0894	af 	. 
	out (0a0h),a		;0895	d3 a0 	. . 
	inc a			;0897	3c 	< 
	outi		;0898	ed a3 	. . 
	jr nz,$-5		;089a	20 f9 	  . 
	ld ix,00000h		;089c	dd 21 00 00 	. ! . . 
	call 0c764h		;08a0	cd 64 c7 	. d . 
	call 0c8b6h		;08a3	cd b6 c8 	. . . 
	ld hl,00000h		;08a6	21 00 00 	! . . 
	call 0c71ch		;08a9	cd 1c c7 	. . . 
	ld a,(0ffd1h)		;08ac	3a d1 ff 	: . . 
	res 3,a		;08af	cb 9f 	. . 
	ld (0ffd1h),a		;08b1	32 d1 ff 	2 . . 
	xor a			;08b4	af 	. 
	ret			;08b5	c9 	. 
	ld a,006h		;08b6	3e 06 	> . 
	out (0a0h),a		;08b8	d3 a0 	. . 
	ld a,018h		;08ba	3e 18 	> . 
	out (0a1h),a		;08bc	d3 a1 	. . 
	ret			;08be	c9 	. 
	xor a			;08bf	af 	. 
	ld (0ffceh),a		;08c0	32 ce ff 	2 . . 
	ld (0ffd0h),a		;08c3	32 d0 ff 	2 . . 
	ld (0ffc9h),a		;08c6	32 c9 ff 	2 . . 
	ld a,017h		;08c9	3e 17 	> . 
	ld (0ffcdh),a		;08cb	32 cd ff 	2 . . 
	ret			;08ce	c9 	. 
	ld b,004h		;08cf	06 04 	. . 
	call 0c75bh		;08d1	cd 5b c7 	. [ . 
	xor a			;08d4	af 	. 
	ld c,0a1h		;08d5	0e a1 	. . 
	out (0a0h),a		;08d7	d3 a0 	. . 
	inc a			;08d9	3c 	< 
	outi		;08da	ed a3 	. . 
	jr nz,$-5		;08dc	20 f9 	  . 
	ret			;08de	c9 	. 
	ld a,(0ffd9h)		;08df	3a d9 ff 	: . . 
	or a			;08e2	b7 	. 
	jr nz,$+7		;08e3	20 05 	  . 
	inc a			;08e5	3c 	< 
	ld (0ffd9h),a		;08e6	32 d9 ff 	2 . . 
	ret			;08e9	c9 	. 
	ld a,c			;08ea	79 	y 
	and 00fh		;08eb	e6 0f 	. . 
	rlca			;08ed	07 	. 
	rlca			;08ee	07 	. 
	rlca			;08ef	07 	. 
	rlca			;08f0	07 	. 
	cpl			;08f1	2f 	/ 
	ld b,a			;08f2	47 	G 
	ld a,(0ffd1h)		;08f3	3a d1 ff 	: . . 
	and b			;08f6	a0 	. 
	ld (0ffd1h),a		;08f7	32 d1 ff 	2 . . 
	xor a			;08fa	af 	. 
	ret			;08fb	c9 	. 
	xor a			;08fc	af 	. 
	ld (0ffd1h),a		;08fd	32 d1 ff 	2 . . 
	ret			;0900	c9 	. 
	ld a,(0ffd9h)		;0901	3a d9 ff 	: . . 
	ld b,a			;0904	47 	G 
	ld d,000h		;0905	16 00 	. . 
	ld e,a			;0907	5f 	_ 
	ld hl,0ffd9h		;0908	21 d9 ff 	! . . 
	add hl,de			;090b	19 	. 
	ld a,c			;090c	79 	y 
	sub 020h		;090d	d6 20 	.   
	ld (hl),a			;090f	77 	w 
	ld a,b			;0910	78 	x 
	inc a			;0911	3c 	< 
	ld (0ffd9h),a		;0912	32 d9 ff 	2 . . 
	ret			;0915	c9 	. 
	ld a,b			;0916	78 	x 
	out (0a0h),a		;0917	d3 a0 	. . 
	ld a,c			;0919	79 	y 
	out (0a1h),a		;091a	d3 a1 	. . 
	ret			;091c	c9 	. 
	call 0c6f1h		;091d	cd f1 c6 	. . . 
	push hl			;0920	e5 	. 
	ld b,d			;0921	42 	B 
	ld c,e			;0922	4b 	K 
	call 0c6f1h		;0923	cd f1 c6 	. . . 
	pop de			;0926	d1 	. 
	push de			;0927	d5 	. 
	or a			;0928	b7 	. 
	sbc hl,de		;0929	ed 52 	. R 
	inc hl			;092b	23 	# 
	ex de,hl			;092c	eb 	. 
	pop hl			;092d	e1 	. 
	ld b,a			;092e	47 	G 
	call 0c795h		;092f	cd 95 c7 	. . . 
	call 0c715h		;0932	cd 15 c7 	. . . 
	ld a,(hl)			;0935	7e 	~ 
	or b			;0936	b0 	. 
	ld (hl),a			;0937	77 	w 
	inc hl			;0938	23 	# 
	dec de			;0939	1b 	. 
	ld a,d			;093a	7a 	z 
	or e			;093b	b3 	. 
	jr nz,$-10		;093c	20 f4 	  . 
	call 0c79eh		;093e	cd 9e c7 	. . . 
	ret			;0941	c9 	. 
	ld a,c			;0942	79 	y 
	cp 044h		;0943	fe 44 	. D 
	jr nz,$+6		;0945	20 04 	  . 
	ld c,040h		;0947	0e 40 	. @ 
	jr $+59		;0949	18 39 	. 9 
	cp 045h		;094b	fe 45 	. E 
	jr nz,$+6		;094d	20 04 	  . 
	ld c,060h		;094f	0e 60 	. ` 
	jr $+51		;0951	18 31 	. 1 
	cp 046h		;0953	fe 46 	. F 
	jr nz,$+6		;0955	20 04 	  . 
	ld c,020h		;0957	0e 20 	.   
	jr $+43		;0959	18 29 	. ) 
	ld a,(0c86fh)		;095b	3a 6f c8 	: o . 
	ld d,a			;095e	57 	W 
	in a,(0d6h)		;095f	db d6 	. . 
	bit 5,a		;0961	cb 6f 	. o 
	jr z,$+4		;0963	28 02 	( . 
	ld d,003h		;0965	16 03 	. . 
	bit 6,a		;0967	cb 77 	. w 
	jr z,$+6		;0969	28 04 	( . 
	set 5,d		;096b	cb ea 	. . 
	set 6,d		;096d	cb f2 	. . 
	ld a,d			;096f	7a 	z 
	ld (0ffd3h),a		;0970	32 d3 ff 	2 . . 
	ld b,00ah		;0973	06 0a 	. . 
	ld c,a			;0975	4f 	O 
	call 0c916h		;0976	cd 16 c9 	. . . 
	ld a,(0c870h)		;0979	3a 70 c8 	: p . 
	ld c,a			;097c	4f 	O 
	ld b,00bh		;097d	06 0b 	. . 
	call 0c916h		;097f	cd 16 c9 	. . . 
	xor a			;0982	af 	. 
	ret			;0983	c9 	. 
	ld a,(0ffd3h)		;0984	3a d3 ff 	: . . 
	and 09fh		;0987	e6 9f 	. . 
	or c			;0989	b1 	. 
	ld (0ffd3h),a		;098a	32 d3 ff 	2 . . 
	ld c,a			;098d	4f 	O 
	ld b,00ah		;098e	06 0a 	. . 
	call 0c916h		;0990	cd 16 c9 	. . . 
	xor a			;0993	af 	. 
	ret			;0994	c9 	. 
	ld hl,0ffd1h		;0995	21 d1 ff 	! . . 
	set 0,(hl)		;0998	cb c6 	. . 
	xor a			;099a	af 	. 
	ret			;099b	c9 	. 
	ld hl,0ffd1h		;099c	21 d1 ff 	! . . 
	res 0,(hl)		;099f	cb 86 	. . 
	xor a			;09a1	af 	. 
	ret			;09a2	c9 	. 
	ld hl,0ffd1h		;09a3	21 d1 ff 	! . . 
	set 2,(hl)		;09a6	cb d6 	. . 
	xor a			;09a8	af 	. 
	ret			;09a9	c9 	. 
	ld hl,0ffd1h		;09aa	21 d1 ff 	! . . 
	res 2,(hl)		;09ad	cb 96 	. . 
	xor a			;09af	af 	. 
	ret			;09b0	c9 	. 
	ld hl,0ffd1h		;09b1	21 d1 ff 	! . . 
	set 1,(hl)		;09b4	cb ce 	. . 
	xor a			;09b6	af 	. 
	ret			;09b7	c9 	. 
	ld hl,0ffd1h		;09b8	21 d1 ff 	! . . 
	res 1,(hl)		;09bb	cb 8e 	. . 
	xor a			;09bd	af 	. 
	ret			;09be	c9 	. 
	ld a,(0ffd1h)		;09bf	3a d1 ff 	: . . 
	and 08fh		;09c2	e6 8f 	. . 
	or 010h		;09c4	f6 10 	. . 
	ld (0ffd1h),a		;09c6	32 d1 ff 	2 . . 
	xor a			;09c9	af 	. 
	ret			;09ca	c9 	. 
	ld a,(0ffd1h)		;09cb	3a d1 ff 	: . . 
	and 08fh		;09ce	e6 8f 	. . 
	or 000h		;09d0	f6 00 	. . 
	ld (0ffd1h),a		;09d2	32 d1 ff 	2 . . 
	xor a			;09d5	af 	. 
	ret			;09d6	c9 	. 
	ld a,(0ffd1h)		;09d7	3a d1 ff 	: . . 
	and 08fh		;09da	e6 8f 	. . 
	or 020h		;09dc	f6 20 	.   
	ld (0ffd1h),a		;09de	32 d1 ff 	2 . . 
	xor a			;09e1	af 	. 
	ret			;09e2	c9 	. 
	call 0ca01h		;09e3	cd 01 ca 	. . . 
	cp 001h		;09e6	fe 01 	. . 
	jr nz,$+3		;09e8	20 01 	  . 
	ld a,c			;09ea	79 	y 
	ld (0ffd8h),a		;09eb	32 d8 ff 	2 . . 
	cp 060h		;09ee	fe 60 	. ` 
	jp nc,0ca70h		;09f0	d2 70 ca 	. p . 
	sub 031h		;09f3	d6 31 	. 1 
	jp c,0ca70h		;09f5	da 70 ca 	. p . 
	call 0ca05h		;09f8	cd 05 ca 	. . . 
	or a			;09fb	b7 	. 
	jr z,$+116		;09fc	28 72 	( r 
	jp 0c6a3h		;09fe	c3 a3 c6 	. . . 
	ld hl,(0bffah)		;0a01	2a fa bf 	* . . 
	jp (hl)			;0a04	e9 	. 
	add a,a			;0a05	87 	. 
	ld hl,0ca12h		;0a06	21 12 ca 	! . . 
	ld d,000h		;0a09	16 00 	. . 
	ld e,a			;0a0b	5f 	_ 
	add hl,de			;0a0c	19 	. 
	ld e,(hl)			;0a0d	5e 	^ 
	inc hl			;0a0e	23 	# 
	ld d,(hl)			;0a0f	56 	V 
	ex de,hl			;0a10	eb 	. 
	jp (hl)			;0a11	e9 	. 
	ld b,d			;0a12	42 	B 
	call 0cd46h		;0a13	cd 46 cd 	. F . 
	ld a,d			;0a16	7a 	z 
	jp z,0ca7ah		;0a17	ca 7a ca 	. z . 
	ld a,d			;0a1a	7a 	z 
	jp z,0ca7ch		;0a1b	ca 7c ca 	. | . 
	cp a			;0a1e	bf 	. 
	ret			;0a1f	c9 	. 
	ld a,a			;0a20	7f 	 
	call z,0ca7ah		;0a21	cc 7a ca 	. z . 
	call nc,0f2cah		;0a24	d4 ca f2 	. . . 
	jp z,0cb1ch		;0a27	ca 1c cb 	. . . 
	ld l,d			;0a2a	6a 	j 
	res 3,a		;0a2b	cb 9f 	. . 
	res 7,e		;0a2d	cb bb 	. . 
	bit 7,h		;0a2f	cb 7c 	. | 
	jp z,0c875h		;0a31	ca 75 c8 	. u . 
	xor h			;0a34	ac 	. 
	ret z			;0a35	c8 	. 
	ld a,d			;0a36	7a 	z 
	jp z,0c942h		;0a37	ca 42 c9 	. B . 
	ld b,d			;0a3a	42 	B 
	ret			;0a3b	c9 	. 
	ld b,d			;0a3c	42 	B 
	ret			;0a3d	c9 	. 
	ld b,d			;0a3e	42 	B 
	ret			;0a3f	c9 	. 
	sub l			;0a40	95 	. 
	ret			;0a41	c9 	. 
	sbc a,h			;0a42	9c 	. 
	ret			;0a43	c9 	. 
	and e			;0a44	a3 	. 
	ret			;0a45	c9 	. 
	xor d			;0a46	aa 	. 
	ret			;0a47	c9 	. 
	or c			;0a48	b1 	. 
	ret			;0a49	c9 	. 
	cp b			;0a4a	b8 	. 
	ret			;0a4b	c9 	. 
	ld b,l			;0a4c	45 	E 
	call z,0ca7ah		;0a4d	cc 7a ca 	. z . 
	xor e			;0a50	ab 	. 
	call z,0ccdfh		;0a51	cc df cc 	. . . 
	ld a,d			;0a54	7a 	z 
	jp z,0cbdah		;0a55	ca da cb 	. . . 
	inc b			;0a58	04 	. 
	call z,0cc1bh		;0a59	cc 1b cc 	. . . 
	inc sp			;0a5c	33 	3 
	call z,0c9bfh		;0a5d	cc bf c9 	. . . 
	set 1,c		;0a60	cb c9 	. . 
	rst 10h			;0a62	d7 	. 
	ret			;0a63	c9 	. 
	cp a			;0a64	bf 	. 
	ret			;0a65	c9 	. 
	ld a,a			;0a66	7f 	 
	call z,0c8dfh		;0a67	cc df c8 	. . . 
	call m,095c8h		;0a6a	fc c8 95 	. . . 
	call z,0cd27h		;0a6d	cc 27 cd 	. ' . 
	xor a			;0a70	af 	. 
	ld (0ffd8h),a		;0a71	32 d8 ff 	2 . . 
	ld (0ffd9h),a		;0a74	32 d9 ff 	2 . . 
	jp 0c6a3h		;0a77	c3 a3 c6 	. . . 
	xor a			;0a7a	af 	. 
	ret			;0a7b	c9 	. 
	call 0cdd7h		;0a7c	cd d7 cd 	. . . 
	cp 001h		;0a7f	fe 01 	. . 
	jr nz,$+11		;0a81	20 09 	  . 
	ld a,c			;0a83	79 	y 
	cp 031h		;0a84	fe 31 	. 1 
	jr c,$+42		;0a86	38 28 	8 ( 
	cp 036h		;0a88	fe 36 	. 6 
	jr nc,$+38		;0a8a	30 24 	0 $ 
	call 0cab5h		;0a8c	cd b5 ca 	. . . 
	or a			;0a8f	b7 	. 
	ret nz			;0a90	c0 	. 
	ld a,(0ffdah)		;0a91	3a da ff 	: . . 
	and 00fh		;0a94	e6 0f 	. . 
	dec a			;0a96	3d 	= 
	add a,a			;0a97	87 	. 
	ld b,a			;0a98	47 	G 
	add a,a			;0a99	87 	. 
	ld c,a			;0a9a	4f 	O 
	add a,a			;0a9b	87 	. 
	add a,b			;0a9c	80 	. 
	add a,c			;0a9d	81 	. 
	add a,004h		;0a9e	c6 04 	. . 
	ld hl,(0bff4h)		;0aa0	2a f4 bf 	* . . 
	ld d,000h		;0aa3	16 00 	. . 
	ld e,a			;0aa5	5f 	_ 
	add hl,de			;0aa6	19 	. 
	ex de,hl			;0aa7	eb 	. 
	ld hl,0ffdbh		;0aa8	21 db ff 	! . . 
	ld bc,00009h		;0aab	01 09 00 	. . . 
	ldir		;0aae	ed b0 	. . 
	call 0cd51h		;0ab0	cd 51 cd 	. Q . 
	xor a			;0ab3	af 	. 
	ret			;0ab4	c9 	. 
	call 0c901h		;0ab5	cd 01 c9 	. . . 
	ld (hl),c			;0ab8	71 	q 
	cp 00ah		;0ab9	fe 0a 	. . 
	ret nz			;0abb	c0 	. 
	ld hl,0ffdbh		;0abc	21 db ff 	! . . 
	ld b,008h		;0abf	06 08 	. . 
	ld a,(hl)			;0ac1	7e 	~ 
	inc hl			;0ac2	23 	# 
	cp 07fh		;0ac3	fe 7f 	.  
	jr z,$+8		;0ac5	28 06 	( . 
	djnz $-6		;0ac7	10 f8 	. . 
	ld (hl),07fh		;0ac9	36 7f 	6  
	jr $+7		;0acb	18 05 	. . 
	ld hl,0ffe3h		;0acd	21 e3 ff 	! . . 
	ld (hl),020h		;0ad0	36 20 	6   
	xor a			;0ad2	af 	. 
	ret			;0ad3	c9 	. 
	call 0cdd7h		;0ad4	cd d7 cd 	. . . 
	cp 004h		;0ad7	fe 04 	. . 
	jr z,$+6		;0ad9	28 04 	( . 
	call 0c901h		;0adb	cd 01 c9 	. . . 
	ret			;0ade	c9 	. 
	ld a,c			;0adf	79 	y 
	sub 020h		;0ae0	d6 20 	.   
	ld e,a			;0ae2	5f 	_ 
	ld hl,0ffdah		;0ae3	21 da ff 	! . . 
	ld b,(hl)			;0ae6	46 	F 
	inc hl			;0ae7	23 	# 
	ld c,(hl)			;0ae8	4e 	N 
	inc hl			;0ae9	23 	# 
	ld d,(hl)			;0aea	56 	V 
	ld a,001h		;0aeb	3e 01 	> . 
	call 0c91dh		;0aed	cd 1d c9 	. . . 
	xor a			;0af0	af 	. 
	ret			;0af1	c9 	. 
	call 0cdd7h		;0af2	cd d7 cd 	. . . 
	cp 002h		;0af5	fe 02 	. . 
	jr z,$+6		;0af7	28 04 	( . 
	call 0c901h		;0af9	cd 01 c9 	. . . 
	ret			;0afc	c9 	. 
	ld a,c			;0afd	79 	y 
	sub 020h		;0afe	d6 20 	.   
	ld e,a			;0b00	5f 	_ 
	ld a,(0ffdah)		;0b01	3a da ff 	: . . 
	ld d,a			;0b04	57 	W 
	ld a,(0ffd3h)		;0b05	3a d3 ff 	: . . 
	and 060h		;0b08	e6 60 	. ` 
	or d			;0b0a	b2 	. 
	ld (0ffd3h),a		;0b0b	32 d3 ff 	2 . . 
	ld c,a			;0b0e	4f 	O 
	ld b,00ah		;0b0f	06 0a 	. . 
	call 0c916h		;0b11	cd 16 c9 	. . . 
	ld c,e			;0b14	4b 	K 
	ld b,00bh		;0b15	06 0b 	. . 
	call 0c916h		;0b17	cd 16 c9 	. . . 
	xor a			;0b1a	af 	. 
	ret			;0b1b	c9 	. 
	call 0cdd7h		;0b1c	cd d7 cd 	. . . 
	cp 004h		;0b1f	fe 04 	. . 
	jr z,$+6		;0b21	28 04 	( . 
	call 0c901h		;0b23	cd 01 c9 	. . . 
	ret			;0b26	c9 	. 
	ld a,c			;0b27	79 	y 
	sub 020h		;0b28	d6 20 	.   
	ld e,a			;0b2a	5f 	_ 
	ld a,04fh		;0b2b	3e 4f 	> O 
	cp e			;0b2d	bb 	. 
	jr c,$+58		;0b2e	38 38 	8 8 
	ld hl,0ffdah		;0b30	21 da ff 	! . . 
	ld b,(hl)			;0b33	46 	F 
	inc hl			;0b34	23 	# 
	ld a,(hl)			;0b35	7e 	~ 
	cp 018h		;0b36	fe 18 	. . 
	jr nc,$+48		;0b38	30 2e 	0 . 
	ld c,a			;0b3a	4f 	O 
	inc hl			;0b3b	23 	# 
	ld d,(hl)			;0b3c	56 	V 
	ld a,c			;0b3d	79 	y 
	cp b			;0b3e	b8 	. 
	jr c,$+41		;0b3f	38 27 	8 ' 
	ld a,e			;0b41	7b 	{ 
	cp d			;0b42	ba 	. 
	jr c,$+37		;0b43	38 23 	8 # 
	ld hl,0ffcdh		;0b45	21 cd ff 	! . . 
	ld (hl),c			;0b48	71 	q 
	inc hl			;0b49	23 	# 
	ld (hl),b			;0b4a	70 	p 
	inc hl			;0b4b	23 	# 
	ld (hl),e			;0b4c	73 	s 
	inc hl			;0b4d	23 	# 
	ld (hl),d			;0b4e	72 	r 
	ld a,001h		;0b4f	3e 01 	> . 
	ld (0ffc9h),a		;0b51	32 c9 ff 	2 . . 
	ld a,050h		;0b54	3e 50 	> P 
	sub e			;0b56	93 	. 
	ld e,a			;0b57	5f 	_ 
	ld a,d			;0b58	7a 	z 
	add a,e			;0b59	83 	. 
	ld hl,0ffd1h		;0b5a	21 d1 ff 	! . . 
	bit 3,(hl)		;0b5d	cb 5e 	. ^ 
	jr z,$+3		;0b5f	28 01 	( . 
	add a,a			;0b61	87 	. 
	ld (0ffc8h),a		;0b62	32 c8 ff 	2 . . 
	call 0cc1bh		;0b65	cd 1b cc 	. . . 
	xor a			;0b68	af 	. 
	ret			;0b69	c9 	. 
	call 0cdd7h		;0b6a	cd d7 cd 	. . . 
	cp 002h		;0b6d	fe 02 	. . 
	jr z,$+6		;0b6f	28 04 	( . 
	call 0c901h		;0b71	cd 01 c9 	. . . 
	ret			;0b74	c9 	. 
	ld a,c			;0b75	79 	y 
	sub 020h		;0b76	d6 20 	.   
	ld c,a			;0b78	4f 	O 
	ld a,04fh		;0b79	3e 4f 	> O 
	cp c			;0b7b	b9 	. 
	jr c,$+33		;0b7c	38 1f 	8 . 
	ld a,(0ffd1h)		;0b7e	3a d1 ff 	: . . 
	bit 3,a		;0b81	cb 5f 	. _ 
	jr z,$+5		;0b83	28 03 	( . 
	ld a,c			;0b85	79 	y 
	add a,a			;0b86	87 	. 
	ld c,a			;0b87	4f 	O 
	ld a,(0ffdah)		;0b88	3a da ff 	: . . 
	cp 019h		;0b8b	fe 19 	. . 
	jr nc,$+16		;0b8d	30 0e 	0 . 
	ld b,a			;0b8f	47 	G 
	ld (0ffcbh),a		;0b90	32 cb ff 	2 . . 
	ld a,c			;0b93	79 	y 
	ld (0ffcah),a		;0b94	32 ca ff 	2 . . 
	call 0c6f1h		;0b97	cd f1 c6 	. . . 
	call 0c71ch		;0b9a	cd 1c c7 	. . . 
	xor a			;0b9d	af 	. 
	ret			;0b9e	c9 	. 
	call 0cdd7h		;0b9f	cd d7 cd 	. . . 
	ld a,c			;0ba2	79 	y 
	sub 020h		;0ba3	d6 20 	.   
	ld c,a			;0ba5	4f 	O 
	ld a,04fh		;0ba6	3e 4f 	> O 
	cp c			;0ba8	b9 	. 
	jr c,$+16		;0ba9	38 0e 	8 . 
	ld a,(0ffcbh)		;0bab	3a cb ff 	: . . 
	ld b,a			;0bae	47 	G 
	ld a,c			;0baf	79 	y 
	ld (0ffcah),a		;0bb0	32 ca ff 	2 . . 
	call 0c6f1h		;0bb3	cd f1 c6 	. . . 
	call 0c71ch		;0bb6	cd 1c c7 	. . . 
	xor a			;0bb9	af 	. 
	ret			;0bba	c9 	. 
	call 0cdd7h		;0bbb	cd d7 cd 	. . . 
	cp 004h		;0bbe	fe 04 	. . 
	jr z,$+6		;0bc0	28 04 	( . 
	call 0c901h		;0bc2	cd 01 c9 	. . . 
	ret			;0bc5	c9 	. 
	ld a,c			;0bc6	79 	y 
	sub 020h		;0bc7	d6 20 	.   
	ld e,a			;0bc9	5f 	_ 
	ld hl,0ffdah		;0bca	21 da ff 	! . . 
	ld b,(hl)			;0bcd	46 	F 
	inc hl			;0bce	23 	# 
	ld c,(hl)			;0bcf	4e 	N 
	inc hl			;0bd0	23 	# 
	ld d,(hl)			;0bd1	56 	V 
	ld a,(0ffd2h)		;0bd2	3a d2 ff 	: . . 
	call 0c91dh		;0bd5	cd 1d c9 	. . . 
	xor a			;0bd8	af 	. 
	ret			;0bd9	c9 	. 
	ld bc,00780h		;0bda	01 80 07 	. . . 
	push ix		;0bdd	dd e5 	. . 
	pop hl			;0bdf	e1 	. 
	call 0c795h		;0be0	cd 95 c7 	. . . 
	ld a,(0ffd2h)		;0be3	3a d2 ff 	: . . 
	ld d,a			;0be6	57 	W 
	ld e,020h		;0be7	1e 20 	.   
	call 0c715h		;0be9	cd 15 c7 	. . . 
	ld a,(hl)			;0bec	7e 	~ 
	and d			;0bed	a2 	. 
	jr nz,$+11		;0bee	20 09 	  . 
	ld (hl),000h		;0bf0	36 00 	6 . 
	call 0c795h		;0bf2	cd 95 c7 	. . . 
	ld (hl),e			;0bf5	73 	s 
	call 0c795h		;0bf6	cd 95 c7 	. . . 
	inc hl			;0bf9	23 	# 
	dec bc			;0bfa	0b 	. 
	ld a,b			;0bfb	78 	x 
	or c			;0bfc	b1 	. 
	jr nz,$-20		;0bfd	20 ea 	  . 
	call 0c79eh		;0bff	cd 9e c7 	. . . 
	xor a			;0c02	af 	. 
	ret			;0c03	c9 	. 
	ld a,(0ffd0h)		;0c04	3a d0 ff 	: . . 
	ld c,a			;0c07	4f 	O 
	ld a,(0ffceh)		;0c08	3a ce ff 	: . . 
	ld b,a			;0c0b	47 	G 
	ld a,(0ffcfh)		;0c0c	3a cf ff 	: . . 
	ld e,a			;0c0f	5f 	_ 
	ld a,(0ffcdh)		;0c10	3a cd ff 	: . . 
	ld d,a			;0c13	57 	W 
	call 0c805h		;0c14	cd 05 c8 	. . . 
	call 0cc1bh		;0c17	cd 1b cc 	. . . 
	ret			;0c1a	c9 	. 
	ld a,(0ffceh)		;0c1b	3a ce ff 	: . . 
	ld b,a			;0c1e	47 	G 
	ld a,(0ffd0h)		;0c1f	3a d0 ff 	: . . 
	ld c,a			;0c22	4f 	O 
	call 0c6f1h		;0c23	cd f1 c6 	. . . 
	call 0c71ch		;0c26	cd 1c c7 	. . . 
	ld a,b			;0c29	78 	x 
	ld (0ffcbh),a		;0c2a	32 cb ff 	2 . . 
	ld a,c			;0c2d	79 	y 
	ld (0ffcah),a		;0c2e	32 ca ff 	2 . . 
	xor a			;0c31	af 	. 
	ret			;0c32	c9 	. 
	call 0c764h		;0c33	cd 64 c7 	. d . 
	ld a,001h		;0c36	3e 01 	> . 
	ld (0ffc8h),a		;0c38	32 c8 ff 	2 . . 
	ld a,04fh		;0c3b	3e 4f 	> O 
	ld (0ffcfh),a		;0c3d	32 cf ff 	2 . . 
	call 0c8bfh		;0c40	cd bf c8 	. . . 
	xor a			;0c43	af 	. 
	ret			;0c44	c9 	. 
	ld b,000h		;0c45	06 00 	. . 
	ld c,000h		;0c47	0e 00 	. . 
	push bc			;0c49	c5 	. 
	call 0cdf4h		;0c4a	cd f4 cd 	. . . 
	ld c,d			;0c4d	4a 	J 
	push de			;0c4e	d5 	. 
	call 0ffa0h		;0c4f	cd a0 ff 	. . . 
	pop de			;0c52	d1 	. 
	pop bc			;0c53	c1 	. 
	bit 3,e		;0c54	cb 5b 	. [ 
	jr z,$+15		;0c56	28 0d 	( . 
	inc c			;0c58	0c 	. 
	ld a,c			;0c59	79 	y 
	cp 050h		;0c5a	fe 50 	. P 
	jr z,$+15		;0c5c	28 0d 	( . 
	push bc			;0c5e	c5 	. 
	ld c,020h		;0c5f	0e 20 	.   
	call 0ffa0h		;0c61	cd a0 ff 	. . . 
	pop bc			;0c64	c1 	. 
	inc c			;0c65	0c 	. 
	ld a,c			;0c66	79 	y 
	cp 050h		;0c67	fe 50 	. P 
	jr nz,$-32		;0c69	20 de 	  . 
	push bc			;0c6b	c5 	. 
	ld c,00dh		;0c6c	0e 0d 	. . 
	call 0ffa0h		;0c6e	cd a0 ff 	. . . 
	ld c,00ah		;0c71	0e 0a 	. . 
	call 0ffa0h		;0c73	cd a0 ff 	. . . 
	pop bc			;0c76	c1 	. 
	inc b			;0c77	04 	. 
	ld a,b			;0c78	78 	x 
	cp 018h		;0c79	fe 18 	. . 
	jr nz,$-52		;0c7b	20 ca 	  . 
	xor a			;0c7d	af 	. 
	ret			;0c7e	c9 	. 
	call 0cdd7h		;0c7f	cd d7 cd 	. . . 
	ld a,c			;0c82	79 	y 
	and 00fh		;0c83	e6 0f 	. . 
	rlca			;0c85	07 	. 
	rlca			;0c86	07 	. 
	rlca			;0c87	07 	. 
	rlca			;0c88	07 	. 
	ld b,a			;0c89	47 	G 
	ld a,(0ffd1h)		;0c8a	3a d1 ff 	: . . 
	and 00fh		;0c8d	e6 0f 	. . 
	or b			;0c8f	b0 	. 
	ld (0ffd1h),a		;0c90	32 d1 ff 	2 . . 
	xor a			;0c93	af 	. 
	ret			;0c94	c9 	. 
	call 0cdd7h		;0c95	cd d7 cd 	. . . 
	ld a,c			;0c98	79 	y 
	cp 030h		;0c99	fe 30 	. 0 
	jr z,$+16		;0c9b	28 0e 	( . 
	cp 031h		;0c9d	fe 31 	. 1 
	jr z,$+30		;0c9f	28 1c 	( . 
	cp 032h		;0ca1	fe 32 	. 2 
	jr z,$+60		;0ca3	28 3a 	( : 
	cp 033h		;0ca5	fe 33 	. 3 
	jr z,$+77		;0ca7	28 4b 	( K 
	xor a			;0ca9	af 	. 
	ret			;0caa	c9 	. 
	ld a,(0ffcbh)		;0cab	3a cb ff 	: . . 
	ld b,a			;0cae	47 	G 
	ld d,a			;0caf	57 	W 
	ld a,(0ffcah)		;0cb0	3a ca ff 	: . . 
	ld c,a			;0cb3	4f 	O 
	ld a,(0ffcfh)		;0cb4	3a cf ff 	: . . 
	ld e,a			;0cb7	5f 	_ 
	call 0c805h		;0cb8	cd 05 c8 	. . . 
	xor a			;0cbb	af 	. 
	ret			;0cbc	c9 	. 
	ld a,(0ffceh)		;0cbd	3a ce ff 	: . . 
	ld b,a			;0cc0	47 	G 
	ld a,(0ffcbh)		;0cc1	3a cb ff 	: . . 
	ld (0ffceh),a		;0cc4	32 ce ff 	2 . . 
	ld a,(0ffc9h)		;0cc7	3a c9 ff 	: . . 
	ld c,a			;0cca	4f 	O 
	ld a,001h		;0ccb	3e 01 	> . 
	ld (0ffc9h),a		;0ccd	32 c9 ff 	2 . . 
	push bc			;0cd0	c5 	. 
	call 0c62eh		;0cd1	cd 2e c6 	. . . 
	pop bc			;0cd4	c1 	. 
	ld a,b			;0cd5	78 	x 
	ld (0ffceh),a		;0cd6	32 ce ff 	2 . . 
	ld a,c			;0cd9	79 	y 
	ld (0ffc9h),a		;0cda	32 c9 ff 	2 . . 
	xor a			;0cdd	af 	. 
	ret			;0cde	c9 	. 
	ld a,(0ffcbh)		;0cdf	3a cb ff 	: . . 
	ld b,a			;0ce2	47 	G 
	ld a,(0ffcah)		;0ce3	3a ca ff 	: . . 
	ld c,a			;0ce6	4f 	O 
	ld a,(0ffcdh)		;0ce7	3a cd ff 	: . . 
	ld d,a			;0cea	57 	W 
	ld a,(0ffcfh)		;0ceb	3a cf ff 	: . . 
	ld e,a			;0cee	5f 	_ 
	call 0c805h		;0cef	cd 05 c8 	. . . 
	xor a			;0cf2	af 	. 
	ret			;0cf3	c9 	. 
	ld a,(0ffceh)		;0cf4	3a ce ff 	: . . 
	ld b,a			;0cf7	47 	G 
	ld a,(0ffcbh)		;0cf8	3a cb ff 	: . . 
	ld c,a			;0cfb	4f 	O 
	ld a,(0ffcdh)		;0cfc	3a cd ff 	: . . 
	cp c			;0cff	b9 	. 
	jr z,$+24		;0d00	28 16 	( . 
	ld a,c			;0d02	79 	y 
	ld (0ffceh),a		;0d03	32 ce ff 	2 . . 
	push bc			;0d06	c5 	. 
	call 0c830h		;0d07	cd 30 c8 	. 0 . 
	pop bc			;0d0a	c1 	. 
	ld a,b			;0d0b	78 	x 
	ld (0ffceh),a		;0d0c	32 ce ff 	2 . . 
	ld a,(0ffd0h)		;0d0f	3a d0 ff 	: . . 
	ld c,a			;0d12	4f 	O 
	call 0cb9fh		;0d13	cd 9f cb 	. . . 
	xor a			;0d16	af 	. 
	ret			;0d17	c9 	. 
	ld b,a			;0d18	47 	G 
	ld d,a			;0d19	57 	W 
	ld a,(0ffcfh)		;0d1a	3a cf ff 	: . . 
	ld e,a			;0d1d	5f 	_ 
	ld a,(0ffd0h)		;0d1e	3a d0 ff 	: . . 
	ld c,a			;0d21	4f 	O 
	call 0c805h		;0d22	cd 05 c8 	. . . 
	jr $-22		;0d25	18 e8 	. . 
	call 0cdd7h		;0d27	cd d7 cd 	. . . 
	cp 002h		;0d2a	fe 02 	. . 
	jp nc,0cd8ah		;0d2c	d2 8a cd 	. . . 
	ld a,c			;0d2f	79 	y 
	cp 030h		;0d30	fe 30 	. 0 
	jr z,$+16		;0d32	28 0e 	( . 
	cp 031h		;0d34	fe 31 	. 1 
	jr z,$+16		;0d36	28 0e 	( . 
	cp 034h		;0d38	fe 34 	. 4 
	jr z,$+23		;0d3a	28 15 	( . 
	cp 035h		;0d3c	fe 35 	. 5 
	jr z,$+76		;0d3e	28 4a 	( J 
	xor a			;0d40	af 	. 
	ret			;0d41	c9 	. 
	ld b,019h		;0d42	06 19 	. . 
	jr $+4		;0d44	18 02 	. . 
	ld b,018h		;0d46	06 18 	. . 
	ld a,006h		;0d48	3e 06 	> . 
	out (0a0h),a		;0d4a	d3 a0 	. . 
	ld a,b			;0d4c	78 	x 
	out (0a1h),a		;0d4d	d3 a1 	. . 
	xor a			;0d4f	af 	. 
	ret			;0d50	c9 	. 
	ld hl,(0bff4h)		;0d51	2a f4 bf 	* . . 
	ex de,hl			;0d54	eb 	. 
	ld b,018h		;0d55	06 18 	. . 
	ld c,000h		;0d57	0e 00 	. . 
	call 0c6f1h		;0d59	cd f1 c6 	. . . 
	ld a,(0bfeah)		;0d5c	3a ea bf 	: . . 
	ld c,a			;0d5f	4f 	O 
	ld b,046h		;0d60	06 46 	. F 
	ld a,b			;0d62	78 	x 
	ld (0ffdah),a		;0d63	32 da ff 	2 . . 
	call 0c715h		;0d66	cd 15 c7 	. . . 
	ld a,(de)			;0d69	1a 	. 
	ld (hl),a			;0d6a	77 	w 
	call 0c795h		;0d6b	cd 95 c7 	. . . 
	ld (hl),c			;0d6e	71 	q 
	call 0c79eh		;0d6f	cd 9e c7 	. . . 
	inc de			;0d72	13 	. 
	inc hl			;0d73	23 	# 
	djnz $-14		;0d74	10 f0 	. . 
	ld a,(0ffdah)		;0d76	3a da ff 	: . . 
	or a			;0d79	b7 	. 
	jr z,$+14		;0d7a	28 0c 	( . 
	ld b,00ah		;0d7c	06 0a 	. . 
	ld a,(0bfebh)		;0d7e	3a eb bf 	: . . 
	ld c,a			;0d81	4f 	O 
	xor a			;0d82	af 	. 
	ld (0ffdah),a		;0d83	32 da ff 	2 . . 
	jr $-32		;0d86	18 de 	. . 
	xor a			;0d88	af 	. 
	ret			;0d89	c9 	. 
	ld a,c			;0d8a	79 	y 
	cp 00dh		;0d8b	fe 0d 	. . 
	jr z,$+40		;0d8d	28 26 	( & 
	ld a,(0ffd9h)		;0d8f	3a d9 ff 	: . . 
	cp 001h		;0d92	fe 01 	. . 
	jr z,$+6		;0d94	28 04 	( . 
	call 0cdb7h		;0d96	cd b7 cd 	. . . 
	ret			;0d99	c9 	. 
	ld b,018h		;0d9a	06 18 	. . 
	ld c,000h		;0d9c	0e 00 	. . 
	call 0c6f1h		;0d9e	cd f1 c6 	. . . 
	ld (0ffdah),hl		;0da1	22 da ff 	" . . 
	ld a,002h		;0da4	3e 02 	> . 
	ld (0ffd9h),a		;0da6	32 d9 ff 	2 . . 
	ld b,046h		;0da9	06 46 	. F 
	ld c,020h		;0dab	0e 20 	.   
	call 0c715h		;0dad	cd 15 c7 	. . . 
	ld (hl),c			;0db0	71 	q 
	inc hl			;0db1	23 	# 
	djnz $-5		;0db2	10 f9 	. . 
	ret			;0db4	c9 	. 
	xor a			;0db5	af 	. 
	ret			;0db6	c9 	. 
	ld b,a			;0db7	47 	G 
	inc a			;0db8	3c 	< 
	ld (0ffd9h),a		;0db9	32 d9 ff 	2 . . 
	ld hl,(0ffdah)		;0dbc	2a da ff 	* . . 
	call 0c715h		;0dbf	cd 15 c7 	. . . 
	ld (hl),c			;0dc2	71 	q 
	ld a,(0bfebh)		;0dc3	3a eb bf 	: . . 
	call 0c795h		;0dc6	cd 95 c7 	. . . 
	ld (hl),a			;0dc9	77 	w 
	call 0c79eh		;0dca	cd 9e c7 	. . . 
	inc hl			;0dcd	23 	# 
	ld (0ffdah),hl		;0dce	22 da ff 	" . . 
	ld a,b			;0dd1	78 	x 
	cp 047h		;0dd2	fe 47 	. G 
	ret nz			;0dd4	c0 	. 
	xor a			;0dd5	af 	. 
	ret			;0dd6	c9 	. 
	ld a,(0ffd9h)		;0dd7	3a d9 ff 	: . . 
	or a			;0dda	b7 	. 
	ret nz			;0ddb	c0 	. 
	inc a			;0ddc	3c 	< 
	ld (0ffd9h),a		;0ddd	32 d9 ff 	2 . . 
	pop hl			;0de0	e1 	. 
	ret			;0de1	c9 	. 
	call 0c69ah		;0de2	cd 9a c6 	. . . 
	call 0c6f1h		;0de5	cd f1 c6 	. . . 
	call 0c715h		;0de8	cd 15 c7 	. . . 
	ld (hl),d			;0deb	72 	r 
	call 0c795h		;0dec	cd 95 c7 	. . . 
	ld (hl),e			;0def	73 	s 
	call 0c79eh		;0df0	cd 9e c7 	. . . 
	ret			;0df3	c9 	. 
	call 0c69ah		;0df4	cd 9a c6 	. . . 
	call 0c6f1h		;0df7	cd f1 c6 	. . . 
	call 0c715h		;0dfa	cd 15 c7 	. . . 
	ld d,(hl)			;0dfd	56 	V 
	call 0c795h		;0dfe	cd 95 c7 	. . . 
	ld e,(hl)			;0e01	5e 	^ 
	call 0c79eh		;0e02	cd 9e c7 	. . . 
	ret			;0e05	c9 	. 
	nop			;0e06	00 	. 
	nop			;0e07	00 	. 
	nop			;0e08	00 	. 
	nop			;0e09	00 	. 
	nop			;0e0a	00 	. 
	nop			;0e0b	00 	. 
	nop			;0e0c	00 	. 
	nop			;0e0d	00 	. 
	nop			;0e0e	00 	. 
	nop			;0e0f	00 	. 
	nop			;0e10	00 	. 
	nop			;0e11	00 	. 
	nop			;0e12	00 	. 
	nop			;0e13	00 	. 
	nop			;0e14	00 	. 
	nop			;0e15	00 	. 
	nop			;0e16	00 	. 
	nop			;0e17	00 	. 
	nop			;0e18	00 	. 
	nop			;0e19	00 	. 
	nop			;0e1a	00 	. 
	nop			;0e1b	00 	. 
	nop			;0e1c	00 	. 
	nop			;0e1d	00 	. 
	nop			;0e1e	00 	. 
	nop			;0e1f	00 	. 
	nop			;0e20	00 	. 
	nop			;0e21	00 	. 
	nop			;0e22	00 	. 
	nop			;0e23	00 	. 
	nop			;0e24	00 	. 
	nop			;0e25	00 	. 
	nop			;0e26	00 	. 
	nop			;0e27	00 	. 
	nop			;0e28	00 	. 
	nop			;0e29	00 	. 
	nop			;0e2a	00 	. 
	nop			;0e2b	00 	. 
	nop			;0e2c	00 	. 
	nop			;0e2d	00 	. 
	nop			;0e2e	00 	. 
	nop			;0e2f	00 	. 
	nop			;0e30	00 	. 
	nop			;0e31	00 	. 
	nop			;0e32	00 	. 
	nop			;0e33	00 	. 
	nop			;0e34	00 	. 
	nop			;0e35	00 	. 
	nop			;0e36	00 	. 
	nop			;0e37	00 	. 
	nop			;0e38	00 	. 
	nop			;0e39	00 	. 
	nop			;0e3a	00 	. 
	nop			;0e3b	00 	. 
	nop			;0e3c	00 	. 
	nop			;0e3d	00 	. 
	nop			;0e3e	00 	. 
	nop			;0e3f	00 	. 
	nop			;0e40	00 	. 
	nop			;0e41	00 	. 
	nop			;0e42	00 	. 
	nop			;0e43	00 	. 
	nop			;0e44	00 	. 
	nop			;0e45	00 	. 
	nop			;0e46	00 	. 
	nop			;0e47	00 	. 
	nop			;0e48	00 	. 
	nop			;0e49	00 	. 
	nop			;0e4a	00 	. 
	nop			;0e4b	00 	. 
	nop			;0e4c	00 	. 
	nop			;0e4d	00 	. 
	nop			;0e4e	00 	. 
	nop			;0e4f	00 	. 
	nop			;0e50	00 	. 
	nop			;0e51	00 	. 
	nop			;0e52	00 	. 
	nop			;0e53	00 	. 
	nop			;0e54	00 	. 
	nop			;0e55	00 	. 
	nop			;0e56	00 	. 
	nop			;0e57	00 	. 
	nop			;0e58	00 	. 
	nop			;0e59	00 	. 
	nop			;0e5a	00 	. 
	nop			;0e5b	00 	. 
	nop			;0e5c	00 	. 
	nop			;0e5d	00 	. 
	nop			;0e5e	00 	. 
	nop			;0e5f	00 	. 
	nop			;0e60	00 	. 
	nop			;0e61	00 	. 
	nop			;0e62	00 	. 
	nop			;0e63	00 	. 
	nop			;0e64	00 	. 
	nop			;0e65	00 	. 
	nop			;0e66	00 	. 
	nop			;0e67	00 	. 
	nop			;0e68	00 	. 
	nop			;0e69	00 	. 
	nop			;0e6a	00 	. 
	nop			;0e6b	00 	. 
	nop			;0e6c	00 	. 
	nop			;0e6d	00 	. 
	nop			;0e6e	00 	. 
	nop			;0e6f	00 	. 
	nop			;0e70	00 	. 
	nop			;0e71	00 	. 
	nop			;0e72	00 	. 
	nop			;0e73	00 	. 
	nop			;0e74	00 	. 
	nop			;0e75	00 	. 
	nop			;0e76	00 	. 
	nop			;0e77	00 	. 
	nop			;0e78	00 	. 
	nop			;0e79	00 	. 
	nop			;0e7a	00 	. 
	nop			;0e7b	00 	. 
	nop			;0e7c	00 	. 
	nop			;0e7d	00 	. 
	nop			;0e7e	00 	. 
	nop			;0e7f	00 	. 
	nop			;0e80	00 	. 
	nop			;0e81	00 	. 
	nop			;0e82	00 	. 
	nop			;0e83	00 	. 
	nop			;0e84	00 	. 
	nop			;0e85	00 	. 
	nop			;0e86	00 	. 
	nop			;0e87	00 	. 
	nop			;0e88	00 	. 
	nop			;0e89	00 	. 
	nop			;0e8a	00 	. 
	nop			;0e8b	00 	. 
	nop			;0e8c	00 	. 
	nop			;0e8d	00 	. 
	nop			;0e8e	00 	. 
	nop			;0e8f	00 	. 
	nop			;0e90	00 	. 
	nop			;0e91	00 	. 
	nop			;0e92	00 	. 
	nop			;0e93	00 	. 
	nop			;0e94	00 	. 
	nop			;0e95	00 	. 
	nop			;0e96	00 	. 
	nop			;0e97	00 	. 
	nop			;0e98	00 	. 
	nop			;0e99	00 	. 
	nop			;0e9a	00 	. 
	nop			;0e9b	00 	. 
	nop			;0e9c	00 	. 
	nop			;0e9d	00 	. 
	nop			;0e9e	00 	. 
	nop			;0e9f	00 	. 
	nop			;0ea0	00 	. 
	nop			;0ea1	00 	. 
	nop			;0ea2	00 	. 
	nop			;0ea3	00 	. 
	nop			;0ea4	00 	. 
	nop			;0ea5	00 	. 
	nop			;0ea6	00 	. 
	nop			;0ea7	00 	. 
	nop			;0ea8	00 	. 
	nop			;0ea9	00 	. 
	nop			;0eaa	00 	. 
	nop			;0eab	00 	. 
	nop			;0eac	00 	. 
	nop			;0ead	00 	. 
	nop			;0eae	00 	. 
	nop			;0eaf	00 	. 
	nop			;0eb0	00 	. 
	nop			;0eb1	00 	. 
	nop			;0eb2	00 	. 
	nop			;0eb3	00 	. 
	nop			;0eb4	00 	. 
	nop			;0eb5	00 	. 
	nop			;0eb6	00 	. 
	nop			;0eb7	00 	. 
	nop			;0eb8	00 	. 
	nop			;0eb9	00 	. 
	nop			;0eba	00 	. 
	nop			;0ebb	00 	. 
	nop			;0ebc	00 	. 
	nop			;0ebd	00 	. 
	nop			;0ebe	00 	. 
	nop			;0ebf	00 	. 
	nop			;0ec0	00 	. 
	nop			;0ec1	00 	. 
	nop			;0ec2	00 	. 
	nop			;0ec3	00 	. 
	nop			;0ec4	00 	. 
	nop			;0ec5	00 	. 
	nop			;0ec6	00 	. 
	nop			;0ec7	00 	. 
	nop			;0ec8	00 	. 
	nop			;0ec9	00 	. 
	nop			;0eca	00 	. 
	nop			;0ecb	00 	. 
	nop			;0ecc	00 	. 
	nop			;0ecd	00 	. 
	nop			;0ece	00 	. 
	nop			;0ecf	00 	. 
	nop			;0ed0	00 	. 
	nop			;0ed1	00 	. 
	nop			;0ed2	00 	. 
	nop			;0ed3	00 	. 
	nop			;0ed4	00 	. 
	nop			;0ed5	00 	. 
	nop			;0ed6	00 	. 
	nop			;0ed7	00 	. 
	nop			;0ed8	00 	. 
	nop			;0ed9	00 	. 
	nop			;0eda	00 	. 
	nop			;0edb	00 	. 
	nop			;0edc	00 	. 
	nop			;0edd	00 	. 
	nop			;0ede	00 	. 
	nop			;0edf	00 	. 
	nop			;0ee0	00 	. 
	nop			;0ee1	00 	. 
	nop			;0ee2	00 	. 
	nop			;0ee3	00 	. 
	nop			;0ee4	00 	. 
	nop			;0ee5	00 	. 
	nop			;0ee6	00 	. 
	nop			;0ee7	00 	. 
	nop			;0ee8	00 	. 
	nop			;0ee9	00 	. 
	nop			;0eea	00 	. 
	nop			;0eeb	00 	. 
	nop			;0eec	00 	. 
	nop			;0eed	00 	. 
	nop			;0eee	00 	. 
	nop			;0eef	00 	. 
	nop			;0ef0	00 	. 
	nop			;0ef1	00 	. 
	nop			;0ef2	00 	. 
	nop			;0ef3	00 	. 
	nop			;0ef4	00 	. 
	nop			;0ef5	00 	. 
	nop			;0ef6	00 	. 
	nop			;0ef7	00 	. 
	nop			;0ef8	00 	. 
	nop			;0ef9	00 	. 
	nop			;0efa	00 	. 
	nop			;0efb	00 	. 
	nop			;0efc	00 	. 
	nop			;0efd	00 	. 
	nop			;0efe	00 	. 
	nop			;0eff	00 	. 
	nop			;0f00	00 	. 
	nop			;0f01	00 	. 
	nop			;0f02	00 	. 
	nop			;0f03	00 	. 
	nop			;0f04	00 	. 
	nop			;0f05	00 	. 
	nop			;0f06	00 	. 
	nop			;0f07	00 	. 
	nop			;0f08	00 	. 
	nop			;0f09	00 	. 
	nop			;0f0a	00 	. 
	nop			;0f0b	00 	. 
	nop			;0f0c	00 	. 
	nop			;0f0d	00 	. 
	nop			;0f0e	00 	. 
	nop			;0f0f	00 	. 
	nop			;0f10	00 	. 
	nop			;0f11	00 	. 
	nop			;0f12	00 	. 
	nop			;0f13	00 	. 
	nop			;0f14	00 	. 
	nop			;0f15	00 	. 
	nop			;0f16	00 	. 
	nop			;0f17	00 	. 
	nop			;0f18	00 	. 
	nop			;0f19	00 	. 
	nop			;0f1a	00 	. 
	nop			;0f1b	00 	. 
	nop			;0f1c	00 	. 
	nop			;0f1d	00 	. 
	nop			;0f1e	00 	. 
	nop			;0f1f	00 	. 
	nop			;0f20	00 	. 
	nop			;0f21	00 	. 
	nop			;0f22	00 	. 
	nop			;0f23	00 	. 
	nop			;0f24	00 	. 
	nop			;0f25	00 	. 
	nop			;0f26	00 	. 
	nop			;0f27	00 	. 
	nop			;0f28	00 	. 
	nop			;0f29	00 	. 
	nop			;0f2a	00 	. 
	nop			;0f2b	00 	. 
	nop			;0f2c	00 	. 
	nop			;0f2d	00 	. 
	nop			;0f2e	00 	. 
	nop			;0f2f	00 	. 
	nop			;0f30	00 	. 
	nop			;0f31	00 	. 
	nop			;0f32	00 	. 
	nop			;0f33	00 	. 
	nop			;0f34	00 	. 
	nop			;0f35	00 	. 
	nop			;0f36	00 	. 
	nop			;0f37	00 	. 
	nop			;0f38	00 	. 
	nop			;0f39	00 	. 
	nop			;0f3a	00 	. 
	nop			;0f3b	00 	. 
	nop			;0f3c	00 	. 
	nop			;0f3d	00 	. 
	nop			;0f3e	00 	. 
	nop			;0f3f	00 	. 
	nop			;0f40	00 	. 
	nop			;0f41	00 	. 
	nop			;0f42	00 	. 
	nop			;0f43	00 	. 
	nop			;0f44	00 	. 
	nop			;0f45	00 	. 
	nop			;0f46	00 	. 
	nop			;0f47	00 	. 
	nop			;0f48	00 	. 
	nop			;0f49	00 	. 
	nop			;0f4a	00 	. 
	nop			;0f4b	00 	. 
	nop			;0f4c	00 	. 
	nop			;0f4d	00 	. 
	nop			;0f4e	00 	. 
	nop			;0f4f	00 	. 
	nop			;0f50	00 	. 
	nop			;0f51	00 	. 
	nop			;0f52	00 	. 
	nop			;0f53	00 	. 
	nop			;0f54	00 	. 
	nop			;0f55	00 	. 
	nop			;0f56	00 	. 
	nop			;0f57	00 	. 
	nop			;0f58	00 	. 
	nop			;0f59	00 	. 
	nop			;0f5a	00 	. 
	nop			;0f5b	00 	. 
	nop			;0f5c	00 	. 
	nop			;0f5d	00 	. 
	nop			;0f5e	00 	. 
	nop			;0f5f	00 	. 
	nop			;0f60	00 	. 
	nop			;0f61	00 	. 
	nop			;0f62	00 	. 
	nop			;0f63	00 	. 
	nop			;0f64	00 	. 
	nop			;0f65	00 	. 
	nop			;0f66	00 	. 
	nop			;0f67	00 	. 
	nop			;0f68	00 	. 
	nop			;0f69	00 	. 
	nop			;0f6a	00 	. 
	nop			;0f6b	00 	. 
	nop			;0f6c	00 	. 
	nop			;0f6d	00 	. 
	nop			;0f6e	00 	. 
	nop			;0f6f	00 	. 
	nop			;0f70	00 	. 
	nop			;0f71	00 	. 
	nop			;0f72	00 	. 
	nop			;0f73	00 	. 
	nop			;0f74	00 	. 
	nop			;0f75	00 	. 
	nop			;0f76	00 	. 
	nop			;0f77	00 	. 
	nop			;0f78	00 	. 
	nop			;0f79	00 	. 
	nop			;0f7a	00 	. 
	nop			;0f7b	00 	. 
	nop			;0f7c	00 	. 
	nop			;0f7d	00 	. 
	nop			;0f7e	00 	. 
	nop			;0f7f	00 	. 
	nop			;0f80	00 	. 
	nop			;0f81	00 	. 
	nop			;0f82	00 	. 
	nop			;0f83	00 	. 
	nop			;0f84	00 	. 
	nop			;0f85	00 	. 
	nop			;0f86	00 	. 
	nop			;0f87	00 	. 
	nop			;0f88	00 	. 
	nop			;0f89	00 	. 
	nop			;0f8a	00 	. 
	nop			;0f8b	00 	. 
	nop			;0f8c	00 	. 
	nop			;0f8d	00 	. 
	nop			;0f8e	00 	. 
	nop			;0f8f	00 	. 
	nop			;0f90	00 	. 
	nop			;0f91	00 	. 
	nop			;0f92	00 	. 
	nop			;0f93	00 	. 
	nop			;0f94	00 	. 
	nop			;0f95	00 	. 
	nop			;0f96	00 	. 
	nop			;0f97	00 	. 
	nop			;0f98	00 	. 
	nop			;0f99	00 	. 
	nop			;0f9a	00 	. 
	nop			;0f9b	00 	. 
	nop			;0f9c	00 	. 
	nop			;0f9d	00 	. 
	nop			;0f9e	00 	. 
	nop			;0f9f	00 	. 
	nop			;0fa0	00 	. 
	nop			;0fa1	00 	. 
	nop			;0fa2	00 	. 
	nop			;0fa3	00 	. 
	nop			;0fa4	00 	. 
	nop			;0fa5	00 	. 
	nop			;0fa6	00 	. 
	nop			;0fa7	00 	. 
	nop			;0fa8	00 	. 
	nop			;0fa9	00 	. 
	nop			;0faa	00 	. 
	nop			;0fab	00 	. 
	nop			;0fac	00 	. 
	nop			;0fad	00 	. 
	nop			;0fae	00 	. 
	nop			;0faf	00 	. 
	nop			;0fb0	00 	. 
	nop			;0fb1	00 	. 
	nop			;0fb2	00 	. 
	nop			;0fb3	00 	. 
	nop			;0fb4	00 	. 
	nop			;0fb5	00 	. 
	nop			;0fb6	00 	. 
	nop			;0fb7	00 	. 
	nop			;0fb8	00 	. 
	nop			;0fb9	00 	. 
	nop			;0fba	00 	. 
	nop			;0fbb	00 	. 
	nop			;0fbc	00 	. 
	nop			;0fbd	00 	. 
	nop			;0fbe	00 	. 
	nop			;0fbf	00 	. 
	nop			;0fc0	00 	. 
	nop			;0fc1	00 	. 
	nop			;0fc2	00 	. 
	nop			;0fc3	00 	. 
	nop			;0fc4	00 	. 
	nop			;0fc5	00 	. 
	nop			;0fc6	00 	. 
	nop			;0fc7	00 	. 
	nop			;0fc8	00 	. 
	nop			;0fc9	00 	. 
	nop			;0fca	00 	. 
	nop			;0fcb	00 	. 
	nop			;0fcc	00 	. 
	nop			;0fcd	00 	. 
	nop			;0fce	00 	. 
	nop			;0fcf	00 	. 
	nop			;0fd0	00 	. 
	nop			;0fd1	00 	. 
	nop			;0fd2	00 	. 
	nop			;0fd3	00 	. 
	nop			;0fd4	00 	. 
	nop			;0fd5	00 	. 
	nop			;0fd6	00 	. 
	nop			;0fd7	00 	. 
	nop			;0fd8	00 	. 
	nop			;0fd9	00 	. 
	nop			;0fda	00 	. 
	nop			;0fdb	00 	. 
	nop			;0fdc	00 	. 
	nop			;0fdd	00 	. 
	nop			;0fde	00 	. 
	nop			;0fdf	00 	. 
	nop			;0fe0	00 	. 
	nop			;0fe1	00 	. 
	nop			;0fe2	00 	. 
	nop			;0fe3	00 	. 
	nop			;0fe4	00 	. 
	nop			;0fe5	00 	. 
	nop			;0fe6	00 	. 
	nop			;0fe7	00 	. 
	nop			;0fe8	00 	. 
	nop			;0fe9	00 	. 
	nop			;0fea	00 	. 
	nop			;0feb	00 	. 
	nop			;0fec	00 	. 
	nop			;0fed	00 	. 
	nop			;0fee	00 	. 
	nop			;0fef	00 	. 
	nop			;0ff0	00 	. 
	nop			;0ff1	00 	. 
	nop			;0ff2	00 	. 
	nop			;0ff3	00 	. 
	nop			;0ff4	00 	. 
	nop			;0ff5	00 	. 
	nop			;0ff6	00 	. 
	nop			;0ff7	00 	. 
	nop			;0ff8	00 	. 
	nop			;0ff9	00 	. 
	nop			;0ffa	00 	. 
	nop			;0ffb	00 	. 
	ld sp,0302eh		;0ffc	31 2e 30 	1 . 0 
	ld sp,030c3h		;0fff	31 c3 30 	1 . 0 
	ret nz			;1002	c0 	. 
	jp 0c027h		;1003	c3 27 c0 	. ' . 
	jp 0c027h		;1006	c3 27 c0 	. ' . 
	jp 0c45eh		;1009	c3 5e c4 	. ^ . 
	jp 0c027h		;100c	c3 27 c0 	. ' . 
	jp 0c027h		;100f	c3 27 c0 	. ' . 
	jp 0c027h		;1012	c3 27 c0 	. ' . 
	jp 0c027h		;1015	c3 27 c0 	. ' . 
	jp 0c19dh		;1018	c3 9d c1 	. . . 
	jp 0c18fh		;101b	c3 8f c1 	. . . 
	jp 0c174h		;101e	c3 74 c1 	. t . 
	jp 0cde2h		;1021	c3 e2 cd 	. . . 
	jp 0cdf4h		;1024	c3 f4 cd 	. . . 
	di			;1027	f3 	. 
	ld a,010h		;1028	3e 10 	> . 
	out (0b1h),a		;102a	d3 b1 	. . 
	out (0b3h),a		;102c	d3 b3 	. . 
	jr $+18		;102e	18 10 	. . 
	ld a,089h		;1030	3e 89 	> . 
	out (083h),a		;1032	d3 83 	. . 
	di			;1034	f3 	. 
	ld a,010h		;1035	3e 10 	> . 
	out (081h),a		;1037	d3 81 	. . 
	ld h,07dh		;1039	26 7d 	& } 
	dec hl			;103b	2b 	+ 
	ld a,h			;103c	7c 	| 
	or l			;103d	b5 	. 
	jr nz,$-3		;103e	20 fb 	  . 
	ld sp,00080h		;1040	31 80 00 	1 . . 
	call 0c0c2h		;1043	cd c2 c0 	. . . 
	call 0c6afh		;1046	cd af c6 	. . . 
	call 0c14eh		;1049	cd 4e c1 	. N . 
	ld a,012h		;104c	3e 12 	> . 
	out (0b2h),a		;104e	d3 b2 	. . 
	in a,(0b3h)		;1050	db b3 	. . 
	bit 0,a		;1052	cb 47 	. G 
	jr z,$-4		;1054	28 fa 	( . 
	in a,(0b2h)		;1056	db b2 	. . 
	out (0dah),a		;1058	d3 da 	. . 
	ld c,056h		;105a	0e 56 	. V 
	call 0c45eh		;105c	cd 5e c4 	. ^ . 
	ld hl,0cffch		;105f	21 fc cf 	! . . 
	ld b,004h		;1062	06 04 	. . 
	ld c,(hl)			;1064	4e 	N 
	inc hl			;1065	23 	# 
	call 0c45eh		;1066	cd 5e c4 	. ^ . 
	djnz $-5		;1069	10 f9 	. . 
	call 0c0a7h		;106b	cd a7 c0 	. . . 
	ld a,b			;106e	78 	x 
	cp 04dh		;106f	fe 4d 	. M 
	jr z,$+23		;1071	28 15 	( . 
	cp 05ch		;1073	fe 5c 	. \ 
	jr nz,$-10		;1075	20 f4 	  . 
	ld a,(08000h)		;1077	3a 00 80 	: . . 
	cpl			;107a	2f 	/ 
	ld (08000h),a		;107b	32 00 80 	2 . . 
	ld a,(08000h)		;107e	3a 00 80 	: . . 
	cp 0c3h		;1081	fe c3 	. . 
	jr nz,$-92		;1083	20 a2 	  . 
	jp 08000h		;1085	c3 00 80 	. . . 
	ld de,00000h		;1088	11 00 00 	. . . 
	ld bc,04000h		;108b	01 00 40 	. . @ 
	ld hl,00080h		;108e	21 80 00 	! . . 
	ld a,001h		;1091	3e 01 	> . 
	call 0c19dh		;1093	cd 9d c1 	. . . 
	cp 0ffh		;1096	fe ff 	. . 
	jr nz,$+6		;1098	20 04 	  . 
	out (0dah),a		;109a	d3 da 	. . 
	jr $-20		;109c	18 ea 	. . 
	ld a,006h		;109e	3e 06 	> . 
	out (0b2h),a		;10a0	d3 b2 	. . 
	out (0dah),a		;10a2	d3 da 	. . 
	jp 00080h		;10a4	c3 80 00 	. . . 
	in a,(0b3h)		;10a7	db b3 	. . 
	bit 0,a		;10a9	cb 47 	. G 
	jr z,$-4		;10ab	28 fa 	( . 
	in a,(0b2h)		;10ad	db b2 	. . 
	ld b,a			;10af	47 	G 
	bit 7,a		;10b0	cb 7f 	.  
	jr nz,$-11		;10b2	20 f3 	  . 
	in a,(0b3h)		;10b4	db b3 	. . 
	bit 0,a		;10b6	cb 47 	. G 
	jr z,$-4		;10b8	28 fa 	( . 
	in a,(0b2h)		;10ba	db b2 	. . 
	ld c,a			;10bc	4f 	O 
	bit 7,a		;10bd	cb 7f 	.  
	jr z,$-11		;10bf	28 f3 	( . 
	ret			;10c1	c9 	. 
	im 2		;10c2	ed 5e 	. ^ 
	call 0c0d1h		;10c4	cd d1 c0 	. . . 
	call 0c43fh		;10c7	cd 3f c4 	. ? . 
	call 0c108h		;10ca	cd 08 c1 	. . . 
	call 0c88dh		;10cd	cd 8d c8 	. . . 
	ret			;10d0	c9 	. 
	ld hl,0c0f1h		;10d1	21 f1 c0 	! . . 
	ld a,(hl)			;10d4	7e 	~ 
	inc hl			;10d5	23 	# 
	cp 0ffh		;10d6	fe ff 	. . 
	jr z,$+9		;10d8	28 07 	( . 
	ld c,a			;10da	4f 	O 
	ld a,(hl)			;10db	7e 	~ 
	inc hl			;10dc	23 	# 
	out (c),a		;10dd	ed 79 	. y 
	jr $-11		;10df	18 f3 	. . 
	in a,(0d6h)		;10e1	db d6 	. . 
	and 007h		;10e3	e6 07 	. . 
	ld d,000h		;10e5	16 00 	. . 
	ld e,a			;10e7	5f 	_ 
	add hl,de			;10e8	19 	. 
	ld a,(hl)			;10e9	7e 	~ 
	out (0e1h),a		;10ea	d3 e1 	. . 
	ld a,041h		;10ec	3e 41 	> A 
	out (0e1h),a		;10ee	d3 e1 	. . 
	ret			;10f0	c9 	. 
	jp po,0e205h		;10f1	e2 05 e2 	. . . 
	djnz $-28		;10f4	10 e2 	. . 
	ld b,c			;10f6	41 	A 
	ex (sp),hl			;10f7	e3 	. 
	dec b			;10f8	05 	. 
	ex (sp),hl			;10f9	e3 	. 
	ld bc,041e3h		;10fa	01 e3 41 	. . A 
	pop hl			;10fd	e1 	. 
	dec b			;10fe	05 	. 
	rst 38h			;10ff	ff 	. 
	xor (hl)			;1100	ae 	. 
	ld b,b			;1101	40 	@ 
	jr nz,$+18		;1102	20 10 	  . 
	ex af,af'			;1104	08 	. 
	inc b			;1105	04 	. 
	ld (bc),a			;1106	02 	. 
	ld bc,03421h		;1107	01 21 34 	. ! 4 
	pop bc			;110a	c1 	. 
	ld a,(hl)			;110b	7e 	~ 
	inc hl			;110c	23 	# 
	cp 0ffh		;110d	fe ff 	. . 
	jr z,$+10		;110f	28 08 	( . 
	out (0b1h),a		;1111	d3 b1 	. . 
	ld a,(hl)			;1113	7e 	~ 
	out (0b1h),a		;1114	d3 b1 	. . 
	inc hl			;1116	23 	# 
	jr $-12		;1117	18 f2 	. . 
	ld a,(hl)			;1119	7e 	~ 
	cp 0ffh		;111a	fe ff 	. . 
	jr z,$+11		;111c	28 09 	( . 
	out (0b3h),a		;111e	d3 b3 	. . 
	inc hl			;1120	23 	# 
	ld a,(hl)			;1121	7e 	~ 
	out (0b3h),a		;1122	d3 b3 	. . 
	inc hl			;1124	23 	# 
	jr $-12		;1125	18 f2 	. . 
	in a,(0b0h)		;1127	db b0 	. . 
	in a,(0b2h)		;1129	db b2 	. . 
	in a,(0b0h)		;112b	db b0 	. . 
	in a,(0b2h)		;112d	db b2 	. . 
	in a,(0b0h)		;112f	db b0 	. . 
	in a,(0b2h)		;1131	db b2 	. . 
	ret			;1133	c9 	. 
	nop			;1134	00 	. 
	djnz $+2		;1135	10 00 	. . 
	djnz $+6		;1137	10 04 	. . 
	ld b,h			;1139	44 	D 
	ld bc,00300h		;113a	01 00 03 	. . . 
	pop bc			;113d	c1 	. 
	dec b			;113e	05 	. 
	jp pe,000ffh		;113f	ea ff 00 	. . . 
	djnz $+2		;1142	10 00 	. . 
	djnz $+6		;1144	10 04 	. . 
	ld b,h			;1146	44 	D 
	ld bc,00300h		;1147	01 00 03 	. . . 
	pop bc			;114a	c1 	. 
	dec b			;114b	05 	. 
	jp pe,021ffh		;114c	ea ff 21 	. . ! 
	ld h,l			;114f	65 	e 
	pop bc			;1150	c1 	. 
	ld de,00010h		;1151	11 10 00 	. . . 
	ld bc,0000fh		;1154	01 0f 00 	. . . 
	ldir		;1157	ed b0 	. . 
	ld hl,00000h		;1159	21 00 00 	! . . 
	ld de,00000h		;115c	11 00 00 	. . . 
	ld bc,00000h		;115f	01 00 00 	. . . 
	jp 00010h		;1162	c3 10 00 	. . . 
	in a,(081h)		;1165	db 81 	. . 
	set 0,a		;1167	cb c7 	. . 
	out (081h),a		;1169	d3 81 	. . 
	ldir		;116b	ed b0 	. . 
	res 0,a		;116d	cb 87 	. . 
	out (081h),a		;116f	d3 81 	. . 
	out (0deh),a		;1171	d3 de 	. . 
	ret			;1173	c9 	. 
	push af			;1174	f5 	. 
	rrca			;1175	0f 	. 
	rrca			;1176	0f 	. 
	rrca			;1177	0f 	. 
	rrca			;1178	0f 	. 
	and 00fh		;1179	e6 0f 	. . 
	call 0c181h		;117b	cd 81 c1 	. . . 
	pop af			;117e	f1 	. 
	and 00fh		;117f	e6 0f 	. . 
	call 0c187h		;1181	cd 87 c1 	. . . 
	jp 0c45eh		;1184	c3 5e c4 	. ^ . 
	add a,090h		;1187	c6 90 	. . 
	daa			;1189	27 	' 
	adc a,040h		;118a	ce 40 	. @ 
	daa			;118c	27 	' 
	ld c,a			;118d	4f 	O 
	ret			;118e	c9 	. 
	ex (sp),hl			;118f	e3 	. 
	ld a,(hl)			;1190	7e 	~ 
	inc hl			;1191	23 	# 
	or a			;1192	b7 	. 
	jr z,$+8		;1193	28 06 	( . 
	ld c,a			;1195	4f 	O 
	call 0c45eh		;1196	cd 5e c4 	. ^ . 
	jr $-9		;1199	18 f5 	. . 
	ex (sp),hl			;119b	e3 	. 
	ret			;119c	c9 	. 
	push bc			;119d	c5 	. 
	push de			;119e	d5 	. 
	push hl			;119f	e5 	. 
	ld (0ffb8h),a		;11a0	32 b8 ff 	2 . . 
	ld a,00ah		;11a3	3e 0a 	> . 
	ld (0ffbfh),a		;11a5	32 bf ff 	2 . . 
	ld (0ffb9h),bc		;11a8	ed 43 b9 ff 	. C . . 
	ld (0ffbbh),de		;11ac	ed 53 bb ff 	. S . . 
	ld (0ffbdh),hl		;11b0	22 bd ff 	" . . 
	call 0c423h		;11b3	cd 23 c4 	. # . 
	ld a,(0ffbah)		;11b6	3a ba ff 	: . . 
	and 0f0h		;11b9	e6 f0 	. . 
	jp z,0c1e6h		;11bb	ca e6 c1 	. . . 
	cp 040h		;11be	fe 40 	. @ 
	jp z,0c1dch		;11c0	ca dc c1 	. . . 
	cp 080h		;11c3	fe 80 	. . 
	jp z,0c1d7h		;11c5	ca d7 c1 	. . . 
	cp 020h		;11c8	fe 20 	.   
	jp z,0c1e1h		;11ca	ca e1 c1 	. . . 
	cp 0f0h		;11cd	fe f0 	. . 
	jp z,0c1ebh		;11cf	ca eb c1 	. . . 
	ld a,0ffh		;11d2	3e ff 	> . 
	jp 0c1f0h		;11d4	c3 f0 c1 	. . . 
	call 0c1f4h		;11d7	cd f4 c1 	. . . 
	jr $+22		;11da	18 14 	. . 
	call 0c24ah		;11dc	cd 4a c2 	. J . 
	jr $+17		;11df	18 0f 	. . 
	call 0c3a9h		;11e1	cd a9 c3 	. . . 
	jr $+12		;11e4	18 0a 	. . 
	call 0c391h		;11e6	cd 91 c3 	. . . 
	jr $+7		;11e9	18 05 	. . 
	call 0c2e3h		;11eb	cd e3 c2 	. . . 
	jr $+2		;11ee	18 00 	. . 
	pop hl			;11f0	e1 	. 
	pop de			;11f1	d1 	. 
	pop bc			;11f2	c1 	. 
	ret			;11f3	c9 	. 
	call 0c3a9h		;11f4	cd a9 c3 	. . . 
	call 0c2b7h		;11f7	cd b7 c2 	. . . 
	push de			;11fa	d5 	. 
	call 0c41ch		;11fb	cd 1c c4 	. . . 
	ld c,0c5h		;11fe	0e c5 	. . 
	ld a,(0ffb8h)		;1200	3a b8 ff 	: . . 
	or a			;1203	b7 	. 
	jr nz,$+4		;1204	20 02 	  . 
	res 6,c		;1206	cb b1 	. . 
	call 0c415h		;1208	cd 15 c4 	. . . 
	di			;120b	f3 	. 
	call 0c34eh		;120c	cd 4e c3 	. N . 
	pop de			;120f	d1 	. 
	ld c,0c1h		;1210	0e c1 	. . 
	ld b,e			;1212	43 	C 
	ld hl,(0ffbdh)		;1213	2a bd ff 	* . . 
	in a,(082h)		;1216	db 82 	. . 
	bit 2,a		;1218	cb 57 	. W 
	jr z,$-4		;121a	28 fa 	( . 
	in a,(0c0h)		;121c	db c0 	. . 
	bit 5,a		;121e	cb 6f 	. o 
	jr z,$+9		;1220	28 07 	( . 
	outi		;1222	ed a3 	. . 
	jr nz,$-14		;1224	20 f0 	  . 
	dec d			;1226	15 	. 
	jr nz,$-17		;1227	20 ed 	  . 
	out (0dch),a		;1229	d3 dc 	. . 
	ei			;122b	fb 	. 
	call 0c3f4h		;122c	cd f4 c3 	. . . 
	ld a,(0ffc0h)		;122f	3a c0 ff 	: . . 
	and 0c0h		;1232	e6 c0 	. . 
	cp 040h		;1234	fe 40 	. @ 
	jr nz,$+18		;1236	20 10 	  . 
	call 0c2a0h		;1238	cd a0 c2 	. . . 
	ld a,(0ffbfh)		;123b	3a bf ff 	: . . 
	dec a			;123e	3d 	= 
	ld (0ffbfh),a		;123f	32 bf ff 	2 . . 
	jp nz,0c1f7h		;1242	c2 f7 c1 	. . . 
	ld a,0ffh		;1245	3e ff 	> . 
	ret			;1247	c9 	. 
	xor a			;1248	af 	. 
	ret			;1249	c9 	. 
	call 0c3a9h		;124a	cd a9 c3 	. . . 
	call 0c2b7h		;124d	cd b7 c2 	. . . 
	push de			;1250	d5 	. 
	call 0c41ch		;1251	cd 1c c4 	. . . 
	ld c,0c6h		;1254	0e c6 	. . 
	ld a,(0ffb8h)		;1256	3a b8 ff 	: . . 
	or a			;1259	b7 	. 
	jr nz,$+4		;125a	20 02 	  . 
	res 6,c		;125c	cb b1 	. . 
	call 0c415h		;125e	cd 15 c4 	. . . 
	di			;1261	f3 	. 
	call 0c34eh		;1262	cd 4e c3 	. N . 
	pop de			;1265	d1 	. 
	ld c,0c1h		;1266	0e c1 	. . 
	ld b,e			;1268	43 	C 
	ld hl,(0ffbdh)		;1269	2a bd ff 	* . . 
	in a,(082h)		;126c	db 82 	. . 
	bit 2,a		;126e	cb 57 	. W 
	jr z,$-4		;1270	28 fa 	( . 
	in a,(0c0h)		;1272	db c0 	. . 
	bit 5,a		;1274	cb 6f 	. o 
	jr z,$+9		;1276	28 07 	( . 
	ini		;1278	ed a2 	. . 
	jr nz,$-14		;127a	20 f0 	  . 
	dec d			;127c	15 	. 
	jr nz,$-17		;127d	20 ed 	  . 
	out (0dch),a		;127f	d3 dc 	. . 
	ei			;1281	fb 	. 
	call 0c3f4h		;1282	cd f4 c3 	. . . 
	ld a,(0ffc0h)		;1285	3a c0 ff 	: . . 
	and 0c0h		;1288	e6 c0 	. . 
	cp 040h		;128a	fe 40 	. @ 
	jr nz,$+18		;128c	20 10 	  . 
	call 0c2a0h		;128e	cd a0 c2 	. . . 
	ld a,(0ffbfh)		;1291	3a bf ff 	: . . 
	dec a			;1294	3d 	= 
	ld (0ffbfh),a		;1295	32 bf ff 	2 . . 
	jp nz,0c24dh		;1298	c2 4d c2 	. M . 
	ld a,0ffh		;129b	3e ff 	> . 
	ret			;129d	c9 	. 
	xor a			;129e	af 	. 
	ret			;129f	c9 	. 
	ld a,(0ffc2h)		;12a0	3a c2 ff 	: . . 
	bit 4,a		;12a3	cb 67 	. g 
	jr z,$+6		;12a5	28 04 	( . 
	call 0c391h		;12a7	cd 91 c3 	. . . 
	ret			;12aa	c9 	. 
	ld a,(0ffc1h)		;12ab	3a c1 ff 	: . . 
	bit 0,a		;12ae	cb 47 	. G 
	jr z,$+6		;12b0	28 04 	( . 
	call 0c391h		;12b2	cd 91 c3 	. . . 
	ret			;12b5	c9 	. 
	ret			;12b6	c9 	. 
	ld e,000h		;12b7	1e 00 	. . 
	ld a,(0ffb8h)		;12b9	3a b8 ff 	: . . 
	cp 003h		;12bc	fe 03 	. . 
	jr nz,$+22		;12be	20 14 	  . 
	ld d,004h		;12c0	16 04 	. . 
	ld a,(0ffbbh)		;12c2	3a bb ff 	: . . 
	bit 7,a		;12c5	cb 7f 	.  
	jr z,$+27		;12c7	28 19 	( . 
	ld a,(0ffbah)		;12c9	3a ba ff 	: . . 
	and 00fh		;12cc	e6 0f 	. . 
	rlca			;12ce	07 	. 
	rlca			;12cf	07 	. 
	add a,d			;12d0	82 	. 
	ld d,a			;12d1	57 	W 
	jr $+16		;12d2	18 0e 	. . 
	or a			;12d4	b7 	. 
	jr nz,$+4		;12d5	20 02 	  . 
	ld e,080h		;12d7	1e 80 	. . 
	ld a,(0ffbah)		;12d9	3a ba ff 	: . . 
	and 00fh		;12dc	e6 0f 	. . 
	ld d,001h		;12de	16 01 	. . 
	add a,d			;12e0	82 	. 
	ld d,a			;12e1	57 	W 
	ret			;12e2	c9 	. 
	call 0c3a9h		;12e3	cd a9 c3 	. . . 
	cp 0ffh		;12e6	fe ff 	. . 
	ret z			;12e8	c8 	. 
	ld b,014h		;12e9	06 14 	. . 
	ld a,(0ffb8h)		;12eb	3a b8 ff 	: . . 
	cp 003h		;12ee	fe 03 	. . 
	jr z,$+4		;12f0	28 02 	( . 
	ld b,040h		;12f2	06 40 	. @ 
	push bc			;12f4	c5 	. 
	call 0c41ch		;12f5	cd 1c c4 	. . . 
	ld c,04dh		;12f8	0e 4d 	. M 
	call 0c415h		;12fa	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;12fd	ed 4b b9 ff 	. K . . 
	call 0c415h		;1301	cd 15 c4 	. . . 
	ld a,(0ffb8h)		;1304	3a b8 ff 	: . . 
	ld c,a			;1307	4f 	O 
	call 0c415h		;1308	cd 15 c4 	. . . 
	ld c,005h		;130b	0e 05 	. . 
	ld a,(0ffb8h)		;130d	3a b8 ff 	: . . 
	cp 003h		;1310	fe 03 	. . 
	jr z,$+4		;1312	28 02 	( . 
	ld c,010h		;1314	0e 10 	. . 
	call 0c415h		;1316	cd 15 c4 	. . . 
	ld c,028h		;1319	0e 28 	. ( 
	call 0c415h		;131b	cd 15 c4 	. . . 
	di			;131e	f3 	. 
	ld c,0e5h		;131f	0e e5 	. . 
	call 0c415h		;1321	cd 15 c4 	. . . 
	pop bc			;1324	c1 	. 
	ld c,0c1h		;1325	0e c1 	. . 
	ld hl,(0ffbdh)		;1327	2a bd ff 	* . . 
	in a,(082h)		;132a	db 82 	. . 
	bit 2,a		;132c	cb 57 	. W 
	jr z,$-4		;132e	28 fa 	( . 
	in a,(0c0h)		;1330	db c0 	. . 
	bit 5,a		;1332	cb 6f 	. o 
	jr z,$+6		;1334	28 04 	( . 
	outi		;1336	ed a3 	. . 
	jr nz,$-14		;1338	20 f0 	  . 
	out (0dch),a		;133a	d3 dc 	. . 
	ei			;133c	fb 	. 
	call 0c3f4h		;133d	cd f4 c3 	. . . 
	ld a,(0ffc0h)		;1340	3a c0 ff 	: . . 
	and 0c0h		;1343	e6 c0 	. . 
	cp 040h		;1345	fe 40 	. @ 
	jr nz,$+5		;1347	20 03 	  . 
	ld a,0ffh		;1349	3e ff 	> . 
	ret			;134b	c9 	. 
	xor a			;134c	af 	. 
	ret			;134d	c9 	. 
	ld bc,(0ffb9h)		;134e	ed 4b b9 ff 	. K . . 
	call 0c415h		;1352	cd 15 c4 	. . . 
	ld de,(0ffbbh)		;1355	ed 5b bb ff 	. [ . . 
	ld c,d			;1359	4a 	J 
	call 0c415h		;135a	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;135d	ed 4b b9 ff 	. K . . 
	ld a,c			;1361	79 	y 
	and 004h		;1362	e6 04 	. . 
	rrca			;1364	0f 	. 
	rrca			;1365	0f 	. 
	ld c,a			;1366	4f 	O 
	call 0c415h		;1367	cd 15 c4 	. . . 
	res 7,e		;136a	cb bb 	. . 
	ld c,e			;136c	4b 	K 
	inc c			;136d	0c 	. 
	call 0c415h		;136e	cd 15 c4 	. . . 
	ld a,(0ffb8h)		;1371	3a b8 ff 	: . . 
	ld c,a			;1374	4f 	O 
	call 0c415h		;1375	cd 15 c4 	. . . 
	ld c,005h		;1378	0e 05 	. . 
	ld a,(0ffb8h)		;137a	3a b8 ff 	: . . 
	cp 003h		;137d	fe 03 	. . 
	jr z,$+4		;137f	28 02 	( . 
	ld c,010h		;1381	0e 10 	. . 
	call 0c415h		;1383	cd 15 c4 	. . . 
	ld c,028h		;1386	0e 28 	. ( 
	call 0c415h		;1388	cd 15 c4 	. . . 
	ld c,0ffh		;138b	0e ff 	. . 
	call 0c415h		;138d	cd 15 c4 	. . . 
	ret			;1390	c9 	. 
	call 0c41ch		;1391	cd 1c c4 	. . . 
	ld c,007h		;1394	0e 07 	. . 
	call 0c415h		;1396	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;1399	ed 4b b9 ff 	. K . . 
	res 2,c		;139d	cb 91 	. . 
	call 0c415h		;139f	cd 15 c4 	. . . 
	call 0c3d2h		;13a2	cd d2 c3 	. . . 
	jr z,$-20		;13a5	28 ea 	( . 
	xor a			;13a7	af 	. 
	ret			;13a8	c9 	. 
	ld de,(0ffbbh)		;13a9	ed 5b bb ff 	. [ . . 
	ld a,d			;13ad	7a 	z 
	or a			;13ae	b7 	. 
	jp z,0c391h		;13af	ca 91 c3 	. . . 
	call 0c41ch		;13b2	cd 1c c4 	. . . 
	ld c,00fh		;13b5	0e 0f 	. . 
	call 0c415h		;13b7	cd 15 c4 	. . . 
	ld bc,(0ffb9h)		;13ba	ed 4b b9 ff 	. K . . 
	call 0c415h		;13be	cd 15 c4 	. . . 
	ld c,d			;13c1	4a 	J 
	call 0c415h		;13c2	cd 15 c4 	. . . 
	call 0c3d2h		;13c5	cd d2 c3 	. . . 
	jr nz,$+8		;13c8	20 06 	  . 
	call 0c391h		;13ca	cd 91 c3 	. . . 
	jp 0c3a9h		;13cd	c3 a9 c3 	. . . 
	xor a			;13d0	af 	. 
	ret			;13d1	c9 	. 
	in a,(082h)		;13d2	db 82 	. . 
	bit 2,a		;13d4	cb 57 	. W 
	jp z,0c3d2h		;13d6	ca d2 c3 	. . . 
	call 0c41ch		;13d9	cd 1c c4 	. . . 
	call 0c403h		;13dc	cd 03 c4 	. . . 
	ld a,008h		;13df	3e 08 	> . 
	out (0c1h),a		;13e1	d3 c1 	. . 
	call 0c40ch		;13e3	cd 0c c4 	. . . 
	in a,(0c1h)		;13e6	db c1 	. . 
	ld b,a			;13e8	47 	G 
	call 0c40ch		;13e9	cd 0c c4 	. . . 
	in a,(0c1h)		;13ec	db c1 	. . 
	ld a,b			;13ee	78 	x 
	and 0c0h		;13ef	e6 c0 	. . 
	cp 040h		;13f1	fe 40 	. @ 
	ret			;13f3	c9 	. 
	ld hl,0ffc0h		;13f4	21 c0 ff 	! . . 
	ld b,007h		;13f7	06 07 	. . 
	ld c,0c1h		;13f9	0e c1 	. . 
	call 0c40ch		;13fb	cd 0c c4 	. . . 
	ini		;13fe	ed a2 	. . 
	jr nz,$-5		;1400	20 f9 	  . 
	ret			;1402	c9 	. 
	in a,(0c0h)		;1403	db c0 	. . 
	rlca			;1405	07 	. 
	jr nc,$-3		;1406	30 fb 	0 . 
	rlca			;1408	07 	. 
	jr c,$-6		;1409	38 f8 	8 . 
	ret			;140b	c9 	. 
	in a,(0c0h)		;140c	db c0 	. . 
	rlca			;140e	07 	. 
	jr nc,$-3		;140f	30 fb 	0 . 
	rlca			;1411	07 	. 
	jr nc,$-6		;1412	30 f8 	0 . 
	ret			;1414	c9 	. 
	call 0c403h		;1415	cd 03 c4 	. . . 
	ld a,c			;1418	79 	y 
	out (0c1h),a		;1419	d3 c1 	. . 
	ret			;141b	c9 	. 
	in a,(0c0h)		;141c	db c0 	. . 
	bit 4,a		;141e	cb 67 	. g 
	jr nz,$-4		;1420	20 fa 	  . 
	ret			;1422	c9 	. 
	ld b,001h		;1423	06 01 	. . 
	ld a,c			;1425	79 	y 
	and 003h		;1426	e6 03 	. . 
	or a			;1428	b7 	. 
	jr z,$+7		;1429	28 05 	( . 
	rlc b		;142b	cb 00 	. . 
	dec a			;142d	3d 	= 
	jr nz,$-3		;142e	20 fb 	  . 
	ld a,(0ffc7h)		;1430	3a c7 ff 	: . . 
	ld c,a			;1433	4f 	O 
	and b			;1434	a0 	. 
	ret nz			;1435	c0 	. 
	ld a,c			;1436	79 	y 
	or b			;1437	b0 	. 
	ld (0ffc7h),a		;1438	32 c7 ff 	2 . . 
	call 0c391h		;143b	cd 91 c3 	. . . 
	ret			;143e	c9 	. 
	push bc			;143f	c5 	. 
	push hl			;1440	e5 	. 
	ld hl,0c45ch		;1441	21 5c c4 	! \ . 
	call 0c41ch		;1444	cd 1c c4 	. . . 
	ld c,003h		;1447	0e 03 	. . 
	call 0c415h		;1449	cd 15 c4 	. . . 
	ld c,(hl)			;144c	4e 	N 
	inc hl			;144d	23 	# 
	call 0c415h		;144e	cd 15 c4 	. . . 
	ld c,(hl)			;1451	4e 	N 
	call 0c415h		;1452	cd 15 c4 	. . . 
	xor a			;1455	af 	. 
	ld (0ffc7h),a		;1456	32 c7 ff 	2 . . 
	pop hl			;1459	e1 	. 
	pop bc			;145a	c1 	. 
	ret			;145b	c9 	. 
	ld l,a			;145c	6f 	o 
	dec de			;145d	1b 	. 
	push af			;145e	f5 	. 
	push bc			;145f	c5 	. 
	push de			;1460	d5 	. 
	push hl			;1461	e5 	. 
	push ix		;1462	dd e5 	. . 
	push iy		;1464	fd e5 	. . 
	call 0c69ah		;1466	cd 9a c6 	. . . 
	ld a,(0ffd8h)		;1469	3a d8 ff 	: . . 
	or a			;146c	b7 	. 
	jp nz,0c9e3h		;146d	c2 e3 c9 	. . . 
	ld a,(0ffcch)		;1470	3a cc ff 	: . . 
	cp 0ffh		;1473	fe ff 	. . 
	jp z,0c6a3h		;1475	ca a3 c6 	. . . 
	or a			;1478	b7 	. 
	jp nz,0c4beh		;1479	c2 be c4 	. . . 
	ld a,c			;147c	79 	y 
	cp 01bh		;147d	fe 1b 	. . 
	jr z,$+55		;147f	28 35 	( 5 
	cp 020h		;1481	fe 20 	.   
	jp nc,0c4beh		;1483	d2 be c4 	. . . 
	cp 00dh		;1486	fe 0d 	. . 
	jp z,0c524h		;1488	ca 24 c5 	. $ . 
	cp 00ah		;148b	fe 0a 	. . 
	jp z,0c532h		;148d	ca 32 c5 	. 2 . 
	cp 00bh		;1490	fe 0b 	. . 
	jp z,0c558h		;1492	ca 58 c5 	. X . 
	cp 00ch		;1495	fe 0c 	. . 
	jp z,0c56fh		;1497	ca 6f c5 	. o . 
	cp 008h		;149a	fe 08 	. . 
	jp z,0c59bh		;149c	ca 9b c5 	. . . 
	cp 01eh		;149f	fe 1e 	. . 
	jp z,0c5dbh		;14a1	ca db c5 	. . . 
	cp 01ah		;14a4	fe 1a 	. . 
	jp z,0c5eeh		;14a6	ca ee c5 	. . . 
	cp 007h		;14a9	fe 07 	. . 
	call z,0c5f4h		;14ab	cc f4 c5 	. . . 
	cp 000h		;14ae	fe 00 	. . 
	jp z,0c6a3h		;14b0	ca a3 c6 	. . . 
	jp 0c4beh		;14b3	c3 be c4 	. . . 
	ld a,001h		;14b6	3e 01 	> . 
	ld (0ffd8h),a		;14b8	32 d8 ff 	2 . . 
	jp 0c6a3h		;14bb	c3 a3 c6 	. . . 
	push iy		;14be	fd e5 	. . 
	pop hl			;14c0	e1 	. 
	call 0c715h		;14c1	cd 15 c7 	. . . 
	ld (hl),c			;14c4	71 	q 
	call 0c795h		;14c5	cd 95 c7 	. . . 
	ld a,(0ffd1h)		;14c8	3a d1 ff 	: . . 
	ld b,a			;14cb	47 	G 
	ld a,(0ffd2h)		;14cc	3a d2 ff 	: . . 
	and (hl)			;14cf	a6 	. 
	or b			;14d0	b0 	. 
	ld (hl),a			;14d1	77 	w 
	call 0c79eh		;14d2	cd 9e c7 	. . . 
	call 0c5f8h		;14d5	cd f8 c5 	. . . 
	jr c,$+8		;14d8	38 06 	8 . 
	call 0c613h		;14da	cd 13 c6 	. . . 
	jp 0c6a3h		;14dd	c3 a3 c6 	. . . 
	ld a,(0ffcbh)		;14e0	3a cb ff 	: . . 
	ld b,a			;14e3	47 	G 
	ld a,(0ffcdh)		;14e4	3a cd ff 	: . . 
	cp b			;14e7	b8 	. 
	jr z,$+25		;14e8	28 17 	( . 
	inc b			;14ea	04 	. 
	ld a,b			;14eb	78 	x 
	ld (0ffcbh),a		;14ec	32 cb ff 	2 . . 
	ld a,(0ffc9h)		;14ef	3a c9 ff 	: . . 
	or a			;14f2	b7 	. 
	jr nz,$+8		;14f3	20 06 	  . 
	call 0c613h		;14f5	cd 13 c6 	. . . 
	jp 0c6a3h		;14f8	c3 a3 c6 	. . . 
	call 0c620h		;14fb	cd 20 c6 	.   . 
	jp 0c6a3h		;14fe	c3 a3 c6 	. . . 
	ld a,(0ffc9h)		;1501	3a c9 ff 	: . . 
	or a			;1504	b7 	. 
	jr nz,$+11		;1505	20 09 	  . 
	call 0c613h		;1507	cd 13 c6 	. . . 
	call 0c62eh		;150a	cd 2e c6 	. . . 
	jp 0c6a3h		;150d	c3 a3 c6 	. . . 
	ld a,(0ffcdh)		;1510	3a cd ff 	: . . 
	ld b,a			;1513	47 	G 
	ld a,(0ffd0h)		;1514	3a d0 ff 	: . . 
	ld c,a			;1517	4f 	O 
	call 0c6f1h		;1518	cd f1 c6 	. . . 
	call 0c71ch		;151b	cd 1c c7 	. . . 
	call 0c62eh		;151e	cd 2e c6 	. . . 
	jp 0c6a3h		;1521	c3 a3 c6 	. . . 
	ld a,(0ffd0h)		;1524	3a d0 ff 	: . . 
	ld (0ffcah),a		;1527	32 ca ff 	2 . . 
	ld c,a			;152a	4f 	O 
	ld a,(0ffcbh)		;152b	3a cb ff 	: . . 
	ld b,a			;152e	47 	G 
	jp 0c5e5h		;152f	c3 e5 c5 	. . . 
	ld a,(0ffcbh)		;1532	3a cb ff 	: . . 
	ld b,a			;1535	47 	G 
	ld a,(0ffcdh)		;1536	3a cd ff 	: . . 
	cp b			;1539	b8 	. 
	jr z,$+17		;153a	28 0f 	( . 
	inc b			;153c	04 	. 
	ld a,b			;153d	78 	x 
	ld (0ffcbh),a		;153e	32 cb ff 	2 . . 
	push iy		;1541	fd e5 	. . 
	pop hl			;1543	e1 	. 
	ld de,00050h		;1544	11 50 00 	. P . 
	add hl,de			;1547	19 	. 
	jp 0c5e8h		;1548	c3 e8 c5 	. . . 
	call 0c62eh		;154b	cd 2e c6 	. . . 
	ld a,(0ffcbh)		;154e	3a cb ff 	: . . 
	ld b,a			;1551	47 	G 
	ld a,(0ffcah)		;1552	3a ca ff 	: . . 
	ld c,a			;1555	4f 	O 
	jr $-21		;1556	18 e9 	. . 
	ld a,(0ffcbh)		;1558	3a cb ff 	: . . 
	ld b,a			;155b	47 	G 
	ld a,(0ffceh)		;155c	3a ce ff 	: . . 
	cp b			;155f	b8 	. 
	jp z,0c6a3h		;1560	ca a3 c6 	. . . 
	dec b			;1563	05 	. 
	ld a,b			;1564	78 	x 
	ld (0ffcbh),a		;1565	32 cb ff 	2 . . 
	ld a,(0ffcah)		;1568	3a ca ff 	: . . 
	ld c,a			;156b	4f 	O 
	jp 0c5e5h		;156c	c3 e5 c5 	. . . 
	call 0c5f8h		;156f	cd f8 c5 	. . . 
	ld a,(0ffcbh)		;1572	3a cb ff 	: . . 
	ld b,a			;1575	47 	G 
	jr c,$+5		;1576	38 03 	8 . 
	jp 0c5e5h		;1578	c3 e5 c5 	. . . 
	ld a,(0ffd0h)		;157b	3a d0 ff 	: . . 
	ld (0ffcah),a		;157e	32 ca ff 	2 . . 
	ld c,a			;1581	4f 	O 
	ld a,(0ffcbh)		;1582	3a cb ff 	: . . 
	ld b,a			;1585	47 	G 
	ld a,(0ffcdh)		;1586	3a cd ff 	: . . 
	cp b			;1589	b8 	. 
	jr z,$+10		;158a	28 08 	( . 
	inc b			;158c	04 	. 
	ld a,b			;158d	78 	x 
	ld (0ffcbh),a		;158e	32 cb ff 	2 . . 
	jp 0c5e5h		;1591	c3 e5 c5 	. . . 
	push bc			;1594	c5 	. 
	call 0c62eh		;1595	cd 2e c6 	. . . 
	pop bc			;1598	c1 	. 
	jr $+76		;1599	18 4a 	. J 
	ld a,(0ffcah)		;159b	3a ca ff 	: . . 
	ld c,a			;159e	4f 	O 
	ld a,(0ffd0h)		;159f	3a d0 ff 	: . . 
	cp c			;15a2	b9 	. 
	jr z,$+21		;15a3	28 13 	( . 
	dec c			;15a5	0d 	. 
	ld a,(0ffd1h)		;15a6	3a d1 ff 	: . . 
	bit 3,a		;15a9	cb 5f 	. _ 
	jr z,$+3		;15ab	28 01 	( . 
	dec c			;15ad	0d 	. 
	ld a,c			;15ae	79 	y 
	ld (0ffcah),a		;15af	32 ca ff 	2 . . 
	ld a,(0ffcbh)		;15b2	3a cb ff 	: . . 
	ld b,a			;15b5	47 	G 
	jr $+47		;15b6	18 2d 	. - 
	ld a,(0ffcfh)		;15b8	3a cf ff 	: . . 
	ld b,a			;15bb	47 	G 
	ld a,(0ffd1h)		;15bc	3a d1 ff 	: . . 
	bit 3,a		;15bf	cb 5f 	. _ 
	jr z,$+3		;15c1	28 01 	( . 
	dec b			;15c3	05 	. 
	ld a,b			;15c4	78 	x 
	ld (0ffcah),a		;15c5	32 ca ff 	2 . . 
	ld c,a			;15c8	4f 	O 
	ld a,(0ffcbh)		;15c9	3a cb ff 	: . . 
	ld b,a			;15cc	47 	G 
	ld a,(0ffceh)		;15cd	3a ce ff 	: . . 
	cp b			;15d0	b8 	. 
	jp z,0c6a3h		;15d1	ca a3 c6 	. . . 
	dec b			;15d4	05 	. 
	ld a,b			;15d5	78 	x 
	ld (0ffcbh),a		;15d6	32 cb ff 	2 . . 
	jr $+12		;15d9	18 0a 	. . 
	xor a			;15db	af 	. 
	ld (0ffcbh),a		;15dc	32 cb ff 	2 . . 
	ld (0ffcah),a		;15df	32 ca ff 	2 . . 
	ld bc,00000h		;15e2	01 00 00 	. . . 
	call 0c6f1h		;15e5	cd f1 c6 	. . . 
	call 0c71ch		;15e8	cd 1c c7 	. . . 
	jp 0c6a3h		;15eb	c3 a3 c6 	. . . 
	call 0c764h		;15ee	cd 64 c7 	. d . 
	jp 0c6a3h		;15f1	c3 a3 c6 	. . . 
	xor a			;15f4	af 	. 
	out (0dah),a		;15f5	d3 da 	. . 
	ret			;15f7	c9 	. 
	ld a,(0ffcah)		;15f8	3a ca ff 	: . . 
	ld c,a			;15fb	4f 	O 
	inc c			;15fc	0c 	. 
	ld a,(0ffd1h)		;15fd	3a d1 ff 	: . . 
	bit 3,a		;1600	cb 5f 	. _ 
	jr z,$+3		;1602	28 01 	( . 
	inc c			;1604	0c 	. 
	ld a,(0ffcfh)		;1605	3a cf ff 	: . . 
	cp c			;1608	b9 	. 
	ld a,c			;1609	79 	y 
	jr nc,$+5		;160a	30 03 	0 . 
	ld a,(0ffd0h)		;160c	3a d0 ff 	: . . 
	ld (0ffcah),a		;160f	32 ca ff 	2 . . 
	ret			;1612	c9 	. 
	inc hl			;1613	23 	# 
	ld a,(0ffd1h)		;1614	3a d1 ff 	: . . 
	bit 3,a		;1617	cb 5f 	. _ 
	jr z,$+3		;1619	28 01 	( . 
	inc hl			;161b	23 	# 
	call 0c71ch		;161c	cd 1c c7 	. . . 
	ret			;161f	c9 	. 
	ld a,(0ffc8h)		;1620	3a c8 ff 	: . . 
	ld e,a			;1623	5f 	_ 
	ld d,000h		;1624	16 00 	. . 
	push iy		;1626	fd e5 	. . 
	pop hl			;1628	e1 	. 
	add hl,de			;1629	19 	. 
	call 0c71ch		;162a	cd 1c c7 	. . . 
	ret			;162d	c9 	. 
	ld a,(0ffc9h)		;162e	3a c9 ff 	: . . 
	or a			;1631	b7 	. 
	jr nz,$+21		;1632	20 13 	  . 
	push ix		;1634	dd e5 	. . 
	pop hl			;1636	e1 	. 
	ld de,00050h		;1637	11 50 00 	. P . 
	add hl,de			;163a	19 	. 
	call 0c742h		;163b	cd 42 c7 	. B . 
	ld b,017h		;163e	06 17 	. . 
	call 0c7fah		;1640	cd fa c7 	. . . 
	call 0c670h		;1643	cd 70 c6 	. p . 
	ret			;1646	c9 	. 
	ld a,(0ffd0h)		;1647	3a d0 ff 	: . . 
	ld c,a			;164a	4f 	O 
	ld a,(0ffceh)		;164b	3a ce ff 	: . . 
	ld b,a			;164e	47 	G 
	ld a,(0ffceh)		;164f	3a ce ff 	: . . 
	ld d,a			;1652	57 	W 
	ld a,(0ffcdh)		;1653	3a cd ff 	: . . 
	sub d			;1656	92 	. 
	jr z,$+13		;1657	28 0b 	( . 
	ld d,a			;1659	57 	W 
	inc b			;165a	04 	. 
	call 0c6f1h		;165b	cd f1 c6 	. . . 
	call 0c7a7h		;165e	cd a7 c7 	. . . 
	dec d			;1661	15 	. 
	jr nz,$-8		;1662	20 f6 	  . 
	ld a,(0ffcdh)		;1664	3a cd ff 	: . . 
	ld d,a			;1667	57 	W 
	ld a,(0ffcfh)		;1668	3a cf ff 	: . . 
	ld e,a			;166b	5f 	_ 
	call 0c805h		;166c	cd 05 c8 	. . . 
	ret			;166f	c9 	. 
	push ix		;1670	dd e5 	. . 
	pop hl			;1672	e1 	. 
	ld de,00730h		;1673	11 30 07 	. 0 . 
	ld b,050h		;1676	06 50 	. P 
	add hl,de			;1678	19 	. 
	ld de,02000h		;1679	11 00 20 	. .   
	call 0c795h		;167c	cd 95 c7 	. . . 
	call 0c715h		;167f	cd 15 c7 	. . . 
	push hl			;1682	e5 	. 
	push bc			;1683	c5 	. 
	ld e,000h		;1684	1e 00 	. . 
	call 0c690h		;1686	cd 90 c6 	. . . 
	pop bc			;1689	c1 	. 
	pop hl			;168a	e1 	. 
	call 0c79eh		;168b	cd 9e c7 	. . . 
	ld e,020h		;168e	1e 20 	.   
	ld (hl),e			;1690	73 	s 
	inc hl			;1691	23 	# 
	bit 3,h		;1692	cb 5c 	. \ 
	call z,0c715h		;1694	cc 15 c7 	. . . 
	djnz $-7		;1697	10 f7 	. . 
	ret			;1699	c9 	. 
	ld ix,(0ffd4h)		;169a	dd 2a d4 ff 	. * . . 
	ld iy,(0ffd6h)		;169e	fd 2a d6 ff 	. * . . 
	ret			;16a2	c9 	. 
	call 0c6e8h		;16a3	cd e8 c6 	. . . 
	pop iy		;16a6	fd e1 	. . 
	pop ix		;16a8	dd e1 	. . 
	pop hl			;16aa	e1 	. 
	pop de			;16ab	d1 	. 
	pop bc			;16ac	c1 	. 
	pop af			;16ad	f1 	. 
	ret			;16ae	c9 	. 
	ld hl,0ffc9h		;16af	21 c9 ff 	! . . 
	xor a			;16b2	af 	. 
	ld (hl),a			;16b3	77 	w 
	inc hl			;16b4	23 	# 
	ld (hl),a			;16b5	77 	w 
	inc hl			;16b6	23 	# 
	ld (hl),a			;16b7	77 	w 
	inc hl			;16b8	23 	# 
	ld (hl),a			;16b9	77 	w 
	inc hl			;16ba	23 	# 
	ld (hl),017h		;16bb	36 17 	6 . 
	inc hl			;16bd	23 	# 
	ld (hl),a			;16be	77 	w 
	inc hl			;16bf	23 	# 
	ld (hl),04fh		;16c0	36 4f 	6 O 
	inc hl			;16c2	23 	# 
	ld (hl),a			;16c3	77 	w 
	inc hl			;16c4	23 	# 
	ld (hl),a			;16c5	77 	w 
	inc hl			;16c6	23 	# 
	ld (hl),080h		;16c7	36 80 	6 . 
	inc hl			;16c9	23 	# 
	ld a,(0c86fh)		;16ca	3a 6f c8 	: o . 
	ld d,a			;16cd	57 	W 
	in a,(0d6h)		;16ce	db d6 	. . 
	bit 5,a		;16d0	cb 6f 	. o 
	jr z,$+4		;16d2	28 02 	( . 
	ld d,003h		;16d4	16 03 	. . 
	bit 6,a		;16d6	cb 77 	. w 
	jr z,$+6		;16d8	28 04 	( . 
	set 5,d		;16da	cb ea 	. . 
	set 6,d		;16dc	cb f2 	. . 
	ld (hl),d			;16de	72 	r 
	xor a			;16df	af 	. 
	inc hl			;16e0	23 	# 
	ld b,015h		;16e1	06 15 	. . 
	ld (hl),a			;16e3	77 	w 
	inc hl			;16e4	23 	# 
	djnz $-2		;16e5	10 fc 	. . 
	ret			;16e7	c9 	. 
	ld (0ffd4h),ix		;16e8	dd 22 d4 ff 	. " . . 
	ld (0ffd6h),iy		;16ec	fd 22 d6 ff 	. " . . 
	ret			;16f0	c9 	. 
	push af			;16f1	f5 	. 
	push bc			;16f2	c5 	. 
	push de			;16f3	d5 	. 
	push ix		;16f4	dd e5 	. . 
	pop hl			;16f6	e1 	. 
	ld de,00050h		;16f7	11 50 00 	. P . 
	ld a,b			;16fa	78 	x 
	ld b,005h		;16fb	06 05 	. . 
	rra			;16fd	1f 	. 
	jr nc,$+3		;16fe	30 01 	0 . 
	add hl,de			;1700	19 	. 
	or a			;1701	b7 	. 
	rl e		;1702	cb 13 	. . 
	rl d		;1704	cb 12 	. . 
	dec b			;1706	05 	. 
	jr nz,$-10		;1707	20 f4 	  . 
	ld d,000h		;1709	16 00 	. . 
	ld e,c			;170b	59 	Y 
	add hl,de			;170c	19 	. 
	ld a,h			;170d	7c 	| 
	and 00fh		;170e	e6 0f 	. . 
	ld h,a			;1710	67 	g 
	pop de			;1711	d1 	. 
	pop bc			;1712	c1 	. 
	pop af			;1713	f1 	. 
	ret			;1714	c9 	. 
	ld a,h			;1715	7c 	| 
	and 007h		;1716	e6 07 	. . 
	or 0d0h		;1718	f6 d0 	. . 
	ld h,a			;171a	67 	g 
	ret			;171b	c9 	. 
	ld a,h			;171c	7c 	| 
	and 007h		;171d	e6 07 	. . 
	ld h,a			;171f	67 	g 
	push ix		;1720	dd e5 	. . 
	pop de			;1722	d1 	. 
	ex de,hl			;1723	eb 	. 
	or a			;1724	b7 	. 
	sbc hl,de		;1725	ed 52 	. R 
	jr c,$+9		;1727	38 07 	8 . 
	jr z,$+7		;1729	28 05 	( . 
	ld hl,00800h		;172b	21 00 08 	! . . 
	add hl,de			;172e	19 	. 
	ex de,hl			;172f	eb 	. 
	ld a,00eh		;1730	3e 0e 	> . 
	out (0a0h),a		;1732	d3 a0 	. . 
	ld a,d			;1734	7a 	z 
	out (0a1h),a		;1735	d3 a1 	. . 
	ld a,00fh		;1737	3e 0f 	> . 
	out (0a0h),a		;1739	d3 a0 	. . 
	ld a,e			;173b	7b 	{ 
	out (0a1h),a		;173c	d3 a1 	. . 
	push de			;173e	d5 	. 
	pop iy		;173f	fd e1 	. . 
	ret			;1741	c9 	. 
	ld a,h			;1742	7c 	| 
	and 007h		;1743	e6 07 	. . 
	ld h,a			;1745	67 	g 
	call 0c75bh		;1746	cd 5b c7 	. [ . 
	ld a,00ch		;1749	3e 0c 	> . 
	out (0a0h),a		;174b	d3 a0 	. . 
	ld a,h			;174d	7c 	| 
	out (0a1h),a		;174e	d3 a1 	. . 
	ld a,00dh		;1750	3e 0d 	> . 
	out (0a0h),a		;1752	d3 a0 	. . 
	ld a,l			;1754	7d 	} 
	out (0a1h),a		;1755	d3 a1 	. . 
	push hl			;1757	e5 	. 
	pop ix		;1758	dd e1 	. . 
	ret			;175a	c9 	. 
	in a,(0a0h)		;175b	db a0 	. . 
	in a,(082h)		;175d	db 82 	. . 
	bit 1,a		;175f	cb 4f 	. O 
	jr z,$-4		;1761	28 fa 	( . 
	ret			;1763	c9 	. 
	ld bc,00780h		;1764	01 80 07 	. . . 
	push ix		;1767	dd e5 	. . 
	pop hl			;1769	e1 	. 
	ld de,02000h		;176a	11 00 20 	. .   
	call 0c715h		;176d	cd 15 c7 	. . . 
	ld (hl),d			;1770	72 	r 
	in a,(081h)		;1771	db 81 	. . 
	set 7,a		;1773	cb ff 	. . 
	out (081h),a		;1775	d3 81 	. . 
	ld (hl),e			;1777	73 	s 
	res 7,a		;1778	cb bf 	. . 
	out (081h),a		;177a	d3 81 	. . 
	inc hl			;177c	23 	# 
	bit 3,h		;177d	cb 5c 	. \ 
	call z,0c715h		;177f	cc 15 c7 	. . . 
	dec bc			;1782	0b 	. 
	ld a,b			;1783	78 	x 
	or c			;1784	b1 	. 
	jr nz,$-21		;1785	20 e9 	  . 
	push ix		;1787	dd e5 	. . 
	pop hl			;1789	e1 	. 
	call 0c71ch		;178a	cd 1c c7 	. . . 
	xor a			;178d	af 	. 
	ld (0ffcah),a		;178e	32 ca ff 	2 . . 
	ld (0ffcbh),a		;1791	32 cb ff 	2 . . 
	ret			;1794	c9 	. 
	push af			;1795	f5 	. 
	in a,(081h)		;1796	db 81 	. . 
	set 7,a		;1798	cb ff 	. . 
	out (081h),a		;179a	d3 81 	. . 
	pop af			;179c	f1 	. 
	ret			;179d	c9 	. 
	push af			;179e	f5 	. 
	in a,(081h)		;179f	db 81 	. . 
	res 7,a		;17a1	cb bf 	. . 
	out (081h),a		;17a3	d3 81 	. . 
	pop af			;17a5	f1 	. 
	ret			;17a6	c9 	. 
	push de			;17a7	d5 	. 
	push bc			;17a8	c5 	. 
	ld a,050h		;17a9	3e 50 	> P 
	cpl			;17ab	2f 	/ 
	ld d,0ffh		;17ac	16 ff 	. . 
	ld e,a			;17ae	5f 	_ 
	inc de			;17af	13 	. 
	call 0c7b6h		;17b0	cd b6 c7 	. . . 
	pop bc			;17b3	c1 	. 
	pop de			;17b4	d1 	. 
	ret			;17b5	c9 	. 
	ld a,(0ffd0h)		;17b6	3a d0 ff 	: . . 
	ld c,a			;17b9	4f 	O 
	call 0c6f1h		;17ba	cd f1 c6 	. . . 
	push hl			;17bd	e5 	. 
	add hl,de			;17be	19 	. 
	ex de,hl			;17bf	eb 	. 
	pop hl			;17c0	e1 	. 
	ld a,(0ffd0h)		;17c1	3a d0 ff 	: . . 
	ld b,a			;17c4	47 	G 
	ld a,(0ffcfh)		;17c5	3a cf ff 	: . . 
	sub b			;17c8	90 	. 
	inc a			;17c9	3c 	< 
	ld b,a			;17ca	47 	G 
	call 0c715h		;17cb	cd 15 c7 	. . . 
	ex de,hl			;17ce	eb 	. 
	call 0c715h		;17cf	cd 15 c7 	. . . 
	ex de,hl			;17d2	eb 	. 
	push bc			;17d3	c5 	. 
	push de			;17d4	d5 	. 
	push hl			;17d5	e5 	. 
	ld c,002h		;17d6	0e 02 	. . 
	ld a,(hl)			;17d8	7e 	~ 
	ld (de),a			;17d9	12 	. 
	inc de			;17da	13 	. 
	ld a,d			;17db	7a 	z 
	and 007h		;17dc	e6 07 	. . 
	or 0d0h		;17de	f6 d0 	. . 
	ld d,a			;17e0	57 	W 
	inc hl			;17e1	23 	# 
	bit 3,h		;17e2	cb 5c 	. \ 
	call z,0c715h		;17e4	cc 15 c7 	. . . 
	djnz $-15		;17e7	10 ef 	. . 
	dec c			;17e9	0d 	. 
	jr z,$+12		;17ea	28 0a 	( . 
	ld a,c			;17ec	79 	y 
	pop hl			;17ed	e1 	. 
	pop de			;17ee	d1 	. 
	pop bc			;17ef	c1 	. 
	ld c,a			;17f0	4f 	O 
	call 0c795h		;17f1	cd 95 c7 	. . . 
	jr $-28		;17f4	18 e2 	. . 
	call 0c79eh		;17f6	cd 9e c7 	. . . 
	ret			;17f9	c9 	. 
	push de			;17fa	d5 	. 
	push bc			;17fb	c5 	. 
	ld de,00050h		;17fc	11 50 00 	. P . 
	call 0c7b6h		;17ff	cd b6 c7 	. . . 
	pop bc			;1802	c1 	. 
	pop de			;1803	d1 	. 
	ret			;1804	c9 	. 
	ld a,e			;1805	7b 	{ 
	sub c			;1806	91 	. 
	inc a			;1807	3c 	< 
	ld e,a			;1808	5f 	_ 
	ld a,d			;1809	7a 	z 
	sub b			;180a	90 	. 
	inc a			;180b	3c 	< 
	ld d,a			;180c	57 	W 
	call 0c6f1h		;180d	cd f1 c6 	. . . 
	call 0c715h		;1810	cd 15 c7 	. . . 
	ld (hl),020h		;1813	36 20 	6   
	call 0c795h		;1815	cd 95 c7 	. . . 
	ld (hl),000h		;1818	36 00 	6 . 
	call 0c79eh		;181a	cd 9e c7 	. . . 
	inc hl			;181d	23 	# 
	dec e			;181e	1d 	. 
	jr nz,$-15		;181f	20 ef 	  . 
	inc b			;1821	04 	. 
	ld a,(0ffd0h)		;1822	3a d0 ff 	: . . 
	ld c,a			;1825	4f 	O 
	ld a,(0ffcfh)		;1826	3a cf ff 	: . . 
	sub c			;1829	91 	. 
	inc a			;182a	3c 	< 
	ld e,a			;182b	5f 	_ 
	dec d			;182c	15 	. 
	jr nz,$-32		;182d	20 de 	  . 
	ret			;182f	c9 	. 
	ld a,(0ffcdh)		;1830	3a cd ff 	: . . 
	ld b,a			;1833	47 	G 
	ld a,(0ffceh)		;1834	3a ce ff 	: . . 
	cp b			;1837	b8 	. 
	jr z,$+13		;1838	28 0b 	( . 
	ld d,a			;183a	57 	W 
	ld a,b			;183b	78 	x 
	sub d			;183c	92 	. 
	ld d,a			;183d	57 	W 
	dec b			;183e	05 	. 
	call 0c7fah		;183f	cd fa c7 	. . . 
	dec d			;1842	15 	. 
	jr nz,$-5		;1843	20 f9 	  . 
	ld a,(0ffceh)		;1845	3a ce ff 	: . . 
	ld b,a			;1848	47 	G 
	ld d,a			;1849	57 	W 
	ld a,(0ffd0h)		;184a	3a d0 ff 	: . . 
	ld c,a			;184d	4f 	O 
	ld a,(0ffcfh)		;184e	3a cf ff 	: . . 
	ld e,a			;1851	5f 	_ 
	call 0c805h		;1852	cd 05 c8 	. . . 
	ret			;1855	c9 	. 
	push bc			;1856	c5 	. 
	ld b,01eh		;1857	06 1e 	. . 
	ld c,00fh		;1859	0e 0f 	. . 
	dec c			;185b	0d 	. 
	jp nz,0c85bh		;185c	c2 5b c8 	. [ . 
	dec b			;185f	05 	. 
	jp nz,0c859h		;1860	c2 59 c8 	. Y . 
	pop bc			;1863	c1 	. 
	ret			;1864	c9 	. 
	ld h,e			;1865	63 	c 
	ld d,b			;1866	50 	P 
	ld d,h			;1867	54 	T 
	xor d			;1868	aa 	. 
	add hl,de			;1869	19 	. 
	ld b,019h		;186a	06 19 	. . 
	add hl,de			;186c	19 	. 
	nop			;186d	00 	. 
	dec c			;186e	0d 	. 
	dec c			;186f	0d 	. 
	dec c			;1870	0d 	. 
	nop			;1871	00 	. 
	nop			;1872	00 	. 
	nop			;1873	00 	. 
	nop			;1874	00 	. 
	ld a,(0ffd1h)		;1875	3a d1 ff 	: . . 
	set 3,a		;1878	cb df 	. . 
	ld (0ffd1h),a		;187a	32 d1 ff 	2 . . 
	ld a,(0ffcah)		;187d	3a ca ff 	: . . 
	ld c,a			;1880	4f 	O 
	rra			;1881	1f 	. 
	jr nc,$+9		;1882	30 07 	0 . 
	inc iy		;1884	fd 23 	. # 
	inc c			;1886	0c 	. 
	ld a,c			;1887	79 	y 
	ld (0ffcah),a		;1888	32 ca ff 	2 . . 
	xor a			;188b	af 	. 
	ret			;188c	c9 	. 
	ld hl,0c865h		;188d	21 65 c8 	! e . 
	ld b,010h		;1890	06 10 	. . 
	ld c,0a1h		;1892	0e a1 	. . 
	xor a			;1894	af 	. 
	out (0a0h),a		;1895	d3 a0 	. . 
	inc a			;1897	3c 	< 
	outi		;1898	ed a3 	. . 
	jr nz,$-5		;189a	20 f9 	  . 
	ld ix,00000h		;189c	dd 21 00 00 	. ! . . 
	call 0c764h		;18a0	cd 64 c7 	. d . 
	call 0c8b6h		;18a3	cd b6 c8 	. . . 
	ld hl,00000h		;18a6	21 00 00 	! . . 
	call 0c71ch		;18a9	cd 1c c7 	. . . 
	ld a,(0ffd1h)		;18ac	3a d1 ff 	: . . 
	res 3,a		;18af	cb 9f 	. . 
	ld (0ffd1h),a		;18b1	32 d1 ff 	2 . . 
	xor a			;18b4	af 	. 
	ret			;18b5	c9 	. 
	ld a,006h		;18b6	3e 06 	> . 
	out (0a0h),a		;18b8	d3 a0 	. . 
	ld a,018h		;18ba	3e 18 	> . 
	out (0a1h),a		;18bc	d3 a1 	. . 
	ret			;18be	c9 	. 
	xor a			;18bf	af 	. 
	ld (0ffceh),a		;18c0	32 ce ff 	2 . . 
	ld (0ffd0h),a		;18c3	32 d0 ff 	2 . . 
	ld (0ffc9h),a		;18c6	32 c9 ff 	2 . . 
	ld a,017h		;18c9	3e 17 	> . 
	ld (0ffcdh),a		;18cb	32 cd ff 	2 . . 
	ret			;18ce	c9 	. 
	ld b,004h		;18cf	06 04 	. . 
	call 0c75bh		;18d1	cd 5b c7 	. [ . 
	xor a			;18d4	af 	. 
	ld c,0a1h		;18d5	0e a1 	. . 
	out (0a0h),a		;18d7	d3 a0 	. . 
	inc a			;18d9	3c 	< 
	outi		;18da	ed a3 	. . 
	jr nz,$-5		;18dc	20 f9 	  . 
	ret			;18de	c9 	. 
	ld a,(0ffd9h)		;18df	3a d9 ff 	: . . 
	or a			;18e2	b7 	. 
	jr nz,$+7		;18e3	20 05 	  . 
	inc a			;18e5	3c 	< 
	ld (0ffd9h),a		;18e6	32 d9 ff 	2 . . 
	ret			;18e9	c9 	. 
	ld a,c			;18ea	79 	y 
	and 00fh		;18eb	e6 0f 	. . 
	rlca			;18ed	07 	. 
	rlca			;18ee	07 	. 
	rlca			;18ef	07 	. 
	rlca			;18f0	07 	. 
	cpl			;18f1	2f 	/ 
	ld b,a			;18f2	47 	G 
	ld a,(0ffd1h)		;18f3	3a d1 ff 	: . . 
	and b			;18f6	a0 	. 
	ld (0ffd1h),a		;18f7	32 d1 ff 	2 . . 
	xor a			;18fa	af 	. 
	ret			;18fb	c9 	. 
	xor a			;18fc	af 	. 
	ld (0ffd1h),a		;18fd	32 d1 ff 	2 . . 
	ret			;1900	c9 	. 
	ld a,(0ffd9h)		;1901	3a d9 ff 	: . . 
	ld b,a			;1904	47 	G 
	ld d,000h		;1905	16 00 	. . 
	ld e,a			;1907	5f 	_ 
	ld hl,0ffd9h		;1908	21 d9 ff 	! . . 
	add hl,de			;190b	19 	. 
	ld a,c			;190c	79 	y 
	sub 020h		;190d	d6 20 	.   
	ld (hl),a			;190f	77 	w 
	ld a,b			;1910	78 	x 
	inc a			;1911	3c 	< 
	ld (0ffd9h),a		;1912	32 d9 ff 	2 . . 
	ret			;1915	c9 	. 
	ld a,b			;1916	78 	x 
	out (0a0h),a		;1917	d3 a0 	. . 
	ld a,c			;1919	79 	y 
	out (0a1h),a		;191a	d3 a1 	. . 
	ret			;191c	c9 	. 
	call 0c6f1h		;191d	cd f1 c6 	. . . 
	push hl			;1920	e5 	. 
	ld b,d			;1921	42 	B 
	ld c,e			;1922	4b 	K 
	call 0c6f1h		;1923	cd f1 c6 	. . . 
	pop de			;1926	d1 	. 
	push de			;1927	d5 	. 
	or a			;1928	b7 	. 
	sbc hl,de		;1929	ed 52 	. R 
	inc hl			;192b	23 	# 
	ex de,hl			;192c	eb 	. 
	pop hl			;192d	e1 	. 
	ld b,a			;192e	47 	G 
	call 0c795h		;192f	cd 95 c7 	. . . 
	call 0c715h		;1932	cd 15 c7 	. . . 
	ld a,(hl)			;1935	7e 	~ 
	or b			;1936	b0 	. 
	ld (hl),a			;1937	77 	w 
	inc hl			;1938	23 	# 
	dec de			;1939	1b 	. 
	ld a,d			;193a	7a 	z 
	or e			;193b	b3 	. 
	jr nz,$-10		;193c	20 f4 	  . 
	call 0c79eh		;193e	cd 9e c7 	. . . 
	ret			;1941	c9 	. 
	ld a,c			;1942	79 	y 
	cp 044h		;1943	fe 44 	. D 
	jr nz,$+6		;1945	20 04 	  . 
	ld c,040h		;1947	0e 40 	. @ 
	jr $+59		;1949	18 39 	. 9 
	cp 045h		;194b	fe 45 	. E 
	jr nz,$+6		;194d	20 04 	  . 
	ld c,060h		;194f	0e 60 	. ` 
	jr $+51		;1951	18 31 	. 1 
	cp 046h		;1953	fe 46 	. F 
	jr nz,$+6		;1955	20 04 	  . 
	ld c,020h		;1957	0e 20 	.   
	jr $+43		;1959	18 29 	. ) 
	ld a,(0c86fh)		;195b	3a 6f c8 	: o . 
	ld d,a			;195e	57 	W 
	in a,(0d6h)		;195f	db d6 	. . 
	bit 5,a		;1961	cb 6f 	. o 
	jr z,$+4		;1963	28 02 	( . 
	ld d,003h		;1965	16 03 	. . 
	bit 6,a		;1967	cb 77 	. w 
	jr z,$+6		;1969	28 04 	( . 
	set 5,d		;196b	cb ea 	. . 
	set 6,d		;196d	cb f2 	. . 
	ld a,d			;196f	7a 	z 
	ld (0ffd3h),a		;1970	32 d3 ff 	2 . . 
	ld b,00ah		;1973	06 0a 	. . 
	ld c,a			;1975	4f 	O 
	call 0c916h		;1976	cd 16 c9 	. . . 
	ld a,(0c870h)		;1979	3a 70 c8 	: p . 
	ld c,a			;197c	4f 	O 
	ld b,00bh		;197d	06 0b 	. . 
	call 0c916h		;197f	cd 16 c9 	. . . 
	xor a			;1982	af 	. 
	ret			;1983	c9 	. 
	ld a,(0ffd3h)		;1984	3a d3 ff 	: . . 
	and 09fh		;1987	e6 9f 	. . 
	or c			;1989	b1 	. 
	ld (0ffd3h),a		;198a	32 d3 ff 	2 . . 
	ld c,a			;198d	4f 	O 
	ld b,00ah		;198e	06 0a 	. . 
	call 0c916h		;1990	cd 16 c9 	. . . 
	xor a			;1993	af 	. 
	ret			;1994	c9 	. 
	ld hl,0ffd1h		;1995	21 d1 ff 	! . . 
	set 0,(hl)		;1998	cb c6 	. . 
	xor a			;199a	af 	. 
	ret			;199b	c9 	. 
	ld hl,0ffd1h		;199c	21 d1 ff 	! . . 
	res 0,(hl)		;199f	cb 86 	. . 
	xor a			;19a1	af 	. 
	ret			;19a2	c9 	. 
	ld hl,0ffd1h		;19a3	21 d1 ff 	! . . 
	set 2,(hl)		;19a6	cb d6 	. . 
	xor a			;19a8	af 	. 
	ret			;19a9	c9 	. 
	ld hl,0ffd1h		;19aa	21 d1 ff 	! . . 
	res 2,(hl)		;19ad	cb 96 	. . 
	xor a			;19af	af 	. 
	ret			;19b0	c9 	. 
	ld hl,0ffd1h		;19b1	21 d1 ff 	! . . 
	set 1,(hl)		;19b4	cb ce 	. . 
	xor a			;19b6	af 	. 
	ret			;19b7	c9 	. 
	ld hl,0ffd1h		;19b8	21 d1 ff 	! . . 
	res 1,(hl)		;19bb	cb 8e 	. . 
	xor a			;19bd	af 	. 
	ret			;19be	c9 	. 
	ld a,(0ffd1h)		;19bf	3a d1 ff 	: . . 
	and 08fh		;19c2	e6 8f 	. . 
	or 010h		;19c4	f6 10 	. . 
	ld (0ffd1h),a		;19c6	32 d1 ff 	2 . . 
	xor a			;19c9	af 	. 
	ret			;19ca	c9 	. 
	ld a,(0ffd1h)		;19cb	3a d1 ff 	: . . 
	and 08fh		;19ce	e6 8f 	. . 
	or 000h		;19d0	f6 00 	. . 
	ld (0ffd1h),a		;19d2	32 d1 ff 	2 . . 
	xor a			;19d5	af 	. 
	ret			;19d6	c9 	. 
	ld a,(0ffd1h)		;19d7	3a d1 ff 	: . . 
	and 08fh		;19da	e6 8f 	. . 
	or 020h		;19dc	f6 20 	.   
	ld (0ffd1h),a		;19de	32 d1 ff 	2 . . 
	xor a			;19e1	af 	. 
	ret			;19e2	c9 	. 
	call 0ca01h		;19e3	cd 01 ca 	. . . 
	cp 001h		;19e6	fe 01 	. . 
	jr nz,$+3		;19e8	20 01 	  . 
	ld a,c			;19ea	79 	y 
	ld (0ffd8h),a		;19eb	32 d8 ff 	2 . . 
	cp 060h		;19ee	fe 60 	. ` 
	jp nc,0ca70h		;19f0	d2 70 ca 	. p . 
	sub 031h		;19f3	d6 31 	. 1 
	jp c,0ca70h		;19f5	da 70 ca 	. p . 
	call 0ca05h		;19f8	cd 05 ca 	. . . 
	or a			;19fb	b7 	. 
	jr z,$+116		;19fc	28 72 	( r 
	jp 0c6a3h		;19fe	c3 a3 c6 	. . . 
	ld hl,(0bffah)		;1a01	2a fa bf 	* . . 
	jp (hl)			;1a04	e9 	. 
	add a,a			;1a05	87 	. 
	ld hl,0ca12h		;1a06	21 12 ca 	! . . 
	ld d,000h		;1a09	16 00 	. . 
	ld e,a			;1a0b	5f 	_ 
	add hl,de			;1a0c	19 	. 
	ld e,(hl)			;1a0d	5e 	^ 
	inc hl			;1a0e	23 	# 
	ld d,(hl)			;1a0f	56 	V 
	ex de,hl			;1a10	eb 	. 
	jp (hl)			;1a11	e9 	. 
	ld b,d			;1a12	42 	B 
	call 0cd46h		;1a13	cd 46 cd 	. F . 
	ld a,d			;1a16	7a 	z 
	jp z,0ca7ah		;1a17	ca 7a ca 	. z . 
	ld a,d			;1a1a	7a 	z 
	jp z,0ca7ch		;1a1b	ca 7c ca 	. | . 
	cp a			;1a1e	bf 	. 
	ret			;1a1f	c9 	. 
	ld a,a			;1a20	7f 	 
	call z,0ca7ah		;1a21	cc 7a ca 	. z . 
	call nc,0f2cah		;1a24	d4 ca f2 	. . . 
	jp z,0cb1ch		;1a27	ca 1c cb 	. . . 
	ld l,d			;1a2a	6a 	j 
	res 3,a		;1a2b	cb 9f 	. . 
	res 7,e		;1a2d	cb bb 	. . 
	bit 7,h		;1a2f	cb 7c 	. | 
	jp z,0c875h		;1a31	ca 75 c8 	. u . 
	xor h			;1a34	ac 	. 
	ret z			;1a35	c8 	. 
	ld a,d			;1a36	7a 	z 
	jp z,0c942h		;1a37	ca 42 c9 	. B . 
	ld b,d			;1a3a	42 	B 
	ret			;1a3b	c9 	. 
	ld b,d			;1a3c	42 	B 
	ret			;1a3d	c9 	. 
	ld b,d			;1a3e	42 	B 
	ret			;1a3f	c9 	. 
	sub l			;1a40	95 	. 
	ret			;1a41	c9 	. 
	sbc a,h			;1a42	9c 	. 
	ret			;1a43	c9 	. 
	and e			;1a44	a3 	. 
	ret			;1a45	c9 	. 
	xor d			;1a46	aa 	. 
	ret			;1a47	c9 	. 
	or c			;1a48	b1 	. 
	ret			;1a49	c9 	. 
	cp b			;1a4a	b8 	. 
	ret			;1a4b	c9 	. 
	ld b,l			;1a4c	45 	E 
	call z,0ca7ah		;1a4d	cc 7a ca 	. z . 
	xor e			;1a50	ab 	. 
	call z,0ccdfh		;1a51	cc df cc 	. . . 
	ld a,d			;1a54	7a 	z 
	jp z,0cbdah		;1a55	ca da cb 	. . . 
	inc b			;1a58	04 	. 
	call z,0cc1bh		;1a59	cc 1b cc 	. . . 
	inc sp			;1a5c	33 	3 
	call z,0c9bfh		;1a5d	cc bf c9 	. . . 
	set 1,c		;1a60	cb c9 	. . 
	rst 10h			;1a62	d7 	. 
	ret			;1a63	c9 	. 
	cp a			;1a64	bf 	. 
	ret			;1a65	c9 	. 
	ld a,a			;1a66	7f 	 
	call z,0c8dfh		;1a67	cc df c8 	. . . 
	call m,095c8h		;1a6a	fc c8 95 	. . . 
	call z,0cd27h		;1a6d	cc 27 cd 	. ' . 
	xor a			;1a70	af 	. 
	ld (0ffd8h),a		;1a71	32 d8 ff 	2 . . 
	ld (0ffd9h),a		;1a74	32 d9 ff 	2 . . 
	jp 0c6a3h		;1a77	c3 a3 c6 	. . . 
	xor a			;1a7a	af 	. 
	ret			;1a7b	c9 	. 
	call 0cdd7h		;1a7c	cd d7 cd 	. . . 
	cp 001h		;1a7f	fe 01 	. . 
	jr nz,$+11		;1a81	20 09 	  . 
	ld a,c			;1a83	79 	y 
	cp 031h		;1a84	fe 31 	. 1 
	jr c,$+42		;1a86	38 28 	8 ( 
	cp 036h		;1a88	fe 36 	. 6 
	jr nc,$+38		;1a8a	30 24 	0 $ 
	call 0cab5h		;1a8c	cd b5 ca 	. . . 
	or a			;1a8f	b7 	. 
	ret nz			;1a90	c0 	. 
	ld a,(0ffdah)		;1a91	3a da ff 	: . . 
	and 00fh		;1a94	e6 0f 	. . 
	dec a			;1a96	3d 	= 
	add a,a			;1a97	87 	. 
	ld b,a			;1a98	47 	G 
	add a,a			;1a99	87 	. 
	ld c,a			;1a9a	4f 	O 
	add a,a			;1a9b	87 	. 
	add a,b			;1a9c	80 	. 
	add a,c			;1a9d	81 	. 
	add a,004h		;1a9e	c6 04 	. . 
	ld hl,(0bff4h)		;1aa0	2a f4 bf 	* . . 
	ld d,000h		;1aa3	16 00 	. . 
	ld e,a			;1aa5	5f 	_ 
	add hl,de			;1aa6	19 	. 
	ex de,hl			;1aa7	eb 	. 
	ld hl,0ffdbh		;1aa8	21 db ff 	! . . 
	ld bc,00009h		;1aab	01 09 00 	. . . 
	ldir		;1aae	ed b0 	. . 
	call 0cd51h		;1ab0	cd 51 cd 	. Q . 
	xor a			;1ab3	af 	. 
	ret			;1ab4	c9 	. 
	call 0c901h		;1ab5	cd 01 c9 	. . . 
	ld (hl),c			;1ab8	71 	q 
	cp 00ah		;1ab9	fe 0a 	. . 
	ret nz			;1abb	c0 	. 
	ld hl,0ffdbh		;1abc	21 db ff 	! . . 
	ld b,008h		;1abf	06 08 	. . 
	ld a,(hl)			;1ac1	7e 	~ 
	inc hl			;1ac2	23 	# 
	cp 07fh		;1ac3	fe 7f 	.  
	jr z,$+8		;1ac5	28 06 	( . 
	djnz $-6		;1ac7	10 f8 	. . 
	ld (hl),07fh		;1ac9	36 7f 	6  
	jr $+7		;1acb	18 05 	. . 
	ld hl,0ffe3h		;1acd	21 e3 ff 	! . . 
	ld (hl),020h		;1ad0	36 20 	6   
	xor a			;1ad2	af 	. 
	ret			;1ad3	c9 	. 
	call 0cdd7h		;1ad4	cd d7 cd 	. . . 
	cp 004h		;1ad7	fe 04 	. . 
	jr z,$+6		;1ad9	28 04 	( . 
	call 0c901h		;1adb	cd 01 c9 	. . . 
	ret			;1ade	c9 	. 
	ld a,c			;1adf	79 	y 
	sub 020h		;1ae0	d6 20 	.   
	ld e,a			;1ae2	5f 	_ 
	ld hl,0ffdah		;1ae3	21 da ff 	! . . 
	ld b,(hl)			;1ae6	46 	F 
	inc hl			;1ae7	23 	# 
	ld c,(hl)			;1ae8	4e 	N 
	inc hl			;1ae9	23 	# 
	ld d,(hl)			;1aea	56 	V 
	ld a,001h		;1aeb	3e 01 	> . 
	call 0c91dh		;1aed	cd 1d c9 	. . . 
	xor a			;1af0	af 	. 
	ret			;1af1	c9 	. 
	call 0cdd7h		;1af2	cd d7 cd 	. . . 
	cp 002h		;1af5	fe 02 	. . 
	jr z,$+6		;1af7	28 04 	( . 
	call 0c901h		;1af9	cd 01 c9 	. . . 
	ret			;1afc	c9 	. 
	ld a,c			;1afd	79 	y 
	sub 020h		;1afe	d6 20 	.   
	ld e,a			;1b00	5f 	_ 
	ld a,(0ffdah)		;1b01	3a da ff 	: . . 
	ld d,a			;1b04	57 	W 
	ld a,(0ffd3h)		;1b05	3a d3 ff 	: . . 
	and 060h		;1b08	e6 60 	. ` 
	or d			;1b0a	b2 	. 
	ld (0ffd3h),a		;1b0b	32 d3 ff 	2 . . 
	ld c,a			;1b0e	4f 	O 
	ld b,00ah		;1b0f	06 0a 	. . 
	call 0c916h		;1b11	cd 16 c9 	. . . 
	ld c,e			;1b14	4b 	K 
	ld b,00bh		;1b15	06 0b 	. . 
	call 0c916h		;1b17	cd 16 c9 	. . . 
	xor a			;1b1a	af 	. 
	ret			;1b1b	c9 	. 
	call 0cdd7h		;1b1c	cd d7 cd 	. . . 
	cp 004h		;1b1f	fe 04 	. . 
	jr z,$+6		;1b21	28 04 	( . 
	call 0c901h		;1b23	cd 01 c9 	. . . 
	ret			;1b26	c9 	. 
	ld a,c			;1b27	79 	y 
	sub 020h		;1b28	d6 20 	.   
	ld e,a			;1b2a	5f 	_ 
	ld a,04fh		;1b2b	3e 4f 	> O 
	cp e			;1b2d	bb 	. 
	jr c,$+58		;1b2e	38 38 	8 8 
	ld hl,0ffdah		;1b30	21 da ff 	! . . 
	ld b,(hl)			;1b33	46 	F 
	inc hl			;1b34	23 	# 
	ld a,(hl)			;1b35	7e 	~ 
	cp 018h		;1b36	fe 18 	. . 
	jr nc,$+48		;1b38	30 2e 	0 . 
	ld c,a			;1b3a	4f 	O 
	inc hl			;1b3b	23 	# 
	ld d,(hl)			;1b3c	56 	V 
	ld a,c			;1b3d	79 	y 
	cp b			;1b3e	b8 	. 
	jr c,$+41		;1b3f	38 27 	8 ' 
	ld a,e			;1b41	7b 	{ 
	cp d			;1b42	ba 	. 
	jr c,$+37		;1b43	38 23 	8 # 
	ld hl,0ffcdh		;1b45	21 cd ff 	! . . 
	ld (hl),c			;1b48	71 	q 
	inc hl			;1b49	23 	# 
	ld (hl),b			;1b4a	70 	p 
	inc hl			;1b4b	23 	# 
	ld (hl),e			;1b4c	73 	s 
	inc hl			;1b4d	23 	# 
	ld (hl),d			;1b4e	72 	r 
	ld a,001h		;1b4f	3e 01 	> . 
	ld (0ffc9h),a		;1b51	32 c9 ff 	2 . . 
	ld a,050h		;1b54	3e 50 	> P 
	sub e			;1b56	93 	. 
	ld e,a			;1b57	5f 	_ 
	ld a,d			;1b58	7a 	z 
	add a,e			;1b59	83 	. 
	ld hl,0ffd1h		;1b5a	21 d1 ff 	! . . 
	bit 3,(hl)		;1b5d	cb 5e 	. ^ 
	jr z,$+3		;1b5f	28 01 	( . 
	add a,a			;1b61	87 	. 
	ld (0ffc8h),a		;1b62	32 c8 ff 	2 . . 
	call 0cc1bh		;1b65	cd 1b cc 	. . . 
	xor a			;1b68	af 	. 
	ret			;1b69	c9 	. 
	call 0cdd7h		;1b6a	cd d7 cd 	. . . 
	cp 002h		;1b6d	fe 02 	. . 
	jr z,$+6		;1b6f	28 04 	( . 
	call 0c901h		;1b71	cd 01 c9 	. . . 
	ret			;1b74	c9 	. 
	ld a,c			;1b75	79 	y 
	sub 020h		;1b76	d6 20 	.   
	ld c,a			;1b78	4f 	O 
	ld a,04fh		;1b79	3e 4f 	> O 
	cp c			;1b7b	b9 	. 
	jr c,$+33		;1b7c	38 1f 	8 . 
	ld a,(0ffd1h)		;1b7e	3a d1 ff 	: . . 
	bit 3,a		;1b81	cb 5f 	. _ 
	jr z,$+5		;1b83	28 03 	( . 
	ld a,c			;1b85	79 	y 
	add a,a			;1b86	87 	. 
	ld c,a			;1b87	4f 	O 
	ld a,(0ffdah)		;1b88	3a da ff 	: . . 
	cp 019h		;1b8b	fe 19 	. . 
	jr nc,$+16		;1b8d	30 0e 	0 . 
	ld b,a			;1b8f	47 	G 
	ld (0ffcbh),a		;1b90	32 cb ff 	2 . . 
	ld a,c			;1b93	79 	y 
	ld (0ffcah),a		;1b94	32 ca ff 	2 . . 
	call 0c6f1h		;1b97	cd f1 c6 	. . . 
	call 0c71ch		;1b9a	cd 1c c7 	. . . 
	xor a			;1b9d	af 	. 
	ret			;1b9e	c9 	. 
	call 0cdd7h		;1b9f	cd d7 cd 	. . . 
	ld a,c			;1ba2	79 	y 
	sub 020h		;1ba3	d6 20 	.   
	ld c,a			;1ba5	4f 	O 
	ld a,04fh		;1ba6	3e 4f 	> O 
	cp c			;1ba8	b9 	. 
	jr c,$+16		;1ba9	38 0e 	8 . 
	ld a,(0ffcbh)		;1bab	3a cb ff 	: . . 
	ld b,a			;1bae	47 	G 
	ld a,c			;1baf	79 	y 
	ld (0ffcah),a		;1bb0	32 ca ff 	2 . . 
	call 0c6f1h		;1bb3	cd f1 c6 	. . . 
	call 0c71ch		;1bb6	cd 1c c7 	. . . 
	xor a			;1bb9	af 	. 
	ret			;1bba	c9 	. 
	call 0cdd7h		;1bbb	cd d7 cd 	. . . 
	cp 004h		;1bbe	fe 04 	. . 
	jr z,$+6		;1bc0	28 04 	( . 
	call 0c901h		;1bc2	cd 01 c9 	. . . 
	ret			;1bc5	c9 	. 
	ld a,c			;1bc6	79 	y 
	sub 020h		;1bc7	d6 20 	.   
	ld e,a			;1bc9	5f 	_ 
	ld hl,0ffdah		;1bca	21 da ff 	! . . 
	ld b,(hl)			;1bcd	46 	F 
	inc hl			;1bce	23 	# 
	ld c,(hl)			;1bcf	4e 	N 
	inc hl			;1bd0	23 	# 
	ld d,(hl)			;1bd1	56 	V 
	ld a,(0ffd2h)		;1bd2	3a d2 ff 	: . . 
	call 0c91dh		;1bd5	cd 1d c9 	. . . 
	xor a			;1bd8	af 	. 
	ret			;1bd9	c9 	. 
	ld bc,00780h		;1bda	01 80 07 	. . . 
	push ix		;1bdd	dd e5 	. . 
	pop hl			;1bdf	e1 	. 
	call 0c795h		;1be0	cd 95 c7 	. . . 
	ld a,(0ffd2h)		;1be3	3a d2 ff 	: . . 
	ld d,a			;1be6	57 	W 
	ld e,020h		;1be7	1e 20 	.   
	call 0c715h		;1be9	cd 15 c7 	. . . 
	ld a,(hl)			;1bec	7e 	~ 
	and d			;1bed	a2 	. 
	jr nz,$+11		;1bee	20 09 	  . 
	ld (hl),000h		;1bf0	36 00 	6 . 
	call 0c795h		;1bf2	cd 95 c7 	. . . 
	ld (hl),e			;1bf5	73 	s 
	call 0c795h		;1bf6	cd 95 c7 	. . . 
	inc hl			;1bf9	23 	# 
	dec bc			;1bfa	0b 	. 
	ld a,b			;1bfb	78 	x 
	or c			;1bfc	b1 	. 
	jr nz,$-20		;1bfd	20 ea 	  . 
	call 0c79eh		;1bff	cd 9e c7 	. . . 
	xor a			;1c02	af 	. 
	ret			;1c03	c9 	. 
	ld a,(0ffd0h)		;1c04	3a d0 ff 	: . . 
	ld c,a			;1c07	4f 	O 
	ld a,(0ffceh)		;1c08	3a ce ff 	: . . 
	ld b,a			;1c0b	47 	G 
	ld a,(0ffcfh)		;1c0c	3a cf ff 	: . . 
	ld e,a			;1c0f	5f 	_ 
	ld a,(0ffcdh)		;1c10	3a cd ff 	: . . 
	ld d,a			;1c13	57 	W 
	call 0c805h		;1c14	cd 05 c8 	. . . 
	call 0cc1bh		;1c17	cd 1b cc 	. . . 
	ret			;1c1a	c9 	. 
	ld a,(0ffceh)		;1c1b	3a ce ff 	: . . 
	ld b,a			;1c1e	47 	G 
	ld a,(0ffd0h)		;1c1f	3a d0 ff 	: . . 
	ld c,a			;1c22	4f 	O 
	call 0c6f1h		;1c23	cd f1 c6 	. . . 
	call 0c71ch		;1c26	cd 1c c7 	. . . 
	ld a,b			;1c29	78 	x 
	ld (0ffcbh),a		;1c2a	32 cb ff 	2 . . 
	ld a,c			;1c2d	79 	y 
	ld (0ffcah),a		;1c2e	32 ca ff 	2 . . 
	xor a			;1c31	af 	. 
	ret			;1c32	c9 	. 
	call 0c764h		;1c33	cd 64 c7 	. d . 
	ld a,001h		;1c36	3e 01 	> . 
	ld (0ffc8h),a		;1c38	32 c8 ff 	2 . . 
	ld a,04fh		;1c3b	3e 4f 	> O 
	ld (0ffcfh),a		;1c3d	32 cf ff 	2 . . 
	call 0c8bfh		;1c40	cd bf c8 	. . . 
	xor a			;1c43	af 	. 
	ret			;1c44	c9 	. 
	ld b,000h		;1c45	06 00 	. . 
	ld c,000h		;1c47	0e 00 	. . 
	push bc			;1c49	c5 	. 
	call 0cdf4h		;1c4a	cd f4 cd 	. . . 
	ld c,d			;1c4d	4a 	J 
	push de			;1c4e	d5 	. 
	call 0ffa0h		;1c4f	cd a0 ff 	. . . 
	pop de			;1c52	d1 	. 
	pop bc			;1c53	c1 	. 
	bit 3,e		;1c54	cb 5b 	. [ 
	jr z,$+15		;1c56	28 0d 	( . 
	inc c			;1c58	0c 	. 
	ld a,c			;1c59	79 	y 
	cp 050h		;1c5a	fe 50 	. P 
	jr z,$+15		;1c5c	28 0d 	( . 
	push bc			;1c5e	c5 	. 
	ld c,020h		;1c5f	0e 20 	.   
	call 0ffa0h		;1c61	cd a0 ff 	. . . 
	pop bc			;1c64	c1 	. 
	inc c			;1c65	0c 	. 
	ld a,c			;1c66	79 	y 
	cp 050h		;1c67	fe 50 	. P 
	jr nz,$-32		;1c69	20 de 	  . 
	push bc			;1c6b	c5 	. 
	ld c,00dh		;1c6c	0e 0d 	. . 
	call 0ffa0h		;1c6e	cd a0 ff 	. . . 
	ld c,00ah		;1c71	0e 0a 	. . 
	call 0ffa0h		;1c73	cd a0 ff 	. . . 
	pop bc			;1c76	c1 	. 
	inc b			;1c77	04 	. 
	ld a,b			;1c78	78 	x 
	cp 018h		;1c79	fe 18 	. . 
	jr nz,$-52		;1c7b	20 ca 	  . 
	xor a			;1c7d	af 	. 
	ret			;1c7e	c9 	. 
	call 0cdd7h		;1c7f	cd d7 cd 	. . . 
	ld a,c			;1c82	79 	y 
	and 00fh		;1c83	e6 0f 	. . 
	rlca			;1c85	07 	. 
	rlca			;1c86	07 	. 
	rlca			;1c87	07 	. 
	rlca			;1c88	07 	. 
	ld b,a			;1c89	47 	G 
	ld a,(0ffd1h)		;1c8a	3a d1 ff 	: . . 
	and 00fh		;1c8d	e6 0f 	. . 
	or b			;1c8f	b0 	. 
	ld (0ffd1h),a		;1c90	32 d1 ff 	2 . . 
	xor a			;1c93	af 	. 
	ret			;1c94	c9 	. 
	call 0cdd7h		;1c95	cd d7 cd 	. . . 
	ld a,c			;1c98	79 	y 
	cp 030h		;1c99	fe 30 	. 0 
	jr z,$+16		;1c9b	28 0e 	( . 
	cp 031h		;1c9d	fe 31 	. 1 
	jr z,$+30		;1c9f	28 1c 	( . 
	cp 032h		;1ca1	fe 32 	. 2 
	jr z,$+60		;1ca3	28 3a 	( : 
	cp 033h		;1ca5	fe 33 	. 3 
	jr z,$+77		;1ca7	28 4b 	( K 
	xor a			;1ca9	af 	. 
	ret			;1caa	c9 	. 
	ld a,(0ffcbh)		;1cab	3a cb ff 	: . . 
	ld b,a			;1cae	47 	G 
	ld d,a			;1caf	57 	W 
	ld a,(0ffcah)		;1cb0	3a ca ff 	: . . 
	ld c,a			;1cb3	4f 	O 
	ld a,(0ffcfh)		;1cb4	3a cf ff 	: . . 
	ld e,a			;1cb7	5f 	_ 
	call 0c805h		;1cb8	cd 05 c8 	. . . 
	xor a			;1cbb	af 	. 
	ret			;1cbc	c9 	. 
	ld a,(0ffceh)		;1cbd	3a ce ff 	: . . 
	ld b,a			;1cc0	47 	G 
	ld a,(0ffcbh)		;1cc1	3a cb ff 	: . . 
	ld (0ffceh),a		;1cc4	32 ce ff 	2 . . 
	ld a,(0ffc9h)		;1cc7	3a c9 ff 	: . . 
	ld c,a			;1cca	4f 	O 
	ld a,001h		;1ccb	3e 01 	> . 
	ld (0ffc9h),a		;1ccd	32 c9 ff 	2 . . 
	push bc			;1cd0	c5 	. 
	call 0c62eh		;1cd1	cd 2e c6 	. . . 
	pop bc			;1cd4	c1 	. 
	ld a,b			;1cd5	78 	x 
	ld (0ffceh),a		;1cd6	32 ce ff 	2 . . 
	ld a,c			;1cd9	79 	y 
	ld (0ffc9h),a		;1cda	32 c9 ff 	2 . . 
	xor a			;1cdd	af 	. 
	ret			;1cde	c9 	. 
	ld a,(0ffcbh)		;1cdf	3a cb ff 	: . . 
	ld b,a			;1ce2	47 	G 
	ld a,(0ffcah)		;1ce3	3a ca ff 	: . . 
	ld c,a			;1ce6	4f 	O 
	ld a,(0ffcdh)		;1ce7	3a cd ff 	: . . 
	ld d,a			;1cea	57 	W 
	ld a,(0ffcfh)		;1ceb	3a cf ff 	: . . 
	ld e,a			;1cee	5f 	_ 
	call 0c805h		;1cef	cd 05 c8 	. . . 
	xor a			;1cf2	af 	. 
	ret			;1cf3	c9 	. 
	ld a,(0ffceh)		;1cf4	3a ce ff 	: . . 
	ld b,a			;1cf7	47 	G 
	ld a,(0ffcbh)		;1cf8	3a cb ff 	: . . 
	ld c,a			;1cfb	4f 	O 
	ld a,(0ffcdh)		;1cfc	3a cd ff 	: . . 
	cp c			;1cff	b9 	. 
	jr z,$+24		;1d00	28 16 	( . 
	ld a,c			;1d02	79 	y 
	ld (0ffceh),a		;1d03	32 ce ff 	2 . . 
	push bc			;1d06	c5 	. 
	call 0c830h		;1d07	cd 30 c8 	. 0 . 
	pop bc			;1d0a	c1 	. 
	ld a,b			;1d0b	78 	x 
	ld (0ffceh),a		;1d0c	32 ce ff 	2 . . 
	ld a,(0ffd0h)		;1d0f	3a d0 ff 	: . . 
	ld c,a			;1d12	4f 	O 
	call 0cb9fh		;1d13	cd 9f cb 	. . . 
	xor a			;1d16	af 	. 
	ret			;1d17	c9 	. 
	ld b,a			;1d18	47 	G 
	ld d,a			;1d19	57 	W 
	ld a,(0ffcfh)		;1d1a	3a cf ff 	: . . 
	ld e,a			;1d1d	5f 	_ 
	ld a,(0ffd0h)		;1d1e	3a d0 ff 	: . . 
	ld c,a			;1d21	4f 	O 
	call 0c805h		;1d22	cd 05 c8 	. . . 
	jr $-22		;1d25	18 e8 	. . 
	call 0cdd7h		;1d27	cd d7 cd 	. . . 
	cp 002h		;1d2a	fe 02 	. . 
	jp nc,0cd8ah		;1d2c	d2 8a cd 	. . . 
	ld a,c			;1d2f	79 	y 
	cp 030h		;1d30	fe 30 	. 0 
	jr z,$+16		;1d32	28 0e 	( . 
	cp 031h		;1d34	fe 31 	. 1 
	jr z,$+16		;1d36	28 0e 	( . 
	cp 034h		;1d38	fe 34 	. 4 
	jr z,$+23		;1d3a	28 15 	( . 
	cp 035h		;1d3c	fe 35 	. 5 
	jr z,$+76		;1d3e	28 4a 	( J 
	xor a			;1d40	af 	. 
	ret			;1d41	c9 	. 
	ld b,019h		;1d42	06 19 	. . 
	jr $+4		;1d44	18 02 	. . 
	ld b,018h		;1d46	06 18 	. . 
	ld a,006h		;1d48	3e 06 	> . 
	out (0a0h),a		;1d4a	d3 a0 	. . 
	ld a,b			;1d4c	78 	x 
	out (0a1h),a		;1d4d	d3 a1 	. . 
	xor a			;1d4f	af 	. 
	ret			;1d50	c9 	. 
	ld hl,(0bff4h)		;1d51	2a f4 bf 	* . . 
	ex de,hl			;1d54	eb 	. 
	ld b,018h		;1d55	06 18 	. . 
	ld c,000h		;1d57	0e 00 	. . 
	call 0c6f1h		;1d59	cd f1 c6 	. . . 
	ld a,(0bfeah)		;1d5c	3a ea bf 	: . . 
	ld c,a			;1d5f	4f 	O 
	ld b,046h		;1d60	06 46 	. F 
	ld a,b			;1d62	78 	x 
	ld (0ffdah),a		;1d63	32 da ff 	2 . . 
	call 0c715h		;1d66	cd 15 c7 	. . . 
	ld a,(de)			;1d69	1a 	. 
	ld (hl),a			;1d6a	77 	w 
	call 0c795h		;1d6b	cd 95 c7 	. . . 
	ld (hl),c			;1d6e	71 	q 
	call 0c79eh		;1d6f	cd 9e c7 	. . . 
	inc de			;1d72	13 	. 
	inc hl			;1d73	23 	# 
	djnz $-14		;1d74	10 f0 	. . 
	ld a,(0ffdah)		;1d76	3a da ff 	: . . 
	or a			;1d79	b7 	. 
	jr z,$+14		;1d7a	28 0c 	( . 
	ld b,00ah		;1d7c	06 0a 	. . 
	ld a,(0bfebh)		;1d7e	3a eb bf 	: . . 
	ld c,a			;1d81	4f 	O 
	xor a			;1d82	af 	. 
	ld (0ffdah),a		;1d83	32 da ff 	2 . . 
	jr $-32		;1d86	18 de 	. . 
	xor a			;1d88	af 	. 
	ret			;1d89	c9 	. 
	ld a,c			;1d8a	79 	y 
	cp 00dh		;1d8b	fe 0d 	. . 
	jr z,$+40		;1d8d	28 26 	( & 
	ld a,(0ffd9h)		;1d8f	3a d9 ff 	: . . 
	cp 001h		;1d92	fe 01 	. . 
	jr z,$+6		;1d94	28 04 	( . 
	call 0cdb7h		;1d96	cd b7 cd 	. . . 
	ret			;1d99	c9 	. 
	ld b,018h		;1d9a	06 18 	. . 
	ld c,000h		;1d9c	0e 00 	. . 
	call 0c6f1h		;1d9e	cd f1 c6 	. . . 
	ld (0ffdah),hl		;1da1	22 da ff 	" . . 
	ld a,002h		;1da4	3e 02 	> . 
	ld (0ffd9h),a		;1da6	32 d9 ff 	2 . . 
	ld b,046h		;1da9	06 46 	. F 
	ld c,020h		;1dab	0e 20 	.   
	call 0c715h		;1dad	cd 15 c7 	. . . 
	ld (hl),c			;1db0	71 	q 
	inc hl			;1db1	23 	# 
	djnz $-5		;1db2	10 f9 	. . 
	ret			;1db4	c9 	. 
	xor a			;1db5	af 	. 
	ret			;1db6	c9 	. 
	ld b,a			;1db7	47 	G 
	inc a			;1db8	3c 	< 
	ld (0ffd9h),a		;1db9	32 d9 ff 	2 . . 
	ld hl,(0ffdah)		;1dbc	2a da ff 	* . . 
	call 0c715h		;1dbf	cd 15 c7 	. . . 
	ld (hl),c			;1dc2	71 	q 
	ld a,(0bfebh)		;1dc3	3a eb bf 	: . . 
	call 0c795h		;1dc6	cd 95 c7 	. . . 
	ld (hl),a			;1dc9	77 	w 
	call 0c79eh		;1dca	cd 9e c7 	. . . 
	inc hl			;1dcd	23 	# 
	ld (0ffdah),hl		;1dce	22 da ff 	" . . 
	ld a,b			;1dd1	78 	x 
	cp 047h		;1dd2	fe 47 	. G 
	ret nz			;1dd4	c0 	. 
	xor a			;1dd5	af 	. 
	ret			;1dd6	c9 	. 
	ld a,(0ffd9h)		;1dd7	3a d9 ff 	: . . 
	or a			;1dda	b7 	. 
	ret nz			;1ddb	c0 	. 
	inc a			;1ddc	3c 	< 
	ld (0ffd9h),a		;1ddd	32 d9 ff 	2 . . 
	pop hl			;1de0	e1 	. 
	ret			;1de1	c9 	. 
	call 0c69ah		;1de2	cd 9a c6 	. . . 
	call 0c6f1h		;1de5	cd f1 c6 	. . . 
	call 0c715h		;1de8	cd 15 c7 	. . . 
	ld (hl),d			;1deb	72 	r 
	call 0c795h		;1dec	cd 95 c7 	. . . 
	ld (hl),e			;1def	73 	s 
	call 0c79eh		;1df0	cd 9e c7 	. . . 
	ret			;1df3	c9 	. 
	call 0c69ah		;1df4	cd 9a c6 	. . . 
	call 0c6f1h		;1df7	cd f1 c6 	. . . 
	call 0c715h		;1dfa	cd 15 c7 	. . . 
	ld d,(hl)			;1dfd	56 	V 
	call 0c795h		;1dfe	cd 95 c7 	. . . 
	ld e,(hl)			;1e01	5e 	^ 
	call 0c79eh		;1e02	cd 9e c7 	. . . 
	ret			;1e05	c9 	. 
	nop			;1e06	00 	. 
	nop			;1e07	00 	. 
	nop			;1e08	00 	. 
	nop			;1e09	00 	. 
	nop			;1e0a	00 	. 
	nop			;1e0b	00 	. 
	nop			;1e0c	00 	. 
	nop			;1e0d	00 	. 
	nop			;1e0e	00 	. 
	nop			;1e0f	00 	. 
	nop			;1e10	00 	. 
	nop			;1e11	00 	. 
	nop			;1e12	00 	. 
	nop			;1e13	00 	. 
	nop			;1e14	00 	. 
	nop			;1e15	00 	. 
	nop			;1e16	00 	. 
	nop			;1e17	00 	. 
	nop			;1e18	00 	. 
	nop			;1e19	00 	. 
	nop			;1e1a	00 	. 
	nop			;1e1b	00 	. 
	nop			;1e1c	00 	. 
	nop			;1e1d	00 	. 
	nop			;1e1e	00 	. 
	nop			;1e1f	00 	. 
	nop			;1e20	00 	. 
	nop			;1e21	00 	. 
	nop			;1e22	00 	. 
	nop			;1e23	00 	. 
	nop			;1e24	00 	. 
	nop			;1e25	00 	. 
	nop			;1e26	00 	. 
	nop			;1e27	00 	. 
	nop			;1e28	00 	. 
	nop			;1e29	00 	. 
	nop			;1e2a	00 	. 
	nop			;1e2b	00 	. 
	nop			;1e2c	00 	. 
	nop			;1e2d	00 	. 
	nop			;1e2e	00 	. 
	nop			;1e2f	00 	. 
	nop			;1e30	00 	. 
	nop			;1e31	00 	. 
	nop			;1e32	00 	. 
	nop			;1e33	00 	. 
	nop			;1e34	00 	. 
	nop			;1e35	00 	. 
	nop			;1e36	00 	. 
	nop			;1e37	00 	. 
	nop			;1e38	00 	. 
	nop			;1e39	00 	. 
	nop			;1e3a	00 	. 
	nop			;1e3b	00 	. 
	nop			;1e3c	00 	. 
	nop			;1e3d	00 	. 
	nop			;1e3e	00 	. 
	nop			;1e3f	00 	. 
	nop			;1e40	00 	. 
	nop			;1e41	00 	. 
	nop			;1e42	00 	. 
	nop			;1e43	00 	. 
	nop			;1e44	00 	. 
	nop			;1e45	00 	. 
	nop			;1e46	00 	. 
	nop			;1e47	00 	. 
	nop			;1e48	00 	. 
	nop			;1e49	00 	. 
	nop			;1e4a	00 	. 
	nop			;1e4b	00 	. 
	nop			;1e4c	00 	. 
	nop			;1e4d	00 	. 
	nop			;1e4e	00 	. 
	nop			;1e4f	00 	. 
	nop			;1e50	00 	. 
	nop			;1e51	00 	. 
	nop			;1e52	00 	. 
	nop			;1e53	00 	. 
	nop			;1e54	00 	. 
	nop			;1e55	00 	. 
	nop			;1e56	00 	. 
	nop			;1e57	00 	. 
	nop			;1e58	00 	. 
	nop			;1e59	00 	. 
	nop			;1e5a	00 	. 
	nop			;1e5b	00 	. 
	nop			;1e5c	00 	. 
	nop			;1e5d	00 	. 
	nop			;1e5e	00 	. 
	nop			;1e5f	00 	. 
	nop			;1e60	00 	. 
	nop			;1e61	00 	. 
	nop			;1e62	00 	. 
	nop			;1e63	00 	. 
	nop			;1e64	00 	. 
	nop			;1e65	00 	. 
	nop			;1e66	00 	. 
	nop			;1e67	00 	. 
	nop			;1e68	00 	. 
	nop			;1e69	00 	. 
	nop			;1e6a	00 	. 
	nop			;1e6b	00 	. 
	nop			;1e6c	00 	. 
	nop			;1e6d	00 	. 
	nop			;1e6e	00 	. 
	nop			;1e6f	00 	. 
	nop			;1e70	00 	. 
	nop			;1e71	00 	. 
	nop			;1e72	00 	. 
	nop			;1e73	00 	. 
	nop			;1e74	00 	. 
	nop			;1e75	00 	. 
	nop			;1e76	00 	. 
	nop			;1e77	00 	. 
	nop			;1e78	00 	. 
	nop			;1e79	00 	. 
	nop			;1e7a	00 	. 
	nop			;1e7b	00 	. 
	nop			;1e7c	00 	. 
	nop			;1e7d	00 	. 
	nop			;1e7e	00 	. 
	nop			;1e7f	00 	. 
	nop			;1e80	00 	. 
	nop			;1e81	00 	. 
	nop			;1e82	00 	. 
	nop			;1e83	00 	. 
	nop			;1e84	00 	. 
	nop			;1e85	00 	. 
	nop			;1e86	00 	. 
	nop			;1e87	00 	. 
	nop			;1e88	00 	. 
	nop			;1e89	00 	. 
	nop			;1e8a	00 	. 
	nop			;1e8b	00 	. 
	nop			;1e8c	00 	. 
	nop			;1e8d	00 	. 
	nop			;1e8e	00 	. 
	nop			;1e8f	00 	. 
	nop			;1e90	00 	. 
	nop			;1e91	00 	. 
	nop			;1e92	00 	. 
	nop			;1e93	00 	. 
	nop			;1e94	00 	. 
	nop			;1e95	00 	. 
	nop			;1e96	00 	. 
	nop			;1e97	00 	. 
	nop			;1e98	00 	. 
	nop			;1e99	00 	. 
	nop			;1e9a	00 	. 
	nop			;1e9b	00 	. 
	nop			;1e9c	00 	. 
	nop			;1e9d	00 	. 
	nop			;1e9e	00 	. 
	nop			;1e9f	00 	. 
	nop			;1ea0	00 	. 
	nop			;1ea1	00 	. 
	nop			;1ea2	00 	. 
	nop			;1ea3	00 	. 
	nop			;1ea4	00 	. 
	nop			;1ea5	00 	. 
	nop			;1ea6	00 	. 
	nop			;1ea7	00 	. 
	nop			;1ea8	00 	. 
	nop			;1ea9	00 	. 
	nop			;1eaa	00 	. 
	nop			;1eab	00 	. 
	nop			;1eac	00 	. 
	nop			;1ead	00 	. 
	nop			;1eae	00 	. 
	nop			;1eaf	00 	. 
	nop			;1eb0	00 	. 
	nop			;1eb1	00 	. 
	nop			;1eb2	00 	. 
	nop			;1eb3	00 	. 
	nop			;1eb4	00 	. 
	nop			;1eb5	00 	. 
	nop			;1eb6	00 	. 
	nop			;1eb7	00 	. 
	nop			;1eb8	00 	. 
	nop			;1eb9	00 	. 
	nop			;1eba	00 	. 
	nop			;1ebb	00 	. 
	nop			;1ebc	00 	. 
	nop			;1ebd	00 	. 
	nop			;1ebe	00 	. 
	nop			;1ebf	00 	. 
	nop			;1ec0	00 	. 
	nop			;1ec1	00 	. 
	nop			;1ec2	00 	. 
	nop			;1ec3	00 	. 
	nop			;1ec4	00 	. 
	nop			;1ec5	00 	. 
	nop			;1ec6	00 	. 
	nop			;1ec7	00 	. 
	nop			;1ec8	00 	. 
	nop			;1ec9	00 	. 
	nop			;1eca	00 	. 
	nop			;1ecb	00 	. 
	nop			;1ecc	00 	. 
	nop			;1ecd	00 	. 
	nop			;1ece	00 	. 
	nop			;1ecf	00 	. 
	nop			;1ed0	00 	. 
	nop			;1ed1	00 	. 
	nop			;1ed2	00 	. 
	nop			;1ed3	00 	. 
	nop			;1ed4	00 	. 
	nop			;1ed5	00 	. 
	nop			;1ed6	00 	. 
	nop			;1ed7	00 	. 
	nop			;1ed8	00 	. 
	nop			;1ed9	00 	. 
	nop			;1eda	00 	. 
	nop			;1edb	00 	. 
	nop			;1edc	00 	. 
	nop			;1edd	00 	. 
	nop			;1ede	00 	. 
	nop			;1edf	00 	. 
	nop			;1ee0	00 	. 
	nop			;1ee1	00 	. 
	nop			;1ee2	00 	. 
	nop			;1ee3	00 	. 
	nop			;1ee4	00 	. 
	nop			;1ee5	00 	. 
	nop			;1ee6	00 	. 
	nop			;1ee7	00 	. 
	nop			;1ee8	00 	. 
	nop			;1ee9	00 	. 
	nop			;1eea	00 	. 
	nop			;1eeb	00 	. 
	nop			;1eec	00 	. 
	nop			;1eed	00 	. 
	nop			;1eee	00 	. 
	nop			;1eef	00 	. 
	nop			;1ef0	00 	. 
	nop			;1ef1	00 	. 
	nop			;1ef2	00 	. 
	nop			;1ef3	00 	. 
	nop			;1ef4	00 	. 
	nop			;1ef5	00 	. 
	nop			;1ef6	00 	. 
	nop			;1ef7	00 	. 
	nop			;1ef8	00 	. 
	nop			;1ef9	00 	. 
	nop			;1efa	00 	. 
	nop			;1efb	00 	. 
	nop			;1efc	00 	. 
	nop			;1efd	00 	. 
	nop			;1efe	00 	. 
	nop			;1eff	00 	. 
	nop			;1f00	00 	. 
	nop			;1f01	00 	. 
	nop			;1f02	00 	. 
	nop			;1f03	00 	. 
	nop			;1f04	00 	. 
	nop			;1f05	00 	. 
	nop			;1f06	00 	. 
	nop			;1f07	00 	. 
	nop			;1f08	00 	. 
	nop			;1f09	00 	. 
	nop			;1f0a	00 	. 
	nop			;1f0b	00 	. 
	nop			;1f0c	00 	. 
	nop			;1f0d	00 	. 
	nop			;1f0e	00 	. 
	nop			;1f0f	00 	. 
	nop			;1f10	00 	. 
	nop			;1f11	00 	. 
	nop			;1f12	00 	. 
	nop			;1f13	00 	. 
	nop			;1f14	00 	. 
	nop			;1f15	00 	. 
	nop			;1f16	00 	. 
	nop			;1f17	00 	. 
	nop			;1f18	00 	. 
	nop			;1f19	00 	. 
	nop			;1f1a	00 	. 
	nop			;1f1b	00 	. 
	nop			;1f1c	00 	. 
	nop			;1f1d	00 	. 
	nop			;1f1e	00 	. 
	nop			;1f1f	00 	. 
	nop			;1f20	00 	. 
	nop			;1f21	00 	. 
	nop			;1f22	00 	. 
	nop			;1f23	00 	. 
	nop			;1f24	00 	. 
	nop			;1f25	00 	. 
	nop			;1f26	00 	. 
	nop			;1f27	00 	. 
	nop			;1f28	00 	. 
	nop			;1f29	00 	. 
	nop			;1f2a	00 	. 
	nop			;1f2b	00 	. 
	nop			;1f2c	00 	. 
	nop			;1f2d	00 	. 
	nop			;1f2e	00 	. 
	nop			;1f2f	00 	. 
	nop			;1f30	00 	. 
	nop			;1f31	00 	. 
	nop			;1f32	00 	. 
	nop			;1f33	00 	. 
	nop			;1f34	00 	. 
	nop			;1f35	00 	. 
	nop			;1f36	00 	. 
	nop			;1f37	00 	. 
	nop			;1f38	00 	. 
	nop			;1f39	00 	. 
	nop			;1f3a	00 	. 
	nop			;1f3b	00 	. 
	nop			;1f3c	00 	. 
	nop			;1f3d	00 	. 
	nop			;1f3e	00 	. 
	nop			;1f3f	00 	. 
	nop			;1f40	00 	. 
	nop			;1f41	00 	. 
	nop			;1f42	00 	. 
	nop			;1f43	00 	. 
	nop			;1f44	00 	. 
	nop			;1f45	00 	. 
	nop			;1f46	00 	. 
	nop			;1f47	00 	. 
	nop			;1f48	00 	. 
	nop			;1f49	00 	. 
	nop			;1f4a	00 	. 
	nop			;1f4b	00 	. 
	nop			;1f4c	00 	. 
	nop			;1f4d	00 	. 
	nop			;1f4e	00 	. 
	nop			;1f4f	00 	. 
	nop			;1f50	00 	. 
	nop			;1f51	00 	. 
	nop			;1f52	00 	. 
	nop			;1f53	00 	. 
	nop			;1f54	00 	. 
	nop			;1f55	00 	. 
	nop			;1f56	00 	. 
	nop			;1f57	00 	. 
	nop			;1f58	00 	. 
	nop			;1f59	00 	. 
	nop			;1f5a	00 	. 
	nop			;1f5b	00 	. 
	nop			;1f5c	00 	. 
	nop			;1f5d	00 	. 
	nop			;1f5e	00 	. 
	nop			;1f5f	00 	. 
	nop			;1f60	00 	. 
	nop			;1f61	00 	. 
	nop			;1f62	00 	. 
	nop			;1f63	00 	. 
	nop			;1f64	00 	. 
	nop			;1f65	00 	. 
	nop			;1f66	00 	. 
	nop			;1f67	00 	. 
	nop			;1f68	00 	. 
	nop			;1f69	00 	. 
	nop			;1f6a	00 	. 
	nop			;1f6b	00 	. 
	nop			;1f6c	00 	. 
	nop			;1f6d	00 	. 
	nop			;1f6e	00 	. 
	nop			;1f6f	00 	. 
	nop			;1f70	00 	. 
	nop			;1f71	00 	. 
	nop			;1f72	00 	. 
	nop			;1f73	00 	. 
	nop			;1f74	00 	. 
	nop			;1f75	00 	. 
	nop			;1f76	00 	. 
	nop			;1f77	00 	. 
	nop			;1f78	00 	. 
	nop			;1f79	00 	. 
	nop			;1f7a	00 	. 
	nop			;1f7b	00 	. 
	nop			;1f7c	00 	. 
	nop			;1f7d	00 	. 
	nop			;1f7e	00 	. 
	nop			;1f7f	00 	. 
	nop			;1f80	00 	. 
	nop			;1f81	00 	. 
	nop			;1f82	00 	. 
	nop			;1f83	00 	. 
	nop			;1f84	00 	. 
	nop			;1f85	00 	. 
	nop			;1f86	00 	. 
	nop			;1f87	00 	. 
	nop			;1f88	00 	. 
	nop			;1f89	00 	. 
	nop			;1f8a	00 	. 
	nop			;1f8b	00 	. 
	nop			;1f8c	00 	. 
	nop			;1f8d	00 	. 
	nop			;1f8e	00 	. 
	nop			;1f8f	00 	. 
	nop			;1f90	00 	. 
	nop			;1f91	00 	. 
	nop			;1f92	00 	. 
	nop			;1f93	00 	. 
	nop			;1f94	00 	. 
	nop			;1f95	00 	. 
	nop			;1f96	00 	. 
	nop			;1f97	00 	. 
	nop			;1f98	00 	. 
	nop			;1f99	00 	. 
	nop			;1f9a	00 	. 
	nop			;1f9b	00 	. 
	nop			;1f9c	00 	. 
	nop			;1f9d	00 	. 
	nop			;1f9e	00 	. 
	nop			;1f9f	00 	. 
	nop			;1fa0	00 	. 
	nop			;1fa1	00 	. 
	nop			;1fa2	00 	. 
	nop			;1fa3	00 	. 
	nop			;1fa4	00 	. 
	nop			;1fa5	00 	. 
	nop			;1fa6	00 	. 
	nop			;1fa7	00 	. 
	nop			;1fa8	00 	. 
	nop			;1fa9	00 	. 
	nop			;1faa	00 	. 
	nop			;1fab	00 	. 
	nop			;1fac	00 	. 
	nop			;1fad	00 	. 
	nop			;1fae	00 	. 
	nop			;1faf	00 	. 
	nop			;1fb0	00 	. 
	nop			;1fb1	00 	. 
	nop			;1fb2	00 	. 
	nop			;1fb3	00 	. 
	nop			;1fb4	00 	. 
	nop			;1fb5	00 	. 
	nop			;1fb6	00 	. 
	nop			;1fb7	00 	. 
	nop			;1fb8	00 	. 
	nop			;1fb9	00 	. 
	nop			;1fba	00 	. 
	nop			;1fbb	00 	. 
	nop			;1fbc	00 	. 
	nop			;1fbd	00 	. 
	nop			;1fbe	00 	. 
	nop			;1fbf	00 	. 
	nop			;1fc0	00 	. 
	nop			;1fc1	00 	. 
	nop			;1fc2	00 	. 
	nop			;1fc3	00 	. 
	nop			;1fc4	00 	. 
	nop			;1fc5	00 	. 
	nop			;1fc6	00 	. 
	nop			;1fc7	00 	. 
	nop			;1fc8	00 	. 
	nop			;1fc9	00 	. 
	nop			;1fca	00 	. 
	nop			;1fcb	00 	. 
	nop			;1fcc	00 	. 
	nop			;1fcd	00 	. 
	nop			;1fce	00 	. 
	nop			;1fcf	00 	. 
	nop			;1fd0	00 	. 
	nop			;1fd1	00 	. 
	nop			;1fd2	00 	. 
	nop			;1fd3	00 	. 
	nop			;1fd4	00 	. 
	nop			;1fd5	00 	. 
	nop			;1fd6	00 	. 
	nop			;1fd7	00 	. 
	nop			;1fd8	00 	. 
	nop			;1fd9	00 	. 
	nop			;1fda	00 	. 
	nop			;1fdb	00 	. 
	nop			;1fdc	00 	. 
	nop			;1fdd	00 	. 
	nop			;1fde	00 	. 
	nop			;1fdf	00 	. 
	nop			;1fe0	00 	. 
	nop			;1fe1	00 	. 
	nop			;1fe2	00 	. 
	nop			;1fe3	00 	. 
	nop			;1fe4	00 	. 
	nop			;1fe5	00 	. 
	nop			;1fe6	00 	. 
	nop			;1fe7	00 	. 
	nop			;1fe8	00 	. 
	nop			;1fe9	00 	. 
	nop			;1fea	00 	. 
	nop			;1feb	00 	. 
	nop			;1fec	00 	. 
	nop			;1fed	00 	. 
	nop			;1fee	00 	. 
	nop			;1fef	00 	. 
	nop			;1ff0	00 	. 
	nop			;1ff1	00 	. 
	nop			;1ff2	00 	. 
	nop			;1ff3	00 	. 
	nop			;1ff4	00 	. 
	nop			;1ff5	00 	. 
	nop			;1ff6	00 	. 
	nop			;1ff7	00 	. 
	nop			;1ff8	00 	. 
	nop			;1ff9	00 	. 
	nop			;1ffa	00 	. 
	nop			;1ffb	00 	. 
	ld sp,0302eh		;1ffc	31 2e 30 	1 . 0 
	rst 38h			;1fff	ff 	. 
