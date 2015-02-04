src=hello.s
obj=hello.o
elf=boot.elf
boot=boot.img
asm=boot.asm

$(boot):$(src)
	gcc -c $(src) -m32 -o $(obj)
	ld -m elf_i386 $(obj) -e start -Ttext 0x7c00 -o $(elf)
	objcopy -S -O binary -j .text $(elf)  $(boot)
	#objdump -S $(elf) > $(asm)

clean:
	rm *.elf
	rm *.o

cleanall:
	$(clean)
	rm *.img
