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


loop: beq r9, r0, secondloop
srli r12, r9, 1
slli r12, r12, 1
sub r11, r9, r12
add r10, r11, r10
srli r9, r9, 1
br loop

secondloop: stw r13, (r10)
br endiloop

endiloop: br endiloop
.data
InputWord: .word 0x4a01fead
Answer: .word 0
