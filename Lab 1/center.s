			.text
		    .global _start
	
_start:	
			MOV R0, #0 		//Sum is initialized to null in R0 
			LDR R1, =N		//R1 contains address of list
			LDR	R2, [R1]		//R2 contains the size of list
			ADD	R3, R1, #4		//R3 contains a pointer to the first element 
					
			MOV	R4, R2		//R4 contains the down-counter for this loop
SUMLOOP: 
			CMP	R4, #0 		//Compare counter to 0
			BLE	DONE			//Exit the loop when R4 <= 0
			LDR	R5, [R3]		//Load the first element
			ADD	R0, R0, R5		//Add the value of the array element to the sum
			ADD	R3, R3, #4		//Update the pointer to point to the next element
			SUB	R4, R4, #1		//Decrement the counter
			B 	SUMLOOP			//Loop back

DONE: 		MOV	R4, R2		//R4 contains the next counter
			MOV	R6, #0 		//R6 contains the number of shifts (initialize)
			MOV	R7, R2		//Copy the array size into R7
SHIFT: 
			CMP	R7, #1		//Compare the counter with 0
			BLE	DIVIDE		//Exit the loop when R4<=0
			LSR	R7, R7, #1		//Shift to the right by 1 for each loop pass. 
			ADD	R6, R6, #1 	//Count the number of shifts
			B 	SHIFT			//Loop back
DIVIDE: 	
			MOV	R11, R0		//Copy sum for testing purposes
			ASR	R0, R0, R6		//Arithmetic shift right to maintain leading bit. ow contains the average
			MOV	R7, R2		//Recopy the array size into R7
			ADD	R8, R1, #4		//Update pointer to the first element in the list	
			MOV	R4, R2		//R4 will act as counter
CENTER: 
			CMP	R4, #0		//Compare the counter with 0
			BLE	END			//Exit loop if R4 <= 0
			LDR R9, [R8]
			SUB	R9, R9, R0		//Subtract the average from the element 
			STR R9, [R8]
			ADD	R8, R8, #4		//Update the pointer to point to the next element
			SUB	R4, R4, #1		//Decrement the counter
			B	CENTER			//Loop Back
END:
			B 	END
			

RESULT:		.word	0		
N:			.word	8		
NUMBERS:	.word 	-1,-2,-3,-4	
			.word	-5,-6,-7,-8
