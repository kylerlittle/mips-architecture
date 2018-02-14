# Assignment: HW #3, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 2/4/18


.text
.globl main
main:	
	# PROBLEM 1
	# Print instruction
	li $v0, 4
	la $a0, user_instruction
	syscall
	
	# Read keyboard input. Read at maximum 64 characters.
	li $s0, 0         # $s0 will store number of characters read so far; if 6, then exit loop
	la $s1, myString      # $s1 will store the address of myString
	move $a0, $s1   # load arguments (a0 contains address of myString, a1 is max number of chars you can read)
	li $a1, 63
	li $v0, 8
	syscall
	
	# Delete last occurrence of 'a' in myString. ASSUME myString contains an 'a'.
	# Step #1. Get the address of the last character in myString and store in $s2.
	move $s2, $s1
	LAST_CHAR_LOOP:
		lb $t1, 0($s2)    # load character at address s2
		beq $t1, $zero, EXIT_LCL    # exit if '\0'
		beq $t1, 10, EXIT_LCL       # exit if '\n'
		addi $s2, $s2, 1
		j LAST_CHAR_LOOP
	EXIT_LCL:
	addi $s2, $s2, -1      # point at last actual char that isn't null or newline
	
	# Step #2. Get $s2 to point at the last actual 'a' in myString
	LAST_A_LOOP:
		lb $t1, 0($s2)
		beq $t1, 97, EXIT_A
		addi $s2, $s2, -1
		j LAST_A_LOOP
	EXIT_A:
	
	# Step #3. Shift the remaining characters over.
	#	   Use $t1 to store the address of the character at $s2 + 1
	#	   Use $t2 to store the value at ($s2 + 1)
	SHIFT_LOOP:
		move $t1, $s2
		addi $t1, $t1, 1
		lb $t2, 0($t1)    # $t2 stores value of char AFTER $s2
		sb $t2, 0($s2)    # performs the shift
		beq $t2, $zero, EXIT_SHIFT     # exit if $t2 is '\0' since I would have already copied '\0' to where $s2 points 
		addi $s2, $s2, 1    # increment
		j SHIFT_LOOP
	EXIT_SHIFT:
	
	# Print string.
	li $v0, 4
	la $a0, myString
	syscall
	
	
	
	# PROBLEM 2
	
	# Terminate the program
	li $v0, 10
	syscall
	
.data
	myString: .space 64      # 64 chars = 64 bytes
	user_instruction: .asciiz "Enter a string of length at most 64 characters with at least one 'a'.\n"
