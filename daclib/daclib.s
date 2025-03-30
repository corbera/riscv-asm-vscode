# Use a datasheet for a 16550 UART (www.ti.com/lit/ds/symlink/tl16c550d.pdf)

    .equ   UART0_BASE, 0x10000000          # Base address of UART0
    .equ   UART0_DR, 0x00                  # Data Register
    .equ   UART0_FCR, 0x02                 # FIFO Control Register
    .equ   UART0_LSR, 0x05                 # Line Status Register
    .equ   UARTFCR_FFENA, 0x01             # UART FIFO Control Register enable bit
    .equ   UARTLSR_THRE, 0x20              # UART Line Status Register Transmit Hold Register Empty bit

    .globl uart_init, uart_putc, uart_puts

    .text
uart_init:
    li     a0, UART0_BASE                  # Load base address of UART0
    li     a1, UARTFCR_FFENA               # Load FIFO enable value
    sb     a1, UART0_FCR(a0)               # Enable FIFO
    ret

uart_putc:
    li     t0, UART0_BASE                  # Load base address of UART0
1:
    lb     t1, UART0_LSR(t0)               # Read Line Status Register
    andi   t1, t1, UARTLSR_THRE            # Check if THR is empty
    beqz   t1, 1b                          # Wait until THR is empty
    sb     a0, UART0_DR(t0)                # Write character to Data Register
    ret

uart_puts:
    addi   sp, sp, -16                     # Allocate stack space
    sw     ra, 0(sp)                       # Save return address
    sw     s1, 4(sp)                       # Save s1 register

    mv     s1, a0                          # Move string pointer to s1
1:
    lb     a0, 0(s1)                       # Load character from string
    beqz   a0, 2f                          # If null terminator, end of string
    jal    uart_putc                       # Call uart_putc to send character
    addi   s1, s1, 1                       # Move to next character
    j      1b                              # Repeat for next character
2:
    lw     ra, 0(sp)                       # Restore return address
    lw     s1, 4(sp)                       # Restore s1 register
    addi   sp, sp, 16                      # Deallocate stack space
    ret                                    
