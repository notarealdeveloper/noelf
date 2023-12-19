build:
	nasm -f bin -o mkdir.bin mkdir.asm
	nasm -f elf64 -o ld.o ld.asm
	ld -o ld ld.o
	chmod +x ld
	#cc -o ld ld.c

run:
	./ld mkdir.bin

clean:
	rm -rf *.bin *.o ld boop

disassemble:
	ndisasm mkdir.bin
	ndisasm ld
