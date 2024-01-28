.text
/* Program to Count the number of 1’s in a 32-bit word,
located at InputWord */
.global _start
_start:
/* Your code here */
movia r8, InputWord #address of the Input word
ldw r9, (r8) #value of the address of Input word
movi r10, 0 #this will contain the number of 1s
movi r11, 0
movi r12, 0
movia r13, Answer

movia sp, 0x20000

mov r4, r9

call ONES
stw r2, (r13)

endiloop: br endiloop

ONES:
    subi sp, sp, 4 /* push ra onto the stack */
    stw ra, (sp)

    loop: 
        srli r12, r4, 1
        slli r12, r12, 1
        sub r11, r4, r12
        add r10, r11, r10
        srli r4, r4, 1
        beq r4, r0, secondloop
        br loop

    secondloop: 
        mov r2, r10
		
    ldw ra, (sp) /* pop stack into ra before returning*/
    addi sp, sp, 4
    ret



.data
InputWord: .word 0x4a01fead
Answer: .word 0