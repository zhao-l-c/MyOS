BOOT = boot.asm
LDT = loader.asm

BOOT_BIN = boot.bin
LDR_BIN = loader.bin

IMG = a.img
FLOPPY = /mnt/floppy

# 一般生成规则，NASM把.asm文件编译为.bin文件
%.bin: %.asm
	nasm -o $*.bin $*.asm

all: $(BOOT_BIN) $(LDR_BIN) $(IMG)
	# 1. 把启动扇区的内容写入全新的虚拟软盘中
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	# 2. 把loader的内容用fat12格式复制到虚拟软盘
	sudo mount -t msdos -o loop $(IMG) $(FLOPPY)
	sudo cp $(LDR_BIN) $(FLOPPY) -v
	sudo umount $(FLOPPY) 

run:
	qemu -fda $(IMG)

clean:
	-sudo umount $(FLOPPY) 
	-rm -f $(BOOT_BIN) $(LDR_BIN)
	#-rm $(IMG)

