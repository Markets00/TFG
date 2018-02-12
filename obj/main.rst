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
                             27 
                     0000    28 .equ	_C,	#0
                     0001    29 .equ	_Cs,	#1
                     0002    30 .equ	_D,	#2
                     0003    31 .equ	_Ds,	#3
                     0004    32 .equ	_E,	#4
                     0005    33 .equ	_F,	#5
                     0006    34 .equ	_Fs,	#6
                     0007    35 .equ	_G,	#7
                     0008    36 .equ	_Gs,	#8
                     0009    37 .equ	_A,	#9
                     000A    38 .equ	_As,	#10
                     000B    39 .equ	_B,	#11
                             40 
   400C                      41 tunes_table::
   400C EE 0E                42 	.dw #3822	;   C	-   0	;
   400E 18 0E                43 	.dw #3608	;   C#	-   1	;
   4010 4D 0D                44 	.dw #3405	;   D	-   2	;
   4012 8E 0C                45 	.dw #3214	;   D#	-   3	;
   4014 DA 0B                46 	.dw #3034	;   E	-   4	;
   4016 2F 0B                47 	.dw #2863	;   F	-   5	;
   4018 8F 0A                48 	.dw #2703	;   F#	-   6	;
   401A F7 09                49 	.dw #2551	;   G	-   7	;
   401C 68 09                50 	.dw #2408	;   G#	-   8	;
   401E E1 08                51 	.dw #2273	;   A	-   9	;
   4020 61 08                52 	.dw #2145	;   A#	-   10	;
   4022 E9 07                53 	.dw #2025	;   B	-   11	;
                             54 
                             55 
                             56 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             57 ;; AY-3-8910/2 registers ID table
                     0000    58 .equ A_f_pitch_reg,		#0
                     0001    59 .equ A_c_pitch_reg,		#1
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                     0002    60 .equ B_f_pitch_reg,		#2
                     0003    61 .equ B_c_pitch_reg,		#3
                     0004    62 .equ C_f_pitch_reg,		#4
                     0005    63 .equ C_c_pitch_reg,		#5
                     0006    64 .equ noise_period_reg,		#6
                     0007    65 .equ mixer_reg,			#7
                     0008    66 .equ A_volume_reg,		#8
                     0009    67 .equ B_volume_reg,		#9
                     000A    68 .equ C_volume_reg,		#10
                     000B    69 .equ f_envelope_period_reg,	#11
                     000C    70 .equ c_envelope_period_reg,	#12
                     000D    71 .equ envelope_shape_reg,	#13
                     000E    72 .equ A_in_out_reg,		#14
                     000F    73 .equ B_in_out_reg,		#15
                             74 
                     0028    75 .equ	player_period, 	#40
   4024 28                   76 player_n_interruptions: .db #player_period
                             77 
                             78 
   4025 38                   79 mixer_config:	.db #0b00111000
                             80 
                             81 ; FIRST TEST
                             82 ; Input
                             83 ; note 3421
                             84 ; octave 4
                             85 ; 
                             86 ; Output
                             87 ; fine 213
                             88 ; course 0
                             89 ; tune playing
                             90 
                             91 ; SECOND TEST
                             92 ; Input
                             93 ; note 3421 (C)
                             94 ; octave 0-8
                             95 ;
                             96 ; Output
                             97 ; Octave:Fine - Course
                             98 ; 0:	 3421 - 13
                             99 ; 1:	 1710 - 6
                            100 ; 2:	  855 - 3
                            101 ; 3:	  427 - 1
                            102 ; 4:	  213 - 0
                            103 ; 5:	  106 - 0
                            104 ; 6:	   53 - 0
                            105 ; 7:	   26 - 0
                            106 ; 8:	   13 - 0
                            107 
                            108 
   4026                     109 _main::
   4026 CD 3F 40      [17]  110 	call initialize_player
   4029 DD 21 0A 40   [14]  111 	ld	ix, #current_octave	; IX <= octave position
   402D                     112 	loop:
                            113 
   402D C3 2D 40      [10]  114 		jp 	loop
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                            115 
   4030                     116 musicHandler::
   4030 3A 24 40      [13]  117 	ld 	a, (player_n_interruptions)
   4033 3D            [ 4]  118 	dec 	a
   4034 20 05         [12]  119 	jr 	nz, not_play
                            120 		;; n_interruptions == 0
   4036 CD 72 41      [17]  121 		call 	play_frame
   4039 3E 28         [ 7]  122 		ld 	a, #player_period
                            123 
   403B                     124 	not_play:
   403B 32 24 40      [13]  125 		ld 	(player_n_interruptions), a
   403E C9            [10]  126 	ret
                            127 
   403F                     128 initialize_player:
   403F 3E 0F         [ 7]  129 	ld	a, #channel_A_volume
   4041 0E 08         [ 7]  130 	ld	c, #A_volume_reg
   4043 CD 80 40      [17]  131 	call 	set_AY_register
                            132 
   4046 3E 0F         [ 7]  133 	ld	a, #channel_B_volume
   4048 0E 09         [ 7]  134 	ld	c, #B_volume_reg
   404A CD 80 40      [17]  135 	call 	set_AY_register
                            136 
   404D 3E 0F         [ 7]  137 	ld	a, #channel_C_volume
   404F 0E 0A         [ 7]  138 	ld	c, #C_volume_reg
   4051 CD 80 40      [17]  139 	call 	set_AY_register
                            140 
   4054 3E 0A         [ 7]  141 	ld 	a, #10
   4056 0E 0D         [ 7]  142 	ld	c, #envelope_shape_reg
   4058 CD 80 40      [17]  143 	call 	set_AY_register
                            144 
   405B 3E 03         [ 7]  145 	ld 	a, #0x03
   405D 0E 0C         [ 7]  146 	ld	c, #c_envelope_period_reg
   405F CD 80 40      [17]  147 	call 	set_AY_register
                            148 
   4062 3E FF         [ 7]  149 	ld 	a, #0xFF
   4064 0E 0B         [ 7]  150 	ld	c, #f_envelope_period_reg
   4066 CD 80 40      [17]  151 	call 	set_AY_register
                            152 
   4069 3E 00         [ 7]  153 	ld 	a, #0
   406B 0E 06         [ 7]  154 	ld	c, #noise_period_reg
   406D CD 80 40      [17]  155 	call 	set_AY_register
                            156 
   4070 21 30 40      [10]  157 	ld 	hl, #musicHandler
   4073 CD BA 42      [17]  158 	call 	cpct_setInterruptHandler_asm
                            159 
   4076 CD 90 42      [17]  160 	call 	update_PSG_mixer
                            161 
   4079 21 EC 40      [10]  162 	ld	hl, #song_2
   407C CD 6B 41      [17]  163 	call	set_song_pointer
                            164 
   407F C9            [10]  165 	ret
                            166 
                            167 
                            168 ;; A => given value to set
                            169 ;; C => register ID
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



                            170 ;;
                            171 ;; DESTROYS BC
   4080                     172 set_AY_register:
   4080 06 F4         [ 7]  173 	ld 	b,#0xF4
   4082 ED 49         [12]  174 	out 	(c), c
   4084 01 C0 F6      [10]  175 	ld 	bc,#0xF6C0
   4087 ED 49         [12]  176 	out 	(c),c
   4089 ED 71               177 	.db #0xED, #0x71
                            178 
   408B 06 F4         [ 7]  179 	ld 	b,#0xF4
   408D ED 79         [12]  180 	out 	(c), a
   408F 01 80 F6      [10]  181 	ld 	bc,#0xF680
   4092 ED 49         [12]  182 	out 	(c),c
   4094 ED 71               183 	.db #0xED, #0x71
                            184 
   4096 C9            [10]  185 	ret
                            186 
                            187 ;;			0	1	2	3	4	5	6	7	 8
                            188 ;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   4097                     189 song_1::
   4097 0F 00 04 00 05 04   190 		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
        00 07 04
   40A0 0F 00 04 0C 05 04   191 		.db 	#15,	#_C,	#4,	#12,	#_F,	#4,	#0,	#_G,	#4
        00 07 04
   40A9 0F 00 04 00 05 04   192 		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#12,	#_G,	#4
        0C 07 04
   40B2 80                  193 		.db 	#silence_command
   40B3 0F 05 04 00 09 04   194 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#0,	#_C,	#5
        00 00 05
   40BC 0F 05 04 0C 09 04   195 		.db 	#15,	#_F,	#4,	#12,	#_A,	#4,	#0,	#_C,	#5
        00 00 05
   40C5 0F 05 04 00 09 04   196 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#12,	#_C,	#5
        0C 00 05
   40CE 80                  197 		.db 	#silence_command
   40CF 0F 07 04 00 0B 04   198 		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   40D8 0F 07 04 0C 0B 04   199 		.db 	#15,	#_G,	#4,	#12,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   40E1 0F 07 04 00 0B 04   200 		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#12,	#_D,	#5
        0C 02 05
   40EA 80                  201 		.db 	#silence_command
   40EB 81                  202 		.db	#end_song_command
                            203 
                            204 ;;			0	1	2	3	4	5	6	7	 8
                            205 ;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   40EC                     206 song_2::
   40EC 84 1F               207 		.db	#set_B_noise_command,	#31
   40EE 89 00 01 FF         208 		.db	#set_envelope_command,	#0,	#0x01,	#0xFF
   40F2 0F 0B 02 10 0B 04   209 		.db 	#15,	#_B,	#2,	#16,	#_B,	#4,	#0,	#_G,	#4
        00 07 04
   40FB 82                  210 		.db	#sustain_command
   40FC 80                  211 		.db	#silence_command
   40FD 80                  212 		.db 	#silence_command
   40FE 89 08 00 FF         213 		.db	#set_envelope_command,	#8,	#0x00,	#0xFF
   4102 0F 0B 03 10 0B 05   214 		.db 	#15,	#_B,	#3,	#16,	#_B,	#5,	#0,	#_G,	#4
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



        00 07 04
   410B 82                  215 		.db	#sustain_command
   410C 82                  216 		.db	#sustain_command
   410D 0F 06 03 00 0B 02   217 		.db 	#15,	#_Fs,	#3,	#0,	#_B,	#2,	#0,	#_D,	#5
        00 02 05
   4116 89 0A 01 FF         218 		.db	#set_envelope_command,	#10,	#0x01,	#0xFF
   411A 0F 0B 02 10 0B 02   219 		.db 	#15,	#_B,	#2,	#16,	#_B,	#2,	#0,	#_D,	#5
        00 02 05
   4123 82                  220 		.db	#sustain_command
   4124 80                  221 		.db	#silence_command
   4125 80                  222 		.db 	#silence_command
   4126 89 0B 01 FF         223 		.db	#set_envelope_command,	#11,	#0x01,	#0xFF
   412A 0F 06 02 10 0B 03   224 		.db 	#15,	#_Fs,	#2,	#16,	#_B,	#3,	#0,	#_D,	#5
        00 02 05
   4133 82                  225 		.db	#sustain_command
   4134 80                  226 		.db	#silence_command
   4135 80                  227 		.db 	#silence_command
   4136 89 0F 01 FF         228 		.db	#set_envelope_command,	#15,	#0x01,	#0xFF
   413A 0F 09 02 10 0B 04   229 		.db 	#15,	#_A,	#2,	#16,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   4143 82                  230 		.db	#sustain_command
   4144 80                  231 		.db	#silence_command
   4145 80                  232 		.db 	#silence_command
   4146 89 0E 01 FF         233 		.db	#set_envelope_command,	#14,	#0x01,	#0xFF
   414A 0F 0B 02 10 0B 01   234 		.db 	#15,	#_B,	#2,	#16,	#_B,	#1,	#0,	#_D,	#5
        00 02 05
   4153 82                  235 		.db	#sustain_command
   4154 80                  236 		.db	#silence_command
   4155 80                  237 		.db 	#silence_command
   4156 89 0C 01 FF         238 		.db	#set_envelope_command,	#12,	#0x01,	#0xFF
   415A 0F 02 03 10 0B 03   239 		.db 	#15,	#_D,	#3,	#16,	#_B,	#3,	#0,	#_D,	#5
        00 02 05
   4163 82                  240 		.db	#sustain_command
   4164 82                  241 		.db	#sustain_command
   4165 82                  242 		.db	#sustain_command
   4166 81                  243 		.db	#end_song_command
                            244 
   4167 00 00               245 current_song_init_pointer: 	.dw #0
   4169 00 00               246 current_song_pointer: 		.dw #0
                            247 
                            248 
                     0080   249 .equ silence_command, 		#0b10000000
                     0081   250 .equ end_song_command, 		#0b10000001
                     0082   251 .equ sustain_command, 		#0b10000010
                     0083   252 .equ set_A_noise_command,	#0b10000011
                     0084   253 .equ set_B_noise_command,	#0b10000100
                     0085   254 .equ set_C_noise_command,	#0b10000101
                     0086   255 .equ reset_A_noise_command,	#0b10000110
                     0087   256 .equ reset_B_noise_command,	#0b10000111
                     0088   257 .equ reset_C_noise_command,	#0b10001000
                     0089   258 .equ set_envelope_command,	#0b10001001
                            259 
                            260 ;; HL => song pointer
   416B                     261 set_song_pointer:
   416B 22 67 41      [16]  262 	ld	(current_song_init_pointer), hl
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



   416E 22 69 41      [16]  263 	ld	(current_song_pointer), hl
   4171 C9            [10]  264 	ret
                            265 
   4172                     266 play_frame::
   4172 2A 69 41      [16]  267 	ld	hl, (current_song_pointer)
                            268 
   4175 7E            [ 7]  269 	ld	a, (hl)
   4176 FE 80         [ 7]  270 	cp 	#silence_command
   4178 20 07         [12]  271 	jr	nz, not_play_silence
                            272 	;;
                            273 	;;	PLAY SILENCE
   417A CD 88 42      [17]  274 		call 	silence_PSG_mixer
   417D 23            [ 6]  275 		inc 	hl
   417E C3 30 42      [10]  276 		jp	exit_play_frame
                            277 
   4181                     278 	not_play_silence:
   4181 FE 81         [ 7]  279 		cp 	#end_song_command
   4183 20 0A         [12]  280 		jr	nz, not_play_end
                            281 		;;
                            282 		;;	PLAY END
   4185 2A 67 41      [16]  283 			ld 	hl, (current_song_init_pointer)
   4188 22 69 41      [16]  284 			ld	(current_song_pointer), hl
   418B CD 72 41      [17]  285 			call 	play_frame
   418E C9            [10]  286 			ret
                            287 
   418F                     288 	not_play_end:
   418F FE 82         [ 7]  289 		cp 	#sustain_command
   4191 20 04         [12]  290 		jr	nz, not_play_sustain
                            291 		;;
                            292 		;;	PLAY SUSTAIN
   4193 23            [ 6]  293 			inc 	hl
   4194 C3 30 42      [10]  294 			jp	exit_play_frame
                            295 
   4197                     296 	not_play_sustain:
   4197 FE 83         [ 7]  297 		cp 	#set_A_noise_command
   4199 20 0C         [12]  298 		jr	nz, not_set_A_noise
                            299 		;;
                            300 		;;	SET A NOISE
   419B 3A 25 40      [13]  301 			ld	a, (mixer_config)	;
   419E CB 9F         [ 8]  302 			res	3, a			;
   41A0 32 25 40      [13]  303 			ld	(mixer_config), a	; enable A channel noise
   41A3 CD 34 42      [17]  304 			call	play_frame_noise_period
   41A6 C9            [10]  305 			ret
                            306 
   41A7                     307 	not_set_A_noise:
   41A7 FE 84         [ 7]  308 		cp 	#set_B_noise_command
   41A9 20 0C         [12]  309 		jr	nz, not_set_B_noise
                            310 		;;
                            311 		;;	SET B NOISE
   41AB 3A 25 40      [13]  312 			ld	a, (mixer_config)	;
   41AE CB A7         [ 8]  313 			res	4, a			;
   41B0 32 25 40      [13]  314 			ld	(mixer_config), a	; enable B channel noise
   41B3 CD 34 42      [17]  315 			call	play_frame_noise_period
   41B6 C9            [10]  316 			ret
                            317 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



   41B7                     318 	not_set_B_noise:
   41B7 FE 85         [ 7]  319 		cp 	#set_C_noise_command
   41B9 20 0C         [12]  320 		jr	nz, not_set_C_noise
                            321 		;;
                            322 		;;	SET C NOISE
   41BB 3A 25 40      [13]  323 			ld	a, (mixer_config)	;
   41BE CB AF         [ 8]  324 			res	5, a			;
   41C0 32 25 40      [13]  325 			ld	(mixer_config), a	; enable C channel noise
   41C3 CD 34 42      [17]  326 			call	play_frame_noise_period
   41C6 C9            [10]  327 			ret
                            328 
   41C7                     329 	not_set_C_noise:
   41C7 FE 86         [ 7]  330 		cp 	#reset_A_noise_command
   41C9 20 0C         [12]  331 		jr	nz, not_reset_A_noise
                            332 		;;
                            333 		;;	RESET A NOISE
   41CB 3A 25 40      [13]  334 			ld	a, (mixer_config)	;
   41CE CB DF         [ 8]  335 			set	3, a			;
   41D0 32 25 40      [13]  336 			ld	(mixer_config), a	; disable A channel noise
   41D3 CD 34 42      [17]  337 			call	play_frame_noise_period
   41D6 C9            [10]  338 			ret
                            339 
   41D7                     340 	not_reset_A_noise:
   41D7 FE 87         [ 7]  341 		cp 	#reset_B_noise_command
   41D9 20 0C         [12]  342 		jr	nz, not_reset_B_noise
                            343 		;;
                            344 		;;	RESET B NOISE
   41DB 3A 25 40      [13]  345 			ld	a, (mixer_config)	;
   41DE CB E7         [ 8]  346 			set	4, a			;
   41E0 32 25 40      [13]  347 			ld	(mixer_config), a	; disable B channel noise
   41E3 CD 34 42      [17]  348 			call	play_frame_noise_period
   41E6 C9            [10]  349 			ret
                            350 
   41E7                     351 	not_reset_B_noise:
   41E7 FE 88         [ 7]  352 		cp 	#reset_C_noise_command
   41E9 20 0C         [12]  353 		jr	nz, not_reset_C_noise
                            354 		;;
                            355 		;;	RESET B NOISE
   41EB 3A 25 40      [13]  356 			ld	a, (mixer_config)	;
   41EE CB EF         [ 8]  357 			set	5, a			;
   41F0 32 25 40      [13]  358 			ld	(mixer_config), a	; disable C channel noise
   41F3 CD 34 42      [17]  359 			call	play_frame_noise_period
   41F6 C9            [10]  360 			ret
                            361 
   41F7                     362 	not_reset_C_noise:
   41F7 FE 89         [ 7]  363 		cp 	#set_envelope_command
   41F9 20 1D         [12]  364 		jr	nz, not_set_envelope
                            365 		;;
                            366 		;;	SET ENVELOPE
   41FB 23            [ 6]  367 			inc 	hl
                            368 
   41FC 7E            [ 7]  369 			ld	a, (hl)			; A <= envelope shape ID
   41FD 0E 0D         [ 7]  370 			ld	c, #envelope_shape_reg
   41FF CD 80 40      [17]  371 			call	set_AY_register
   4202 23            [ 6]  372 			inc 	hl
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 12.
Hexadecimal [16-Bits]



                            373 
   4203 7E            [ 7]  374 			ld	a, (hl)			; A <= envelope coarse period
   4204 0E 0C         [ 7]  375 			ld	c, #c_envelope_period_reg
   4206 CD 80 40      [17]  376 			call	set_AY_register
   4209 23            [ 6]  377 			inc 	hl
                            378 
   420A 7E            [ 7]  379 			ld	a, (hl)			; A <= envelope fine period
   420B 0E 0B         [ 7]  380 			ld	c, #f_envelope_period_reg
   420D CD 80 40      [17]  381 			call	set_AY_register
   4210 23            [ 6]  382 			inc 	hl
                            383 
   4211 22 69 41      [16]  384 			ld	(current_song_pointer), hl
   4214 CD 72 41      [17]  385 			call 	play_frame
   4217 C9            [10]  386 			ret
                            387 
   4218                     388 	not_set_envelope:
                            389 	;;
                            390 	;;	PLAY TUNES LINE
   4218 CD 90 42      [17]  391 		call 	update_PSG_mixer
                            392 		;; play A tune
   421B 0E 08         [ 7]  393 		ld	c, #A_volume_reg	; C <= A volume register ID
   421D 16 00         [ 7]  394 		ld	d, #channel_A		; D <= channel A ID
   421F CD 43 42      [17]  395 		call	play_frame_tune
                            396 
                            397 		;; play B tune
   4222 0E 09         [ 7]  398 		ld	c, #B_volume_reg	; C <= B volume register ID
   4224 16 01         [ 7]  399 		ld	d, #channel_B		; D <= channel B ID
   4226 CD 43 42      [17]  400 		call	play_frame_tune
                            401 
                            402 		;; play C tune
   4229 0E 0A         [ 7]  403 		ld	c, #C_volume_reg	; C <= C volume register ID
   422B 16 02         [ 7]  404 		ld	d, #channel_C		; D <= channel C ID
   422D CD 43 42      [17]  405 		call	play_frame_tune
                            406 	
   4230                     407 	exit_play_frame:
   4230 22 69 41      [16]  408 	ld	(current_song_pointer), hl
                            409 
   4233 C9            [10]  410 	ret
                            411 
                            412 ;; HL => current song pointer
                            413 ;;
                            414 ;; HL keeps updated here
                            415 ;; DESTROYS: AF, BC, DE, HL
   4234                     416 play_frame_noise_period:
   4234 23            [ 6]  417 	inc 	hl
   4235 7E            [ 7]  418 	ld	a, (hl)			; A <= noise period value
   4236 0E 06         [ 7]  419 	ld	c, #noise_period_reg
   4238 CD 80 40      [17]  420 	call	set_AY_register
   423B 23            [ 6]  421 	inc 	hl
                            422 
   423C 22 69 41      [16]  423 	ld	(current_song_pointer), hl
   423F CD 72 41      [17]  424 	call 	play_frame
   4242 C9            [10]  425 	ret
                            426 
                            427 ;; C => AY register ID
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 13.
Hexadecimal [16-Bits]



                            428 ;; D => channel ID
                            429 ;;
                            430 ;; HL keeps updated here
                            431 ;; DESTROYS: AF, BC, DE, HL
   4243                     432 play_frame_tune::
   4243 7E            [ 7]  433 	ld	a, (hl)			; read value 
   4244 CD 80 40      [17]  434 	call	set_AY_register		; set C AY register
   4247 23            [ 6]  435 	inc 	hl
                            436 
   4248 7A            [ 4]  437 	ld	a, d		; A <= channel ID
   4249 46            [ 7]  438 	ld	b, (hl)		; B <= tune ID
   424A 23            [ 6]  439 	inc 	hl		;
   424B 4E            [ 7]  440 	ld 	c, (hl)		; C <= octave
   424C 23            [ 6]  441 	inc 	hl
                            442 
   424D E5            [11]  443 	push	hl
   424E CD 53 42      [17]  444 	call	play_note
   4251 E1            [10]  445 	pop 	hl
                            446 
   4252 C9            [10]  447 	ret
                            448 
                            449 ;; A => channel ID
                            450 ;; B => tune ID
                            451 ;; C => octave
                            452 ;;
                            453 ;; DESTROYS: AF, BC, HL
   4253                     454 play_note::
   4253 FE 00         [ 7]  455 	cp #channel_A
   4255 20 08         [12]  456 	jr nz, is_channel_B
                            457 		; CHANNEL A
   4257 1E 00         [ 7]  458 		ld	e, #A_f_pitch_reg
   4259 16 01         [ 7]  459 		ld	d, #A_c_pitch_reg
   425B CD 78 42      [17]  460 		call	play_note_channel
                            461 
   425E C9            [10]  462 		ret
   425F                     463 	is_channel_B:
   425F FE 01         [ 7]  464 		cp #channel_B
   4261 20 08         [12]  465 		jr nz, is_channel_C
                            466 			; CHANNEL B
   4263 1E 02         [ 7]  467 			ld	e, #B_f_pitch_reg
   4265 16 03         [ 7]  468 			ld	d, #B_c_pitch_reg
   4267 CD 78 42      [17]  469 			call	play_note_channel
                            470 
   426A C9            [10]  471 			ret
   426B                     472 	is_channel_C:
   426B FE 02         [ 7]  473 		cp #channel_C
   426D 20 08         [12]  474 		jr nz, exit_channel_selection
                            475 			; CHANNEL C
   426F 1E 04         [ 7]  476 			ld	e, #C_f_pitch_reg
   4271 16 05         [ 7]  477 			ld	d, #C_c_pitch_reg
   4273 CD 78 42      [17]  478 			call	play_note_channel
                            479 
   4276 C9            [10]  480 			ret
                            481 
   4277                     482 	exit_channel_selection:
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 14.
Hexadecimal [16-Bits]



   4277 C9            [10]  483 	ret
                            484 
                            485 ;; B => tune ID
                            486 ;; C => octave
                            487 ;; D => coarse pitch register ID
                            488 ;; E => fine pitch register ID
   4278                     489 play_note_channel::
   4278 D5            [11]  490 	push 	de
   4279 CD 99 42      [17]  491 	call	get_fine_pitch	; HL <= fine pitch value
   427C D1            [10]  492 	pop	de
                            493 
   427D 7D            [ 4]  494 	ld	a, l
   427E 4B            [ 4]  495 	ld	c, e		; C <= fine pitch register ID
   427F CD 80 40      [17]  496 	call	set_AY_register
                            497 
   4282 7C            [ 4]  498 	ld	a, h		; A <= course pitch value (HL/256)
   4283 4A            [ 4]  499 	ld	c, d		; C <= coarse pitch register ID
   4284 CD 80 40      [17]  500 	call	set_AY_register
   4287 C9            [10]  501 	ret
                            502 
   4288                     503 silence_PSG_mixer:
   4288 3E 3F         [ 7]  504 	ld 	a, #0b00111111
   428A 0E 07         [ 7]  505 	ld	c, #mixer_reg
   428C CD 80 40      [17]  506 	call	set_AY_register
   428F C9            [10]  507 	ret
                            508 
   4290                     509 update_PSG_mixer:
   4290 3A 25 40      [13]  510 	ld	a, (mixer_config)
   4293 0E 07         [ 7]  511 	ld	c, #mixer_reg
   4295 CD 80 40      [17]  512 	call	set_AY_register
   4298 C9            [10]  513 	ret
                            514 
                            515 ;; B => tune ID
                            516 ;; C => octave
                            517 ;; 
                            518 ;; HL <= fine pitch value
                            519 ;; DESTROYS: AF, BC, DE
   4299                     520 get_fine_pitch::
   4299 78            [ 4]  521 	ld	a, b		; A <= tune ID
   429A CD AC 42      [17]  522 	call 	get_tune	; HL <= tune value
                            523 
   429D 79            [ 4]  524 	ld	a, c
   429E FE 00         [ 7]  525 	cp	#0
   42A0 20 02         [12]  526 	jr	nz, octaves_loop
                            527 		; octave is 0
   42A2 7C            [ 4]  528 		ld	a, h	; A <= tune value integer part
   42A3 C9            [10]  529 		ret
   42A4                     530 	octaves_loop:
   42A4 CB 3C         [ 8]  531 		srl 	h			;
   42A6 CB 1D         [ 8]  532 		rr 	l			; HL/2
   42A8 0D            [ 4]  533 		dec 	c
   42A9 20 F9         [12]  534 		jr	nz, octaves_loop	; EXIT IF C-- == ZERO
   42AB C9            [10]  535 	ret
                            536 
                            537 ;; A => tune ID
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 15.
Hexadecimal [16-Bits]



                            538 ;; HL <= tune value
                            539 ;;
                            540 ;; DESTROYS AF, DE, HL
   42AC                     541 get_tune::
   42AC 21 0C 40      [10]  542 	ld	hl, #tunes_table	; HL <= Tunes vector address
   42AF 11 00 00      [10]  543 	ld	de, #0			;
   42B2 5F            [ 4]  544 	ld	e, a			; DE <= A
   42B3 19            [11]  545 	add 	hl, de			;
   42B4 19            [11]  546 	add 	hl, de			; HL <= vector adress + tuneIDx2
                            547 
   42B5 5E            [ 7]  548 	ld	e, (hl)			; 
   42B6 2C            [ 4]  549 	inc 	l			; 
   42B7 56            [ 7]  550 	ld	d, (hl)			; DE <= tune value
                            551 
   42B8 EB            [ 4]  552 	ex 	de, hl 			; HL <= tune value
                            553 
   42B9 C9            [10]  554 	ret
                            555 
                            556 ; doc : https://github.com/AugustoRuiz/WYZTracker/blob/master/AsmPlayer/WYZPROPLAY47c_CPC.ASM
                            557 ; doc : http://www.cpcwiki.eu/imgs/d/dc/Ay3-891x.pdf
                            558 ; Link: http://www.sinclair.hu/hardver/otletek/ay_doc/AY-3-8912.htm
                            559 ; Link: http://cpctech.cpc-live.com/docs/psg.html
                            560 ; http://www.cpcmania.com/Docs/Manuals/Manual%20de%20Usuario%20Amstrad%20CPC%20464.pdf
                            561 ; http://www.z80.info/zip/z80cpu_um.pdf#G10.1000022639
                            562 ; http://www.next.gr/uploads/63/circuit.diagram.cpc464.png
                            563 
                            564 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            565 ;; 		AY-3-8910 REGISTERS
                            566 ;;
                            567 ;; 	0	Channel A fine pitch	8-bit (0-255)
                            568 ;; 	1	Channel A course pitch	4-bit (0-15)
                            569 ;; 	2	Channel B fine pitch	8-bit (0-255)
                            570 ;; 	3	Channel B course pitch	4-bit (0-15)
                            571 ;; 	4	Channel C fine pitch	8-bit (0-255)
                            572 ;; 	5	Channel C course pitch	4-bit (0-15)
                            573 ;; 	6	Noise pitch	5-bit (0-31)
                            574 ;; 	7	Mixer	8-bit (see below)
                            575 ;; 	8	Channel A volume	4-bit (0-15, see below)
                            576 ;; 	9	Channel B volume	4-bit (0-15, see below)
                            577 ;; 	10	Channel C volume	4-bit (0-15, see below)
                            578 ;; 	11	Envelope fine duration	8-bit (0-255)
                            579 ;; 	12	Envelope course duration	8-bit (0-255)
                            580 ;; 	13	Envelope shape	4-bit (0-15)
                            581 ;; 	14	I/O port A	8-bit (0-255)
                            582 ;; 	15	I/O port B	8-bit (0-255)
                            583 
                            584 
                            585 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            586 ;; 				MIXER
                            587 ;; Bit: 7 	6 	5 	4 	3 	2 	1 	0
                            588 ;; 	I/O 	I/O 	Noise 	Noise 	Noise 	Tone 	Tone 	Tone
                            589 ;; 	B 	A 	C 	B 	A 	C 	B 	A
                            590 ;; The AY-3-8912 ignores bit 7 of this register.
                            591 
                            592 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 16.
Hexadecimal [16-Bits]



                            593 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            594 ;;			ENVELOPES
                            595 ;;
                            596 ;; Select with register 13
                            597 ;; 0	\_________	single decay then off
                            598 ;; 1	/	single attack then hold
                            599 ;; 4	/|_________	single attack then off
                            600 ;; 8	\|\|\|\|\|\|\|\|\|\|\|\	repeated decay
                            601 ;; 9	\_________	single decay then off
                            602 ;; 10	\/\/\/\/\/\/\/\/\/\	repeated decay-attack
                            603 ;; 11	\| 	single decay then hold
                            604 ;; 12	/|/|/|/|/|/|/|/|/|/|/|/	repeated attack
                            605 ;; 14	/\/\/\/\/\/\/\/\/\/	repeated attack-decay
                            606 ;; 15	/|_________	single attack then off
                            607 
                            608 
                            609 
                            610 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            611 ;;		PITCH
                            612 ;;
                            613 ;;	fine 	= value/2^octave
                            614 ;;	course	= fine/256
                            615 ;;	
                            616 ;;	Note 	Frequency (Hz) 	
                            617 ;;	A 	220
                            618 ;;	A# 	233.3
                            619 ;;	B 	246.94
                            620 ;;	C	261.63 	
                            621 ;;	C# 	277.2
                            622 ;;	D 	293.66
                            623 ;;	D# 	311.1
                            624 ;;	E 	329.63
                            625 ;;	F 	349.23
                            626 ;;	F# 	370
                            627 ;;	G 	392
                            628 ;;	G# 	415.3
                            629 ;;	
                            630 ;;	Note	Value
                            631 ;;	C	3421
                            632 ;;	C#	3228
                            633 ;;	D	3047
                            634 ;;	D#	2876
                            635 ;;	E	2715
                            636 ;;	F	2562
                            637 ;;	F#	2419
                            638 ;;	G	2283
                            639 ;;	G#	2155
                            640 ;;	A	2034
                            641 ;;	A#	1920
                            642 ;;	B	1892
