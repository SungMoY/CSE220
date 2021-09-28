.data
player: .byte 'B'
distance: .byte 3
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0104040407040420018040000500"
.text
.globl main
main:
la $a0, state
lb $a1, player
lb $a2, distance
jal get_pocket
# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hw3.asm"