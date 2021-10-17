ASM=nasm
UNLINK=rm

build:
	$(ASM) -f bin ./boot.asm -o ./boot.bin # Using bin format since processor can only understand binary!

clean:
	$(UNLINK) boot.bin
