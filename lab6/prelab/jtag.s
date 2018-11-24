.equ JTAG, 0xFF201000	#JTAG UART base address

.section .text
.global _start
_start:
	
	movia r8, JTAG 
	
	movui r9, 0b01 
	stwio r9,4(r8) #enable read interrupts in control register
	
	movi r9, 0x100 #JTAG is IRQ line 8
	wrctl ienable, r9
	
	movi r9, 0b1
	wrctl status, r9 #enable interrupts globally in the processor
	
	loop:
		br loop
	

.section .exceptions, "ax"
.align 2

JTAG_ISR:
	rdctl et, ipending #check ipending to see what device caused the interrupt
	andi et, et, 0x100 #if bit 8 of ipending is high, we know the JTAG UART is requesting an interrupt
	beq et, r0, exit
	ldwio et, 0(r8)
	andi et, et, 0x8000 #bit 15 is "read data is valid"
	beq et, r0, exit
	
	ldwio r2, 0(r8) #get the read data itself
	andi r2, r2, 0xff
	stwio r2, 0(r8) #write to the JTAG
	movi r2, 0x0A
	stwio r2, 0(r8)
	
	exit:
		subi ea, ea, 4
		eret #return so last instruction executed