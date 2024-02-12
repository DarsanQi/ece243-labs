/******************************************************************************
 * Write an interrupt service routine
 *****************************************************************************/
.section .exceptions, "ax"
IRQ_HANDLER:
        # save registers on the stack (et, ra, ea, others as needed)
        subi    sp, sp, 44         # make room on the stack
        stw     et, 0(sp)
        stw     ra, 4(sp)
        stw     r20, 8(sp)
        stw     r2, 12(sp)          # save r2 for the HEX_DISP 
        stw     r4, 16(sp)          # save r4 for the HEX_DISP
        stw     r7, 20(sp)          # save r7 for the HEX_DISP
        stw     r8, 24(sp)          # save r8 for the HEX_DISP
        stw     r11, 28(sp)         # save r11 for the HEX_DISP
        stw     r5, 32(sp)          # save r5 for the HEX_DISP
        stw     r13, 36(sp) # save r13 for the HEX_DISP

        rdctl   et, ctl4            # read exception type
        beq     et, r0, SKIP_EA_DEC # not external?
        subi    ea, ea, 4           # decrement ea by 4 for external interrupts

SKIP_EA_DEC:
        stw     ea, 40(sp)
        andi    r20, et, 0x2        # check if interrupt is from pushbuttons
        beq     r20, r0, END_ISR    # if not, ignore this interrupt
        br    KEY_ISR             # if yes, call the pushbutton ISR

END_ISR:
        ldw     et, 0(sp)           # restore registers
        ldw     ra, 4(sp)
        ldw     r20, 8(sp)
        ldw    r2, 12(sp)          # restore r2 for the HEX_DISP
        ldw    r4, 16(sp)          # restore r4 for the HEX_DISP
        ldw    r7, 20(sp)          # restore r7 for the HEX_DISP
        ldw    r8, 24(sp)          # restore r8 for the HEX_DISP
        ldw    r11, 28(sp)         # restore r11 for the HEX_DISP
        ldw    r5, 32(sp) # restore r13 for the HEX_DISP
        ldw    r13, 36(sp)          # restore stack pointer
        ldw     ea, 40(sp)
        addi    sp, sp, 44         # restore stack pointer
        eret                        # return from exception

KEY_ISR:
        ldwio r13, 12(r15) # load the edge capture registers

        andi r11, r13, 0b0001 # check if KEY0 was pressed
        bne r11, r0, KEY0_PRESSED

        andi r11, r13, 0b0010 # check if KEY1 was pressed
        bne r11, r0, KEY1_PRESSED

        andi r11, r13, 0b0100 # check if KEY2 was pressed
        bne r11, r0, KEY2_PRESSED

        andi r11, r13, 0b1000 # check if KEY3 was pressed
        bne r11, r0, KEY3_PRESSED

KEY0_PRESSED:   
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b1 # check if HEX0 is on
        bne r8, r0, HEX0_ON

        movi r4, 0
        movi r5, 0
        call HEX_DISP
        movi r8, 0b1
        stwio r8, 12(r15) # reset the edge capture bit
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        addi r8, r8, 0b1 # turn on HEX0
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        br END_ISR
HEX0_ON:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b1110 # turn off HEX0
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        movi r4, 16
        movi r5, 0
        call HEX_DISP
        movi r8, 0b1
        stwio r8, 12(r15) # reset the edge capture bit
        br END_ISR


KEY1_PRESSED:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b10 # check if HEX1 is on
        bne r8, r0, HEX1_ON

        movi r4, 1
        movi r5, 1
        call HEX_DISP
        movi r8, 0b10
        stwio r8, 12(r15) # reset the edge capture bit
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        addi r8, r8, 0b10 # turn on HEX1
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        br END_ISR
HEX1_ON:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b1101 # turn off HEX1
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        movi r4, 16
        movi r5, 1
        call HEX_DISP
        movi r8, 0b10
        stwio r8, 12(r15) # reset the edge capture bit
        br END_ISR        

KEY2_PRESSED:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b100 # check if HEX2 is on
        bne r8, r0, HEX2_ON

        movi r4, 2
        movi r5, 2
        call HEX_DISP
        movi r8, 0b100
        stwio r8, 12(r15) # reset the edge capture bit
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        addi r8, r8, 0b100 # turn on HEX2
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        br END_ISR
HEX2_ON:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b1011 # turn off HEX2
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        movi r4, 16
        movi r5, 2
        call HEX_DISP
        movi r8, 0b100
        stwio r8, 12(r15) # reset the edge capture bit
        br END_ISR        

KEY3_PRESSED:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b1000 # check if HEX3 is on
        bne r8, r0, HEX3_ON

        movi r4, 3
        movi r5, 3
        call HEX_DISP
        movi r8, 0b1000
        stwio r8, 12(r15) # reset the edge capture bit
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        addi r8, r8, 0b1000 # turn on HEX3
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        br END_ISR
HEX3_ON:
        ldw r8, 0(r14) # load the one hot encoding of the HEX display
        andi r8, r8, 0b0111 # turn off HEX3
        stw r8, 0(r14) # store the one hot encoding of the HEX display
        movi r4, 16
        movi r5, 3
        call HEX_DISP
        movi r8, 0b1000
        stwio r8, 12(r15) # reset the edge capture bit
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

        #clear all the displays
        movi r4, 16
        movi r5, 0
        call HEX_DISP
        movi r4, 16
        movi r5, 1
        call HEX_DISP
        movi r4, 16
        movi r5, 2
        call HEX_DISP
        movi r4, 16
        movi r5, 3
        call HEX_DISP

        movia r14, 0x10000 # address to store one hot encoding of the HEX display
        movi r8, 0b0000 
        stw r8, 0(r14) # reset the one hot encoding

        movia sp, 0x20000 #set the stack pointer
        movi r8, 0b1111
        stwio r8, 8(r15) # enable interrupts for all pushbuttons
        stwio r8, 12(r15) # reset all edge capture bits        
        movi r8, 1
        wrctl ctl0, r8 # enable interrupts
        movi r8, 0b10
        wrctl ctl3, r8 # enable pushbutton interrupts

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
			