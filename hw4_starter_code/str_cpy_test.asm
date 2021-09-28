# add test cases to data section
.data
src: .asciiz "Allison Burgers"
dest: .asciiz ""

.text:
main:
	la $a0, src
	la $a1, dest
	li $s0, 999
	li $s1, 888
	li $s2, 777
	li $s3, 666
	jal str_cpy
	#write test code
	li $v0, 10
	syscall
	
.include "hw4.asm"
