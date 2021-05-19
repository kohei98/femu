	; ���X�^�[�X�N���[���T���v��

	; INES�w�b�_�[
	.inesprg 1 ;   - �v���O�����ɂ����̃o���N���g�����B���͂P�B
	.ineschr 1 ;   - �O���t�B�b�N�f�[�^�ɂ����̃o���N���g�����B���͂P�B
	.inesmir 0 ;   - �����~���[�����O
	.inesmap 0 ;   - �}�b�p�[�B�O�Ԃɂ���B

	; �[���y�[�W�ϐ�
Scroll_X1 = $00	; ��i�X�N���[���l
Scroll_X2 = $01	; ���i�X�N���[���l
Scroll_X3 = $02	; ���i�X�N���[���l

	.bank 1      ; �o���N�P
	.org $FFFA   ; $FFFA����J�n

	.dw mainLoop ; VBlank���荞�݃n���h��(1/60�b����mainLoop���R�[�������)
	.dw Start    ; ���Z�b�g���荞�݁B�N�����ƃ��Z�b�g��Start�ɔ��
	.dw IRQ      ; �n�[�h�E�F�A���荞�݂ƃ\�t�g�E�F�A���荞�݂ɂ���Ĕ���

	.bank 0		; �o���N�O

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
	ldx #$00		; X���W�X�^�N���A

	; VRAM�A�h���X���W�X�^��$2006�ɁA�p���b�g�̃��[�h��̃A�h���X$3F00���w�肷��B
	lda #$3F
	sta $2006
	lda #$00
	sta $2006

loadPal:			; ���x���́A�u���x�����{:�v�̌`���ŋL�q
	lda tilepal, x	; A��(ourpal + x)�Ԓn�̃p���b�g�����[�h����

	sta $2007		; $2007�Ƀp���b�g�̒l��ǂݍ���

	inx				; X���W�X�^�ɒl��1���Z���Ă���

	cpx #32			; X��32(10�i���BBG�ƃX�v���C�g�̃p���b�g�̑���)�Ɣ�r���ē������ǂ�����r���Ă���	
	bne loadPal		;	�オ�������Ȃ��ꍇ�́Aloadpal���x���̈ʒu�ɃW�����v����
	; X��32�Ȃ�p���b�g���[�h�I��

	; ����(BG�̃p���b�g�w��f�[�^)�����[�h

	; $23C0�̑����e�[�u���Ƀ��[�h����
	lda #$23
	sta $2006
	lda #$C0
	sta $2006

	ldx #$00		; X���W�X�^�N���A
	lda #%00000000	; �S�Ƃ��p���b�g0��
	; �S��0�Ԃɂ���
loadAttrib
	sta $2007		; $2007�ɑ����̒l($0)��ǂݍ���
	; 64��(�S�L�����N�^�[��)���[�v����
	inx
	cpx #64
	bne loadAttrib

	; �l�[���e�[�u������(250+230=480���0�ԁA1�Ԃ̏��ō��v960�񏑂�����)

	; �l�[���e�[�u����$2000���琶������
	lda #$20
	sta $2006
	lda #$00
	sta $2006

	lda #$00        ; 0��(����)
	ldx #$00		; X���W�X�^������
	jmp loadNametable2
loadNametable1:
	lda #$01        ; 1��(�n��)
	ldx #$00		; X���W�X�^������
loadNametable2:
	sta $2007		; $2007�ɏ�������
	inx
	cpx #250		; 250��J��Ԃ�
	bne loadNametable2
	ldx $00
loadNametable3:
	sta $2007		; $2007�ɏ�������
	inx
	cpx #230		; 230��J��Ԃ�
	bne loadNametable3
	cmp #$01
	bne loadNametable1	; �܂������Ȃ̂Ŗ߂�

	; �[���y�[�W������
	lda #$00
	ldx #$00
initZeroPage:
	sta <$00, x
	inx
	bne initZeroPage

	; PPU�R���g���[�����W�X�^2������
	lda #%00011110	; �X�v���C�g��BG�̕\����ON�ɂ���
	sta $2001

	; PPU�R���g���[�����W�X�^1�̊��荞�݋��t���O�𗧂Ă�
	lda #%10001000
	sta $2000

	; ���X�^�[�X�N���[���J�n�_��0�ԃX�v���C�g�z�u
	lda #$00   ; $00(�X�v���C�gRAM�̃A�h���X��8�r�b�g��)��A�Ƀ��[�h
	sta $2003  ; A�̃X�v���C�gRAM�̃A�h���X���X�g�A

	lda #119	; �X�L�������C���̐^��(���X�^�[�X�N���[���J�n�_)
	sta $2004   ; Y���W�����W�X�^�ɃX�g�A����
	lda #00
	sta $2004   ; 0���X�g�A����0�Ԃ̃X�v���C�g���w�肷��
	sta $2004   ; ���]��D�揇�ʂ͑��삵�Ȃ��̂ŁA�ēx$00���X�g�A����
	lda #0
	sta $2004   ; X���W�����W�X�^�ɃX�g�A����

infinityLoop:					; VBlank���荞�ݔ�����҂����̖������[�v

waitZeroSpriteClear:			; 0�ԃX�v���C�g�`��O�܂ő҂�
	bit $2002
	bvs waitZeroSpriteClear		; $2002��6�r�b�g�ڂ�0�ɂȂ�܂ő҂�
waitZeroSpriteHit:				; 0�ԃX�v���C�g�`��܂ő҂�
	bit $2002
	bvc waitZeroSpriteHit		; $2002��6�r�b�g�ڂ�1�ɂȂ�܂ő҂�

	; BG�X�N���[��(��i)
	lda $2002		; �X�N���[���l�N���A
	lda <Scroll_X1	; ��i�X�N���[���l�����[�h
	lsr a			; A���W�X�^�E�V�t�g(�����ɂ���)
	jsr doScrollX
	inc <Scroll_X1	; �X�N���[���l�����Z

	jsr waitScan
	jsr waitScan
	jsr waitScan

	; BG�X�N���[��(���i)
	lda $2002		; �X�N���[���l�N���A
	lda <Scroll_X2	; ���i�X�N���[���l�����[�h
	jsr doScrollX
	inc <Scroll_X2	; �X�N���[���l�����Z

	jsr waitScan
	jsr waitScan
	jsr waitScan

	; BG�X�N���[��(���i)
	lda $2002		; �X�N���[���l�N���A
	lda <Scroll_X3	; ���i�X�N���[���l�����[�h
	lsr a			; A���W�X�^�E�V�t�g(�����ɂ���)
	jsr doScrollX
	inc <Scroll_X3	; �X�N���[���l�����Z
	inc <Scroll_X3	; �X�N���[���l�����Z
	inc <Scroll_X3	; �X�N���[���l�����Z

	jmp infinityLoop

mainLoop:			; ���C�����[�v
	; �X�N���[���Œ�(VBlank���荞�ݒ���Ɏ��s����̂ŁA���̉�ʕ`��̍ŏ�����Œ肷�邱�ƂɂȂ�)
	lda $2002		; �X�N���[���l�N���A
	lda #$00
	jsr doScrollX

	rti				; ���荞�݂��畜�A

doScrollX			; X�����X�N���[��(A���W�X�^�ɒl�Z�b�g��)
	sta $2005		; X�����X�N���[��
	lda #$00		; Y�����Œ�
	sta $2005
	rts

waitScan			; ���������҂�
	ldx #255
.waitScanSub
	dex
	bne .waitScanSub
	rts

IRQ:
	rti

tilepal: .incbin "giko3.pal" ; �p���b�g��include����

	.bank 2       ; �o���N�Q
	.org $0000    ; $0000����J�n

	.incbin "giko3.bkg"  ; �w�i�f�[�^�̃o�C�i���B�t�@�C����include����
	.incbin "giko2.spr"  ; �X�v���C�g�f�[�^�̃o�C�i���B�t�@�C����include����
