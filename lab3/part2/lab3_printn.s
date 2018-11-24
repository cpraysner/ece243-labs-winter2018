 # # * 
 # # * Write the assembly function:
 # # *     printn ( char * , ... ) ;
 # # * Use the following C functions:
 # # *     printHex ( int ) ;
 # # *     printOct ( int ) ;
 # # *     printDec ( int ) ;
 # # * 
 # # * Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you don't need to look up ASCII values.

# .global	printn
# printn:

	# mov r22, r4 #r4 contains the address of the char array in memory
	# mov r23, sp
	
	# #need to store these so we can compare w char array
	# movi r17, 0x4f #'O'
	# movi r18, 0x48 #'H'
	# movi r19, 0x44 #'D'
	
	# subi sp, sp, 12 #allocate 12 extra bytes of storage on top of the stack 
	# stw r5, 0(sp) 
	# stw r6, 4(sp) 
    # stw r7, 8(sp) 
	# addi r22, r22, 1
	
	
# first_branch:
	# ldb r16, 0(r22) #get character
	# beq r16, r0, done #check if end of string
	# beq r16, r17, oct #octal
	# beq r16, r18, hex #hexadecimal 
	# beq r16, r19, dec #decimal
	
# oct:
	# call printOct
	# br first_branch
	
# hex:
	# call printHex
	# br first_branch

# dec:
	# call printDec
	# br first_branch

# done:
	# ret
	
	

# .end

# /*********
 # * 
 # * Write the assembly function:
 # *     printn ( char * , ... ) ;
 # * Use the following C functions:
 # *     printHex ( int ) ;
 # *     printOct ( int ) ;
 # *     printDec ( int ) ;
 # * 
 # * Note that 'a' is a valid integer, so movi r2, 'a' is valid, and you do not need to look up ASCII values.
 # *********/
 
.global	printn
printn:
	#store param into stack
	addi sp, sp, -12
	stw r5, 0(sp)
	stw r6, 4(sp)
	stw r7, 8(sp)
	addi sp, sp, -12 #store return address
	stw ra, 8(sp)
	stw r16, 4(sp)
	stw r17, 0(sp)
	mov r16, r4 #move address of string parameter
	addi r17, sp, 12
	

LOOP:
	#load the next letter to check
	movi r15, 'D'
	movi r14, 'H'
	movi r13, 'O' 
	ldb r8, 0(r16)
	beq r8, r15, PRINT_DEC
	beq r8, r14, PRINT_HEX
	beq r8, r13, PRINT_OCT
	#if it's none of these letters, exit subroutine
	br END_LOOP
	
PRINT_DEC:
	ldw r4, 0(r17)
	call printDec
	br RETURN_TO_LOOP
	
PRINT_HEX:
	ldw r4, 0(r17)
	call printHex
	br RETURN_TO_LOOP
	
PRINT_OCT:	
	ldw r4, 0(r17)
	call printOct
	br RETURN_TO_LOOP
	
RETURN_TO_LOOP:
	addi r17, r17, 4
	addi r16, r16, 1
	br LOOP
	
END_LOOP:
	ldw ra, 8(sp)
	ldw r16, 4(sp)
	ldw r17, 0(sp)
	addi sp, sp, 24
	ret






