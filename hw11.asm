# Assignment: HW #11, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 4/14/18


.text
.globl main
main:	
	# Program Goal:
	# Keyboard input: X+Y=
	# Display output: X+Y=Z (where Z is the actual sum)
	
	li $s5, 0               # $s5 will store number of characters read so far
	input_loop:
		jal grab_receiver_control
		jal receiver_loop
		addi $s5, $s5, 1          # increment number of characters read so far	
		beq $s5, 4, output         # if number of characters read is 4, exit and begin outputting
		j input_loop
	
	output:
		jal transmit_loop

	# Change receiver_loop so that it stores the input values in an array!
	# Once number of values is 4, simply compute the expression and store the result at the end of the array. THEN...
	# We poll the transmitter to display the results!
	
	# Terminate the program
	li $v0, 10
	syscall
	
	# Put receiver control address into $t0
	grab_receiver_control:
		lui $t0, 0xFFFF
		jr $ra
	
	# Keep reading from receiver data whenever receiver control is ready
	receiver_loop:
		lw $t1, 0($t0)
		andi $t2, $t1, 0x0001
		beq $zero, $t2, receiver_loop
		lw $s0, 4($t0)  # Now the lower 8 bits of $s0 store the keyboard input
		jr $ra
	
	# Keep writing to the display whenever transmit control is ready
	transmit_loop:
		lw $t1, 8($t0)      # $t1 now stores the entire 32 bits of the transmitter control
		andi $t2, $t1, 0x0001
		beq $zero, $t2, transmit_loop         # if true, not ready to write to transmitter or transmitter is busy
		sw $s0, 12($t0)                      # if we made it here, user pressed a character, so we store it in $s0 to echo to console
		jr $ra		
	
char2num:
	lb $t0, asciiZero         # load '0' byte in ASCII to $t0
	subu $v0, $a0, $t0        # argument supplied ($a0) - '0'   ==> store result in $v0 
	jr $ra
	
num2char:
	lb $t0, asciiZero         # load '0' byte in ASCII to $t0
	addu $v0, $a0, $t0        # argument supplied ($a0) + '0'   ==> store result in $v0 
	jr $ra

	
.data
	asciiZero: .byte '0'
	exp: .space 30
