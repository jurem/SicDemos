. rc for rotating cube
rc			START	0
			JSUB	variable_init
			J	main

halt			J	halt


. main rutine
main			JSUB	memset
if_pause		JSUB	handle_input
			LDA	pause_flag
			COMP	#1
			JEQ	if_pause

			JSUB	calc_sins_and_coss
main_loop		LDF	f_half_cube_width
			MULF	f_neg_one
			STF	fy			. fx and fy is used as loop variables
outer_loop		LDF	f_half_cube_width
			MULF	f_neg_one
			STF	fx
inner_loop		LDF	fx
			STF	f_cube_x
			LDF	fy
			STF	f_cube_y		. f_cube_y's value
			LDF	f_half_cube_width
			MULF	f_neg_one
			STF	f_cube_z
			LDCH	color_f			. f side cube color
			STCH	cur_color
			JSUB	calc_cube_surface	. f side cube

			LDF	fx
			STF	f_cube_x
			LDF	fy
			STF	f_cube_y
			LDF	f_half_cube_width
			STF	f_cube_z
			LDCH	color_b			. b side cube color
			STCH	cur_color
			JSUB	calc_cube_surface	. b side cube

			LDF	f_half_cube_width
			MULF	f_neg_one
			STF	f_cube_x
			LDF	fy
			STF	f_cube_y
			LDF	fx
			STF	f_cube_z
			LDCH	color_l			. l side color
			STCH	cur_color
			JSUB	calc_cube_surface	. l side cube

			LDF	f_half_cube_width
			STF	f_cube_x
			LDF	fy
			STF	f_cube_y
			LDF	fx
			STF	f_cube_z
			LDCH	color_r			. r side color
			STCH	cur_color
			JSUB	calc_cube_surface	. r side cube

			LDF	fx
			STF	f_cube_x
			LDF	f_half_cube_width
			MULF	f_neg_one
			STF	f_cube_y
			LDF	fy
			STF	f_cube_z
			LDCH	color_d			. d side color
			STCH	cur_color
			JSUB	calc_cube_surface	. d side cube

			LDF	fx
			STF	f_cube_x
			LDF	f_half_cube_width
			STF	f_cube_y
			LDF	fy
			STF	f_cube_z
			LDCH	color_u			. u side color
			STCH	cur_color
			JSUB	calc_cube_surface	. u side cube

			LDF	#5
			DIVF	#10
			ADDF	fx
			STF	fx			. fx += 0.5
			COMPF	f_inner_loop_condition	. fx <= cube_width/2
			JLT	inner_loop
			JEQ	inner_loop

			LDF	#5
			DIVF	#10
			ADDF	fy
			STF	fy			. fy += 0.5
			COMPF	f_outer_loop_condition	. fy <= cube_width/2 
			JLT	outer_loop
			JEQ	outer_loop
			JSUB	write_to_screen

. add angle to rotate
angle_a_add		LDF	f_rotate_speed_for_x
			ADDF	f_angle_a
			COMPF	pi
			JLT	angle_b_add
			SUBF	pi
			SUBF	pi
angle_b_add		STF	f_angle_a
			LDF	f_rotate_speed_for_y
			ADDF	f_angle_b
			COMPF	pi
			JLT	angle_c_add
			SUBF	pi
			SUBF	pi
angle_c_add		STF	f_angle_b
			LDF	f_rotate_speed_for_z
			ADDF	f_angle_c
			COMPF	pi
			JLT	return_to_main
			SUBF	pi
			SUBF	pi
return_to_main		STF	f_angle_c
			J	main


write_to_screen		LDX	#0
wts_for			LDT	screen_start
			LDCH	colors, X		. load the color to write
			ADDR	X, T
			STT	index
			STCH	@index

			+TIX	#SIZE
			JLT	wts_for

			RSUB

.==================================================

. memset to zero, both f_check_front_z and colors
memset			LDX	#0
			LDT	#6
			LDF	#0
			CLEAR	A
			LDCH	color_bg
memset_for		STCH	colors, X		. write color_bg to colors
			MULR	T, X
			STF	f_check_front_z, X	. write 0 to f_check_front_z
			DIVR	T, X
			+TIX	#SIZE
			JLT	memset_for
			RSUB

. Handle input subrutine
handle_input		+LDCH	@keyboard_addr
			STCH	keyboard_read_temp
			CLEAR	A
			+STCH	@keyboard_addr		. Clear the content of keyboard_addr
			LDCH	keyboard_read_temp

			. if not changing, return
			COMP	#0
			JEQ	handle_input_return

			. if it's SPACE
			COMP	#32
			JEQ	toggle_pause

			. if it's q
			COMP	#81
			JEQ	halt

			. if it's a
			COMP	#65
			JEQ	inc_x_speed

			. if it's s
			COMP	#83
			JEQ	inc_y_speed

			. if it's d
			COMP	#68
			JEQ	inc_z_speed

			. if it's z
			COMP	#90
			JEQ	dec_x_speed

			. if it's x
			COMP	#88
			JEQ	dec_y_speed

			. if it's c
			COMP	#67
			JEQ	dec_z_speed

			J	handle_input_return
toggle_pause		LDA	pause_flag
			COMP	#0
			JEQ	set_to_one		. if equal 0, then set to 1
			LDA	#0
			STA	pause_flag		. else set to 0
			J	handle_input_return
set_to_one		LDA	#1
			STA	pause_flag
			J	handle_input_return
inc_x_speed		LDF	#1
			DIVF	#100
			ADDF	f_rotate_speed_for_x
			STF	f_rotate_speed_for_x
			J	handle_input_return
inc_y_speed		LDF	#1
			DIVF	#100
			ADDF	f_rotate_speed_for_y
			STF	f_rotate_speed_for_y
			J	handle_input_return
inc_z_speed		LDF	#1
			DIVF	#100
			ADDF	f_rotate_speed_for_z
			STF	f_rotate_speed_for_z
			J	handle_input_return
dec_x_speed		LDF	#1
			DIVF	#100
			MULF	f_neg_one
			ADDF	f_rotate_speed_for_x
			STF	f_rotate_speed_for_x
			J	handle_input_return
dec_y_speed		LDF	#1
			DIVF	#100
			MULF	f_neg_one
			ADDF	f_rotate_speed_for_y
			STF	f_rotate_speed_for_y
			J	handle_input_return
dec_z_speed		LDF	#1
			DIVF	#100
			MULF	f_neg_one
			ADDF	f_rotate_speed_for_z
			STF	f_rotate_speed_for_z
			J	handle_input_return
handle_input_return	RSUB

. subrutine for calculate cube surface
calc_cube_surface	STL	temp_L
			JSUB	calculate_x		. it will read f_cube_{x, y, z}, and calc them
			LDF	f_result
			STF	f_cube_x_result		. calc f_cube_x_result's value
			FIX
			STA	i_cube_x_result		. store it to i_cube_x_result

			JSUB	calculate_y
			LDF	f_result
			STF	f_cube_y_result		. calc f_cube_y_result's value
			FIX
			STA	i_cube_y_result		. store it to i_cube_y_result

			JSUB	calculate_z
			LDF	f_result
			STF	f_cube_z_result		. calc f_cube_z_result's value
			FIX
			STA	i_cube_z_result		. store it to i_cube_z_result

			. Calculate the position on the screen
			LDA	opy
			SUB	i_cube_y_result
			+MUL	#SCREEN_COLS
			ADD	opx
			ADD	i_cube_x_result		. index = (opy-y)*SCREEN_COLS + opx-(-x);

			STA	index
			LDX	index
			LDT	#6
			MULR	T, X			. multiply 6 because f_check_front_z's type is float
			LDF	f_check_front_z, X
			COMPF	#0			. if (check_front_symbols[position]==0)
			JEQ	eq_0_or_gt_z
			COMPF	f_cube_z_result		. else (check_front_symbols[position] > z)
			JGT	eq_0_or_gt_z
			J	calc_surface_return
eq_0_or_gt_z		LDF	f_cube_z_result
			STF	f_check_front_z, X
			LDX	index
			LDCH	cur_color
			STCH	colors, X		. write color to colors matrix
calc_surface_return	LDL	temp_L
			RSUB

. subrutine for pre-calculate sins and coss to f_angle_{a, b, c}
calc_sins_and_coss	STL	temp_L			. store L to temp_L
			. sins
			LDF	f_angle_a
			STF	f_tri
			JSUB	sin_func		. calc sin(f_angle_a),
			LDF	f_result
			STF	sin_f_angle_a		. store it to sin_f_angle_a

			LDF	f_angle_b
			STF	f_tri
			JSUB	sin_func		. calc sin(f_angle_b),
			LDF	f_result
			STF	sin_f_angle_b		. store it to sin_f_angle_b

			LDF	f_angle_c
			STF	f_tri
			JSUB	sin_func		. calc sin(f_angle_c),
			LDF	f_result
			STF	sin_f_angle_c		. store it to sin_f_angle_c

			. coss
			LDF	f_angle_a
			STF	f_tri
			JSUB	cos_func		. calc cos(f_angle_a),
			LDF	f_result
			STF	cos_f_angle_a		. store it to cos_f_angle_a

			LDF	f_angle_b
			STF	f_tri
			JSUB	cos_func		. calc cos(f_angle_b),
			LDF	f_result
			STF	cos_f_angle_b		. store it to cos_f_angle_b

			LDF	f_angle_c
			STF	f_tri
			JSUB	cos_func		. calc cos(f_angle_c),
			LDF	f_result
			STF	cos_f_angle_c		. store it to cos_f_angle_c

			LDL	temp_L			. put temp_L to register L
			RSUB

calculate_x		LDF	f_cube_x
			MULF	cos_f_angle_b
			MULF	cos_f_angle_c
			STF	f_term_1		. f_term_1 = x*cos(b)*cos(c)
			LDF	f_cube_y
			MULF	cos_f_angle_b
			MULF	sin_f_angle_c
			STF	f_term_2		. f_term_2 = y*cos(b)*sin(c)
			LDF	f_cube_z
			MULF	sin_f_angle_b
			STF	f_term_3		. f_term_3 = z*sin(b)

			LDF	f_term_1
			SUBF	f_term_2
			ADDF	f_term_3
			STF	f_result
			RSUB

calculate_y		LDF	sin_f_angle_a
			MULF	sin_f_angle_b
			MULF	cos_f_angle_c
			STF	f_temp			. f_temp = sin(a)*sin(b)*cos(c)
			LDF	cos_f_angle_a
			MULF	sin_f_angle_c		. F = cos(a)*sin(c)
			ADDF	f_temp			. F = F + f_temp
			MULF	f_cube_x	
			STF	f_term_1		. f_term_1 = x*(sin(a)*sin(b)*cos(c) + cos(a)*sin(c))
			LDF	cos_f_angle_a
			MULF	cos_f_angle_c
			STF	f_temp			. f_temp = cos(a)*cos(c)
			LDF	sin_f_angle_a
			MULF	sin_f_angle_b
			MULF	sin_f_angle_c
			STF	f_temp_2		. f_temp_2 = sin(a)*sin(b)*sin(c)
			LDF	f_temp
			SUBF	f_temp_2
			MULF	f_cube_y
			STF	f_term_2		. f_term_2 = y*(cos(a)*cos(c)- sin(a)*sin(b)*sin(c))
			LDF	f_cube_z
			MULF	sin_f_angle_a
			MULF	cos_f_angle_b
			STF	f_term_3		. f_term_3 = z*sin(a)*cos(b)

			LDF	f_term_1
			ADDF	f_term_2
			SUBF	f_term_3
			STF	f_result		. 
			RSUB

calculate_z		LDF	sin_f_angle_a
			MULF	sin_f_angle_c
			STF	f_temp			. f_temp = sin(a)*sin(c)
			LDF	cos_f_angle_a
			MULF	sin_f_angle_b
			MULF	cos_f_angle_c
			STF	f_temp_2		. f_temp_2 = cos(a)*sin(b)*cos(c)
			LDF	f_temp
			SUBF	f_temp_2
			MULF	f_cube_x
			STF	f_term_1		. f_term_1 = (sin(a)*sin(c) - cos(a)*sin(b)*cos(c))*x
			LDF	cos_f_angle_a
			MULF	sin_f_angle_b
			MULF	sin_f_angle_c
			STF	f_temp			. f_temp = cos(a)*sin(b)*sin(c)
			LDF	sin_f_angle_a
			MULF	cos_f_angle_c		. F = sin(a)*cos(c)
			ADDF	f_temp			. F = F + f_temp
			MULF	f_cube_y		. F = (F + f_temp) * y
			STF	f_term_2		. f_term_2 = F
			LDF	f_cube_z
			MULF	cos_f_angle_a
			MULF	cos_f_angle_b
			STF	f_term_3		. f_term_3 = cos(a)*cos(b)*z

			LDF	f_term_1
			ADDF	f_term_2
			ADDF	f_term_3
			STF	f_result		. 
			RSUB

sin_func		LDF	f_tri
			MULF	f_tri		. F = f_tri ^ 2
			STF	f_sqare_x	. f_sqare_x = f_tri ^ 2
			LDF	f_tri
			MULF	f_sqare_x	. F = f_tri ^ 3
			STF	f_temp		. f_temp = f_tri ^ 3
			DIVF	#6		. 3! = 6
			STF	f_term_2	. f_term_2 = (f_tri ^ 3) / (3!)
			LDF	f_temp
			MULF	f_sqare_x	. F = f_tri ^ 5
			STF	f_temp		. f_temp = f_tri ^ 5
			DIVF	#120		. 5! = 120
			STF	f_term_3	. f_term_3 = (f_tri ^ 5) / (5!)
			LDF	f_temp
			MULF	f_sqare_x	. F = f_tri ^ 7
			STF	f_temp
			+DIVF	#5040		. 5040 = 7!
			STF	f_term_4	. f_term_4 = (f_tri ^ 7) / (7!)
			LDF	f_temp
			MULF	f_sqare_x
			STF	f_temp		. f_temp = f_tri ^ 9
			+DIVF	#362880		. 362880 = 9!
			STF	f_term_5	. f_term_5 = (f_tri ^ 9) / (9!)
			LDF	f_temp
			MULF	f_sqare_x
			STF	f_temp		. f_temp = f_tri ^ 11
			+DIVF	#362880
			DIVF	#110		. 362880 * 110 = 11!
			STF	f_term_6	. f_term_6 = (f_tri ^ 11) / (11!)
			LDF	f_temp
			MULF	f_sqare_x
			STF	f_temp		. f_temp = f_tri ^ 13
			+DIVF	#362880
			DIVF	#110
			DIVF	#156		. 11! * 12 * 13 = 13!
			STF	f_term_7	. f_term_7 = (f_tri ^ 13) / (13!)

			LDF	f_tri
			SUBF	f_term_2
			ADDF	f_term_3
			SUBF	f_term_4
			ADDF	f_term_5
			SUBF	f_term_6
			ADDF	f_term_7
			STF	f_result	. store the result to f_result
			RSUB

cos_func		LDF	f_tri
			MULF	f_tri		. F = f_tri ^ 2
			STF	f_sqare_x	. f_sqare_x = f_tri ^ 2
			DIVF	#2
			STF	f_term_2	. f_term_2 = (f_tri ^ 2) / (2!)
			LDF	f_sqare_x
			MULF	f_sqare_x	. F = f_^ 4
			STF	f_temp		. f_temp = f ^ 4
			DIVF	#24		. 4!
			STF	f_term_3	. f_term_3 = (f_tri ^ 4) / (4!)
			LDF	f_temp
			MULF	f_sqare_x	. F = f_tri ^ 6
			STF	f_temp		. f_temp = f ^ 6
			DIVF	#720		. 6!
			STF	f_term_4	. f_term_4 = (f_tri ^ 6) / (6!)
			LDF	f_temp
			MULF	f_sqare_x	. F = f_tri ^ 8
			STF	f_temp		. f_temp = f_tri ^ 8
			+DIVF	#40320		. 40320 = 8!
			STF	f_term_5	. f_term_5 = (f_tri ^ 8) / (8!)
			LDF	f_temp
			MULF	f_sqare_x
			STF	f_temp		. f_temp = f_tri ^ 10
			+DIVF	#40320
			DIVF	#90		. 40320 * 90 = 10!
			STF	f_term_6	. f_term_6 = (f_tri ^ 10) / (10!)
			LDF	f_temp
			MULF	f_sqare_x
			STF	f_temp		. f_temp = f_tri ^ 12
			+DIVF	#40320
			DIVF	#90
			DIVF	#132		. 10! * 11 * 12 = 12!
			STF	f_term_7	. f_term_7 = (f_tri ^ 12) / (12!)

			LDF	#1
			SUBF	f_term_2
			ADDF	f_term_3
			SUBF	f_term_4
			ADDF	f_term_5
			SUBF	f_term_6
			ADDF	f_term_7
			STF	f_result	. store the result to f_result
			RSUB


variable_init		CLEAR	A
			. Create constants
			FLOAT
			. set f_angle_* to 0
			STF	f_angle_a
			STF	f_angle_b
			STF	f_angle_c
			. create a floating negative 1
			SUBF	#1
			STF	f_neg_one
			. create a pi
			LDF	#314
			DIVF	#100
			STF	pi

			. Initialize variables
			. set rotate_speed to
			. 0.05, 0.05, 0.01
			. to f_rotate_speed_for_{x, y, z}
			LDF	#5
			DIVF	#100
			STF	f_rotate_speed_for_x
			STF	f_rotate_speed_for_y
			DIVF	#5
			STF	f_rotate_speed_for_z

			. set cube width to custom value
			LDF	#CUBE_WIDTH
			DIVF	#2
			STF	f_half_cube_width

			. set op{x, y} to half columns and rows
			LDA	#SCREEN_ROWS
			DIV	#2
			STA	opy
			LDA	#SCREEN_COLS
			DIV	#2
			STA	opx

			. set loop condition
			LDF	#CUBE_WIDTH
			DIVF	#2
			STF	f_outer_loop_condition

			LDF	#CUBE_WIDTH
			DIVF	#2
			STF	f_inner_loop_condition

			. if set to pause at beginning
			LDA	#PAUSE_AT_BEGIN
			STA	pause_flag
			RSUB


.===================================================
.===== Program parameters =====
.===== customizable values =====
screen_start		WORD	X'0A0000'
keyboard_addr		WORD	X'0C0000'

. It's better to let the rows and cols the same value
. See README.md
SCREEN_ROWS		EQU	128  . or 176
SCREEN_COLS		EQU	128  . or 176

CUBE_WIDTH		EQU	48  . or 96

. Boolean, 1 to pause at beginning
PAUSE_AT_BEGIN		EQU	0

. colors (0biirrggbb, or 0x..)
. see https://jurem.github.io/SicTools/documentation/simulator#color-graphical-screen
color_bg		BYTE	0x22	. very black purple
color_f			BYTE	0xCC	. green
color_b			BYTE	0xD7	. blue
color_r			BYTE	0xF0	. red
color_l			BYTE	0xF8	. orange
color_u			BYTE	0xFF	. white
color_d			BYTE	0xFC	. yellow


.===================================================
.===== Constants =====
. Screen size
SIZE			EQU	SCREEN_COLS * SCREEN_ROWS

. negative one in integer and float
i_neg_one		WORD	-1
f_neg_one		RESF	1

. pi is type float
pi			RESF	1

. original point x and y
. o(x, y) is the center of the graphical screen
opx			RESW	1
opy			RESW	1


.===================================================
.===== Variables =====
. index of the array (matrix)
index			RESW	1

. variable that stores the current color to print
cur_color		RESB	1

keyboard_read_temp	RESB	1
pause_flag		RESW	1

. Temporary variables
. temp_Ls store the link info of the last subrutine
temp_L			RESW	1

. variables that stores the coordinate
. of the surface after rotation, in type integer
. (the integer type of f_cube_{x,y,z}_result)
i_cube_x_result		RESW	1
i_cube_y_result		RESW	1
i_cube_z_result		RESW	1

. Float number variables
f_half_cube_width	RESF	1


. coordinate for calculating cube surface
f_cube_x		RESF	1
f_cube_y		RESF	1
f_cube_z		RESF	1
. coordinate after calculating cube surface
f_cube_x_result		RESF	1
f_cube_y_result		RESF	1
f_cube_z_result		RESF	1

. Angle
. current rotation angle
f_angle_a		RESF	1
f_angle_b		RESF	1
f_angle_c		RESF	1

f_rotate_speed_for_x	RESF	1
f_rotate_speed_for_y	RESF	1
f_rotate_speed_for_z	RESF	1

. use for pre-calculation
. the result of sin( f_angle_{a, b, c} )
sin_f_angle_a		RESF	1
sin_f_angle_b		RESF	1
sin_f_angle_c		RESF	1
. the result of cos( f_angle_{a, b, c} )
cos_f_angle_a		RESF	1
cos_f_angle_b		RESF	1
cos_f_angle_c		RESF	1

. f_tri used only in sin and cos calculation
f_tri			RESF	1
. Variables for calculation
f_temp			RESF	1
f_temp_2		RESF	1
f_sqare_x		RESF	1
f_term_1		RESF	1	. 
f_term_2		RESF	1	. 多項式第二項
f_term_3		RESF	1	. 多項式第三項
f_term_4		RESF	1	. 多項式第四項
f_term_5		RESF	1	. 多項式第五項
f_term_6		RESF	1	. 多項式第六項
f_term_7		RESF	1	. 多項式第七項
f_result		RESF	1

. fx and fy is used as loop variables
fx			RESF	1
fy			RESF	1
f_outer_loop_condition	RESF	1
f_inner_loop_condition	RESF	1

. array (matrices) that stores values of colors and z positions
colors			RESB	SIZE
. type float
f_check_front_z		RESF	SIZE

			END	rc