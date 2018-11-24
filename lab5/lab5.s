.global _start

.equ BASE, 0x10001020	#Car World JTAG UART Base Address

_start:

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
	
# top_of_hill:
	# movia r4, 0x02 #send a 0x02 to request sensors and speed
	# call write_byte
	# call read_byte #first byte should be 0x00
	# bne r3, r0, read_sensors_and_speed
	# call read_byte
	# mov r8, r3 #r8 now contains the sensor values
	# call read_byte
	# mov r9, r3 #r9 now contains the speed
	# movia r4, 0x03 #request to get position data
	# call write_byte
	# call read_byte
	# call read_byte
	# call read_byte
	# call read_byte
	# mov r11, r3 #r3 now contains the z coordinate
	# movia r10, 35
	# ble r9, r10, straight_accelerate_hill
	# blt r10, r9, straight_decelerate_hill
	# bne r3, r0, top_of_hill
	# br get_sensor_data