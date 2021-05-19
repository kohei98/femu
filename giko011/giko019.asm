	; �}�b�p�[�R�T���v��

	; INES�w�b�_�[
	.inesprg 1 ;   - �v���O�����P�o���N
	.ineschr 2 ;   - �O���t�B�b�N�Q�o���N
	.inesmir 1 ;   - �����~���[�����O
	.inesmap 3 ;   - �}�b�p�[�R��(CNROM)

	; �[���y�[�W
ViewAdr_L = $00		; �l�[���e�[�u���A�h���X(����)
ViewAdr_H = $01		; �l�[���e�[�u���A�h���X(���)
MapAdr_L = $02		; �}�b�v�A�h���X(����)
MapAdr_H = $03		; �}�b�v�A�h���X(����)
MapAdrW_L = $04		; �}�b�v�A�h���X(����)�X�V�p
MapAdrW_H = $05		; �}�b�v�A�h���X(���)�X�V�p
MapAdr_ofs = $06	; �}�b�v�A�N�Z�X�p�I�t�Z�b�g

View_X = $07		; �ėp
View_Y = $08		; �ėp
Work_X = $09		; �ėp
Work_Y = $0A		; �ėp

Walk_Cnt = $10
GameMode = $11		; ���[�h(0=�t�B�[���h,1=�o���N�؂�ւ��\��,2=�؂�ւ���)

KumaAdr_L = $20		; �N�}���ʃA�h���X
KumaAdr_H = $21		; �N�}��ʃA�h���X

	.bank 1      ; �o���N�P
	.org $FFFA   ; $FFFA����J�n

	.dw mainLoop ; VBlank���荞�݃n���h��(1/60�b����mainLoop���R�[�������)
	.dw Start    ; ���Z�b�g���荞�݁B�N�����ƃ��Z�b�g��Start�ɔ��
	.dw IRQ      ; �n�[�h�E�F�A���荞�݂ƃ\�t�g�E�F�A���荞�݂ɂ���Ĕ���

	.bank 0		; �o���N�O

	.org $0300	 ; $0300����J�n�A�X�v���C�gDMA�f�[�^�z�u
Sprite1_Y:     .db  0   ; �X�v���C�g#1 Y���W
Sprite1_T:     .db  0   ; �X�v���C�g#1 �i���o�[
Sprite1_S:     .db  0   ; �X�v���C�g#1 ����
Sprite1_X:     .db  0   ; �X�v���C�g#1 X���W
Sprite2_Y:     .db  0   ; �X�v���C�g#1 Y���W
Sprite2_T:     .db  0   ; �X�v���C�g#1 �i���o�[
Sprite2_S:     .db  0   ; �X�v���C�g#1 ����
Sprite2_X:     .db  0   ; �X�v���C�g#1 X���W

	.org $8000	; $8000����J�n

Start:
	sei			; ���荞�ݕs����
	cld			; �f�V�}�����[�h�t���O�N���A
	ldx #$ff
	txs			; �X�^�b�N�|�C���^������ 

	; PPU�R���g���[�����W�X�^1������
	lda #%00110000	; �����ł�VBlank���荞�݋֎~
	sta $2000

	; VROM�o���N�؂�ւ�
	lda #2			; �o���N2
	sta $8000

waitVSync:
	lda $2002		; VBlank����������ƁA$2002��7�r�b�g�ڂ�1�ɂȂ�
	bpl waitVSync  	; bit7��0�̊Ԃ́AwaitVSync���x���̈ʒu�ɔ��Ń��[�v���đ҂�������

	; PPU�R���g���[�����W�X�^2������
	lda #%00000110	; ���������̓X�v���C�g��BG��\��OFF�ɂ���
	sta $2001

	; �p���b�g�����[�h
	ldx #$00    	; X���W�X�^�N���A

	; VRAM�A�h���X���W�X�^��$2006�ɁA�p���b�g�̃��[�h��̃A�h���X$3F00���w�肷��B
	lda #$3F
	sta $2006
	lda #$00
	sta $2006

loadPal:			; ���x���́A�u���x�����{:�v�̌`���ŋL�q
	lda tilepal, x	; A��(ourpal + x)�Ԓn�̃p���b�g�����[�h����
	sta $2007		; $2007�Ƀp���b�g�̒l��ǂݍ���
	inx				; X���W�X�^�ɒl��1���Z���Ă���
	cpx #32 		; X��32(10�i���BBG�ƃX�v���C�g�̃p���b�g�̑���)�Ɣ�r���ē������ǂ�����r���Ă���	
	bne loadPal		;	�オ�������Ȃ��ꍇ�́Aloadpal���x���̈ʒu�ɃW�����v����
	; X��32�Ȃ�p���b�g���[�h�I��

	; �X�v���C�gDMA�̈揉����(���ׂ�0�ɂ���)
	lda #0
	ldx #$00
initSpriteDMA:
	sta $0300, x
	inx
	bne initSpriteDMA

	; �[���y�[�W������
	lda #$00
	ldx #$00
initZeroPage:
	sta <$00, x
	inx
	bne initZeroPage

	; �����n�`�`��
	; ViewAdr������($2000)
	lda #$20
	sta <ViewAdr_H
	sta $2006
	lda #$00
	sta <ViewAdr_L
	sta $2006
	; �}�b�v�̐擪�A�h���X�ݒ�
	lda #high(Map_Tbl_Init)
	sta <MapAdr_H
	lda #low(Map_Tbl_Init)
	sta <MapAdr_L
	lda #32				; �l�[���e�[�u��1���C��16*2�Z�b�g
	sta <View_Y			; �Ƃ肠����View_Y���g��
initField:
	ldy <MapAdr_ofs		; �I�t�Z�b�g
	lda [MapAdr_L],y	; �}�b�v���[�h
	pha					; A��ۑ�
	lda <View_Y
	and #1
	bne .initFieldSub	; View_Y�������Ȃ�l�[���e�[�u����ʁA��Ȃ牺��

	pla					; A�ɕ��A
	; ��ʂ��擾����̂�4��E�V�t�g�ɂ���
	lsr a
	lsr a
	lsr a
	lsr a
	jmp .initFieldSub2
.initFieldSub
	; ���ʎ擾
	pla					; A�ɕ��A
	and #$F	
	; ���ʎ擾���MapAdr�I�t�Z�b�g���Z
	inc <MapAdr_ofs
.initFieldSub2
	; �L�����o��
	; 2x2�L�����Ȃ̂�4�{�ɂ���
	asl a
	asl a
	clc
	ldy <View_Y
	cpy #17
	bcs .initFieldSub3
	clc
	adc #2				; 2x2�̂����̉��̕����̃L�����Ȃ̂�2���Z����
.initFieldSub3
	; 2�L�����o�͂���
	sta $2007
	clc
	adc #1				; 1���Z
	sta $2007

	dec <View_Y
	lda <View_Y
	beq .initFieldEnter2	; 2�s�`���I����

	cmp #16
	bne initField

	; �l�[���e�[�u�����s����(1�s�`���I����)
	; MapAdr�I�t�Z�b�g�N���A
	lda #0
	sta <MapAdr_ofs
	jmp initField

.initFieldEnter2
	; �l�[���e�[�u�����s����(2�s�`���I����)
	inc <View_X
	lda <View_X
	cmp #15
	beq .initFieldEnd	; 15�s�o�͂�����I��

	lda #32				; �l�[���e�[�u��1���C��16*2�Z�b�g
	sta <View_Y
	; MapAdr���Z
	lda <MapAdr_L
	clc
	adc <MapAdr_ofs		; �I�t�Z�b�g�����Z
	adc #8				; ����ɉ�ʊO�̕���8���X�L�b�v
	sta <MapAdr_L
	bcc .initFieldSub4

	inc <MapAdr_H		; ���オ��
.initFieldSub4
	lda #0
	sta <MapAdr_ofs

	jmp initField

.initFieldEnd
	; �}�b�v�̐擪�A�h���X���ēx�ݒ肵�ď�����
	lda #high(Map_Tbl_Init)
	sta <MapAdr_H
	sta <MapAdrW_H
	lda #low(Map_Tbl_Init)
	sta <MapAdr_L
	sta <MapAdrW_L

	; ����������������
	; $23C0����
	lda #$23
	sta $2006
	lda #$C0
	sta $2006
	sta <Work_X
	lda #8			; 8�񖈂ɉ��s
	sta <Work_Y
.initAttr
	jsr setAttrib
	sta $2007
	inc <MapAdrW_L
	lda <MapAdrW_L
	bne .initAttrSub
	inc <MapAdrW_H	; ���オ��
.initAttrSub
	dec <Work_Y
	lda <Work_Y
	bne .initAttrSub2
	lda #8			; 8�񖈂ɉ��s
	sta <Work_Y
	lda <MapAdrW_L
	clc
	adc #24			; 8+16
	sta <MapAdrW_L
	bcc .initAttrSub2
	inc <MapAdrW_H	; ���オ��
.initAttrSub2
	inc <Work_X
	lda <Work_X
	bne .initAttr	; X��$00�ɂȂ�܂Ń��[�v

	; �X�N���[���N���A
	lda $2002
	lda #$00
	sta $2005
	sta $2005

	; VBlank�҂�
waitVSync2:
	lda $2002
	bpl waitVSync2

	; PPU�R���g���[�����W�X�^2������
	lda #%00011110	; BG�̕\����ON�ɂ���
	sta $2001

	; PPU�R���g���[�����W�X�^1�̊��荞�݋��t���O�𗧂Ă�
	lda #%10110000
	sta $2000

infinityLoop:		; VBlank���荞�ݔ�����҂����̖������[�v
	lda <GameMode
	cmp #1
	bne infinityLoop

	lda #%00110000	; VBlank���荞�݋֎~

	; VROM�o���N�؂�ւ�
	lda #3			; �o���N3
	sta $8000

	; �l�[���e�[�u���N���A
	jsr clearNameTbl

	; �N�}�\��
	jsr putKuma

waitVSync3:
	lda $2002		; VBlank�҂�
	bpl waitVSync3

	lda #%00011110	; BG�̕\����ON�ɂ���
	sta $2001

	; �X�N���[���N���A
	lda $2002
	lda #$00
	sta $2005
	sta $2005

	; �Q�[�����[�h��2��
	inc <GameMode

	lda #%10110000	; VBlank�����݋֎~����

	jmp infinityLoop

mainLoop:			; ���C�����[�v
	pha				; A���W�X�^���X�^�b�N�ɕۑ�

	; �Q�[�����[�h0�̂Ƃ��ȊO�͉������Ȃ�
	lda <GameMode
	beq .mainLoopSub
	pla				; ���荞�ݑO�̓��e��A���W�X�^�ɕ��A
	rti

.mainLoopSub

	jsr putSprite

	inc <Walk_Cnt	; �����J�E���^�[���Z

	; �p�b�hI/O���W�X�^�̏���
	lda #$01
	sta $4016
	lda #$00
	sta $4016

	; �p�b�h���̓`�F�b�N
	lda $4016  ; A�{�^��
	and #1     ; AND #1
	beq NOTHINGdown
	; �o���N�؂�ւ��\��
	inc <GameMode

	lda #%00000110	; �X�v���C�g��BG��\��OFF�ɂ���
	sta $2001

	jmp NOTHINGdown
NOTHINGdown:
	pla				; ���荞�ݑO�̓��e��A���W�X�^�ɕ��A
	rti				; ���荞�݂��畜�A

putSprite:
	lda #$3  ; �X�v���C�g�f�[�^��$0300�Ԓn����Ȃ̂ŁA3�����[�h����B
	sta $4014 ; �X�v���C�gDMA���W�X�^��A���X�g�A���āA�X�v���C�g�f�[�^��DMA�]������

	; �v���C���[�L�����X�v���C�g�`��(���W�Œ�)

	; �����A�j���p�^�[���擾
	lda <Walk_Cnt
	and #$20
	asl a
	tax

	; ����
	lda #112    ; Y���W
	sta Sprite1_Y
	cpx #$40
	beq .spritePut
	lda #02     ; 2��
	jmp .spritePut2
.spritePut
	lda #04		; 4��
.spritePut2
	sta Sprite1_T
	stx Sprite1_S
	lda #112	; X���W
	sta Sprite1_X
	; �E��
	lda #112    ; Y���W
	sta Sprite2_Y
	cpx #$40
	beq .spritePut3
	lda #04     ; 4��
	jmp .spritePut4
.spritePut3
	lda #02		; 2��
.spritePut4
	sta Sprite2_T
	stx Sprite2_S
	lda #120	; X���W
	sta Sprite2_X
	rts

setAttrib:
	; MapAdrW_H,L������Ƃ��āA����1�}�X����A���W�X�^�ɐݒ肷��
	; (Map�̃L�����ԍ��ƃp���b�g�ԍ��͓���Ƃ����V���v���ȑO��)
	ldy #0		; �I�t�Z�b�g
	; ����(000000xx)
	lda [MapAdrW_L],y	; �}�b�v���[�h
	; ��ʂ��擾����̂�4��E�V�t�g�ɂ���
	ldx #4
	jsr shiftR
	sta <View_X			; View_X�ɕۑ�
	; �E��(0000xx00)
	lda [MapAdrW_L],y	; �}�b�v���[�h
	; ���ʂ��擾����̂�$F��AND����
	and #$F
	; ���V�t�g2�񂵂�View_X��OR����
	ldx #2
	jsr shiftL
	ora <View_X
	sta <View_X
	; ����(00xx0000)
	ldy #16				; �}�b�v�͉�16�o�C�g�Ȃ̂�16���Z
	lda [MapAdrW_L],y	; �}�b�v���[�h
	; ��ʂ��擾����̂�4��E�V�t�g�ɂ���
	ldx #4
	jsr shiftR
	; ���V�t�g4�񂵂�View_X��OR����
	ldx #4
	jsr shiftL
	ora <View_X
	sta <View_X
	; �E��(xx000000)
	lda [MapAdrW_L],y	; �}�b�v���[�h
	; ���ʂ��擾����̂�$F��AND����
	and #$F
	; ���V�t�g6�񂵂�View_X��OR����
	ldx #6
	jsr shiftL
	ora <View_X
	rts

shiftL:
	; X���W�X�^�̉񐔂���A�����V�t�g����
	asl a
	dex
	bne shiftL
	rts

shiftR:
	; X���W�X�^�̉񐔂���A���E�V�t�g����
	lsr a
	dex
	bne shiftR
	rts

putKuma:
	; �v���C���[�L�����X�v���C�g�N���A
	lda #$00	; �A�h���X0
	sta $2003
	sta $2004
	sta $2004
	sta $2004
	sta $2004
	lda #$04	; �A�h���X4
	sta $2003
	lda #$00
	sta $2004
	sta $2004
	sta $2004
	sta $2004

	; BG�p���b�g�ƃX�v���C�g�p���b�g��������
	lda #$3F
	sta $2006
	lda #$01
	sta $2006
	lda #$30	; ��
	sta $2007
	sta $2007
	lda #$0F	; ��
	sta $2007

	lda #$3F
	sta $2006
	lda #$10
	sta $2006
	lda #$0F	; ��
	sta $2007

	; ����������
	jsr clearAttrib

	; �N�}�\��
	lda #$20
	sta <KumaAdr_H
	lda #$6B
	sta <KumaAdr_L
	ldx #0
putKumaSub:
	lda <KumaAdr_H
	sta $2006
	lda <KumaAdr_L
	sta $2006
.putKumaSub2
	stx $2007
	inx
	txa
	and #$F
	cmp #$9
	bne .putKumaSub2
	lda <KumaAdr_L
	clc
	adc #$20			; �l�[���e�[�u�������s����
	sta <KumaAdr_L
	bcc .putKumaSub3
	inc <KumaAdr_H		; ���オ��
.putKumaSub3
	txa
	clc
	adc #$7				; �L���������s����
	tax
	cpx #$E0			; �L������$D0�܂ŏo�͂���
	bne putKumaSub

	; �g�\��
	lda #$22
	sta $2006
	lda #$28
	sta $2006
	ldx #$E
	ldy #$FC			; ����
.putYokoWaku1
	sty $2007
	dex
	bne .putYokoWaku1

	lda #$23
	sta $2006
	lda #$08
	sta $2006
	ldx #$E
.putYokoWaku2
	sty $2007
	dex
	bne .putYokoWaku2

	ldx #$47
	ldy #$FD			; �c��
.putTateWaku1
	lda #$22
	sta $2006
	stx $2006
	sty $2007
	txa
	clc
	adc #$20
	tax
	bcc .putTateWaku1	; �ʓ|�Ȃ�Ō��オ�肷��܂�

	ldx #$56
.putTateWaku2
	lda #$22
	sta $2006
	stx $2006
	sty $2007
	txa
	clc
	adc #$20
	tax
	bcc .putTateWaku2	; �ʓ|�Ȃ�Ō��オ�肷��܂�

	; ����
	lda #$22
	sta $2006
	lda #$27
	sta $2006
	lda #$EE
	sta $2007
	; �E��
	lda #$22
	sta $2006
	lda #$36
	sta $2006
	lda #$EF
	sta $2007
	; ����
	lda #$23
	sta $2006
	lda #$07
	sta $2006
	lda #$FE
	sta $2007
	; �E��
	lda #$23
	sta $2006
	lda #$16
	sta $2006
	lda #$FF
	sta $2007

	; �u���܂��@�����ꂽ�I�v
	lda #$22
	sta $2006
	lda #$48
	sta $2006
	ldx #$E0
.putKumaAppeared
	stx $2007
	inx
	cpx #$E9
	bne .putKumaAppeared

	rts

clearNameTbl:
	; �l�[���e�[�u��0�N���A
	; �l�[���e�[�u����$2000����
	lda #$20
	sta $2006
	lda #$00
	sta $2006
	lda #$00        ; 0��(����)
	ldx #240		; 240��J��Ԃ�
	ldy #4			; �����4��A�v960��J��Ԃ�
.clearNameTblSub
	sta $2007
	dex
	bne .clearNameTblSub
	ldx #240
	dey
	bne .clearNameTblSub
	rts

clearAttrib:
	; ����������
	lda #$23
	sta $2006
	lda #$C0
	sta $2006
	ldx #$00    	; X���W�X�^�N���A
	lda #0			; �S�Ƃ��p���b�g0��
.clearAttribSub
	sta $2007		; $2007�ɑ����̒l��ǂݍ���
	; 64��(�S�L�����N�^�[��)���[�v����
	inx
	cpx #64
	bne .clearAttribSub
	rts

IRQ:
	rti

	; �����f�[�^
	.org $9000    ; $9000����J�n
tilepal: .incbin "giko6.pal" ; �p���b�g��include����
	; �}�b�v�f�[�^(32x32)
Map_Tbl: .include "giko019map.txt"

	.bank 2       ; �o���N�Q
	.org $0000    ; $0000����J�n
	.incbin "giko4.spr"  ; �X�v���C�g�f�[�^
	.incbin "giko7.bkg"  ; �n�`BG�f�[�^

	.bank 3       ; �o���N�R
	.org $0000    ; $0000����J�n
	.incbin "giko4.spr"  ; �X�v���C�g�f�[�^
	.incbin "giko8.bkg"  ; �G&���b�Z�[�WBG�f�[�^

