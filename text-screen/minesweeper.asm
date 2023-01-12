prog	START	0

	JSUB	stack_init
	JSUB	txt_init
	JSUB	field_init
	JSUB	rnd_init
	JSUB	place_mines
	
	JSUB	cursor_init
	LDA	cursor_pos
	STA	cursor_pos_new
	JSUB	cursor_update
	JSUB	actions_init

	J	user_input

halt	J	halt
	END	prog

.
.	BEGIN KEYBOARD
.

. value of kbd in previous iteration
. (to check for change in input)
kbd_prev_val
	RESW	1
. address of the keyboard byte
kbd_addr
	WORD	X'00C000'

. wait for user input
. upon a valid input, execute the right subroutines
user_input
	LDA	#0
	STCH	@kbd_addr		. clear any previous values
	STA	kbd_prev_val
user_input_loop
	LDCH	@kbd_addr
	COMP	kbd_prev_val
	JEQ	user_input_loop
	. user has made an input
	RMO	A, X

	LDCH	char_up
	COMPR	A, X
	JEQ	move_up

	LDCH	char_down
	COMPR	A, X
	JEQ	move_down

	LDCH	char_left
	COMPR	A, X
	JEQ	move_left

	LDCH	char_right
	COMPR	A, X
	JEQ	move_right

	LDCH	char_flag
	COMPR	A, X
	JEQ	plot_flag

	LDCH	char_select
	COMPR	A, X
	JEQ	plot_select_pre

	. user made an invalid input
	STX	kbd_prev_val
	J	user_input_loop

.
.	END KEYBOARD
.

.
.	BEGIN RND ARRAY
.

. array with "random" bytes
rnd_arr
	RESB	rnd_size

. initialize array using keyboard input
rnd_init
	. get starting value of keyboard
	LDA	#0
	STCH	@kbd_addr
	STA	kbd_prev_val
	LDX	#0
	LDA	#0
	LDT	#0
. check for change in the input
kbd_check_change
	LDCH	@kbd_addr
	COMP	kbd_prev_val
	JEQ	kbd_check_change	. no change -> loop

	STA	kbd_prev_val		. change -> log to array

	LDCH	char_rnd_min
	COMP	kbd_prev_val		. check lower bound
	JGT	kbd_check_change

	LDCH	char_rnd_max
	COMP	kbd_prev_val		. check higher bound
	JLT	kbd_check_change

	LDT	char_rnd_min		. bytes will get left padded
	SHIFTR	T, 16			. shift 4 nibbles right
	LDA	kbd_prev_val
	SUBR	T, A			. subtract lower bound

	STCH	rnd_arr, X
	TIX	#rnd_size		. reached end of array
	JEQ	rnd_init_end
	J	kbd_check_change
rnd_init_end
	RSUB

.
.	END RND ARRAY
.

.
.	BEGIN TEXTUAL SCREEN
.

txt_height		. 2 for borders
	EQU	txt_rows + 2
txt_width		. 2 for borders
	EQU	txt_cols + 2
txt_len			. number of bytes the screen occupies
	RESW	1
txt_ptr			. address of a particular character on screen
	RESW	1
txt_end			. address of last byte on screen
	RESW	1
txt_addr
	WORD	X'00B800'

. initialize textual screen
txt_init
	. push L to stack
	STL	@sp
	JSUB	push

	. initialize txt_len
	LDA	#txt_width
	MUL	#txt_height
	STA	txt_len

	. initialize txt_ptr
	LDA	txt_addr
	STA	txt_ptr

	. initialize txt_end
	LDA	txt_addr
	ADD	txt_len
	STA	txt_end

	JSUB	txt_clear
	JSUB	draw_border_horizontal
	JSUB	draw_border_vertical
	JSUB	draw_border_horizontal

	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. set all bytes on textual screen to 0
txt_clear
	. push L to stack
	STL	@sp
	JSUB	push
	. push txt_ptr to stack
	LDA	txt_ptr
	STA	@sp
	JSUB	push
	. set txt_ptr to start of textscreen
	LDA	txt_addr
	STA	txt_ptr
txt_clear_loop
	LDA	#0
	STCH	@txt_ptr

	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr

	COMP	txt_end
	JEQ	txt_clear_end
	J	txt_clear_loop

txt_clear_end
	. pop txt_ptr from stack
	JSUB	pop
	LDA	@sp
	STA	txt_ptr
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. print +---------+ to textual screen
draw_border_horizontal
	LDCH	char_corner
	STCH	@txt_ptr
	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr

	LDX	#0
draw_border_horizontal_loop
	LDCH	char_border_horizontal
	STCH	@txt_ptr
	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr
	TIX	#txt_cols
	JEQ	draw_border_horizontal_end
	J	draw_border_horizontal_loop

draw_border_horizontal_end
	LDCH	char_corner
	STCH	@txt_ptr
	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr
	RSUB

. print |         | to textual screen
draw_border_vertical_one
	. push L to stack
	STL	@sp
	JSUB	push
	. push X to stack
	STX	@sp
	JSUB	push
	. print single pipe
	LDCH	char_border_vertical
	STCH	@txt_ptr
	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr

	. print space txt_cls times
	LDX	#0
draw_border_vertical_one_loop
	LDCH	char_unopened
	STCH	@txt_ptr
	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr
	TIX	#txt_cols
	JEQ	draw_border_vertical_one_end
	J	draw_border_vertical_one_loop

draw_border_vertical_one_end
	. print single pipe
	LDCH	char_border_vertical
	STCH	@txt_ptr
	LDA	txt_ptr
	ADD	#1
	STA	txt_ptr
	. pop X from stack
	JSUB	pop
	LDX	@sp
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB


. print |         | txt_rows times to textual screen
draw_border_vertical
	. push L to stack
	STL	@sp
	JSUB	push
	LDX	#0
draw_border_vertical_loop
	JSUB	draw_border_vertical_one
	TIX	#txt_rows
	JEQ	draw_border_vertical_end
	J	draw_border_vertical_loop
draw_border_vertical_end
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

.
.	END TEXTUAL SCREEN
.

.
.	BEGIN FIELD
.

. cols and rows can be reused from the textscreen section
. number of plots in field
field_len
	EQU	txt_cols * txt_rows
. address of first plot
field_addr
	RESW	field_len
. address of last mine
field_end
	RESW	1
. address of particular plot in the field
field_ptr
	RESW	1
mine_count
	RESW	1
. column of field_ptr in the field
. used in count_neighbor_mines to avoid "wrapping"
field_col_index
	RESW	1

. A |-> (A * 21 + 17) mod len
. because why not
hash	. push L to stack
	STL	@sp
	JSUB	push
	. push X to stack
	STX	@sp
	JSUB	push
	
	MUL	#21
	ADD	#17
	RMO	A, X

	DIV	#field_len
	MUL	#field_len
	SUBR	A, X
	RMO	X, A

	. pop X from stack
	JSUB	pop
	LDX	@sp
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. try to place single mine on plot A
. if there's already one there, try the next one recursively
place_mine
	. push L to stack
	STL	@sp
	JSUB	push
	. push X to stack
	STX	@sp
	JSUB	push

	RMO	A, X
	J	place_mine_loop

. X |-> X mod field_len
place_mine_mod
	RMO	X, A
	DIV	#field_len
	MUL	#field_len
	SUBR	A, X

place_mine_loop
	LDA	field_addr, X
	COMP	#0
	JEQ	place_mine_end	. found a plot without a mine
	TIX	field_len	. go to the next plot (modulo principle)
	JGT	place_mine_mod
	J	place_mine_loop

place_mine_end
	LDA	#1		. actually place the mine now
	STA	field_addr, X
	. pop X from stack
	JSUB	pop
	LDX	@sp
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. use rnd_arr to place mines
place_mines
	. push L to stack
	STL	@sp
	JSUB	push

	LDA	#0
	LDX 	#0
place_mines_loop
	LDCH	rnd_arr, X
	JSUB	hash		. spread values over the field
	JSUB	place_mine	. place mine on plot A (or first free one)
	TIX	#rnd_size	. check if all mines have been placed
	JEQ	place_mines_end
	J	place_mines_loop

place_mines_end
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. check if the address at A is within bounds
. and if it points to a mine -> increment mine_count
check_mine
	. push L to stack
	STL	@sp
	JSUB	push
	. push A to stack
	STA	@sp
	JSUB	push
	. push field_ptr to stack
	LDX	field_ptr
	STX	@sp
	JSUB	push

	COMP	#field_addr
	JLT	check_mine_end	. outside bounds
	COMP	field_end
	JGT	check_mine_end	. outside bounds

	STA	field_ptr
	LDA	#0
	LDCH	@field_ptr
	COMP	#0
	JEQ	check_mine_end	. no mine at the plot

	. the plot is within bounds & contains a mine
	LDA	mine_count
	ADD	#1
	STA	mine_count	. increment mine_count

check_mine_end
	. pop field_ptr from stack
	JSUB	pop	
	LDX	@sp
	STX	field_ptr
	. pop A from stack
	JSUB	pop
	LDA	@sp
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. count the number of mines around the plot
. that field_ptr is pointing to
. and save it to mine_count
count_neighbor_mines
	. push L to stack
	STL	@sp
	JSUB	push

	LDA	#0
	STA	mine_count	. reset counter

	. field_ptr -> column index
	. (field_ptr - #field_addr) mod #txt_cols
	LDA	field_ptr
	SUB	#field_addr
	RMO	A, X
	DIV	#txt_cols
	MUL	#txt_cols
	SUBR	A, X
	RMO	X, A
	STA	field_col_index

	. skip left column if current col. index is 0
	. LDA	field_col_index
	COMP	#0
	JEQ	count_neighbor_mines_centre

count_neighbor_mines_left
	LDA	field_ptr
	. top-left
	SUB	#1
	SUB	#txt_cols
	JSUB	check_mine
	. middle-left
	ADD	#txt_cols
	JSUB	check_mine
	. bottom-left
	ADD	#txt_cols
	JSUB	check_mine

count_neighbor_mines_centre
	LDA	field_ptr
	. top-centre
	SUB	#txt_cols
	JSUB	check_mine
	. bottom-centre
	ADD	#txt_cols
	ADD	#txt_cols
	JSUB	check_mine

	. skip right column if current col. index is #txt_cols - 1
	LDA	field_col_index
	ADD	#1
	COMP	#txt_cols
	JEQ	count_neighbor_mines_end

count_neighbor_mines_right
	LDA	field_ptr
	. top-right
	ADD	#1
	SUB	#txt_cols
	JSUB	check_mine
	. middle-right
	ADD	#txt_cols
	JSUB	check_mine
	. bottom-right
	ADD	#txt_cols
	JSUB	check_mine

count_neighbor_mines_end
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

field_clear
	. push L to stack
	STL	@sp
	JSUB	push
	. push field_ptr to stack
	LDA	field_ptr
	STA	@sp
	JSUB	push

	. set field_ptr to start of field
	LDA	#field_addr
	STA	field_ptr

	LDX	#0
	LDA	#0
field_clear_loop
	STCH	@field_ptr

	LDA	field_ptr	. increment field_ptr
	ADD	#1
	STA	field_ptr
	LDA	#0

	TIX	#field_len
	JEQ	field_clear_end
	J	field_clear_loop

field_clear_end
	. pop field_ptr from stack
	JSUB	pop
	LDA	@sp
	STA	field_ptr
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. must be called after txt_init
field_init
	. push L to stack
	STL	@sp
	JSUB	push
	. initialize field_end
	LDA	#field_addr
	ADD	#field_len
	SUB	#1
	STA	field_end
	. initialize field_ptr
	LDA	#field_addr
	STA	field_ptr
	. set all bytes to 0
	JSUB	field_clear
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

.
.	END FIELD
.

.
.	BEGIN CURSOR
.

. row and column index storage for actions
cursor_row
	RESW	1
cursor_col
	RESW	1

. index of the plot currently "looked at"
cursor_pos
	RESW	1
. use this and cursor_update to change position
cursor_pos_new
	RESW	1
. remember cursor position at the start of selecting a plot
cursor_pos_old
	RESW	1

. save the char that was present before the cursor moved onto it
cursor_prev_char
	RESB	1

cursor_init
	. initialize cursor_pos
	LDA	#txt_width	. skip top border
	ADD	#1		. skip left border
	STA	cursor_pos
	. initialize cursor_prev_char
	LDA	txt_addr
	ADD	cursor_pos
	STA	txt_ptr
	LDCH	@txt_ptr
	STCH	cursor_prev_char
	RSUB

. update cursor on the textual screen
. check if cursor_pos_new is valid before this
cursor_update
	. txt[cursor_pos] = char_prev_char
	LDA	txt_addr
	ADD	cursor_pos
	STA	txt_ptr		. txt_ptr points to txt[cursor_pos]
	LDCH	cursor_prev_char
	STCH	@txt_ptr
	. char_prev_char = txt[cursor_pos_new]
	LDA	txt_addr
	ADD	cursor_pos_new
	STA	txt_ptr		. txt_ptr points to txt[cursor_pos_new]
	LDCH	@txt_ptr
	STCH	cursor_prev_char
	. txt[cursor_pos_new] = char_cursor
	LDA	txt_addr
	ADD	cursor_pos_new
	STA	txt_ptr		. txt_ptr points to txt[cursor_pos]
	LDCH	char_cursor
	STCH	@txt_ptr
	. cursor_pos = cursor_pos_new
	LDA	cursor_pos_new
	STA	cursor_pos
	RSUB

. set field_ptr to wherever cursor_pos is pointing to
. on the textual screen
pos_to_addr
	. push L to stack
	STL	@sp
	JSUB	push
	. push A to stack
	STA	@sp
	JSUB	push

	JSUB	pos_to_index	. set the cursor_row and cursor_col indexes
	. get index in field "array"
	LDA	cursor_row
	MUL	#txt_cols
	ADD	cursor_col
	. get actual address of the plot
	ADD	#field_addr
	STA	field_ptr

	. pop A from stack
	JSUB	pop
	LDA	@sp
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. convert the cursor position on the textual screen
. to a column and row index (cursor_row and cursor_col)
pos_to_index
	. get row index from cursor_pos
	LDA	cursor_pos
	DIV	#txt_width
	SUB	#1		. skip top border
	STA	cursor_row

	. get column index from cursor_pos
	LDA	cursor_pos
	RMO	A, X
	DIV	#txt_width
	MUL	#txt_width
	SUBR	A, X
	RMO	X, A
	SUB	#1		. skip left border 
	STA	cursor_col
	RSUB

.
.	END CURSOR
.

.
.	BEGIN ACTIONS
.

safe_plot_count
	RESW	1
	. EQU	txt_cols * txt_rows - rnd_size
uncovered_count
	RESW	1

actions_init
	. initialize safe_plot_count
	LDA	#txt_cols
	MUL	#txt_rows
	SUB	#rnd_size
	STA	safe_plot_count
	. initialize uncovered_count
	LDA	#0
	STA	uncovered_count

move_up
	LDA	cursor_pos
	SUB	#txt_width
	STA	cursor_pos_new
	J	check_move

move_down
	LDA	cursor_pos
	ADD	#txt_width
	STA	cursor_pos_new
	J	check_move

move_left
	LDA	cursor_pos
	SUB	#1
	STA	cursor_pos_new
	J	check_move

move_right
	LDA	cursor_pos
	ADD	#1
	STA	cursor_pos_new
	J	check_move

. check if cursor_pos_new is within the borders
check_move
	. check top and bottom border
	LDA	cursor_pos_new
	DIV	#txt_width	. A is now the (txt) row number
	COMP	#0
	JEQ	user_input	. row 0 -> top border
	ADD	#1
	COMP	#txt_height
	JEQ	user_input	. row txt_height-1 -> bottom border

	. check left and right border
	LDA	cursor_pos_new
	RMO	A, X
	DIV	#txt_width
	MUL	#txt_width
	SUBR	A, X
	RMO	X, A		. A is not the (txt) col number
	COMP	#0
	JEQ	user_input	. col 0 -> left border
	ADD	#1
	COMP	#txt_width
	JEQ	user_input	. col txt_width-1 -> right border

	. cursor_new_pos is within bounds
	JSUB	cursor_update
	J	user_input

. toggle the current plot's flag
plot_flag

	LDA	#0
	LDCH	cursor_prev_char

	RMO	A, X		. set X to char under cursor
	LDCH	char_unopened	. set A to char_unopened

	COMPR	A, X
	JEQ	plot_flag_mark
	J	plot_flag_unmark
	
plot_flag_unmark
	LDA	#0
	LDCH	char_unopened
	STCH	cursor_prev_char
	J	user_input

plot_flag_mark
	LDA	#0
	LDCH	char_flagged
	STCH	cursor_prev_char
	J	user_input

. get mine_count for current cursor
. set cursor_prev_char accordingly
. then continue with plot_select
plot_select_pre
	LDA	cursor_pos
	STA	cursor_pos_old		. save cursor position
	JSUB	pos_to_addr		. set field_ptr according to cursor_pos
	JSUB	count_neighbor_mines	. use field_ptr to set mine_count
	LDA	mine_count
	COMP	#0
	JEQ	plot_select_pre_zero
	J	plot_select_pre_nonzero
plot_select_pre_zero
	LDCH	char_nomine
	STCH	cursor_prev_char
	J	plot_select
plot_select_pre_nonzero
	LDCH	char_zero
	ADD	mine_count
	STCH	cursor_prev_char
	J	plot_select

. selected the plot the cursor is currently on
. check if there is a mine there
plot_select
	JSUB	pos_to_addr	. set field_ptr according to cursor_pos
	LDA	#0
	LDCH	@field_ptr
	COMP	#0
	JEQ	plot_nomine
	J	plot_mine

. user has selected a plot with a mine
plot_mine
	. set plot to char_mine
	LDA	txt_addr
	ADD	cursor_pos
	STA	txt_ptr

	. display the mine
	LDA	#0
	LDCH	char_mine
	STCH	@txt_ptr

	. wait for user input
	LDA	#0
	STCH	@kbd_addr
plot_mine_loop
	STA	kbd_prev_val
	LDCH	@kbd_addr
	COMP	kbd_prev_val
	JEQ	plot_mine_loop
	J	user_defeat	. restart

. user has selected a plot without a mine
. check if plot has (non)zero mines as neighbors
. return to user_input at the end
plot_nomine
	JSUB	pos_to_addr		. set field_ptr according to cursor_pos
	JSUB	count_neighbor_mines	. use field_ptr to set mine_count
	
	. increment uncovered_count
	LDA	uncovered_count
	ADD	#1
	STA	uncovered_count
	
	LDA	mine_count
	COMP	#0
	JEQ	plot_nomine_zero	. uncover neighbors
	J	plot_nomine_end		. cursor_prev_char has already been set

. uncover 4 adjacent plots (recursively)
plot_nomine_zero

	. top
	LDA	cursor_pos
	SUB	#txt_width
	STA	cursor_pos
	JSUB	plot_uncover_rec

	. left
	LDA	cursor_pos
	ADD	#txt_width
	SUB	#1
	STA	cursor_pos
	JSUB	plot_uncover_rec

	. right
	LDA	cursor_pos
	ADD	#2
	STA	cursor_pos
	JSUB	plot_uncover_rec

	. bottom
	LDA	cursor_pos
	SUB	#1
	ADD	#txt_width
	STA	cursor_pos
	JSUB	plot_uncover_rec

	J	plot_nomine_end

plot_nomine_end
	. restore cursor
	LDA	cursor_pos_old
	STA	cursor_pos
	. check if user has won
	LDA	uncovered_count
	COMP	safe_plot_count
	JEQ	user_victory
	JGT	user_victory
	J	user_input

. uncover cursor_pos and possibly its neighbors recursively
plot_uncover_rec
	. push L to stack
	STL	@sp
	JSUB	push

	. check if cursor_pos is within bounds
	LDA	cursor_pos
	COMP	#0
	JLT	plot_uncover_rec_end	. index < 0 -> out of bounds
	ADD	#1			. A > 120 <==> A + 1 > 121
	COMP	txt_len
	JGT	plot_uncover_rec_end	. index >= txt_len -> out of bounds
	SUB	#1

	. push cursor_pos to stack
	STA	@sp
	JSUB	push

	. check if cursor_pos points to a char_unopened
	ADD	txt_addr
	STA	txt_ptr
	LDA	#0
	LDCH	@txt_ptr
	RMO	A, X
	LDCH	char_unopened
	COMPR	A, X
	JEQ	plot_uncover_rec_pass

	. pop cursor_pos from stack
	JSUB	pop
	J	plot_uncover_rec_end	. not equal -> plot is already uncovered	

plot_uncover_rec_pass
	. peek cursor_pos from stack
	JSUB	pop
	LDA	@sp
	JSUB	push
	STA	cursor_pos

	. count mines as neighbors
	JSUB	pos_to_addr		. set field_ptr according to cursor_pos
	JSUB	count_neighbor_mines	. use field_ptr to set mine_count
	
	. pop cursor_pos from stack
	JSUB	pop
	LDA	@sp
	STA	cursor_pos

	LDA	mine_count
	COMP	#0
	JEQ	plot_uncover_rec_zero
	J	plot_uncover_rec_nonzero

. uncovered plot has 0 mines as neighbors
plot_uncover_rec_zero

	. uncover self (txt[cursor_pos] = char_nomine)
	LDA	txt_addr
	ADD	cursor_pos
	STA	txt_ptr
	LDCH	char_nomine
	STCH	@txt_ptr

	. increment uncovered_count
	LDA	uncovered_count
	ADD	#1
	STA	uncovered_count

	. push cursor_pos to stack
	LDA	cursor_pos
	STA	@sp
	JSUB	push

	. uncover neighbors

	. top
	SUB	#txt_width
	STA	cursor_pos
	JSUB	plot_uncover_rec
	
	. left
	JSUB	pop
	LDA	@sp	. peek cursor_pos from stack
	JSUB	push
	SUB	#1
	STA	cursor_pos
	JSUB	plot_uncover_rec

	. right
	JSUB	pop
	LDA	@sp	. peek cursor_pos from stack
	JSUB	push
	ADD	#1
	STA	cursor_pos
	JSUB	plot_uncover_rec

	. bottom
	JSUB	pop
	LDA	@sp	. peek cursor_pos from stack
	JSUB	push
	ADD	#txt_width
	STA	cursor_pos
	JSUB	plot_uncover_rec

	. pop cursor_pos from stack
	JSUB	pop

	J	plot_uncover_rec_end

. uncovered plot has a nonzero number of mines as neighbors
plot_uncover_rec_nonzero

	. uncover self (txt[cursor_pos] = ascii(mine_count))
	LDA	txt_addr
	ADD	cursor_pos
	STA	txt_ptr
	LDCH	char_zero
	ADD	mine_count
	STCH	@txt_ptr

	. increment uncovered_count
	LDA	uncovered_count
	ADD	#1
	STA	uncovered_count

	J	plot_uncover_rec_end

plot_uncover_rec_end
	. pop L from stack
	JSUB	pop
	LDL	@sp
	RSUB

. user has won -> print on txt screen and reset upon input
user_victory
	JSUB	txt_clear
	LDA	txt_addr
	STA	field_ptr

	LDX	#0
user_victory_print_loop
	LDA	#0
	LDCH	string_victory, X
	STCH	@field_ptr

	LDA	field_ptr
	ADD	#1
	STA	field_ptr

	TIX	#string_victory_len
	JEQ	user_victory_wait
	J	user_victory_print_loop

user_victory_wait
	LDA	#0
	STCH	@kbd_addr
	STA	kbd_prev_val
user_victory_wait_loop
	LDCH	@kbd_addr
	COMP	kbd_prev_val
	JEQ	user_victory_wait_loop
	J	prog	. input -> restart game

. user has lost -> print on txt screen and reset upon input
user_defeat
	JSUB	txt_clear
	LDA	txt_addr
	STA	field_ptr

	LDX	#0
user_defeat_print_loop
	LDA	#0
	LDCH	string_defeat, X
	STCH	@field_ptr

	LDA	field_ptr
	ADD	#1
	STA	field_ptr

	TIX	#string_defeat_len
	JEQ	user_defeat_wait
	J	user_defeat_print_loop

user_defeat_wait
	LDA	#0
	STCH	@kbd_addr
	STA	kbd_prev_val
user_defeat_wait_loop
	LDCH	@kbd_addr
	COMP	kbd_prev_val
	JEQ	user_defeat_wait_loop
	J	prog	. input -> restart game
.
.	END ACTIONS
.

.
.	BEGIN STACK
.

stack_size
	EQU	5000

. stack pointer
sp	RESW	1

. stack memory reservation
stack	RESW	stack_size

. storing the value of A
. for stack-related operations
stack_a	RESW	1

. set stack pointer to start of stack
stack_init
	STA	stack_a
	+LDA	#stack
	STA	sp
	LDA	stack_a
	RSUB

. increment sp by one word
push	STA	stack_a
	LDA	sp
	ADD	#3
	STA	sp
	LDA	stack_a
	RSUB

. decrement sp by one word
pop	STA	stack_a
	LDA	sp
	SUB	#3
	STA	sp
	LDA	stack_a
	RSUB

.
.	END STACK
.

.
.	BEGIN SPECIAL CHARTACTERS
.

char_corner
	BYTE	C'+'
char_border_horizontal
	BYTE	C'-'
char_border_vertical
	BYTE	C'|'
char_unopened
	BYTE	C'?'
char_flagged
	BYTE	C'!'
char_rnd_min
	BYTE	C'A'
char_rnd_max
	BYTE	C'Z'
char_cursor
	BYTE	C'+'
char_up
	BYTE	C'W'
char_down
	BYTE	C'S'
char_left
	BYTE	C'A'
char_right
	BYTE	C'D'
char_flag
	BYTE	C'J'
char_select
	BYTE	C'K'
char_mine
	BYTE	C'M'
char_nomine
	BYTE	C' '
char_zero
	BYTE	C'0'

string_victory
	BYTE	C'You Win!'
string_victory_end
	EQU	*
string_victory_len
	EQU	string_victory_end - string_victory
string_defeat
	BYTE	C'Game over'
string_defeat_end
	EQU	*
string_defeat_len
	EQU	string_defeat_end - string_defeat

.
.	END SPECIAL CHARTACTERS
.

.
.	BEGIN GAME CONFIG
.

. number of mines
rnd_size
	EQU	30
. number of rows (set text screen to this + 2)
txt_rows
	EQU	15
. number of columns (set text screen to this + 2)
txt_cols
	EQU	15

.
.	END GAME CONFIG
.
