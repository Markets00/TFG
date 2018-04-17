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
   40DE CD F1 41      [17]  135 		call 	play_frame
   40E1 3E 28         [ 7]  136 		ld 	a, #player_period
                            137 
   40E3                     138 	not_play:
   40E3 32 CC 40      [13]  139 		ld 	(player_n_interruptions), a
   40E6 C9            [10]  140 	ret
                            141 
   40E7                     142 initialize_player:
   40E7 21 D8 40      [10]  143 	ld 	hl, #musicHandler
   40EA CD 41 43      [17]  144 	call 	cpct_setInterruptHandler_asm
                            145 
   40ED CD 1D 43      [17]  146 	call 	update_PSG_mixer
                            147 
   40F0 21 63 41      [10]  148 	ld	hl, #song_2
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 8.
Hexadecimal [16-Bits]



   40F3 CD EA 41      [17]  149 	call	set_song_pointer
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
   4129 00                  179 		.db 	#silence_command
   412A 0F 05 04 00 09 04   180 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#0,	#_C,	#5
        00 00 05
   4133 0F 05 04 0C 09 04   181 		.db 	#15,	#_F,	#4,	#12,	#_A,	#4,	#0,	#_C,	#5
        00 00 05
   413C 0F 05 04 00 09 04   182 		.db 	#15,	#_F,	#4,	#0,	#_A,	#4,	#12,	#_C,	#5
        0C 00 05
   4145 00                  183 		.db 	#silence_command
   4146 0F 07 04 00 0B 04   184 		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   414F 0F 07 04 0C 0B 04   185 		.db 	#15,	#_G,	#4,	#12,	#_B,	#4,	#0,	#_D,	#5
        00 02 05
   4158 0F 07 04 00 0B 04   186 		.db 	#15,	#_G,	#4,	#0,	#_B,	#4,	#12,	#_D,	#5
        0C 02 05
   4161 00                  187 		.db 	#silence_command
   4162 01                  188 		.db	#end_song_command
                            189 
                            190 ;;						0	1	2	3	4	5	6	7	 8
                            191 ;;					  A volume|A tune ID|A octv|B volume|B tune ID|B octv|C volume|C tune ID|C octv
   4163                     192 song_2::
   4163 04 1F               193 		.db	#set_B_noise_command,	#31
   4165 09 00 01 FF         194 		.db	#set_envelope_command,	#0,	#0x01,	#0xFF
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 9.
Hexadecimal [16-Bits]



   4169 0A 0F 0B 02 10 0B   195 		.db 	#read_line_command,	#15,	#_B,	#2,	#16,	#_B,	#4,	#0,	#_G,	#4
        04 00 07 04
   4173 02                  196 		.db	#sustain_command
   4174 00                  197 		.db	#silence_command
   4175 00                  198 		.db 	#silence_command
   4176 09 08 00 FF         199 		.db	#set_envelope_command,	#8,	#0x00,	#0xFF
   417A 0A 0F 0B 03 10 0B   200 		.db 	#read_line_command,	#15,	#_B,	#3,	#16,	#_B,	#5,	#0,	#_G,	#4
        05 00 07 04
   4184 02                  201 		.db	#sustain_command
   4185 02                  202 		.db	#sustain_command
   4186 0A 0F 06 03 00 0B   203 		.db 	#read_line_command,	#15,	#_Fs,	#3,	#0,	#_B,	#2,	#0,	#_D,	#5
        02 00 02 05
   4190 09 0A 01 FF         204 		.db	#set_envelope_command,	#10,	#0x01,	#0xFF
   4194 0A 0F 0B 02 10 0B   205 		.db 	#read_line_command,	#15,	#_B,	#2,	#16,	#_B,	#2,	#0,	#_D,	#5
        02 00 02 05
   419E 02                  206 		.db	#sustain_command
   419F 00                  207 		.db	#silence_command
   41A0 00                  208 		.db 	#silence_command
   41A1 09 0B 01 FF         209 		.db	#set_envelope_command,	#11,	#0x01,	#0xFF
   41A5 0A 0F 06 02 10 0B   210 		.db 	#read_line_command,	#15,	#_Fs,	#2,	#16,	#_B,	#3,	#0,	#_D,	#5
        03 00 02 05
   41AF 02                  211 		.db	#sustain_command
   41B0 00                  212 		.db	#silence_command
   41B1 00                  213 		.db 	#silence_command
   41B2 09 0F 01 FF         214 		.db	#set_envelope_command,	#15,	#0x01,	#0xFF
   41B6 0A 0F 09 02 10 0B   215 		.db 	#read_line_command,	#15,	#_A,	#2,	#16,	#_B,	#4,	#0,	#_D,	#5
        04 00 02 05
   41C0 02                  216 		.db	#sustain_command
   41C1 00                  217 		.db	#silence_command
   41C2 00                  218 		.db 	#silence_command
   41C3 09 0E 01 FF         219 		.db	#set_envelope_command,	#14,	#0x01,	#0xFF
   41C7 0A 0F 0B 02 10 0B   220 		.db 	#read_line_command,	#15,	#_B,	#2,	#16,	#_B,	#1,	#0,	#_D,	#5
        01 00 02 05
   41D1 02                  221 		.db	#sustain_command
   41D2 00                  222 		.db	#silence_command
   41D3 00                  223 		.db 	#silence_command
   41D4 09 0C 01 FF         224 		.db	#set_envelope_command,	#12,	#0x01,	#0xFF
   41D8 0A 0F 02 03 10 0B   225 		.db 	#read_line_command,	#15,	#_D,	#3,	#16,	#_B,	#3,	#0,	#_D,	#5
        03 00 02 05
   41E2 02                  226 		.db	#sustain_command
   41E3 02                  227 		.db	#sustain_command
   41E4 02                  228 		.db	#sustain_command
   41E5 01                  229 		.db	#end_song_command
                            230 
   41E6 00 00               231 current_song_init_pointer: 	.dw #0
   41E8 00 00               232 current_song_pointer: 		.dw #0
                            233 
                            234 
                     0000   235 .equ silence_command, 		#0
                     0001   236 .equ end_song_command, 		#1
                     0002   237 .equ sustain_command, 		#2
                     0003   238 .equ set_A_noise_command,	#3
                     0004   239 .equ set_B_noise_command,	#4
                     0005   240 .equ set_C_noise_command,	#5
                     0006   241 .equ reset_A_noise_command,	#6
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 10.
Hexadecimal [16-Bits]



                     0007   242 .equ reset_B_noise_command,	#7
                     0008   243 .equ reset_C_noise_command,	#8
                     0009   244 .equ set_envelope_command,	#9
                     000A   245 .equ read_line_command,		#10
                            246 
                            247 ;; Switch
                            248 ;;
                            249 ;;ld a, (hl)
                            250 ;;add a
                            251 ;;add a
                            252 ;;ld (jump_from), a
                            253 ;;jump_from = .+1
                            254 ;;jr 00 
                            255 ;;jp comando1
                            256 ;;jp comando2
                            257 ;;jp comando3
                            258 ;;jp comando4
                            259 ;;....
                            260 ;;
                            261 ;;comando1:
                            262 ;;	....
                            263 ;;
                            264 ;;comando2:
                            265 ;;	....
                            266 ;;
                            267 ;;comando3:
                            268 ;;	....
                            269 
                            270 
                            271 ;; HL => song pointer
   41EA                     272 set_song_pointer:
   41EA 22 E6 41      [16]  273 	ld	(current_song_init_pointer), hl
   41ED 22 E8 41      [16]  274 	ld	(current_song_pointer), hl
   41F0 C9            [10]  275 	ret
                            276 
   41F1                     277 play_frame::
   41F1 2A E8 41      [16]  278 	ld	hl, (current_song_pointer)
                            279 
   41F4 7E            [ 7]  280 	ld 	a, (hl)
   41F5 47            [ 4]  281 	ld	b, a
   41F6 80            [ 4]  282 	add 	b
   41F7 80            [ 4]  283 	add 	b
   41F8 32 FC 41      [13]  284 	ld 	(jump_from), a
                     01FC   285 	jump_from = .+1
   41FB 18 21         [12]  286 	jr silence_code
                            287 
   41FD C3 1E 42      [10]  288 	jp silence_code		; +0
   4200 C3 25 42      [10]  289 	jp end_song_code 	; +3
   4203 C3 2F 42      [10]  290 	jp sustain_code		; +6
   4206 C3 33 42      [10]  291 	jp set_A_noise_code	; +9
   4209 C3 3F 42      [10]  292 	jp set_B_noise_code	; +12
   420C C3 4B 42      [10]  293 	jp set_C_noise_code	; +15
   420F C3 57 42      [10]  294 	jp reset_A_noise_code	; +18
   4212 C3 67 42      [10]  295 	jp reset_B_noise_code	; +21
   4215 C3 77 42      [10]  296 	jp reset_C_noise_code	; +24
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 11.
Hexadecimal [16-Bits]



   4218 C3 87 42      [10]  297 	jp set_envelope_code	; +27
   421B C3 A4 42      [10]  298 	jp read_tunes_code	; +30
                            299 
                            300 
   421E                     301 	silence_code:
                            302 	;;	PLAY SILENCE
   421E CD 15 43      [17]  303 		call 	silence_PSG_mixer
   4221 23            [ 6]  304 		inc 	hl
   4222 C3 BD 42      [10]  305 		jp	exit_play_frame
                            306 
   4225                     307 	end_song_code:
                            308 	;;	PLAY END
   4225 2A E6 41      [16]  309 		ld 	hl, (current_song_init_pointer)
   4228 22 E8 41      [16]  310 		ld	(current_song_pointer), hl
   422B CD F1 41      [17]  311 		call 	play_frame
   422E C9            [10]  312 		ret
                            313 
   422F                     314 	sustain_code:
                            315 	;;	PLAY SUSTAIN
   422F 23            [ 6]  316 		inc 	hl
   4230 C3 BD 42      [10]  317 		jp	exit_play_frame
                            318 
   4233                     319 	set_A_noise_code:
                            320 	;;	SET A NOISE
   4233 3A CD 40      [13]  321 		ld	a, (mixer_config)	;
   4236 CB 9F         [ 8]  322 		res	3, a			;
   4238 32 CD 40      [13]  323 		ld	(mixer_config), a	; enable A channel noise
   423B CD C1 42      [17]  324 		call	play_frame_noise_period
   423E C9            [10]  325 		ret
                            326 
   423F                     327 	set_B_noise_code:
                            328 	;;	SET B NOISE
   423F 3A CD 40      [13]  329 		ld	a, (mixer_config)	;
   4242 CB A7         [ 8]  330 		res	4, a			;
   4244 32 CD 40      [13]  331 		ld	(mixer_config), a	; enable B channel noise
   4247 CD C1 42      [17]  332 		call	play_frame_noise_period
   424A C9            [10]  333 		ret
                            334 
   424B                     335 	set_C_noise_code:
                            336 	;;	SET C NOISE
   424B 3A CD 40      [13]  337 		ld	a, (mixer_config)	;
   424E CB AF         [ 8]  338 		res	5, a			;
   4250 32 CD 40      [13]  339 		ld	(mixer_config), a	; enable C channel noise
   4253 CD C1 42      [17]  340 		call	play_frame_noise_period
   4256 C9            [10]  341 		ret
                            342 
   4257                     343 	reset_A_noise_code:
                            344 	;;	RESET A NOISE
   4257 3A CD 40      [13]  345 		ld	a, (mixer_config)	;
   425A CB DF         [ 8]  346 		set	3, a			;
   425C 32 CD 40      [13]  347 		ld	(mixer_config), a	; disable A channel noise
   425F 23            [ 6]  348 		inc 	hl
                            349 
   4260 22 E8 41      [16]  350 		ld	(current_song_pointer), hl
   4263 CD F1 41      [17]  351 		call 	play_frame
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 12.
Hexadecimal [16-Bits]



   4266 C9            [10]  352 		ret
                            353 
   4267                     354 	reset_B_noise_code:
                            355 	;;	RESET B NOISE
   4267 3A CD 40      [13]  356 		ld	a, (mixer_config)	;
   426A CB E7         [ 8]  357 		set	4, a			;
   426C 32 CD 40      [13]  358 		ld	(mixer_config), a	; disable B channel noise
   426F 23            [ 6]  359 		inc 	hl
                            360 
   4270 22 E8 41      [16]  361 		ld	(current_song_pointer), hl
   4273 CD F1 41      [17]  362 		call 	play_frame
   4276 C9            [10]  363 		ret
                            364 
   4277                     365 	reset_C_noise_code:
                            366 	;;	RESET C NOISE
   4277 3A CD 40      [13]  367 		ld	a, (mixer_config)	;
   427A CB EF         [ 8]  368 		set	5, a			;
   427C 32 CD 40      [13]  369 		ld	(mixer_config), a	; disable C channel noise
   427F 23            [ 6]  370 		inc 	hl
                            371 
   4280 22 E8 41      [16]  372 		ld	(current_song_pointer), hl
   4283 CD F1 41      [17]  373 		call 	play_frame
   4286 C9            [10]  374 		ret
                            375 
   4287                     376 	set_envelope_code:
                            377 	;;	SET ENVELOPE
   4287 23            [ 6]  378 		inc 	hl
                            379 
   4288 7E            [ 7]  380 		ld	a, (hl)			; A <= envelope shape ID
   4289 0E 0D         [ 7]  381 		ld	c, #envelope_shape_reg
   428B CD F7 40      [17]  382 		call	set_AY_register
   428E 23            [ 6]  383 		inc 	hl
                            384 
   428F 7E            [ 7]  385 		ld	a, (hl)			; A <= envelope coarse period
   4290 0E 0C         [ 7]  386 		ld	c, #c_envelope_period_reg
   4292 CD F7 40      [17]  387 		call	set_AY_register
   4295 23            [ 6]  388 		inc 	hl
                            389 
   4296 7E            [ 7]  390 		ld	a, (hl)			; A <= envelope fine period
   4297 0E 0B         [ 7]  391 		ld	c, #f_envelope_period_reg
   4299 CD F7 40      [17]  392 		call	set_AY_register
   429C 23            [ 6]  393 		inc 	hl
                            394 
   429D 22 E8 41      [16]  395 		ld	(current_song_pointer), hl
   42A0 CD F1 41      [17]  396 		call 	play_frame
   42A3 C9            [10]  397 		ret
                            398 
   42A4                     399 	read_tunes_code:
                            400 	;;	PLAY TUNES LINE
   42A4 23            [ 6]  401 		inc 	hl
                            402 
   42A5 CD 1D 43      [17]  403 		call 	update_PSG_mixer
                            404 		;; play A tune
   42A8 0E 08         [ 7]  405 		ld	c, #A_volume_reg	; C <= A volume register ID
   42AA 16 00         [ 7]  406 		ld	d, #channel_A		; D <= channel A ID
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 13.
Hexadecimal [16-Bits]



   42AC CD D0 42      [17]  407 		call	play_frame_tune
                            408 
                            409 		;; play B tune
   42AF 0E 09         [ 7]  410 		ld	c, #B_volume_reg	; C <= B volume register ID
   42B1 16 01         [ 7]  411 		ld	d, #channel_B		; D <= channel B ID
   42B3 CD D0 42      [17]  412 		call	play_frame_tune
                            413 
                            414 		;; play C tune
   42B6 0E 0A         [ 7]  415 		ld	c, #C_volume_reg	; C <= C volume register ID
   42B8 16 02         [ 7]  416 		ld	d, #channel_C		; D <= channel C ID
   42BA CD D0 42      [17]  417 		call	play_frame_tune
                            418 	
   42BD                     419 	exit_play_frame:
   42BD 22 E8 41      [16]  420 	ld	(current_song_pointer), hl
                            421 
   42C0 C9            [10]  422 	ret
                            423 
                            424 ;; HL => current song pointer
                            425 ;;
                            426 ;; HL keeps updated here
                            427 ;; DESTROYS: AF, BC, DE, HL
   42C1                     428 play_frame_noise_period:
   42C1 23            [ 6]  429 	inc 	hl
   42C2 7E            [ 7]  430 	ld	a, (hl)			; A <= noise period value
   42C3 0E 06         [ 7]  431 	ld	c, #noise_period_reg
   42C5 CD F7 40      [17]  432 	call	set_AY_register
   42C8 23            [ 6]  433 	inc 	hl
                            434 
   42C9 22 E8 41      [16]  435 	ld	(current_song_pointer), hl
   42CC CD F1 41      [17]  436 	call 	play_frame
   42CF C9            [10]  437 	ret
                            438 
                            439 ;; C => AY register ID
                            440 ;; D => channel ID
                            441 ;;
                            442 ;; HL keeps updated here
                            443 ;; DESTROYS: AF, BC, DE, HL
   42D0                     444 play_frame_tune::
   42D0 7E            [ 7]  445 	ld	a, (hl)			; read value 
   42D1 CD F7 40      [17]  446 	call	set_AY_register		; set C AY register
   42D4 23            [ 6]  447 	inc 	hl
                            448 
   42D5 7A            [ 4]  449 	ld	a, d		; A <= channel ID
   42D6 46            [ 7]  450 	ld	b, (hl)		; B <= tune ID
   42D7 23            [ 6]  451 	inc 	hl		;
   42D8 4E            [ 7]  452 	ld 	c, (hl)		; C <= octave
   42D9 23            [ 6]  453 	inc 	hl
                            454 
   42DA E5            [11]  455 	push	hl
   42DB CD E0 42      [17]  456 	call	play_note
   42DE E1            [10]  457 	pop 	hl
                            458 
   42DF C9            [10]  459 	ret
                            460 
                            461 ;; A => channel ID
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 14.
Hexadecimal [16-Bits]



                            462 ;; B => tune ID
                            463 ;; C => octave
                            464 ;;
                            465 ;; DESTROYS: AF, BC, HL
   42E0                     466 play_note::
   42E0 FE 00         [ 7]  467 	cp #channel_A
   42E2 20 08         [12]  468 	jr nz, is_channel_B
                            469 		; CHANNEL A
   42E4 1E 00         [ 7]  470 		ld	e, #A_f_pitch_reg
   42E6 16 01         [ 7]  471 		ld	d, #A_c_pitch_reg
   42E8 CD 05 43      [17]  472 		call	play_note_channel
                            473 
   42EB C9            [10]  474 		ret
   42EC                     475 	is_channel_B:
   42EC FE 01         [ 7]  476 		cp #channel_B
   42EE 20 08         [12]  477 		jr nz, is_channel_C
                            478 			; CHANNEL B
   42F0 1E 02         [ 7]  479 			ld	e, #B_f_pitch_reg
   42F2 16 03         [ 7]  480 			ld	d, #B_c_pitch_reg
   42F4 CD 05 43      [17]  481 			call	play_note_channel
                            482 
   42F7 C9            [10]  483 			ret
   42F8                     484 	is_channel_C:
   42F8 FE 02         [ 7]  485 		cp #channel_C
   42FA 20 08         [12]  486 		jr nz, exit_channel_selection
                            487 			; CHANNEL C
   42FC 1E 04         [ 7]  488 			ld	e, #C_f_pitch_reg
   42FE 16 05         [ 7]  489 			ld	d, #C_c_pitch_reg
   4300 CD 05 43      [17]  490 			call	play_note_channel
                            491 
   4303 C9            [10]  492 			ret
                            493 
   4304                     494 	exit_channel_selection:
   4304 C9            [10]  495 	ret
                            496 
                            497 ;; B => tune ID
                            498 ;; C => octave
                            499 ;; D => coarse pitch register ID
                            500 ;; E => fine pitch register ID
   4305                     501 play_note_channel::
   4305 D5            [11]  502 	push 	de
   4306 CD 26 43      [17]  503 	call	get_fine_pitch	; HL <= fine pitch value
   4309 D1            [10]  504 	pop	de
                            505 
   430A 7D            [ 4]  506 	ld	a, l
   430B 4B            [ 4]  507 	ld	c, e		; C <= fine pitch register ID
   430C CD F7 40      [17]  508 	call	set_AY_register
                            509 
   430F 7C            [ 4]  510 	ld	a, h		; A <= course pitch value (HL/256)
   4310 4A            [ 4]  511 	ld	c, d		; C <= coarse pitch register ID
   4311 CD F7 40      [17]  512 	call	set_AY_register
   4314 C9            [10]  513 	ret
                            514 
   4315                     515 silence_PSG_mixer:
   4315 3E 3F         [ 7]  516 	ld 	a, #0b00111111
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 15.
Hexadecimal [16-Bits]



   4317 0E 07         [ 7]  517 	ld	c, #mixer_reg
   4319 CD F7 40      [17]  518 	call	set_AY_register
   431C C9            [10]  519 	ret
                            520 
   431D                     521 update_PSG_mixer:
   431D 3A CD 40      [13]  522 	ld	a, (mixer_config)
   4320 0E 07         [ 7]  523 	ld	c, #mixer_reg
   4322 CD F7 40      [17]  524 	call	set_AY_register
   4325 C9            [10]  525 	ret
                            526 
                            527 
                            528 
                            529 ;; B => tune ID
                            530 ;; C => octave
                            531 ;; 
                            532 ;; HL <= fine pitch value
                            533 ;; DESTROYS: AF, BC, DE
   4326                     534 get_fine_pitch::
   4326 21 0C 40      [10]  535 	ld	hl, #tunes_table	; HL <= Tunes vector address
   4329 79            [ 4]  536 	ld	a, c
   432A FE 00         [ 7]  537 	cp	#0
   432C 20 02         [12]  538 	jr	nz, iterate_octaves
                            539 		; octave is 0
   432E 18 07         [12]  540 		jr exit_octaves
   4330                     541 	iterate_octaves:
   4330 11 18 00      [10]  542 		ld	de, #24
   4333                     543 	octaves_loop:
   4333 19            [11]  544 		add 	hl, de			; HL <= HL + 32 (next octave frequencies address)
   4334 0D            [ 4]  545 		dec 	c
   4335 20 FC         [12]  546 		jr	nz, octaves_loop
                            547 
   4337                     548 	exit_octaves:
   4337 58            [ 4]  549 		ld	e, b		; E <= tune ID
                            550 
   4338 16 00         [ 7]  551 		ld	d, #0		;
   433A 19            [11]  552 		add 	hl, de		;
   433B 19            [11]  553 		add 	hl, de		; HL <= vector address + tuneIDx2
                            554 
   433C 5E            [ 7]  555 		ld	e, (hl)		; 
   433D 23            [ 6]  556 		inc 	hl		; 
   433E 56            [ 7]  557 		ld	d, (hl)		; DE <= tune value
                            558 
   433F EB            [ 4]  559 		ex 	de, hl 		; HL <= tune value
                            560 
   4340 C9            [10]  561 	ret
                            562 
                            563 
                            564 ; UI: dear imgui
                            565 
                            566 ; doc : https://github.com/AugustoRuiz/WYZTracker/blob/master/AsmPlayer/WYZPROPLAY47c_CPC.ASM
                            567 ; doc : http://www.cpcwiki.eu/imgs/d/dc/Ay3-891x.pdf
                            568 ; Link: http://www.sinclair.hu/hardver/otletek/ay_doc/AY-3-8912.htm
                            569 ; Link: http://cpctech.cpc-live.com/docs/psg.html
                            570 ; http://www.cpcmania.com/Docs/Manuals/Manual%20de%20Usuario%20Amstrad%20CPC%20464.pdf
                            571 ; http://www.z80.info/zip/z80cpu_um.pdf#G10.1000022639
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 16.
Hexadecimal [16-Bits]



                            572 ; http://www.next.gr/uploads/63/circuit.diagram.cpc464.png
                            573 
                            574 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            575 ;; 		AY-3-8910 REGISTERS
                            576 ;;
                            577 ;; 	0	Channel A fine pitch	8-bit (0-255)
                            578 ;; 	1	Channel A course pitch	4-bit (0-15)
                            579 ;; 	2	Channel B fine pitch	8-bit (0-255)
                            580 ;; 	3	Channel B course pitch	4-bit (0-15)
                            581 ;; 	4	Channel C fine pitch	8-bit (0-255)
                            582 ;; 	5	Channel C course pitch	4-bit (0-15)
                            583 ;; 	6	Noise pitch	5-bit (0-31)
                            584 ;; 	7	Mixer	8-bit (see below)
                            585 ;; 	8	Channel A volume	4-bit (0-15, see below)
                            586 ;; 	9	Channel B volume	4-bit (0-15, see below)
                            587 ;; 	10	Channel C volume	4-bit (0-15, see below)
                            588 ;; 	11	Envelope fine duration	8-bit (0-255)
                            589 ;; 	12	Envelope course duration	8-bit (0-255)
                            590 ;; 	13	Envelope shape	4-bit (0-15)
                            591 ;; 	14	I/O port A	8-bit (0-255)
                            592 ;; 	15	I/O port B	8-bit (0-255)
                            593 
                            594 
                            595 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            596 ;; 				MIXER
                            597 ;; Bit: 7 	6 	5 	4 	3 	2 	1 	0
                            598 ;; 	I/O 	I/O 	Noise 	Noise 	Noise 	Tone 	Tone 	Tone
                            599 ;; 	B 	A 	C 	B 	A 	C 	B 	A
                            600 ;; The AY-3-8912 ignores bit 7 of this register.
                            601 
                            602 
                            603 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            604 ;;			ENVELOPES
                            605 ;;
                            606 ;; Select with register 13
                            607 ;; 0	\_________	single decay then off
                            608 ;; 1	/	single attack then hold
                            609 ;; 4	/|_________	single attack then off
                            610 ;; 8	\|\|\|\|\|\|\|\|\|\|\|\	repeated decay
                            611 ;; 9	\_________	single decay then off
                            612 ;; 10	\/\/\/\/\/\/\/\/\/\	repeated decay-attack
                            613 ;; 11	\| 	single decay then hold
                            614 ;; 12	/|/|/|/|/|/|/|/|/|/|/|/	repeated attack
                            615 ;; 14	/\/\/\/\/\/\/\/\/\/	repeated attack-decay
                            616 ;; 15	/|_________	single attack then off
                            617 
                            618 
                            619 
                            620 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                            621 ;;		PITCH
                            622 ;;
                            623 ;;	fine 	= value/2^octave
                            624 ;;	course	= fine/256
                            625 ;;	
                            626 ;;	Note 	Frequency (Hz) 	
ASxxxx Assembler V02.00 + NoICE + SDCC mods  (Zilog Z80 / Hitachi HD64180), page 17.
Hexadecimal [16-Bits]



                            627 ;;	A 	220
                            628 ;;	A# 	233.3
                            629 ;;	B 	246.94
                            630 ;;	C	261.63 	
                            631 ;;	C# 	277.2
                            632 ;;	D 	293.66
                            633 ;;	D# 	311.1
                            634 ;;	E 	329.63
                            635 ;;	F 	349.23
                            636 ;;	F# 	370
                            637 ;;	G 	392
                            638 ;;	G# 	415.3
                            639 ;;	
                            640 ;;	Note	Value
                            641 ;;	C	3421
                            642 ;;	C#	3228
                            643 ;;	D	3047
                            644 ;;	D#	2876
                            645 ;;	E	2715
                            646 ;;	F	2562
                            647 ;;	F#	2419
                            648 ;;	G	2283
                            649 ;;	G#	2155
                            650 ;;	A	2034
                            651 ;;	A#	1920
                            652 ;;	B	1892
