#Homework 4
#CS 2340
#Ismail Ahmed
#MIPS Assembly Language Program that uses Bitmap to display a box made of pixels.
#The box has different colors for each bit.
#It can move up, down, left, or right while making sure to delete the box from the previous position.
#To run the program, click Tools -> Bitmap Display, Keyboard and Display MMIO Simulator.
#After that, click the Assemble icon. Then, in the Bitmap Display, change the unit width and heigt in pixels to 4,
#display width and height in pixels to 256, and the base address for display to ($gp).
# After that, click Connect to MIPS for both. Then, click Run. Finally, in the bottom textbox of the Simulator, type in character
# w to move the box up, a to move the box left, s to move the box down, d to move the box right, and space to quit. Click Close on each to exit.


# width of screen in pixels
# 256 / 4 = 64
.eqv 		WIDTH 		64
# 256 / 4 = 64
# height of screen in pixels
.eqv 		HEIGHT		64

# colors
.eqv		RED 		0x00FF0000
.eqv		GREEN 		0x0000FF00
.eqv		BLUE		0x000000FF
.eqv		WHITE		0x00FFFFFF
.eqv		YELLOW		0x00FFFF00
.eqv		CYAN		0x0000FFFF
.eqv		MAGENTA		0x00FF00FF

.data
colors:		.word		MAGENTA, CYAN, YELLOW, BLUE, GREEN, RED

.text
main:
	# set up starting position
	addi 	$a0, $0, WIDTH    	# a0 = X = WIDTH/2
	sra 	$a0, $a0, 1
	addi 	$a1, $0, HEIGHT   	# a1 = Y = HEIGHT/2
	sra 	$a1, $a1, 1
	addi 	$a2, $0, RED  		# a2 = red (ox00RRGGBB)
	
	la	$s0, colors		# load address of colors array into register
	li	$t1, 0			# pixel limit length
	
mainLoop:
	# check for input
	lw 	$t0, 0xffff0000  	#t1 holds if input available
    	beq 	$t0, 0, loop1   	#If no input, keep displaying
	
	# process input
	lw 	$s1, 0xffff0004
	beq	$s1, 32, exit	# input space
	beq	$s1, 119, up 	# input w
	beq	$s1, 115, down 	# input s
	beq	$s1, 97, left  	# input a
	beq	$s1, 100, right	# input d

	# invalid input, ignore
	j	mainLoop

up:	
	# removes previous boxes
	li	$a2, 0			# black out the pixel
	jal	sLoop1
	
	# moves box up
	addi	$a1, $a1, -1		# move box up by size 1
	jal	loop1
	
	j mainLoop
	
down:	
	# removes previous boxes
	li	$a2, 0			# black out the pixel
	jal	sLoop1
	
	# moves box up
	addi	$a1, $a1, 1		# move box down by size 1
	jal	loop1
	
	j mainLoop
	
left:	
	# removes previous boxes
	li	$a2, 0			# black out the pixel
	jal	sLoop1
	
	# moves box up
	addi	$a0, $a0, -1		# move box left by size 1
	jal	loop1
	
	j mainLoop
	
right:	
	# removes previous boxes
	li	$a2, 0			# black out the pixel
	jal	sLoop1
	
	# moves box up
	addi	$a0, $a0, 1		# move box right by size 1
	jal	loop1
	
	j mainLoop

loop1:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	# address of color array
	sll 	$t3, $t2, 2		# word
	add 	$t3, $t3, $s0		# address of byte for a word
	lw 	$a2, ($t3)		# color element into register
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi 	$t1, $t1, 1 		# increment pixel counter
	#addi	$t7, $t7, 1		# increment pixel index
	addi	$a0, $a0, 1 		# increment x coord
	addi 	$t2, $t2, 1 		# increment address index
	
	jal pause			# pause between pixel writes
	
	bne 	$t2, 6, reLoop1		# if index not less than value after last element, go to label

	# reset index to starting pos if it is out of bounds
	li	$t6, 0
	move	$t2, $t6		# reset index to 0 starting pos
	
	j loop1				# restart loop to get final element w 0th color element
			
reLoop1:
	blt 	$t1, 7, loop1		# only 7 pixels 
	
li	$t1, 0 # pixel limit length
loop2:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	# address of color array
	sll 	$t3, $t2, 2		# word
	add 	$t3, $t3, $s0		# address of byte for a word
	lw 	$a2, ($t3)		# integer to print
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi	$a1, $a1, 1		# increment y coord
	addi 	$t1, $t1, 1		# increment pixel counter
	addi 	$t2, $t2, 1		# increment address index
	
	jal pause			# pause between pixel writes

	bne 	$t2, 6, reLoop2		# if index not less than value after last element, go to label

	# reset index to starting pos if it is out of bounds
	li	$t6, 0
	move	$t2, $t6		# reset index to 0 starting pos
	
	j loop2				# restart loop to get final element w 0th color element
	
reLoop2:
	blt 	$t1, 7, loop2		# only 7 pixels 
	
li	$t1, 0 # pixel limit length
loop3:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	# address of color array
	sll 	$t3, $t2, 2		# word
	add 	$t3, $t3, $s0		# address of byte for a word
	lw 	$a2, ($t3)		# integer to print
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi	$a0, $a0, -1		# increment x coord
	addi 	$t1, $t1, 1		# increment pixel counter
	addi 	$t2, $t2, 1		# increment address index
	
	jal pause			# pause between pixel writes

	bne 	$t2, 6, reLoop3		# if index not less than value after last element, go to label	

	# reset index to starting pos if it is out of bounds
	li	$t6, 0
	move	$t2, $t6		# reset index to 0 starting pos
	
	j loop3				# restart loop to get final element w 0th color element

reLoop3:
	blt 	$t1, 7, loop3		# only 7 pixels 
	
li	$t1, 0 # pixel limit length
loop4:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	# address of color array
	sll 	$t3, $t2, 2		# word
	add 	$t3, $t3, $s0		# address of byte for a word
	lw 	$a2, ($t3)		# integer to print
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi	$a1, $a1, -1		# increment y coord
	addi 	$t1, $t1, 1		# increment pixel counter
	addi 	$t2, $t2, 1		# increment address index
	
	jal pause			# pause between pixel writes

	bne 	$t2, 6, reLoop4		# if index not less than value after last element, go to label

	# reset index to starting pos if it is out of bounds
	li	$t6, 0
	move	$t2, $t6		# reset index to 0 starting pos
	
	j loop4				# restart loop to get final element w 0th color element
	
reLoop4:
	blt 	$t1, 7, loop4		# only 7 pixels
	
	li	$t1, 0 			# pixel limit length reset
	li	$t2, 0 			# array address index reset
	
	#addi	$t4, $t4, 1		# increment since went through whole square
	
	j 	mainLoop		# jump to mainLoop to refresh box
	
pause:
	# save to stack
	addi	$sp, $sp, -8
	sw	$ra, ($sp)
	sw	$a0, 4($sp)
	
	# pause
	li 	$v0, 32			# system call for sleep
	li 	$a0, 50			# length of time to sleep in milliseconds
	syscall				# sleep
	
	# restore from stack
	lw	$ra, ($sp)
	lw	$a0, 4($sp)
	addi	$sp, $sp, 8
	
	jr	$ra			# go back to calling function after calling line

# following functions used for removing boxes
sLoop1:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi 	$t1, $t1, 1 		# increment pixel counter
	#addi	$t7, $t7, 1		# increment pixel index
	addi	$a0, $a0, 1 		# increment x coord
	
	blt 	$t1, 7, sLoop1		# only 7 pixels 
	
li	$t1, 0 # pixel limit length
sLoop2:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi	$a1, $a1, 1		# increment y coord
	addi 	$t1, $t1, 1		# increment pixel counter

	blt 	$t1, 7, sLoop2		# only 7 pixels 
	
li	$t1, 0 # pixel limit length
sLoop3:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi	$a0, $a0, -1		# increment x coord
	addi 	$t1, $t1, 1		# increment pixel counter
	
	blt 	$t1, 7, sLoop3		# only 7 pixels 
	
li	$t1, 0 # pixel limit length
sLoop4:
	# s1 = address = $gp + 4*(x + y*width), address where color should go
	mul	$t9, $a1, WIDTH   	# y * WIDTH
	add	$t9, $t9, $a0	  	# add X
	mul	$t9, $t9, 4	  	# multiply by 4 to get word offset
	add	$t9, $t9, $gp	  	# add to base address
	
	sw	$a2, ($t9)	  	# store color at memory location
	
	# incrementations
	addi	$a1, $a1, -1		# increment y coord
	addi 	$t1, $t1, 1		# increment pixel counter
	
	blt 	$t1, 7, sLoop4		# only 7 pixels
	
	li	$t1, 0 			# pixel limit length reset, here cuz of mainLoop

	jr $ra
	
exit:	
	li	$v0, 10			# system call to exit program
	syscall				# exit program
