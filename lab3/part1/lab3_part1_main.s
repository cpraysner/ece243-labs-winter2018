# Print ten in octal, hexadecimal, and decimal
# Use the following C functions:
#     printHex ( int ) ;
#     printOct ( int ) ;
#     printDec ( int ) ;

.global main

main:
	movi r5, 10
	call printOct
	movi r5, 10
	call printHex
	movi r5, 10
	call printDec
ret	# Make sure this returns to main's caller
