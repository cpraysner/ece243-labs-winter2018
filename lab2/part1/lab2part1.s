.equ RED_LEDS, 0xFF200000 	   # (From DESL website > NIOS II > devices)


.data                              # "data" section for input and output lists


IN_LIST:                  	   # List of 9 signed halfwords starting at address IN_LIST
    .hword 1
    .hword -1
    .hword -2
    .hword 2
    .hword 0
    .hword -3
    .hword 100
    .hword 0xff9c
    .hword 0b1111
LAST:			 	    # These 2 bytes are the last halfword in IN_LIST
    .byte  0x01		  	    # address LAST
    .byte  0x02		  	    # address LAST+1
    
IN_LINKED_LIST:                     # Used only in Part 3
    A: .word 1
       .word B
    B: .word -1
       .word C
    C: .word -2
       .word E + 8
    D: .word 2
       .word C
    E: .word 0
       .word K
    F: .word -3
       .word G
    G: .word 100
       .word J
    H: .word 0xffffff9c
       .word E
    I: .word 0xff9c
       .word H
    J: .word 0b1111
       .word IN_LINKED_LIST + 0x40
    K: .byte 0x01		    # address K
       .byte 0x02		    # address K+1
       .byte 0x03		    # address K+2
       .byte 0x04		    # address K+3
       .word 0
    
OUT_NEGATIVE:
    .skip 40                         # Reserve space for 10 output words
    
OUT_POSITIVE:
    .skip 40                         # Reserve space for 10 output words

#-----------------------------------------

.text                  # "text" section for code

    # Register allocation:
    #   r0 is zero, and r1 is "assembler temporary". Not used here.
    #   r2  Holds the number of negative numbers in the list
    #   r3  Holds the number of positive numbers in the list
    #   r18 A pointer to the value
    #   r19  loop counter for list
    # r20 current value to be compared
    # r21 address of OUT_POSITIVE
    # r22 address of OUT_NEGATIVE
    #   r16, r17 Short-lived temporary values.
    #   etc...

.global _start
_start:
    
    # Your program here. Pseudocode and some code done for you:

	movia r18, IN_LIST  #move the 32 bit address of the beginning of IN_LIST into r18   
	movia r21, OUT_POSITIVE
	movia r22, OUT_NEGATIVE
	movi r23, 0xA

	
LOOP:           
        addi r19,r19,1
		beq r19,r23, LOOP_FOREVER
		ldw r20,0(r18)

		blt r0,r20,NEGATIVE_NUMBER 
        bgt r0,r20,POSITIVE_NUMBER
		
        #        insert number in OUT_NEGATIVE list
        #        increment count of negative values (r2)
        #    } else if (number is positive) { 
        #        insert number in OUT_POSITIVE list
        #        increment count of positive values (r3)
        #    }
        # Done processing.


        
		
    # End loop


POSITIVE_NUMBER:
	stw r20, 0(r21)
	addi r18,r18,0x4
	addi r2,r2,1
	movia  r16, RED_LEDS          # r16 and r17 are temporary values
	ldwio  r17, 0(r16)
	addi   r17, r17, 1
	stwio  r17, 0(r16)
	br LOOP

NEGATIVE_NUMBER:
	stw r20, 0(r22)
	addi r18,r18,0x4
	addi r3,r3,1
	movia  r16, RED_LEDS          # r16 and r17 are temporary values
	ldwio  r17, 0(r16)
	addi   r17, r17, 1
	stwio  r17, 0(r16)
	br LOOP
LOOP_FOREVER:
    br LOOP_FOREVER                   # Loop forever.