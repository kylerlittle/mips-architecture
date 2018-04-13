# Assignment: HW #11, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 4/13/18


.text
.globl main
main:	
	# Keyboard input: X+Y=
	# Display output: X+Y=Z (where Z is the actual sum)
	
	lui $t0, 0xFFFF
	li $s5, 0               # $s5 will store number of characters read so far
	
	polling_loop:
		lw $t1, 8($t0)      # $t1 now stores the contents of the transmitter control
		andi $t2, $t1, 0x0001
		beq $zero, $t2, polling_loop         # if true, not ready to write to transmitter or transmitter is busy
		sw $s0, 12($t0)                      # if we made it here, user pressed a character, so we store it in $s0
		
		# increment number of characters read
		addi $s5, $s5, 1
		
		# if number of characters read is 4, exit
		beq $s5, 4, exit
		
		j polling_loop
	exit:
	
		
	
char2num:
	lb $t0, asciiZero         # load '0' byte in ASCII to $t0
	subu $v0, $a0, $t0        # argument supplied ($a0) - '0'   ==> store result in $v0 
	jr $ra
	
num2char:
	lb $t0, asciiZero         # load '0' byte in ASCII to $t0
	addu $v0, $a0, $t0        # argument supplied ($a0) + '0'   ==> store result in $v0 
	jr $ra

	# Terminate the program
	li $v0, 10
	syscall
	
.data
	asciiZero: .byte '0'
	exp: .space 30