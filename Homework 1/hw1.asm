.data
ErrMsg: .asciiz "Invalid Argument"
WrongArgMsg: .asciiz "You must provide exactly two arguments"
EvenMsg: .asciiz "Even"
OddMsg: .asciiz "Odd"
OneDot: .asciiz "1."
NumOne: .asciiz "1"
NumZero: .asciiz "0"

arg1_addr : .word 0
arg2_addr : .word 0
num_args : .word 0

.text:
.globl main
main:
	sw $a0, num_args

	lw $t0, 0($a1)
	sw $t0, arg1_addr
	lw $s1, arg1_addr

	lw $t1, 4($a1)
	sw $t1, arg2_addr
	lw $s2, arg2_addr
	
# do not change any line of code above this section
# you can add code to the .data section
start_coding_here:
	li $t0, 2			#temporarily stores 2 
	beq $a0, $t0, CheckSecondArg	#checks if more/less than 2 args, then moves to check second arg
	
	li $v0, 4			#prints WrongArgMsg
	la $a0, WrongArgMsg
	syscall
	
	li $v0, 10			#terminates program
	syscall
	
PrintErrorMsg:
	li $v0, 4			#prints ErrMsg
	la $a0, ErrMsg
	syscall
	
	li $v0, 10			#terminates program
	syscall
	
ShiftLeft:
	sll $s3, $s3, 4			#shifts the binary representation of second arg
	j ShiftReturn
	
Positive:
	li $v0, 1
	move $a0, $t0
	syscall

	li $v0, 10			#terminates program
	syscall
	j Terminate
	
IsEven:
	li $v0, 4
	la $a0, EvenMsg
	syscall
	
	li $v0, 10			#terminates program
	syscall
	
PrintZero:
	li $v0, 4
	la $a0, NumZero
	syscall
	addi $t1, $t1, 1
	blt $t1, $t2, PrintLoop
	j Terminate
	
CheckSecondArg:
	lbu $t0, 0($s2)			#load first character of the second argument into t1
	li $t1, '0'			#check if first character is a zero
	bne $t0, $t1, PrintErrorMsg	#else print error msg
	
	lbu $t0, 1($s2)			#load second character of the second argument into t1
	li $t1, 'x'			#check if second character is a x
	bne $t0, $t1, PrintErrorMsg	#else print error msg
	
	lw  $t0, arg2_addr		#store address of second arg into $t0
	li $t2, 0			#initialize counter
	li $t3, 8			#limit to for loop
	
	loop:
		lbu $t1, 2($t0)			#loads the current bit into $t1
		blt $t2, $t3, ShiftLeft		#if there are more chars to check, shift binary rep to fit those more chars
		ShiftReturn:
		case0:
			li $t4, '0'		#loads the char 0 into $t4
			bne $t1, $t4, case1	#compares current bit with char 0
			addi $s3, $s3, 0	#adds the value of 0 into the binary rep
			addi $t0, $t0, 1	#moves bit pointer of second argument forward once
			addi $t2, $t2, 1	#increments the loop counter once
			blt $t2, $t3, loop	#compares counter with limit value, loops if counter is less
		case1:
			li $t4, '1'
			bne $t1, $t4, case2
			addi $s3, $s3, 1
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case2:
			li $t4, '2'
			bne $t1, $t4, case3
			addi $s3, $s3, 2
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case3:
			li $t4, '3'
			bne $t1, $t4, case4
			addi $s3, $s3, 3
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case4:
			li $t4, '4'
			bne $t1, $t4, case5
			addi $s3, $s3, 4
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case5:
			li $t4, '5'
			bne $t1, $t4, case6
			addi $s3, $s3, 5
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case6:
			li $t4, '6'
			bne $t1, $t4, case7
			addi $s3, $s3, 6
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case7:
			li $t4, '7'
			bne $t1, $t4, case8
			addi $s3, $s3, 7
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case8:
			li $t4, '8'
			bne $t1, $t4, case9
			addi $s3, $s3, 8
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		case9:
			li $t4, '9'
			bne $t1, $t4, caseA
			addi $s3, $s3, 9
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		caseA:
			li $t4, 'A'
			bne $t1, $t4, caseB
			addi $s3, $s3, 10
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		caseB:
			li $t4, 'B'
			bne $t1, $t4, caseC
			addi $s3, $s3, 11
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		caseC:
			li $t4, 'C'
			bne $t1, $t4, caseD
			addi $s3, $s3, 12
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		caseD:
			li $t4, 'D'
			bne $t1, $t4, caseE
			addi $s3, $s3, 13
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		caseE:
			li $t4, 'E'
			bne $t1, $t4, caseF
			addi $s3, $s3, 14
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		caseF:
			li $t4, 'F'
			bne $t1, $t4, default
			addi $s3, $s3, 15
			addi $t0, $t0, 1
			addi $t2, $t2, 1
			blt $t2, $t3, loop
		default:
			beq $t2, $t3, CheckFirstArg	#Second arg should be valid so move on to check first arg	
			j PrintErrorMsg			#jump occurs if there are less than 10 chars of second arg

CheckFirstArg:
	lbu $t1, 0($s1)		#loads the value of address of the first argument stored in s1 into s1
	
	li $t0, 'O'		#loads character into temporary register
	beq $t1, $t0, OpO	#compares value to character and branches if they are equal
	li $t0, 'S'		#if not, check with other characters
	beq $t1, $t0, OpS	#if valid first arg, do the operation the first arg says
	li $t0, 'T'
	beq $t1, $t0, OpT
	li $t0, 'I'
	beq $t1, $t0, OpI
	li $t0, 'E'
	beq $t1, $t0, OpE
	li $t0, 'C'
	beq $t1, $t0, OpC
	li $t0, 'X'
	beq $t1, $t0, OpX
	li $t0, 'M'
	beq $t1, $t0, OpM
	
	jal PrintErrorMsg	#else, print the error msg	

OpO:				#print the opcode (first 6 bits)
	move $t0, $s3		#binary rep in $s3 is stored into $t0
	srl $t0, $t0, 26	#binary bits are shifted right to just leave the opcode
	
	li $v0, 1		#prints opcode as decimal
	move $a0, $t0
	syscall
	j Terminate

OpS:
	move $t0, $s3		#binary rep in $s3 is stored into $t0
	sll $t0, $t0, 6
	srl $t0, $t0, 27
	
	li $v0, 1
	move $a0, $t0
	syscall
	j Terminate
	
OpT:
	move $t0, $s3		#binary rep in $s3 is stored into $t0
	sll $t0, $t0, 11
	srl $t0, $t0, 27
	
	li $v0, 1
	move $a0, $t0
	syscall
	j Terminate

OpI:
	move $t0, $s3		#binary rep in $s3 is stored into $t0
	sll $t0, $t0, 16
	srl $t0, $t0, 16

	move $t1, $t0		#isolates the 16th bit to see if positive/negative
	srl $t1, $t1, 15
	
	li $t6, 0x00000030
	beq $t5, $t6, Positive	
	
	sll $t0, $t0, 16
	sra $t0, $t0, 16
	
	li $v0, 1
	move $a0, $t0
	syscall
	j Terminate
	
OpE:
	move $t0, $s3		#binary rep in $s3 is stored into $t0
	sll $t0, $t0, 31
	srl $t0, $t0, 31
	beqz $t0, IsEven
	li $v0, 4
	la $a0, OddMsg
	syscall
	j Terminate
	
OpC:
	move $t0, $s3			#binary rep in $s3 is stored into $t0
	li $t1, 1			#comparator
	li $t2, 0			#counter
	LoopCounting:
		li $t3, 0		#temp holding
		and $t3, $t0, $t1	
		add $t2, $t2, $t3
		srl $t0, $t0, 1
		bgtz  $t0, LoopCounting
	
	li $v0, 1
	move $a0, $t2
	syscall
	j Terminate
		
OpX:
	move $t0, $s3	
	sll $t0, $t0, 1
	srl $t0, $t0, 24
	addi $t0, $t0, -127
	
	li $v0, 1
	move $a0, $t0
	syscall
	j Terminate

OpM:
	move $t0, $s3
	sll $t0, $t0, 9
	
	li $v0, 4
	la $a0, OneDot
	syscall
	
	li $t1, 0	#loop counter
	li $t2, 32	#loop limit
	li $t3, 1	#comparator
	li $t4, 48	#add to convert to ascii 0 or 1
	
	li $t6, 0x00000030	#value of 0 in ascii to compare the masked value with
	
	PrintLoop:
		
		rol $t0, $t0, 1		#roll the msb down to the lsb place
		and $t5, $t0, $t3	#compare to see if its a 0 or a 1
		add $t5, $t5, $t4	#add 48 to $t5 to convert the value of masking
		
		beq $t5, $t6, PrintZero
		
		li $v0, 4
		la $a0, NumOne
		syscall
		
		addi $t1, $t1, 1
		blt $t1, $t2, PrintLoop
		j Terminate
		
Terminate:	
li $v0, 10			#terminates program
syscall
