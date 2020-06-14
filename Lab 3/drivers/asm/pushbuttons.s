		.text
		.global read_PB_data_ASM
        .global PB_data_is_pressed_ASM

        .global read_PB_edgecap_ASM
        .global PB_edgecap_is_pressed_ASM
        .global PB_clear_edgecap_ASM

        .global enable_PB_INT_ASM
        .global disable_PB_INT_ASM

        .equ button_base_data, 0xFF200050
        .equ button_base_interruptmask, 0xFF200058
        .equ button_base_edgecapture, 0xFF20005C

read_PB_data_ASM: 
    LDR R0,=button_base_data
    LDR R0,[R0]
    BX LR  
PB_data_is_pressed_ASM: PUSH {R1}
  	LDR R1,=button_base_data
    LDR R1,[R1]
    AND R1,R1,R0
    CMP R1,R0
    MOVNE R0,#0
    MOVEQ R0,#1
    POP {R1}
    BX LR
read_PB_edgecap_ASM:
    LDR R0,=button_base_edgecapture
    LDR R0,[R0]
    BX LR
PB_edgecap_is_pressed_ASM:  
    PUSH {R1}
    LDR R1,=button_base_edgecapture
    LDR R1,[R1]
    AND R1, R1,#0xF 
    CMP R1,R0
    MOVNE R0,#0
    MOVEQ R0,#1
    POP {R1}
    BX LR
PB_clear_edgecap_ASM:  
    PUSH {R1,R2}
    LDR R1,= button_base_edgecapture
    MOV R2,#1
    STR R2,[R1]
    POP {R1,R2}
    BX LR
enable_PB_INT_ASM: 
    POUSH {R1}
    LDR R1, =button_base_interruptmask
    AND R0, R0, #0xF
    STR R0,[R1]
    POP {R1}
    BX LR
disable_PB_INT_ASM: 
    LDR R0, =button_base_interruptmask
    LDR R0,[R0]
                    

