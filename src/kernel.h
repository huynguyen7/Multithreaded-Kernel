#ifndef KERNEL_H
#define KERNEL_H

#include <stdint.h>
#define VGA_WIDTH  80
#define VGA_HEIGHT 20

void kernel_main();
void print(const char* str);
void println(const char* str);
void print_color(const char* str, char color);
void println_color(const char* str, char color);

#endif
