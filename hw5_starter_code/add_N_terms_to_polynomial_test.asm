.data
pair: .word 12 8


terms: .word 0 -1
p: .word 0
N: .word 4		#how many we are just CONSIDERING to at (considering)


#cases
#N is less than number of pairs
#N is greater than number of pairs
#invalid pair exists in terms[]
#pair has pre-existing exponent value


.text:
main:
    la $a0, p
    la $a1, pair
    jal init_polynomial

    la $a0, p
    la $a1, terms
    lw $a2, N
    jal add_N_terms_to_polynomial
    


    #write test code

    li $v0, 10
    syscall

.include "hw5.asm"
