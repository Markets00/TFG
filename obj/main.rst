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
                             42 ;; OCTAVE -3,
   400C EE 0E                43 	.dw #3822	;   C	-   0	;
   400E 18 0E                44 	.dw #3608	;   C#	-   1	;
   4010 4D 0D                45 	.dw #3405	;   D	-   2	;
   4012 8E 0C                46 	.dw #3214	;   D#	-   3	;
   4014 DA 0B                47 	.dw #3034	;   E	-   4	;
   4016 2F 0B                48 	.dw #2863	;   F	-   5	;
   4018 8F 0A                49 	.dw #2703	;   F#	-   6	;
   401A F7 09                50 	.dw #2551	;   G	-   7	;
   401C 68 09                51 	.dw #2408	;   G#	-   8	;
   401E E1 08                52 	.dw #2273	;   A	-   9	;
   4020 61 08                53 	.dw #2145	;   A#	-   10	;
   4022 E9 07                54 	.dw #2025	;   B	-   11	;
                             55 ;; OCTAVE -2,
   4024 77 07 0C 07 A7 06    56 	.dw #1911, #1804, #1703, #1607, #1517, #1432, #1351, #1276, #1204, #1136, #1073, #1012
        47 06 ED 05 98 05
        47 05 FC 04 B4 04
        70 04 31 04 F4 03
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 6.
Hexadecimal [16-Bits]



                             57 ;; OCTAVE -1,
   403C BC 03 86 03 53 03    58 	.dw #956, #902, #851, #804, #758, #716, #676, #638, #602, #568, #536, #506
        24 03 F6 02 CC 02
        A4 02 7E 02 5A 02
        38 02 18 02 FA 01
                             59 ;; OCTAVE 0
   4054 DE 01 C3 01 AA 01    60 	.dw #478, #451, #426, #402, #379, #358, #338, #319, #301, #284, #268, #253
        92 01 7B 01 66 01
        52 01 3F 01 2D 01
        1C 01 0C 01 FD 00
                             61 ;; OCTAVE 1
   406C EF 00 E1 00 D5 00    62 	.dw #239, #225, #213, #201, #190, #179, #169, #159, #150, #142, #134, #127
        C9 00 BE 00 B3 00
        A9 00 9F 00 96 00
        8E 00 86 00 7F 00
                             63 ;; OCTAVE 2
   4084 77 00 71 00 6A 00    64 	.dw #119, #113, #106, #100, #95, #89, #84, #80, #75, #71, #67, #63
        64 00 5F 00 59 00
        54 00 50 00 4B 00
        47 00 43 00 3F 00
                             65 ;; OCTAVE 3
   409C 3C 00 38 00 35 00    66 	.dw #60, #56, #53, #50, #47, #45, #42, #40, #38, #36, #34, #32
        32 00 2F 00 2D 00
        2A 00 28 00 26 00
        24 00 22 00 20 00
                             67 ;; OCTAVE 4
   40B4 1E 00 1C 00 1B 00    68 	.dw #30, #28, #27, #25, #24, #22, #21, #20, #19, #18, #17, #16
        19 00 18 00 16 00
        15 00 14 00 13 00
        12 00 11 00 10 00
                             69 
                             70 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                             71 ;; AY-3-8910/2 registers ID table
                     0000    72 .equ A_f_pitch_reg,		#0
                     0001    73 .equ A_c_pitch_reg,		#1
                     0002    74 .equ B_f_pitch_reg,		#2
                     0003    75 .equ B_c_pitch_reg,		#3
                     0004    76 .equ C_f_pitch_reg,		#4
                     0005    77 .equ C_c_pitch_reg,		#5
                     0006    78 .equ noise_period_reg,		#6
                     0007    79 .equ mixer_reg,			#7
                     0008    80 .equ A_volume_reg,		#8
                     0009    81 .equ B_volume_reg,		#9
                     000A    82 .equ C_volume_reg,		#10
                     000B    83 .equ f_envelope_period_reg,	#11
                     000C    84 .equ c_envelope_period_reg,	#12
                     000D    85 .equ envelope_shape_reg,	#13
                     000E    86 .equ A_in_out_reg,		#14
                     000F    87 .equ B_in_out_reg,		#15
                             88 
                     0028    89 .equ	player_period, 	#40
   40CC 28                   90 player_n_interruptions: .db #player_period
                             91 
                             92 
   40CD 38                   93 mixer_config:	.db #0b00111000
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 7.
Hexadecimal [16-Bits]



                             94 
                             95 ; FIRST TEST
                             96 ; Input
                             97 ; note 3421
                             98 ; octave 4
                             99 ; 
                            100 ; Output
                            101 ; fine 213
                            102 ; course 0
                            103 ; tune playing
                            104 
                            105 ; SECOND TEST
                            106 ; Input
                            107 ; note 3421 (C)
                            108 ; octave 0-8
                            109 ;
                            110 ; Output
                            111 ; Octave:Fine - Course
                            112 ; 0:	 3421 - 13
                            113 ; 1:	 1710 - 6
                            114 ; 2:	  855 - 3
                            115 ; 3:	  427 - 1
                            116 ; 4:	  213 - 0
                            117 ; 5:	  106 - 0
                            118 ; 6:	   53 - 0
                            119 ; 7:	   26 - 0
                            120 ; 8:	   13 - 0
                            121 
                            122 
   40CE                     123 _main::
   40CE CD E7 40      [17]  124 	call initialize_player
   40D1 DD 21 0A 40   [14]  125 	ld	ix, #current_octave	; IX <= octave position
   40D5                     126 	loop:
                            127 
   40D5 C3 D5 40      [10]  128 		jp 	loop
                            129 
   40D8                     130 musicHandler::
   40D8 3A CC 40      [13]  131 	ld 	a, (player_n_interruptions)
   40DB 3D            [ 4]  132 	dec 	a
   40DC 20 05         [12]  133 	jr 	nz, not_play
                            134 		;; n_interruptions == 0
   40DE CD E9 41      [17]  135 		call 	play_frame
   40E1 3E 28         [ 7]  136 		ld 	a, #player_period
                            137 
   40E3                     138 	not_play:
   40E3 32 CC 40      [13]  139 		ld 	(player_n_interruptions), a
   40E6 C9            [10]  140 	ret
                            141 
   40E7                     142 initialize_player:
   40E7 21 D8 40      [10]  143 	ld 	hl, #musicHandler
   40EA CD 3B 43      [17]  144 	call 	cpct_setInterruptHandler_asm
                            145 
   40ED CD 13 43      [17]  146 	call 	update_PSG_mixer
                            147 
   40F0 21 63 41      [10]  148 	ld	hl, #song_2
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   40F3 CD E2 41      [17]  149 	call	set_song_pointer
                            150 
   40F6 C9            [10]  151 	ret
                            152 
                            153 
                            154 ;; A => given value to set
                            155 ;; C => register ID
                            156 ;;
                            157 ;; DESTROYS BC
   40F7                     158 set_AY_register:
   40F7 06 F4         [ 7]  159 	ld 	b,#0xF4
   40F9 ED 49         [12]  160 	out 	(c), c
   40FB 01 C0 F6      [10]  161 	ld 	bc,#0xF6C0
   40FE ED 49         [12]  162 	out 	(c),c
   4100 ED 71               163 	.db #0xED, #0x71
                            164 
   4102 06 F4         [ 7]  165 	ld 	b,#0xF4
   4104 ED 79         [12]  166 	out 	(c), a
   4106 01 80 F6      [10]  167 	ld 	bc,#0xF680
   4109 ED 49         [12]  168 	out 	(c),c
   410B ED 71               169 	.db #0xED, #0x71
                            170 
   410D C9            [10]  171 	ret
                            172 
                            173 ;;			0	1	2	3	4	5	6	7	 8
                            174 ;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   410E                     175 song_1::
   410E 0F 00 04 00 05 04   176 		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#0,	#_G,	#4
        00 07 04
   4117 0F 00 04 0C 05 04   177 		.db 	#15,	#_C,	#4,	#12,	#_F,	#4,	#0,	#_G,	#4
        00 07 04
   4120 0F 00 04 00 05 04   178 		.db 	#15,	#_C,	#4,	#0,	#_F,	#4,	#12,	#_G,	#4
        0C 07 04
   4129 80                  179 		.db 	#silence_command
   412A 0F 05 04 00 09 04   180 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#0,	#_C,	#5
        00 00 05
   4133 0F 05 04 0C 09 04   181 		.db 	#15,	#_F,	#4,	#12,	#_A,	#4,	#0,	#_C,	#5
        00 00 05
   413C 0F 05 04 00 09 04   182 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#12,	#_C,	#5
        0C 00 05
   4145 80                  183 		.db 	#silence_command
   4146 0F 07 04 00 0B 04   184 		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   414F 0F 07 04 0C 0B 04   185 		.db 	#15,	#_G,	#4,	#12,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   4158 0F 07 04 00 0B 04   186 		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#12,	#_D,	#5
        0C 02 05
   4161 80                  187 		.db 	#silence_command
   4162 81                  188 		.db	#end_song_command
                            189 
                            190 ;;			0	1	2	3	4	5	6	7	 8
                            191 ;;		  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   4163                     192 song_2::
   4163 84 1F               193 		.db	#set_B_noise_command,	#31
   4165 89 00 01 FF         194 		.db	#set_envelope_command,	#0,	#0x01,	#0xFF
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



   4169 0F 0B 02 10 0B 04   195 		.db 	#15,	#_B,	#2,	#16,	#_B,	#4,	#0,	#_G,	#4
        00 07 04
   4172 82                  196 		.db	#sustain_command
   4173 80                  197 		.db	#silence_command
   4174 80                  198 		.db 	#silence_command
   4175 89 08 00 FF         199 		.db	#set_envelope_command,	#8,	#0x00,	#0xFF
   4179 0F 0B 03 10 0B 05   200 		.db 	#15,	#_B,	#3,	#16,	#_B,	#5,	#0,	#_G,	#4
        00 07 04
   4182 82                  201 		.db	#sustain_command
   4183 82                  202 		.db	#sustain_command
   4184 0F 06 03 00 0B 02   203 		.db 	#15,	#_Fs,	#3,	#0,	#_B,	#2,	#0,	#_D,	#5
        00 02 05
   418D 89 0A 01 FF         204 		.db	#set_envelope_command,	#10,	#0x01,	#0xFF
   4191 0F 0B 02 10 0B 02   205 		.db 	#15,	#_B,	#2,	#16,	#_B,	#2,	#0,	#_D,	#5
        00 02 05
   419A 82                  206 		.db	#sustain_command
   419B 80                  207 		.db	#silence_command
   419C 80                  208 		.db 	#silence_command
   419D 89 0B 01 FF         209 		.db	#set_envelope_command,	#11,	#0x01,	#0xFF
   41A1 0F 06 02 10 0B 03   210 		.db 	#15,	#_Fs,	#2,	#16,	#_B,	#3,	#0,	#_D,	#5
        00 02 05
   41AA 82                  211 		.db	#sustain_command
   41AB 80                  212 		.db	#silence_command
   41AC 80                  213 		.db 	#silence_command
   41AD 89 0F 01 FF         214 		.db	#set_envelope_command,	#15,	#0x01,	#0xFF
   41B1 0F 09 02 10 0B 04   215 		.db 	#15,	#_A,	#2,	#16,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   41BA 82                  216 		.db	#sustain_command
   41BB 80                  217 		.db	#silence_command
   41BC 80                  218 		.db 	#silence_command
   41BD 89 0E 01 FF         219 		.db	#set_envelope_command,	#14,	#0x01,	#0xFF
   41C1 0F 0B 02 10 0B 01   220 		.db 	#15,	#_B,	#2,	#16,	#_B,	#1,	#0,	#_D,	#5
        00 02 05
   41CA 82                  221 		.db	#sustain_command
   41CB 80                  222 		.db	#silence_command
   41CC 80                  223 		.db 	#silence_command
   41CD 89 0C 01 FF         224 		.db	#set_envelope_command,	#12,	#0x01,	#0xFF
   41D1 0F 02 03 10 0B 03   225 		.db 	#15,	#_D,	#3,	#16,	#_B,	#3,	#0,	#_D,	#5
        00 02 05
   41DA 82                  226 		.db	#sustain_command
   41DB 82                  227 		.db	#sustain_command
   41DC 82                  228 		.db	#sustain_command
   41DD 81                  229 		.db	#end_song_command
                            230 
   41DE 00 00               231 current_song_init_pointer: 	.dw #0
   41E0 00 00               232 current_song_pointer: 		.dw #0
                            233 
                            234 
                     0080   235 .equ silence_command, 		#0b10000000
                     0081   236 .equ end_song_command, 		#0b10000001
                     0082   237 .equ sustain_command, 		#0b10000010
                     0083   238 .equ set_A_noise_command,	#0b10000011
                     0084   239 .equ set_B_noise_command,	#0b10000100
                     0085   240 .equ set_C_noise_command,	#0b10000101
                     0086   241 .equ reset_A_noise_command,	#0b10000110
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



                     0087   242 .equ reset_B_noise_command,	#0b10000111
                     0088   243 .equ reset_C_noise_command,	#0b10001000
                     0089   244 .equ set_envelope_command,	#0b10001001
                            245 
                            246 ;; Switch
                            247 ;;
                            248 ;;ld a, (hl)
                            249 ;;add a
                            250 ;;add a
                            251 ;;ld (jump_from), a
                            252 ;;jump_from = .+1
                            253 ;;jr 00 
                            254 ;;jp comando1
                            255 ;;jp comando2
                            256 ;;jp comando3
                            257 ;;jp comando4
                            258 ;;....
                            259 ;;
                            260 ;;comando1:
                            261 ;;	....
                            262 ;;
                            263 ;;comando2:
                            264 ;;	....
                            265 ;;
                            266 ;;comando3:
                            267 ;;	....
                            268 
                            269 
                            270 ;; HL => song pointer
   41E2                     271 set_song_pointer:
   41E2 22 DE 41      [16]  272 	ld	(current_song_init_pointer), hl
   41E5 22 E0 41      [16]  273 	ld	(current_song_pointer), hl
   41E8 C9            [10]  274 	ret
                            275 
   41E9                     276 play_frame::
   41E9 2A E0 41      [16]  277 	ld	hl, (current_song_pointer)
                            278 
   41EC 7E            [ 7]  279 	ld	a, (hl)
   41ED FE 80         [ 7]  280 	cp 	#silence_command
   41EF 20 07         [12]  281 	jr	nz, not_play_silence
                            282 	;;
                            283 	;;	PLAY SILENCE
   41F1 CD 0B 43      [17]  284 		call 	silence_PSG_mixer
   41F4 23            [ 6]  285 		inc 	hl
   41F5 C3 B3 42      [10]  286 		jp	exit_play_frame
                            287 
   41F8                     288 	not_play_silence:
   41F8 FE 81         [ 7]  289 		cp 	#end_song_command
   41FA 20 0A         [12]  290 		jr	nz, not_play_end
                            291 		;;
                            292 		;;	PLAY END
   41FC 2A DE 41      [16]  293 			ld 	hl, (current_song_init_pointer)
   41FF 22 E0 41      [16]  294 			ld	(current_song_pointer), hl
   4202 CD E9 41      [17]  295 			call 	play_frame
   4205 C9            [10]  296 			ret
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



                            297 
   4206                     298 	not_play_end:
   4206 FE 82         [ 7]  299 		cp 	#sustain_command
   4208 20 04         [12]  300 		jr	nz, not_play_sustain
                            301 		;;
                            302 		;;	PLAY SUSTAIN
   420A 23            [ 6]  303 			inc 	hl
   420B C3 B3 42      [10]  304 			jp	exit_play_frame
                            305 
   420E                     306 	not_play_sustain:
   420E FE 83         [ 7]  307 		cp 	#set_A_noise_command
   4210 20 0C         [12]  308 		jr	nz, not_set_A_noise
                            309 		;;
                            310 		;;	SET A NOISE
   4212 3A CD 40      [13]  311 			ld	a, (mixer_config)	;
   4215 CB 9F         [ 8]  312 			res	3, a			;
   4217 32 CD 40      [13]  313 			ld	(mixer_config), a	; enable A channel noise
   421A CD B7 42      [17]  314 			call	play_frame_noise_period
   421D C9            [10]  315 			ret
                            316 
   421E                     317 	not_set_A_noise:
   421E FE 84         [ 7]  318 		cp 	#set_B_noise_command
   4220 20 0C         [12]  319 		jr	nz, not_set_B_noise
                            320 		;;
                            321 		;;	SET B NOISE
   4222 3A CD 40      [13]  322 			ld	a, (mixer_config)	;
   4225 CB A7         [ 8]  323 			res	4, a			;
   4227 32 CD 40      [13]  324 			ld	(mixer_config), a	; enable B channel noise
   422A CD B7 42      [17]  325 			call	play_frame_noise_period
   422D C9            [10]  326 			ret
                            327 
   422E                     328 	not_set_B_noise:
   422E FE 85         [ 7]  329 		cp 	#set_C_noise_command
   4230 20 0C         [12]  330 		jr	nz, not_set_C_noise
                            331 		;;
                            332 		;;	SET C NOISE
   4232 3A CD 40      [13]  333 			ld	a, (mixer_config)	;
   4235 CB AF         [ 8]  334 			res	5, a			;
   4237 32 CD 40      [13]  335 			ld	(mixer_config), a	; enable C channel noise
   423A CD B7 42      [17]  336 			call	play_frame_noise_period
   423D C9            [10]  337 			ret
                            338 
   423E                     339 	not_set_C_noise:
   423E FE 86         [ 7]  340 		cp 	#reset_A_noise_command
   4240 20 10         [12]  341 		jr	nz, not_reset_A_noise
                            342 		;;
                            343 		;;	RESET A NOISE
   4242 3A CD 40      [13]  344 			ld	a, (mixer_config)	;
   4245 CB DF         [ 8]  345 			set	3, a			;
   4247 32 CD 40      [13]  346 			ld	(mixer_config), a	; disable A channel noise
   424A 23            [ 6]  347 			inc 	hl
                            348 
   424B 22 E0 41      [16]  349 			ld	(current_song_pointer), hl
   424E CD E9 41      [17]  350 			call 	play_frame
   4251 C9            [10]  351 			ret
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 12.
Hexadecimal [16-Bits]



                            352 
   4252                     353 	not_reset_A_noise:
   4252 FE 87         [ 7]  354 		cp 	#reset_B_noise_command
   4254 20 10         [12]  355 		jr	nz, not_reset_B_noise
                            356 		;;
                            357 		;;	RESET B NOISE
   4256 3A CD 40      [13]  358 			ld	a, (mixer_config)	;
   4259 CB E7         [ 8]  359 			set	4, a			;
   425B 32 CD 40      [13]  360 			ld	(mixer_config), a	; disable B channel noise
   425E 23            [ 6]  361 			inc 	hl
                            362 
   425F 22 E0 41      [16]  363 			ld	(current_song_pointer), hl
   4262 CD E9 41      [17]  364 			call 	play_frame
   4265 C9            [10]  365 			ret
                            366 
   4266                     367 	not_reset_B_noise:
   4266 FE 88         [ 7]  368 		cp 	#reset_C_noise_command
   4268 20 10         [12]  369 		jr	nz, not_reset_C_noise
                            370 		;;
                            371 		;;	RESET C NOISE
   426A 3A CD 40      [13]  372 			ld	a, (mixer_config)	;
   426D CB EF         [ 8]  373 			set	5, a			;
   426F 32 CD 40      [13]  374 			ld	(mixer_config), a	; disable C channel noise
   4272 23            [ 6]  375 			inc 	hl
                            376 
   4273 22 E0 41      [16]  377 			ld	(current_song_pointer), hl
   4276 CD E9 41      [17]  378 			call 	play_frame
   4279 C9            [10]  379 			ret
                            380 
   427A                     381 	not_reset_C_noise:
   427A FE 89         [ 7]  382 		cp 	#set_envelope_command
   427C 20 1D         [12]  383 		jr	nz, not_set_envelope
                            384 		;;
                            385 		;;	SET ENVELOPE
   427E 23            [ 6]  386 			inc 	hl
                            387 
   427F 7E            [ 7]  388 			ld	a, (hl)			; A <= envelope shape ID
   4280 0E 0D         [ 7]  389 			ld	c, #envelope_shape_reg
   4282 CD F7 40      [17]  390 			call	set_AY_register
   4285 23            [ 6]  391 			inc 	hl
                            392 
   4286 7E            [ 7]  393 			ld	a, (hl)			; A <= envelope coarse period
   4287 0E 0C         [ 7]  394 			ld	c, #c_envelope_period_reg
   4289 CD F7 40      [17]  395 			call	set_AY_register
   428C 23            [ 6]  396 			inc 	hl
                            397 
   428D 7E            [ 7]  398 			ld	a, (hl)			; A <= envelope fine period
   428E 0E 0B         [ 7]  399 			ld	c, #f_envelope_period_reg
   4290 CD F7 40      [17]  400 			call	set_AY_register
   4293 23            [ 6]  401 			inc 	hl
                            402 
   4294 22 E0 41      [16]  403 			ld	(current_song_pointer), hl
   4297 CD E9 41      [17]  404 			call 	play_frame
   429A C9            [10]  405 			ret
                            406 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 13.
Hexadecimal [16-Bits]



   429B                     407 	not_set_envelope:
                            408 	;;
                            409 	;;	PLAY TUNES LINE
   429B CD 13 43      [17]  410 		call 	update_PSG_mixer
                            411 		;; play A tune
   429E 0E 08         [ 7]  412 		ld	c, #A_volume_reg	; C <= A volume register ID
   42A0 16 00         [ 7]  413 		ld	d, #channel_A		; D <= channel A ID
   42A2 CD C6 42      [17]  414 		call	play_frame_tune
                            415 
                            416 		;; play B tune
   42A5 0E 09         [ 7]  417 		ld	c, #B_volume_reg	; C <= B volume register ID
   42A7 16 01         [ 7]  418 		ld	d, #channel_B		; D <= channel B ID
   42A9 CD C6 42      [17]  419 		call	play_frame_tune
                            420 
                            421 		;; play C tune
   42AC 0E 0A         [ 7]  422 		ld	c, #C_volume_reg	; C <= C volume register ID
   42AE 16 02         [ 7]  423 		ld	d, #channel_C		; D <= channel C ID
   42B0 CD C6 42      [17]  424 		call	play_frame_tune
                            425 	
   42B3                     426 	exit_play_frame:
   42B3 22 E0 41      [16]  427 	ld	(current_song_pointer), hl
                            428 
   42B6 C9            [10]  429 	ret
                            430 
                            431 ;; HL => current song pointer
                            432 ;;
                            433 ;; HL keeps updated here
                            434 ;; DESTROYS: AF, BC, DE, HL
   42B7                     435 play_frame_noise_period:
   42B7 23            [ 6]  436 	inc 	hl
   42B8 7E            [ 7]  437 	ld	a, (hl)			; A <= noise period value
   42B9 0E 06         [ 7]  438 	ld	c, #noise_period_reg
   42BB CD F7 40      [17]  439 	call	set_AY_register
   42BE 23            [ 6]  440 	inc 	hl
                            441 
   42BF 22 E0 41      [16]  442 	ld	(current_song_pointer), hl
   42C2 CD E9 41      [17]  443 	call 	play_frame
   42C5 C9            [10]  444 	ret
                            445 
                            446 ;; C => AY register ID
                            447 ;; D => channel ID
                            448 ;;
                            449 ;; HL keeps updated here
                            450 ;; DESTROYS: AF, BC, DE, HL
   42C6                     451 play_frame_tune::
   42C6 7E            [ 7]  452 	ld	a, (hl)			; read value 
   42C7 CD F7 40      [17]  453 	call	set_AY_register		; set C AY register
   42CA 23            [ 6]  454 	inc 	hl
                            455 
   42CB 7A            [ 4]  456 	ld	a, d		; A <= channel ID
   42CC 46            [ 7]  457 	ld	b, (hl)		; B <= tune ID
   42CD 23            [ 6]  458 	inc 	hl		;
   42CE 4E            [ 7]  459 	ld 	c, (hl)		; C <= octave
   42CF 23            [ 6]  460 	inc 	hl
                            461 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 14.
Hexadecimal [16-Bits]



   42D0 E5            [11]  462 	push	hl
   42D1 CD D6 42      [17]  463 	call	play_note
   42D4 E1            [10]  464 	pop 	hl
                            465 
   42D5 C9            [10]  466 	ret
                            467 
                            468 ;; A => channel ID
                            469 ;; B => tune ID
                            470 ;; C => octave
                            471 ;;
                            472 ;; DESTROYS: AF, BC, HL
   42D6                     473 play_note::
   42D6 FE 00         [ 7]  474 	cp #channel_A
   42D8 20 08         [12]  475 	jr nz, is_channel_B
                            476 		; CHANNEL A
   42DA 1E 00         [ 7]  477 		ld	e, #A_f_pitch_reg
   42DC 16 01         [ 7]  478 		ld	d, #A_c_pitch_reg
   42DE CD FB 42      [17]  479 		call	play_note_channel
                            480 
   42E1 C9            [10]  481 		ret
   42E2                     482 	is_channel_B:
   42E2 FE 01         [ 7]  483 		cp #channel_B
   42E4 20 08         [12]  484 		jr nz, is_channel_C
                            485 			; CHANNEL B
   42E6 1E 02         [ 7]  486 			ld	e, #B_f_pitch_reg
   42E8 16 03         [ 7]  487 			ld	d, #B_c_pitch_reg
   42EA CD FB 42      [17]  488 			call	play_note_channel
                            489 
   42ED C9            [10]  490 			ret
   42EE                     491 	is_channel_C:
   42EE FE 02         [ 7]  492 		cp #channel_C
   42F0 20 08         [12]  493 		jr nz, exit_channel_selection
                            494 			; CHANNEL C
   42F2 1E 04         [ 7]  495 			ld	e, #C_f_pitch_reg
   42F4 16 05         [ 7]  496 			ld	d, #C_c_pitch_reg
   42F6 CD FB 42      [17]  497 			call	play_note_channel
                            498 
   42F9 C9            [10]  499 			ret
                            500 
   42FA                     501 	exit_channel_selection:
   42FA C9            [10]  502 	ret
                            503 
                            504 ;; B => tune ID
                            505 ;; C => octave
                            506 ;; D => coarse pitch register ID
                            507 ;; E => fine pitch register ID
   42FB                     508 play_note_channel::
   42FB D5            [11]  509 	push 	de
   42FC CD 1C 43      [17]  510 	call	get_fine_pitch	; HL <= fine pitch value
   42FF D1            [10]  511 	pop	de
                            512 
   4300 7D            [ 4]  513 	ld	a, l
   4301 4B            [ 4]  514 	ld	c, e		; C <= fine pitch register ID
   4302 CD F7 40      [17]  515 	call	set_AY_register
                            516 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 15.
Hexadecimal [16-Bits]



   4305 7C            [ 4]  517 	ld	a, h		; A <= course pitch value (HL/256)
   4306 4A            [ 4]  518 	ld	c, d		; C <= coarse pitch register ID
   4307 CD F7 40      [17]  519 	call	set_AY_register
   430A C9            [10]  520 	ret
                            521 
   430B                     522 silence_PSG_mixer:
   430B 3E 3F         [ 7]  523 	ld 	a, #0b00111111
   430D 0E 07         [ 7]  524 	ld	c, #mixer_reg
   430F CD F7 40      [17]  525 	call	set_AY_register
   4312 C9            [10]  526 	ret
                            527 
   4313                     528 update_PSG_mixer:
   4313 3A CD 40      [13]  529 	ld	a, (mixer_config)
   4316 0E 07         [ 7]  530 	ld	c, #mixer_reg
   4318 CD F7 40      [17]  531 	call	set_AY_register
   431B C9            [10]  532 	ret
                            533 
                            534 ;; B => tune ID
                            535 ;; C => octave
                            536 ;; 
                            537 ;; HL <= fine pitch value
                            538 ;; DESTROYS: AF, BC, DE
   431C                     539 get_fine_pitch::
   431C 58            [ 4]  540 	ld	e, b		; E <= tune ID
   431D CD 2F 43      [17]  541 	call 	get_tune	; HL <= tune value
                            542 
   4320 79            [ 4]  543 	ld	a, c
   4321 FE 00         [ 7]  544 	cp	#0
   4323 20 02         [12]  545 	jr	nz, octaves_loop
                            546 		; octave is 0
   4325 7C            [ 4]  547 		ld	a, h	; A <= tune value integer part
   4326 C9            [10]  548 		ret
   4327                     549 	octaves_loop:
   4327 CB 3C         [ 8]  550 		srl 	h			;
   4329 CB 1D         [ 8]  551 		rr 	l			; HL/2
   432B 0D            [ 4]  552 		dec 	c
   432C 20 F9         [12]  553 		jr	nz, octaves_loop	; EXIT IF C-- == ZERO
   432E C9            [10]  554 	ret
                            555 
                            556 ;; E => tune ID
                            557 ;; HL <= tune value
                            558 ;;
                            559 ;; DESTROYS AF, DE, HL
   432F                     560 get_tune::
   432F 21 0C 40      [10]  561 	ld	hl, #tunes_table	; HL <= Tunes vector address
   4332 16 00         [ 7]  562 	ld	d, #0			;
   4334 19            [11]  563 	add 	hl, de			;
   4335 19            [11]  564 	add 	hl, de			; HL <= vector address + tuneIDx2
                            565 
   4336 5E            [ 7]  566 	ld	e, (hl)			; 
   4337 23            [ 6]  567 	inc 	hl			; 
   4338 56            [ 7]  568 	ld	d, (hl)			; DE <= tune value
                            569 
   4339 EB            [ 4]  570 	ex 	de, hl 			; HL <= tune value
                            571 
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 16.
Hexadecimal [16-Bits]



   433A C9            [10]  572 	ret
                            573 
                            574 
                            575 ; UI: dear imgui
                            576 
                            577 ; doc : https://github.com/AugustoRuiz/WYZTracker/blob/master/AsmPlayer/WYZPROPLAY47c_CPC.ASM
                            578 ; doc : http://www.cpcwiki.eu/imgs/d/dc/Ay3-891x.pdf
                            579 ; Link: http://www.sinclair.hu/hardver/otletek/ay_doc/AY-3-8912.htm
                            580 ; Link: http://cpctech.cpc-live.com/docs/psg.html
                            581 ; http://www.cpcmania.com/Docs/Manuals/Manual%20de%20Usuario%20Amstrad%20CPC%20464.pdf
                            582 ; http://www.z80.info/zip/z80cpu_um.pdf#G10.1000022639
                            583 ; http://www.next.gr/uploads/63/circuit.diagram.cpc464.png
                            584 
                            585 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            586 ;; 		AY-3-8910 REGISTERS
                            587 ;;
                            588 ;; 	0	Channel A fine pitch	8-bit (0-255)
                            589 ;; 	1	Channel A course pitch	4-bit (0-15)
                            590 ;; 	2	Channel B fine pitch	8-bit (0-255)
                            591 ;; 	3	Channel B course pitch	4-bit (0-15)
                            592 ;; 	4	Channel C fine pitch	8-bit (0-255)
                            593 ;; 	5	Channel C course pitch	4-bit (0-15)
                            594 ;; 	6	Noise pitch	5-bit (0-31)
                            595 ;; 	7	Mixer	8-bit (see below)
                            596 ;; 	8	Channel A volume	4-bit (0-15, see below)
                            597 ;; 	9	Channel B volume	4-bit (0-15, see below)
                            598 ;; 	10	Channel C volume	4-bit (0-15, see below)
                            599 ;; 	11	Envelope fine duration	8-bit (0-255)
                            600 ;; 	12	Envelope course duration	8-bit (0-255)
                            601 ;; 	13	Envelope shape	4-bit (0-15)
                            602 ;; 	14	I/O port A	8-bit (0-255)
                            603 ;; 	15	I/O port B	8-bit (0-255)
                            604 
                            605 
                            606 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            607 ;; 				MIXER
                            608 ;; Bit: 7 	6 	5 	4 	3 	2 	1 	0
                            609 ;; 	I/O 	I/O 	Noise 	Noise 	Noise 	Tone 	Tone 	Tone
                            610 ;; 	B 	A 	C 	B 	A 	C 	B 	A
                            611 ;; The AY-3-8912 ignores bit 7 of this register.
                            612 
                            613 
                            614 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            615 ;;			ENVELOPES
                            616 ;;
                            617 ;; Select with register 13
                            618 ;; 0	\_________	single decay then off
                            619 ;; 1	/	single attack then hold
                            620 ;; 4	/|_________	single attack then off
                            621 ;; 8	\|\|\|\|\|\|\|\|\|\|\|\	repeated decay
                            622 ;; 9	\_________	single decay then off
                            623 ;; 10	\/\/\/\/\/\/\/\/\/\	repeated decay-attack
                            624 ;; 11	\| 	single decay then hold
                            625 ;; 12	/|/|/|/|/|/|/|/|/|/|/|/	repeated attack
                            626 ;; 14	/\/\/\/\/\/\/\/\/\/	repeated attack-decay
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 17.
Hexadecimal [16-Bits]



                            627 ;; 15	/|_________	single attack then off
                            628 
                            629 
                            630 
                            631 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            632 ;;		PITCH
                            633 ;;
                            634 ;;	fine 	= value/2^octave
                            635 ;;	course	= fine/256
                            636 ;;	
                            637 ;;	Note 	Frequency (Hz) 	
                            638 ;;	A 	220
                            639 ;;	A# 	233.3
                            640 ;;	B 	246.94
                            641 ;;	C	261.63 	
                            642 ;;	C# 	277.2
                            643 ;;	D 	293.66
                            644 ;;	D# 	311.1
                            645 ;;	E 	329.63
                            646 ;;	F 	349.23
                            647 ;;	F# 	370
                            648 ;;	G 	392
                            649 ;;	G# 	415.3
                            650 ;;	
                            651 ;;	Note	Value
                            652 ;;	C	3421
                            653 ;;	C#	3228
                            654 ;;	D	3047
                            655 ;;	D#	2876
                            656 ;;	E	2715
                            657 ;;	F	2562
                            658 ;;	F#	2419
                            659 ;;	G	2283
                            660 ;;	G#	2155
                            661 ;;	A	2034
                            662 ;;	A#	1920
                            663 ;;	B	1892
