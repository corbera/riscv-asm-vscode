// Librería de funciones básicas para programar en ensamblador RISC-V en QEMU
// Autor: Francisco Corbera
// Fecha: Marzo 2025

#include <stdarg.h>

// Definiciones para la UART
// Use a datasheet for a 16550 UART
// For example: https://www.ti.com/lit/ds/symlink/tl16c550d.pdf
#define UART0_BASE 0x10000000
#define REG(base, offset) ((*((volatile unsigned char *)(base + offset))))
#define UART0_DR REG(UART0_BASE, 0x00)
#define UART0_FCR REG(UART0_BASE, 0x02)
#define UART0_LSR REG(UART0_BASE, 0x05)

#define UARTFCR_FFENA 0x01 // UART FIFO Control Register enable bit
#define UARTLSR_THRE 0x20  // UART Line Status Register Transmit Hold Register Empty bit
#define UART0_FF_THR_EMPTY (UART0_LSR & UARTLSR_THRE)

/**
 * @brief Inicializa la UART
 * @details Esta función configura la UART para su uso. Se establece el FIFO para operación en modo polled.
 */
void uart_init()
{
  UART0_FCR = UARTFCR_FFENA; // Set the FIFO for polled operation
}

/**
 * @brief Escribe un caracter en la UART
 * @param c Caracter a escribir
 * @details Esta función espera hasta que el registro de retención FIFO de la UART esté vacío
 *          antes de escribir el caracter en el registro del transmisor.
 */
void uart_putc(char c)
{
  while (!UART0_FF_THR_EMPTY)
    ;           // Wait until the FIFO holding register is empty
  UART0_DR = c; // Write character to transmitter register
}

/**
 * @brief Escribe una cadena de caracteres en la UART
 * @param str Cadena de caracteres a escribir
 * @details Esta función escribe una cadena de caracteres en la UART utilizando la función uart_putc.
 */
void dac_prints(const char *str)
{
  while (*str)
  {                    // Loop until value at string pointer is zero
    uart_putc(*str++); // Write the character and increment pointer
  }
}

/**
 * @brief Escribe un número entero en la UART
 * @param num Número entero a escribir
 * @details Esta función convierte un número entero en una cadena de caracteres y lo escribe en la UART.
 */
void dac_printi(int num)
{
  char buffer[12]; // Buffer to hold the string representation of the number
  int i = 0;

  if (num < 0)
  {
    uart_putc('-'); // Print negative sign
    num = -num;     // Make number positive
  }

  if (num == 0)
  {
    uart_putc('0');
    return;
  }

  while (num > 0)
  {
    buffer[i++] = (num % 10) + '0'; // Convert digit to character
    num /= 10;                      // Divide by 10 to get next digit
  }

  while (i > 0)
    uart_putc(buffer[--i]); // Write characters in reverse order
}

/**
 * @brief Escribe una cadena con formato en la UART
 * @param format Cadena de formato
 * @details Esta función permite escribir cadenas con formato en la UART. Soporta %d para enteros y %s para cadenas.
 */
void dac_printf(const char *format, ...)
{
  va_list args;
  va_start(args, format);

  while (*format)
  {
    if (*format == '%')
    {
      format++;
      if (*format == 'd')
      {
        int num = va_arg(args, int);
        dac_printi(num);
      }
      else if (*format == 's')
      {
        const char *str = va_arg(args, const char *);
        dac_prints(str);
      }
    }
    else
    {
      uart_putc(*format);
    }
    format++;
  }

  va_end(args);
}