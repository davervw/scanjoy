; scanjoy.asm - Commodore 64 joystick / keyboard scans addressing interference
; Copyright (c) 2024 by David Van Wagner ALL RIGHTS RESERVED
; MIT LICENSE
; github.com/davervw
; www.davevw.com

scan=$cb     ; last keyboard scan 0..64, 64=none
shflag=$28d  ; shift(1)/commodore(2)/control(4) flags
CIAPRA=$dc00 ; CIA#1 Data Port Register A
CIAPRB=$dc01 ; CIA#1 Data Port Register B
kbdmatrix=$eb81
CHROUT=$ffd2 ; KERNAL character out
joy1 = $fd
joy2 = $fe
oldirq = $ea31
oldkeylog = $eb48
irqvector = $314
keylogvector = $28f

*=$c000
	jmp init
	jmp doscan

init:
	lda #<title
	ldx #>title
	jsr strout
	sei
	lda #<newirq
	ldx #>newirq
	sta irqvector
	stx irqvector+1
	lda #<newkeylog
	ldx #>newkeylog
	sta keylogvector
	stx keylogvector+1
	cli
	rts

doscan:
	php
	sei
repeatscan:	
	lda #64
	sta scan
	lda #0
	sta shflag
	sta CIAPRA
-   lda CIAPRB
    cmp CIAPRB
	bne -
	cmp #$ff
	beq exitscan
	ldy #0
	ldx #$fe
scancol:
	stx CIAPRA
-   lda CIAPRB
    cmp CIAPRB
	bne -
	ora joy1
	cmp #$ff
	beq notrow
nextcol:
	lsr
	pha
	bcs +
	lda kbdmatrix,y
	cmp #5
	bcs notshift
	ora shflag
	sta shflag
	bne +
notshift:
	sty scan
+	iny
	tya
	and #7
	clc
	bne +
	sec
+	pla
	bcs +
	bcc nextcol
notrow:	
	tya
	clc
	adc #8
	tay
+	txa
	sec
	rol
	tax
	bcs scancol
	lda #$ff
	sta CIAPRA
-	lda CIAPRB
	cmp CIAPRB
	bne -
	eor #$ff
	cmp joy1
	bne repeatscan
exitscan:
	lda #$7f
	sta CIAPRA
	lda scan
	ldx shflag
	ldy #0
	plp
	rts

strout:
	sta $fb
	stx $fc
	ldy #0
-	lda ($fb),y
	beq +
	jsr CHROUT
	iny
	bne -
+	rts

newirq:
	lda #$ff
	sta CIAPRA
-   lda CIAPRB
    cmp CIAPRB
	bne -
	eor #$ff
	sta joy1
-   lda CIAPRA
    cmp CIAPRA
	bne -
	eor #$ff
	sta joy2
	lda #$7f
	sta CIAPRA
	jmp oldirq

newkeylog:
	jsr doscan
	jmp oldkeylog

loginit:
	php
	pha
	lda #00
	sta loga_store+1
	lda #$c2
	sta loga_store+2
	pla
	plp
	rts

loga:
	php
loga_store:
	sta $c200
	inc loga_store+1
	bne +
	inc loga_store+2
+	plp
	rts

logx:
	php
	pha
	txa
	jsr loga
	pla
	plp
	rts

logy:
	php
	pha
	tya
	jsr loga
	pla
	plp
	rts

title: 
	!byte 147
	!text 18,"SCANJOY (C) 2024     GITHUB.COM/DAVERVW"
	!text 157,157,157,157,157,157,157,157,157,157,157,157,157,157,157,157,157,157,148,32,13
	!text 18,"BY DAVID R. VAN WAGNER       DAVEVW.COM"
	!text 157,157,157,157,157,157,157,157,157,157,148,32,13
	!byte 0