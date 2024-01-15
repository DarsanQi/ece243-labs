.global _start
_start:
movi r8,0 /* r8 <- 1 */
movi r9,29 /* r9 <- 30 */
movi r12, 0 /* r9 <- 0 */
myloop: addi r8, r8, 1 /* r10 <- r8 + r9 */
		add r12, r8, r12
		ble r8, r9, myloop
		
done: br done /* infinite loop */