			.text
			.global _start

_start:
			LDR R4, =RESULT		//R4 points to the results location
			LDR R2,[R4, #4] 	// =R2 holds the number of elements in the list
			ADD R3, R4, #8 		//R3 points to the first number
			LDR R0, [R3]		//R0 holds the first number in the list
			LDR R5, [R3]		//R5 holds the minimum value in the list
			LDR R6, [R3]		//R6 holds the maximum value in the list

LOOP:		SUBS R2, R2, #1		//decrement the loop counter
			BEQ DONE 			//end loop if the counter has reached 0
			ADD R3, R3, #4		//R3 points to the next number in the list
			LDR R1, [R3]		//R1 holds the next number in the list
			CMP R0, R1			//check if its greater than the maximum
			BGE MIN				//If no, check if it is a minimum
			BLE MAX				//If yes, check if it is a maximum
			B LOOP				//Branch back to the loop

MAX: 		CMP R6, R1			//check if the new number is greater than the value stored
			BGE LOOP			//if no, go back to the maximum value loop
			MOV R6, R1			//if yes, store the new maximum value
			B LOOP				//return to the loop

MIN: 		CMP R5, R1			//check if the new number is less than the value stored
			BLE LOOP			//if no, go back to the maximum value loop
			MOV R5, R1			//if yes, store the new minimum value
			B LOOP				//return to the loop

DONE: 		SUB R7, R6, R5
			ASR R7, R7, #2
			STR R7, [R4]		//Store the result to the memory

END: 		B END 				//Infinite Loop!


RESULT:		.word 0				//memory assigned for the result location
N:			.word 7				//number of entries in the list
NUMBERS:	.word 4,5,-3,6		//the list data
			.word 1,-8,2
