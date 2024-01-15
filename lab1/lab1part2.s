.global _start
_start:
		movi r8,2 /* r8 <- 2 */
		movi r9,3 /* r9 <- 3 */
		add r10, r8, r9 /* r10 <- r8 + r9 */
	done: br done /* infinite loop */