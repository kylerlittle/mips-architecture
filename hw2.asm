	.text 
	.globl main
main:
	la $a0, helloStr
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	

	.data
helloStr: .asciiz "Hello\n"
