	; ���X�N���[���T���v��

	; INES�w�b�_�[
	.inesprg 1 ;   - �v���O�����ɂ����̃o���N���g�����B���͂P�B
	.ineschr 1 ;   - �O���t�B�b�N�f�[�^�ɂ����̃o���N���g�����B���͂P�B
	.inesmir 1 ;   - VRAM�̃~���[�����O�𐂒��ɂ���
	.inesmap 0 ;   - �}�b�p�[�B�O�Ԃɂ���B

Scroll_X  = $00		; X�X�N���[���l

Floor_X    = $01	; �`�悷��c���C����X���W
Floor_Y    = $02	; �`�悷�鏰��Y���W
Floor_Cnt  = $03	; ���X�V�҂��J�E���^�[

Course_Index=$04 	; �R�[�X�e�[�u���C���f�b�N�X
Course_Cnt = $05 	; �R�[�X�p���J�E���^�[ 

Walk_Cnt   = $06	; �����J�E���^�[
Walk_Page  = $07	; �����Ă���l�[���e�[�u��
Jump_Mode  = $08	; �W�����v���H(1�Ȃ�W�����v��)
Jump_VY    = $09	; �W�����v�����x
Jump_NL    = $0A	; �W�����v�����蔻��p�̃l�[���e�[�u���A�h���X(����)
Jump_NH    = $0B	; �W�����v�����蔻��p�̃l�[���e�[�u���A�h���X(���)

NameTblNum = $0C	; �l�[���e�[�u���I��ԍ�(0=$2000,1=$2400)

	.bank 1      	; �o���N�P
	.org $FFFA		; $FFFA����J�n

	.dw mainLoop 	; VBlank���荞�݃n���h��(1/60�b����mainLoop���R�[�������)
	.dw Start    	; ���Z�b�g���荞�݁B�N�����ƃ��Z�b�g��Start�ɔ��
	.dw IRQ			; �n�[�h�E�F�A���荞�݂ƃ\�t�g�E�F�A���荞�݂ɂ���Ĕ���

	.bank 0			; �o���N�O

	.org $0300	 ; $0300����J�n�A�X�v���C�gDMA�f�[�^�z�u
Sprite1_Y:     .db  0   ; �X�v���C�g#1 Y���W
Sprite1_T:     .db  0   ; �X�v���C�g#1 �i���o�[
Sprite1_S:     .db  0   ; �X�v���C�g#1 ����
Sprite1_X:     .db  0   ; �X�v���C�g#1 X���W

	.org $8000	 ; $8000����J�n
Start:
	sei			; ���荞�ݕs����
	cld			; �f�V�}�����[�h�t���O�N���A
	ldx #$ff
	txs			; �X�^�b�N�|�C���^������ 

	; PPU�R���g���[�����W�X�^1������
	lda #%00110000	; �����ł�VBlank���荞�݋֎~
	sta $2000

waitVSync:
	lda $2002		; VBlank����������ƁA$2002��7�r�b�g�ڂ�1�ɂȂ�
	bpl waitVSync	; bit7��0�̊Ԃ́AwaitVSync���x���̈ʒu�ɔ��Ń��[�v���đ҂�������


	; PPU�R���g���[�����W�X�^2������
	lda #%00000110	; ���������̓X�v���C�g��BG��\��OFF�ɂ���
	sta $2001

	; �p���b�g�����[�h
	ldx #$00    ; X���W�X�^�N���A

	; VRAM�A�h���X���W�X�^��$2006�ɁA�p���b�g�̃��[�h��̃A�h���X$3F00���w�肷��B
	lda #$3F
	sta $2006
	lda #$00
	sta $2006

loadPal:			; ���x���́A�u���x�����{:�v�̌`���ŋL�q
	lda tilepal, x ; A��(ourpal + x)�Ԓn�̃p���b�g�����[�h����

	sta $2007 ; $2007�Ƀp���b�g�̒l��ǂݍ���

	inx ; X���W�X�^�ɒl��1���Z���Ă���

	cpx #32 ; X��32(10�i���BBG�ƃX�v���C�g�̃p���b�g�̑���)�Ɣ�r���ē������ǂ�����r���Ă���	
	bne loadPal ;	�オ�������Ȃ��ꍇ�́Aloadpal���x���̈ʒu�ɃW�����v����
	; X��32�Ȃ�p���b�g���[�h�I��

	; ����(BG�̃p���b�g�w��f�[�^)�����[�h
	lda #0
	sta <NameTblNum
	; $23C0,27C0�̑����e�[�u���Ƀ��[�h����
	lda #$23
	sta $2006
	lda #$C0
	sta $2006
	jmp loadAttribSub
loadAttrib:
	lda #1
	sta <NameTblNum
	lda #$27
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
	jmp loadNametable1
loadNametable:
	; �l�[���e�[�u����$2400���琶������
	lda #1
	sta <NameTblNum
	lda #$24
	sta $2006
	lda #$00
	sta $2006
loadNametable1:
	lda #$00        ; 0��(����)
	; 112*8=896��o�͂���
	ldx #112		; X���W�X�^������
	ldy #8			; Y���W�X�^������
.loadNametable2
	sta $2007		; $2007�ɏ�������
	dex
	bne .loadNametable2
	ldx #112		; X���W�X�^������
	dey
	bne .loadNametable2
	; 64��o�͂���
	lda #$01        ; 1��(�n��)
	ldx #64			; X���W�X�^������
loadNametable3:
	sta $2007		; $2007�ɏ�������
	dex
	bne loadNametable3
	lda <NameTblNum
	beq loadNametable

	; �X�v���C�gDMA�̈揉����(���ׂ�0�ɂ���)
	lda #0
	ldx #$00
initSpriteDMA:
	sta $0300, x
	inx
	bne initSpriteDMA

	; �X�v���C�g���W������
	lda X_Pos_Init
	sta Sprite1_X
	sta Walk_Cnt	; �����J�E���^�[�������l��ݒ�
	lda Y_Pos_Init
	sta Sprite1_Y
	lda #2			; �X�v���C�g2��
	sta Sprite1_T

	; �[���y�[�W������
	lda #$00
	ldx #$00
initZeroPage:
	sta <$00, x
	inx
	bne initZeroPage

	lda Sprite1_X
	sta Walk_Cnt	; �����J�E���^�[��X���W�Ɠ����l��ݒ�
	
	; PPU�R���g���[�����W�X�^2������
	lda #%00011110	; �X�v���C�g��BG�̕\����ON�ɂ���
	sta $2001

	; PPU�R���g���[�����W�X�^1�̊��荞�݋��t���O�𗧂Ă�
	lda #%10110101				; �X�v���C�g��8x16�A�l�[���e�[�u����$2400���w��APPU�A�h���X�C���N�������g��+32�ɂ���
	sta $2000

infinityLoop:					; VBlank���荞�ݔ�����҂����̖������[�v
	jmp infinityLoop

mainLoop:					; ���C�����[�v

calcCourse:
	; ���`�攻��(4����1�x�A��ʊO�ɏ���`�悷��)
	lda <Floor_Cnt
	cmp #4
	bne spriteDMA		; ���J�E���^��4�łȂ��Ȃ�܂�����`�悵�Ȃ�
	lda #0
	sta <Floor_Cnt		; ���J�E���^�N���A

	; Course�e�[�u���ǂݍ���
	lda <Course_Cnt
	bne writeFloor		; �܂��J�E���g��
	ldx <Course_Index
	lda Course_Tbl, x	; Course�e�[�u���̒l��A�ɓǂݍ���
	sta <Floor_Y		; ��Y���W�i�[
	inc <Course_Index	; �C���f�b�N�X���Z
	ldx <Course_Index
	lda Course_Tbl, x	; Course�e�[�u���̒l��A�ɓǂݍ���
	sta <Course_Cnt		; ���J�E���^�i�[
	inc <Course_Index	; �C���f�b�N�X���Z
	lda <Course_Index
	cmp #20				; �R�[�X�e�[�u��20�񕪃��[�v����
	bne writeFloor
	lda #0				; �C���f�b�N�X��0�ɖ߂�
	sta <Course_Index

	; �l�[���e�[�u���ɏ���`�悷��
writeFloor:
	lda $2002			; PPU���W�X�^�N���A
	dec <Course_Cnt		; �R�[�X�J�E���^���Z
	lda #$20			; �l�[���e�[�u���̏�ʃA�h���X($2000����)
	ldx <NameTblNum
	cpx #1				; �l�[���e�[�u���I��ԍ���1�Ȃ�$2400����
	bne .writeFloorE
	lda #$24			; �l�[���e�[�u���̏�ʃA�h���X($2400����)
.writeFloorE
	sta $2006			; �l�[���e�[�u����ʃA�h���X���Z�b�g
	lda <Floor_X		; ��X���W�����[�h(���̂܂܉��ʃA�h���X�ɂȂ�)
	sta $2006
	ldx #28				; �c28�񕪃��[�v����(�n�ʂ�2�L��������̂�30-2)
.writeFloorSub
	lda #$00			; 0��(����)
	cpx <Floor_Y
	bne .writeFloorSub2	; ����Y���W�ƈႤ�Ȃ�writeFloorSub2��
	lda #$02			; 2��(�����K)
.writeFloorSub2
	sta $2007
	dex
	bne .writeFloorSub	; 28�񃋁[�v����

	inc <Floor_X		; ��X���W���Z
	lda <Floor_X
	cmp #32				; �l�[���e�[�u���̃��C���E�[�ɓ��B�����H
	bne spriteDMA
	lda #0				; 0�ɖ߂�
	sta <Floor_X
	; �l�[���e�[�u���I��ԍ���؂�ւ���
	lda <NameTblNum
	eor #1				; �r�b�g���]
	sta <NameTblNum

spriteDMA:
	; �X�v���C�g�`��(DMA�𗘗p)
	lda #$3  ; �X�v���C�g�f�[�^��$0300�Ԓn����Ȃ̂ŁA3�����[�h����B
	sta $4014 ; �X�v���C�gDMA���W�X�^��A���X�g�A���āA�X�v���C�g�f�[�^��DMA�]������
	
	; �����A�j���[�V����(2�Ԃ�4�Ԃ����݂�)
	lda <Walk_Cnt		; �����J�E���^�[�����[�h
	and #8				; 3�r�b�g�ڂ��擾
	lsr a				; �E�V�t�g�Ŕ�����
	lsr a				; �E�V�t�g�Ŕ�����
	clc					; C�t���O�N���A
	adc #2				; A��2���Z
	sta Sprite1_T		; �X�v���C�g�ԍ��ɐݒ�

	lda <Jump_Mode
	beq startIsHitBlock	; �W�����v���ł͂Ȃ�

startIsHitBlock:
	; ���Ƃ̓����蔻��
	lda $2002			; PPU���W�X�^�N���A

	lda <Jump_VY
	bmi addPreGrav		; �܂��㏸��

	lda #$20
	ldx <Walk_Page
	beq isHitBlock		; 0�Ȃ�l�[���e�[�u���A�h���X��ʂ�$2000
	lda #$24
isHitBlock:
	sta <Jump_NH

	lda Sprite1_Y
	lsr a				; 1/8�ɂ���
	lsr a
	lsr a
	tax
	inx					; ����ꏊ�̓X�v���C�g�̑�����Y���W�Ȃ̂ŉ��Z����
	inx
	lda #0
.isHitBlock2
	clc
	adc #32
	bcc .isHitBlock3		; ���オ�薳���Ȃ�
	inc <Jump_NH		; ���オ�肵���̂ŏ�ʃA�h���X���Z
.isHitBlock3
	dex
	bne .isHitBlock2	; Y���W�̐��������[�v
	sta <Jump_NL		; ���ʃA�h���X�ɃX�g�A
	lda <Jump_NH		; �l�[���e�[�u����ʃA�h���X���Z�b�g
	sta $2006
	lda Walk_Cnt		; Walk_Cnt����1/8�����ʃA�h���X
	lsr a				; 1/8�ɂ���
	lsr a
	lsr a
	clc
	adc <Jump_NL		; ���ʃA�h���X���Z
	sta $2006
	lda $2007			; �X�v���C�g�̑�����BG�L�����N�^�[���擾����
	beq	.isHitBlock4	; 0�Ȃ瑫�̒n�_�����ɓ������Ă��Ȃ�
	lda <Jump_Mode
	beq setBGScroll	; �W�����v���ĂȂ��Ȃ炻�̂܂�

	lda #0				; �����x�N���A
	sta <Jump_VY
	lda Sprite1_Y		; Y���W�␳
	and #$f8
	sta Sprite1_Y
	dec <Jump_Mode		; �W�����v���[�h�I��
	jmp setBGScroll
.isHitBlock4
	lda <Jump_Mode
	bne addGrav			; ���łɃW�����v���Ȃ炻�̂܂�
	lda #0				; �����x�N���A
	sta <Jump_VY
	inc <Jump_Mode		; �����J�n

addPreGrav:
	; �W�����v����A1�񂾂�$2007������������
	lda <Jump_VY
	cmp #$F4		; �W�����v�����x�����l�Ɠ������H
	bne addGrav
	lda $2002		; VRAM���W�X�^������
	lda #$20
	sta $2006
	sta $2006
	lda $2007
addGrav:

	; �W�����v�����x���Z
	lda Sprite1_Y
	clc
	adc <Jump_VY		; �W�����vY�����x���Z
	sta Sprite1_Y

	; �W�����v�����x�ɏd�͉��Z
	inc <Jump_VY
	; �d�͉����x���~�b�^�[
	lda <Jump_VY
	cmp #5				; �ő�4
	bne setBGScroll
	dec <Jump_VY

setBGScroll:
	; BG�X�N���[��(���̃^�C�~���O�Ŏ��s����)
	lda $2002			; �X�N���[���l�N���A
	lda <Scroll_X		; X�̃X�N���[���l�����[�h
	sta $2005			; X�����X�N���[��
	lda #0
	sta $2005			; Y�����X�N���[���iY�����͌Œ�)

	; �\������l�[���e�[�u���ԍ�(bit1~0)���Z�b�g����
	; PPU�A�h���X�C���N�������g��+32�ɂ���
	lda #%10110101				; �l�[���e�[�u��$2400���w��
	ldx <NameTblNum
	bne setNameTblNum
	lda #%10110100				; �l�[���e�[�u��$2000���w��
setNameTblNum:
	sta $2000

	; �p�b�hI/O���W�X�^�̏���
	lda #$01
	sta $4016
	lda #$00
	sta $4016

	; �p�b�h���̓`�F�b�N
	lda $4016  ; A�{�^�����X�L�b�v
	and #1     ; AND #1
	bne AKEYdown ; 0�łȂ��Ȃ�Ή�����Ă�̂�AKeydown�փW�����v	
isBKEYdown:
	lda $4016  ; B�{�^�����X�L�b�v
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

AKEYdown:
	; �W�����v
	lda <Jump_Mode
	bne isBKEYdown	; 0�ȊO�Ȃ猻�݃W�����v��
	lda #$F4		; �W�����v�����x
	sta <Jump_VY
	inc <Jump_Mode	; �W�����v���[�h��
	jmp isBKEYdown	; ���E���͂��󂯕t����

LEFTKEYdown:
	jsr moveLeft
	jmp NOTHINGdown
RIGHTKEYdown:
	jsr moveRight
NOTHINGdown:

	rti				; ���荞�݂��畜�A

IRQ:
	rti

moveRight:
	; �E�ړ�
	clc
	lda <Walk_Cnt
	adc #2
	sta <Walk_Cnt
	bcc .moveRightSub	; ���オ�肵����l�[���e�[�u���؂�ւ�
	lda <Walk_Page
	eor #1
	sta <Walk_Page
.moveRightSub
	lda #0
	sta Sprite1_S	; �E������
	lda Sprite1_X
	cmp #120		; ��ʒ������H
	beq .moveRightSub2
	inc Sprite1_X	; �X�v���C�gX���W�����Z
	inc Sprite1_X	; �X�v���C�gX���W�����Z
	rts
.moveRightSub2
	inc <Scroll_X	; �X�N���[��X���W�����Z
	inc <Scroll_X	; �X�N���[��X���W�����Z
	inc Floor_Cnt	; ���J�E���^�[���Z
	rts

moveLeft:
	; ���ړ�
	lda #%01000000
	sta Sprite1_S		; ��������
	lda Sprite1_X
	beq .moveLeftSub	; ���W0�Ȃ猸�Z���Ȃ�
	dec Sprite1_X		; �X�v���C�gX���W�����Z
	dec Sprite1_X		; �X�v���C�gX���W�����Z
	sec
	lda <Walk_Cnt
	sbc #2
	sta <Walk_Cnt
	bcs .moveLeftSub	; �������肵����l�[���e�[�u���؂�ւ�
	lda <Walk_Page
	eor #1
	sta <Walk_Page
.moveLeftSub
	rts

	; �����f�[�^
X_Pos_Init   .db 120      ; X���W�����l
Y_Pos_Init   .db 208      ; Y���W�����l

	; �w�i�f�[�^(10x2�EY���W�E�p���J�E���^)
Course_Tbl    .db 3,4,5,10,8,10,3,10,6,5,9,10,12,15,7,8,10,10,5,6

tilepal: .incbin "giko5.pal" ; �p���b�g��include����

	.bank 2       ; �o���N�Q
	.org $0000    ; $0000����J�n

	.incbin "giko3.spr"  ; �X�v���C�g�f�[�^�̃o�C�i���B�t�@�C����include����
	.incbin "giko5.bkg"  ; �w�i�f�[�^�̃o�C�i���B�t�@�C����include����
