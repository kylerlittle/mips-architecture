# Assignment: HW #5, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 2/17/18


.text
.globl main
main:	
	# PROBLEM 1: AlmostFibonacci
	li $a0, 4
	jal almostFibonacci
	move $s7, $v0          # store almostFibonacci(4) in $s7
	la $a0, almost_fib_message
	li $v0, 4
	syscall
	move $a0, $s7
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall
	
	
	
	# PROBLEM 2: Omega
	li $a0, 15
	jal omega
	move $s6, $v0          # store omega(4) in $s6
	la $a0, omega_message
	li $v0, 4
	syscall
	move $a0, $s6
	li $v0, 1
	syscall
	la $a0, newline
	li $v0, 4
	syscall



	# PROBLEM 3: QuickSort
	# Translated C Code from: https://www.geeksforgeeks.org/quick-sort/
	
	# Load array A to test
	la $s1, arrA
	
	# Print Pre-sorted Array to Screen
	la $a0, pre_sort_message
	li $v0, 4
	syscall
	move $a0, $s1
	li $a1, 7
	jal printArray
	
	# Call quick sort on arrA
	move $a0, $s1
	li $a1, 0
	li $a2, 6
	jal quickSort
	
	# Print Post-sorted Array to Screen
	la $a0, post_sort_message
	li $v0, 4
	syscall
	move $a0, $s1
	li $a1, 7
	jal printArray
	
	
	
	# Load array B to test
	la $s1, arrB
	
	# Print Pre-sorted Array to Screen
	la $a0, pre_sort_message
	li $v0, 4
	syscall
	move $a0, $s1
	li $a1, 8
	jal printArray
	
	# Call quick sort on arrA
	move $a0, $s1
	li $a1, 0
	li $a2, 7
	jal quickSort
	
	# Print Post-sorted Array to Screen
	la $a0, post_sort_message
	li $v0, 4
	syscall
	move $a0, $s1
	li $a1, 8
	jal printArray
	
	# Terminate the program
	li $v0, 10
	syscall
	
almostFibonacci:
	beqz $a0, base_case_0
	beq $a0, 1, base_case_1
	
	# Save registers $a0 (N), $ra (return address), $t0 (almostFibonacci(N-1)), $t1 (almostFibonacci(N-2))
	sub $sp, $sp, 20
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	sw $t0, 8($sp)
	sw $t1, 12($sp)
	
	# Recurse. Store almostFibonacci(n-1) in $t0, almostFibonacci(n-2) in $t1
	sub $a0, $a0, 1
	jal almostFibonacci
	move $t0, $v0
	
	sub $a0, $a0, 1
	jal almostFibonacci
	move $t1, $v0
	
	# Calculate 2*almostFibonacci(N-1) + 3*almostFibonacci(N-2) and store in $v0
	mul $t0, $t0, 2
	mul $t1, $t1, 3
	add $v0, $t0, $t1
	
	lw $t1, 12($sp)
	lw $t0, 8($sp)
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 20
	jr $ra
	
	base_case_0:
		li $v0, 1
		jr $ra
	base_case_1:
		li $v0, 2
		jr $ra
	
omega:
	jr $ra
	
quickSort:
	bge $a1, $a2, exit_quickSort
	# Save registers $a0 (array to sort), $a1 (low), $a2 (high), $ra, and $s2 (pivot)
	addi $sp, $sp, -20
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	sw $s2, 16($sp)
	
	# Calculate partition
	jal partition        # result stored in $v0
	move $s2, $v0        # partition result stored in $v0
	
	# Recurse
	sub $a2, $s2, 1      
	jal quickSort      # ($a0 = arr, $a1 = low, $a2 = $s2 - 1)
	add $a1, $s2, 1
	lw $a2, 8($sp)
	jal quickSort      # ($a0 = arr, $a1 = $s2 + 1, $a2 = high)
	
	# Put saved values back into registers.
	lw $s2, 16($sp)
	lw $ra, 12($sp)
	lw $a2, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 20
	exit_quickSort:
	jr $ra
	
partition:
	# Recall, $a0 = adress of array; $a1 is low; $a2 is high
	# Use $t0 for pivot, use $t1 for address of arr[high], $t2 for i, $t3 for j, $t4 for high-1, $t5 for address of arr[i], 
	# $t6 for val of arr[i], $t7 for address of arr[j], $t8 for value of arr[j]
	sll $t1, $a2, 2
	add $t1, $t1, $a0
	lw $t0, 0($t1)
	addi $t2, $a1, -1
	move $t3, $a1
	addi $t4, $a2, -1
	partition_loop:
		bgt $t3, $t4, exit_partition_loop
		sll $t7, $t3, 2
		add $t7, $t7, $a0
		lw $t8, 0($t7)
		bgt $t8, $t0, exit_if_pl
		addi $t2, $t2, 1
		sll $t5, $t2, 2
		add $t5, $t5, $a0
		lw $t6, 0($t5)
		sw $t6 0($t7)
		sw $t8 0($t5)
		exit_if_pl:
		addi $t3, $t3, 1
		j partition_loop
	exit_partition_loop:
	# Now, swap arr[high] and arr[i+1]
	addi $t2, $t2, 1       # add one to i
	sll $t5, $t2, 2
	add $t5, $t5, $a0      # $t5 now stores address of arr[i+1]
	lw $t6, 0($t5)         # $t6 stores value of arr[i+1]
	sll $t7, $a2, 2
	add $t7, $t7, $a0      # $t7 now stores address of arr[high]
	lw $t8, 0($t7)         # $t8 stores value of arr[high]
	sw $t6, 0($t7)         # value of arr[i+1] stored in arr[high]
	sw $t8, 0($t5)         # value of arr[high] stored in arr[i+1]
	move $v0, $t2      # Store i + 1 in $v0
	jr $ra
	
printArray:
	sub $sp, $sp, 4
	sw $a0, 0($sp)
	move $s3, $a0        # use s3 as array address
	li $t0, 0            # counter
	move $t1, $s3        # $t1 is address of A[i]
	print_array_loop:
		bge $t0, $a1, exit_print_array_loop
		sll $t1, $t0, 2
		add $t1, $t1, $s3
		lw $a0, 0($t1)
		li $v0, 1
		syscall
		la $a0, space
		li $v0, 4
		syscall
		addi $t0, $t0, 1
		j print_array_loop
	exit_print_array_loop:
	la $a0, newline
	li $v0, 4
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
.data
	almost_fib_message: .asciiz "almostFibonacci(4) = "
	omega_message: .asciiz "omega(15) = "
	arrA: .word 10, 2, 17, 9, 6, 4, 8    # size:7x4 = 28 bytes
	arrB: .word 28, 26, 24, 22, 20, 18, 0, -18   # size 8x4 = 32 bytes
	pre_sort_message: .asciiz "Pre-sorted Array:\n"
	post_sort_message: .asciiz "Post-sorted Array:\n"
	space: .asciiz " "
	newline: .asciiz "\n"
