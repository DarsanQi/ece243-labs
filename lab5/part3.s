

.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 20          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
        stw     r9, 12(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 16(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 16(sp)
        addi    sp, sp, 20          # restore stack pointer
        eret                        # return from exception

KEY_ISR:
        stwio r13, 12(r15)        # store the edge capture registers

        andi r11, r13, 0b0001 # check if KEY0 was pressed
        bne r11, r0, KEY0_PRESSED

        andi r11, r13, 0b0010 # check if KEY1 was pressed
        bne r11, r0, KEY1_PRESSED

        andi r11, r13, 0b0100 # check if KEY2 was pressed
        bne r11, r0, KEY2_PRESSED

        andi r11, r13, 0b1000 # check if KEY3 was pressed
        bne r11, r0, KEY3_PRESSED

KEY0_PRESSED:
        br ADJUST_TIMER

KEY1_PRESSED:   
        br ADJUST_TIMER

KEY2_PRESSED:  
        br ADJUST_TIMER

KEY3_PRESSED:
        br ADJUST_TIMER                         # code not shown

ADJUST_TIMER:
    beq r9, r0, CONTINUE_TIMER
    bne r9, r0, PAUSE_TIMER

CONTINUE_TIMER:
    movi r9, 1
    br END_ISR

PAUSE_TIMER:
    movi r9, 0
    br END_ISR



.text
.global  _start
_start:
    /* Set up stack pointer */
    movia sp, 0x20000
    call    CONFIG_TIMER        # configure the Timer
    call    CONFIG_KEYS         # configure the KEYs port
    /* Enable interrupts in the NIOS-II processor */

    ldwio r13, 0(r14) #read the timer
	andi r13, r13, 0b1 #extract the TO bit
	addi r9, r9, 1 #increment the counter




    movia   r8, LED_BASE        # LEDR base address (0xFF200000)
    movia   r9, COUNT           # global variable
    movia   r11, RUN            #RUN global variable
LOOP:
    ldw     r10, 0(r9)          # global variable
    stwio   r10, 0(r8)          # write to the LEDR lights
    br      LOOP

CONFIG_TIMER:       ...         # code not shown
movi r12, 0 #start a counter
movia r13, 2 #limit for counter
movia r14, TIMER
movi r15, 0b110
stwio r14, 4(r15) #enable the counter and have it continue


CONFIG_KEYS:        ...         # code not shown


.data
/* Global variables */
.global  COUNT
COUNT:  .word    0x0            # used by timer

.global  RUN                    # used by pushbutton KEYs
RUN:    .word    0x1            # initial value to increment COUNT

.end



.equ LEDs, 0xFF200000
.equ TIMER, 0xff202000