	; �X�v���C�g�ړ��T���v��

	; INES�w�b�_�[
	.inesprg 1 ;   - �v���O�����ɂ����̃o���N���g�����B���͂P�B
	.ineschr 1 ;   - �O���t�B�b�N�f�[�^�ɂ����̃o���N���g�����B���͂P�B
	.inesmir 0 ;   - �����~���[�����O
	.inesmap 0 ;   - �}�b�p�[�B�O�Ԃɂ���B

	.bank 1      ; �o���N�P
	.org $FFFA   ; $FFFA����J�n

	.dw 0        ; VBlank���荞��
	.dw Start    ; ���Z�b�g���荞�݁B�N�����ƃ��Z�b�g��Start�ɔ��
	.dw 0        ; �n�[�h�E�F�A���荞�݂ƃ\�t�g�E�F�A���荞�݂ɂ���Ĕ���

	.bank 0			 ; �o���N�O
	.org $0000	 ; $0000����J�n
X_Pos   .db 0	 ; �X�v���C�gX���W�̕ϐ�($0000)
Y_Pos   .db 0	 ; �X�v���C�gY���W�̕ϐ�($0001)

	.org $8000	 ; $8000����J�n
Start:
	lda $2002  ; VBlank����������ƁA$2002��7�r�b�g�ڂ�1�ɂȂ�
	bpl Start  ; bit7��0�̊Ԃ́AStart���x���̈ʒu�ɔ��Ń��[�v���đ҂�

	; PPU�R���g���[�����W�X�^������
	lda #%00001000 
	sta $2000
	lda #%00000110		; ���������̓X�v���C�g��BG��\��OFF�ɂ���
	sta $2001

	ldx #$00    ; X���W�X�^�N���A

	; VRAM�A�h���X���W�X�^��$2006�ɁA�p���b�g�̃��[�h��̃A�h���X$3F00���w�肷��B
	lda #$3F    ; have $2006 tell
	sta $2006   ; $2007 to start
	lda #$00    ; at $3F00 (pallete).
	sta $2006

loadPal:			; ���x���́A�u���x�����{:�v�̌`���ŋL�q
	lda tilepal, x ; A��(ourpal + x)�Ԓn�̃p���b�g�����[�h����

	sta $2007 ; $2007�Ƀp���b�g�̒l��ǂݍ���

	inx ; X���W�X�^�ɒl��1���Z���Ă���

	cpx #32 ; X��32(10�i���BBG�ƃX�v���C�g�̃p���b�g�̑���)�Ɣ�r���ē������ǂ�����r���Ă���	
	bne loadPal ;	�オ�������Ȃ��ꍇ�́Aloadpal���x���̈ʒu�ɃW�����v����
	; X��32�Ȃ�p���b�g���[�h�I��

	; �X�v���C�g���W������
	lda X_Pos_Init
	sta X_Pos
	lda Y_Pos_Init
	sta Y_Pos

	; PPU�R���g���[�����W�X�^2������
	lda #%00011110	; �X�v���C�g��BG�̕\����ON�ɂ���
	sta $2001

mainLoop:					; ���C�����[�v
	lda $2002  ; VBlank����������ƁA$2002��7�r�b�g�ڂ�1�ɂȂ�܂��B
	bpl mainLoop  ; bit7��0�̊Ԃ́AmainLoop���x���̈ʒu�ɔ��Ń��[�v���đ҂������܂��B

	; �X�v���C�g�`��
	lda #$00   ; $00(�X�v���C�gRAM�̃A�h���X��8�r�b�g��)��A�Ƀ��[�h
	sta $2003  ; A�̃X�v���C�gRAM�̃A�h���X���X�g�A

	lda Y_Pos  ; Y���W�̒l�����[�h
	sta $2004	 ; Y���W�����W�X�^�ɃX�g�A����

	lda #00     ; 0(10�i��)��A�Ƀ��[�h
	sta $2004   ; 0���X�g�A����0�Ԃ̃X�v���C�g���w�肷��
	sta $2004   ; ���]��D�揇�ʂ͑��삵�Ȃ��̂ŁA�ēx$00���X�g�A����

	lda X_Pos  ; X���W�̒l�����[�h
	sta $2004	 ; X���W�����W�X�^�ɃX�g�A����
	
	; �p�b�hI/O���W�X�^�̏���
	lda #$01
	sta $4016
	lda #$00 
	sta $4016

	; �p�b�h���̓`�F�b�N
	lda $4016  ; A�{�^�����X�L�b�v
	lda $4016  ; B�{�^�����X�L�b�v
	lda $4016  ; Select�{�^�����X�L�b�v
	lda $4016  ; Start�{�^�����X�L�b�v
	lda $4016  ; ��{�^��
	and #1     ; AND #1
	bne UPKEYdown  ; 0�łȂ��Ȃ�Ή�����Ă�̂�UPKeydown�փW�����v
	
	lda $4016  ; ���{�^��
	and #1     ; AND #1
	bne DOWNKEYdown ; 0�łȂ��Ȃ�Ή�����Ă�̂�DOWNKeydown�փW�����v

	lda $4016  ; ���{�^��
	and #1     ; AND #1
	bne LEFTKEYdown ; 0�łȂ��Ȃ�Ή�����Ă�̂�LEFTKeydown�փW�����v

	lda $4016  ; �E�{�^��
	and #1     ; AND #1
	bne RIGHTKEYdown ; 0�łȂ��Ȃ�Ή�����Ă�̂�RIGHTKeydown�փW�����v
	jmp NOTHINGdown  ; �Ȃɂ�������Ă��Ȃ��Ȃ��NOTHINGdown��

UPKEYdown:
	dec Y_Pos	; Y���W��1���Z�B�[���y�[�W�Ȃ̂ŁA�ȉ��̃R�[�h�����̂P���߂ɒZ�k�ł���
;	lda Y_Pos ; Y���W�����[�h
;	sbc #1  ; #1���Z����
;	sta Y_Pos ; Y���W���X�g�A

	jmp NOTHINGdown

DOWNKEYdown:
	inc Y_Pos ; Y���W��1���Z
	jmp NOTHINGdown

LEFTKEYdown:
	dec X_Pos	; X���W��1���Z
	jmp NOTHINGdown 

RIGHTKEYdown:
	inc X_Pos	; X���W��1���Z
	; ���̌�NOTHINGdown�Ȃ̂ŃW�����v����K�v����

NOTHINGdown:
	jmp mainLoop				; mainLoop�̍ŏ��ɖ߂�

	; �����f�[�^
X_Pos_Init   .db 20       ; X���W�����l
Y_Pos_Init   .db 40       ; Y���W�����l

tilepal: .incbin "giko.pal" ; �p���b�g��include����

	.bank 2       ; �o���N�Q
	.org $0000    ; $0000����J�n

	.incbin "giko.bkg"  ; �w�i�f�[�^�̃o�C�i���B�t�@�C����include����
	.incbin "giko.spr"  ; �X�v���C�g�f�[�^�̃o�C�i���B�t�@�C����include����
