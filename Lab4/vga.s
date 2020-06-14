.global _start
_start:

.text
	
	.equ PIXEL_BASE, 0xC8000000
	.equ CHAR_BASE, 0xC9000000
	.equ button_base_data, 0xFF200050
	.equ button_base_interruptmask, 0xFF200058
	.equ button_base_edgecapture, 0xFF20005C
/*
Main: Poll each pushbutton my storing the address of the pushbutton data, 
and calling a subroutine which returns a 1 if the button as been pressed. 
Call the corresponding test subroutine. 
*/

MAIN: 
	MOV R0, #0x00000001
	BL PB_data_is_pressed_ASM
	CMP R0, #1	
	BLEQ TEST_BYTE

	MOV R0, #0x00000002
	BL PB_data_is_pressed_ASM
	CMP R0, #1		
	BLEQ TEST_CHAR

	MOV R0, #0x00000004
	BL PB_data_is_pressed_ASM
	CMP R0, #1	
	BLEQ TEST_PIXEL

	MOV R0, #0x00000008
	BL PB_data_is_pressed_ASM
	CMP R0, #1	
	BLEQ VGA_clear_charbuff_ASM
	CMP R0, #1 //Raise Z flag again
	BLEQ VGA_clear_pixelbuff_ASM

	B MAIN
//------------------------------------

PB_data_is_pressed_ASM: 
	PUSH {R1, LR}
  	LDR R1,=button_base_data
    LDR R1,[R1]
    AND R1,R1,R0
    CMP R1,R0
    MOVNE R0,#0
    MOVEQ R0,#1
    POP {R1, LR}
    BX LR

  
//**************************************************************
//VGA DRIVER

/*
Save the LR on the stack since these subroutines call nested subroutines. 
Iterate through all the rows (Y) and for each row, iterate through all the 
columns (X). Increment the third parameter for each position and pass these
three arguments to their respective subroutines. 
*/

TEST_CHAR: 
	PUSH {R1-r8, LR}
	MOV R1, #0		//Y
	MOV R2, #0		//C
Y_CHAR_LOOP: 
	MOV R0, #0 		//X
	CMP R1, #59
	BGT END_CHAR
X_CHAR_LOOP: 
	BL VGA_write_char_ASM
	ADD R2, R2, #1
	ADD R0, R0, #1
	CMP R0, #79
	BLE X_CHAR_LOOP
	ADD R1, R1, #1
	B Y_CHAR_LOOP
END_CHAR: 
	POP {R1-r8, LR}
	BX LR


TEST_BYTE: 
	PUSH {R0-r8, LR}
	MOV R1, #0		//Y
	MOV R2, #0		//C
Y_BYTE_LOOP: 
	MOV R0, #0 		//X
	CMP R1, #59
	BGT END_BYTE
X_BYTE_LOOP: 
	BL VGA_write_byte_ASM
	ADD R2, R2, #1
	ADD R0, R0, #3
	CMP R0, #79
	BLE X_BYTE_LOOP
	ADD R1, R1, #1
	B Y_BYTE_LOOP
END_BYTE: 
	POP {R0-r8, LR}
	BX LR

TEST_PIXEL: 
	PUSH {R0-r8, LR}
	MOV R1, #0		//Y
	MOV R2, #0		//Colour
	LDR R7, =319	//Move 320 into memory because its too big for 8 bits
Y_PIXEL_LOOP: 
	MOV R0, #0 		//X
	CMP R1, #239
	BGT END_PIXEL
X_PIXEL_LOOP: 
	BL VGA_draw_point_ASM
	ADD R2, R2, #1
	ADD R0, R0, #1
	CMP R0, R7
	BLE X_PIXEL_LOOP
	ADD R1, R1, #1
	B Y_PIXEL_LOOP
END_PIXEL: 
	POP {R0-r8, LR}
	BX LR



//------------------------------------------------
/*
Store the base address for the pixels. Compute a memory offset for each pixel
on the screen. Iterate through all the columns (x). For each iteration, interate 
through all the Y pixels, updating the offset by left shifting the counter and 
adding it to the total offset. When the last Y pixels in a column has been
reached, use a bit field clear to reset the Y part of the offset to zero, and
increment the X. For each pixel address, compute the effective address and 
store a 0. 

VGA_clear_charbuff_ASM works the same way, only with different bounds and
offsets due to different amount of left shiting and bit clearing. 
*/

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


/*
To draw a point, a value for position and colour are passed as arguments. 
The subroutine checks that the position arguments are valid. 
The base address for a pixel is loaded and an offset is calculated by 
appropriately left shifting the x and y position counts. 
The colour value is stored at that address. 
*/

//*********WORKS *********	
VGA_draw_point_ASM: 
	PUSH {R3-r8, LR}
	LDR R3, =PIXEL_BASE
	MOV R4, #0		//Address offser
	LDR R7, =319	//Move 319 into memory because its too big for 8 bits
	CMP R0, #0		//Checking that the input pixel is in bounds
	BLT DRAW_DONE
	CMP R0, R7
	BGT DRAW_DONE
	CMP R1, #0
	BLT DRAW_DONE
	CMP R1, #239
	BGT DRAW_DONE

	ADD R4, R4, R0, LSL #1
	ADD R4, R4, R1, LSL #10
	STRH R2, [R3,R4]

DRAW_DONE: 
	POP {R3-r8, LR}
	BX LR


/*
To write a character, a values for position and character are passed as arguments. 
The subroutine checks that the position arguments are valid. 
The base address for a character is loaded and an offset is calculated by 
appropriately left shifting the x and y position counts. 
The character value is stored at that address. 
*/

//*********Works*********
VGA_write_char_ASM: 
	PUSH {R0-r8, LR}
	LDR R3, =CHAR_BASE
	MOV R4, #0		//Address offset
	CMP R0, #0		//Checking that the input character location is in bounds
	BLT WRITE_DONE
	CMP R0, #79
	BGT WRITE_DONE
	CMP R1, #0
	BLT WRITE_DONE
	CMP R1, #59
	BGT WRITE_DONE

	ADD R4, R4, R0
	ADD R4, R4, R1, LSL #7
	STRB R2, [R3, R4]

WRITE_DONE: 
	POP {R0-r8, LR}
	BX LR

/*
To write a character, a values for position and character are passed as arguments. 
The subroutine checks that the position arguments are valid. 
The base address for a character is loaded and an offset is calculated by 
appropriately left shifting the x and y position counts. 

To calculate the character to write, the two bits are separated by sel;cting the appropriate bit fields
for each character. 
The character is selected from the list in consecutive memory of ascii values 0-F by adding the 
character to the base address of the list of bytes. The bytes are then stored at the effective addresses.  
*/

//*********WORKS*********	
VGA_write_byte_ASM:
	PUSH {R3-r8}
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

	LDR R7, =BYTE
	ADD R8, R7, R5
	ADD R7, R7, R6

	LDRB R7, [R7]
	STRB R7, [R3, R4]

	LDRB R8, [R8]
	ADD R4, R4, #1
	STRB R8, [R3, R4]

WRITE_BYTE_DONE: 
	POP {R3-r8}
	BX LR


	BYTE:
	.byte 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46


	.end