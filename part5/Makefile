all: build run

clean:
	rm -rf ./*.bin
build:
	nasm -fbin kernelImage.asm -o kernelImagePart.bin
	nasm -fbin kernelMoving.asm -o kernelMovingPart.bin
	nasm -fbin kernelShapes.asm -o kernelShapesPart.bin
	nasm -fbin bootloader.asm -o bootloader.bin
	cat bootloader.bin kernelImagePart.bin > kernelImage.bin
	cat bootloader.bin kernelMovingPart.bin > kernelMoving.bin
	cat bootloader.bin kernelShapesPart.bin > kernelShapes.bin
run:
	qemu-system-i386 kernelMoving.bin