# Assignment: HW #5, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 2/16/18


.text
.globl main
main:	
	# PROBLEM 3: QuickSort
	# Translated C Code from: https://www.geeksforgeeks.org/quick-sort/
	
	# Load array to test
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
	#jal quickSort
	
	# Print Post-sorted Array to Screen
	la $a0, post_sort_message
	li $v0, 4
	syscall
	
	# Terminate the program
	li $v0, 10
	syscall
	
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

	move $v0, $a0      # Store result in $v0
	jr $ra
	
printArray:
	sub $sp, $sp, 4
	sw $a0, 0($sp)
	move $s3, $a0        # use s3 as array address
	li $t0, 0            # counter
	move $t1, $s3        # $t1 is address of A[i]
	print_array_loop:
		bge $t0, $a1, exit_print_array_loop
		sll $a0, $t0, 2
		add $a0, $a0, $s3
		li $v0, 1
		syscall
		j print_array_loop
	exit_print_array_loop:
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $ra
	
.data
	arrA: .word 9, -18, 27, 84, 4, 11, 70    # size:7x4 = 28 bytes
	pre_sort_message: .asciiz "Pre-sorted Array:\n"
	post_sort_message: .asciiz "Post-sorted Array:\n"
