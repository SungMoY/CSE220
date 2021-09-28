############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################
.text
ApplyOpErrorMsg:
	li $v0, 4
	la $a0, ApplyOpError
	syscall
	li $v0, 10			#terminates program
	syscall

BadTokenErrorMsg:
	li $v0, 4
	la $a0, BadToken
	syscall
	li $v0, 10			#terminates program
	syscall
	
ParseErrorMsg:
	li $v0, 4
	la $a0, ParseError
	syscall
	li $v0, 10			#terminates program
	syscall

validNextDigit:
	li $t0, 10
	mult $s5, $t0
	mflo $s5
	addi $t0, $a0, -48
	add $s5, $s5, $t0
	addi $s0, $s0, 1
	j checkCharAfterForMoreDigits	#keep checking to see if it is a valid digit

pushNum:
	addi $s5, $s5, -48		#convert ascii val of digit into integer val
	j checkCharAfterForMoreDigits
	checkCharAfterForMoreDigits:
	move $s6, $s0
	addi $s6, $s6, 1
	lb $a0, 0($s6)
	jal is_digit
	bgtz $v0, validNextDigit
	
	move $a0, $s5
	move $a1, $s2			#get the tp value of val_stack
	move $a2, $s1			#get the address of val_stack
	jal stack_push
	move $s2, $v0			#update tp value of val_stack
	addi $s0, $s0, 1
	j whileLoopUntilNullTerm
	
pushLeftP:
	move $a0, $s5
	move $a1, $s4			#get the tp value of val_stack
	move $a2, $s3			#get the address of val_stack
	jal stack_push
	move $s4, $v0			#update tp value of val_stack
	addi $s0, $s0, 1
	j whileLoopUntilNullTerm
	
evalRightP:
	whileNotLeftP:
		addi $a0, $s4, -4		#peek to see if current op in op_stack is left Parenthesis
		move $a1, $s3
		jal stack_peek
		move $s5, $v0
		li $t0, 40
		beq $s5, $t0, endWhileNotLeftP	#if it is, end the while loop and discard the left Parenthesis
	
		addi $a0, $s4, -4		#pop operator from operator stack
		move $a1, $s3
		jal stack_pop
		move $s4, $v0
		move $t4, $v1
					
		addi $a0, $s2, -4		#pop second operand
		move $a1, $s1
		jal stack_pop
		move $s2, $v0
		move $s6, $v1
					
		addi $a0, $s2, -4		#pop first operand
		move $a1, $s1
		jal stack_pop
		move $s2, $v0
		move $s7, $v1
					
		move $a0, $s7
		move $a1, $t4
		move $a2, $s6
		jal apply_bop
			
		move $a0, $v0			#convert ascii val of digit into integer val		
		move $a1, $s2			#get the tp value of val_stack
		move $a2, $s1			#get the address of val_stack
		jal stack_push
		move $s2, $v0			#update tp value of val_stack
		j whileNotLeftP
	
	endWhileNotLeftP:
		addi $a0, $s4, -4		#discard left Parenthesis and return to the iterating while loop
		move $a1, $s3
		jal stack_pop
		move $s4, $v0
		move $s5, $v1
		addi $s0, $s0, 1
		j whileLoopUntilNullTerm


isOperator:
	#if the next character is an operator, throw ParseErrorMsg
	#if the next character is not a digit or operator, throw BadTokenErrorMsg
	
	addi $a0, $s2, -4				#if val stack is empty, then an operator appears before numbers so throw ParseErrorMsg
	jal is_stack_empty
	bgtz $v0, ParseErrorMsg
	
	move $t3, $s0
	addi $t3, $t3, 1
	lb $t4, 0($t3)
	beq $t4, $0, ParseErrorMsg			#if next character is null terminator, then current operator is at the end of the stsring so throw parse error
	
	move $a0, $t4
	jal valid_ops
	bgtz $v0, ParseErrorMsg
	
	whileOpStackNotEmptyAndTopGreaterPrec:
		addi $a0, $s4, -4
		jal is_stack_empty
		bgtz $v0, isOpWhileLoopEnd
		
		addi $a0, $s4, -4
		move $a1, $s3
		jal stack_peek
		move $t8, $v0	#op on top of stack
		
		li $t0, 40
		beq $t8, $t0, isOpWhileLoopEnd
		
		move $a0, $t8
		jal op_precedence
		move $t8, $v0
		move $t9, $s5	#op that is current char
		move $a0, $t9
		jal op_precedence
		move $t9, $v0
		blt $t8, $t9, isOpWhileLoopEnd
		addi $a0, $s3, -4
		jal is_stack_empty
		bgtz $v0, OpStackEmpty
		
		addi $a0, $s4, -4		#pop operator from operator stack
		move $a1, $s3
		jal stack_pop
		move $s4, $v0
		move $t4, $v1
					
		addi $a0, $s2, -4		#pop second operand
		move $a1, $s1
		jal stack_pop
		move $s2, $v0
		move $s6, $v1
					
		addi $a0, $s2, -4		#pop first operand
		move $a1, $s1
		jal stack_pop
		move $s2, $v0
		move $s7, $v1
					
		move $a0, $s7
		move $a1, $t4
		move $a2, $s6
		jal apply_bop
			
		move $a0, $v0			#convert ascii val of digit into integer val		
		move $a1, $s2			#get the tp value of val_stack
		move $a2, $s1			#get the address of val_stack
		jal stack_push
		move $s2, $v0			#update tp value of val_stack
		
		
		j whileOpStackNotEmptyAndTopGreaterPrec
	isOpWhileLoopEnd:
		move $a0, $s5
		move $a1, $s4
		move $a2, $s3
		jal stack_push
		move $s4, $v0
		
		addi $s0, $s0, 1
		j whileLoopUntilNullTerm
	

eval:
	addi $sp, $sp, -4
	sw $ra 0($sp)
	
	move $s0, $a0			#$s0 holds the address of the input string
	la $s1, val_stack		#$s1 holds the address of the value stack
	li $s2, 0			#tp value of val_stack
	la $s3, op_stack		#$s2 holds the address of the op_stack
	addi $s3, $s3, 3000
	li $s4, 0			#tp value of op_stack

	whileLoopUntilNullTerm:
		lb $s5, 0($s0)		#gets ascii value of the first char
		li $t0, 0		#loads ascii value of 0 which is the null terminator
		beq $s5, $t0, endLoop	#checks if the current char is the null terminator and ends loop if so
		move $a0, $s5
		jal is_digit
		bgtz $v0, pushNum
		li $t0, 40			#load the ascii value of left parenthesis
		beq $s5, $t0, pushLeftP		#checks if curernt char is left parenthesis
		li $t0, 41			#load the ascii value of right parenthesis
		beq $s5, $t0, evalRightP		#checks if curernt char is left parenthesis
		move $a0, $s5
		jal valid_ops
		bgtz $v0, isOperator
		addi $s0, $s0, 1
		j BadTokenErrorMsg
		
	endLoop:
		whileOpStackNotEmpty:
			addi $a0, $s4, -4
			jal is_stack_empty
			bgtz $v0, OpStackEmpty
			
			addi $a0, $s4, -4		#pop operator from operator stack
			move $a1, $s3
			jal stack_pop
			move $s4, $v0
			move $s5, $v1
		
			addi $a0, $s2, -4		#pop second operand
			move $a1, $s1
			jal stack_pop
			move $s2, $v0
			move $s6, $v1
		
			addi $a0, $s2, -4		#pop first operand
			move $a1, $s1
			jal stack_pop
			move $s2, $v0
			move $s7, $v1
		
			move $a0, $s7
			move $a1, $s5
			move $a2, $s6
			jal apply_bop
			
			move $a0, $v0			#convert ascii val of digit into integer val
			move $a1, $s2			#get the tp value of val_stack
			move $a2, $s1			#get the address of val_stack
			jal stack_push
			move $s2, $v0			#update tp value of val_stack
			j whileOpStackNotEmpty
	
		OpStackEmpty:
			addi $a0, $s2, -4	#retrieves only element in value stack which is the answer
			move $a1, $s1
			jal stack_pop
			move $v0, $v1
			
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

is_digit:
	move $t0, $a0			#holds ascii value of character
	li $t1, 48
	li $t2, 57
	bge $t0, $t1 checkUpperBound	#checks if greater than or eq the ascii value of 0
	li $v0, 0			#returning 0 bc ascii val of input char is not in range
  	jr $ra
  	checkUpperBound:		#checks if less than or eq the ascii value of 9
	ble $t0, $t2, ValidDigit	#if ascii value of input char is in range, it is a valid digit
	li $v0, 0			#return 0 if not valid digit
	jr $ra
	ValidDigit:			#return 1 if valid digit
	li $v0, 1
	jr $ra

stack_push:	#push(element to be pushed, current top value, address of stack array) :returns the new top of the stack
	move $t0, $a0		#int element to push on stack array
	move $t1, $a1		#offset that holds the top of the stack, this is above the topest element
	move $t2, $a2		#base address of the stack array
	
	li $t3, 2000				#checks if stack array is full at 500 elements
	bge $t1, $t3, BadTokenErrorMsg 
	
	add $t2, $t2, $t1	#adds top value to base address to get address of current top
	sw $t0, 0($t2)		#stores the input element at this new empty new top address slot of the array
	addi $v0, $t1, 4	#increases and returns the top value by 4 so that it points to the next empty top slot
	jr $ra

stack_peek:	#peek(kocation of element to peek, address of stack array) :returns the value at the top
	move $t0, $a0		#value of tp (top offset value of the stack array)
	move $t1, $a1		#base address of the stack array
	
	bltz $t0, BadTokenErrorMsg	#checks if stack array is empty, returns error
	
	add $t1, $t1, $t0	#sets the index address to the top value index
	lw $v0, 0($t1)		#sets return register v1 to the value peeked
  	jr $ra

stack_pop:	#pop(location of element to pop, address of stack array) :returns v0 new top and v1 popped value
	move $t0, $a0		#value of tp (top offset value of the stack array)
	move $t1, $a1		#base address of the stack array
	
	bltz $t0, BadTokenErrorMsg	#checks if stack array is empty, returns error
	
	add $t1, $t1, $t0	#sets the index address to the top value index
	lw $v1, 0($t1)		#sets return register v1 to the value popped
	move $v0, $t0		#updates the tp value to be where the top value was
  	jr $ra

is_stack_empty:
	move $t0, $a0			#holds the value of tp
	bltz $t0, emptyStackReturnOne
	li $v0, 0
 	jr $ra
 	emptyStackReturnOne:
 	li $v0, 1
 	jr $ra
	
valid_ops:
	move $t0, $a0
	casePlus: 
		li $t1, 43
		bne $t0, $t1, caseMinus
		li $v0, 1
		jr $ra
	caseMinus:
		li $t1, 45
		bne $t0, $t1, caseMult
		li $v0, 1
		jr $ra
	caseMult:
		li $t1, 42
		bne $t0, $t1, caseDiv
		li $v0, 1
		jr $ra
	caseDiv:
		li $t1, 47
		bne $t0, $t1, default
		li $v0, 1
		jr $ra
	default:
		li $v0, 0
  		jr $ra

op_precedence:
	move $t0, $a0
	casePlusPrec: 
		li $t1, 43
		bne $t0, $t1, caseMinusPrec
		li $v0, 1
		jr $ra
	caseMinusPrec:
		li $t1, 45
		bne $t0, $t1, caseMultPrec
		li $v0, 1
		jr $ra
	caseMultPrec:
		li $t1, 42
		bne $t0, $t1, caseDivPrec
		li $v0, 2
		jr $ra
	caseDivPrec:
		li $t1, 47
		bne $t0, $t1, defaultPrec
		li $v0, 2
		jr $ra
	defaultPrec:
		li $v0, 4
		la $a0, ApplyOpError
		syscall
		li $v0, 10			#terminates program
		syscall

apply_bop:
	move $t0, $a0				#integer value (positive or negative)
	move $t1, $a1				#ascii value of the char of the operation
	move $t2, $a2				#integer value (positive or negative)
	casePlusApply: 
		li $t3, 43
		bne $t1, $t3, caseMinusApply
		add $v0, $t0, $t2
		jr $ra
	caseMinusApply:
		li $t3, 45
		bne $t1, $t3, caseMultApply
		sub $v0, $t0, $t2
		jr $ra
	caseMultApply:
		li $t3, 42
		bne $t1, $t3, caseDivApply
		mult $t0, $t2
		mflo $v0
		jr  $ra
	caseDivApply:
		li $t3, 47
		bne $t1, $t3, ApplyOpErrorMsg	#checks for division operator sign char
		beqz $t2, ApplyOpErrorMsg	#error if dividing by zero
		
		bltz $t0, firstNumNegDiv
		bltz $t2, secondNumNegDiv
		
		div $t0, $t2
		mflo $v0
		jr $ra
	firstNumNegDiv:
		bltz $t2, bothNumNegDiv
		mult $t0, $t0
		mflo $t6
		mult $t2, $t2
		mflo $t7
		ble $t6, $t7, firstNumNegAndNegFraction
		div $t0, $t2
		mfhi $t5
		beqz $t5, firstNumNegFullyDivisibleReturnLO
		mflo $v0
		addi $v0, $v0, -1	#firstNumNegDivisionWithRemainderReturnLOMinusOne:
		jr $ra
	firstNumNegAndNegFraction:
		li $v0, -1
		jr $ra
	firstNumNegFullyDivisibleReturnLO:
		mflo $v0
		jr $ra
	secondNumNegDiv:
		mult $t0, $t0
		mflo $t6
		mult $t2, $t2
		mflo $t7
		ble $t6, $t7, firstNumNegAndNegFraction
		div $t0, $t2
		mfhi $t5
		beqz $t5, firstNumNegFullyDivisibleReturnLO
		mflo $v0
		addi $v0, $v0, -1	#firstNumNegDivisionWithRemainderReturnLOMinusOne:
		jr $ra
	bothNumNegDiv:
		div $t0, $t2
		mflo $v0
		jr $ra