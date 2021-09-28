.data
origin_pocket: .byte 3
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 0         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 0         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "TTPP1122334455LL000000000000"
    #TT000102030405050403020100BB
.text
.globl main
main:
la $a0, state
lb $a1, origin_pocket
li $a2, 3
jal steal_destinationHelper
# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hw3.asm"
