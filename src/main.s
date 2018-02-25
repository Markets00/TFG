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

.equ	_C,	#0
.equ	_Cs,	#1
.equ	_D,	#2
.equ	_Ds,	#3
.equ	_E,	#4
.equ	_F,	#5
.equ	_Fs,	#6
.equ	_G,	#7
.equ	_Gs,	#8
.equ	_A,	#9
.equ	_As,	#10
.equ	_B,	#11

tunes_table::
;; OCTAVE -3,
	.dw #3822	;   C	-   0	;
	.dw #3608	;   C#	-   1	;
	.dw #3405	;   D	-   2	;
	.dw #3214	;   D#	-   3	;
	.dw #3034	;   E	-   4	;
	.dw #2863	;   F	-   5	;
	.dw #2703	;   F#	-   6	;
	.dw #2551	;   G	-   7	;
	.dw #2408	;   G#	-   8	;
	.dw #2273	;   A	-   9	;
	.dw #2145	;   A#	-   10	;
	.dw #2025	;   B	-   11	;
;; OCTAVE -2,
	.dw #1911, #1804, #1703, #1607, #1517, #1432, #1351, #1276, #1204, #1136, #1073, #1012
;; OCTAVE -1,
	.dw #956, #902, #851, #804, #758, #716, #676, #638, #602, #568, #536, #506
;; OCTAVE 0
	.dw #478, #451, #426, #402, #379, #358, #338, #319, #301, #284, #268, #253
;; OCTAVE 1
	.dw #239, #225, #213, #201, #190, #179, #169, #159, #150, #142, #134, #127
;; OCTAVE 2
	.dw #119, #113, #106, #100, #95, #89, #84, #80, #75, #71, #67, #63
;; OCTAVE 3
	.dw #60, #56, #53, #50, #47, #45, #42, #40, #38, #36, #34, #32
;; OCTAVE 4
	.dw #30, #28, #27, #25, #24, #22, #21, #20, #19, #18, #17, #16

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

.equ	player_period, 	#40
player_n_interruptions: .db #player_period


mixer_config:	.db #0b00111000

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
	ld 	hl, #musicHandler
	call 	cpct_setInterruptHandler_asm

	call 	update_PSG_mixer

	ld	hl, #song_2
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

;;			0	1	2	3	4	5	6	7	 8
;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
song_1::
		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
		.db 	#15,	#_C,	#4,	#12,	#_F,	#4,	#0,	#_G,	#4
		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#12,	#_G,	#4
		.db 	#silence_command
		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#0,	#_C,	#5
		.db 	#15,	#_F,	#4,	#12,	#_A,	#4,	#0,	#_C,	#5
		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#12,	#_C,	#5
		.db 	#silence_command
		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#0,	#_D,	#5
		.db 	#15,	#_G,	#4,	#12,	#_B,	#4,	#0,	#_D,	#5
		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#12,	#_D,	#5
		.db 	#silence_command
		.db	#end_song_command

;;						0	1	2	3	4	5	6	7	 8
;;					  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
song_2::
		.db	#set_B_noise_command,	#31
		.db	#set_envelope_command,	#0,	#0x01,	#0xFF
		.db 	#read_line_command,	#15,	#_B,	#2,	#16,	#_B,	#4,	#0,	#_G,	#4
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db	#set_envelope_command,	#8,	#0x00,	#0xFF
		.db 	#read_line_command,	#15,	#_B,	#3,	#16,	#_B,	#5,	#0,	#_G,	#4
		.db	#sustain_command
		.db	#sustain_command
		.db 	#read_line_command,	#15,	#_Fs,	#3,	#0,	#_B,	#2,	#0,	#_D,	#5
		.db	#set_envelope_command,	#10,	#0x01,	#0xFF
		.db 	#read_line_command,	#15,	#_B,	#2,	#16,	#_B,	#2,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db	#set_envelope_command,	#11,	#0x01,	#0xFF
		.db 	#read_line_command,	#15,	#_Fs,	#2,	#16,	#_B,	#3,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db	#set_envelope_command,	#15,	#0x01,	#0xFF
		.db 	#read_line_command,	#15,	#_A,	#2,	#16,	#_B,	#4,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db	#set_envelope_command,	#14,	#0x01,	#0xFF
		.db 	#read_line_command,	#15,	#_B,	#2,	#16,	#_B,	#1,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#silence_command
		.db 	#silence_command
		.db	#set_envelope_command,	#12,	#0x01,	#0xFF
		.db 	#read_line_command,	#15,	#_D,	#3,	#16,	#_B,	#3,	#0,	#_D,	#5
		.db	#sustain_command
		.db	#sustain_command
		.db	#sustain_command
		.db	#end_song_command

current_song_init_pointer: 	.dw #0
current_song_pointer: 		.dw #0


.equ silence_command, 		#0
.equ end_song_command, 		#1
.equ sustain_command, 		#2
.equ set_A_noise_command,	#3
.equ set_B_noise_command,	#4
.equ set_C_noise_command,	#5
.equ reset_A_noise_command,	#6
.equ reset_B_noise_command,	#7
.equ reset_C_noise_command,	#8
.equ set_envelope_command,	#9
.equ read_line_command,		#10

;; Switch
;;
;;ld a, (hl)
;;add a
;;add a
;;ld (jump_from), a
;;jump_from = .+1
;;jr 00 
;;jp comando1
;;jp comando2
;;jp comando3
;;jp comando4
;;....
;;
;;comando1:
;;	....
;;
;;comando2:
;;	....
;;
;;comando3:
;;	....


;; HL => song pointer
set_song_pointer:
	ld	(current_song_init_pointer), hl
	ld	(current_song_pointer), hl
	ret

play_frame::
	ld	hl, (current_song_pointer)

	ld 	a, (hl)
	ld	b, a
	add 	b
	add 	b
	ld 	(jump_from), a
	jump_from = .+1
	jr silence_code

	jp silence_code		; +0
	jp end_song_code 	; +3
	jp sustain_code		; +6
	jp set_A_noise_code	; +9
	jp set_B_noise_code	; +12
	jp set_C_noise_code	; +15
	jp reset_A_noise_code	; +18
	jp reset_B_noise_code	; +21
	jp reset_C_noise_code	; +24
	jp set_envelope_code	; +27
	jp read_tunes_code	; +30


	silence_code:
	;;	PLAY SILENCE
		call 	silence_PSG_mixer
		inc 	hl
		jp	exit_play_frame

	end_song_code:
	;;	PLAY END
		ld 	hl, (current_song_init_pointer)
		ld	(current_song_pointer), hl
		call 	play_frame
		ret

	sustain_code:
	;;	PLAY SUSTAIN
		inc 	hl
		jp	exit_play_frame

	set_A_noise_code:
	;;	SET A NOISE
		ld	a, (mixer_config)	;
		res	3, a			;
		ld	(mixer_config), a	; enable A channel noise
		call	play_frame_noise_period
		ret

	set_B_noise_code:
	;;	SET B NOISE
		ld	a, (mixer_config)	;
		res	4, a			;
		ld	(mixer_config), a	; enable B channel noise
		call	play_frame_noise_period
		ret

	set_C_noise_code:
	;;	SET C NOISE
		ld	a, (mixer_config)	;
		res	5, a			;
		ld	(mixer_config), a	; enable C channel noise
		call	play_frame_noise_period
		ret

	reset_A_noise_code:
	;;	RESET A NOISE
		ld	a, (mixer_config)	;
		set	3, a			;
		ld	(mixer_config), a	; disable A channel noise
		inc 	hl

		ld	(current_song_pointer), hl
		call 	play_frame
		ret

	reset_B_noise_code:
	;;	RESET B NOISE
		ld	a, (mixer_config)	;
		set	4, a			;
		ld	(mixer_config), a	; disable B channel noise
		inc 	hl

		ld	(current_song_pointer), hl
		call 	play_frame
		ret

	reset_C_noise_code:
	;;	RESET C NOISE
		ld	a, (mixer_config)	;
		set	5, a			;
		ld	(mixer_config), a	; disable C channel noise
		inc 	hl

		ld	(current_song_pointer), hl
		call 	play_frame
		ret

	set_envelope_code:
	;;	SET ENVELOPE
		inc 	hl

		ld	a, (hl)			; A <= envelope shape ID
		ld	c, #envelope_shape_reg
		call	set_AY_register
		inc 	hl

		ld	a, (hl)			; A <= envelope coarse period
		ld	c, #c_envelope_period_reg
		call	set_AY_register
		inc 	hl

		ld	a, (hl)			; A <= envelope fine period
		ld	c, #f_envelope_period_reg
		call	set_AY_register
		inc 	hl

		ld	(current_song_pointer), hl
		call 	play_frame
		ret

	read_tunes_code:
	;;	PLAY TUNES LINE
		inc 	hl

		call 	update_PSG_mixer
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
	
	exit_play_frame:
	ld	(current_song_pointer), hl

	ret

;; HL => current song pointer
;;
;; HL keeps updated here
;; DESTROYS: AF, BC, DE, HL
play_frame_noise_period:
	inc 	hl
	ld	a, (hl)			; A <= noise period value
	ld	c, #noise_period_reg
	call	set_AY_register
	inc 	hl

	ld	(current_song_pointer), hl
	call 	play_frame
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
		call	play_note_channel

		ret
	is_channel_B:
		cp #channel_B
		jr nz, is_channel_C
			; CHANNEL B
			ld	e, #B_f_pitch_reg
			ld	d, #B_c_pitch_reg
			call	play_note_channel

			ret
	is_channel_C:
		cp #channel_C
		jr nz, exit_channel_selection
			; CHANNEL C
			ld	e, #C_f_pitch_reg
			ld	d, #C_c_pitch_reg
			call	play_note_channel

			ret

	exit_channel_selection:
	ret

;; B => tune ID
;; C => octave
;; D => coarse pitch register ID
;; E => fine pitch register ID
play_note_channel::
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

update_PSG_mixer:
	ld	a, (mixer_config)
	ld	c, #mixer_reg
	call	set_AY_register
	ret



;; B => tune ID
;; C => octave
;; 
;; HL <= fine pitch value
;; DESTROYS: AF, BC, DE
get_fine_pitch::
	ld	hl, #tunes_table	; HL <= Tunes vector address
	ld	a, c
	cp	#0
	jr	nz, iterate_octaves
		; octave is 0
		jr exit_octaves
	iterate_octaves:
		ld	de, #24
	octaves_loop:
		add 	hl, de			; HL <= HL + 32 (next octave frequencies address)
		dec 	c
		jr	nz, octaves_loop

	exit_octaves:
		ld	e, b		; E <= tune ID

		ld	d, #0		;
		add 	hl, de		;
		add 	hl, de		; HL <= vector address + tuneIDx2

		ld	e, (hl)		; 
		inc 	hl		; 
		ld	d, (hl)		; DE <= tune value

		ex 	de, hl 		; HL <= tune value

	ret


; UI: dear imgui

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