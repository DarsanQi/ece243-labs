.global _start
_start:
	
movia r14, KEY_BASE
movia r15, LEDs
movi r9, 0
movi r10, 255

stwio r13, (r14)
	
DO_DELAY: 
movia r8, 500000

SUB_LOOP: 
ldwio r11, 0xC(r14)
andi r12, r11, 0b1111
bne r12, r0, clear_flag
br continue

clear_flag:
stwio r12, 0xC(r14)

wait:
ldwio r11, 0xC(r14)
andi r12, r11, 0b1111
beq r12, r0, wait
stwio r12, 0xC(r14)

continue:
subi r8, r8, 1
stwio r9, (r15)
bne r8, r0, SUB_LOOP

increment_counter: 
addi r9, r9, 1

done_increment:
beq r9, r10, reset_counter
br restart

reset_counter:
mov r9, r0

restart:
br DO_DELAY

.data 

.equ KEY_BASE, 0xFF200050
.equ LEDs, 0xFF200000