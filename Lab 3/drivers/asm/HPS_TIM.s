	.text
	.equ   HPS_TIM0_BASE, 0xFFC08000
	.equ   HPS_TIM1_BASE, 0xFFC09000
	.equ   HPS_TIM2_BASE, 0xFFD00000
	.equ   HPS_TIM3_BASE, 0xFFD01000
	
	.global HPS_TIM_config_ASM
	.global HPS_TIM_clear_INT_ASM
	.global HPS_TIM_read_INT_ASM

HPS_TIM_config_ASM:
		PUSH {R4-R7, LR}
		MOV R1, #0
		MOV R2, #1
		LDR R7, [R0]
		B LOOP

LOOP:
		TST R7, R2, LSL R1
		BEQ CONTINUE
		BL CONFIG

CONTINUE:
		ADD R1, R1, #1
		CMP R1, #4
		BLT LOOP

DONE:
		POP {R4-R7, LR}
		BX LR

CONFIG:
		PUSH {LR}
	
		LDR R3, =HPS_TIM_BASE
		LDR R4, [R3, R1, LSL #2]
	
		BL DISABLE
		BL SET_LOAD_VAL
		BL SET_LOAD_BIT
		BL SET_INT_BIT
		BL SET_EN_BIT
	
		POP {LR}
		BX LR 

DISABLE:
		LDR R5, [R4, #0x8]
		AND R5, R5, #0xFFFFFFFE
		STR R5, [R4, #0x8]
		BX LR
	
SET_LOAD_VAL:
		LDR R5, [R0, #0x4]
		MOV R6, #25
		MUL R5, R5, R6
		CMP R1, #2
		LSLLT R5, R5, #2
		STR R5, [R4]
		BX LR
	
SET_LOAD_BIT:
		LDR R5, [R4, #0x8]
		LDR R6, [R0, #0x8]
		AND R5, R5, #0xFFFFFFFD
		ORR R5, R5, R6, LSL #1
		STR R5, [R4, #0x8]
		BX LR
	
SET_INT_BIT:
		LDR R5, [R4, #0x8]
		LDR R6, [R0, #0xC]
		EOR R6, R6, #0x00000001
		AND R5, R5, #0xFFFFFFFB
		ORR R5, R5, R6, LSL #2
		STR R5, [R4, #0x8]
		BX LR
	
SET_EN_BIT:
		LDR R5, [R4, #0x8]
		LDR R6, [R0, #0x10]
		AND R5, R5, #0xFFFFFFFE
		ORR R5, R5, R6
		STR R5, [R4, #0x8]
		BX LR


// Clearing timer to zero
HPS_TIM_clear_INT_ASM:
			PUSH {R1-R5}
			AND R0, R0, #0xF			
			MOV R1, #0					
			
clear_loop:
			CMP R1, #4					
			BGE clear_done	
			
			AND R3, R0, #1
			ASR R0, R0, #1		

			CMP R3, #0					
			ADDEQ R1, R1, #1			
			BEQ clear_loop	

clear_select_timer:
			CMP R1, #0
			LDREQ R5, =HPS_TIM0_BASE
			CMP R1, #1
			LDREQ R5, =HPS_TIM1_BASE
			CMP R1, #2
			LDREQ R5, =HPS_TIM2_BASE
			CMP R1, #3
			LDREQ R5, =HPS_TIM3_BASE

			LDR R3, [R5, #0xC]			

			ADD R1, R1, #1				
			B clear_loop

clear_done:
			POP {R1-R5}
			BX LR			


// Reading s-bit timer status
HPS_TIM_read_INT_ASM:
			PUSH {R1-R5}
			AND R0, R0, #0xF			
			MOV R1, #0					
			
read_loop:							
			CMP R1, #4					
			BGE read_done	

			AND R3, R0, #1           
			ASR R0, R0, #1				

			CMP R3, #0 
			ADDEQ R1, R1, #1			
			BEQ read_loop	        
read_select_timer:
			CMP R1, #0
			LDREQ R5, =HPS_TIM0_BASE
			CMP R1, #1
			LDREQ R5, =HPS_TIM1_BASE
			CMP R1, #2
			LDREQ R5, =HPS_TIM2_BASE
			CMP R1, #3
			LDREQ R5, =HPS_TIM3_BASE

read_interrupt_status:
			LDR R2, [R5, #0x10]			
			AND R0, R2, #1				
			B read_done 

read_done:
			POP {R1-R5}
			BX LR
	
HPS_TIM_BASE:
	.word 0xFFC08000, 0xFFC09000, 0xFFD00000, 0xFFD01000

	.end