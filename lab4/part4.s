.global _start
_start:

    movia r15, TIMER
    movia r14, LEDs
    movia r13, KEYS
    movi r8, 0 # # of 10ns periods
    movi r9, 0 #seconds
    movi r10, 0 #hundreths

    #enable clock
    movi r11, 0b110
    stwio r11, 4(r15)

BIG_LOOP:
    #check for key
    ldwio r11, 0xC(r14)
    andi r11, r11, 0b1111
    bne r11, r0, clear_flag
    br continue

    clear_flag:
    stwio r11, 0xC(r14)

    wait:
    ldwio r11, 0xC(r14)
    andi r11, r11, 0b1111
    beq r11, r0, wait
    stwio r11, 0xC(r14)



continue:
    srli r11, r9, 7
    add r11, r11, r10
    stwio r11, (r14)    

    ldwio r11, (r15)
    andi r11, r11, 0b1
    beq r11, r0, BIG_LOOP

    addi r8, r8, 1
    movia r11, 10000000
    beq r8, r11, increment_hundredths
    br BIG_LOOP

increment_hundredths:
    movi r8, 0
    addi r10, r10, 1
    movia r11, 100
    beq r10, r11, increment_seconds
    br BIG_LOOP

increment_seconds:
    movi r10, 0
    addi r9, r9, 1
    movia r11, 8
    beq r9, r11, reset
    br BIG_LOOP

reset:
    mov r8, r0
    mov r9, r0
    br BIG_LOOP

.data

.equ TIMER, 0xFF202000
.equ LEDs, 0xFF200000
.equ KEYS, 0xFF200050
