.equ TIMER, 0xFF202000	#Timer 1 Base Address
.equ LEDR, 0xFF200000	#Red LEDs Base Address
.equ PERIOD, 100000000 #1 second intervals


.section .text
.global _start
_start:
	movia r8, LEDR 
	movi r9, 0x1
 	stwio r9, (r8) #turn on one LED
	
	movia r8, TIMER
	addi r9, r0, %lo(PERIOD)
	stwio r9,8(r8) #store lower 16 bits of timeout period
	
	addi r9,r0,%hi(PERIOD)
	stwio r9,12(r8) #store upper 16 bits of timeout period
	
	movui r9, 0b0111 
	stwio r9,4(r8)
	
	movi r9, 0b1 #timer is IRQ line 0
	wrctl ienable, r9
	
	movi r9, 0b1
	wrctl status, r9 #enable interrupts globally in the processor
	
	loop:
		br loop
	

.section .exceptions, "ax"

TIMER_ISR:
	rdctl et, ipending #check ipending to see what device caused the interrupt
	andi et, et, 0x1 #if bit 0 of ipending is high, we know the timer is requesting an interrupt
	beq et, r0, exit
	
	movia r8, LEDR 
	ldwio r9, (r8) 
	andi r9, r9, 0x1
	beq r9, r0, LED_ON #if LEDS are off, turn them on
	br LED_OFF #if LEDS are on, turn them off
	
	LED_OFF:
		movia et, LEDR
		stwio r0, (et) #turn off all LEDs
		movia et, TIMER #acknowledge interrupt and reset timer
		stwio r0, (et)
		br exit
	
	LED_ON:
		movia et, LEDR
		movi r9, 0x1
		stwio r9, (et) #turn off all LEDs
		movia et, TIMER #acknowledge interrupt and reset timer
		stwio r0, (et)
		br exit
	
	
	
	exit:
		subi ea, ea, 4
		eret #return so last instruction executes