		.text
		.global _start
_start:
		LDR		R4, =RESULT		//R4 contains pointer to the result
		LDR 	R5, =N			//R5 contains pointer to the number
		LDR 	R0, [R5]		//Store the fibonacci number in R0. Represents the current node of the call tree
		MOV		R3, #0			//Initialize the counter to count the number of base cases reached = fib(n)
		BL		FIB				//Branch to fibonacci subroutine
		MOV		R0, R3
		STR		R0, [R4]
END:	B		END
		
FIB:
		PUSH {R1, R2,LR}		//Push the contents of registers R1, R2, LR onto the stack. R1 and R2 contain no useful information at start. LR used to move up the call tree. 
		MOV		R1, R0			//R0 copied into R1 and R2 so that they are later decremented by 1 or 2 to go to left or right child in call tree
		MOV		R2, R0
		CMP		R0, #2			//Compare R0 to 2
		ADDLE	R3, R3, #1		//If R0<=2, then the next subroutine call will result in a base case being reached. So, we've reached a leaf node and increment the count.
		BLE		DONE			//Branch to done
		SUB		R1, R1, #1		//Go to the left child by decrementing the fibonacci number by 1
		MOV		R0, R1			//Copy left child into current node register so that the left child is the node being evaluated 
		BL		FIB				//Keep moving down the call tree
		SUB		R2, R2, #2		//Go to the right child by decrementing the fibonacci number by 1
		MOV		R0, R2			//Copy right child into current node register so that the left child is the node being evaluated 
		BL		FIB				//Keep moving down the call tree
		
DONE:
		POP {R1, R2,PC}			//Move back up the tree to evalute the next node. By popping R1, R2, LR, we return the processor back to the state in was in 
								//Earlier in the call tree

RESULT:		.word 0		//Reserve memory for the result
N: 			.word 6		//Reserve memory for the number

