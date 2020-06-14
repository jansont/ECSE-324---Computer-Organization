.text
			.global _start


_start:		
			LDR R0, =RESULT		
			LDR R1, [R0, #4]	
			ADD R3,	R1, #8		//Pointing to first element		

BPUSH:		
			SUBS R1, R1, #1			
			BLT BPOP		
			LDR R2, [R3] 		
			
			ADD R3, R3, #4
			SUBS SP, SP, #4		
			STR R0, [SP]		
			
			ADD R0, R0, #4
			
			B BPUSH

BPOP:		
			LDR R0, [SP]		
			ADD SP, SP, #4		
			
 			LDR R1, [SP]		
			ADD SP, SP, #4		
			
			LDR R2, [SP]		

END:		
			B END 				//infinite loop!

RESULT:		.word 	0			
N:		 	.word	4			//Number of elements
NUMBERS:	.word	1, 2, 3, 4	//Numbers list