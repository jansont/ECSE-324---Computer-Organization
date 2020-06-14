.text
		.equ HEX1, 0xFF200020
		.equ HEX2, 0xFF200030
		.global HEX_clear_ASM
		.global HEX_flood_ASM
		.global HEX_write_ASM

HEX_clear_ASM:
	PUSH {R1-R11, LR}	//save register contents on the stack
	LDR R1, =HEX1		//R1 contains the memory location of hex displays 0-3
	LDR R2, =HEX2		//R2 contains the memory location of hex displays 4-5
	MOV R3, #1			//HEX count in 1 hot encoding (decimal)
	MOV R4, #0			//Counter to loop from 0 to 5
	MOV R5, #0			

CLEAR_HEX_LOOP: 
	CMP R4, #5			//Comparing counter to 5
	BGT CLEAR_DONE		//If greater than 5, we've cleared all hexes
	TST R0, R3			//Bitwise AND of Current HEX and hex number?
	BLNE CLEAR_HEX 		//If they're not equal, we need to clear
	ADD R4, R4, #1		//Once cleared or no, increment counter
	LSL R3, R3, #1		//Also shift hex number to the left (multiply decimal by 2
	B CLEAR_HEX_LOOP	//Loop

CLEAR_HEX: 		
	CMP R4, #3			//Check if we need to store value of 0 in register for 0-3 or 4-5
	STRLE R5, [R1]	//Store in 0-3 register if less than or equal to 3
	STRGT R5, [R2]	//Store 0, contained in R5 at these two addresses
	BX LR 				

CLEAR_DONE:				//Once finished looping through all 5 hex, finish
	POP {R1-R11, LR}
	BX LR

HEX_flood_ASM:
	PUSH {R1-R8, LR}	//Save contents of registers onto stack
	LDR R1, =HEX1		//R1 contains address for hex 0-3
	LDR R2, =HEX2		//R1 contains address for hex 4-5
	MOV R3, #0			//Initializing value for flooding
	MOV	R4, #0			//Initializing value for flooding
	MOV R5, #0			//counter from 0 to 5
	MOV R6, #1			//HEX number in one hot encoding
	MOV R7, #0x0000007F	//Load with value of 0x7f = 0b1111111 = 8 for flooding
			
HEXLOOP:
	CMP R5, #5			//Check counter 
	BGT FLOOD_DONE		//Exit to done if looped through all 5 hex displays
	TST R0, R6			//Bitwise AND between current hex and hex value ??
	BLNE FLOOD_HEX		//If theyre not equal, call flooding subroutine
	ADD R5, R5, #1		//Increment counter
	LSL R6, R6, #1		//shift hex number to the left (multiply decimal by 2)
	LSL R7, R7, #8		//Shift flooding value by 8 bits to shift hex by 2
	B HEXLOOP

FLOOD_HEX:
	CMP R5, #3			//Compare counter to 3
	BLE FLOOD_HEX_03	//Flood hex 0-3 if less than or equal to 3
	CMP R5, #4
	BEQ FLOOD_HEX_4		//Otherwise flood 4
	CMP R5, #5
	BEQ FLOOD_HEX_5		//Otherwise flood 5

FLOOD_HEX_03:
	ADD R3, R3, R7		//Adding the value of R7 to R3 to flood the hexes
	STR R3, [R1]		//Store the flood value in the register for Hex 0-3
	BX LR

FLOOD_HEX_4:			//Do the same for registers 4-5
	ADD R4, R4, #0x0000007F
	STR R4, [R2]
	BX LR

FLOOD_HEX_5:			//Do the same for registers 4-5
	ADD R4, R4, #0x00007F00
	STR R4, [R2]
	BX LR

FLOOD_DONE:		
POP {R1-R8, LR}
BX LR

HEX_write_ASM: 			//Initializing the write routine
	PUSH {R2-R8, LR}	//Save register contents on the stack
	LDR R2, =HEX1		//Load R2 and R3 with the addresses of Hex 0-3 and Hex 4-5
	LDR R3, =HEX2
	PUSH {R1-R8,LR}		//Clear the hexes before writing anything on them
	BL HEX_clear_ASM 
	POP {R1-R8,LR}
	MOV R4, #1			//One hot encoding counter for the hex displays
	MOV R5, #0			//Counter for looping through all hex displays

CHECK_HEX: 
	CMP R5, #5			//Have we looped thruogh all displays
	BGT DONE			//If so, exit
	CMP R0, R4			//Compare R0 to the decimal 1HE in R6
	PUSH {R6-R11, LR}	//Call the write subroutine, save register contents first (delete)
	BLEQ WRITE
	POP {R6-R11, LR}
	LSL R4, R4, #1		//Multiply the hex number by 2 in decimal
	ADD R5, R5, #1		//Incremnent the counter
	B CHECK_HEX

WRITE:
	LDR R9, =WRITE_ARRAY	//Load R9 with the address of number to be displayed 
	MOV R10, #0	 //Counter through 15

WRITE_LOOP:
	CMP R10, #15		//Have we looped through all possible numbers to be displayed
	BGT STORE			//If so, store the value in the Hex adress 
	LDR R11, [R9], #4	//Load R11 with the value to be loaded, then increment the memory adress to point ot the next value
	CMP R1, R10			//Compare R1 to the current value in the counter
	MOVEQ R6, R11		//If theyre equal, move the number to be displayed into R6 for future storing
	ADD R10, R10, #1	//Increment the counter
	B WRITE_LOOP

STORE:		//Implement without subroutine calls?
	CMP R5, #3			//Compare the 0-5 counter to 3
	BLE STORE_0_3		//Branch to store hex 0-3 if less than or equal
	CMP R5, #4			//Compare to 4
	BEQ STORE_4		//Branch to store hex 4
	CMP R5, #5			//Compare to 5
	BEQ STORE_5		//Branch to store hex 5

STORE_0_3:
	STRB R6, [R2, R5]	//Store number in adress contained in R2, offset by R5
	BX LR

STORE_4:
	STRB R6, [R3]
	BX LR

STORE_5:
	STRB R6, [R3, #1]
	BX LR

DONE: 
	POP {R2-R8, LR}
	BX LR

WRITE_ARRAY: .word 0x0000003F, 0x00000006, 0x0000005B, 0x0000004F, 0x000000066, 0x00000006D, 0x0000007D, 0x00000007, 0x0000007F, 0x00000067, 0x000000077, 0x00000007C, 0x000000039, 0x00000005E, 0x000000079, 0x000000071


