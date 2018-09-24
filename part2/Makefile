all: build run

clean:
	rm -rf ./*.bin
build:
	nasm -fbin kernel.asm -o kernel.bin
	nasm -fbin bootloader.asm -o bootloader.bin
	cat bootloader.bin kernel.bin > kernelCopy.bin
run:
	qemu-system-i386 kernelCopy.bin