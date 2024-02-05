.global _start
_start:

    movia r15, TIMER
    movia r14, LEDs
    movi r8, 0
    movi r9, 0
    movia r13, 250000000
    movi r10, 0b110
    stwio r10, 4(r15)

BIG_LOOP:
    stwio r8, (r14)
    ldwio r10, (r15)
    andi r11, r10, 0b1
    beq r11, r0, BIG_LOOP
    addi r9, r9, 1
    stwio r0, (r15)
    bne r9, r13, BIG_LOOP
    movi r9, 0
    addi r8, r8, 1



.data

.equ TIMER, 0xFF202000
.equ LEDs, 0xFF200000