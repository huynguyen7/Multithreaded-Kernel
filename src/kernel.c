#include "kernel.h"
#include <stdint.h>
#include <stddef.h>
#include "idt/idt.h"
#include "io/io.h"

/**
 * By using the absolute address 0xB8000,
 * we can print to the monitor ascii characters with colors.
 * Format: 2 bytes for each char (first byte if the char ascii value, second byte is the color value ranging from [0,16))
 * Source: https://wiki.osdev.org/Printing_To_Screen
 */

uint16_t* video_mem = 0;   // Printing char routine usage.
uint16_t terminal_row = 0; // Keep track of current row we are printing.
uint16_t terminal_col = 0; // Keep track of current col we are printing.

// Return a word (2 bytes) can print with video mem
uint16_t terminal_make_char(char c, char color) {
	//return (c << 8 | color); // Big endian.
	return (color << 8 | c); // Little endian.
}

// Put char c to the current row and col, with specified color.
void terminal_put_char(int col, int row, char c, char color) {
    video_mem[(row*VGA_WIDTH)+col] = terminal_make_char(c, color);
}

// This let us write char just like writing to a piece of paper.
void terminal_write_char(char c, char color) {
    if(c == '\n') {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }

    terminal_put_char(terminal_col, terminal_row, c, color);
    terminal_col += 1;
    if(terminal_col >= VGA_WIDTH) {
        terminal_col = 0;
        terminal_row += 1;
    }
} 

// Cleaning the BIOS annoying screen output.
void terminal_initialize() {
    video_mem = (uint16_t*)(0xB8000); // Activate VGA at absolutea address 0xB8000.
    for(int y = 0; y < VGA_HEIGHT; ++y) {
        for(int x = 0; x < VGA_WIDTH; ++x)
            terminal_put_char(x, y, ' ', 0); // Just SPACE char.
    }
}

// Getting string length.
size_t strlen(const char* str) {
    size_t len = 0;
    while(str[len]) len++;
    return len;
}

// Print string with color.
void print_color(const char* str, char color) {
    size_t len = strlen(str);
    for(int i = 0; i < len; ++i)
        terminal_write_char(str[i], color);
}

void println_color(const char* str, char color) {
    size_t len = strlen(str);
    for(int i = 0; i < len; ++i)
        terminal_write_char(str[i], color);
    terminal_write_char('\n', color);
}

// Default print, with white colored chars.
void print(const char* str) {
    size_t len = strlen(str);
    for(int i = 0; i < len; ++i)
        terminal_write_char(str[i], 15);
}

void println(const char* str) {
    size_t len = strlen(str);
    for(int i = 0; i < len; ++i)
        terminal_write_char(str[i], 15);
    terminal_write_char('\n', 15);
}

// Main
void kernel_main() {
    terminal_initialize();
	//terminal_write_char('A', 15); // Test printing char.
    print("Hello World!\n"); // Test printing string.
    print_color("I'm in protected mode..\n", 3);

    // Initialize Interrupt Descriptor Table.
    idt_init();
}
