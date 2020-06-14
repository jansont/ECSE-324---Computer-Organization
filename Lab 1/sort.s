			.text
			.global _start

_start:
			LDR R0, =N			// R0 points to the input number of elements
			LDR R2, [R0] 		// R2 holds the number of elements in the array
			
			MOV R3, #1			// Counter for the number of elements in the loop
			MOV R12, #0			// Counter for the number of loops completed

			B SORTSTART
			
SORTSTART:	
			// "Bubble sort" algorithm
			// At each iteration, the first number in the array is identified
			// The counter is reset at every iteration start

			CMP R12, R2			// Check the number of times the loop has been completed
			BEQ END 			// Array has been sorted. The sorted array will be listed in registers.
			ADD R12, R12, #1
			MOV R4, R0
			MOV R5, R0
			ADD R4, R4, #4		// R4 points to A(i-1)
			ADD R5, R5, #8		// R5 points to A(i)
			MOV R3, #0			// Counter starts at  i = 1
			
			B ITERATION	

ITERATION:
			CMP R3, R2			// Check the value of the counter
			
			BEQ SORTSTART		// If i = N, go back to SORTSTART.
			
			ADD R3, R3, #1		// Else, increment the counter by one and start iterating
		
			LDR R6, [R4]		// R6 contains the value of A(i-1)
			LDR R7, [R5]		// R7 contains the value of A(i)

			CMP R6, R7			
			
			BGE SWAP			// If R7 is greater, swap values
		
			ADD R4, R4, #4		// Selecting the next element for the new iteration
			ADD R5, R5, #4		// Selecting the second next element for the new iteration

			B ITERATION			// Find the next values

SWAP:		MOV R11, R6			// R11 is used as temp
			MOV R6, R7			// R6 is switched with R7
			MOV R7, R11			// R7 is switched for R6
			
			STR R6, [R4]		// The new value is stored in R4
			STR R7, [R5]		// The new value is stored in R5
			
			B ITERATION

END:
			B END 				//Infinite Loop!

N:			.word 7				//number of entries in the list
ARRAY:		.word -4,5,-3,6		//the array
			.word 1,-8,2


