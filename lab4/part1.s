.global _start
_start:
    
    movia r14, KEY_BASE
    movia r15, LEDs

    #KEY0 PRESSED
    #poll for key0 pressed
key0:   
    ldwio r13, (r14)
    andi r9, r13, 0b1 
    beq r9, r0, key1
    #poll for key0 unpressed
poll0: 
    ldwio r13, (r14)
    andi r9, r13, 0b1 
    bne r9, r0, poll0
    movi r13, 1
    stwio r13, (r15)


key1:   
    ldwio r13, (r14)
    andi r10, r13, 0b10
    beq r10, r0, key2
poll1:
    ldwio r13, (r14)
    andi r10, r13, 0b10
    bne r10, r0, poll1
    movi r13, 15
    ldwio r10, (r15)
    beq r10, r13, key2
    addi r13, r10, 1
    stwio r13, (r15)

key2:   
    ldwio r13, (r14)
    andi r11, r13, 0b100
    beq r11, r0, key3
poll2:
    ldwio r13, (r14)
    andi r11, r13, 0b100
    bne r11, r0, poll2
    movi r13, 1
    ldwio r11, (r15)
    beq r11, r13, key3
    subi r13, r11, 1
    stwio r13, (r15)



key3:   
    ldwio r13, (r14)
    andi r12, r13, 0b1000
    beq r12, r0, key0  
poll3:
    ldwio r13, (r14)
    andi r12, r13, 0b1000
    bne r12, r0, poll3
    stwio r0, (r15)
wait:
    ldwio r8, (r14)
    andi r13, r8, 0b1111
    beq r13, r0, wait
zero:
    ldwio r8, (r14)
    andi r13, r8, 0b1111
    bne r13, r0, zero
    movi r13, 1
    stwio r13, (r15)

br key0


.data

.equ KEY_BASE, 0xFF200050
.equ LEDs, 0xFF200000