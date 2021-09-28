.data
moves_filename: .asciiz "moves02.txt"
board_filename: .asciiz "game01.txt"
num_moves_to_execute: .word 50
moves: .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.align 2
state:        
    .byte 99         # bot_mancala       	(byte #0)
    .byte 99         # top_mancala       	(byte #1)
    .byte 99         # bot_pockets       	(byte #2)
    .byte 99         # top_pockets        	(byte #3)
    .byte 99         # moves_executed	(byte #4)
    .byte 'X'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "9999999999999999999999999999"
.text
.globl main
main:
la $a0, moves_filename
la $a1, board_filename
la $a2, state
la $a3, moves
addi $sp, $sp, -4
lw $t0, num_moves_to_execute
sw $t0, 0($sp)
jal play_game
addi $sp, $sp, 4
# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hw3.asm"
