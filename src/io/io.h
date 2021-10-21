#ifndef IO_H
#define IO_H

unsigned char insb(unsigned short port); // One byte input to the port.
unsigned char insw(unsigned short port); // Two bytes(word) input to the port.

void outb(unsigned short port, unsigned char val);  // One byte output to the port.
void outw(unsigned short port, unsigned short val); // Two bytes (word) output to the port.

#endif
