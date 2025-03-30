    .data
vector1:
    .word   -1,-2,-3,-4,-5
res:
    .word   0
str:
.asciz "La suma de los elementos del vector es: %d\n"
    .text
    .global main
main:
    la      a0, vector1    # Load address of vector into a0
    li      a1, 5          # Load size of vector into a1
    li      a2, 0          # Initialize sum to 0
1:
    beqz    a1, 2f         # If size is 0, go to print
    lw      t0, 0(a0)      # Load current element into t0
    add     a2, a2, t0     # Add current element to sum
    addi    a0, a0, 4      # Move to next element
    addi    a1, a1, -1     # Decrease size by 1
    j       1b             # Repeat loop

2:
    sw      a2, res, a0    # Store the sum in res
    la      a0, str        # Load address of string into a0
    lw      a1, res        # Load sum from res into a1
    jal     dac_printf     # Call the print function

en:
    j       en             # Infinite loop to prevent returning from main
