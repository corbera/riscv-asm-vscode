.data 
vector2: .word 1,2,3,4,5
str: .asciz "Hello, World!\n"

.text
.global main
main:
    la a0, str # Load address of string into a0
    jal uart_puts # Call the print function

    la a0, vector2 # Load address of vector into a0
    lw a1, 0(a0)  # Load first element of vector into a1
    lw a2, 4(a0)  # Load second element of vector into a2
    add a3, a1, a2 # Add the two elements and store in a3



en: j en # Infinite loop to prevent returning from main
