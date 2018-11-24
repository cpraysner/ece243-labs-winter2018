.equ BASE, 0x10001020	#Car World JTAG UART Base Address
.equ JTAG, 0xFF201000	#JTAG UART base address
.equ TIMER, 0xFF202000	#Timer 1 Base Address
.equ PERIOD, 100000000 #1 second intervals

.section .text
.global _start
_start:

####Timer set up code####
movia r17, TIMER
addi r18, r0, %lo(PERIOD)
stwio r18,8(r17) #store lower 16 bits of timeout period

addi r18,r0,%hi(PERIOD)
stwio r18,12(r17) #store upper 16 bits of timeout period

movui r18, 0b0111 
stwio r18,4(r17)

movi r18, 0x101 #timer is IRQ line 0, JTAG is IRQ line 8
wrctl ienable, r18

movi r18, 0b1
wrctl status, r18 #enable interrupts globally in the processor

#################################################################
####JTAG UART Interrupt set up code####
movia r19, JTAG 
	
movui r20, 0b01 
stwio r20,4(r19) #enable read interrupts in control register

################################################################

#if r16 is 0x1, we are in 'r' (sensor) mode, if it is 0x0, we are in 's' (speed) mode

movi r16, 0x1 #start the program in sensor mode

movia r7, BASE

movia r4, 0x00
call write_byte

movia r5,95 #set initial acceleration
movia r4, 0x04
call write_byte
mov r4, r5 #r5 contains the desired acceleration value
call write_byte


get_sensor_data:	
	call read_sensors_and_speed

decisions:
	
	movia r15, 0x1f
	beq r8, r15, straight

	movia r15, 0x1e
	beq r8, r15, right

	movia r15, 0x1c
	beq r8, r15, hard_right

	movia r15, 0x0f
	beq r8, r15, left

	movia r15, 0x07
	beq r8, r15, hard_left



read_sensors_and_speed:
	movia r4, 0x02 #send a 0x02 to request sensors and speed
	call write_byte
	call read_byte #first byte should be 0x00
	bne r3, r0, read_sensors_and_speed
	call read_byte
	mov r8, r3 #r8 now contains the sensor values
	call read_byte
	mov r9, r3 #r9 now contains the speed
	movia r4, 0x03 #request to get position data
	call write_byte
	call read_byte
	call read_byte
	call read_byte
	call read_byte
	mov r11, r3 #r3 now contains the z coordinate
	br decisions
	

write_byte:
	ldwio r3, 4(r7)
	srli r3, r3, 16 #check write available bits
	beq r3, r0, write_byte #if FIFO has no empty spaces, no data can be sent
	stwio r4, 0(r7) #write the byte to the JTAG
	ret
	
read_byte:
	ldwio r2, 0(r7) #load from JTAG
	andi r3, r2, 0x8000 #mask the read valid bit
	beq r3, r0, read_byte
	andi r3, r2, 0x00FF #data read is in r3
	ret

straight:
	movia r4, 0x05 #set steering angle
	call write_byte
	movia r4, 0 #new steering value
	call write_byte
	movia r10, 48
	ble r9, r10, straight_accelerate
	blt r10, r9, straight_decelerate
	

right:
	movia r5, -127 #deceleration value
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	movia r4, 0x05 #set steering angle
	call write_byte
	movia r4, 64 #new steering value
	call write_byte
	br accelerate_after_turn

hard_right:
	movia r5, -127 #deceleration value
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	movia r4, 0x05 #set steering angle
	call write_byte
	movia r4, 127 #new steering value
	call write_byte
	br accelerate_after_turn	
	
left:
	movia r5, -127 #deceleration value
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	movia r4, 0x05 #set steering angle
	call write_byte
	movia r4, -64 #new steering value
	call write_byte
	br accelerate_after_turn	

hard_left:
	movia r5, -127 #deceleration value
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	movia r4, 0x05 #set steering angle
	call write_byte
	movia r4, -127 #new steering value
	call write_byte
	br accelerate_after_turn
	

straight_accelerate:
	movia r5, 127 #acceleration value
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	br get_sensor_data

straight_decelerate:
	movia r5, -127 #acceleration value
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	br get_sensor_data
	

accelerate_after_turn:
	movia r5, 127 #speed back up again
	movia r4, 0x04
	call write_byte
	mov r4, r5 #r5 contains the desired acceleration value
	call write_byte
	br get_sensor_data
	
.section .exceptions, "ax"
#.align 2

rdctl r21, ipending #check ipending to see what device caused the interrupt
mov et, r21
movi r22, 0x100
andi et, et, 0x100 #if bit 8 of ipending is high, we know the JTAG UART is requesting an interrupt
movia r23, JTAG
beq et, r22, JTAG_ISR
mov et, r21
movi r22, 0x1
andi et, et, 0x1 #if bit 0 of ipending is high, we know the timer requested an interrupt
beq et, r22, TIMER_ISR 
br exit


JTAG_ISR:
	ldwio et, 0(r23)
	andi et, et, 0x8000 #bit 15 is "read data is valid"
	beq et, r0, exit
	ldwio r22, 0(r23) #get the read data itself
	andi r22, r22, 0xff
	movi r18, 0x73
	beq r22, r18, speed_mode
	br sensor_mode

speed_mode:
	mov r16, r0
	br exit

sensor_mode:
	movi r16, 0x1
	br exit


TIMER_ISR:
	#r22 contains the value 0x1
	movi r22, 0x1
	beq r16, r22, sensor
	beq r16, r0, speed

sensor:
	# movi r22, 0x1b5b
	# stwio r22, 0(r23)
	# #movi r22, 0x5b
	# #stwio r22, 0(r23)
	# movi r22, 0x324b
	# stwio r22, 0(r23)
	# movi r22, 0x4b
	# stwio r22, 0(r23) #now the JTAG terminal is cleared
	movia r8, 0x01
	stwio r8, 0(r23) #write to the JTAG
	movia et, TIMER
	stwio r0, (et)
	br exit

speed:
	# movi r22, 0x1b5b
	# stwio r22, 0(r23)
	# #movi r22, 0x5B
	# #stwio r22, 0(r23)
	# movi r22, 0x324b
	# stwio r22, 0(r23)
	# #movi r22, 0x4B
	# #stwio r22, 0(r23) #now the JTAG terminal is cleared
	movi r8, 0x01
	stwio r8, 0(r23) #write to the JTAG
	movia et, TIMER
	stwio r0, (et)
	br exit
	
	
exit:
	subi ea, ea, 4
	eret #return so last instruction executed