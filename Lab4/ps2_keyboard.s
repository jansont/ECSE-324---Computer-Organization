.global _start
_start:

.text
.equ Keyboard_Data, 0xFF200100
.equ CHAR_BASE, 0xC9000000
.equ PIXEL_BASE, 0xC8000000

MOV R0, #0 	//x
MOV R1, #0	//y
LDR R4, =79 //max x
LDR R5, = 59 //max y

BL VGA_clear_pixelbuff_ASM
BL VGA_clear_charbuff_ASM



/* Save the value of x into another register. Load the address for a byte and pass it to Ps2_data, which
returns a 1 if a character has been written on the keyboard. If theres a 1, load the byte at the address
passed and write the it to the vga and increment 
appropriately – x by 3, y by 1 if x has reached max, reset x, and reset y, clearing the screen. If not 
valid. Skip all this. 
*/


WHILE: 
MOV R7, R0 		//Save the x 
LDR R0, =CHAR
BL read_PS2_data_ASM 	//Pass this address and return valid/invalid
CMP R0, #1				//Check validity
MOV R0, R7		//Return R0 to x
BNE WHILE_DONE
LDRB R2, CHAR	//Load R2 with the character stored at the adress in R0
BL VGA_write_byte_ASM //Call while passing x, y, and character
ADD R0, R0, #3 		//increment column
CMP R0, R4		//compare x to the max
BLGT INCREMENT
WHILE_DONE: 
B WHILE

INCREMENT: 
PUSH {LR}
MOV R0, #0	//reset x
ADD R1, R1, #1	//increment y
CMP R1, R5	//compare y to y max
MOVGT R1, #0	//Reset y
BLGT VGA_clear_charbuff_ASM //Clear if weve written everywhere
POP {LR}
BX LR


/* Pass a reserved address into memory, test the valid bit, if valid, isolate the bits corresponding
to the data and store the byte at the address 1. Return a 1 to indicate that a byte was inputed. 
*/

read_PS2_data_ASM: 
	PUSH {R1-R8}
	LDR R1, =Keyboard_Data
	LDR R2, [R1]
	TST R2, #0x8000 	//Test the RValid (15) bit with bitwise AND
	BEQ	Invalid
	AND R2, R2, #0xFF 	//Get first 8 bits
	STRB R2, [R0]
	MOV R0, #1
	POP {R1-R8}
	BX LR

Invalid:
	MOV R0, #0
	POP {R1-R8}
	BX LR
CHAR: 
.space 4


//*********WORKS *********		
VGA_write_byte_ASM:
	PUSH {R0-r8}
	MOV R4, #0		//Address offset
	CMP R0, #0		//Checking that the input character location is in bounds
	BLT WRITE_BYTE_DONE
	CMP R0, #79
	BGT WRITE_BYTE_DONE
	CMP R1, #0
	BLT WRITE_BYTE_DONE
	CMP R1, #59
	BGT WRITE_BYTE_DONE

	LDR R3, =CHAR_BASE
	UBFX R5, R2, #0, #4		//Select the first character
	UBFX R6, R2, #4, #4		//Select the second character

	ADD R4, R4, R0 			
	ADD R4, R4, R1, LSL #7	//Offset

	LDR R7, =BYTES
	ADD R8, R7, R5
	ADD R7, R7, R6

	LDRB R7, [R7]
	STRB R7, [R3, R4]

	LDRB R8, [R8]
	ADD R4, R4, #1
	STRB R8, [R3, R4]

WRITE_BYTE_DONE: 
	POP {R0-r8}
	BX LR
	
	
BYTES:
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46



//*********WORKS *********	
VGA_clear_pixelbuff_ASM:
	PUSH {R0-r8, LR}
	MOV R0, #0	//0 for clearing
	LDR R1, =PIXEL_BASE
	MOV R2, #0 	//Counter for x
	MOV R3, #0 	//Counter for y
	MOV R4, #0	//Total offset
	MOV R6, #0	
	LDR R7, =320	//Move 320 into memory because its too big for 8 bits
	CLEAR_PIXEL_X: 
	
	BFC R5, #10,#8 			//Clear the Y offset bits (can alternatively do SUB R4, R4, R3, LSL #7 or a XOR R3+0000
	MOV R3, #0				//Reset row (y) counter
	ADD R6, R4, R2, LSL #1	//Incrememt the offset for x
	ADD R2, R2, #1			//Increment the x counter
	CMP R2, R7				//Compare to 320
	BGT PIXEL_DONE
	
	CLEAR_PIXEL_Y: 
	ADD R5, R6, R3, LSL #10		//Add the y-counter to the offset
	STRH R0, [R1, R5]			//Store a 0 at base address + offset
	ADD R3, R3, #1				//Increment the Y-counter
	CMP R3, #239
	BGT CLEAR_PIXEL_X			//Clear the next column
	B CLEAR_PIXEL_Y				//Otherwise loop through Y


	PIXEL_DONE: 
	POP {R0-r8, LR}
	BX LR

	//*********WORKS *********		
VGA_clear_charbuff_ASM:
	PUSH {R0-R8}
	MOV R0, #0	//0 for clearing
	LDR R1, = CHAR_BASE
	MOV R2, #0 	//Counter for x
	MOV R3, #0 	//Counter for y
	MOV R4, #0	//Total offset
	MOV R6, #0	

CLEAR_CHAR_X: 
	BFC R4, #7,#6 		//Clear the Y offset bits (can alternatively do SUB R4, R4, R3, LSL #7 or a XOR R3+0000
	MOV R3, #0			//Reset row (y) counter
	ADD R6, R4, R2, LSL #1	//Incrememt the offset for x
	ADD R2, R2, #1		//Increment the x counter
	CMP R2, #79
	BGT CHAR_DONE
	
CLEAR_CHAR_Y: 
	ADD R5, R6, R3, LSL #7		//Add the y-counter to the offset
	STRH R0, [R1, R5]			//Store a 0 at base address + offset
	ADD R3, R3, #1				//Increment the Y-counter
	CMP R3, #59
	BGT CLEAR_CHAR_X			//Clear the next column
	B CLEAR_CHAR_Y				//Otherwise loop through Y


CHAR_DONE: 
	POP {R0-R8}
	BX LR

	
	