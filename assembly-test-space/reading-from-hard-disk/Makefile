ASM=nasm
DD=dd
UNLINK=rm

build:
	$(ASM) -f bin ./boot.asm -o ./boot.bin # Using bin format since processor can only understand binary!
	$(DD) if=./message.txt >> ./boot.bin
	$(DD) if=/dev/zero bs=512 count=1 >> ./boot.bin

clean:
	$(UNLINK) boot.bin
