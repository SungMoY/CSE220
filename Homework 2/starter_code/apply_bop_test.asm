.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"

val_stack : .word 0
op_stack : .word 0
arg1_addr : .word 0
arg2_addr : .word 0
arg3_addr : .word 0

.text
.globl main
main:

	lw $t0, 0($a1)
	sw $t0, arg1_addr
	lw $s1, arg1_addr
	
	# add code to test call and test apply_bop function
	li $a0, -5
	lbu $a1, 0($s1)
	li $a2, 4
	jal apply_bop

end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
