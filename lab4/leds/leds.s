.equ  ADDR_REDLEDS,  0xFF200000
.equ TIMER0_BASE,	0XFF202000
.equ TIMER0_STATUS,	0
.equ TIMER0_CONTROL,	4
.equ TIMER0_PERIODL,	8
.equ TIMER0_PERIODH,	12
.equ TIMER0_SNAPL,	16
.equ TIMER0_SNAPH,	20
.equ CYCLES_PER_SECOND,	100000000

.text
.global _start
_start:	
	
	movia r2, ADDR_REDLEDS
	movi  r3,0x01
	stwio r0,0(r2)
	addi r4, r0, 1
	call delay
	stwio r3,0(r2)
	addi r4, r0, 1
	call delay
	br _start


delay:
	movia r8, TIMER0_BASE
	stwio r9, TIMER0_CONTROL(r8)

	addi r9,r0, %lo(CYCLES_PER_SECOND)
	stwio r9, TIMER0_PERIODL(r8)
	addi r9,r0, %hi(CYCLES_PER_SECOND)
	stwio r9, TIMER0_PERIODH(r8)
	addi r9,r0,0X4 
	stwio r9,TIMER0_CONTROL(r8)

delay1:
	ldwio r9,TIMER0_STATUS(r8)
	andi r9,r9,0x1
	beq r9,r0,delay1
	movi r9,0x0
	stwio r9,TIMER0_STATUS(r8)
	subi r4, r4, 1
	bne r4,r0,delay1
	movi r9,8
	stwio r9,TIMER0_CONTROL(r8)
	ret



	