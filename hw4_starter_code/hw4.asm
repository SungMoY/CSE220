############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
.text:

str_len:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0		#address of a string
	li $s1, 0		#counter
	str_len_loop:
		lb $s2, 0($s0)	#current byte
		beqz $s2, str_len_endString	#if current char is null terminator, end the loop
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		j str_len_loop
	str_len_endString:
		move $v0, $s1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
########################################
str_equals:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	
	move $s0, $a0		#address of first string
	move $s1, $a1		#address of second string
	str_equals_loop:
		lb $s2, 0($s0)	#current byte of first string
		lb $s3, 0($s1)	#current byte of second string
		
		bne $s2, $s3, str_equals_notSameString		#if current char is not equal, end the loop
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		bnez $s2, str_equals_loop
		j str_equals_sameString
	str_equals_sameString:
		li $v0, 1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 20
		jr $ra
	str_equals_notSameString:
		li $v0, 0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		addi $sp, $sp, 20
		jr $ra
########################################
str_cpy:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	move $s0, $a0		#address of a string
	move $s3, $a1		#address of destination
	li $s1, 0		#counter
	str_cpy_loop:
		lb $s2, 0($s0)	#current byte
		beqz $s2, str_cpy_endString	#if current char is null terminator, end the loop
		sb $s2, 0($s3)
		addi $s0, $s0, 1
		addi $s1, $s1, 1
		addi $s3, $s3, 1
		j str_cpy_loop
	str_cpy_endString:
		move $v0, $s1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
########################################
create_person:
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	move $s0, $a0		#address of the network data structure
	lw $s1, 0($s0)		#number of possible nodes
	lw $s2, 8($s0)		#size of each node
	lw $s3, 16($s0)		#number of nodes already in the network data structure
	beq $s1, $s3, create_person_networkFull		#network is full, no new nodes can be created
	
	mult $s3, $s2		#create a new node in the network data structure
	mflo $s2
	add $v0, $s0, $s2
	addi $v0, $v0, 36
	
	addi $s3, $s3, 1	#update the number of nodes already in the network data structure
	sw $s3, 16($s0)
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	create_person_networkFull:
		li $v0, -1
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		addi $sp, $sp, 16
		jr $ra
########################################	
is_person_exists:
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	
	move $s0, $a0		#address of network data structure
	move $s1, $a1		#address of a person node inside the network data structure
	
	li $s2, -1
	mult $s0, $s2
	mflo $s0		#negative number of address of network data structure
	add $s1, $s1, $s0
	addi $s1, $s1, -36	#the i'th node in the network data structure. i must be less than or equal to the number of nodes already in network
	lw $s2, 8($a0)		#if max is 5, i is 0,1,2,3,4
	div $s1, $s2
	mflo $s1		#s1 holds i, the position of the current person node being checked for existence
	
	lw $s0, 16($a0)		#number of nodes currently in the network
	bge $s1, $s0, is_person_exists_notExist		#if i in s1 is greater than or equal the number of nodes existing, then it does not exist
	bltz $s1, is_person_exists_notExist		#so if there are no nodes in the network, there are 0 nodes. any value of position i: node 0, node 1, node 2, node 3, node 4 dont have a node
	li $v0, 1
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
	is_person_exists_notExist:
		li $v0, 0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		addi $sp, $sp, 12
		jr $ra
########################################
is_person_name_exists:
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $ra, 16($sp)
	
	move $s0, $a0		#address of network construct
	move $s1, $a1		#address of the name string
	
	lw $s2, 8($s0)		#size of each person node
	lw $s3, 16($s0)		#number of person nodes currently inside the network
	beqz $s3, is_person_name_exists_notExist	#if there are no person nodes in the network, name cannot exist
	
	addi $s0, $s0, 36	#address of network construct now points to the first person node
	
	is_person_name_exists_loop:	#loop through each instance of a person node and check string
		move $a0, $s0
		move $a1, $s1
		jal str_equals
		li $t0, 1
		beq $v0, $t0, is_person_name_exists_Exists
		
		add $s0, $s0, $s2	#address of network construct now points to the next person node
		addi $s3, $s3, -1	#decrements the number of person nodes currently inside the network bc one has just been checked
		bgtz $s3, is_person_name_exists_loop
			
	is_person_name_exists_notExist:
		li $v0, 0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20
		jr $ra
	is_person_name_exists_Exists:
		li $v0, 1
		move $v1, $s0
		
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $ra, 16($sp)
		addi $sp, $sp, 20
		jr $ra
########################################
add_person_property:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $ra, 20($sp)

	move $s0, $a0		#address of network construct
	move $s1, $a1		#address of the person node in network construct
	move $s2, $a2		#address of prop_name "NAME\0"
	move $s3, $a3		#address of the person's name to add as a property to current node
	
	move $a0, $s2		#condition One: property name is not "NAME\0"
	addi $a1, $s0, 24
	jal str_equals
	li $t0, 1
	bne $v0, $t0, add_person_property_conditionOne
	
	move $a0, $s0		#condition Two: person node does not exist in the network data structure
	move $a1, $s1
	jal is_person_exists
	li $t0, 1
	bne $v0, $t0, add_person_property_conditionTwo
	
	move $a0, $s3		#condition Three: length of person's name is greater than or equal to the size of the node
	jal str_len
	lw $t0, 8($s0)
	bge $v0, $t0, add_person_property_conditionThree
	
	move $a0, $s0		#condition Four: name to be added must not already exist in the network construct
	move $a1, $s3
	jal is_person_name_exists
	li $t0, 1
	beq $v0, $t0, add_person_property_conditionFour
	
	#adding name part
	
	add_person_property_loop:
		lb $s4, 0($s3)		#get single ascii char of name
		
		beqz $s4, add_person_property_nameAdded		#if the single ascii char is the null terminator, end the loop
		
		sb $s4, 0($s1)		#store that single ascii char of name to the person node
		addi $s3, $s3, 1	#update name address to next char
		addi $s1, $s1, 1	#update person node to next byte
		j add_person_property_loop
		
	add_person_property_nameAdded:
		li $v0, 1
		j add_person_property_RegisterConvention
	add_person_property_conditionOne:
		li $v0, 0
		j add_person_property_RegisterConvention
	add_person_property_conditionTwo:
		li $v0, -1
		j add_person_property_RegisterConvention
	add_person_property_conditionThree:
		li $v0, -2
		j add_person_property_RegisterConvention
	add_person_property_conditionFour:
		li $v0, -3
		j add_person_property_RegisterConvention
	add_person_property_RegisterConvention:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $ra, 20($sp)
		addi $sp, $sp, 24
		jr $ra
########################################
get_person:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $a0, $a0
	move $a1, $a1
	jal is_person_name_exists
	beqz $v0, get_person_notFound		#if person is found, v1 holds the address
	move $v0, $v1				#move #v1 to v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
	get_person_notFound:			#if person is not found, then v0 is 0 and not 1
		li $v0, 0			#return 0 in v0 for no address
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
########################################
is_relation_exists:
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)

	move $s0, $a0			#address of network construct
	move $s1, $a1			#address of first person node
	move $s2, $a2			#address of second person node
	
	lw $s3, 8($s0)			#size of each node
	lw $s4, 12($s0)			#size of each edge
	lw $s5, 0($s0)			#max number of nodes
	lw $s6, 20($s0)			#current number of edges
	
	addi $s0, $s0, 36		#move address to the first byte of nodes array
	mult $s3, $s5
	mflo $s3
	add $s0, $s0, $s3		#move address to the first byte of the edges array, #s3 and $s5 are open to use
	
	move $s7, $s0			#s7 and s0 hold the address at first byte of edges array
	
	is_relation_exists_loopAtoB:
		#get the address at each edge
		lw $s3, 0($s0)		#address of person A
		lw $s5, 4($s0)		#address of person B
		
		beq $s3, $s1, is_relation_exists_checkOtherAtoB
		j is_relation_exists_loopAtoBIterate
		
		is_relation_exists_checkOtherAtoB:
			beq $s5, $s2, is_relation_exists_ExistsAtoB
			j is_relation_exists_loopAtoBIterate
			
		is_relation_exists_loopAtoBIterate:
		add $s0, $s0, $s4	#move address to first byte of next edge
		addi $s6, $s6, -1	#decrement the number of edges left to check bc one has just been checked
		bgtz $s6, is_relation_exists_loopAtoB
	
	
	lw $s6, 20($a0)			#current number of edges
	is_relation_exists_loopBtoA:
		#get the address at each edge
		lw $s3, 4($s7)		#address of person B
		lw $s5, 0($s7)		#address of person A
		
		beq $s3, $s1, is_relation_exists_checkOtherBtoA
		j is_relation_exists_loopBtoAIterate
		
		is_relation_exists_checkOtherBtoA:
			beq $s5, $s2, is_relation_exists_ExistsBtoA
			j is_relation_exists_loopBtoAIterate
			
		is_relation_exists_loopBtoAIterate:
		add $s7, $s7, $s4	#move address to first byte of next edge
		addi $s6, $s6, -1	#decrement the number of edges left to check bc one has just been checked
		bgtz $s6, is_relation_exists_loopBtoA
	
	li $v0, 0
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 32
	jr $ra
	
	is_relation_exists_ExistsAtoB:
		li $v0, 1
		move $v1, $s0
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 32
		jr $ra
	is_relation_exists_ExistsBtoA:
		li $v0, 1
		move $v1, $s7
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $s7, 28($sp)
		addi $sp, $sp, 32
		jr $ra
########################################
add_relation:
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $ra, 28($sp)

	move $s0, $a0		#address of network construct
	move $s7, $s0
	move $s1, $a1		#address of person A
	move $s2, $a2		#address of person B
	
	move $a0, $s0				#condition One: either person node does not exist in the network
	move $a1, $s1
	jal is_person_exists
	beqz $v0, add_relation_conditionOne
	
	move $a0, $s0
	move $a1, $s2
	jal is_person_exists
	beqz $v0, add_relation_conditionOne
	
	lw $t0, 4($s0)		#maximum number of edges	#Condition Two: already contains maximum number of edges
	lw $t1, 20($s0)		#current number of edges
	bge $t1, $t0, add_relation_conditionTwo
	
	move $a0, $s0					#condition three: relation already exists
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	bgtz $v0, add_relation_conditionThree
	
	beq $s1, $s2, add_relation_conditionFour		#condition four: person node is trying to relate to itself
	
	###
	lw $s3, 8($s0)			#size of each node
	lw $s4, 12($s0)			#size of each edge
	lw $s5, 0($s0)			#max number of nodes
	lw $s6, 20($s0)			#current number of edges
	
	addi $s0, $s0, 36		#move address to the first byte of nodes array
	mult $s3, $s5
	mflo $s3
	add $s0, $s0, $s3		#move address to the first byte of the edges array, #s3 and $s5 are open to use
	
	mult $s4, $s6
	mflo $s4
	add $s0, $s0, $s4		#move address to the first byte of the next available edge space in the edge array, $s4 and $s6 are open to use
	
	sw $s1, 0($s0)			#create person A relation
	sw $s2, 4($s0)			#create person B relation
	sw $0, 8($s0)			#make sure the relation property is zero
	###
	lw $s1, 20($s7)			#increment current number of edges
	addi $s1, $s1, 1
	sw $s1, 20($s7)
	
	li $v0, 1
	j add_relation_RegisterConvention
	
	add_relation_conditionOne:
		li $v0, 0
		j add_relation_RegisterConvention
	add_relation_conditionTwo:
		li $v0, -1
		j add_relation_RegisterConvention
	add_relation_conditionThree:
		li $v0, -2
		j add_relation_RegisterConvention
	add_relation_conditionFour:
		li $v0, -3
		j add_relation_RegisterConvention
	add_relation_RegisterConvention:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $ra, 28($sp)
		addi $sp, $sp, 32
		jr $ra
########################################
add_relation_property:
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $ra, 28($sp) 

	move $s0, $a0		#address of network construct
	move $s1, $a1		#address of person A node in network construct
	move $s2, $a2		#address of person B node in network construct
	move $s3, $a3		#address of string of the prop_name (name of the property: "FRIEND\0"
	lw $s4, 32($sp)		#prop_value to change the name of the property into
	
	move $a0, $s0		#condition One: relation exists between two persons
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	beqz $v0, add_relation_property_conditionOne
	
	addi $a0, $s0, 29	#condition Two: prop_name is not "FRIEND\0"
	move $a1, $s3		#compare the function parameter and the asciiz word in network construct
	jal str_equals
	beqz $v0, add_relation_property_conditionTwo
	
	bltz $s4, add_relation_property_conditionThree		#condition Three: prop_value is less than 0. prop_value of an edge can be 0 or 1
	##
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	sw $s4, 8($v1)
	li $v0, 1
	j add_relation_property_RegisterConvention
	
	##
	add_relation_property_conditionOne:
		li $v0, 0
		j add_relation_property_RegisterConvention
	add_relation_property_conditionTwo:
		li $v0, -1
		j add_relation_property_RegisterConvention
	add_relation_property_conditionThree:
		li $v0, -2
		j add_relation_property_RegisterConvention
	add_relation_property_RegisterConvention:
		lw $s0, 0($sp)
		lw $s1, 4($sp)
		lw $s2, 8($sp)
		lw $s3, 12($sp)
		lw $s4, 16($sp)
		lw $s5, 20($sp)
		lw $s6, 24($sp)
		lw $ra, 28($sp)
		addi $sp, $sp, 32
		jr $ra
########################################
is_friend_of_friend:
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
	
	move $s0, $a0		#address of network construct
	move $s1, $a1		#person A's name
	move $s2, $a2		#person B's name

	lw $s3, 8($s0)			#size of each node
	lw $s4, 0($s0)			#max number of nodes
	
	move $s7, $s0		#address of network construct
	addi $s7, $s7, 36	#address now points to the first byte of the nodes array
	move $s6, $s7
	mult $s3, $s4
	mflo $s3		#total size of nodes array
	add $s7, $s7, $s3	#address now points to the first byte of the edges array
	
	
	
	move $a0, $s0		#check if person A's name is in the network. If so, update s1 with the address of person A's node
	move $a1, $s1
	jal is_person_name_exists
	beqz $v0, is_friend_of_friend_personNotExist
	move $s1, $v1
	
	move $a0, $s0		#check if person B's name is in the network. If so, update s2 with the address of person B's node
	move $a1, $s2
	jal is_person_name_exists
	beqz $v0, is_friend_of_friend_personNotExist
	move $s2, $v1
	
	move $a0, $s0
	move $a1, $s1
	move $a2, $s2
	jal is_relation_exists
	bnez $v0, is_friend_of_friend_relationExists
	j is_friend_of_friend_relationExists_butNotFriends
	
	is_friend_of_friend_relationExists:
		lw $s3, 8($v1)		#the value of the relation property
		li $t0, 1
		beq $s3, $t0, is_friend_of_friend_relationExists_andFriend
	
	is_friend_of_friend_relationExists_butNotFriends:
	####
	#$s7 is address at first byte of edges array
	#$s6 is address at first byte of nodes array
	#s1 with the address of person A's node
	#s2 with the address of person B's node
	
	lw $s3, 16($s0)						#number of persons currently in the network construct
	is_friend_of_friend_loop:
		
		move $a0, $s0
		move $a1, $s1					#check if current person, Perxon X, has a relation with Person A
		move $a2, $s6
		jal is_relation_exists
		bgtz $v0, is_friend_of_friend_relationAXExists
		j is_friend_of_friend_loopContinue
		is_friend_of_friend_relationAXExists:
			lw $s5, 8($v1)
			li $t0, 1
			beq $s5, $t0, is_friend_of_friend_loopCheckB	#Person A has a relation AND IS A FRIEND with Person X.
		j is_friend_of_friend_loopContinue
		
		is_friend_of_friend_loopCheckB:			#check if Person X has a relation with Person B, making a friend-to-friend relation with Person A
			move $a0, $s0
			move $a1, $s6
			move $a2, $s2
			jal is_relation_exists
			bgtz $v0, is_friend_of_friend_RelationFoundXB
			j is_friend_of_friend_loopContinue
			is_friend_of_friend_RelationFoundXB:
				lw $s5, 8($v1)
				li $t0, 1
				beq $s5, $t0, is_friend_of_friend_RelationFound
			j is_friend_of_friend_loopContinue
			
		is_friend_of_friend_loopContinue:
		lw $s4, 8($s0)						#size of each node
		add $s6, $s6, $s4					#check next Person X in the network
		addi $s3, $s3, -1
		bgtz $s3, is_friend_of_friend_loop
		
	j is_friend_of_friend_directRelationOrNotFriendOfFriend
	###
	
	

	is_friend_of_friend_relationExists_andFriend:
		li $v0, 0
		j is_friend_of_friend_RegisterConvention
	is_friend_of_friend_directRelationOrNotFriendOfFriend:
		li $v0, 0
		j is_friend_of_friend_RegisterConvention
	is_friend_of_friend_personNotExist:
		li $v0, -1
		j is_friend_of_friend_RegisterConvention
	is_friend_of_friend_RelationFound:
		li $v0, 1
		j is_friend_of_friend_RegisterConvention
	is_friend_of_friend_RegisterConvention:
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
