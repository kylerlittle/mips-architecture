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
	
	# Terminate the program
	li $v0, 10
	syscall
	
.data
	#blah
