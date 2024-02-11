/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 16          # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 12(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        call    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw     ea, 12(sp)
        addi    sp, sp, 16          # restore stack pointer
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
        movi r4, 0
        movi r5, 0
        call HEX_DISP
        br END_ISR

KEY1_PRESSED:
        movi r4, 1
        movi r5, 1
        call HEX_DISP
        br END_ISR

KEY2_PRESSED:
        movi r4, 2
        movi r5, 2
        call HEX_DISP
        br END_ISR

KEY3_PRESSED:
        movi r4, 3
        movi r5, 3
        call HEX_DISP
        br END_ISR

/*********************************************************************************
 * set where to go upon reset
 ********************************************************************************/
.section .reset, "ax"
        movia   r8, _start
        jmp    r8

/*********************************************************************************
 * Main program
 ********************************************************************************/
.text
.global  _start
_start:
        movia r15, KEY_BASE
        /*
        1. Initialize the stack pointer
        2. set up keys to generate interrupts
        3. enable interrupts in NIOS II
        */
        movia sp, 0x20000
        movi r8, 1
        wrctl ctl0, r8 # enable interrupts
        movi r8, 0b10
        wrctl ctl3, r8 # enable pushbutton interrupts
        movi r8, 0b1111
        stwio r8, 8(r15) # enable interrupts for all pushbuttons
        stwio r8, 12(r15) # reset all edge capture bits

IDLE:   br  IDLE

HEX_DISP:   movia    r8, BIT_CODES         # starting address of the bit codes
	    andi     r6, r4, 0x10	   # get bit 4 of the input into r6
	    beq      r6, r0, not_blank 
	    mov      r2, r0
	    br       DO_DISP
not_blank:  andi     r4, r4, 0x0f	   # r4 is only 4-bit
            add      r4, r4, r8            # add the offset to the bit codes
            ldb      r2, 0(r4)             # index into the bit codes

#Display it on the target HEX display
DO_DISP:    
        movia    r8, HEX_BASE1         # load address
        movi     r6,  4
        blt      r5,r6, FIRST_SET      # hex4 and hex 5 are on 0xff200030
        sub      r5, r5, r6            # if hex4 or hex5, we need to adjust the shift
        addi     r8, r8, 0x0010        # we also need to adjust the address
FIRST_SET:
        slli     r5, r5, 3             # hex*8 shift is needed
        addi     r7, r0, 0xff          # create bit mask so other values are not corrupted
        sll      r7, r7, r5 
        addi     r4, r0, -1
        xor      r7, r7, r4  
        sll      r4, r2, r5            # shift the hex code we want to write
        ldwio    r5, 0(r8)             # read current value       
        and      r5, r5, r7            # and it with the mask to clear the target hex
        or       r5, r5, r4	           # or with the hex code
        stwio    r5, 0(r8)		       # store back
END:			
        ret



.equ    KEY_BASE, 0xFF200050
.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030

        
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
        .byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
        .byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
        .byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

.end
			