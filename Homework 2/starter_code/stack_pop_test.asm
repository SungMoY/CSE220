.data
Newline: .asciiz "\n"
WrongArgMsg: .asciiz "You must provide exactly one argument"
BadToken: .asciiz "Unrecognized Token"
ParseError: .asciiz "Ill Formed Expression"
ApplyOpError: .asciiz "Operator could not be applied"
Comma: .asciiz ","
Space: .asciiz " "

val_stack : .word 0
op_stack : .word 0
numbers : .space 0

.text
.globl main
main:

  # add code to call and test stack_push function
	li $a0, 10
	li $a1, 0
	la $a2, numbers
	jal stack_push
	
	li $a0, 20
	li $a1, 4
	la $a2, numbers
	jal stack_push
	
	li $a0, 4
	la $a1, numbers
	jal stack_pop
	
	li $a0, 0
	la $a1, numbers
	jal stack_pop
	
	li $a0, -4
	la $a1, numbers
	jal stack_pop
	
	
end:
  # Terminates the program
  li $v0, 10
  syscall

.include "hw2-funcs.asm"
