ASM=nasm
UNLINK=rm

all:
	$(ASM) -f bin ./src/boot/boot.asm -o ./bin/boot.bin # Using bin format since processor can only understand binary!

clean:
	$(UNLINK) -rf ./bin/boot.bin
