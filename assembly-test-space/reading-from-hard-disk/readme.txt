This program is designed to explain how reading a hard disk with assembly work.

1. Compile the program:
$ make build

2. Check the hexdump:
$ hexdump -C boot.bin

Look at the stdout from hexdump, after the 'U' character, this is another 512-bytes sector.
This should look like `Hello world, this is an awesome message......`.

The question is, how can we read this sector of 512 bytes of data?
