# Simple C runtime startup bootstrap
# Primary functions:
# - Stack allocation and initializing stack pointer
# - UART initialization
# - Jumping to main
    .section .text._start
    .global  _start
_start:
    la       sp, __stack_top # Load the stack pointer
    add      s0, sp, zero    # Set the frame pointer
    jal      uart_init       # Initialize UART
    jal      main            # Run main entry point - no argc
end:
    j        end             # Spin forever in case main returns

    .section .data
    .space   1024*8          # allocate 8K of memory to serve as initial stack
    .align   16              # Smallest stack allocation is 16 bytes, so align accordingly
__stack_top: # The stack grows downward according the Risc-V ABI
