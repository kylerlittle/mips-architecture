# Assignment: HW #6, Zhe Dang, Introduction to Computer Architecture
# Author: Kyler Little
# Last Modified: 3/5/18


.text
.globl main
main:	
	# PROBLEM 3: Cubic Root of Three
	# Use $f0 for m = 3.0, $f1 = 2.0, $f2 = f(k), $f3 = f(k+1), $f4 = 1e-3, $f5 = 3.0, $f6 = f(k) ^2, $f7 = 2*f(k), $f8 = f(k) ^ 3
	
	# 1. Initialize variables
	#	$f0 = 3.0, $f1 = 2.0, $f2 = 3.0, $f4 = 1e-3, $f5 = 3.0
	li $s1, 3
	mtc1 $s1, $f0
	cvt.s.w $f0, $f0
	li $s1, 2
	mtc1 $s1, $f1
	cvt.s.w $f1, $f1
	li $s1, 100
	mtc1 $s1, $f2
	cvt.s.w $f2, $f2
	li $s1, 1
	mtc1 $s1, $f4
	cvt.s.w $f4, $f4
	li $s1, 1000
	mtc1 $s1, $f10
	cvt.s.w $f10, $f10
	div.s $f4, $f4, $f10
	li $s1, 3
	mtc1 $s1, $f5
	cvt.s.w $f5, $f5
	
	# 2. Loop until precision is < 1e-3 
	LOOP:
		# First, check if | (f(k)^3) - m | < 1e-3
		mul.s $f8, $f2, $f2
		mul.s $f8, $f8, $f2        # f(k) ^ 3
		sub.s $f8, $f8, $f0        # (f(k) ^ 3) - 3.0 (what m is)
		abs.s $f8, $f8             # take abs of it
		c.lt.s $f8, $f4            # if | (f(k)^3) - m | < 1e-3 then branch
		bc1t done
		
		# Calculate f(k+1)
		mul.s $f6, $f2, $f2        # f(k) ^ 2
		div.s $f3, $f0, $f6        # m / (f(k) ^2)
		mul.s $f7, $f2, $f1        # 2 * f(k)
		add.s $f3, $f7, $f3 	   # numerator
		div.s $f3, $f3, $f5        # numerator / 3.0       # f(k+1)
		
		# Move f(k+1) into f(k)
		mov.s $f2, $f3
		j LOOP
	done:
	
	# Print cubic_root_message
	la $a0, cubic_root_message
        li $v0, 4
        syscall
	# Print cubic root of 3.0
	mov.s $f12, $f2
	li $v0, 2
	syscall 

	# Terminate the program
	li $v0, 10
	syscall
	
.data
	cubic_root_message: .asciiz "cubic_root(3) = "
