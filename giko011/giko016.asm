	; �c�X�N���[���T���v��

	; INES�w�b�_�[
	.inesprg 1 ;   - �v���O�����ɂ����̃o���N���g�����B���͂P�B
	.ineschr 1 ;   - �O���t�B�b�N�f�[�^�ɂ����̃o���N���g�����B���͂P�B
	.inesmir 0 ;   - VRAM�̃~���[�����O�𐅕��ɂ���B
	.inesmap 0 ;   - �}�b�p�[�B�O�Ԃɂ���B

	; �[���y�[�W�ϐ�
Scroll_Y  = $00	; Y�X�N���[���l

Road_X    = $01	; ���H��X���W
Road_YL   = $02	; ���H��Y���W�A�h���X(����)
Road_YH   = $03	; ���H��Y���W�A�h���X(���)
Road_Cnt  = $04	; ���H�X�V�҂��J�E���^�[

Course_Index=$05 ; �R�[�X�e�[�u���C���f�b�N�X
Course_Dir= $06  ; �R�[�X����(0:���i1:����2:�E��)
Course_Cnt = $07 ; �R�[�X�����p���J�E���^�[ 

Crash_YH   = $08	; �Փ�Y���W�A�h���X(���)
Crash_YL   = $09	; �Փ�Y���W�A�h���X(����)

NameTblNum = $0A	; �l�[���e�[�u���I��ԍ�(0=$2000,1=$2800)

	.bank 1      ; �o���N�P
	.org $FFFA   ; $FFFA����J�n

	.dw mainLoop ; VBlank���荞�݃n���h��(1/60�b����mainLoop���R�[�������)
	.dw Start    ; ���Z�b�g���荞�݁B�N�����ƃ��Z�b�g��Start�ɔ��
	.dw IRQ      ; �n�[�h�E�F�A���荞�݂ƃ\�t�g�E�F�A���荞�݂ɂ���Ĕ���

	.bank 0			 ; �o���N�O
	.org $0300	 ; $0300����J�n�A�X�v���C�gDMA�f�[�^�z�u
Sprite1_Y:     .db  0   ; �X�v���C�g#1 Y���W
Sprite1_T:     .db  0   ; �X�v���C�g#1 �i���o�[
Sprite1_S:     .db  0   ; �X�v���C�g#1 ����
Sprite1_X:     .db  0   ; �X�v���C�g#1 X���W
Sprite2_Y:     .db  0   ; �X�v���C�g#2 Y���W
Sprite2_T:     .db  0   ; �X�v���C�g#2 �i���o�[
Sprite2_S:     .db  0   ; �X�v���C�g#2 ����
Sprite2_X:     .db  0   ; �X�v���C�g#2 X���W


	.org $8000	; $8000����J�n
Start:
	sei			; ���荞�ݕs����
	cld			; �f�V�}�����[�h�t���O�N���A
	ldx #$ff
	txs			; �X�^�b�N�|�C���^������ 

	; PPU�R���g���[�����W�X�^1������
	lda #%00001000	; �����ł�VBlank���荞�݋֎~
	sta $2000

waitVSync:
	lda $2002		; VBlank����������ƁA$2002��7�r�b�g�ڂ�1�ɂȂ�
	bpl waitVSync	; bit7��0�̊Ԃ́AwaitVSync���x���̈ʒu�ɔ��Ń��[�v���đ҂�������

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

	sta $2007 ; $2007�Ƀp���b�g�̒l��ǂݍ���

	inx ; X���W�X�^�ɒl��1���Z���Ă���

	cpx #32 	; X��32(10�i���BBG�ƃX�v���C�g�̃p���b�g�̑���)�Ɣ�r���ē������ǂ�����r���Ă���	
	bne loadPal ;	�オ�������Ȃ��ꍇ�́Aloadpal���x���̈ʒu�ɃW�����v����
	; X��32�Ȃ�p���b�g���[�h�I��

	; ����(BG�̃p���b�g�w��f�[�^)�����[�h
	lda #0
	sta <NameTblNum
	; $23C0,2BC0�̑����e�[�u���Ƀ��[�h����
	lda #$23
	sta $2006
	lda #$C0
	sta $2006
	jmp loadAttribSub
loadAttrib:
	lda #1
	sta <NameTblNum
	lda #$2B
	sta $2006
	lda #$C0
	sta $2006
loadAttribSub:
	ldx #$00    		; X���W�X�^�N���A
	lda #%00000000		; �S�Ƃ��p���b�g0��
	; 0�Ԃɂ���
.loadAttribSub2
	sta $2007			; $2007�ɑ����̒l($0)��ǂݍ���
	; 64��(�S�L�����N�^�[��)���[�v����
	inx
	cpx #64
	bne .loadAttribSub2
	lda <NameTblNum
	beq loadAttrib

	; �l�[���e�[�u������
	lda #0
	sta <NameTblNum
	; �l�[���e�[�u����$2000���琶������
	lda #$20
	sta $2006
	lda #$00
	sta $2006
	jmp loadNametableSub
	; �l�[���e�[�u����$2800���琶������
loadNametable:
	lda #1
	sta <NameTblNum
	lda #$28
	sta $2006
	lda #$00
	sta $2006
loadNametableSub:
	ldy #0
	lda #11		; ���H�̏���X���W=11
	sta <Road_X
.loadNametableSub2
	jsr writeCourse
	iny
	cpy #30		; 30��J��Ԃ�
	bne .loadNametableSub2
	lda <NameTblNum
	beq loadNametable

	; �X�v���C�gDMA�̈揉����(0��1�ȊO�͑S�ĉ��ɂ���)
	lda #%00100000
	ldx #$00
initSpriteDMA:
	sta $0300, x
	inx
	bne initSpriteDMA
	lda #0
	sta Sprite1_T
	sta Sprite1_S
	sta Sprite2_T

	; �P�Ԗڂ̃X�v���C�g���W������
	lda X_Pos_Init
	sta Sprite1_X
	lda Y_Pos_Init
	sta Sprite1_Y
	; �Q�Ԗڂ̃X�v���C�g���W�X�V�T�u���[�`�����R�[��
	jsr setSprite2
	; �Q�Ԗڂ̃X�v���C�g�𐅕����]
	lda #%01000000
	sta Sprite2_S

	; �[���y�[�W������
	lda #$00
	ldx #$00
initZeroPage:
	sta <$00, x
	inx
	bne initZeroPage
	
	lda #$23	; ���H��Y���W�A�h���X������($23C0)
	sta <Road_YH
	lda #$C0
	sta <Road_YL
	lda #11		; ���H�̏���X���W=11
	sta <Road_X

	; PPU�R���g���[�����W�X�^2������
	lda #%00011110	; �X�v���C�g��BG�̕\����ON�ɂ���
	sta $2001

	; PPU�R���g���[�����W�X�^1�̊��荞�݋��t���O�𗧂Ă�
	lda #%10001010
	sta $2000

infinityLoop:					; VBlank���荞�ݔ�����҂����̖������[�v
	jmp infinityLoop

mainLoop:					; ���C�����[�v

calcCourse:
	; ���H�`�攻��(4����1�x�A��ʊO�ɓ��H��`�悷��)
	inc <Road_Cnt		; �J�E���^����
	lda <Road_Cnt
	cmp #4
	bne scrollBG		; 4�łȂ��Ȃ�܂����H��`�悵�Ȃ�
	lda #0
	sta <Road_Cnt
	; ���HY���W�A�h���X�v�Z
	lda <Road_YL
	sec					; sbc�̑O�ɃL�����[�t���O���Z�b�g
	sbc #32				; ���H��Y���W�A�h���X(����)��32���Z
	sta <Road_YL
	bcs setCourse		; �������肵�ĂȂ����setCourse��
	lda <Road_YH
	cmp #$20			; Y���W�A�h���X(���)��$20�܂ŉ����������H
	bne .calcCourseSub

	; �l�[���e�[�u���I��ԍ����X�V
	lda <NameTblNum
	eor #1
	sta <NameTblNum

	lda #$23			; ���H��Y���W�A�h���X������($23C0)
	sta <Road_YH
	lda #$C0
	sta <Road_YL
	lda #03				; ����X�V���邽�߂ɁA�J�E���^��4-1=3
	sta <Road_Cnt
	jmp scrollBG		; ����͍X�V���Ȃ�
.calcCourseSub
	dec <Road_YH		; Y���W�A�h���X�̏�ʂ�$23��$22��$21��$20��$23...
	
setCourse:
	; �l�[���e�[�u����Road_YH*$100+Road_YH�ɓ��H��1���C���`�悷��
	lda <Road_YH		; ��ʃA�h���X

	ldx <NameTblNum
	beq .setCourseSub	; NameTblNum��0�Ȃ��$2000����X�V����
	clc					; adc�̑O�ɃL�����[�t���O���N���A
	adc #8 				; NameTblNum��1�Ȃ��$2800����X�V����
.setCourseSub
	sta $2006
	lda <Road_YL		; ���ʃA�h���X
	sta $2006
	jsr writeCourse

	; �Փ˔���
	jsr isCrash

scrollBG:
	; BG�X�N���[��
	lda $2002			; �X�N���[���l�N���A
	lda #0
	sta $2005			; X�����͌Œ�
	lda <Scroll_Y
	sta $2005			; Y�����X�N���[��
	dec <Scroll_Y		; �X�N���[���l�����Z
	dec <Scroll_Y		; �X�N���[���l�����Z
	cmp #254			; 254�ɂȂ����H
	bne sendSprite
	lda #238			; 16�h�b�g�X�L�b�v����238�ɂ���
	sta <Scroll_Y

sendSprite:
	; �X�v���C�g�`��(DMA�𗘗p)
	lda #$3  ; �X�v���C�g�f�[�^��$0300�Ԓn����Ȃ̂ŁA3�����[�h����B
	sta $4014 ; �X�v���C�gDMA���W�X�^��A���X�g�A���āA�X�v���C�g�f�[�^��DMA�]������

	; �R�[�X�ݒ�
    jsr goCourse

	; �\������l�[���e�[�u���ԍ�(bit1~0)���Z�b�g����
	lda #%10001000
	ldx <NameTblNum
	bne setNameTblNum
	ora #2			; (%10001010)�l�[���e�[�u��2�Ԃ�\������
setNameTblNum:
	sta $2000

getPad:
	; �p�b�hI/O���W�X�^�̏���
	lda #$01
	sta $4016
	lda #$00
	sta $4016

	; �p�b�h���̓`�F�b�N
	lda $4016  ; A�{�^��
	lda $4016  ; B�{�^��
	lda $4016  ; Select�{�^�����X�L�b�v
	lda $4016  ; Start�{�^�����X�L�b�v
	lda $4016  ; ��{�^��
	lda $4016  ; ���{�^��
	lda $4016  ; ���{�^��
	and #1     ; AND #1
	bne LEFTKEYdown ; 0�łȂ��Ȃ�Ή�����Ă�̂�LEFTKeydown�փW�����v

	lda $4016  ; �E�{�^��
	and #1     ; AND #1
	bne RIGHTKEYdown ; 0�łȂ��Ȃ�Ή�����Ă�̂�RIGHTKeydown�փW�����v
	jmp NOTHINGdown  ; �Ȃɂ�������Ă��Ȃ��Ȃ��NOTHINGdown��

LEFTKEYdown:
	dec Sprite1_X	; X���W��1���Z
	jmp NOTHINGdown

RIGHTKEYdown:
	inc Sprite1_X	; X���W��1���Z
	; ���̌�NOTHINGdown�Ȃ̂ŃW�����v����K�v����

NOTHINGdown:
	; �Q�Ԗڂ̃X�v���C�g���W�X�V�T�u���[�`�����R�[��
	jsr setSprite2
	
	; �T�E���h�҂��J�E���^A~D(�[���y�[�W�ŘA�������̈�Ƃ����O��)�����ꂼ��-1���Z����	
NMIEnd:
	rti				; ���荞�݂��畜�A

setSprite2:
	; �Q�Ԗڂ̃X�v���C�g�̍��W�X�V�T�u���[�`��
	clc					;�@adc�̑O�ɃL�����[�t���O���N���A
	lda Sprite1_X
	adc #8 				; 8�ޯĉE�ɂ��炷
	sta Sprite2_X
	lda Sprite1_Y
	sta Sprite2_Y
	rts

	; �Փ˔���
	; ���H��Y���W�A�h���X�𗘗p����
isCrash:
	ldy #0				; ��������t���O0
	lda <Road_YL		; ���ʃA�h���X
	sec					; sbc�̑O�ɃL�����[�t���O���Z�b�g
	sbc #$C0			; ���H��Y���W�A�h���X(����)��$C0���Z
	sta <Crash_YL
	bcs .isCrashSub2	; �������肵�ĂȂ����isCrashSub2��
	lda <Road_YH
	sta <Crash_YH
	cmp #$20			; Y���W�A�h���X(���)��$20�܂ŉ����������H
	bne .isCrashSub
	ldy #1				; ��������t���O1
	lda #$24			; ���H��Y���W�A�h���X������($24��$23)
	sta <Crash_YH
	lda <Crash_YL
	sec					; sbc�̑O�ɃL�����[�t���O���Z�b�g
	sbc #$40			; ���H��Y���W�A�h���X(����)��$40���Z
	sta <Crash_YL
.isCrashSub
	dec <Crash_YH		; Y���W�A�h���X(���)���Z
.isCrashSub2
	lda <Crash_YH		; ��ʃA�h���X

	; ��������̏ꍇ�́A�����Е��̃l�[���e�[�u�����`�F�b�N����
	ldx <NameTblNum		; X��NameTblNum�����[�h
	cpy #1				; ��������t���O��1���H
	bne .isCrashSubE
	pha					; A���X�^�b�N��PUSH(��ʃA�h���X��ޔ�)
	txa					; X��A
	eor #1				; NameTblNum���r�b�g���]
	tax					; A��X
	pla					; A�ɃX�^�b�N����PULL(��ʃA�h���X�𕜋A)
.isCrashSubE:
	cpx #0
	beq .isCrashSub3	; NameTblNum��0�Ȃ�΃l�[���e�[�u��$2000����`�F�b�N����
	clc					; adc�̑O�ɃL�����[�t���O���N���A
	adc #8 				; NameTblNum��1�Ȃ�΃l�[���e�[�u��$2800����`�F�b�N����
.isCrashSub3
	sta $2006
	lda Sprite2_X		; �X�v���C�g�̒������W�����[�h
	lsr a				; �E�V�t�g3���1/8
	lsr a
	lsr a
	clc
	adc <Crash_YL		; Y���W�A�h���X(����)�ɉ��Z
	sta $2006
	lda $2007			; A�ɃX�v���C�g���S���W�t�߂�BG���擾
	beq .isCrashEnd		; BG0�ԂȂ�Γ��H�Ȃ̂�OK
	; �Փ˂����̂ŐԂ�����
	; �X�v���C�g�̃p���b�g1��
	lda #1
	sta Sprite1_S
	lda #%01000001
	sta Sprite2_S
	rts	
.isCrashEnd
	; �X�v���C�g�̃p���b�g0��
	lda #0
	sta Sprite1_S
	lda #%01000000
	sta Sprite2_S
	rts

	; �R�[�X��i�߂�
goCourse:
	lda <Road_Cnt
	beq .goCourseSub	; �҂����Ȃ�X�V���Ȃ�
	rts
.goCourseSub
	lda <Course_Cnt
	bne .goCourseSub2	; �܂��J�E���g��
	ldx <Course_Index
	lda Course_Tbl, x	; Course�e�[�u���̒l��A�ɓǂݍ���
	pha					; A��PUSH
	and #$3				; bit0~1���擾
	sta <Course_Dir		; �R�[�X�����Ɋi�[
	pla					; A��PULL���Ė߂�
	lsr a				; ��2�V�t�g����bit2~7���擾
	lsr a
	sta <Course_Cnt		; �R�[�X�J�E���^�[�Ɋi�[
	inc <Course_Index
	lda <Course_Index
	cmp #10				; �R�[�X�e�[�u��10�񕪃��[�v����
	bne .goCourseSub2
	lda #0				; �C���f�b�N�X��0�ɖ߂�
	sta <Course_Index
.goCourseSub2
	lda <Course_Dir
	bne .goCourseLeft	; 0(���i)���H
	jmp .goCourseEnd
.goCourseLeft
	cmp #$01			; 1(����)���H
	bne .goCourseRight
	dec <Road_X			; ���HX���W���Z
	jmp .goCourseEnd
.goCourseRight
	inc <Road_X			; 2(�E��)�Ȃ̂œ��HX���W���Z
.goCourseEnd
	dec <Course_Cnt
	rts

	; BG�ɓ��H���P���C���`�悷��
writeCourse:
	; �����̖쌴��`��
	ldx <Road_X
	lda #$01		; �����̖쌴
.writeLeftField
	sta $2007		; $2007�ɏ�������
	dex
	cpx #1 
	bne .writeLeftField

	; �����̘H����`��
	lda <Course_Dir
	bne .writeLeftLeft	; 0(���i)���H
	lda #$02			; �����̘H��(���i)
	jmp .writeLeftEnd
.writeLeftLeft
	cmp #$01			; 1(����)��?
	bne .writeLeftRight
	sta $2007			; Road_X��-1����Ă�̂Ŗ쌴��1�L����������������
	lda #$04			; �����̘H��(����)
	jmp .writeLeftEnd
.writeLeftRight
	lda #$06			; �����̘H��(�E��)
.writeLeftEnd
	sta $2007			; $2007�ɏ�������

	; �����̓��H��`��
	ldx #9				; ����=10���������ł�9
	lda #$00			; ���H
.writeRoad
	sta $2007			; $2007�ɏ�������
	dex
	bne .writeRoad


	; �E���̘H����`��
	ldx <Course_Dir
	bne .writeRightLeft	; 0(���i)���H
	sta $2007			; ���������H��9�Ȃ̂Ŗ쌴��1�L����������������
	lda #$03			; �E���̘H��(���i)
	jmp .writeRightEnd
.writeRightLeft
	cpx #$01			; 1(����)��?
	bne .writeRightRight
	lda #$05			; �E���̘H��(����)
	jmp .writeRightEnd
.writeRightRight
	lda #$07			; �E���̘H��(�E��)
.writeRightEnd
	sta $2007			; $2007�ɏ�������

	; �E���̖쌴��`��
	lda #31
	sec					; sbc�̑O�ɃL�����[�t���O���Z�b�g
	sbc <Road_X			; ���H��X���W������
	sec					; sbc�̑O�ɃL�����[�t���O���Z�b�g
	sbc #10				; ����������
	tax
	lda #$01			; �E���̖쌴
.writeRightField
	sta $2007			; $2007�ɏ�������
	dex
	bne .writeRightField
	rts

IRQ:
	rti

	; �����f�[�^
X_Pos_Init   .db 120      ; X���W�����l
Y_Pos_Init   .db 200      ; Y���W�����l

	; �R�[�X�f�[�^(10�Ebit0~1=�����Ebit2~7�J�E���^)
	; (���i=0,����=1,�E��=2)
Course_Tbl    .db $21,$40,$32,$20,$21,$22,$20,$21,$12,$30

tilepal: .incbin "giko4.pal" ; �p���b�g��include����

	.bank 2       ; �o���N�Q
	.org $0000    ; $0000����J�n

	.incbin "giko4.bkg"  ; �w�i�f�[�^�̃o�C�i���B�t�@�C����include����
	.incbin "giko2.spr"  ; �X�v���C�g�f�[�^�̃o�C�i���B�t�@�C����include����
