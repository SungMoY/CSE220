# add test cases to data section
.data
str1: .asciiz "Jane Doe"

.text:
main:
	la $a0, str1
	li $s0, 999
	li $s1, 998
	li $s2, 997
	jal str_len
	#write test code
	li $v0, 10
	syscall
	
.include "hw4.asm"
