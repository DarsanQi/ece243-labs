/*    Subroutine to display a four-bit quantity as a hex digits (from 0 to F) 
      on one of the six HEX 7-segment displays on the DE1_SoC.
*
 *    Parameters: the low-order 4 bits of register r4 contain the digit to be displayed
		  if bit 4 of r4 is a one, then the display should be blanked
 *    		  the low order 3 bits of r5 say which HEX display number 0-5 to put the digit on
 *    Returns: r2 = bit patterm that is written to HEX display
 */

.equ HEX_BASE1, 0xff200020
.equ HEX_BASE2, 0xff200030
.equ TIMER, 0xff202000

.global  _start
_start:

movi r9, 0 #start a counter
movia r12, 500000 #limit for counter
movi r13, 17 #limit for HEX display
movi r15, 5
#enable timer
movia r10, TIMER
movi r11, 0b110
stwio r11, 4(r10)


movi r11, 0b0 #starts with HEX0
movi r14, 0b0 #starts with 0

movi r4, 16 #blank the HEX display
call HEX_DISP

hexloop:
	mov r4, r14 #move the HEX display to r4
	mov r5, r11 #move the HEX number to r5
	call HEX_DISP
#poll for timer over
	ldwio r8, 0(r10) #read the timer
	andi r8, r8, 0b1 #extract the TO bit
	beq r8, r0, hexloop
	addi r9, r9, 1 #increment the counter
	beq r9, r12, increment_display #if counter is counter limit, increment the HEX display
	br hexloop #else, keep looping

increment_display:
	movi r9, 0 #reset the counter
	addi r14, r14, 1 #increment the HEX display
	beq r14, r13, shift_display #if HEX display is 17, shift the display
	br hexloop #else, keep looping

shift_display:
	movi r14, 0b0 #reset HEX display to 0
	beq r11, r15, reset_display #if HEX display is 5, set it back to 1
	addi r11, r11, 1 #else, increment the HEX display
	br hexloop #keep looping
reset_display:
	movi r11, 0b0 #reset HEX display to 0
	br hexloop #keep looping






iloop: br iloop

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
			
BIT_CODES:  .byte     0b00111111, 0b00000110, 0b01011011, 0b01001111
			.byte     0b01100110, 0b01101101, 0b01111101, 0b00000111
			.byte     0b01111111, 0b01100111, 0b01110111, 0b01111100
			.byte     0b00111001, 0b01011110, 0b01111001, 0b01110001

            .end
			
