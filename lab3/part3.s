.text
/* Program to Count the number of 1’s and Zeroes in a sequence of 32-bit words,
and determines the largest of each */
.global _start
_start:
/* Your code here */

movia r8, TEST_NUM #address of the list
movi r5, 0 #this will hold the greatest number of 1s in the subroutine
movi r6, 0 #this will hold the greatest number of 0s in the subroutine

movi r11, 32 #this will store the current number of 1s in the current word

movia r14, LargestOnes #this will keep track of largest 1s
movia r15, LargestZeroes #this will keep track of largest 0s

movia sp, 0x20000



call LOOP_THROUGH_LIST

endiloop: br endiloop


LOOP_THROUGH_LIST:
	subi sp, sp, 4 /* push ra onto the stack */
    stw ra, (sp)
	iterate_list:
		movi r10, 0 #this will contain the number of 1s
		movi r12, 0
		movi r13, 0 #this will store the number of 1s in the current word
		ldw r9, (r8) #value of the address of Input word
		beq r9, r0, end_of_loop
		mov r4, r9
		call ONES
		sub r13, r11, r2
		bge r2, r5, adjust_largest_ones
		bge r13, r6, adjust_largest_zeroes
		br repeat
			
	adjust_largest_ones:
		stw r2, (r14)
		mov r5, r2
		bge r13, r6, adjust_largest_zeroes
		br repeat
	
	adjust_largest_zeroes:
		stw r13, (r15)
		mov r6, r13
		br repeat
		
	repeat:
		addi r8, r8, 4
		br iterate_list
		
		
	end_of_loop:
	ldw ra, (sp) /* pop stack into ra before returning*/
    addi sp, sp, 4
    ret



ONES: #returns the number of 1s in the current word with r2
    subi sp, sp, 4 /* push ra onto the stack */
    stw ra, (sp)

    loop: 
        srli r12, r4, 1
        slli r12, r12, 1
        sub r12, r4, r12
        add r10, r12, r10
        srli r4, r4, 1
        beq r4, r0, secondloop
        br loop

    secondloop: 
        mov r2, r10
		
    ldw ra, (sp) /* pop stack into ra before returning*/
    addi sp, sp, 4
    ret


.data
TEST_NUM: .word 0x4a01fead, 0xF677D671,0xDC9758D5,0xEBBD45D2,0x8059519D
.word 0x76D8F0D2, 0xB98C9BB5, 0xD7EC3A9E, 0xD9BADC01, 0x89B377CD
.word 0 # end of list
LargestOnes: .word 0
LargestZeroes: .word 0