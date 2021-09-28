# Sung Mo Yang
# sungyang
# 112801117

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text
load_game_Helper:
	move $t0, $a0			#$t0 holds file descriptor
	li $t1, 0			#holds return value digit		
	loopUntilLineEnd:
		addi $sp, $sp, -4
		li $v0, 14		#load syscall 14 into $v0 to read from file
		move $a0, $t0		#load file descriptor into $a0
		move $a1, $sp		#load address of input buffer
		li $a2, 1		#number of characters to read which is only 1
		syscall
		lb $t2, 0($sp)		#check and ends loop if current character is \r or \n
		li $t3, 48		
		bge $t2, $t3, loopProcessChar	#current char is valid number so loop continues. If not, loop exists
		j continue1
	loopProcessChar:
		lb $t2, 0($sp)		#loads the valid current char
		addi $t2, $t2, -48	#converts ascii char to digit
		li $t3, 10		#multiply previous value by 10 to add in current value
		mult $t1, $t3
		mflo $t1
		add $t1, $t1, $t2	#add current value to previous value
		addi $sp $sp, 4		#remove current char from stack pointer
		j loopUntilLineEnd
	continue1:			#if current char is \r, then it is a Windows machine so the \n also needs to be removed
	lb $t2, 0($sp)
	li $t3, 13
	beq $t2, $t3, removeN		#if current char is \r, branch. if it is not, then it has to be \n which means just continue
	j continue2
	removeN:
		addi $sp, $sp, -4
		li $v0, 14		#load syscall 14 into $v0 to read from file
		move $a0, $t0		#load file descriptor into $a0
		move $a1, $sp		#load address of input buffer
		li $a2, 1		#number of characters to read which is only 1
		syscall
		addi $sp, $sp, 4	#removes \n completely
		j continue2
	continue2:			#current char is \r or \n so exit loop and process contents in $sp
	addi $sp, $sp, 4		#these two lines remove \r in windows machine or \n elsewhere. Now next char to process is in the next line
	move $v0, $t1
	jr $ra
########################################
load_game:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	
	move $s0, $a0		#starting address of GameState construct
	move $s1, $a1		#address of filename string
	
	move $a0, $s1		#address of filename string
	li $a1, 0		#read-only flag for syscall
	li $a2, 0		#ignore mode
	li $v0, 13		#load syscall 13
	syscall			#call syscall
	move $s2, $v0		#$s2 contains file descriptor
	bltz $s2, fileOpenError	#if file open error, return -1 for $v0 and $v1
	
	addi $sp, $sp, -4	#store $ra of load_game onto $sp
	sw $ra, 0($sp)
	move $a0, $s2		#file descriptor as parameter
	jal load_game_Helper	#first row of file - top_mancala
	move $s3, $v0
	
	move $a0, $s2		#file descriptor as parameter
	jal load_game_Helper	#second row of file - bot_mancala
	move $s4, $v0
	
	sb $s4, 0($s0)		#byte 0 of gamestate - number of stones in bot_mancala
	addi $s0, $s0, 1	
	
	sb $s3, 0($s0)		#byte 1 of gamestate - number of stones in top_mancala
	addi $s0, $s0, 1
	
	move $a0, $s2		#file descriptor as parameter
	jal load_game_Helper	#third row of file - number of pockets in each row
	move $s5, $v0
	
	sb $s5, 0($s0)		#byte 2 of gamestate - top_mancala
	addi $s0, $s0, 1	#number of pockets of bottom row 

	sb $s5, 0($s0)		#byte 3 of gamestate - top_mancala
	addi $s0, $s0, 1	#number of pockets of top row
	
	sb $0, 0($s0)		#byte 4 of gamestate - moves executed
	addi $s0, $s0, 1
	
	li $t0, 66
	sb $t0, 0($s0)		#byte 5 of gamestate - current turn, by default is player 1 ('B')
	addi $s0, $s0, 1	#player 2 is ('T') and ('D') signifies game is done
	
	move $s6, $s0		#backup address of GameState construct at the ascii board part
	
	li $t0, 10		#add the number of stones in top mancala as an ascii char onto gamestate construct
	div $s3, $t0
	mflo $t1
	addi $t1, $t1, 48
	sb $t1, 0($s0)
	addi $s0, $s0, 1
	mfhi $t1
	addi $t1, $t1, 48
	sb $t1, 0($s0)
	addi $s0, $s0, 1
	
	move $t0, $s5		#adding characters of gameboard to gamestate
	add $t0, $t0, $t0
	li $t1, 0
	loopGameBoard:
		li $v0, 14
		move $a0, $s2
		move $a1, $s0
		li $a2, 1
		syscall
		addi $s0, $s0, 1
		addi $t1, $t1, 1
		blt $t1, $t0, loopGameBoard
		
	li $v0, 14
	move $a0, $s2
	addi $sp, $sp, -4
	move $a1, $sp
	li $a2, 1
	syscall
	
	lb $t0, 0($sp)			####these lines remove \r in windows machine or \n elsewhere. Now next char to process is in the next line
	li $t1, 13
	beq $t2, $t3, removeN3		#if current char is \r, branch. if it is not, then it has to be \n which means just continue
	j continue3
	removeN3:
		addi $sp, $sp, -4
		li $v0, 14		#load syscall 14 into $v0 to read from file
		move $a0, $s2		#load file descriptor into $a0
		move $a1, $sp		#load address of input buffer
		li $a2, 1		#number of characters to read which is only 1
		syscall
		addi $sp, $sp, 4	#removes \n completely
		j continue3
	continue3:									
	addi $sp, $sp, 4

	move $t0, $s5
	add $t0, $t0, $t0
	li $t1, 0
	loopGameBoard2:			#loop through second row of gameboard and add them to gamestate bytes
		li $v0, 14
		move $a0, $s2
		move $a1, $s0
		li $a2, 1
		syscall
		addi $s0, $s0, 1
		addi $t1, $t1, 1
		blt $t1, $t0, loopGameBoard2
	
	li $t0, 10		#add the number of stones in bot mancala as an ascii char onto gamestate construct
	div $s4, $t0
	mflo $t1
	addi $t1, $t1, 48
	sb $t1, 0($s0)
	addi $s0, $s0, 1
	mfhi $t1
	addi $t1, $t1, 48
	sb $t1, 0($s0)
	addi $s0, $s0, 1
	
	move $a0, $s2		#load file descriptor to $a0
	li $v0, 16		#close file syscall
	syscall			#close file syscall
	
	li $t0, 0		#v0 holds the total number of stones, compare with limit 99
	loopGetTotalStones:	#this part of the function sets the values of $v0 and $v1 based on the data extracted from gamefile to gamestate construct
		lb $t1, 0($s6)
		addi $s6, $s6, 1
		addi $t1, $t1, -48
		li $t2, 10
		mult $t1, $t2
		mflo $t1
		lb $t2, 0($s6)
		addi $t2, $t2, -48
		add $t1, $t1, $t2
		addi $s6, $s6, 1
		add $t0, $t0, $t1
		blt $s6, $s0, loopGetTotalStones
	
	add $t1, $s5, $s5	#s5 is the number of pockets in each row. Double this to get total number of rows then compare to limit of 98
		
	li $t2, 99
	bgt $t0, $t2, numStonesExceed
	li $t2, 98
	bgt $t1, $t2, numPocketsExceed

	li $v0, 1
	move $v1, $t1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	j registerConventionReturn1
	numStonesExceed:
		li $t2, 98
		bgt $t1, $t2, bothExceed
		move $v1, $t1
		li $v0, 0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j registerConventionReturn1
	numPocketsExceed:
		li $v1, 0
		li $v0, 0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j registerConventionReturn1
	bothExceed:
		li $v0, 0
		li $v1, 0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		j registerConventionReturn1
	fileOpenError:
		li $v0, -1
		li $v1, -1
		j registerConventionReturn1
	registerConventionReturn1:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra
########################################	
get_pocket:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0		#address of gamestate construct
	move $s1, $a1		#8 bit ascii value of current player 'B' bot #66 or 'T' top #84
	move $s2, $a2		#distance of pocket from player - start pocket distance count from 0
	
	bltz $s2, returnError1
	addi $t1, $s0, 2	#check if distance is not negative and is in range of # of pockets/rows
	lb $t0, 0($t1)
	bge $s2, $t0, returnError1

	li $t0, 66		#check if current player is 'B'
	move $t1, $s1
	beq $t1, $t0, botPlayer1

	li $t0, 84		#check if current player is 'T'
	move $t1, $s1
	beq $t1, $t0, topPlayer1
	j returnError1
	
	returnError1:
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
	botPlayer1:
		move $t0, $s0		#store address of gamestate construct into $t0
		
		addi $t0, $t0, 2	#now at the location of number of pockets
		lbu $t1, 0($t0)		#store the number of pockets
		
		addi $t0, $t0, 4	#move past the rest of the bytes of gamestate until hit gameboard
		addi $t0, $t0, 2	#move past the two bytes holding top player in gameboard
		
		add $t0, $t0, $t1	#move past the top pockets
		add $t0, $t0, $t1
		add $t0, $t0, $t1	#move past the bot pockets. Now currently at right before the two bytes of bot player
		add $t0, $t0, $t1
		
		add $t2, $s2, $s2	#double distance to account for the fact that integers in gameboard are represented as double digits
		
		li $t3, -1
		mult $t2, $t3
		mflo $t2
		add $t0, $t0, $t2	#move address behind to up until 1s place digit
		addi $t0, $t0, -2	#move address behind one more to get to 10s place digit
		
		lbu $t1, 0($t0)		#load 10s place digit
		addi $t1, $t1, -48
		addi $t0, $t0, 1
		lbu $t2, 0($t0)		#load 1s place digit
		addi $t2, $t2, -48
		li $t3, 10
		mult $t1, $t3
		mflo $v0
		add $v0, $v0, $t2	#add 1s place to the 10s place digit
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
	topPlayer1:
		move $t0, $s0		#store address of gamestate construct into $t0
		
		addi $t0, $t0, 6	#move past the 4 bytes of gamestate until hit gameboard
		addi $t0, $t0, 2	#move past the two bytes holding top pocket in gameboard
		
		add $t4, $s2, $s2	#double distance to account for the fact that integers in gameboard are represented as double digits
		add $t0, $t0, $t4	#move past the gameboard the length of distance bytes I do not want
		
		lbu $t1, 0($t0)		#load 10s place digit
		addi $t1, $t1, -48
		addi $t0, $t0, 1
		lbu $t2, 0($t0)		#load 1s place digit
		addi $t2, $t2, -48
		li $t3, 10
		mult $t1, $t3
		mflo $v0
		add $v0, $v0, $t2	#add 1s place to the 10s place digit
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
########################################	
set_pocket:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	move $s0, $a0	#address of gamestate construct
	move $s1, $a1	#ascii char of current player
	move $s2, $a2	#integer value of distance
	move $s3, $a3	#value of new size
	
	bltz $s2, returnError2
	addi $t1, $s0, 2	#check if distance is not negative and is in range of # of pockets/rows
	lb $t0, 0($t1)
	bge $s2, $t0, returnError2

	li $t0, 66		#check if current player is 'B'
	move $t1, $s1
	beq $t1, $t0, botPlayer2

	li $t0, 84		#check if current player is 'T'
	move $t1, $s1
	beq $t1, $t0, topPlayer2
	j returnError2
		
	botPlayer2:
		bltz $s3, returnErrorNegative2		#return -2 if size is a negative number of greater than the limit 99
		li $t0, 99
		bgt $s3, $t0, returnErrorNegative2
		
		move $t0, $s0		#store address of gamestate construct into $t0
		
		addi $t0, $t0, 2	#now at the location of number of pockets
		lbu $t1, 0($t0)		#store the number of pockets
		
		addi $t0, $t0, 4	#move past the rest of the bytes of gamestate until hit gameboard
		addi $t0, $t0, 2	#move past the two bytes holding top player in gameboard
		
		add $t0, $t0, $t1	#move past the top pockets
		add $t0, $t0, $t1
		add $t0, $t0, $t1	#move past the bot pockets. Now currently at right before the two bytes of bot player
		add $t0, $t0, $t1
		
		add $t2, $s2, $s2	#double distance to account for the fact that integers in gameboard are represented as double digits
		
		li $t3, -1
		mult $t2, $t3
		mflo $t2
		add $t0, $t0, $t2	#move address behind to up until 1s place digit
		addi $t0, $t0, -2	#move address behind one more to get to 10s place digit
		
		li $t1, 10
		div $s3, $t1
		mflo $t1		#holds the 10s place digit
		mfhi $t2		#holds the 1s place digit
		
		addi $t1, $t1, 48	#convert 10s place digit into ascii value of its digit
		addi $t2, $t2, 48	#convert 1s place digit into ascii value of its digit
		
		sb $t1, 0($t0)		#store 10s place digit in right place
		sb $t2, 1($t0)		#store 1s place digit in right place
		
		move $v0, $s3		#store size into v0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	
	topPlayer2:
		bltz $s3, returnErrorNegative2		#return -2 if size is a negative number of greater than the limit 99
		li $t0, 99
		bgt $s3, $t0, returnErrorNegative2
		
		move $t0, $s0		#store address of gamestate construct into $t0
		
		addi $t0, $t0, 6	#move past the 4 bytes of gamestate until hit gameboard
		addi $t0, $t0, 2	#move past the two bytes holding top pocket in gameboard
		
		add $t4, $s2, $s2	#double distance to account for the fact that integers in gameboard are represented as double digits
		add $t0, $t0, $t4	#move past the gameboard the length of distance bytes I do not want
		
		li $t1, 10
		div $s3, $t1
		mflo $t1		#holds the 10s place digit
		mfhi $t2		#holds the 1s place digit
		
		addi $t1, $t1, 48	#convert 10s place digit into ascii value of its digit
		addi $t2, $t2, 48	#convert 1s place digit into ascii value of its digit
		
		sb $t1, 0($t0)		#store 10s place digit in right place
		sb $t2, 1($t0)		#store 1s place digit in right place
		
		move $v0, $s3		#store size into v0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
		
	returnError2:
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
		
	returnErrorNegative2:
		li $v0, -2
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
########################################	
collect_stones:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)

	move $s0, $a0		#address of gamestate construct
	move $s1, $a1		#ascii char of current player
	move $s2, $a2		#integer value to be added to current player's mancala
	
	li $t0, 66		#check if current player is 'B'
	move $t1, $s1
	beq $t1, $t0, botPlayer_CollectStones

	li $t0, 84		#check if current player is 'T'
	move $t1, $s1
	beq $t1, $t0, topPlayer_CollectStones
	j invalidPlayerChar_CollectStones
	
	botPlayer_CollectStones:
		blez $s2, stonesLessThanOrEqZero_CollectStones
		
		lb $t0, 0($s0)		#updated bot_mancala byte
		add $t0, $t0, $s2
		sb $t0, 0($s0) 		#$t0 currently has the new updated value
		
		lb $t2, 2($s0)		#holds the number of rows/pockets
		
		li $t1, 6
		addi $t1, $t1, 2	#just moved past the two bytes of top_mancala in gameboard
		add $t1, $t1, $t2
		add $t1, $t1, $t2	#move past the first row of pockets (occurs twice because each pocket is two digits)
		
		add $t1, $t1, $t2
		add $t1, $t1, $t2	#move past the second row of pockets (occurs twice because each pocket is two digits)
		
		add $s0, $s0, $t1	#update address so it now points to the 10s digit byte of bot_mancala
		
		li $t1, 10
		div $t0, $t1
		mflo $t1		#holds 10s place digit
		addi $t1, $t1, 48
		sb $t1, 0($s0)
		mfhi $t1		#holds 1s place digit
		addi $t1, $t1, 48
		sb $t1, 1($s0)
		
		move $v0, $s2
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
		
	topPlayer_CollectStones:
		blez $s2, stonesLessThanOrEqZero_CollectStones
		
		lb $t0, 1($s0)		#updated top_mancala byte
		add $t0, $t0, $s2
		sb $t0, 1($s0) 		#$t0 currently has the new updated value
		
		li $t1, 10
		div $t0, $t1
		mflo $t1		#holds 10s place digit
		addi $t1, $t1, 48
		sb $t1, 6($s0)
		mfhi $t1		#holds 1s place digit
		addi $t1, $t1, 48
		sb $t1, 7($s0)
		
		move $v0, $s2
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
		
	invalidPlayerChar_CollectStones:
	li $v0, -1
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	stonesLessThanOrEqZero_CollectStones:
	li $v0, -2
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
########################################
verify_move:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0				#address of gamestate construct
	move $s1, $a1				#origin pocket: number of pockets away from current player mancala
	move $s2, $a2				#distance: number of pockets to move away from the origin pocket (distance should equal num of stones in origin)
	
	lb $t0, 2($s0)				#stores number of rows
	bge $s1, $t0, invalidOriginPocket	#error if originPocket is greater than available rows
	
	lb $t0, 5($s0)				#stores ascii value of char of current player
	
	li $t1, 66				#check if current player is 'B'
	beq $t1, $t0, botPlayer_VerifyMove

	li $t1, 84				#check if current player is 'T'
	beq $t1, $t0, topPlayer_VerifyMove
	
	jr $ra
	botPlayer_VerifyMove:
		li $t2, 99				#check if distance is 99, can ignore validating origin_pocket
		beq $s2, $t2, botPlayerDistanceEq99
		
		#check if origin pocket has 0, branch if it does
		#check if distance is 0
		#check if distance is not equal to the stones in the origin_pocket
		move $t0, $s0
		addi $t0, $t0, 7
		
		lb $t1, 2($s0)
		add $t0, $t0, $t1
		add $t0, $t0, $t1
		add $t0, $t0, $t1
		add $t0, $t0, $t1			#address is now between the the last byte of gameboard and first byte of botPlayer in gameboard
		
		move $t1, $s1
		li $t2, -2
		mult $t1, $t2
		mflo $t1				#negative value of origin_pocket
		
		add $t0, $t0, $t1			#address is now right before the 1s place of the origin_pocket
		lb $t1, 0($t0)				#1s place digit
		addi $t1, $t1, -48
		
		addi $t0, $t0, -1
		lb $t2, 0($t0)
		addi $t2, $t2, -48
		
		li $t3, 10
		mult $t2, $t3
		mflo $t2
		add $t2, $t2, $t1			#$t2 is the number of stones in the origin pocket
		
		beqz $t2, originPocketZeroStones
		beqz $s2, distanceZeroOrNotEqToOrigin
		bne $s2, $t2, distanceZeroOrNotEqToOrigin
		
		li $v0, 1				#if no error, then move is legal? I THINK... PLEASE RECHECK
		j verifyMoveRegisterConvention
	topPlayer_VerifyMove:
		li $t2, 99				#check if distance is 99, can ignore validating origin_pocket
		beq $s2, $t2, topPlayerDistanceEq99
	
		move $t0, $s0
		addi $t0, $t0, 7			#currently at the first byte of 0th pocket
		add $t0, $t0, $s1			#move up to the first byte of origin pocket
		add $t0, $t0, $s1			#do it twice bc each pocket is represented as two digits
		
		lb $t1, 1($t0)				#10s place of origin_pocket
		addi $t1, $t1, -48			#convert char to its actual integer value
		li $t2, 10
		mult $t1, $t2
		mflo $t3				#$t1 holds the 10s digit of origin_pocket
		
		lb $t1, 2($t0)				#1s place of origin_pocket
		addi $t1, $t1, -48
		add $t3, $t3, $t1			#add the 1s place to $t1 to get actual number of stones of origin_pocket
		
		beqz $t3, originPocketZeroStones
		beqz $s2, distanceZeroOrNotEqToOrigin
		bne $s2, $t3, distanceZeroOrNotEqToOrigin
		
		li $v0, 1				#if no error, then move is legal? I THINK PLEASE RECHECK
		j verifyMoveRegisterConvention
	invalidOriginPocket:
		li $v0, -1
		j verifyMoveRegisterConvention
	originPocketZeroStones:
		li $v0, 0
		j verifyMoveRegisterConvention
	distanceZeroOrNotEqToOrigin:
		li $v0, -2
		j verifyMoveRegisterConvention
	topPlayerDistanceEq99:		#modify gamestate to be bot player
		li $v0, 2
		li $t0, 66
		sb $t0, 5($s0)
		j verifyMoveRegisterConvention
	botPlayerDistanceEq99:		#modify gamestate to be top player
		li $v0, 2
		li $t0, 84
		sb $t0, 5($s0)
		j verifyMoveRegisterConvention
	verifyMoveRegisterConvention:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
########################################
execute_move:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	move $s0, $a0		#address of gamestate construct
	move $s1, $a1		#number of pockets away from player mancala
	move $v0, $0		#set number of stones added to mancala as 0
	move $v1, $0		#empty $v1
	
	lb $t8, 4($s0)
	addi $t8, $t8, 1	#increment moves executed in gamestate
	sb $t8, 4($s0)
	
	move $t8, $s0
	addi $t8, $t8, 6	#address of 10s place byte of top mancala in gameboard is stored in $t8
	
	move $t9, $t8
	addi $t9, $t9, 2
	lb $t4, 2($s0)		#number of rows
	add $t9, $t9, $t4
	add $t9, $t9, $t4
	add $t9, $t9, $t4
	add $t9, $t9, $t4	#address of 10s place byte of bot mancala in gameboard is stored in $t9
	
	lb $t0, 5($s0)				#stores ascii value of char of current player
	li $t1, 66				#check if current player is 'B'
	beq $t1, $t0, botPlayer_ExecuteMove
	li $t1, 84				#check if current player is 'T'
	beq $t1, $t0, topPlayer_ExecuteMove
		
	topPlayer_ExecuteMove:
		move $t1, $s0
		addi $t1, $t1, 8			#currently at the first byte of 0th pocket
		add $t1, $t1, $s1			#move up to the first byte of origin pocket
		add $t1, $t1, $s1			#do it twice bc each pocket is represented as two digits
		
		#get distance/the value in origin_pocket
		lb $t2, 0($t1)				#10s place of origin_pocket
		addi $t2, $t2, -48			#convert char to its actual integer value
		li $t3, 10
		mult $t2, $t3
		mflo $t2				#$t1 holds the 10s digit of origin_pocket
		lb $t3, 1($t1)				#1s place of origin_pocket
		addi $t3, $t3, -48
		add $t2, $t2, $t3			#$t2 holds number of stones from origin_pocket, is the distance to travel

		li $t3 , 48
		sb $t3, 0($t1)				#we're using the stones in origin_pocket so empty the origin_pocket by setting it to zero in both digits
		sb $t3, 1($t1)
		addi $t1, $t1, -2			#moves are counterclockwise, so decrement address to move the current pocket down in a counterclockwise direction

		topPlayer_ExecuteMove_Loop:		#$t0 holds number of rows, $t1 holds current address, $t2 holds number of stones left to deposit
			addi $t2, $t2, -1		#remove one stone from stonesLeftToDeposit
			
			lb $t3, 0($t1)
			addi $t3, $t3, -48
			li $t4, 10
			mult $t3, $t4
			mflo $t3
			lb $t4, 1($t1)
			addi $t4, $t4, -48		#getting integer value of current pocket
			add $t3, $t3, $t4		#$t3 holds the integer value of stones in the current pocket
			
			beqz $t3, topPlayer_ExecuteMove_EmptyBeforeLastDeposit					#check if current pocket is empty
			j topPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue					#continue if it is not empty
			topPlayer_ExecuteMove_EmptyBeforeLastDeposit:						
				beqz $t2, topPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft		#if current pocket is empty, also check if this is last deposit
				j topPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue				#continue if this is not last deposit
				topPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft:
					bgt $t1, $t8, topPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft_inTopRow	#if it is last deposit, also check if current pocket is in top row
					j topPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue
					topPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft_inTopRow:
						li $t4, 1							#current pocket is empty, this is last deposit, pocket is in top row
						move $v1, $t4							#set $v1 to 1, then continue
						
						j topPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue
			topPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue:
			
			addi $t3, $t3, 1		#increase current pocket by one stone (that is removed from hand)
			
			beq $t1, $t8, topPlayer_ExecuteMove_GamestateUpdate		#if the updated pocket was top player's mancala, also update it in gamestate construct
			j topPlayer_ExecuteMove_GamestateUpdate_continue
			topPlayer_ExecuteMove_GamestateUpdate:
				sb $t3, 1($s0)
				addi $v0, $v0, 1					#if the updated pocket was top player's mancala, incremenet $v0 to reflect it
				j topPlayer_ExecuteMove_GamestateUpdate_continue
			topPlayer_ExecuteMove_GamestateUpdate_continue:
			
			li $t4, 10			#convert incremeneted integer value of current pocket back into double digit ascii char values
			div $t3, $t4
			mflo $t4
			addi $t4, $t4, 48
			sb $t4, 0($t1)
			mfhi $t4
			addi $t4, $t4, 48
			sb $t4, 1($t1)
			
			addi $t1, $t1, -2		#update address
			
			#conditionBuffer
			blt $t1, $t8, topPlayer_ExecuteMove_PreBotRow			#branch if no top row left (current address is below the top mancala address)
			bgtz $t2, topPlayer_ExecuteMove_Loop				#return to loop if there are stones remaining and top row pockets remaining
			j topPlayer_ExecuteMove_StillTopRow_NoStonesLeft 		#if there are still pockets left in top row to visit but there are no stones to deposit
			topPlayer_ExecuteMove_PreBotRow:
				blez $t2, topPlayer_ExecuteMove_PreBotRow_NoStonesLeft	#if there are no stones left to deposit but at the top player mancala, the turn ends
				j topPlayer_ExecuteMove_BotRowIterate			#if there are stones but no top pockets left, move onto iterating through the bot row
				
				topPlayer_ExecuteMove_BotRowIterate:
					addi $t1, $t1, 2				#address now points to the 10s place of top player mancala
					addi $t1, $t1, 2				#address now points to the 10s place byte of pocket#0 in top row
					
					lb $t4, 2($s0)
					add $t1, $t1, $t4
					add $t1, $t1, $t4				#address now points to the 10s place byte of pocket#5 in bot row
					
					topPlayer_ExecuteMove_BotRowIterateLoop:		###$t1 is current updated address
						addi $t2, $t2, -1				###$t2 is the number of stones left to deposit, it should be at least 1
												###$t3 holds the integer value of current pocket
						lb $t3, 0($t1)					###$t4 use as temperory variable value holder
						addi $t3, $t3, -48				###$t8 is the address at the 10s place digit of top mancala
						li $t4, 10					###$t9 is the address at the 10s place digit of bot mancala
						mult $t3, $t4
						mflo $t3
						lb $t4, 1($t1)
						addi $t4, $t4, -48		
						add $t3, $t3, $t4		#getting integer value of current pocket into $t3
						
						addi $t3, $t3, 1
						
						li $t4, 10			#convert incremeneted integer value of current pocket back into double digit ascii char values
						div $t3, $t4
						mflo $t4
						addi $t4, $t4, 48
						sb $t4, 0($t1)
						mfhi $t4
						addi $t4, $t4, 48
						sb $t4, 1($t1)
						
						addi $t1, $t1, 2		#update address
						
						#condition buffer
						bge $t1, $t9, topPlayer_ExecuteMove_BotRow_PreTopRow			#branch if no bot row left (current address is past the 10s place byte of the 0th bot pocket)
						bgtz $t2, topPlayer_ExecuteMove_BotRowIterateLoop			#return to loop if there are stones remaining and bot row pockets remaining
						j topPlayer_ExecuteMove_BotRow_StillBotRow_NoStonesLeft 		#if there are still pockets left in bot row to visit but there are no stones to deposit
						topPlayer_ExecuteMove_BotRow_PreTopRow:
							blez $t2, topPlayer_ExecuteMove_BotRow_StillBotRow_NoStonesLeft	#if there are no stones left to deposit and at the end of bot_mancala
							move $t1, $s0							#get address to the pocket#5 of top row to loop back to top row
							addi $t1, $t1, 6
							lb $t4, 2($s0)
							add $t1, $t1, $t4
							add $t1, $t1, $t4
							j topPlayer_ExecuteMove_Loop
						
	topPlayer_ExecuteMove_StillTopRow_NoStonesLeft:		#still pockets in top row left but 0 stones left: change the turn to bot player
		li $t4, 66
		sb $t4, 5($s0)
		j executeMoveRegisterConvention			#v0 and v1 should be updated in topPlayer_ExecuteMove_Loop
	topPlayer_ExecuteMove_PreBotRow_NoStonesLeft:		#last deposit at the top player's mancala: it is again the top player's turn
		li $v1, 2
		j executeMoveRegisterConvention			#v0 and v1 should be updated in topPlayer_ExecuteMove_Loop
	topPlayer_ExecuteMove_BotRow_StillBotRow_NoStonesLeft:
		li $t4, 66
		sb $t4, 5($s0)
		j executeMoveRegisterConvention
	botPlayer_ExecuteMove:
		move $t1, $t9				#address points to 10s place byte in bot player mancala
		addi $t1, $t1, -2			#address points to 10s place byte in pocket#0 of bot row
		
		li $t4, -1
		mult $s1, $t4
		mflo $t4
		add $t1, $t1, $t4
		add $t1, $t1, $t4			#address points to 10s place byte of origin pocket in bot row
		
		lb $t2, 0($t1)				#10s place of origin_pocket
		addi $t2, $t2, -48			#convert char to its actual integer value
		li $t3, 10
		mult $t2, $t3
		mflo $t2				#$t1 holds the 10s digit of origin_pocket
		lb $t3, 1($t1)				#1s place of origin_pocket
		addi $t3, $t3, -48
		add $t2, $t2, $t3			#$t2 holds number of stones from origin_pocket, is the distance to travel

		li $t3 , 48
		sb $t3, 0($t1)				#we're using the stones in origin_pocket so empty the origin_pocket by setting it to zero in both digits
		sb $t3, 1($t1)
		addi $t1, $t1, 2			#moves are counterclockwise, so increment address to move the current pocket down in a counterclockwise direction
		
		botPlayer_ExecuteMove_Loop:		#$t0 holds number of rows, $t1 holds current address, $t2 holds number of stones left to deposit
			addi $t2, $t2, -1		#remove one stone from stonesLeftToDeposit
			
			lb $t3, 0($t1)
			addi $t3, $t3, -48
			li $t4, 10
			mult $t3, $t4
			mflo $t3
			lb $t4, 1($t1)
			addi $t4, $t4, -48		#getting integer value of current pocket
			add $t3, $t3, $t4		#$t3 holds the integer value of stones in the current pocket
			
			beqz $t3, botPlayer_ExecuteMove_EmptyBeforeLastDeposit							#check if current pocket is empty
			j botPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue							#continue if it is not empty
			botPlayer_ExecuteMove_EmptyBeforeLastDeposit:						
				beqz $t2, botPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft				#if current pocket is empty, also check if this is last deposit
				j botPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue						#continue if this is not last deposit
				botPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft:
					blt $t1, $t9, botPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft_inBotRow	#if it is last deposit, also check if current pocket is in bot row
					j botPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue
					botPlayer_ExecuteMove_EmptyBeforeLastDeposit_checkStonesLeft_inBotRow:
						li $t4, 1									#current pocket is empty, this is last deposit, pocket is in bot row
						move $v1, $t4									#set $v1 to 1, then continue
						j botPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue
			botPlayer_ExecuteMove_EmptyBeforeLastDeposit_continue:
			
			addi $t3, $t3, 1		#increase current pocket by one stone (that is removed from hand)
			
			beq $t1, $t9, botPlayer_ExecuteMove_GamestateUpdate		#if the updated pocket was bot player's mancala, also update it in gamestate construct
			j botPlayer_ExecuteMove_GamestateUpdate_continue
			botPlayer_ExecuteMove_GamestateUpdate:
				sb $t3, 0($s0)
				addi $v0, $v0, 1					#if the updated pocket was bot player's mancala, incremenet $v0 to reflect it
				j botPlayer_ExecuteMove_GamestateUpdate_continue
			botPlayer_ExecuteMove_GamestateUpdate_continue:
			
			li $t4, 10			#convert incremeneted integer value of current pocket back into double digit ascii char values
			div $t3, $t4
			mflo $t4
			addi $t4, $t4, 48
			sb $t4, 0($t1)
			mfhi $t4
			addi $t4, $t4, 48
			sb $t4, 1($t1)
			
			addi $t1, $t1, 2		#update address
			
			#conditionBuffer
			bgt $t1, $t9, botPlayer_ExecuteMove_PreTopRow			#branch if no bot row left (current address is greater than the bot mancala address)
			bgtz $t2, botPlayer_ExecuteMove_Loop				#return to loop if there are stones remaining and bot row pockets remaining
			j botPlayer_ExecuteMove_StillBotRow_NoStonesLeft 		#if there are still pockets left in bot row to visit but there are no stones to deposit
			botPlayer_ExecuteMove_PreTopRow:
				blez $t2, botPlayer_ExecuteMove_PreTopRow_NoStonesLeft	#if there are no stones left to deposit but at the bot player mancala, the turn ends
				j botPlayer_ExecuteMove_TopRowIterate			#if there are stones but no bot pockets left, move onto iterating through the top row
				
				botPlayer_ExecuteMove_TopRowIterate:
					addi $t1, $t1, -2				#address now points to the 10s place of bot player mancala
					addi $t1, $t1, -2				#address now points to the 10s place byte of pocket#0 in bot row
					
					lb $t4, 2($s0)
					li $t3, -1
					mult $t4, $t3
					mflo $t4
					add $t1, $t1, $t4
					add $t1, $t1, $t4				#address now points to the 10s place byte of pocket#5 in top row
					
					botPlayer_ExecuteMove_BotRowIterateLoop:	###$t1 is current updated address
						addi $t2, $t2, -1			###$t2 is the number of stones left to deposit, it should be at least 1
											###$t3 holds the integer value of current pocket
						lb $t3, 0($t1)				###$t4 use as temperory variable value holder
						addi $t3, $t3, -48			###$t8 is the address at the 10s place digit of top mancala
						li $t4, 10				###$t9 is the address at the 10s place digit of bot mancala
						mult $t3, $t4
						mflo $t3
						lb $t4, 1($t1)
						addi $t4, $t4, -48		
						add $t3, $t3, $t4		#getting integer value of current pocket into $t3
						
						addi $t3, $t3, 1
						
						li $t4, 10			#convert incremeneted integer value of current pocket back into double digit ascii char values
						div $t3, $t4
						mflo $t4
						addi $t4, $t4, 48
						sb $t4, 0($t1)
						mfhi $t4
						addi $t4, $t4, 48
						sb $t4, 1($t1)
						
						addi $t1, $t1, -2		#update address
						
						#condition buffer
						ble $t1, $t8, botPlayer_ExecuteMove_TopRow_PreBotRow			#branch if no top row left (current address is below the 10s place byte of the 0th top row pocket)
						bgtz $t2, botPlayer_ExecuteMove_BotRowIterateLoop			#return to loop if there are stones remaining and bot row pockets remaining
						j botPlayer_ExecuteMove_TopRow_StillTopRow_NoStonesLeft 		#if there are still pockets left in bot row to visit but there are no stones to deposit
						botPlayer_ExecuteMove_TopRow_PreBotRow:
							blez $t2, botPlayer_ExecuteMove_TopRow_StillTopRow_NoStonesLeft	#if there are no stones left to deposit and at the end of top_mancala
							move $t1, $s0							#get address to the pocket#5 of bot row to loop back to top row
							addi $t1, $t1, 6
							lb $t4, 2($s0)
							add $t1, $t1, $t4
							add $t1, $t1, $t4
							j botPlayer_ExecuteMove_Loop
						
	botPlayer_ExecuteMove_StillBotRow_NoStonesLeft:			#still pockets in top row left but 0 stones left: change the turn to bot player
		li $t4, 84
		sb $t4, 5($s0)
		j executeMoveRegisterConvention				#v0 and v1 should be updated in topPlayer_ExecuteMove_Loop
	botPlayer_ExecuteMove_PreTopRow_NoStonesLeft:			#last deposit at the top player's mancala: it is again the top player's turn
		li $v1, 2
		j executeMoveRegisterConvention				#v0 and v1 should be updated in topPlayer_ExecuteMove_Loop
	botPlayer_ExecuteMove_TopRow_StillTopRow_NoStonesLeft:
		li $t4, 84
		sb $t4, 5($s0)
		j executeMoveRegisterConvention
	executeMoveRegisterConvention:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
#########################################
steal:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	move $s0, $a0				#address of gamestate construct
	move $s1, $a1				#destination pocket of previous turn's player. This should have only 1 stone. The corresponding pocket in the other row will be stolen from.
	
	move $t8, $s0
	addi $t8, $t8, 6	#address of 10s place byte of top mancala in gameboard is stored in $t8
	
	move $t9, $t8
	addi $t9, $t9, 2
	lb $t4, 2($s0)		#number of rows
	add $t9, $t9, $t4
	add $t9, $t9, $t4
	add $t9, $t9, $t4
	add $t9, $t9, $t4	#address of 10s place byte of bot mancala in gameboard is stored in $t9
	
	lb $t0, 5($s0)				#ascii char value of current player's turn AFTER execute move. use the other player's ascii char
	li $t1, 66				#ascii char of 'B'
	beq $t0, $t1, stealFromBot		#current char is 'B' so destination pocket is found in top row
	li $t1, 84
	beq $t0, $t1, stealFromTop		#current char is 'T' so destination pocket is found in bot row
	
	stealFromBot:
		move $t0, $t8		#address of 10s place byte of top mancala
		move $t1, $s1		#distance to destination pocket
		addi $t0, $t0, 2	#addres of 10s place byte of pocket#0 in top row
		li $t3, 2
		mult $t1, $t3
		mflo $t1
		add $t0, $t0, $t1	#update address to 10s place byte of destination pocket
		
		li $t1, 48
		sb $t1, 0($t0)		#empty the destination pocket
		sb $t1, 1($t0)
		
		lb $t1, 2($s0)		#number of rows
		li $t2, 2
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	#update address to 10s place byte of pocket to steal
		
		lb $t1, 0($t0)
		addi $t1, $t1, -48
		li $t2, 10
		mult $t1, $t2
		mflo $t1
		lb $t2, 1($t0)
		addi $t2, $t2, -48		
		add $t1, $t1, $t2	#t1 holds the value of pocket to steal from
		
		li $t2, 48
		sb $t2, 0($t0)		#empty the pocket to steal from
		sb $t2, 1($t0)
		
		addi $t1, $t1, 1	#increase stones stolen by one because it was used to steal in the current player's row
		move $v0, $t1		#number of stones added to mancala is set to v0
		
		lb $t2, 1($s0)
		add $t1, $t1, $t2
		sb $t1, 1($s0)		#add total stones stolen to bot player mancala then update bot player mancala in gamestate
		
		li $t2, 10		#update new top player mancala in gameboard
		div $t1, $t2
		mflo $t1
		addi $t1, $t1, 48
		sb $t1, 0($t8)
		mfhi $t1
		addi $t1, $t1, 48
		sb $t1, 1($t8)
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
	
	stealFromTop:		#destination of bot player row
		move $t0, $t9
		move $t1, $s1
		addi $t0, $t0, -2
		li $t3, -2
		mult $t1, $t3
		mflo $t1
		add $t0, $t0, $t1	#update address to 10s place byte of destination pocket
		
		li $t1, 48
		sb $t1, 0($t0)		#empty the destination pocket
		sb $t1, 1($t0)
		
		lb $t1, 2($s0)
		li $t2, -2
		mult $t1, $t2
		mflo $t1
		add $t0, $t0, $t1	#update address to 10s place byte of pocket to steal
		
		lb $t1, 0($t0)
		addi $t1, $t1, -48
		li $t2, 10
		mult $t1, $t2
		mflo $t1
		lb $t2, 1($t0)
		addi $t2, $t2, -48		
		add $t1, $t1, $t2	#t1 holds the value of pocket to steal from
		
		li $t2, 48
		sb $t2, 0($t0)		#empty the pocket to steal from
		sb $t2, 1($t0)
		
		addi $t1, $t1, 1	#increase stones stolen by one because it was used to steal in the current player's row
		move $v0, $t1		#number of stones added to mancala is set to v0
		
		lb $t2, 0($s0)
		add $t1, $t1, $t2
		sb $t1, 0($s0)		#add total stones stolen to bot player mancala then update bot player mancala in gamestate
		
		li $t2, 10		#update new bot player mancala in gameboard
		div $t1, $t2
		mflo $t1
		addi $t1, $t1, 48
		sb $t1, 0($t9)
		mfhi $t1
		addi $t1, $t1, 48
		sb $t1, 1($t9)
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
###########################################
check_row:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $t9, 4($sp)
	
	move $s0, $a0
	
	move $t8, $s0
	addi $t8, $t8, 8	#address of 10s place byte of pocket#0 in top row
	
	move $t9, $t8
	lb $t0, 2($s0)		#number of rows
	add $t9, $t9, $t0
	add $t9, $t9, $t0	#address of 10s place byte of pocket#5 in bot row
	
	lb $t0, 2($s0)		#number of rows	6
	li $t1, 0		#loop counter 0,1,2,3,4,5
	li $t2, 48
	
	checkTopRowLoop:
		lb $t3, 0($t8)
		bne $t3, $t2, topRowNotEmpty	#if any byte in any pocket in top row is not '48' then it is not empty
		lb $t3, 1($t8)
		bne $t3, $t2, topRowNotEmpty
		addi $t8, $t8, 2		#move up address to 10s place byte of next pocket
		addi $t1, $t1, 1		#increment counter
		blt $t1, $t0, checkTopRowLoop 
	#occurs if top row is empty
	li $t7, 0				#t7 holds the total of every stone in bot pocket
	lb $t0, 2($s0)				#number of rows	6
	li $t1, 0				#loop counter 0,1,2,3,4,5
	sumBotRowLoop:				#sum up every pocket in bot row then add it to bot mancala. Also update gamestate
		lb $t3, 0($t9)
		addi $t3, $t3, -48
		li $t4, 10
		mult $t3, $t4
		mflo $t3			#first byte is 10s place so multiply it by 10
		lb $t4, 1($t9)
		addi $t4, $t4, -48
		add $t3, $t3, $t4		#add 1s place value to 10s place value
		add $t7, $t7, $t3		#add it to t7
		sb $t2, 0($t9)			#empty current pocket bytes
		sb $t2, 1($t9)
		addi $t9, $t9, 2		#move up address to 10s place byte of next pocket
		addi $t1, $t1, 1		#increment counter
		blt $t1, $t0, sumBotRowLoop
	lb $t3, 0($t9)				#address currently points to 10s place byte of bot mancala
	addi $t3, $t3, -48
	li $t4, 10
	mult $t3, $t4
	mflo $t3
	lb $t4, 1($t9)
	addi $t4, $t4, -48
	add $t3, $t3, $t4
	add $t7, $t7, $t3			#add number of stones in mancala to t7
	
	sb $t7, 0($s0)				#update total stones in bot row in gamestate construct
	
	li $t4, 10
	div $t7, $t4
	mflo $t7
	sb $t7, 0($t9)
	mfhi $t7
	sb $t7, 1($t9)				#update bot mancala in gameboard to have total t7 value
	j gameEndedNowCompareMancala
	###############
	topRowNotEmpty:				#in the case top row is not empty so now check bot row
		lb $t0, 2($s0)			#number of rows	6
		li $t1, 0			#loop counter 0,1,2,3,4,5
		li $t2, 48
		
		checkBotRowLoop:
			lb $t3, 0($t9)
			bne $t3, $t2, bothRowNotEmpty		#if any byte in bot row is not '48', bot row is not empty
			lb $t3, 1($t9)
			bne $t3, $t2, bothRowNotEmpty
			addi $t9, $t9, 2			#move up address
			addi $t1, $t1, 1			#increment counter
			blt $t1, $t0, checkBotRowLoop
		#this occurs if bot row is empty
		li $t7, 0				#t7 holds the total of every stone in bot pocket
		lb $t0, 2($s0)				#number of rows	6
		li $t1, 0				#loop counter 0,1,2,3,4,5
		
		move $t8, $s0
		addi $t8, $t8, 8	#reset address of $t9 to loop through top row for its sum
		
		sumTopRowLoop:
			lb $t3, 0($t8)
			addi $t3, $t3, -48
			li $t4, 10
			mult $t3, $t4
			mflo $t3			#first byte is 10s place so multiply it by 10
			lb $t4, 1($t8)
			addi $t4, $t4, -48
			add $t3, $t3, $t4		#add 1s place value to 10s place value
			add $t7, $t7, $t3		#add it to t7
			sb $t2, 0($t8)			#empty current pocket bytes
			sb $t2, 1($t8)
			addi $t8, $t8, 2		#move up address to 10s place byte of next pocket
			addi $t1, $t1, 1		#increment counter
			blt $t1, $t0, sumTopRowLoop
		
		move $t8, $s0
		addi $t8, $t8, 6
		
		lb $t3, 0($t8)				#address currently points to 10s place byte of top mancala
		addi $t3, $t3, -48
		li $t4, 10
		mult $t3, $t4
		mflo $t3
		lb $t4, 1($t8)
		addi $t4, $t4, -48
		add $t3, $t3, $t4
		add $t7, $t7, $t3			#add number of stones in mancala to t7
	
		sb $t7, 1($s0)				#update total stones in top row in gamestate construct
	
		li $t4, 10
		div $t7, $t4
		mflo $t7
		sb $t7, 0($t8)
		mfhi $t7
		sb $t7, 1($t8)				#update top mancala in gameboard to have total t7 value
		j gameEndedNowCompareMancala
	
	gameEndedNowCompareMancala:
		li $t0, 68
		sb $t0, 5($s0)				#update player turn to 'D' for done
		li $v0, 1				#row was found to be empty so set v0 to 1
		j comparingMancalas
		
	bothRowNotEmpty:
		li $v0, 0
		
		comparingMancalas:
			lb $t0, 0($s0)				#bot mancala value
			lb $t1, 1($s0)				#top mancala value
			beq $t0, $t1, mancalaEqual		#mancala values are equal
			bgt $t0, $t1, botMancalaGreater
			bgt $t1, $t0, topMancalaGreater
		mancalaEqual:
			li $v1, 0
			j checkMovesRegisterConvention
		botMancalaGreater:
			li $v1, 1
			j checkMovesRegisterConvention
		topMancalaGreater:
			li $v1, 2
			j checkMovesRegisterConvention
			
	checkMovesRegisterConvention:		
		lw $s0, 0($sp)
		lw $t9, 4($sp)
		addi $sp, $sp, 8
		jr $ra
##################################
load_moves:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
	move $s0, $a0			#starting address of moves array
	move $s1, $a1			#filename
	
	li $t7, 0			#number of moves added - to be returned
	
	move $a0, $s1			#address of filename string
	li $a1, 0			#read-only flag for syscall
	li $a2, 0			#ignore mode
	li $v0, 13			#load syscall 13
	syscall				#call syscall
	move $t0, $v0			#$s2 contains file descriptor
	bltz $t0, loadMoves_fileError	#if file open error, return -1 for $v0
	
	addi $sp, $sp, -4		#store $ra of load_game onto $sp
	sw $ra, 0($sp)
	move $a0, $t0			#file descriptor as parameter
	jal load_game_Helper		#first row of file - top_mancala
	move $t8, $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4		#t8 holds number of columns - size of each subarray
	
	addi $sp, $sp, -4		#store $ra of load_game onto $sp
	sw $ra, 0($sp)
	move $a0, $t0			#file descriptor as parameter
	jal load_game_Helper		#first row of file - top_mancala
	move $t9, $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4		#t9 holds number of rows - number of subarrays in the main array
	
	li $t1, 9				#range to determine invalid moves
	
	li $t2, 0				#counter
	repeatRowLoop:				#creating multiple subarrays
		li $t3, 0			#counter
		repeatColumnLoop:		#creating one specific subarray
			addi $sp, $sp, -4
			li $v0, 14		#load syscall 14 into $v0 to read from file
			move $a0, $t0		#load file descriptor into $a0
			move $a1, $sp		#load address of input buffer
			li $a2, 1		#number of characters to read which is only 1
			syscall
			lb $t4, 0($sp)
			addi $sp, $sp, 4
			
			addi $t4, $t4, -48
			bltz $t4, invalidMoveFirstChar
			bgt $t4, $t1, invalidMoveFirstChar	#if t4 is not between 0-9, invalidMove
			
			addi $sp, $sp, -4
			li $v0, 14		#load syscall 14 into $v0 to read from file
			move $a0, $t0		#load file descriptor into $a0
			move $a1, $sp		#load address of input buffer
			li $a2, 1		#number of characters to read which is only 1
			syscall
			lb $t5, 0($sp)
			addi $sp, $sp, 4
			
			addi $t5, $t5, -48
			bltz $t5, invalidMove
			bgt $t5, $t1, invalidMove	#if t5 is not between 0-9, invalidMove
			bgt $t5, $t1, invalidMove	#if t4 is not between 0-9, invalidMove
			
			li $t6, 10
			mult $t4, $t6
			mflo $t4
			add $t4, $t4, $t5		#get the value
			
			sb $t4, 0($s0)
			addi $s0, $s0, 1		#move up address to the next byte
			
			addi $t7, $t7, 1		#increment number of moves
			
			addi $t3, $t3, 1		#increment counter
			blt $t3, $t8, repeatColumnLoop
			j loadMoves_continue
			
			invalidMove:
				li $t4, -1
				sb $t4, 0($s0)
				addi $s0, $s0, 1	#move up address to the next byte
				addi $t7, $t7, 1	#increment number of moves
				addi $t3, $t3, 1	#increment counter
				blt $t3, $t8, repeatColumnLoop
			
			invalidMoveFirstChar:
				addi $sp, $sp, -4
				li $v0, 14		#load syscall 14 into $v0 to read from file
				move $a0, $t0		#load file descriptor into $a0
				move $a1, $sp		#load address of input buffer
				li $a2, 1		#number of characters to read which is only 1
				syscall
				lb $t5, 0($sp)
				addi $sp, $sp, 4
			
				li $t4, -1
				sb $t4, 0($s0)
				addi $s0, $s0, 1	#move up address to the next byte
				addi $t7, $t7, 1	#increment number of moves
				addi $t3, $t3, 1	#increment counter
				blt $t3, $t8, repeatColumnLoop
		
		loadMoves_continue:		#if it is not the last row, add a 99 at the end. Otherwise, dont add a 99 at the end
			move $t6, $t9
			addi $t6, $t6, -1	#number of columns -1 to not add 99 to the last move
		
			beq $t2, $t6, loadMoves_lastRow		#add 99 to the end
			li $t4, 99
			sb $t4, 0($s0)
			addi $s0, $s0, 1			#move up address to the next byte
			addi $t7, $t7, 1			#increment number of moves
			addi $t2, $t2, 1			#increment counter
			blt $t2, $t9, repeatRowLoop
		
			loadMoves_lastRow:	#dont add 99 to the end
				move $v0, $t7
				lw $s0, 0($sp)
				lw $s1, 4($sp)
				addi $sp, $sp, 8
				jr $ra

	loadMoves_fileError:
		li $v0, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
###################################################		
steal_destinationHelper:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0		#address of gamestate construct
	move $s1, $a1		#number of pockets away from current player mancala that the origin pocket is at
	move $s2, $a2		#number of stones in current pocket(distance)
	
	lb $t0, 2($s0)		#number of rows
	
	move $t8, $s0
	addi $t8, $t8, 6	#address of 10s place byte of top mancala
	
	move $t9, $t8
	addi $t9, $t9, 2
	add $t9, $t9, $t0
	add $t9, $t9, $t0
	add $t9, $t9, $t0
	add $t9, $t9, $t0	#address of 10s place byte of bot mancala
	
	lb $t0, 5($s0)		#ascii char of current player turn#this is before execute move so nothing needs to be changed	B=66, T=84
	
	li $t1, 66
	beq $t0, $t1, steal_destinationHelper_BotMancala
	li $t1, 84
	beq $t0, $t1, steal_destinationHelper_TopMancala
	
	steal_destinationHelper_BotMancala:
		move $t1, $t9		#address points to 10s place byte in bot player mancala
		addi $t1, $t1, -2	#address points to 10s place byte in pocket#0 of bot row
		
		li $t4, -1
		mult $s1, $t4
		mflo $t4
		add $t1, $t1, $t4
		add $t1, $t1, $t4	#address points to 10s place byte of origin pocket in bot row
		
		#addi $t1, $t1, 2	#moving counterclockwise, increment address to point to next pocket
		
		steal_destinationHelper_BotMancalaLoop:
			addi $s2, $s2, -1		#remove one stone from stonesLeftToDeposit
			addi $t1, $t1, 2		#update address up the bot row
			#condition buffer
			bgt $t1, $t9, steal_destinationHelper_BotMancala_PreTopRow		#branch if no bot row left (current address is greater than the bot mancala address)
			bgtz $s2, steal_destinationHelper_BotMancalaLoop			#return to loop if there are stones remaining and bot row pockets remaining
			j steal_destinationHelper_BotMancala_StillBotRow_NoStonesLeft 		#if there are still pockets left in bot row to visit but there are no stones to deposit
			steal_destinationHelper_BotMancala_PreTopRow:
				blez $s2, steal_destinationHelper_BotMancala_endAtBotMancala	#if there are no stones left to deposit but at the bot player mancala, the turn ends
				j steal_destinationHelper_BotMancala_TopRowIterate		#if there are stones but no bot pockets left, move onto iterating through the top row
			steal_destinationHelper_BotMancala_TopRowIterate:
				addi $t1, $t1, -2				#address now points to the 10s place of bot player mancala
				addi $t1, $t1, -2				#address now points to the 10s place byte of pocket#0 in bot row
				lb $t4, 2($s0)                  		#number of rows
				li $t3, -1
				mult $t4, $t3
				mflo $t4                        		#negative number of rows
				add $t1, $t1, $t4
				add $t1, $t1, $t4				#address now points to the 10s place byte of pocket#5 in top row
				steal_destinationHelper_BotMancala_TopRowIterateLoop:
					addi $s2, $s2, -1	#remove one stone from stonesLeftToDeposit
					addi $t1, $t1, -2	#update address down the top row
					#condition buffer
					##
					ble $t1, $t8, steal_destinationHelper_BotMancala_PreBotRow					#branch if no top row left (current address is below the 10s place byte of the 0th top row pocket)
					bgtz $s2, steal_destinationHelper_BotMancala_TopRowIterateLoop					#return to loop if there are stones remaining and bot row pockets remaining
					j steal_destinationHelper_BotMancala_TopRow_StillTopRow_NoStonesLeft 				#if there are still pockets left in top row to visit but there are no stones to deposit
					steal_destinationHelper_BotMancala_PreBotRow:
						blez $s2, steal_destinationHelper_BotMancala_TopRow_StillTopRow_NoStonesLeft		#if there are no stones left to deposit and at the end of top_mancala
						move $t1, $s0										#get address to the pocket#5 of bot row to loop back to top row
						addi $t1, $t1, 8
						lb $t4, 2($s0)
						add $t1, $t1, $t4
						add $t1, $t1, $t4
						j steal_destinationHelper_BotMancalaLoop	
		#exit loop with update address of final destination pocket in $t1
	steal_destinationHelper_BotMancala_StillBotRow_NoStonesLeft:	#inside the bot row, no stones left
		#end case
		#lb $s5, 0($t1)
		#lb $s6, 1($t1)
		
		li $t4, -1
		mult $t1, $t4
		mflo $t1
		add $v0, $t9, $t1
		li $t4, 2
		div $v0, $t4
		mflo $v0
		addi $v0, $v0, -1
		j steal_destinationHelper_end
	steal_destinationHelper_BotMancala_endAtBotMancala:		#this is not important 
		li $t4, -1
		mult $t1, $t4
		mflo $t1
		add $v0, $t9, $t1
		j steal_destinationHelper_end
	steal_destinationHelper_BotMancala_TopRow_StillTopRow_NoStonesLeft:
		move $t1, $s0										#get address to the pocket#5 of bot row to loop back to top row
		addi $t1, $t1, 8
		lb $t4, 2($s0)
		add $t1, $t1, $t4
		add $t1, $t1, $t4
		
		#lb $s5, 0($t1)
		#lb $s6, 1($t1)
		li $t4, -1
		mult $t1, $t4
		mflo $t1
		add $v0, $t9, $t1
		li $t4, 2
		div $v0, $t4
		mflo $v0
		addi $v0, $v0, -1
		j steal_destinationHelper_end
#####################################################################################################################################################################################################################
	steal_destinationHelper_TopMancala:
		move $t1, $t8		#address points to 10s place byte in top player mancala
		addi $t1, $t1, 2	#address points to 10s place byte in pocket#0 of top row
		
		add $t1, $t1, $s1
		add $t1, $t1, $s1	#address points to 10s place byte of origin pocket in top row
		
		#addi $t1, $t1, 2	#moving counterclockwise, increment address to point to next pocket
		
		steal_destinationHelper_TopMancalaLoop:
			addi $s2, $s2, -1		#remove one stone from stonesLeftToDeposit
			addi $t1, $t1, -2		#update address down the top row
			#condition buffer
			ble $t1, $t8, steal_destinationHelper_TopMancala_PreBotRow		#branch if no top row left (current address is less than top mancala address)
			bgtz $s2, steal_destinationHelper_TopMancalaLoop			#return to loop if there are stones remaining and top row pockets remaining
			j steal_destinationHelper_TopMancala_StillTopRow_NoStonesLeft 		#if there are still pockets left in top row to visit but there are no stones to deposit
			steal_destinationHelper_TopMancala_PreBotRow:
				blez $s2, steal_destinationHelper_TopMancala_endAtTopMancala	#if there are no stones left to deposit but at the top player mancala, the turn ends
				j steal_destinationHelper_TopMancala_BotRowIterate		#if there are stones but no bot pockets left, move onto iterating through the top row
			steal_destinationHelper_TopMancala_BotRowIterate:
				addi $t1, $t1, 2				#address now points to the 10s place of top player mancala
				
				lb $t4, 2($s0)                  		#number of rows
				add $t1, $t1, $t4
				add $t1, $t1, $t4				#address now points to the 10s place byte of pocket#5 in bot row
				addi $s2, $s2, -1
				steal_destinationHelper_TopMancala_BotRowIterateLoop:
					addi $s2, $s2, -1	#remove one stone from stonesLeftToDeposit
					addi $t1, $t1, 2	#update address down the top row
					#condition buffer
					##
					bge $t1, $t9, steal_destinationHelper_TopMancala_PreTopRow					#branch if no bot row left (current address is past the 10s place byte of the 0th bot pocket)
					bgtz $s2, steal_destinationHelper_TopMancala_BotRowIterateLoop					#return to loop if there are stones remaining and bot row pockets remaining
					j steal_destinationHelper_TopMancala_BotRow_StillBotRow_NoStonesLeft 				#if there are still pockets left in top row to visit but there are no stones to deposit
					steal_destinationHelper_TopMancala_PreTopRow:
						blez $s2, steal_destinationHelper_TopMancala_BotRow_StillBotRow_NoStonesLeft		#if there are no stones left to deposit and at the end of top_mancala
						move $t1, $s0										#get address to the pocket#5 of bot row to loop back to top row
						addi $t1, $t1, 6
						lb $t4, 2($s0)
						add $t1, $t1, $t4
						add $t1, $t1, $t4
						j steal_destinationHelper_TopMancalaLoop	
		#exit loop with update address of final destination pocket in $t1
	steal_destinationHelper_TopMancala_StillTopRow_NoStonesLeft:	#inside the bot row, no stones left
		#end case
		#lb $s5, 0($t1)
		#lb $s6, 1($t1)
		
		li $t4, -1
		mult $t8, $t4
		mflo $t8
		add $v0, $t1, $t8
		li $t4, 2
		div $v0, $t4
		mflo $v0
		addi $v0, $v0, -1
		j steal_destinationHelper_end
	steal_destinationHelper_TopMancala_endAtTopMancala:		#this is not important 
		li $t4, -1
		mult $t1, $t4
		mflo $t1
		add $v0, $t9, $t1
		j steal_destinationHelper_end
	steal_destinationHelper_TopMancala_BotRow_StillBotRow_NoStonesLeft:
		move $t1, $s0										#get address to the pocket#5 of bot row to loop back to top row
		addi $t1, $t1, 6
		lb $t4, 2($s0)
		add $t1, $t1, $t4
		add $t1, $t1, $t4
		
		#lb $s5, 0($t1)
		#lb $s6, 1($t1)
		
		li $t4, -1
		mult $t8, $t4
		mflo $t8
		add $v0, $t1, $t8
		li $t4, 2
		div $v0, $t4
		mflo $v0
		addi $v0, $v0, -1
		j steal_destinationHelper_end
#####################################################################################################################################################################################################################
	steal_destinationHelper_end:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
###################################################
play_game:
	addi $sp, $sp, -36
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	sw $ra, 32($sp)
	
	move $s0, $a0		#filename holding moves
	move $s1, $a1		#filename holding board
	move $s2, $a2		#address of gamestate construct
	move $s3, $a3		#address of array of moves
	lb $s4, 36($sp)		#integer value of number of moves to execute
	
	#initialize moves
	move $a0, $s3			#address of array of moves
	move $a1, $s0			#filename holding moves
	jal load_moves
	move $s7, $v0			#number of moves stored into the array
	bltz $s7, playGame_FileError	#if number of moves is a negative number, then there was an error reading from the file
	lb $s4, 36($sp)		#integer value of number of moves to execute
	
	#initialize board
	move $a0, $s2			#address of gamestate construct
	move $a1, $s1			#filename holding board
	jal load_game
	move $t0, $v0
	blez  $t0, playGame_FileError	#if v0 is 0, number of stones exceeds limit. If negative, file reading error
	move $t0, $v1
	blez $t0, playGame_FileError	#if v1 is 0, number of stones exceeds limit. If negative, file reading error
	
	lb $s4, 36($sp)		#integer value of number of moves to execute
	blez $s4, numberMovesBad	#check if numberOfMovesToExecute is less than or equal to zero
	
	move $s1, $s3		#store base address of moves array
	add $s1, $s1, $s7	#end index of moves array
	
	#for loop (number of moves to execute)
		#skip invalid moves
	li $s5, 0				#for loop counter - compare with number of moves to execute stored in $s4 - in the end it will be number of moves executed
	playGame_Loop:
##########################		
		move $a0, $s2
		jal check_row			
		bgtz $v0, playGame_emptyRow	#a row is empty so the game is finished
		
		#check if ive used all the moves in the move array
		#s3 address is incremented each time a move is used and s7 holds the number of moves added to the array
		#if s3 = base address of moves array + s7
		
		beq $s3, $s1, playGame_endMiddle			#if address of moves array points to end of moves array, exit
	
	
		lb $t0, 0($s3)			#load the move number in $t0
		bltz $t0, playGame_invalidMove	#current move is invalid
		
		li $t1, 99
		beq $t0, $t1, playGame_forceTurnChange
		
		#rest of all moves must be valid
			#first verify
			#then execute
				#if possible, steal
				#then this turn is done. Execute_move already changes turn. Go to next turn
		
		lb $t0, 0($s3)			#load the move number in $t0
		move $a0, $s2
		lb $a1, 5($s2)
		move $a2, $t0
		jal get_pocket			#returns the number of stones in this pocket
		move $s6, $v0			#store in s6 the number of stones in the current pocket
		
		lb $t0, 0($s3)			#load the move number in $t0
		move $a0, $s2
		move $a1, $t0
		move $a2, $s6
		jal verify_move
		
		li $t1, 1
		bne $v0, $t1, playGame_notValidExecuteSoSkip	#notValidExecute
		
		lb $t0, 0($s3)			#load the move number in $t0
		move $a0, $s2
		move $a1, $t0
		jal execute_move
		
		li $t1, 1
		beq $v1, $t1, playGame_steal
		j playGame_loopContinue
		playGame_steal:
		
			move $a0, $s2		#address of gamestate construct
			lb $a1, 0($s3)		#distance from current player mancala
			move $a2, $s6		#number of stones in current pocket (distance)
			jal steal_destinationHelper
			move $a1, $v0
		
			move $a0, $s2
			lb $t0, 0($s3)			#load the move number in $t0
			move $a1, $a1
			jal steal
			j playGame_loopContinue
		playGame_loopContinue:
		addi $s5, $s5, 1		#for loop counter
		addi $s3, $s3, 1		#update address of moves array for next byte
		
		beq $s5, $s7, playGame_endMiddle
		lb $s4, 36($sp)		#integer value of number of moves to execute
		blt $s5, $s4, playGame_Loop
		j playGame_endMiddle
		


#############


	j playGame_DoneWithMovesArray
	
	playGame_invalidMove:
		addi $s3, $s3, 1		#update address for next byte in moves array
		beq $s5, $s7, playGame_endMiddle
		lb $s4, 36($sp)		#integer value of number of moves to execute
		blt $s5, $s4, playGame_Loop
		j playGame_endMiddle
	playGame_forceTurnChange:
		move $a0, $s2
		li $a1, 0
		li $a2, 99
		jal verify_move
		addi $s5, $s5, 1		#for loop counter
		addi $s3, $s3, 1		#update address of moves array for next byte
		beq $s5, $s7, playGame_endMiddle
		lb $s4, 36($sp)		#integer value of number of moves to execute
		blt $s5, $s4, playGame_Loop
		j playGame_endMiddle
	playGame_DoneWithMovesArray:
		move $a0, $s2
		jal check_row
		bgtz $v0, playGame_emptyRow
	playGame_notValidExecuteSoSkip:
		addi $s3, $s3, 1			#update address of moves array for next byte
		beq $s5, $s7, playGame_endMiddle
		lb $s4, 36($sp)		#integer value of number of moves to execute
		blt $s5, $s4, playGame_Loop
		j playGame_endMiddle
	playGame_endMiddle:
		move $a0, $s2
		jal check_row
		move $v0, $v0
		move $v1, $s5
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36
		jr  $ra
	playGame_emptyRow:
		move $v0, $v1
		move $v1, $s5
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36
		jr  $ra
	numberMovesBad:
		move $a0, $s2
		jal check_row
		move $v0, $v1
		li $v1, 0		#number of valid moves executed
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36
		jr  $ra
	playGame_FileError:
		li $v0, -1
		li $v1, -1
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		lw $ra, 32($sp)
		addi $sp, $sp, 36
		jr  $ra
###################################################
print_board:
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $a0
	move $t0, $s0
	li $v0, 11	#syscall 11 to print ascii character
	
	lb $t1, 2($s0)	#number of rows
	
	move $t0, $s0
	addi $t0, $t0, 6
	
	lb $a0, 0($t0)		#print 10s place byte of top mancala
	addi $t0, $t0, 1	#update address
	syscall
	
	lb $a0, 0($t0)		#print 1s place byte of top mancala
	addi $t0, $t0, 1	#update address
	syscall
	
	li $a0, 0xA		#print newline
	syscall

	move $t2, $s0
	addi $t2, $t2, 8
	add $t2, $t2, $t1
	add $t2, $t2, $t1
	add $t2, $t2, $t1
	add $t2, $t2, $t1
	
	lb $a0, 0($t2)		#print 10s place byte of bot mancala
	addi $t2, $t2, 1	#update address
	syscall
	
	lb $a0, 0($t2)		#print 10s place byte of bot mancala
	syscall
	
	li $a0, 0xA		#print newline
	syscall
	
	move $t2, $s0
	addi $t2, $t2, 8		#address at 10s place byte of pocket#0 of top row
	li $t3, 0			#counter
	printGameBoardLoopTop:
		lb $a0, 0($t2)		#print 10s place byte
		addi $t2, $t2, 1	#update address
		syscall
		
		lb $a0, 0($t2)		#print 10s place byte
		addi $t2, $t2, 1	#update address
		syscall
		
		addi $t3, $t3, 1
		blt $t3, $t1, printGameBoardLoopTop
		
	li $a0, 0xA		#print newline
	syscall
	
	li $t3, 0			#counter
	printGameBoardLoopBot:
		lb $a0, 0($t2)		#print 10s place byte
		addi $t2, $t2, 1	#update address
		syscall
		
		lb $a0, 0($t2)		#print 10s place byte
		addi $t2, $t2, 1	#update address
		syscall
		
		addi $t3, $t3, 1
		blt $t3, $t1, printGameBoardLoopBot
		
	lw $s0, 0($sp)
	addi $sp, $sp, 4	
	jr $ra
#############################
write_board:
	move $t8, $a0		#t8 holds address of gamestate
	move $t9, $t8		#t9 holds address of gamestate
	
	addi $sp, $sp, -12
	move $t4, $sp		#t4 holds address of sp at 'o' in output
	li $t0, 'o'
	sb $t0, 0($sp)
	li $t0, 'u'
	sb $t0, 1($sp)
	li $t0, 't'
	sb $t0, 2($sp)
	li $t0, 'p'
	sb $t0, 3($sp)
	li $t0, 'u'
	sb $t0, 4($sp)
	li $t0, 't'
	sb $t0, 5($sp)
	li $t0, '.'
	sb $t0, 6($sp)
	li $t0, 't'
	sb $t0, 7($sp)
	li $t0, 'x'
	sb $t0, 8($sp)
	li $t0, 't'
	sb $t0, 9($sp)
	li $t0, '\0'
	sb $t0, 10($sp)
	
	li $v0, 13
	move $a0, $t4
	li $a1, 1
	li $a2, 0
	syscall
	move $t0, $v0		#t0 holds file descriptor
	addi $sp, $sp, 12	#remove all previous letters
	
	lb $t1, 2($t8)		#t1 holds the number of rows
	li $t2, 0
	addi $t2, $t2, 3
	addi $t2, $t2, 3
	add $t2, $t2, $t1
	add $t2, $t2, $t1
	addi $t2, $t2, 1
	add $t2, $t2, $t1
	add $t2, $t2, $t1
	addi $t2, $t2, 1
	
	move $a2, $t2		#length of characters to write
	
	li $t3, -1
	mult $t2, $t3
	mflo $t2
	add $sp, $sp, $t2	#decrement stack pointer by the number of bytes we want to use
	
	li $v0, 15		#syscall to read characters
	move $a0, $t0		#file descriptor
	move $a1, $sp		#address of stack pointer starting at the first character of string to write

	addi $t8, $t8, 6
	lb $t2, 0($t8)		#10s place byte of top mancala
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	
	addi $t8, $t8, 1
	lb $t2, 0($t8)		#1s place byte of top mancala
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	
	li $t2, 0xA
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	
	move $t8, $t9		#recopy proper address
	addi $t8, $t8, 8
	add $t8, $t8, $t1
	add $t8, $t8, $t1
	add $t8, $t8, $t1
	add $t8, $t8, $t1
	
	lb $t2, 0($t8)		#10s place byte of bot mancala
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	addi $t8, $t8, 1
	
	lb $t2, 0($t8)		#1s place byte of bot mancala
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	
	li $t2, 0xA
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	
	move $t8, $t9		#recopy proper address
	addi $t8, $t8, 8
	
	li $t3, 0
	writeGameBoardLoopTop:
		lb $t2, 0($t8)		#10s place byte of bot mancala
		sb $t2, 0($sp)
		addi $sp, $sp, 1
		addi $t8, $t8, 1
	
		lb $t2, 0($t8)		#1s place byte of bot mancala
		sb $t2, 0($sp)
		addi $sp, $sp, 1
		addi $t8, $t8, 1
		
		addi $t3, $t3, 1
		blt $t3, $t1, writeGameBoardLoopTop
		
	li $t2, 0xA
	sb $t2, 0($sp)
	addi $sp, $sp, 1
	
	li $t3, 0
	writeGameBoardLoopBot:
		lb $t2, 0($t8)		#10s place byte of bot mancala
		sb $t2, 0($sp)
		addi $sp, $sp, 1
		addi $t8, $t8, 1
	
		lb $t2, 0($t8)		#1s place byte of bot mancala
		sb $t2, 0($sp)
		addi $sp, $sp, 1
		addi $t8, $t8, 1
		
		addi $t3, $t3, 1
		blt $t3, $t1, writeGameBoardLoopBot
	
	li $t2, '\0'
	sb $t2, 0($sp)
	lb $s0, -2($sp)

	syscall		#write to the file all the characters pushed into stack pointer
	
	li $v0, 16		#close file
	move $a0, $t0
	syscall
	
	jr $ra
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
