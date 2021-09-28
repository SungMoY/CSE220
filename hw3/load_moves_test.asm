.data
filename: .asciiz "moves03.txt"
.align 0
moves: .byte 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98, 98
.text
.globl main
main:
la $a0, moves
la $a1, filename
li $s0, 9999
li $s1, 9999
jal load_moves

# You must write your own code here to check the correctness of the function implementation.

li $v0, 10
syscall

.include "hw3.asm"
