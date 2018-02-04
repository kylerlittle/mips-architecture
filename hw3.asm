# Assignment: HW #3, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 2/4/18


.text
.globl main
main:
	# use register $s0 for int x, $s1 for int y
	# use register $t0 for y + 5
	
	# PROBLEM 1 part (1)
	# Store y + 5 in $t0
	li $t0, 0
	addi $t0, $s1, 5
	# Go to label if x<=y+5
	ble $s0, $t0, ELSE
	add $s0, $s0, $s1
	j EXIT
	ELSE:
	sub $s1, $s0, $s1
	EXIT:
	

	# PROBLEM 1 part (2)
	LOOP1:
		li $t0, 0
		addi $t0, $s1, 5
		ble $s0, $t0, EXIT1    # branch to EXIT1 if x <= y+5
		addi $s0, $s0, -1
		addi $s0, $s0, -1
		addi $s1, $s1, 1
		j LOOP1
	EXIT1:
	

	# PROBLEM 1 part (3)
	li $s0, 1
	LOOP2:
		bge $s0, $s1, EXIT2    # exit once x >= y
		addi $s0, $s0, 1
		addi $s0, $s0, 5
		addi $s1, $s1, 1
		j LOOP2
	EXIT2:
	
	
	# PROBLEM 2
	# Print instruction
	li $v0, 4
	la $a0, user_instruction
	syscall
	
	# Read keyboard input
	li $s0, 0         # $s0 will store number of characters read so far; if 6, then exit loop
	la $s1, arrA      # $s1 will store the address of arrA
	READ_LOOP:
		# Get input and store into array
		# 1. Where to store? Use $s2 to store address of arrA[i]
		sll $s2, $s0, 2
		add $s2, $s2, $s1    # s2 now stores address of arrA[$s0]
		# 2. Grab int from keyboard and store to $s2
		li $v0, 5      # stores result to $v0
		syscall
		sw $v0, 0($s2)  # place result in arrA[$s0] = $s2
		
		# Branching Condition
		addi $s0, $s0, 1
		beq $s0, 6, EXIT_READ_LOOP
		j READ_LOOP
	EXIT_READ_LOOP:
	
	# Find second largest int in arrA
	li $t1, -32768     # $t1 will store largest int
	li $t2, -32768     # $t2 will store second largest int
	li $t3, 0          # $t3 is current index i
	LOOP_SLI:     # SecondLargestInt Loop		
		# First, get address and value of arrA[i]
		sll $s2, $t3, 2
		add $s2, $s2, $s1
		lw $t4, 0($s2)  # Store value of arrA[i] into $t4
		
		# First check: arrA[i] > $t1
		ble $t4, $t1, CHECK1
			# If we made it here. Then set $t2 = $t1 and $t1 = arrA[i]
			move $t2, $t1
			move $t1, $t4
		CHECK1:
		# Second check: if $t1 > arrA[i] > $t2, then need to update $t2 to arrA[i]
		ble $t4, $t2, CHECK2
			beq $t4, $t1, CHECK2
				move $t2, $t4
		CHECK2:
		
		# Branching Condition
		addi $t3, $t3, 1
		beq $t3, 6, EXIT_LOOP_SLI
		j LOOP_SLI
	EXIT_LOOP_SLI:
	
	# Print the second largest integer
	move $a0, $t2
	li $v0, 1
	syscall
	
	# Terminate the program
	li $v0, 10
	syscall
	
.data
	arrA: .space 24      # 6 ints * 4 bytes each = 24 bytes
	user_instruction: .asciiz "Enter 6 integers: (for HW, -2, 10, 3, -9, -7, 23)\n"
