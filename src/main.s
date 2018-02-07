.area _DATA
.area _CODE

.include "keyboard/keyboard.s"
.globl cpct_waitVSYNC_asm
.globl cpct_scanKeyboard_asm
.globl cpct_isKeyPressed_asm
.globl cpct_isAnyKeyPressed_asm
.globl cpct_setInterruptHandler_asm

.equ	ayctrl, #65533
.equ	aydata, #49149

.equ	channel_A,	#0
.equ	channel_B,	#1
.equ	channel_C,	#2
.equ	channel_silence,#3

.equ 	n_waits,	#6

.equ	channel_A_volume,	#15
.equ	channel_B_volume,	#15
.equ	channel_C_volume,	#15

current_octave: 	.db #4
current_noise:		.db #0
current_A_volume:	.db #channel_A_volume

.equ	_C,	#1
.equ	_Cs,	#2
.equ	_D,	#3
.equ	_Ds,	#4
.equ	_E,	#5
.equ	_F,	#6
.equ	_Fs,	#7
.equ	_G,	#8
.equ	_Gs,	#9
.equ	_A,	#10
.equ	_As,	#11
.equ	_B,	#12

tunes_table:
	.dw #3822	;   C	-   1	;
	.dw #3608	;   C#	-   2	;
	.dw #3405	;   D	-   3	;
	.dw #3214	;   D#	-   4	;
	.dw #3034	;   E	-   5	;
	.dw #2863	;   F	-   6	;
	.dw #2703	;   F#	-   7	;
	.dw #2551	;   G	-   8	;
	.dw #2408	;   G#	-   9	;
	.dw #2273	;   A	-   10	;
	.dw #2145	;   A#	-   11	;
	.dw #2025	;   B	-   12	;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; AY-3-8910/2 registers ID table
.equ A_f_pitch_reg,		#0
.equ A_c_pitch_reg,		#1
.equ B_f_pitch_reg,		#2
.equ B_c_pitch_reg,		#3
.equ C_f_pitch_reg,		#4
.equ C_c_pitch_reg,		#5
.equ noise_period_reg,		#6
.equ mixer_reg,			#7
.equ A_volume_reg,		#8
.equ B_volume_reg,		#9
.equ C_volume_reg,		#10
.equ f_envelope_period_reg,	#11
.equ c_envelope_period_reg,	#12
.equ envelope_shape_reg,	#13
.equ A_in_out_reg,		#14
.equ B_in_out_reg,		#15

.equ	player_period, 	#50
player_n_interruptions: .db #player_period

; FIRST TEST
; Input
; note 3421
; octave 4
; 
; Output
; fine 213
; course 0
; tune playing

; SECOND TEST
; Input
; note 3421 (C)
; octave 0-8
;
; Output
; Octave:Fine - Course
; 0:	 3421 - 13
; 1:	 1710 - 6
; 2:	  855 - 3
; 3:	  427 - 1
; 4:	  213 - 0
; 5:	  106 - 0
; 6:	   53 - 0
; 7:	   26 - 0
; 8:	   13 - 0


_main::
	call initialize_player
	ld	ix, #current_octave	; IX <= octave position
	loop:

		jp 	loop

musicHandler::
	ld 	a, (player_n_interruptions)
	dec 	a
	jr 	nz, not_play
		;; n_interruptions == 0
		call 	play_frame
		ld 	a, #player_period

	not_play:
		ld 	(player_n_interruptions), a
	ret

initialize_player:
	ld	a, #channel_A_volume
	ld	c, #A_volume_reg
	call 	set_AY_register

	ld	a, #channel_B_volume
	ld	c, #B_volume_reg
	call 	set_AY_register

	ld	a, #channel_C_volume
	ld	c, #C_volume_reg
	call 	set_AY_register

	ld 	a, #10
	ld	c, #envelope_shape_reg
	call 	set_AY_register

	ld 	a, #0x03
	ld	c, #c_envelope_period_reg
	call 	set_AY_register

	ld 	a, #0xFF
	ld	c, #f_envelope_period_reg
	call 	set_AY_register

	ld 	a, #0
	ld	c, #noise_period_reg
	call 	set_AY_register

	ld 	hl, #musicHandler
	call 	cpct_setInterruptHandler_asm

	call 	init_PSG_mixer

	ld	hl, #song_1
	call	set_song_pointer

	ret


;; A => given value to set
;; C => register ID
;;
;; DESTROYS BC
set_AY_register:
	ld 	b,#0xF4
	out 	(c), c
	ld 	bc,#0xF6C0
	out 	(c),c
	.db #0xED, #0x71

	ld 	b,#0xF4
	out 	(c), a
	ld 	bc,#0xF680
	out 	(c),c
	.db #0xED, #0x71

	ret

.equ silence_command, 	#0b10000000
.equ end_song_command, 	#0b10000001
.equ sustain_command, 	#0b10000010

;;			0	1	2	3	4	5	6	7	 8
;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
song_1::	.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
		.db 	#15,	#_C,	#4,	#12,	#_F,	#4,	#0,	#_G,	#4
		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#12,	#_G,	#4
		; .db 	#silence_command
		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#0,	#_C,	#5
		.db 	#15,	#_F,	#4,	#12,	#_A,	#4,	#0,	#_C,	#5
		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#12,	#_C,	#5
		; .db 	#silence_command
		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db 	#15,	#_G,	#4,	#12,	#_B,	#4,	#0,	#_D,	#5
		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#12,	#_D,	#5
		; .db 	#silence_command
		.db	#end_song_command


;;;;;;;;;;; SONG 1 HACE UN RUIDO AL FINAL ;;;;;;;;;;;;;;;;


;;			0	1	2	3	4	5	6	7	 8
;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
song_2::	.db 	#15,	#_C,	#3,	#0,	#_F,	#4,	#0,	#_G,	#4
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
		.db	#sustain_command
		.db	#sustain_command
		.db 	#15,	#_G,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db 	#15,	#_C,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db 	#15,	#_G,	#2,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db 	#15,	#_As,	#2,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db 	#15,	#_C,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db 	#15,	#_Ds,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#sustain_command
		.db	#sustain_command
		.db	#end_song_command

current_song_init_pointer: 	.dw #0
current_song_pointer: 		.dw #0

;; HL => song pointer
set_song_pointer:
	ld	(current_song_init_pointer), hl
	ld	(current_song_pointer), hl
	ret

play_frame::
	ld	hl, (current_song_pointer)

	ld	a, (hl)
	cp 	#silence_command
	jr	z, play_silence

		cp 	#end_song_command
		jr	z, play_end
			cp 	#sustain_command
			jr	z, play_sustain
				call 	init_PSG_mixer
				;; play A tune
				ld	c, #A_volume_reg	; C <= A volume register ID
				ld	d, #channel_A		; D <= channel A ID
				call	play_frame_tune

				;; play B tune
				ld	c, #B_volume_reg	; C <= B volume register ID
				ld	d, #channel_B		; D <= channel B ID
				call	play_frame_tune

				;; play C tune
				ld	c, #C_volume_reg	; C <= C volume register ID
				ld	d, #channel_C		; D <= channel C ID
				call	play_frame_tune

				jr	exit_play_frame

			play_silence:
				call 	silence_PSG_mixer
				inc 	hl
				jr	exit_play_frame

			play_sustain:
				inc 	hl
				jr	exit_play_frame

			play_end:
				ld 	hl, (current_song_init_pointer)
				ld	(current_song_pointer), hl
				call 	play_frame
				;ret

	exit_play_frame:

	ld	(current_song_pointer), hl

	ret

;; C => AY register ID
;; D => channel ID
;;
;; HL keeps updated here
;; DESTROYS: AF, BC, DE, HL
play_frame_tune::
	ld	a, (hl)			; read value 
	call	set_AY_register		; set C AY register
	inc 	hl

	ld	a, d		; A <= channel ID
	ld	b, (hl)		; B <= tune ID
	inc 	hl		;
	ld 	c, (hl)		; C <= octave
	inc 	hl

	push	hl
	call	play_note
	pop 	hl

	ret

;; A => channel ID
;; B => tune ID
;; C => octave
;;
;; DESTROYS: AF, BC, HL
play_note::
	cp #channel_A
	jr nz, is_channel_B
		; CHANNEL A
		ld	e, #A_f_pitch_reg
		ld	d, #A_c_pitch_reg
		call	player_note_channel

		ret
	is_channel_B:
		cp #channel_B
		jr nz, is_channel_C
			; CHANNEL B
			ld	e, #B_f_pitch_reg
			ld	d, #B_c_pitch_reg
			call	player_note_channel

			ret
	is_channel_C:
		cp #channel_C
		jr nz, exit_channel_selection
			; CHANNEL C
			ld	e, #C_f_pitch_reg
			ld	d, #C_c_pitch_reg
			call	player_note_channel

			ret

	exit_channel_selection:
	ret

;; B => tune ID
;; C => octave
;; D => coarse pitch register ID
;; E => fine pitch register ID
player_note_channel::
	push 	de
	call	get_fine_pitch	; HL <= fine pitch value
	pop	de

	ld	a, l
	ld	c, e		; C <= fine pitch register ID
	call	set_AY_register

	ld	a, h		; A <= course pitch value (HL/256)
	ld	c, d		; C <= coarse pitch register ID
	call	set_AY_register
	ret

silence_PSG_mixer:
	ld 	a, #0b00111111
	ld	c, #mixer_reg
	call	set_AY_register
	ret

init_PSG_mixer:
	ld	a, #0b00111000
	ld	c, #mixer_reg
	call	set_AY_register
	ret

;; B => tune ID
;; C => octave
;; 
;; HL <= fine pitch value
;; DESTROYS: AF, BC, DE
get_fine_pitch::
	ld	a, b		; A <= tune ID
	call 	get_tune	; HL <= tune value

	ld	a, c
	cp	#0
	jr	nz, octaves_loop
		; octave is 0
		ld	a, h	; A <= tune value integer part
		ret
	octaves_loop:
		srl 	h			;
		rr 	l			; HL/2
		dec 	c
		jr	nz, octaves_loop	; EXIT IF C-- == ZERO
	ret

;; A => tune ID
;; HL <= tune value
;;
;; DESTROYS AF, DE, HL
get_tune:
	ld	hl, #tunes_table	; HL <= Tunes vector address
	ld	de, #0			;
	ld	e, a			; DE <= A
	add 	hl, de			;
	add 	hl, de			; HL <= vector adress + tuneIDx2

	ld	e, (hl)			; 
	inc 	l			; 
	ld	d, (hl)			; DE <= tune value

	ex 	de, hl 			; HL <= tune value

	ret

check_input::
	call 	cpct_scanKeyboard_asm

	call 	cpct_isAnyKeyPressed_asm
	cp 	#0
	jp	z, none_key_pressed
		;; any key is pressed
		call init_PSG_mixer
		ld 	hl, #Key_Z			;; HL = Keycode
		call 	cpct_isKeyPressed_asm 		;; A = True/False
		cp 	#0 				;; A == 0?
		jr 	z, z_not_pressed
			ld	a, (current_octave)
			ld	c, a
			ld	a, #channel_A
			ld	b, # _C
			call 	play_note
		z_not_pressed:
			ld 	hl, #Key_S			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, s_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _Cs
				call 	play_note
		s_not_pressed:
			ld 	hl, #Key_X			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, x_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _D
				call 	play_note
		x_not_pressed:
			ld 	hl, #Key_D			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, d_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _Ds
				call 	play_note
		d_not_pressed:
			ld 	hl, #Key_C			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, c_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _E
				call 	play_note
		c_not_pressed:
			ld 	hl, #Key_V			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, v_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _F
				call 	play_note
		v_not_pressed:
			ld 	hl, #Key_G			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, g_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _Fs
				call 	play_note
		g_not_pressed:
			ld 	hl, #Key_B			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, b_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _G
				call 	play_note
		b_not_pressed:
			ld 	hl, #Key_H			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, h_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _Gs
				call 	play_note
		h_not_pressed:
			ld 	hl, #Key_N			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, n_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _A
				call 	play_note
		n_not_pressed:
			ld 	hl, #Key_J			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, j_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _As
				call 	play_note
		j_not_pressed:
			ld 	hl, #Key_M			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, m_not_pressed
				ld	a, (current_octave)
				ld	c, a
				ld	a, #channel_A
				ld	b, # _B
				call 	play_note
		m_not_pressed:
			ld 	hl, #Key_Comma			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, comma_not_pressed
				ld	a, (current_octave)
				inc 	a
				ld	c, a
				ld	a, #channel_A
				ld	b, # _C
				call 	play_note
		comma_not_pressed:
			ld 	hl, #Key_L			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, l_not_pressed
				ld	a, (current_octave)
				inc 	a
				ld	c, a
				ld	a, #channel_A
				ld	b, # _Cs
				call 	play_note
		l_not_pressed:
			ld 	hl, #Key_Dot			;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, dot_not_pressed
				ld	a, (current_octave)
				inc 	a
				ld	c, a
				ld	a, #channel_A
				ld	b, # _D
				call 	play_note

		dot_not_pressed:
			ld 	hl, #Key_CursorUp		;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, plus_not_pressed
				call silence_PSG_mixer
				call 	inc_current_octave

		plus_not_pressed:
			ld 	hl, #Key_CursorDown		;; HL = Keycode
			call 	cpct_isKeyPressed_asm 		;; A = True/False
			cp 	#0 				;; A == 0?
			jr 	z, minus_not_pressed
				call 	silence_PSG_mixer
				call 	dec_current_octave

		minus_not_pressed:

	ret
	none_key_pressed:
		; silence
		call silence_PSG_mixer
	ret

; 0-9
.equ octave_lower_limit, 	#0
.equ octave_upper_limit, 	#32


set_current_octave:

	ret

inc_current_octave:
	ld	a, (current_octave)
	cp	#octave_upper_limit
	jr	z, inc_limit_exceed
		inc	a
		ld	(current_octave), a
		ret
	inc_limit_exceed:
		ld	a, #octave_upper_limit
		ld	(current_octave), a
	ret

dec_current_octave:
	ld	a, (current_octave)
	cp	#octave_lower_limit
	jr	z, dec_limit_exceed
		dec	a
		ld	(current_octave), a
		ret
	dec_limit_exceed:
		ld	a, #octave_lower_limit
		ld	(current_octave), a
	ret


; doc : https://github.com/AugustoRuiz/WYZTracker/blob/master/AsmPlayer/WYZPROPLAY47c_CPC.ASM
; doc : http://www.cpcwiki.eu/imgs/d/dc/Ay3-891x.pdf
; Link: http://www.sinclair.hu/hardver/otletek/ay_doc/AY-3-8912.htm
; Link: http://cpctech.cpc-live.com/docs/psg.html
; http://www.cpcmania.com/Docs/Manuals/Manual%20de%20Usuario%20Amstrad%20CPC%20464.pdf
; http://www.z80.info/zip/z80cpu_um.pdf#G10.1000022639
; http://www.next.gr/uploads/63/circuit.diagram.cpc464.png

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 		AY-3-8910 REGISTERS
;;
;; 	0	Channel A fine pitch	8-bit (0-255)
;; 	1	Channel A course pitch	4-bit (0-15)
;; 	2	Channel B fine pitch	8-bit (0-255)
;; 	3	Channel B course pitch	4-bit (0-15)
;; 	4	Channel C fine pitch	8-bit (0-255)
;; 	5	Channel C course pitch	4-bit (0-15)
;; 	6	Noise pitch	5-bit (0-31)
;; 	7	Mixer	8-bit (see below)
;; 	8	Channel A volume	4-bit (0-15, see below)
;; 	9	Channel B volume	4-bit (0-15, see below)
;; 	10	Channel C volume	4-bit (0-15, see below)
;; 	11	Envelope fine duration	8-bit (0-255)
;; 	12	Envelope course duration	8-bit (0-255)
;; 	13	Envelope shape	4-bit (0-15)
;; 	14	I/O port A	8-bit (0-255)
;; 	15	I/O port B	8-bit (0-255)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 				MIXER
;; Bit: 7 	6 	5 	4 	3 	2 	1 	0
;; 	I/O 	I/O 	Noise 	Noise 	Noise 	Tone 	Tone 	Tone
;; 	B 	A 	C 	B 	A 	C 	B 	A
;; The AY-3-8912 ignores bit 7 of this register.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;			ENVELOPES
;;
;; Select with register 13
;; 0	\_________	single decay then off
;; 1	/	single attack then hold
;; 4	/|_________	single attack then off
;; 8	\|\|\|\|\|\|\|\|\|\|\|\	repeated decay
;; 9	\_________	single decay then off
;; 10	\/\/\/\/\/\/\/\/\/\	repeated decay-attack
;; 11	\| 	single decay then hold
;; 12	/|/|/|/|/|/|/|/|/|/|/|/	repeated attack
;; 14	/\/\/\/\/\/\/\/\/\/	repeated attack-decay
;; 15	/|_________	single attack then off



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;		PITCH
;;
;;	fine 	= value/2^octave
;;	course	= fine/256
;;	
;;	Note 	Frequency (Hz) 	
;;	A 	220
;;	A# 	233.3
;;	B 	246.94
;;	C	261.63 	
;;	C# 	277.2
;;	D 	293.66
;;	D# 	311.1
;;	E 	329.63
;;	F 	349.23
;;	F# 	370
;;	G 	392
;;	G# 	415.3
;;	
;;	Note	Value
;;	C	3421
;;	C#	3228
;;	D	3047
;;	D#	2876
;;	E	2715
;;	F	2562
;;	F#	2419
;;	G	2283
;;	G#	2155
;;	A	2034
;;	A#	1920
;;	B	1892