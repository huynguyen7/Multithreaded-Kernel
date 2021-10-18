#include "kernel.h"
#include <stdint.h>

/**
 * By using the absolute address 0xB8000,
 * we can print to the monitor ascii characters with colors.
 * Format: 2 bytes for each char (first byte if the char ascii value, second byte is the color value ranging from [0,16))
 * Source: https://wiki.osdev.org/Printing_To_Screen
 */

/* Return a word (2 bytes) can print with video mem*/
uint16_t terminal_make_char(char c, char color) {
	//return (c << 8 | color); // Big endian.
	return (color << 8 | c); // Little endian.
}

void kernel_main() {
    uint16_t* video_mem = (uint16_t*)(0xB8000);
	video_mem[0] = terminal_make_char('A',3);
}
