
# 一般编译规则：asm文件编译为二进制文件
%.o : %.asm
	nasm -f bin -o $*.o $*.asm

boot:
	dd if=/dev/zero of=a.img bs=512 count=2880

all: boot.o head.o a.img
	dd if=boot.o of=a.img count=1 bs=512 conv=notrunc
	dd if=head.o of=a.img seek=1 count=360 conv=notrunc

clean:
	-rm -f *.o 
