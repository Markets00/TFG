ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 1.
Hexadecimal [16-Bits]



                              1 .area _DATA
                              2 .area _CODE
                              3 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 2.
Hexadecimal [16-Bits]



                              4 .include "keyboard/keyboard.s"
                              1 ;;-----------------------------LICENSE NOTICE------------------------------------
                              2 ;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
                              3 ;;  Copyright (C) 2014 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
                              4 ;;
                              5 ;;  This program is free software: you can redistribute it and/or modify
                              6 ;;  it under the terms of the GNU Lesser General Public License as published by
                              7 ;;  the Free Software Foundation, either version 3 of the License, or
                              8 ;;  (at your option) any later version.
                              9 ;;
                             10 ;;  This program is distributed in the hope that it will be useful,
                             11 ;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
                             12 ;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
                             13 ;;  GNU Lesser General Public License for more details.
                             14 ;;
                             15 ;;  You should have received a copy of the GNU Lesser General Public License
                             16 ;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
                             17 ;;-------------------------------------------------------------------------------
                             18 .module cpct_keyboard
                             19 
                             20 ;; bndry directive does not work when linking previously compiled files
                             21 ;.bndry 16
                             22 ;;   16-byte aligned in memory to let functions use 8-bit maths for pointing
                             23 ;;   (alignment not working on user linking)
                             24 
   4000                      25 _cpct_keyboardStatusBuffer:: .ds 10
                             26 
                             27 ;;
                             28 ;; Assembly constant definitions for keyboard mapping
                             29 ;;
                             30 
                             31 ;; Matrix Line 0x00
                     0100    32 .equ Key_CursorUp     ,#0x0100  ;; Bit 0 (01h) => | 0000 0001 |
                     0200    33 .equ Key_CursorRight  ,#0x0200  ;; Bit 1 (02h) => | 0000 0010 |
                     0400    34 .equ Key_CursorDown   ,#0x0400  ;; Bit 2 (04h) => | 0000 0100 |
                     0800    35 .equ Key_F9           ,#0x0800  ;; Bit 3 (08h) => | 0000 1000 |
                     1000    36 .equ Key_F6           ,#0x1000  ;; Bit 4 (10h) => | 0001 0000 |
                     2000    37 .equ Key_F3           ,#0x2000  ;; Bit 5 (20h) => | 0010 0000 |
                     4000    38 .equ Key_Enter        ,#0x4000  ;; Bit 6 (40h) => | 0100 0000 |
                     8000    39 .equ Key_FDot         ,#0x8000  ;; Bit 7 (80h) => | 1000 0000 |
                             40 ;; Matrix Line 0x01
                     0101    41 .equ Key_CursorLeft   ,#0x0101
                     0201    42 .equ Key_Copy         ,#0x0201
                     0401    43 .equ Key_F7           ,#0x0401
                     0801    44 .equ Key_F8           ,#0x0801
                     1001    45 .equ Key_F5           ,#0x1001
                     2001    46 .equ Key_F1           ,#0x2001
                     4001    47 .equ Key_F2           ,#0x4001
                     8001    48 .equ Key_F0           ,#0x8001
                             49 ;; Matrix Line 0x02
                     0102    50 .equ Key_Clr          ,#0x0102
                     0202    51 .equ Key_OpenBracket  ,#0x0202
                     0402    52 .equ Key_Return       ,#0x0402
                     0802    53 .equ Key_CloseBracket ,#0x0802
                     1002    54 .equ Key_F4           ,#0x1002
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 3.
Hexadecimal [16-Bits]



                     2002    55 .equ Key_Shift        ,#0x2002
                     4002    56 .equ Key_BackSlash    ,#0x4002
                     8002    57 .equ Key_Control      ,#0x8002
                             58 ;; Matrix Line 0x03
                     0103    59 .equ Key_Caret        ,#0x0103
                     0203    60 .equ Key_Hyphen       ,#0x0203
                     0403    61 .equ Key_At           ,#0x0403
                     0803    62 .equ Key_P            ,#0x0803
                     1003    63 .equ Key_SemiColon    ,#0x1003
                     2003    64 .equ Key_Colon        ,#0x2003
                     4003    65 .equ Key_Slash        ,#0x4003
                     8003    66 .equ Key_Dot          ,#0x8003
                             67 ;; Matrix Line 0x04
                     0104    68 .equ Key_0            ,#0x0104
                     0204    69 .equ Key_9            ,#0x0204
                     0404    70 .equ Key_O            ,#0x0404
                     0804    71 .equ Key_I            ,#0x0804
                     1004    72 .equ Key_L            ,#0x1004
                     2004    73 .equ Key_K            ,#0x2004
                     4004    74 .equ Key_M            ,#0x4004
                     8004    75 .equ Key_Comma        ,#0x8004
                             76 ;; Matrix Line 0x05
                     0105    77 .equ Key_8            ,#0x0105
                     0205    78 .equ Key_7            ,#0x0205
                     0405    79 .equ Key_U            ,#0x0405
                     0805    80 .equ Key_Y            ,#0x0805
                     1005    81 .equ Key_H            ,#0x1005
                     2005    82 .equ Key_J            ,#0x2005
                     4005    83 .equ Key_N            ,#0x4005
                     8005    84 .equ Key_Space        ,#0x8005
                             85 ;; Matrix Line 0x06
                     0106    86 .equ Key_6            ,#0x0106
                     0106    87 .equ Joy1_Up          ,#0x0106
                     0206    88 .equ Key_5            ,#0x0206
                     0206    89 .equ Joy1_Down        ,#0x0206
                     0406    90 .equ Key_R            ,#0x0406
                     0406    91 .equ Joy1_Left        ,#0x0406
                     0806    92 .equ Key_T            ,#0x0806
                     0806    93 .equ Joy1_Right       ,#0x0806
                     1006    94 .equ Key_G            ,#0x1006
                     1006    95 .equ Joy1_Fire1       ,#0x1006
                     2006    96 .equ Key_F            ,#0x2006
                     2006    97 .equ Joy1_Fire2       ,#0x2006
                     4006    98 .equ Key_B            ,#0x4006
                     4006    99 .equ Joy1_Fire3       ,#0x4006
                     8006   100 .equ Key_V            ,#0x8006
                            101 ;; Matrix Line 0x07
                     0107   102 .equ Key_4            ,#0x0107
                     0207   103 .equ Key_3            ,#0x0207
                     0407   104 .equ Key_E            ,#0x0407
                     0807   105 .equ Key_W            ,#0x0807
                     1007   106 .equ Key_S            ,#0x1007
                     2007   107 .equ Key_D            ,#0x2007
                     4007   108 .equ Key_C            ,#0x4007
                     8007   109 .equ Key_X            ,#0x8007
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 4.
Hexadecimal [16-Bits]



                            110 ;; Matrix Line 0x08
                     0108   111 .equ Key_1            ,#0x0108
                     0208   112 .equ Key_2            ,#0x0208
                     0408   113 .equ Key_Esc          ,#0x0408
                     0808   114 .equ Key_Q            ,#0x0808
                     1008   115 .equ Key_Tab          ,#0x1008
                     2008   116 .equ Key_A            ,#0x2008
                     4008   117 .equ Key_CapsLock     ,#0x4008
                     8008   118 .equ Key_Z            ,#0x8008
                            119 ;; Matrix Line 0x09
                     0109   120 .equ Joy0_Up          ,#0x0109
                     0209   121 .equ Joy0_Down        ,#0x0209
                     0409   122 .equ Joy0_Left        ,#0x0409
                     0809   123 .equ Joy0_Right       ,#0x0809
                     1009   124 .equ Joy0_Fire1       ,#0x1009
                     2009   125 .equ Joy0_Fire2       ,#0x2009
                     4009   126 .equ Joy0_Fire3       ,#0x4009
                     8009   127 .equ Key_Del          ,#0x8009
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 5.
Hexadecimal [16-Bits]



                              5 .globl cpct_waitVSYNC_asm
                              6 .globl cpct_scanKeyboard_asm
                              7 .globl cpct_isKeyPressed_asm
                              8 .globl cpct_isAnyKeyPressed_asm
                              9 .globl cpct_setInterruptHandler_asm
                             10 
                     FFFD    11 .equ	ayctrl, #65533
                     BFFD    12 .equ	aydata, #49149
                             13 
                     0000    14 .equ	channel_A,	#0
                     0001    15 .equ	channel_B,	#1
                     0002    16 .equ	channel_C,	#2
                     0003    17 .equ	channel_silence,#3
                             18 
                     0006    19 .equ 	n_waits,	#6
                             20 
                     000F    21 .equ	channel_A_volume,	#15
                     000F    22 .equ	channel_B_volume,	#15
                     000F    23 .equ	channel_C_volume,	#15
                             24 
   400A 04                   25 current_octave: 	.db #4
   400B 00                   26 current_noise:		.db #0
   400C 0F                   27 current_A_volume:	.db #channel_A_volume
                             28 
                     0001    29 .equ	_C,	#1
                     0002    30 .equ	_Cs,	#2
                     0003    31 .equ	_D,	#3
                     0004    32 .equ	_Ds,	#4
                     0005    33 .equ	_E,	#5
                     0006    34 .equ	_F,	#6
                     0007    35 .equ	_Fs,	#7
                     0008    36 .equ	_G,	#8
                     0009    37 .equ	_Gs,	#9
                     000A    38 .equ	_A,	#10
                     000B    39 .equ	_As,	#11
                     000C    40 .equ	_B,	#12
                             41 
   400D                      42 tunes_table:
   400D EE 0E                43 	.dw #3822	;   C	-   1	;
   400F 18 0E                44 	.dw #3608	;   C#	-   2	;
   4011 4D 0D                45 	.dw #3405	;   D	-   3	;
   4013 8E 0C                46 	.dw #3214	;   D#	-   4	;
   4015 DA 0B                47 	.dw #3034	;   E	-   5	;
   4017 2F 0B                48 	.dw #2863	;   F	-   6	;
   4019 8F 0A                49 	.dw #2703	;   F#	-   7	;
   401B F7 09                50 	.dw #2551	;   G	-   8	;
   401D 68 09                51 	.dw #2408	;   G#	-   9	;
   401F E1 08                52 	.dw #2273	;   A	-   10	;
   4021 61 08                53 	.dw #2145	;   A#	-   11	;
   4023 E9 07                54 	.dw #2025	;   B	-   12	;
                             55 
                             56 
                             57 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             58 ;; AY-3-8910/2 registers ID table
                     0000    59 .equ A_f_pitch_reg,		#0
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                     0001    60 .equ A_c_pitch_reg,		#1
                     0002    61 .equ B_f_pitch_reg,		#2
                     0003    62 .equ B_c_pitch_reg,		#3
                     0004    63 .equ C_f_pitch_reg,		#4
                     0005    64 .equ C_c_pitch_reg,		#5
                     0006    65 .equ noise_period_reg,		#6
                     0007    66 .equ mixer_reg,			#7
                     0008    67 .equ A_volume_reg,		#8
                     0009    68 .equ B_volume_reg,		#9
                     000A    69 .equ C_volume_reg,		#10
                     000B    70 .equ f_envelope_period_reg,	#11
                     000C    71 .equ c_envelope_period_reg,	#12
                     000D    72 .equ envelope_shape_reg,	#13
                     000E    73 .equ A_in_out_reg,		#14
                     000F    74 .equ B_in_out_reg,		#15
                             75 
                     0032    76 .equ	player_period, 	#50
   4025 32                   77 player_n_interruptions: .db #player_period
                             78 
                             79 ; FIRST TEST
                             80 ; Input
                             81 ; note 3421
                             82 ; octave 4
                             83 ; 
                             84 ; Output
                             85 ; fine 213
                             86 ; course 0
                             87 ; tune playing
                             88 
                             89 ; SECOND TEST
                             90 ; Input
                             91 ; note 3421 (C)
                             92 ; octave 0-8
                             93 ;
                             94 ; Output
                             95 ; Octave:Fine - Course
                             96 ; 0:	 3421 - 13
                             97 ; 1:	 1710 - 6
                             98 ; 2:	  855 - 3
                             99 ; 3:	  427 - 1
                            100 ; 4:	  213 - 0
                            101 ; 5:	  106 - 0
                            102 ; 6:	   53 - 0
                            103 ; 7:	   26 - 0
                            104 ; 8:	   13 - 0
                            105 
                            106 
   4026                     107 _main::
   4026 CD 3F 40      [17]  108 	call initialize_player
   4029 DD 21 0A 40   [14]  109 	ld	ix, #current_octave	; IX <= octave position
   402D                     110 	loop:
                            111 
   402D C3 2D 40      [10]  112 		jp 	loop
                            113 
   4030                     114 musicHandler::
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



   4030 3A 25 40      [13]  115 	ld 	a, (player_n_interruptions)
   4033 3D            [ 4]  116 	dec 	a
   4034 20 05         [12]  117 	jr 	nz, not_play
                            118 		;; n_interruptions == 0
   4036 CD 48 41      [17]  119 		call 	play_frame
   4039 3E 32         [ 7]  120 		ld 	a, #player_period
                            121 
   403B                     122 	not_play:
   403B 32 25 40      [13]  123 		ld 	(player_n_interruptions), a
   403E C9            [10]  124 	ret
                            125 
   403F                     126 initialize_player:
   403F 3E 0F         [ 7]  127 	ld	a, #channel_A_volume
   4041 0E 08         [ 7]  128 	ld	c, #A_volume_reg
   4043 CD 80 40      [17]  129 	call 	set_AY_register
                            130 
   4046 3E 0F         [ 7]  131 	ld	a, #channel_B_volume
   4048 0E 09         [ 7]  132 	ld	c, #B_volume_reg
   404A CD 80 40      [17]  133 	call 	set_AY_register
                            134 
   404D 3E 0F         [ 7]  135 	ld	a, #channel_C_volume
   404F 0E 0A         [ 7]  136 	ld	c, #C_volume_reg
   4051 CD 80 40      [17]  137 	call 	set_AY_register
                            138 
   4054 3E 0A         [ 7]  139 	ld 	a, #10
   4056 0E 0D         [ 7]  140 	ld	c, #envelope_shape_reg
   4058 CD 80 40      [17]  141 	call 	set_AY_register
                            142 
   405B 3E 03         [ 7]  143 	ld 	a, #0x03
   405D 0E 0C         [ 7]  144 	ld	c, #c_envelope_period_reg
   405F CD 80 40      [17]  145 	call 	set_AY_register
                            146 
   4062 3E FF         [ 7]  147 	ld 	a, #0xFF
   4064 0E 0B         [ 7]  148 	ld	c, #f_envelope_period_reg
   4066 CD 80 40      [17]  149 	call 	set_AY_register
                            150 
   4069 3E 00         [ 7]  151 	ld 	a, #0
   406B 0E 06         [ 7]  152 	ld	c, #noise_period_reg
   406D CD 80 40      [17]  153 	call 	set_AY_register
                            154 
   4070 21 30 40      [10]  155 	ld 	hl, #musicHandler
   4073 CD 94 43      [17]  156 	call 	cpct_setInterruptHandler_asm
                            157 
   4076 CD D5 41      [17]  158 	call 	init_PSG_mixer
                            159 
   4079 21 E0 40      [10]  160 	ld	hl, #song_2
   407C CD 41 41      [17]  161 	call	set_song_pointer
                            162 
   407F C9            [10]  163 	ret
                            164 
                            165 
                            166 ;; A => given value to set
                            167 ;; C => register ID
                            168 ;;
                            169 ;; DESTROYS BC
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   4080                     170 set_AY_register:
   4080 06 F4         [ 7]  171 	ld 	b,#0xF4
   4082 ED 49         [12]  172 	out 	(c), c
   4084 01 C0 F6      [10]  173 	ld 	bc,#0xF6C0
   4087 ED 49         [12]  174 	out 	(c),c
   4089 ED 71               175 	.db #0xED, #0x71
                            176 
   408B 06 F4         [ 7]  177 	ld 	b,#0xF4
   408D ED 79         [12]  178 	out 	(c), a
   408F 01 80 F6      [10]  179 	ld 	bc,#0xF680
   4092 ED 49         [12]  180 	out 	(c),c
   4094 ED 71               181 	.db #0xED, #0x71
                            182 
   4096 C9            [10]  183 	ret
                            184 
                     0080   185 .equ silence_command, 	#0b10000000
                     0081   186 .equ end_song_command, 	#0b10000001
                     0082   187 .equ sustain_command, 	#0b10000010
                            188 
                            189 ;;			0	1	2	3	4	5	6	7	 8
                            190 ;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   4097 0F 01 04 00 06 04   191 song_1::	.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
        00 08 04
   40A0 0F 01 04 0C 06 04   192 		.db 	#15,	#_C,	#4,	#12,	#_F,	#4,	#0,	#_G,	#4
        00 08 04
   40A9 0F 01 04 00 06 04   193 		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#12,	#_G,	#4
        0C 08 04
                            194 		; .db 	#silence_command
   40B2 0F 06 04 00 0A 04   195 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#0,	#_C,	#5
        00 01 05
   40BB 0F 06 04 0C 0A 04   196 		.db 	#15,	#_F,	#4,	#12,	#_A,	#4,	#0,	#_C,	#5
        00 01 05
   40C4 0F 06 04 00 0A 04   197 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#12,	#_C,	#5
        0C 01 05
                            198 		; .db 	#silence_command
   40CD 0F 08 04 00 0C 04   199 		 .db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
   40D6 0F 08 04 0C 0C 04   200 		 .db 	#15,	#_G,	#4,	#12,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
                            201 		; .db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#12,	#_D,	#5
                            202 		; .db 	#silence_command
   40DF 81                  203 		.db	#end_song_command
                            204 
                            205 ;;			0	1	2	3	4	5	6	7	 8
                            206 ;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   40E0 0F 01 03 00 06 04   207 song_2::	.db 	#15,	#_C,	#3,	#0,	#_F,	#4,	#0,	#_G,	#4
        00 08 04
   40E9 82                  208 		.db	#sustain_command
   40EA 80                  209 		.db	#silence_command
   40EB 80                  210 		.db 	#silence_command
   40EC 0F 01 04 00 06 04   211 		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
        00 08 04
   40F5 82                  212 		.db	#sustain_command
   40F6 82                  213 		.db	#sustain_command
   40F7 0F 08 03 00 0C 04   214 		.db 	#15,	#_G,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



        00 03 05
   4100 0F 01 03 00 0C 04   215 		.db 	#15,	#_C,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
   4109 82                  216 		.db	#sustain_command
   410A 80                  217 		.db	#silence_command
   410B 80                  218 		.db 	#silence_command
   410C 0F 08 02 00 0C 04   219 		.db 	#15,	#_G,	#2,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
   4115 82                  220 		.db	#sustain_command
   4116 80                  221 		.db	#silence_command
   4117 80                  222 		.db 	#silence_command
   4118 0F 0B 02 00 0C 04   223 		.db 	#15,	#_As,	#2,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
   4121 82                  224 		.db	#sustain_command
   4122 80                  225 		.db	#silence_command
   4123 80                  226 		.db 	#silence_command
   4124 0F 01 03 00 0C 04   227 		.db 	#15,	#_C,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
   412D 82                  228 		.db	#sustain_command
   412E 80                  229 		.db	#silence_command
   412F 80                  230 		.db 	#silence_command
   4130 0F 04 03 00 0C 04   231 		.db 	#15,	#_Ds,	#3,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 03 05
   4139 82                  232 		.db	#sustain_command
   413A 82                  233 		.db	#sustain_command
   413B 82                  234 		.db	#sustain_command
   413C 81                  235 		.db	#end_song_command
                            236 
   413D 00 00               237 current_song_init_pointer: 	.dw #0
   413F 00 00               238 current_song_pointer: 		.dw #0
                            239 
                            240 ;; HL => song pointer
   4141                     241 set_song_pointer:
   4141 22 3D 41      [16]  242 	ld	(current_song_init_pointer), hl
   4144 22 3F 41      [16]  243 	ld	(current_song_pointer), hl
   4147 C9            [10]  244 	ret
                            245 
   4148                     246 play_frame::
   4148 2A 3F 41      [16]  247 	ld	hl, (current_song_pointer)
                            248 
   414B 7E            [ 7]  249 	ld	a, (hl)
   414C FE 80         [ 7]  250 	cp 	#silence_command
   414E 28 22         [12]  251 	jr	z, play_silence
                            252 
   4150 FE 81         [ 7]  253 		cp 	#end_song_command
   4152 28 27         [12]  254 		jr	z, play_end
   4154 FE 82         [ 7]  255 			cp 	#sustain_command
   4156 28 20         [12]  256 			jr	z, play_sustain
   4158 CD D5 41      [17]  257 				call 	init_PSG_mixer
                            258 				;; play A tune
   415B 0E 08         [ 7]  259 				ld	c, #A_volume_reg	; C <= A volume register ID
   415D 16 00         [ 7]  260 				ld	d, #channel_A		; D <= channel A ID
   415F CD 88 41      [17]  261 				call	play_frame_tune
                            262 
                            263 				;; play B tune
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



   4162 0E 09         [ 7]  264 				ld	c, #B_volume_reg	; C <= B volume register ID
   4164 16 01         [ 7]  265 				ld	d, #channel_B		; D <= channel B ID
   4166 CD 88 41      [17]  266 				call	play_frame_tune
                            267 
                            268 				;; play C tune
   4169 0E 0A         [ 7]  269 				ld	c, #C_volume_reg	; C <= C volume register ID
   416B 16 02         [ 7]  270 				ld	d, #channel_C		; D <= channel C ID
   416D CD 88 41      [17]  271 				call	play_frame_tune
                            272 
   4170 18 12         [12]  273 				jr	exit_play_frame
                            274 
   4172                     275 			play_silence:
   4172 CD CD 41      [17]  276 				call 	silence_PSG_mixer
   4175 23            [ 6]  277 				inc 	hl
   4176 18 0C         [12]  278 				jr	exit_play_frame
                            279 
   4178                     280 			play_sustain:
   4178 23            [ 6]  281 				inc 	hl
   4179 18 09         [12]  282 				jr	exit_play_frame
                            283 
   417B                     284 			play_end:
   417B 2A 3D 41      [16]  285 				ld 	hl, (current_song_init_pointer)
   417E 22 3F 41      [16]  286 				ld	(current_song_pointer), hl
   4181 CD 48 41      [17]  287 				call 	play_frame
                            288 				;ret
                            289 
   4184                     290 	exit_play_frame:
                            291 
   4184 22 3F 41      [16]  292 	ld	(current_song_pointer), hl
                            293 
   4187 C9            [10]  294 	ret
                            295 
                            296 ;; C => AY register ID
                            297 ;; D => channel ID
                            298 ;;
                            299 ;; HL keeps updated here
                            300 ;; DESTROYS: AF, BC, DE, HL
   4188                     301 play_frame_tune::
   4188 7E            [ 7]  302 	ld	a, (hl)			; read value 
   4189 CD 80 40      [17]  303 	call	set_AY_register		; set C AY register
   418C 23            [ 6]  304 	inc 	hl
                            305 
   418D 7A            [ 4]  306 	ld	a, d		; A <= channel ID
   418E 46            [ 7]  307 	ld	b, (hl)		; B <= tune ID
   418F 23            [ 6]  308 	inc 	hl		;
   4190 4E            [ 7]  309 	ld 	c, (hl)		; C <= octave
   4191 23            [ 6]  310 	inc 	hl
                            311 
   4192 E5            [11]  312 	push	hl
   4193 CD 98 41      [17]  313 	call	play_note
   4196 E1            [10]  314 	pop 	hl
                            315 
   4197 C9            [10]  316 	ret
                            317 
                            318 ;; A => channel ID
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



                            319 ;; B => tune ID
                            320 ;; C => octave
                            321 ;;
                            322 ;; DESTROYS: AF, BC, HL
   4198                     323 play_note::
   4198 FE 00         [ 7]  324 	cp #channel_A
   419A 20 08         [12]  325 	jr nz, is_channel_B
                            326 		; CHANNEL A
   419C 1E 00         [ 7]  327 		ld	e, #A_f_pitch_reg
   419E 16 01         [ 7]  328 		ld	d, #A_c_pitch_reg
   41A0 CD BD 41      [17]  329 		call	player_note_channel
                            330 
   41A3 C9            [10]  331 		ret
   41A4                     332 	is_channel_B:
   41A4 FE 01         [ 7]  333 		cp #channel_B
   41A6 20 08         [12]  334 		jr nz, is_channel_C
                            335 			; CHANNEL B
   41A8 1E 02         [ 7]  336 			ld	e, #B_f_pitch_reg
   41AA 16 03         [ 7]  337 			ld	d, #B_c_pitch_reg
   41AC CD BD 41      [17]  338 			call	player_note_channel
                            339 
   41AF C9            [10]  340 			ret
   41B0                     341 	is_channel_C:
   41B0 FE 02         [ 7]  342 		cp #channel_C
   41B2 20 08         [12]  343 		jr nz, exit_channel_selection
                            344 			; CHANNEL C
   41B4 1E 04         [ 7]  345 			ld	e, #C_f_pitch_reg
   41B6 16 05         [ 7]  346 			ld	d, #C_c_pitch_reg
   41B8 CD BD 41      [17]  347 			call	player_note_channel
                            348 
   41BB C9            [10]  349 			ret
                            350 
   41BC                     351 	exit_channel_selection:
   41BC C9            [10]  352 	ret
                            353 
                            354 ;; B => tune ID
                            355 ;; C => octave
                            356 ;; D => coarse pitch register ID
                            357 ;; E => fine pitch register ID
   41BD                     358 player_note_channel::
   41BD D5            [11]  359 	push 	de
   41BE CD DD 41      [17]  360 	call	get_fine_pitch	; HL <= fine pitch value
   41C1 D1            [10]  361 	pop	de
                            362 
   41C2 7D            [ 4]  363 	ld	a, l
   41C3 4B            [ 4]  364 	ld	c, e		; C <= fine pitch register ID
   41C4 CD 80 40      [17]  365 	call	set_AY_register
                            366 
   41C7 7C            [ 4]  367 	ld	a, h		; A <= course pitch value (HL/256)
   41C8 4A            [ 4]  368 	ld	c, d		; C <= coarse pitch register ID
   41C9 CD 80 40      [17]  369 	call	set_AY_register
   41CC C9            [10]  370 	ret
                            371 
   41CD                     372 silence_PSG_mixer:
   41CD 3E 3F         [ 7]  373 	ld 	a, #0b00111111
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 12.
Hexadecimal [16-Bits]



   41CF 0E 07         [ 7]  374 	ld	c, #mixer_reg
   41D1 CD 80 40      [17]  375 	call	set_AY_register
   41D4 C9            [10]  376 	ret
                            377 
   41D5                     378 init_PSG_mixer:
   41D5 3E 38         [ 7]  379 	ld	a, #0b00111000
   41D7 0E 07         [ 7]  380 	ld	c, #mixer_reg
   41D9 CD 80 40      [17]  381 	call	set_AY_register
   41DC C9            [10]  382 	ret
                            383 
                            384 ;; B => tune ID
                            385 ;; C => octave
                            386 ;; 
                            387 ;; HL <= fine pitch value
                            388 ;; DESTROYS: AF, BC, DE
   41DD                     389 get_fine_pitch::
   41DD 78            [ 4]  390 	ld	a, b		; A <= tune ID
   41DE CD F0 41      [17]  391 	call 	get_tune	; HL <= tune value
                            392 
   41E1 79            [ 4]  393 	ld	a, c
   41E2 FE 00         [ 7]  394 	cp	#0
   41E4 20 02         [12]  395 	jr	nz, octaves_loop
                            396 		; octave is 0
   41E6 7C            [ 4]  397 		ld	a, h	; A <= tune value integer part
   41E7 C9            [10]  398 		ret
   41E8                     399 	octaves_loop:
   41E8 CB 3C         [ 8]  400 		srl 	h			;
   41EA CB 1D         [ 8]  401 		rr 	l			; HL/2
   41EC 0D            [ 4]  402 		dec 	c
   41ED 20 F9         [12]  403 		jr	nz, octaves_loop	; EXIT IF C-- == ZERO
   41EF C9            [10]  404 	ret
                            405 
                            406 ;; A => tune ID
                            407 ;; HL <= tune value
                            408 ;;
                            409 ;; DESTROYS AF, DE, HL
   41F0                     410 get_tune:
   41F0 21 0D 40      [10]  411 	ld	hl, #tunes_table	; HL <= Tunes vector address
   41F3 11 00 00      [10]  412 	ld	de, #0			;
   41F6 5F            [ 4]  413 	ld	e, a			; DE <= A
   41F7 19            [11]  414 	add 	hl, de			;
   41F8 19            [11]  415 	add 	hl, de			; HL <= vector adress + tuneIDx2
                            416 
   41F9 5E            [ 7]  417 	ld	e, (hl)			; 
   41FA 2C            [ 4]  418 	inc 	l			; 
   41FB 56            [ 7]  419 	ld	d, (hl)			; DE <= tune value
                            420 
   41FC EB            [ 4]  421 	ex 	de, hl 			; HL <= tune value
                            422 
   41FD C9            [10]  423 	ret
                            424 
   41FE                     425 check_input::
   41FE CD DE 43      [17]  426 	call 	cpct_scanKeyboard_asm
                            427 
   4201 CD C8 43      [17]  428 	call 	cpct_isAnyKeyPressed_asm
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 13.
Hexadecimal [16-Bits]



   4204 FE 00         [ 7]  429 	cp 	#0
   4206 CA 6B 43      [10]  430 	jp	z, none_key_pressed
                            431 		;; any key is pressed
   4209 CD D5 41      [17]  432 		call init_PSG_mixer
   420C 21 08 80      [10]  433 		ld 	hl, #Key_Z			;; HL = Keycode
   420F CD BC 43      [17]  434 		call 	cpct_isKeyPressed_asm 		;; A = True/False
   4212 FE 00         [ 7]  435 		cp 	#0 				;; A == 0?
   4214 28 0B         [12]  436 		jr 	z, z_not_pressed
   4216 3A 0A 40      [13]  437 			ld	a, (current_octave)
   4219 4F            [ 4]  438 			ld	c, a
   421A 3E 00         [ 7]  439 			ld	a, #channel_A
   421C 06 01         [ 7]  440 			ld	b, # _C
   421E CD 98 41      [17]  441 			call 	play_note
   4221                     442 		z_not_pressed:
   4221 21 07 10      [10]  443 			ld 	hl, #Key_S			;; HL = Keycode
   4224 CD BC 43      [17]  444 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4227 FE 00         [ 7]  445 			cp 	#0 				;; A == 0?
   4229 28 0B         [12]  446 			jr 	z, s_not_pressed
   422B 3A 0A 40      [13]  447 				ld	a, (current_octave)
   422E 4F            [ 4]  448 				ld	c, a
   422F 3E 00         [ 7]  449 				ld	a, #channel_A
   4231 06 02         [ 7]  450 				ld	b, # _Cs
   4233 CD 98 41      [17]  451 				call 	play_note
   4236                     452 		s_not_pressed:
   4236 21 07 80      [10]  453 			ld 	hl, #Key_X			;; HL = Keycode
   4239 CD BC 43      [17]  454 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   423C FE 00         [ 7]  455 			cp 	#0 				;; A == 0?
   423E 28 0B         [12]  456 			jr 	z, x_not_pressed
   4240 3A 0A 40      [13]  457 				ld	a, (current_octave)
   4243 4F            [ 4]  458 				ld	c, a
   4244 3E 00         [ 7]  459 				ld	a, #channel_A
   4246 06 03         [ 7]  460 				ld	b, # _D
   4248 CD 98 41      [17]  461 				call 	play_note
   424B                     462 		x_not_pressed:
   424B 21 07 20      [10]  463 			ld 	hl, #Key_D			;; HL = Keycode
   424E CD BC 43      [17]  464 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4251 FE 00         [ 7]  465 			cp 	#0 				;; A == 0?
   4253 28 0B         [12]  466 			jr 	z, d_not_pressed
   4255 3A 0A 40      [13]  467 				ld	a, (current_octave)
   4258 4F            [ 4]  468 				ld	c, a
   4259 3E 00         [ 7]  469 				ld	a, #channel_A
   425B 06 04         [ 7]  470 				ld	b, # _Ds
   425D CD 98 41      [17]  471 				call 	play_note
   4260                     472 		d_not_pressed:
   4260 21 07 40      [10]  473 			ld 	hl, #Key_C			;; HL = Keycode
   4263 CD BC 43      [17]  474 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4266 FE 00         [ 7]  475 			cp 	#0 				;; A == 0?
   4268 28 0B         [12]  476 			jr 	z, c_not_pressed
   426A 3A 0A 40      [13]  477 				ld	a, (current_octave)
   426D 4F            [ 4]  478 				ld	c, a
   426E 3E 00         [ 7]  479 				ld	a, #channel_A
   4270 06 05         [ 7]  480 				ld	b, # _E
   4272 CD 98 41      [17]  481 				call 	play_note
   4275                     482 		c_not_pressed:
   4275 21 06 80      [10]  483 			ld 	hl, #Key_V			;; HL = Keycode
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 14.
Hexadecimal [16-Bits]



   4278 CD BC 43      [17]  484 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   427B FE 00         [ 7]  485 			cp 	#0 				;; A == 0?
   427D 28 0B         [12]  486 			jr 	z, v_not_pressed
   427F 3A 0A 40      [13]  487 				ld	a, (current_octave)
   4282 4F            [ 4]  488 				ld	c, a
   4283 3E 00         [ 7]  489 				ld	a, #channel_A
   4285 06 06         [ 7]  490 				ld	b, # _F
   4287 CD 98 41      [17]  491 				call 	play_note
   428A                     492 		v_not_pressed:
   428A 21 06 10      [10]  493 			ld 	hl, #Key_G			;; HL = Keycode
   428D CD BC 43      [17]  494 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4290 FE 00         [ 7]  495 			cp 	#0 				;; A == 0?
   4292 28 0B         [12]  496 			jr 	z, g_not_pressed
   4294 3A 0A 40      [13]  497 				ld	a, (current_octave)
   4297 4F            [ 4]  498 				ld	c, a
   4298 3E 00         [ 7]  499 				ld	a, #channel_A
   429A 06 07         [ 7]  500 				ld	b, # _Fs
   429C CD 98 41      [17]  501 				call 	play_note
   429F                     502 		g_not_pressed:
   429F 21 06 40      [10]  503 			ld 	hl, #Key_B			;; HL = Keycode
   42A2 CD BC 43      [17]  504 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   42A5 FE 00         [ 7]  505 			cp 	#0 				;; A == 0?
   42A7 28 0B         [12]  506 			jr 	z, b_not_pressed
   42A9 3A 0A 40      [13]  507 				ld	a, (current_octave)
   42AC 4F            [ 4]  508 				ld	c, a
   42AD 3E 00         [ 7]  509 				ld	a, #channel_A
   42AF 06 08         [ 7]  510 				ld	b, # _G
   42B1 CD 98 41      [17]  511 				call 	play_note
   42B4                     512 		b_not_pressed:
   42B4 21 05 10      [10]  513 			ld 	hl, #Key_H			;; HL = Keycode
   42B7 CD BC 43      [17]  514 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   42BA FE 00         [ 7]  515 			cp 	#0 				;; A == 0?
   42BC 28 0B         [12]  516 			jr 	z, h_not_pressed
   42BE 3A 0A 40      [13]  517 				ld	a, (current_octave)
   42C1 4F            [ 4]  518 				ld	c, a
   42C2 3E 00         [ 7]  519 				ld	a, #channel_A
   42C4 06 09         [ 7]  520 				ld	b, # _Gs
   42C6 CD 98 41      [17]  521 				call 	play_note
   42C9                     522 		h_not_pressed:
   42C9 21 05 40      [10]  523 			ld 	hl, #Key_N			;; HL = Keycode
   42CC CD BC 43      [17]  524 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   42CF FE 00         [ 7]  525 			cp 	#0 				;; A == 0?
   42D1 28 0B         [12]  526 			jr 	z, n_not_pressed
   42D3 3A 0A 40      [13]  527 				ld	a, (current_octave)
   42D6 4F            [ 4]  528 				ld	c, a
   42D7 3E 00         [ 7]  529 				ld	a, #channel_A
   42D9 06 0A         [ 7]  530 				ld	b, # _A
   42DB CD 98 41      [17]  531 				call 	play_note
   42DE                     532 		n_not_pressed:
   42DE 21 05 20      [10]  533 			ld 	hl, #Key_J			;; HL = Keycode
   42E1 CD BC 43      [17]  534 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   42E4 FE 00         [ 7]  535 			cp 	#0 				;; A == 0?
   42E6 28 0B         [12]  536 			jr 	z, j_not_pressed
   42E8 3A 0A 40      [13]  537 				ld	a, (current_octave)
   42EB 4F            [ 4]  538 				ld	c, a
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 15.
Hexadecimal [16-Bits]



   42EC 3E 00         [ 7]  539 				ld	a, #channel_A
   42EE 06 0B         [ 7]  540 				ld	b, # _As
   42F0 CD 98 41      [17]  541 				call 	play_note
   42F3                     542 		j_not_pressed:
   42F3 21 04 40      [10]  543 			ld 	hl, #Key_M			;; HL = Keycode
   42F6 CD BC 43      [17]  544 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   42F9 FE 00         [ 7]  545 			cp 	#0 				;; A == 0?
   42FB 28 0B         [12]  546 			jr 	z, m_not_pressed
   42FD 3A 0A 40      [13]  547 				ld	a, (current_octave)
   4300 4F            [ 4]  548 				ld	c, a
   4301 3E 00         [ 7]  549 				ld	a, #channel_A
   4303 06 0C         [ 7]  550 				ld	b, # _B
   4305 CD 98 41      [17]  551 				call 	play_note
   4308                     552 		m_not_pressed:
   4308 21 04 80      [10]  553 			ld 	hl, #Key_Comma			;; HL = Keycode
   430B CD BC 43      [17]  554 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   430E FE 00         [ 7]  555 			cp 	#0 				;; A == 0?
   4310 28 0C         [12]  556 			jr 	z, comma_not_pressed
   4312 3A 0A 40      [13]  557 				ld	a, (current_octave)
   4315 3C            [ 4]  558 				inc 	a
   4316 4F            [ 4]  559 				ld	c, a
   4317 3E 00         [ 7]  560 				ld	a, #channel_A
   4319 06 01         [ 7]  561 				ld	b, # _C
   431B CD 98 41      [17]  562 				call 	play_note
   431E                     563 		comma_not_pressed:
   431E 21 04 10      [10]  564 			ld 	hl, #Key_L			;; HL = Keycode
   4321 CD BC 43      [17]  565 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4324 FE 00         [ 7]  566 			cp 	#0 				;; A == 0?
   4326 28 0C         [12]  567 			jr 	z, l_not_pressed
   4328 3A 0A 40      [13]  568 				ld	a, (current_octave)
   432B 3C            [ 4]  569 				inc 	a
   432C 4F            [ 4]  570 				ld	c, a
   432D 3E 00         [ 7]  571 				ld	a, #channel_A
   432F 06 02         [ 7]  572 				ld	b, # _Cs
   4331 CD 98 41      [17]  573 				call 	play_note
   4334                     574 		l_not_pressed:
   4334 21 03 80      [10]  575 			ld 	hl, #Key_Dot			;; HL = Keycode
   4337 CD BC 43      [17]  576 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   433A FE 00         [ 7]  577 			cp 	#0 				;; A == 0?
   433C 28 0C         [12]  578 			jr 	z, dot_not_pressed
   433E 3A 0A 40      [13]  579 				ld	a, (current_octave)
   4341 3C            [ 4]  580 				inc 	a
   4342 4F            [ 4]  581 				ld	c, a
   4343 3E 00         [ 7]  582 				ld	a, #channel_A
   4345 06 03         [ 7]  583 				ld	b, # _D
   4347 CD 98 41      [17]  584 				call 	play_note
                            585 
   434A                     586 		dot_not_pressed:
   434A 21 00 01      [10]  587 			ld 	hl, #Key_CursorUp		;; HL = Keycode
   434D CD BC 43      [17]  588 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4350 FE 00         [ 7]  589 			cp 	#0 				;; A == 0?
   4352 28 06         [12]  590 			jr 	z, plus_not_pressed
   4354 CD CD 41      [17]  591 				call silence_PSG_mixer
   4357 CD 70 43      [17]  592 				call 	inc_current_octave
                            593 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 16.
Hexadecimal [16-Bits]



   435A                     594 		plus_not_pressed:
   435A 21 00 04      [10]  595 			ld 	hl, #Key_CursorDown		;; HL = Keycode
   435D CD BC 43      [17]  596 			call 	cpct_isKeyPressed_asm 		;; A = True/False
   4360 FE 00         [ 7]  597 			cp 	#0 				;; A == 0?
   4362 28 06         [12]  598 			jr 	z, minus_not_pressed
   4364 CD CD 41      [17]  599 				call 	silence_PSG_mixer
   4367 CD 82 43      [17]  600 				call 	dec_current_octave
                            601 
   436A                     602 		minus_not_pressed:
                            603 
   436A C9            [10]  604 	ret
   436B                     605 	none_key_pressed:
                            606 		; silence
   436B CD CD 41      [17]  607 		call silence_PSG_mixer
   436E C9            [10]  608 	ret
                            609 
                            610 ; 0-9
                     0000   611 .equ octave_lower_limit, 	#0
                     0020   612 .equ octave_upper_limit, 	#32
                            613 
                            614 
   436F                     615 set_current_octave:
                            616 
   436F C9            [10]  617 	ret
                            618 
   4370                     619 inc_current_octave:
   4370 3A 0A 40      [13]  620 	ld	a, (current_octave)
   4373 FE 20         [ 7]  621 	cp	#octave_upper_limit
   4375 28 05         [12]  622 	jr	z, inc_limit_exceed
   4377 3C            [ 4]  623 		inc	a
   4378 32 0A 40      [13]  624 		ld	(current_octave), a
   437B C9            [10]  625 		ret
   437C                     626 	inc_limit_exceed:
   437C 3E 20         [ 7]  627 		ld	a, #octave_upper_limit
   437E 32 0A 40      [13]  628 		ld	(current_octave), a
   4381 C9            [10]  629 	ret
                            630 
   4382                     631 dec_current_octave:
   4382 3A 0A 40      [13]  632 	ld	a, (current_octave)
   4385 FE 00         [ 7]  633 	cp	#octave_lower_limit
   4387 28 05         [12]  634 	jr	z, dec_limit_exceed
   4389 3D            [ 4]  635 		dec	a
   438A 32 0A 40      [13]  636 		ld	(current_octave), a
   438D C9            [10]  637 		ret
   438E                     638 	dec_limit_exceed:
   438E 3E 00         [ 7]  639 		ld	a, #octave_lower_limit
   4390 32 0A 40      [13]  640 		ld	(current_octave), a
   4393 C9            [10]  641 	ret
                            642 
                            643 
                            644 ; doc : https://github.com/AugustoRuiz/WYZTracker/blob/master/AsmPlayer/WYZPROPLAY47c_CPC.ASM
                            645 ; doc : http://www.cpcwiki.eu/imgs/d/dc/Ay3-891x.pdf
                            646 ; Link: http://www.sinclair.hu/hardver/otletek/ay_doc/AY-3-8912.htm
                            647 ; Link: http://cpctech.cpc-live.com/docs/psg.html
                            648 ; http://www.cpcmania.com/Docs/Manuals/Manual%20de%20Usuario%20Amstrad%20CPC%20464.pdf
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 17.
Hexadecimal [16-Bits]



                            649 ; http://www.z80.info/zip/z80cpu_um.pdf#G10.1000022639
                            650 ; http://www.next.gr/uploads/63/circuit.diagram.cpc464.png
                            651 
                            652 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            653 ;; 		AY-3-8910 REGISTERS
                            654 ;;
                            655 ;; 	0	Channel A fine pitch	8-bit (0-255)
                            656 ;; 	1	Channel A course pitch	4-bit (0-15)
                            657 ;; 	2	Channel B fine pitch	8-bit (0-255)
                            658 ;; 	3	Channel B course pitch	4-bit (0-15)
                            659 ;; 	4	Channel C fine pitch	8-bit (0-255)
                            660 ;; 	5	Channel C course pitch	4-bit (0-15)
                            661 ;; 	6	Noise pitch	5-bit (0-31)
                            662 ;; 	7	Mixer	8-bit (see below)
                            663 ;; 	8	Channel A volume	4-bit (0-15, see below)
                            664 ;; 	9	Channel B volume	4-bit (0-15, see below)
                            665 ;; 	10	Channel C volume	4-bit (0-15, see below)
                            666 ;; 	11	Envelope fine duration	8-bit (0-255)
                            667 ;; 	12	Envelope course duration	8-bit (0-255)
                            668 ;; 	13	Envelope shape	4-bit (0-15)
                            669 ;; 	14	I/O port A	8-bit (0-255)
                            670 ;; 	15	I/O port B	8-bit (0-255)
                            671 
                            672 
                            673 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            674 ;; 				MIXER
                            675 ;; Bit: 7 	6 	5 	4 	3 	2 	1 	0
                            676 ;; 	I/O 	I/O 	Noise 	Noise 	Noise 	Tone 	Tone 	Tone
                            677 ;; 	B 	A 	C 	B 	A 	C 	B 	A
                            678 ;; The AY-3-8912 ignores bit 7 of this register.
                            679 
                            680 
                            681 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            682 ;;			ENVELOPES
                            683 ;;
                            684 ;; Select with register 13
                            685 ;; 0	\_________	single decay then off
                            686 ;; 1	/	single attack then hold
                            687 ;; 4	/|_________	single attack then off
                            688 ;; 8	\|\|\|\|\|\|\|\|\|\|\|\	repeated decay
                            689 ;; 9	\_________	single decay then off
                            690 ;; 10	\/\/\/\/\/\/\/\/\/\	repeated decay-attack
                            691 ;; 11	\| 	single decay then hold
                            692 ;; 12	/|/|/|/|/|/|/|/|/|/|/|/	repeated attack
                            693 ;; 14	/\/\/\/\/\/\/\/\/\/	repeated attack-decay
                            694 ;; 15	/|_________	single attack then off
                            695 
                            696 
                            697 
                            698 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            699 ;;		PITCH
                            700 ;;
                            701 ;;	fine 	= value/2^octave
                            702 ;;	course	= fine/256
                            703 ;;	
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 18.
Hexadecimal [16-Bits]



                            704 ;;	Note 	Frequency (Hz) 	
                            705 ;;	A 	220
                            706 ;;	A# 	233.3
                            707 ;;	B 	246.94
                            708 ;;	C	261.63 	
                            709 ;;	C# 	277.2
                            710 ;;	D 	293.66
                            711 ;;	D# 	311.1
                            712 ;;	E 	329.63
                            713 ;;	F 	349.23
                            714 ;;	F# 	370
                            715 ;;	G 	392
                            716 ;;	G# 	415.3
                            717 ;;	
                            718 ;;	Note	Value
                            719 ;;	C	3421
                            720 ;;	C#	3228
                            721 ;;	D	3047
                            722 ;;	D#	2876
                            723 ;;	E	2715
                            724 ;;	F	2562
                            725 ;;	F#	2419
                            726 ;;	G	2283
                            727 ;;	G#	2155
                            728 ;;	A	2034
                            729 ;;	A#	1920
                            730 ;;	B	1892
