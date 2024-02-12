

.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 28         # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
        stw     r11, 12(sp)
        stw     r14, 16(sp)
        stw     r15, 20(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 24(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        br    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        movi r14, 0b1111
        stwio r14, 12(r12)
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     r11, 12(sp)
        ldw     r14, 16(sp)
        ldw     r15, 20(sp)
        ldw     ea, 24(sp)
        addi    sp, sp, 28          # restore stack pointer
        eret                        # return from exception

KEY_ISR:
        ldwio r14, 12(r12)        # store the edge capture registers

        andi r15, r14, 0b0001 # check if KEY0 was pressed
        bne r15, r0, KEY0_PRESSED

        andi r15, r14, 0b0010 # check if KEY1 was pressed
        bne r15, r0, KEY1_PRESSED

        andi r15, r14, 0b0100 # check if KEY2 was pressed
        bne r15, r0, KEY2_PRESSED

        andi r15, r14, 0b1000 # check if KEY3 was pressed
        bne r15, r0, KEY3_PRESSED

KEY0_PRESSED:
        br ADJUST_TIMER

KEY1_PRESSED:   
        br ADJUST_TIMER

KEY2_PRESSED:  
        br ADJUST_TIMER

KEY3_PRESSED:
        br ADJUST_TIMER                         # code not shown

ADJUST_TIMER:
    ldw r15, (r11)
    beq r15, r0, CONTINUE_TIMER
    br PAUSE_TIMER

CONTINUE_TIMER:
    movi r11, 1
    stw r15, 0(r11)
    br END_ISR

PAUSE_TIMER:
    movi r11, 0
    stw r15, 0(r11)
    br END_ISR



.equ KEY_BASE, 0xFF200050
.equ LED_BASE, 0xFF200000
.equ TIMER, 0xff202000

.text
.global  _start
_start:


    /* Set up stack pointer */
    movia sp, 0x20000
	
	movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
    movia   r11, RUN            #RUN global variable
    movia   r12, KEY_BASE        # Key base address
    movia r13, TIMER
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */
    movi r15, 1
    wrctl ctl0, r15 # enable interrupts


    #store base addresses into registers

LOOP:
    # ldw r14, (r11)
    # slli r14, r14, 1
    # ldwio r15, 0(r13)
    # add r14, r14, r15
    # stwio r14, 0(r13)
    ldwio r14, 0(r13) #read the timer
	andi r14, r14, 0b1 #extract the TO bit
    #if timer has not counted 0.25 seconds, repeat
    beq r14, r0, LOOP
    #Otherwise
    ldw r14, (r9)
	addi r14, r14, 1 #increment the counter
    stw r14, 0(r9)

    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:                # code not shown
movi r14, 0b110
stwio r14, 4(r13) #enable the counter and have it continue
movia r14, LOWBITS
stwio r14, 8(r13)
movia r14, HIGHBITS
stwio r14, 12(r13)


ret


CONFIG_KEYS:                # code not shown
movi r14, 0b1111
stwio r14, 8(r12) # enable interrupts for all pushbuttons
stwio r14, 12(r12) # reset all edge capture bits 

movi r14, 0b10
wrctl ctl3, r14 # enable pushbutton interrupts

ret
.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

HIGHBITS: .word 0x017d
LOWBITS: .word 0x7840



.end


