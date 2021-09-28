############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

create_term:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $s1, 4($sp)

	move $s0, $a0	#integer value of coefficient of term
	move $s1, $a1	#integer value of exponent of term
	
	beqz $s0, create_term_invalidTerm	#coefficient is equal to zero, return error
	bltz $s1, create_term_invalidTerm	#exponent is negative, return error
	
	li $a0, 12
	li $v0, 9
	syscall		#$creates space in heap, $v0 holds address of this created term in the heap
	
	sw $s0, 0($v0)
	sw $s1, 4($v0)
	sw $0, 8($v0)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
	create_term_invalidTerm:
		li $v0, -1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		addi $sp, $sp, 8
		jr $ra
####################
init_polynomial:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	move $s0, $a0		#main pointer of polynomial
	move $s1, $a1		#integer array containing two terms
	
	lw $a0, 0($s1)		#coefficient element
	lw $a1, 4($s1)		#exponent element
	jal create_term
	bltz $v0, init_polynomial_Error		#if invalid coefficient or exponent, return error
	
	sw $v0, 0($s0)		#save address of valid term to pointer of polynomial
	li $v0, 1
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	init_polynomial_Error:
		li $v0, -1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $ra, 8($sp)
		addi $sp, $sp, 12
		jr $ra
####################	
add_N_terms_to_polynomial:
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

	move $s7, $a0		#s7 holds the address of the polynomial pointer structure
	lw $s0, 0($a0)		#address of the first node
	move $s1, $a1		#address of array of pairs, terms
	move $s2, $a2		#the number of terms to be added to the polynomial, integer N
	li $s6, 0
	
	blez $s2, add_N_terms_to_polynomial_NinvalidEnd
	
	move $s4, $s1
	li $s3, 0		#number of terms in the pairs array
	add_N_terms_to_polynomial_counter:
		lw $t0, 0($s4)
		beqz $t0, add_N_terms_to_polynomial_counter_checkExp
		addi $s3, $s3, 1
		addi $s4, $s4, 8
		j add_N_terms_to_polynomial_counter
		add_N_terms_to_polynomial_counter_checkExp:
			lw $t0, 4($s4)
			li $t1, -1
			beq $t0, $t1, add_N_terms_to_polynomial_counterEnd
			addi $s3, $s3, 1
			addi $s4, $s4, 8
			j add_N_terms_to_polynomial_counter
	add_N_terms_to_polynomial_counterEnd:			#s3 has the number of terms in the pairs array
	blez $s3, add_N_terms_to_polynomial_NinvalidEnd
	bgt $s2, $s3, add_N_terms_to_polynomial_NisGreater_loop	#N is greater than the number of terms in the array. Add all terms in the array
	j add_N_terms_to_polynomial_NisLesserOrEq_loop
#####	
	add_N_terms_to_polynomial_NisLesserOrEq_loop:
		lw $a0, 0($s1)
		lw $a1, 4($s1)
		jal create_term
		bltz $v0, add_N_terms_to_polynomial_NisLesserOrEq_loop_nextTerm		#creates term. If term is invalid, check next term
		move $s4, $v0								# $s4 holds address of valid term created from current pairs
		move $s5, $s0		# $s5 address of the head node
		move $s3, $s7		# $s3 and $s7 holds address of polynomial head. use $s3 to hold address of previous term to inserting a term use $s7 to compare $s3 with to check if current term is the head node
		
		add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting:
			lw $t0, 4($s4)		#exponent of current pair term
			lw $t1, 4($s5)		#exponent of term already in polynomial
			beq $t0, $t1, add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_equalTo
			bgt $t0, $t1, add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_greaterThan
			blt $t0, $t1, add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_lessThan
			
			add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_equalTo:
				#omit
				j add_N_terms_to_polynomial_NisLesserOrEq_loop_nextTerm
				
			add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_greaterThan:
				addi $s6, $s6, 1
				#place in between
				sw $s5, 8($s4)		#inserting term points to next term
				beq $s3, $s7, add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_greaterThan_atHeadNode
				sw $s4, 8($s3)
				j add_N_terms_to_polynomial_NisLesserOrEq_loop_nextTerm
				add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_greaterThan_atHeadNode:
					sw $s4, 0($s3)
					lw $s0, 0($s3)	#update polynomial pointer head node
					j add_N_terms_to_polynomial_NisLesserOrEq_loop_nextTerm
					
			add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_lessThan:
				#current polynomial term's pointer is 0 and place at end. If not, check next term
				lw $t9, 8($s5)
				beqz $t9, add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_lessThan_place
				move $s3, $s5	#store previous
				lw $s5, 8($s5)	#load next
				j add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting
				add_N_terms_to_polynomial_NisLesserOrEq_loop_sorting_lessThan_place:
					addi $s6, $s6, 1
					sw $s4, 8($s5)	#placed
					j add_N_terms_to_polynomial_NisLesserOrEq_loop_nextTerm
					
		add_N_terms_to_polynomial_NisLesserOrEq_loop_nextTerm:
			addi $s2, $s2, -1
			addi $s1, $s1, 8
			bgtz $s2, add_N_terms_to_polynomial_NisLesserOrEq_loop
			j add_N_terms_to_polynomial_NisLesserOrEq_loop_exit
			
		add_N_terms_to_polynomial_NisLesserOrEq_loop_exit:
			move $v0, $s6
			
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
			jr $ra
#####	
	add_N_terms_to_polynomial_NisGreater_loop:
		li $t0, 0
		lw $t1, 0($s1)
		beq $t0, $t1, add_N_terms_to_polynomial_NisGreater_initialEnd
		j add_N_terms_to_polynomial_NisGreater_dontEnd
		
		add_N_terms_to_polynomial_NisGreater_initialEnd:
			li $t0, -1
			lw $t1, 4($s1)
			beq $t0, $t1, add_N_terms_to_polynomial_NisGreater_endCondition

		add_N_terms_to_polynomial_NisGreater_dontEnd:

		lw $a0, 0($s1)
		lw $a1, 4($s1)
		jal create_term
		bltz $v0, add_N_terms_to_polynomial_NisGreater_loop_nextTerm		#creates term. If term is invalid, check next term
		move $s4, $v0								# $s4 holds address of valid term created from current pairs
		move $s5, $s0		# $s5 address of the head node
		move $s3, $s7		# $s3 and $s7 holds address of polynomial head. use $s3 to hold address of previous term to inserting a term use $s7 to compare $s3 with to check if current term is the head node
		
		add_N_terms_to_polynomial_NisGreater_loop_sorting:
			lw $t0, 4($s4)		#exponent of current pair term
			lw $t1, 4($s5)		#exponent of term already in polynomial
			beq $t0, $t1, add_N_terms_to_polynomial_NisGreater_loop_sorting_equalTo
			bgt $t0, $t1, add_N_terms_to_polynomial_NisGreater_loop_sorting_greaterThan
			blt $t0, $t1, add_N_terms_to_polynomial_NisGreater_loop_sorting_lessThan
			
			add_N_terms_to_polynomial_NisGreater_loop_sorting_equalTo:
				#omit
				j add_N_terms_to_polynomial_NisGreater_loop_nextTerm
				
			add_N_terms_to_polynomial_NisGreater_loop_sorting_greaterThan:
				addi $s6, $s6, 1
				#place in between
				sw $s5, 8($s4)		#inserting term points to next term
				beq $s3, $s7, add_N_terms_to_polynomial_NisGreater_loop_sorting_greaterThan_atHeadNode
				sw $s4, 8($s3)
				j add_N_terms_to_polynomial_NisGreater_loop_nextTerm
				add_N_terms_to_polynomial_NisGreater_loop_sorting_greaterThan_atHeadNode:
					sw $s4, 0($s3)
					lw $s0, 0($s3)	#update polynomial pointer head node
					j add_N_terms_to_polynomial_NisGreater_loop_nextTerm
					
			add_N_terms_to_polynomial_NisGreater_loop_sorting_lessThan:
				#current polynomial term's pointer is 0 and place at end. If not, check next term
				lw $t9, 8($s5)
				beqz $t9, add_N_terms_to_polynomial_NisGreater_loop_sorting_lessThan_place
				move $s3, $s5	#store previous
				lw $s5, 8($s5)	#load next
				j add_N_terms_to_polynomial_NisGreater_loop_sorting
				add_N_terms_to_polynomial_NisGreater_loop_sorting_lessThan_place:
					addi $s6, $s6, 1
					sw $s4, 8($s5)	#placed
					j add_N_terms_to_polynomial_NisGreater_loop_nextTerm
					
		add_N_terms_to_polynomial_NisGreater_loop_nextTerm:
			addi $s1, $s1, 8
			j add_N_terms_to_polynomial_NisGreater_loop
			
		add_N_terms_to_polynomial_NisGreater_endCondition:
			move $v0, $s6
			
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
			jr $ra
			
	add_N_terms_to_polynomial_NinvalidEnd:
		li $v0, 0
			
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
		jr $ra
####################
update_N_terms_in_polynomial:
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
	

	move $s0, $a0	#polynomial p pointer
	move $s1, $a1	#terms[] of pairs
	move $s2, $a2	#integer value N of pairs to consider
	
	li $a0, 8	#one word holds coefficient. one word points to next coefficient.
	li $v0, 9
	syscall		#$creates space in heap, $v0 holds address of this created term in the heap
	move $s3, $v0	#s3 holds address of head node of duplicate LinkedList
	
	blez $s2, update_error		#N is 0 or negative, then error
	
	lw $s4, 0($s0)			#if polynomial p is empty/null, then error
	beqz $s4, update_error
	
	##count the number of pairs in terms[] and compare with N
	move $s6, $s1
	li $s5, 0
	update_N_counter:
		lw $s7, 0($s6)
		beqz $s7, update_N_counter_checkExp
		addi $s5, $s5, 1
		addi $s6, $s6, 8
		j update_N_counter
		update_N_counter_checkExp:
			lw $s7, 4($s6)
			bltz $s7, update_N_counter_counterEnd
			addi $s5, $s5, 1
			addi $s6, $s6, 8
			j update_N_counter
	update_N_counter_counterEnd:		#s5 has the number of pairs in terms[]
	blez $s5, update_error
	blt $s2, $s5, update_NisLesser		#N is lesser than the number of pairs in terms[] so consider only the first N elements
	j update_NisGreater			#N is greater than or equal to the number of pairs in terms[] so consider all elements
	
	
	
	
	update_NisLesser:
	##
	
	#s0 is polynomial pointer
	#s1 is terms[]
	#s2 is integer value N
	#s3 is address of head node of duplicates LinkedList
	
	#s4 as copy of polynomial pointer to reset to beginning
	move $s4, $s0
	#s5 as copy of duplicates LinkedList head node to reset to beginning
	move $s5, $s3
	
	#s6 is available
	#s7 is available
	#i do not need a counter. Simply get size of duplicates linkedlist to return in v0 as the number of terms updated
	
	##########
	update_NisLesser_loop:		#consider the first N elements in terms[]
		lw $s6, 4($s1)		#exponent value of current pair
		
		move $s0, $s4				#reset polynomial beginning (pointer p)#################		RESETER
		lw $s0, 0($s0)				#address of head node
		update_NisLesser_polynomialSearch:
			beqz $s0, update_NisLesser_polynomialEnd	#error case: desired exponent does not exist in polynomial
			lw $s7, 4($s0)					#exponent value of current term in polynomial
			beq $s6, $s7, update_NisLesser_polynomialFound
			lw $s0, 8($s0)
			j update_NisLesser_polynomialSearch
			
			update_NisLesser_polynomialFound:
				lw $s6, 0($s1)					#new coeff to now update polynomial term with
				beqz $s6, update_NisLesser_polynomialEnd	#error case: new coeff cannot be 0
			
				sw $s6, 0($s0)		#new coeff is updated to term

				move $s3, $s5		#copy of address of beginning head node of duplicates linkedList############		RESTER
				update_NisLesser_polynomialFound_duplicateLoop:
					lw $t0, 4($s3)
					beqz $t0, update_NisLesser_polynomialFound_duplicateLoop_placeDupe	#if there is no next duplicate or is the first term. Place here
				
					lw $t0, 0($s3)	#data field of node
					lw $t1, 4($s1)	#exponent of current term
					beq $t1, $t0, update_NisLesser_polynomialEnd	#duplicate exists in duplicates linkedlist. decrement N and check next pair
					lw $s3, 4($s3)
					j update_NisLesser_polynomialFound_duplicateLoop
				
					update_NisLesser_polynomialFound_duplicateLoop_placeDupe:
						lw $t0, 4($s1)	#exponent of the term updated
						sw $t0, 0($s3)
					
						li $a0, 8	#one word holds coefficient. one word points to next coefficient.
						li $v0, 9
						syscall		#$creates space in heap, $v0 holds address of this created term in the heap
						sw $v0, 4($s3)
						j update_NisLesser_polynomialEnd
	
		update_NisLesser_polynomialEnd:			#error case: desired exponent does not exist in polynomial
			addi $s1, $s1, 8			#error case: new coeff cannot be 0
			addi $s2, $s2, -1			#duplicate exists in duplicates linkedlist. decrement N and check next pair
			bgtz $s2, update_NisLesser_loop
			j update_NisLesser_loop_Ender
	
	update_NisLesser_loop_Ender:
		li $v0, 0
		update_NisLesser_loop_Ender_countDupes:		#s5 is perserved as the head of the linkedlist node
			lw $t0, 4($s5)
			beqz $t0, update_NisLesser_loop_Ender_countDupes_endLoop
			addi $v0, $v0, 1
			lw $s5, 4($s5)
			j update_NisLesser_loop_Ender_countDupes
		update_NisLesser_loop_Ender_countDupes_endLoop:
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
			jr $ra

	##########
	update_NisGreater:
		##
	
		#s0 is polynomial pointer
		#s1 is terms[]
		#s2 is integer value N
		#s3 is address of head node of duplicates LinkedList
	
		#s4 as copy of polynomial pointer to reset to beginning
		move $s4, $s0
		#s5 as copy of duplicates LinkedList head node to reset to beginning
		move $s5, $s3
	
		#s6 is available
		#s7 is available
		#i do not need a counter. Simply get size of duplicates linkedlist to return in v0 as the number of terms updated
	
		##########
		update_NisGreater_loop:		#go until terminating pair 0, -1
			li $t0, 0
			lw $t1, 0($s1)
			beq $t0, $t1, update_NisGreater_loop_initialEnd
			j update_NisGreater_loop_dontEnd
		
			update_NisGreater_loop_initialEnd:
				li $t0, -1
				lw $t1, 4($s1)
				beq $t0, $t1, update_NisGreater_loop_Ender
				j update_NisGreater_loop_dontEnd
			########
			update_NisGreater_loop_dontEnd:
				lw $s6, 4($s1)		#exponent value of current pair
				
				move $s0, $s4		#reset polynomial beginning (pointer p)
				lw $s0, 0($s0)		#address of head node
				update_NisGreater_loop_polynomialSearch:
					beqz $s0, update_NisGreater_loop_polynomialEnd	#error case: desired exponent does not exist in polynomial
					lw $s7, 4($s0)					#exponent value of current term in polynomial
					beq $s6, $s7, update_NisGreater_loop_polynomialFound
					lw $s0, 8($s0)
					j update_NisGreater_loop_polynomialSearch
			
					update_NisGreater_loop_polynomialFound:
						lw $s6, 0($s1)				#coeff value of current pair
						beqz $s6, update_NisGreater_loop_polynomialEnd		#if coeff value of current pair is 0, it would update the term to an invalid one so skip to next pair
						
						sw $s6, 0($s0)		#update coeff of the term in polynomial
						
						move $s3, $s5		#resetting duplicates linkedlist
						update_NisGreater_loop_polynomialFound_duplicateLoop:	
							lw $t0, 4($s3)
							beqz $t0, update_NisGreater_loop_polynomialFound_duplicateLoop_placeDupe	#if there is no next duplicate or is the first term. Place here
							
							lw $t0, 0($s3)	#data field of node
							lw $t1, 4($s1)	#exponent of current term
							beq $t1, $t0, update_NisGreater_loop_polynomialEnd	#duplicate exists in duplicates linkedlist. decrement N and check next pair
							lw $s3, 4($s3)
							j update_NisGreater_loop_polynomialFound_duplicateLoop
							
							update_NisGreater_loop_polynomialFound_duplicateLoop_placeDupe:
								lw $t0, 4($s1)	#exponent of the term updated
								sw $t0, 0($s3)
					
								li $a0, 8	#one word holds coefficient. one word points to next coefficient.
								li $v0, 9
								syscall		#$creates space in heap, $v0 holds address of this created term in the heap
								sw $v0, 4($s3)
								j update_NisGreater_loop_polynomialEnd
									
			#####										
			update_NisGreater_loop_polynomialEnd:	#go to next pair code
				addi $s1, $s1, 8
				j update_NisGreater_loop
			
			######
			update_NisGreater_loop_Ender:
				li $v0, 0
				update_NisGreater_loop_Ender_countDupes:	#s5 is perserved as the head of the linkedlist node
					lw $t0, 4($s5)
					beqz $t0, update_NisGreater_loop_Ender_countDupes_endLoop
					addi $v0, $v0, 1
					lw $s5, 4($s5)
					j update_NisGreater_loop_Ender_countDupes
				update_NisGreater_loop_Ender_countDupes_endLoop:
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
					jr $ra
	#########	
	update_error:
		li $v0, 0
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
		jr $ra
####################
get_Nth_term:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0	#location in .data. This location conatins the address to the first node of polynomial linkedlist
	move $s1, $a1	#integer N, return the N'th term of the polynomial
	
	blez $s1, get_Nth_term_error
	
	lw $s2, 0($s0)	#address in heap of first term of polynomial
	beqz $s2, get_Nth_term_error	#if address is 0, then polynomial was never initialized so it is empty
	
	get_Nth_term_loop:
		addi $s1, $s1, -1
		beqz $s1, get_Nth_term_loop_atTerm
		lw $s2, 8($s2)
		beqz $s2, get_Nth_term_error	#no more nodes left, or N is greater than the number of available nodes so cant get Nth node
		j get_Nth_term_loop
	
	get_Nth_term_loop_atTerm:
		lw $v0, 4($s2)	#exponent in v0
		lw $v1, 0($s2)	#coefficient in v1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
	
	get_Nth_term_error:
		li $v0, -1
		li $v1, 0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
####################
remove_Nth_term:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)

	move $s0, $a0
	move $s1, $a1
	
	move $s3, $s0		#copy of polynomial location in .data
	
	blez $s1, remove_Nth_term_error
	
	lw $s2, 0($s0)
	beqz $s2, remove_Nth_term_error
	
	remove_Nth_term_loop:
		addi $s1, $s1, -1
		beqz $s1, remove_Nth_term_loop_atTerm
		
		move $s3, $s2					#save previous
		lw $s2, 8($s2)
		
		beqz $s2, remove_Nth_term_error		#no more nodes left, or N is greater than the number of available nodes so cant get Nth node
		j remove_Nth_term_loop
	
	remove_Nth_term_error:
		li $v0, -1
		li $v1, 0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	
	remove_Nth_term_loop_atTerm:
		beq $s3, $s0, remove_Nth_term_loop_atTerm_termIsFirst
	
		lw $t0, 8($s2)
		lw $0, 8($s2)		#disconnect node
		sw $t0, 8($s3)
		
		lw $v0, 4($s2)	#exponent in v0
		lw $v1, 0($s2)	#coefficient in v1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	
	remove_Nth_term_loop_atTerm_termIsFirst:
		lw $t0, 8($s2)
		sw $0, 8($s2)		#disconnect node
		sw $t0, 0($s3)
		
		lw $v0, 4($s2)	#exponent in v0
		lw $v1, 0($s2)	#coefficient in v1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
	
####################
add_poly:
	addi $sp, $sp, -28
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3,	12($sp)
	sw $s4, 16($sp)	
	sw $s7, 20($sp)
	sw $ra, 24($sp)
	
	move $s0, $a0	#address of polynomial p
	move $s1, $a1	#address of polynomial q
	move $s2, $a2	#address of return sum polynomial r
	
	move $s7, $s2	#secondary copy of address of return sum polynomial r
	
	lw $s3, 0($s0)	#head node of p
	lw $s4, 0($s1)	#head node of q
	
	beqz $s3, add_poly_PemptyCheckOrIdentityQ
	beqz $s4, add_poly_QemptyIdentityP	    #checks if there exists at least one term in each polynomial
	
	#this part only executes if both P and Q have at least one term. 0,0 or 1,0 or 0,1 are handled just before
	add_poly_loop:
		lw $t0, 4($s3)
		lw $t1, 4($s4)
		beq $t0, $t1, add_poly_PexpEqualQ
		bgt $t0, $t1, add_poly_PexpGreaterQ
		blt $t0, $t1 add_poly_PexpLessQ
		
		add_poly_PexpEqualQ:
			lw $t0, 0($s3)
			lw $t1, 0($s4)
			add $a0, $t0, $t1	#sum of coefficients
			lw $a1, 4($s3)		#equal exponent value
			jal create_term		#returns address of this valid term
			bltz $v0, add_poly_error
			beq $s2, $s7, add_poly_loop_PexpEqualQ_firstRTerm	#if this is the first term being added to return sum polynomial R
			sw $v0, 8($s2)
			move $s2, $v0
			
			lw $s3, 8($s3)
			lw $s4, 8($s4)
			beqz $s3, add_poly_PemptyAddQ
			beqz $s4, add_poly_QemptyAddP
			j add_poly_loop
			
			add_poly_loop_PexpEqualQ_firstRTerm:
				sw $v0, 0($s2)
				move $s2, $v0
				
				lw $s3, 8($s3)
				lw $s4, 8($s4)
				beqz $s3, add_poly_PemptyAddQ
				beqz $s4, add_poly_QemptyAddP
				j add_poly_loop
				
		
		add_poly_PexpGreaterQ:		#adding and updated P polynomial
			lw $a0, 0($s3)
			lw $a1, 4($s3)
			jal create_term
			bltz $v0, add_poly_error
			beq $s2, $s7, add_poly_loop_PexpGreaterQ_firstRTerm	#if this is the first term being added to return sum polynomial R
			sw $v0, 8($s2)
			move $s2, $v0
			lw $s3, 8($s3)
			beqz $s3, add_poly_PemptyAddQ
			j add_poly_loop
			
			add_poly_loop_PexpGreaterQ_firstRTerm:
				sw $v0, 0($s2)
				move $s2, $v0
				lw $s3, 8($s3)
				beqz $s3, add_poly_PemptyAddQ
				j add_poly_loop
		
		add_poly_PexpLessQ:		#adding and updated Q polynomial
			lw $a0, 0($s4)
			lw $a1, 4($s4)
			jal create_term
			bltz $v0, add_poly_error
			beq $s2, $s7, add_poly_loop_PexpLessQ_firstRTerm	#if this is the first term being added to return sum polynomial R
			sw $v0, 8($s2)
			move $s2, $v0
			lw $s4, 8($s4)
			beqz $s4, add_poly_QemptyAddP
			j add_poly_loop
			
			add_poly_loop_PexpLessQ_firstRTerm:
				sw $v0, 0($s2)
				move $s2, $v0
				lw $s4, 8($s4)
				beqz $s4, add_poly_QemptyAddP
				j add_poly_loop
			
		add_poly_PemptyAddQ:	#also check if Q is 0. If so, just return 1
			beqz $s4, add_poly_success
			lw $a0, 0($s4)
			lw $a1, 4($s4)
			jal create_term
			bltz $v0, add_poly_error
			
			sw $v0, 8($s2)
			move $s2, $v0
			lw $s4, 8($s4)
			j add_poly_PemptyAddQ
			
			
		add_poly_QemptyAddP:	#also check if P is 0. If so, just return 1
			beqz $s3, add_poly_success
			lw $a0, 0($s3)
			lw $a1, 4($s3)
			jal create_term
			bltz $v0, add_poly_error
			
			sw $v0, 8($s2)
			move $s2, $v0
			lw $s3, 8($s3)
			j add_poly_QemptyAddP	
							
	add_poly_error:
		li $v0, 0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3,	12($sp)
		lw $s4, 16($sp)	
		lw $s7, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		jr $ra
		
	add_poly_success:
		li $v0, 1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3,	12($sp)
		lw $s4, 16($sp)	
		lw $s7, 20($sp)
		lw $ra, 24($sp)
		addi $sp, $sp, 28
		jr $ra
		
	add_poly_PemptyCheckOrIdentityQ:
		beqz $s4, add_poly_error	#both are empty
		#if Q/s4 is not empty, identity copy Q to R
		#pointer to head node is stored in s4
		#handle adding the first term of Q to R
		lw $a0, 0($s4)
		lw $a1, 4($s4)
		jal create_term
		bltz $v0, add_poly_error
		
		sw $v0, 0($s2)
		move $s2, $v0
		lw $s4, 8($s4)
		j add_poly_PemptyAddQ
		
	
	add_poly_QemptyIdentityP:	#because this is only reached when Q is null but P exists. So copy P to R
		#pointer to head node is stored in s3
		#handle adding the first term of P to R
		lw $a0, 0($s3)
		lw $a1, 4($s3)
		jal create_term
		bltz $v0, add_poly_error
		
		sw $v0, 0($s2)
		move $s2, $v0
		lw $s3, 8($s3)
		j add_poly_QemptyAddP
	
####################
mult_poly:
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

	move $s0, $a0	#address of polynomial p pointer
	move $s1, $a1	#address of polynomial q pointer
	move $s2, $a2	#address of polynomial r pointer
	
	move $s7, $s2	#second copy of address of r pointer
	
	lw $s3, 0($s0)	#address of first node of p
	lw $s4, 0($s1)	#address of first node of q
	
	move $s5, $s4	#copy of first node of q to reset q iteration loop - RESETTER
	
	beqz $s3, mult_poly_Pempty		#if p is empty, check if q is empty. If just p is empty, do identity of Q to R. If both are empty, error case
	beqz $s4, mult_poly_Qempty_IdentityP	#p is not empty but q is empty. Identity of P into R
	
	#beyond this point, both P and Q are valid polynomials with at least one term in them
	
	mult_poly_PLoop:			#s3 is address of first node of P
		beqz $s3, mult_poly_done	#finished looping through polynomial p
		
		move $s4, $s5	#reset Q Loop for new P.term
		mult_poly_QLoop:
			beqz $s4, mult_poly_QLoop_finished_backToP
			
			lw $t0, 0($s3)	#coeff value of current p term
			lw $t1, 4($s3)	#exponent value of current p term
			
			lw $t2, 0($s4)	#coeff value of current q term
			lw $t3, 4($s4)	#exponent value of current q term
			
			mult $t0, $t2
			mflo $a0		#multiply coefficients
			add $a1, $t1, $t3	#add exponents
			jal create_term
			beqz $v0, mult_poly_error
			
			#####
			move $s2, $s7		#reset R loop for generated term
			move $s6, $s7
			lw $s2, 0($s2)		#address of first node
			mult_poly_RLoop:	#searching and placing term
				beqz $s2, mult_poly_RLoop_placeHere
				
				#check current term
				lw $t0, 4($s2)	#exponent of term in R
				lw $t1, 4($v0)	#exponent of new generated term
				beq $t0, $t1, mult_poly_RLoop_exponentExistsInR
				
				move $s6, $s2	#hold previous
				lw $s2, 8($s2)
				j mult_poly_RLoop
				
				mult_poly_RLoop_placeHere:
					beq $s6, $s7, mult_poly_RLoop_placeHere_firstEverTerm
					sw $v0, 8($s6)
					j mult_poly_RLoop_finished_backToQ
					
					mult_poly_RLoop_placeHere_firstEverTerm:
						sw $v0, 0($s6)
						j mult_poly_RLoop_finished_backToQ
				
				mult_poly_RLoop_exponentExistsInR:
					#update coeff of existing term in R
					lw $t0, 0($s2)	#coeff of existing term in R
					lw $t1, 0($v0)	#coeff of newly generated term
					add $t0, $t0, $t1	#addition of coeffs
					sw $t0, 0($s2)	#update coeff
					j mult_poly_RLoop_finished_backToQ
			
		
			#####
			mult_poly_RLoop_finished_backToQ:
				lw $s4, 8($s4)	#Finished iterating through R polynomial and placing. Continue Q loop to get next term
				j mult_poly_QLoop
				
		mult_poly_QLoop_finished_backToP:
			lw $s3, 8($s3)	#finished iterating through Q polynomial for the current P.term. Reset and loop through Q for the NEXT term of P
			j mult_poly_PLoop

	#############		
	mult_poly_Pempty:
		beqz $s4, mult_poly_error #both p and q are empty
		j mult_poly_Pempty_IdentityQ
		
	mult_poly_Pempty_IdentityQ:	#s4 is address of first node of q
		#TODO - loop through Q and put its terms into R
		#handle first term
		lw $a0, 0($s4)	#coeff value of current Q term
		lw $a1, 4($s4)	#exponent value of current Q term
		jal create_term
		bltz $v0, mult_poly_error
		sw $v0, 0($s2)
		move $s2, $v0
		lw $s4, 8($s4)
		
		IdentityQ_loop:
			beqz $s4, mult_poly_done
			
			lw $a0, 0($s4)	#coeff value of current Q term
			lw $a1, 4($s4)	#exponent value of current Q term
			jal create_term
			bltz $v0, mult_poly_error
			sw $v0, 8($s2)
			lw $s2, 8($s2)
			
			lw $s4, 8($s4)
			j IdentityQ_loop

	mult_poly_Qempty_IdentityP:	#s3 is address of first node or p
		#TODO - loop through P and put its terms into R
		#handle first term
		lw $a0, 0($s3)	#coeff value of current P term
		lw $a1, 4($s3)	#exponent value of current P term
		jal create_term
		bltz $v0, mult_poly_error
		sw $v0, 0($s2)
		move $s2, $v0
		lw $s3, 8($s3)
		
		IdentityP_loop:
			beqz $s3, mult_poly_done
			
			lw $a0, 0($s3)	#coeff value of current P term
			lw $a1, 4($s3)	#exponent value of current P term
			jal create_term
			bltz $v0, mult_poly_error
			sw $v0, 8($s2)
			lw $s2, 8($s2)
			
			lw $s3, 8($s3)
			j IdentityP_loop
	#############
	mult_poly_error:
		li $v0, 0
		
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
		jr $ra
	mult_poly_done:
		li $v0, 1
		
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
		jr $ra
