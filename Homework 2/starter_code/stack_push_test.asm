.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"

val_stack : .word 0
op_stack : .word 0
numbers : .space 0

.text
.globl main
main:

  # add code to call and test stack_push function
	li $a0, 69
	li $a1, 0
	la $a2, numbers
	jal stack_push
	
	li $a0, 70
	move $a1, $v0
	la $a2, numbers
	jal stack_push
	
	addi $a0, $v0, -4
	la $a1, numbers
	jal stack_peek
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
