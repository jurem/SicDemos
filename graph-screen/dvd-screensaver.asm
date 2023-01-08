. Change settings at the bottom of this file.
. This program uses the graphical screen.
. Screen size and values screen_w, screen_h, ... must match.
. To replace dvd image with a simple rectangle, set useDVD to 0.
. Recomended refresh rate is 10'000'000 or 10MHz
prog	START	0
................................................................
	........ create object rect
	LDX	#f_drawRect_rect
	. rect.x
	LDA	#13
	STA	0, X
	. rect.y
	LDA	#20
	STA	3, X
	.
	LDA	#useDVD
	COMP	#0
	JEQ	main_noDVD
	. prepare dvd img pointer
	LDA	#dvd
	STA	f_main_img
	JSUB	f_inflate	. inflate dvd logo from bitmap
	. rect.width
	LDA	#dvd_w
	STA	6, X
	. rect.height
	LDA	#dvd_h
	STA	9, X
	J	main_noDVD_
main_noDVD
	LDA	#0
	STA	f_main_img
	. rect.width
	LDA	#width
	STA	6, X
	. rect.height
	LDA	#height
	STA	9, X
main_noDVD_
	STA	break
	........ prepare nextColor function
	LDA	#red
	STA	f_drawRect_color
	LDA	#f_drawRect_color
	ADD	#2
	STA	f_nextColor_color
	........
main_while
	........ sync
	LDA	#1
	ADDR	A, S
	+LDA	#sync
	COMPR	S, A
	JLT	main_while
	CLEAR	S
	........ clear previous location
	CLEAR	A
	STA	f_drawRect_img
	LDT	f_drawRect_color
	LDA	#0
	STA	f_drawRect_color
	JSUB	f_drawRect
	STT	f_drawRect_color
	........ x += dx
	LDA	0, X
	ADD	dx
	STA	0, X
	........ handle rect.left < 0
	COMP	#0
	JGT	main_while_check_left_gt
	JLT	main_while_check_left_lt
main_while_check_left_lt
	LDA	#0
	STA	0, X
	J	main_while_negate_x
main_while_check_left_gt
	ADD	6, X
	........ handle rect.right < vw
	COMP	#screen_w
	JLT	main_while_negate_x_
	JEQ	main_while_negate_x
	LDA	#screen_w
	SUB	6, X
	STA	0, X
main_while_negate_x
	JSUB	f_nextColor
	RMO	A, S		. dx = -dx
	LDA	dx		. dx = -dx
	MUL	n_m1		. dx = -dx
	STA	dx		. dx = -dx
	RMO	S, A		. dx = -dx
main_while_negate_x_
	........ y += dy
	LDA	3, X
	ADD	dy
	STA	3, X
	........ handle rect.top < 0
	COMP	#0
	JGT	main_while_check_top_gt
main_while_check_top_lt
	LDA	#0
	STA	3, X
	J	main_while_negate_y
main_while_check_top_gt
	ADD	9, X
	........ handle rect.right < vw
	COMP	#screen_h
	JLT	main_while_negate_y_
	JEQ	main_while_negate_y
	LDA	#screen_h
	SUB	9, X
	STA	3, X
main_while_negate_y
	JSUB	f_nextColor
	RMO	A, S		. dy = -dy
	LDA	dy		. dy = -dy
	MUL	n_m1		. dy = -dy
	STA	dy		. dy = -dy
	RMO	S, A		. dy = -dy
main_while_negate_y_
	........ draw rect
	LDA	f_main_img
	STA	f_drawRect_img
	JSUB	f_drawRect
	........
	J	main_while
	........
	J	halt
................................................................
f_px . f(x, y, color)
	STA	f_px_stack_A
	........
	LDA	f_px_y
	MUL	#screen_w
	ADD	f_px_x
	+ADD	#screen_address
	STA	f_px_addr
	LDA	f_px_color
	STCH	@f_px_addr
	........
	LDA	f_px_stack_A
	RSUB
................................................................
f_clampXY . f(x1*, x2*, y1*, y2*)
	STA	f_clampXY_stack_A
	........
	LDA	@f_clampXY_x1
	COMP	#0
	JGT	f_clampXY_x1_min
	LDA	#0
f_clampXY_x1_min
	STA	@f_clampXY_x1
	.
	LDA	@f_clampXY_x2
	COMP	#screen_w
	JLT	f_clampXY_x2_min
	LDA	#screen_w
	SUB	#1
f_clampXY_x2_min
	STA	@f_clampXY_x2
	........
	LDA	@f_clampXY_y1
	COMP	#0
	JGT	f_clampXY_y1_min
	LDA	#0
f_clampXY_y1_min
	STA	@f_clampXY_y1
	.
	LDA	@f_clampXY_y2
	COMP	#screen_h
	JLT	f_clampXY_y2_min
	LDA	#screen_h
	SUB	#1
f_clampXY_y2_min
	STA	@f_clampXY_y2
	........
	LDA	f_clampXY_stack_A
	RSUB
................................................................
f_drawRect . f(rect, color)
STA	break
	STA	f_drawRect_stack_A
	STS	f_drawRect_stack_S
	STT	f_drawRect_stack_T
	STX	f_drawRect_stack_X
	STL	f_drawRect_stack_L
	..........
	LDX	#f_drawRect_rect
	.......... Store min/max x
	LDA	0, X
	STA	f_drawRect_min_x
	ADD	6, X
	SUB	#1
	STA	f_drawRect_max_x
	.......... Store min/max y
	LDA	3, X
	STA	f_drawRect_min_y
	SUB	#1
	ADD	9, X
	STA	f_drawRect_max_y
	..........
	LDA	#f_drawRect_min_x
	STA	f_clampXY_x1
	LDA	#f_drawRect_max_x
	STA	f_clampXY_x2
	LDA	#f_drawRect_min_y
	STA	f_clampXY_y1
	LDA	#f_drawRect_max_y
	STA	f_clampXY_y2
	JSUB	f_clampXY
 	.......... Loop x and y
	CLEAR	T
	LDA	f_drawRect_min_y
	STA	f_px_y
f_drawRect_loop_y
	COMP	f_drawRect_max_y
	JGT	f_drawRect_return
	LDA	f_drawRect_min_x
	STA	f_px_x
f_drawRect_loop_x
		COMP	f_drawRect_max_x
		JGT	f_drawRect_loop_x_end
		.
		LDA	f_drawRect_img
		COMP	#0
		JEQ	f_drawRect_draw_pixel
		. read dvd icon color
		LDX	f_drawRect_img
		ADDR	T, X
		LDCH	0, X
		AND	f_drawRect_color
		STA	f_px_color
		.
		J	f_drawRect_draw_pixel_
f_drawRect_draw_pixel
		LDA	f_drawRect_color
		STA	f_px_color
f_drawRect_draw_pixel_
		JSUB	f_px
		.
		LDA	#1
		ADDR	A, T
		LDA	f_px_x
		ADD	#1
		STA	f_px_x
		J	f_drawRect_loop_x
f_drawRect_loop_x_end
	LDA	f_px_y
	ADD	#1
	STA	f_px_y
	J	f_drawRect_loop_y
	..........
f_drawRect_return
	LDA	f_drawRect_stack_A
	LDS	f_drawRect_stack_S
	LDT	f_drawRect_stack_T
	LDX	f_drawRect_stack_X
	LDL	f_drawRect_stack_L
	RSUB
................................................................
f_nextColor . f(color*)
	STA	f_nextColor_stack_A
	STX	f_nextColor_stack_X
	..........
	LDA	f_nextColor_i
	ADD	#1
	COMP	#f_nextColor_colors_count
	JLT	f_nextColor_skipmod
	LDA	#0
f_nextColor_skipmod
	STA	f_nextColor_i
	ADD	#f_nextColor_colors
	RMO	A, X
	LDCH	0, X
	STCH	@f_nextColor_color
	..........
	LDA	f_nextColor_stack_A
	LDX	f_nextColor_stack_X
	RSUB
................................................................
f_inflate . 
	STA	f_inflate_stack_A
	STS	f_inflate_stack_S
	STT	f_inflate_stack_T
	STX	f_inflate_stack_X
	..........
	LDA	#dvd_w
	MUL	#dvd_h
	DIV	#8
	RMO	A, T
	.
	LDA	#0
	STA	f_inflate_i
f_inflate_loop_i
	COMPR	A, T
	JEQ	f_inflate_loop_i_
	. load byte
	LDA	#dvd_compressed
	ADD	f_inflate_i
	RMO	A, X
	LDCH	0, X
	RMO	A, S
	. prepare location
	LDA	f_inflate_i
	MUL	#8
	ADD	#dvd
	ADD	#7
	RMO	A, X
	. loop 8x
	LDA	#0
	STA	f_inflate_ii
f_inflate_loop_ii
		COMP	#8
		JEQ	f_inflate_loop_ii_
		.
		RMO	S, A
		AND	#1
		MUL	#0xFF
		STCH	0, X
		.
		SHIFTR	S, 1
		LDA	#1
		SUBR	A, X
		.
		LDA	f_inflate_ii
		ADD	#1
		STA	f_inflate_ii
		J	f_inflate_loop_ii
f_inflate_loop_ii_
	LDA	f_inflate_i
	ADD	#1
	STA	f_inflate_i
	J	f_inflate_loop_i
f_inflate_loop_i_
	..........
	LDA	f_inflate_stack_A
	LDS	f_inflate_stack_S
	LDT	f_inflate_stack_T
	LDX	f_inflate_stack_X
	RSUB
................................................................
halt	J	halt
	END	prog
break	WORD	0
.==============================================================.
. f_main()
f_main_img	RESW	1
................................................................
. f_px(x, y, color)
f_px_x		RESW	1
f_px_y		RESW	1
f_px_color	RESW	1

f_px_addr	RESW	1
f_px_stack_A	RESW	1
................................................................
. f_clampXY(x1*, x2*, y1*, y2*)
f_clampXY_x1		RESW	1
f_clampXY_x2		RESW	1
f_clampXY_y1		RESW	1
f_clampXY_y2		RESW	1

f_clampXY_stack_A	RESW	1
................................................................
. f_drawRect(rect, color)
. f_drawRect(rect, color, img*, img_w, img_h)
f_drawRect_rect		RESW	4
f_drawRect_color	RESW	1
f_drawRect_img		RESW	1

f_drawRect_min_x	RESW	1
f_drawRect_max_x	RESW	1
f_drawRect_min_y	RESW	1
f_drawRect_max_y	RESW	1

f_drawRect_stack_A	RESW	1
f_drawRect_stack_S	RESW	1
f_drawRect_stack_T	RESW	1
f_drawRect_stack_X	RESW	1
f_drawRect_stack_L	RESW	1
................................................................
. f_inflate()
f_inflate_i	RESW	1
f_inflate_ii	RESW	1

f_inflate_stack_A	RESW	1
f_inflate_stack_S	RESW	1
f_inflate_stack_T	RESW	1
f_inflate_stack_X	RESW	1
................................................................
. f_nextColor(color*)
f_nextColor_color	RESW	1

f_nextColor_i		WORD	0
f_nextColor_colors
	.	0biirrggbb
	BYTE	0b11000011
	BYTE	0b11001000
	BYTE	0b11001010
	BYTE	0b11001011
	BYTE	0b11001100
	BYTE	0b11001110
	BYTE	0b11001111
	BYTE	0b11100000
	BYTE	0b11100010
	BYTE	0b11100011
	BYTE	0b11101000
	BYTE	0b11101010
	BYTE	0b11101011
	BYTE	0b11101100
	BYTE	0b11101110
	BYTE	0b11101111
	BYTE	0b11110000
	BYTE	0b11110010
	BYTE	0b11110011
	BYTE	0b11111000
	BYTE	0b11111010
	BYTE	0b11111011
	BYTE	0b11111100
	BYTE	0b11111110
	BYTE	0b11111111
f_nextColor_colors_LAST		EQU	*
f_nextColor_colors_count	EQU	f_nextColor_colors_LAST - f_nextColor_colors

f_nextColor_stack_A	RESW	1
f_nextColor_stack_X	RESW	1
................................................................
. CONSTATS
n_m1	WORD	-1
................................................................
. COLORS
ci_0	EQU	0b00000000
ci_1	EQU	0b01000000
ci_2	EQU	0b10000000
ci_3	EQU	0b11000000

c_red	EQU	0b00110000
c_green	EQU	0b00001100
c_blue	EQU	0b00000011

red	EQU	ci_3 + c_red
green	EQU	ci_3 + c_green
blue	EQU	ci_3 + c_blue
white	EQU	ci_3 + red + green + blue
................................................................
dvd_w		EQU	32
dvd_h		EQU	13
dvd		RESB	512
dvd_compressed	BYTE	0b00011111
		BYTE	0b11111110
		BYTE	0b00011111
		BYTE	0b11111100
	
		BYTE	0b00000000
		BYTE	0b11111110
		BYTE	0b00111100
		BYTE	0b00011110
	
		BYTE	0b00011100
		BYTE	0b01110110
		BYTE	0b00111111
		BYTE	0b00001110
	
		BYTE	0b00111000
		BYTE	0b01110111
		BYTE	0b01110111
		BYTE	0b00001110
	
		BYTE	0b00111000
		BYTE	0b01110111
		BYTE	0b11100111
		BYTE	0b00011110
	
		BYTE	0b00111001
		BYTE	0b11100011
		BYTE	0b11000111
		BYTE	0b01111100
	
		BYTE	0b00111111
		BYTE	0b10000011
		BYTE	0b10001111
		BYTE	0b11110000
	
		BYTE	0b00000000
		BYTE	0b00000011
		BYTE	0b00000000
		BYTE	0b00000000
	
		BYTE	0b00000000
		BYTE	0b00000000
		BYTE	0b00000000
		BYTE	0b00000000
	
		BYTE	0b00000001
		BYTE	0b11111111
		BYTE	0b11111111
		BYTE	0b00000000
	
		BYTE	0b01111111
		BYTE	0b11111111
		BYTE	0b11111111
		BYTE	0b11111000
	
		BYTE	0b01111111
		BYTE	0b11100000
		BYTE	0b00111111
		BYTE	0b11111000
	
		BYTE	0b00001111
		BYTE	0b11111111
		BYTE	0b11111111
		BYTE	0b11000000
................................................................
. PROGRAM PARAMETERS
screen_address	EQU	0x0A000
screen_w	EQU	64
screen_h	EQU	64

dx		WORD	1	. object x speed (multiplier)
dy		WORD	1	. object y speed (multiplier)

sync		EQU	120000	. ticks to wait each frame
useDVD		EQU	1
width		EQU	2	. rectangle width (if useDVD = 0)
height		EQU	2	. rectangle height (if useDVD = 0)
................................................................