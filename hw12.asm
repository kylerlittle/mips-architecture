# Assignment: HW #12, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 4/20/18


.text
.globl main
main:	
	# Program Goal:
	# Keyboard input: X+Y=
	# Display output: X+Y=Z (where Z is the actual sum)
	# Method: KEYBOARD INTERRUPT
	
	# 1. Load important things into registers.
	la $s2, exp               # use $s2 for address of expression
	lw $s5, explen            # $s5 will store number of characters read so far
	
	# 2. By default, receiver control and transmitter control interrupt-enable bits are all 1 (second least significant bit)
	#    but we should turn them on anyways just to be safe
	jal grab_receiver_control
	jal enable_receiver_control_interrupt
	
	# 3. Do an infinite loop
	can_be_interrupted_loop:
		#jal grab_receiver_control
		#jal receiver
		#addi $s5, $s5, 1          # increment number of characters read so far	
		#sw $s5, explen            # store for later use
		
		add $t1, $t1, $zero      # some nonsense
		beq $s5, 4, exit         # if number of characters read is 4, exit and begin outputting
		j can_be_interrupted_loop
		
	exit:
		# 1. Disable interrupt_enable bit
		
		# 2. Compute result. Use polling to display!
		jal compute_result
		li $s6, 0     # character count for the number output
		
	output_loop:
		move $a0, $s6    # before calling transmit_loop, we load the number of characters output so far
		jal grab_receiver_control
		jal transmit
		addi $s6, $s6, 1
		beq $s6, $s5, terminate
		j output_loop
	
	terminate:
		# Terminate the program
		li $v0, 10
		syscall
	
	# Put receiver control address into $t0
	grab_receiver_control:
		lui $t0, 0xFFFF
		jr $ra
	
	# Assuming grab_receiver_control is called right before this, this sets the interrupt bit to true
	enable_receiver_control_interrupt:
		lw $t1, 0($t0)
		ori $t1, $t1, 0x0002
		sw $t1, 0($t0)
		jr $ra
	
	# Keep reading from receiver data whenever receiver control is ready
	receiver:
		# Save stuff
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		
		receiver_loop:
			lw $t1, 0($t0)
			andi $t2, $t1, 0x0001        # isolate the ready bit
			beq $zero, $t2, receiver_loop      # if ready bit was 0
			
		lw $a0, 4($t0)        # Now the lower 8 bits of $a0 store the keyboard input
		jal append_char       # append character to array exp!
		
		# Retrieve saved stuff
		lw $t1, 12($sp)
		lw $t0, 8($sp)
		lw $ra, 4($sp)
		lw $a0, 0($sp)
		
		jr $ra
	
	# Keep writing to the display whenever transmit control is ready
	transmit:
		# Save stuff
		sw $a0, 0($sp)
		sw $ra, 4($sp)
		sw $t0, 8($sp)
		sw $t1, 12($sp)
		
		transmit_loop:
			lw $t1, 8($t0)      # $t1 now stores the entire 32 bits of the transmitter control
			andi $t2, $t1, 0x0001
			beq $zero, $t2, transmit_loop         # if true, not ready to write to transmitter or transmitter is busy
			
		jal return_ith_char
		sw $v0, 12($t0)                      # if we made it here, user pressed a character, so we store it to echo to display controller
		
		# Retrieve saved stuff
		lw $t1, 12($sp)
		lw $t0, 8($sp)
		lw $ra, 4($sp)
		lw $a0, 0($sp)
		jr $ra	
	
	# Append character ($a0) to exp
	append_char:
		sw $t6, 0($sp)
		add $t6, $s2, $s5   # current exp length + address of exp will give us address of where to put the char
		sb $a0, 0($t6)      # the lower 8 bits of $a0 is the char to append, so we store that byte at address $t6 or exp[len(exp)], which is appending
		lw $t6, 0($sp)
		jr $ra
	
	# Given an index in $a0, return exp[$a0]
	return_ith_char:
		sw $t0, 0($sp)       # save $t0
		add $t0, $s2, $a0    # address of exp + number of chars output so far (which is i) will give us address of where the next char to grab is
		lb $v0, 0($t0)
		lw $t0, 0($sp)       # retrieve $t0 to put back in place	
		jr $ra
		
	# Compute result of X+Y= and store in same array so resulting array is X+Y=Z where Z could be at most two digits
	compute_result:
		# Store return address since I'm calling functions within this function
		sw $ra, 0($sp)
		
		# Use registers $t8 and $t9 for storing the two numbers to add. Grab the CHARACTERS using offset, then convert to num.
		lb $a0, 0($s2)
		jal char2num
		move $t8, $v0
		lb $a0, 2($s2)
		jal char2num
		move $t9, $v0
		
		# Store result of addition in $t7
		add $t7, $t8, $t9
		
		# Now, convert the result to one or two ascii characters and append to array
		bge $t7, 10, two_digits   # if result of addition is greater than or equal to 10, we have two ascii chars to append
		move $a0, $t7
		jal num2char
		sb $v0, 4($s2)
		j increment
		
		# If two digits, first ascii dig will be $t7 / 10 and second digit is $t7 % 10
		two_digits:
			li $t8, 10
			div $t7, $t8      # num/10-- HI contains remainder (second digit)... LOW contains  quotient (first digit).
			mflo $a0
			jal num2char
			sb $v0, 4($s2)
			mfhi $a0
			jal num2char
			sb $v0, 5($s2)
			addi $s5, $s5, 1          # increment number of characters read so far	(we'll do again for second char once we enter increment label)
			sw $s5, explen            # store for later use
			
		# Don't forget to increment explen one last time (one more time for two_digits and first time for one_digit)
		increment:
			addi $s5, $s5, 1          # increment number of characters read so far	
			sw $s5, explen            # store for later use
			
		# Grab the actual return address from the stack.
		lw $ra, 0($sp)
		jr $ra
		
interrupt_handler:
	# How in the hell do I call functions in here if I can't use the stack??? Figure this shit out.
	# I don't want to continue writing un-modularized code... it's quite painful

	# Retrieve character from receiver data
	lui $t0, 0xFFFF       # address of receiver  ==> $t0
	lw $t1, 0($t0)        # contents of receiver  ==> $t1
	andi $t1, $t1, 0x0001        # isolate the ready bit
	beq $zero, $t1, return      # if ready bit was 0, simply return
	lw $t2, 4($t0)
	
	# Append character to end of exp
	lw $s5, explen
	la $s2, exp
	add $t6, $s2, $s5   # current exp length + address of exp will give us address of where to put the char
	sb $t2, 0($t6)      # the lower 8 bits of $t2 is the char to append, so we store that byte at address $t6 or exp[len(exp)], which is appending
	
	# Increment explen
	addi $s5, $s5, 1          # increment number of characters read so far	
	sw $s5, explen            # store for later use
	
	# If current character is '=', then evaluate the expression (already wrote this part)
	bne $t2, 61, dont_compute
	
	# Send to display using polling
	# jal output_loop      <--- this part needs to be slightly modified but it's mainly good
	
	dont_compute:
	jr $ra
	
retrieve_char:
	# Retrieve the character from the receiver data using retriever control
	lw $t1, 0($t0)
	andi $t1, $t1, 0x0001        # isolate the ready bit
	beq $zero, $t1, return      # if ready bit was 0, simply return
	lw $v0, 4($t0)
	return:
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
	explen: .word 0
	
	
.ktext 0x80000180
	# 1. Save all registers I used here (aside from $k0, $k1) AND $at to KERNEL memory
	sw $at, _k_save_at
	sw $t0, _k_save_t0
	sw $t1, _k_save_t1
	sw $t2, _k_save_t2
	sw $t3, _k_save_t3
	
	# 2. Check cause register to make sure the cause is NOT an exception (bits 2-6)
	mfc0 $k0, $13        # get cause register for coprocessor 0
	srl $a0, $k0, 2    # extract cause (bits 2-6) be shifting right
	
	# 3. Check cause register to make sure the cause IS a keyboard interrupt
	#    AND clear the cause register
	
	# 4. Reset the status register by enabling interrupt once more (probably need to copy the code down to here rather than fct call)
	# status reggie is $12
	
	# 5. Interrupt Handler
		# first, save all registers I used in 'interrupt_handler'
	la $k0, interrupt_handler
	jalr $k0
		# after call, restore those registers
	
	done:
	# 6. Restore any other registers I used here
	lw $at, _k_save_at
	lw $t0, _k_save_t0
	lw $t1, _k_save_t1
	lw $t2, _k_save_t2
	lw $t3, _k_save_t3

	# 7. Return
	eret

.kdata
	_k_save_at: .word 0
	_k_save_t0: .word 0
	_k_save_t1: .word 0
	_k_save_t2: .word 0
	_k_save_t3: .word 0
