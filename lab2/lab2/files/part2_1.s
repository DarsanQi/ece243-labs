.text  # The numbers that turn into executable instructions
.global _start
_start:

/* r13 should contain the grade of the person with the student number, -1 if not found */
/* r10 has the student number being searched */


	movia r10, 718293		# r10 is where you put the student number being searched for
        movia r8, Snumbers
        movia r9, Grades
        movi r11, 0
        movi r12, 0


/* Your code goes here  */
loopA: ldw r12, (r8)
        beq r10, r12, loopB
        beq r0, r12, indexNotfound
        addi r8, r8, 4
        addi r11, r11, 1
        
        br loopA

loopB: ble r11, r0, storeIndex
        addi r9, r9, 4
        subi r11, r11, 1
        br loopB

indexNotfound: movi r13, -1
br iloop

storeIndex: ldw r13, (r9)
br iloop

iloop: br iloop



.data  	# the numbers that are the data 

/* result should hold the grade of the student number put into r10, or
-1 if the student number isn't found */ 

result: .word 0
		
/* Snumbers is the "array," terminated by a zero of the student numbers  */
Snumbers: .word 10392584, 423195, 644370, 496059, 296800
        .word 265133, 68943, 718293, 315950, 785519
        .word 982966, 345018, 220809, 369328, 935042
        .word 467872, 887795, 681936, 0


/* Grades is the corresponding "array" with the grades, in the same order*/
Grades: .word 99, 68, 90, 85, 91, 67, 80
        .word 66, 95, 91, 91, 99, 76, 68  
        .word 69, 93, 90, 72
	
	
