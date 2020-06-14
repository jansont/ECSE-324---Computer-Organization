			.text
			.global _start

_start:
			LDR R4, =RESULT		//R4 points to the results location
			LDR R2,[R4, #4] 	// =R2 holds the number of elements in the list
			ADD R3, R4, #8 		//R3 points to the first number
			LDR R0, [R3]		//R0 holds the first number in the list
			PUSH {R2,R3}	//Store the values of registers before the subroutine call
			BL LOOP
			

LOOP: 		SUBS R2, R2, #1		//decrement the loop counter
			BEQ DONE 			//end loop if the counter has reached 0
			ADD R3, R3, #4		//R3 points to the next number in the list
			LDR R1, [R3]		//R1 holds the next number in the list
			CMP R0, R1			//check if its greater than the maximum
			BGE LOOP			//If no, branch back to the loop
			MOV R0, R1			//IF yes, update the current max
			BX LR				//Branch back to the loop

DONE: 		STR R0, [R4]		//Store the result to the memory location

	 		POP {R2, R3}		//Return the processor to its state before subroutine call
END:		B END 				//Infinite Loop!


RESULT:		.word 0				//memory assigned for the result location
N:			.word 7				//number of entries in the list
NUMBERS:	.word 4,5,3,6		//the list data
			.word 1,8,2

