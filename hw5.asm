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
	
	# Call quick sort on arrA
	move $a0, $s1
	li $a1, 0
	li $a2, 6
	jal quickSort
	
	# Print Post-sorted Array to Screen
	la $a0, post_sort_message
	li $v0, 4
	syscall
	
	# Terminate the program
	li $v0, 10
	syscall
	
quickSort:
	# Save registers $a0 (array to sort), $a1 (low), $a2 (high), $ra, and $s2 (pivot)
	jr $ra
	
partition:
	jr $ra
	
.data
	arrA: .word 9, -18, 27, 84, 4, 11, 70    # size:7x4 = 28 bytes
	pre_sort_message: .asciiz "Pre-sorted Array:\n"
	post_sort_message: .asciiz "Post-sorted Array:\n"
