.equ	ADDR_GPIO_0, 0XFF200060

.text
.global _start
_start:

	movia r9, ADDR_GPIO_0 
	movia r10, 0x07F557FF 
	stwio r10, 4(r9) #set direction for motors and sensors to output, sensor data registers to input
	
	sensor1:
		movia r11, 0xFFFFFBFC 
		stwio r11, 0(r8) #enable sensor 0 and motor
		ldwio r5, 0(r8)	#checking for valid data sensor 0
		srli r6, r5, 11 #bit 11 is valid bit for sensor 0
		andi r6, r6, 0x1 #mask the valid bit
		bne r0, r6, sensor1
	
	sensor2:
		movia r12, 0xFFFFEFFE 
		stwio r12, 0(r8) #enable sensor 1 and motor
		ldwio r8, 0(r8)	#checking for valid data sensor 1
		srli r7, r8, 11 #bit 11 is valid bit for sensor 1
		andi r7, r7, 0x1 #mask the valid bit
		bne r0, r7, sensor2
	good:
		srli r5, r5, 27 #shift to the right by 27 bits so that the 4-bit sensor value is in lower 4 bits
		andi r5, r5, 0x0F
		movi r14, 0x05
		movi r15, 0x08
		beq r5, r14, go_forward
		beq r5, r15, go_backward
		
	go_forward:
		blt r5, r14, sensor1
		br sensor2
	
	go_backward:
		blt r5, r15, sensor2
		br sensor1
	
	
.end