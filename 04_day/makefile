# ----------源代码文件------------
# asm源文件
BOOT_ASM = boot.asm
LOADER_ASM = loader.asm
SYSTEM_FUNC_ASM = system_func.asm

# c源文件
KERNEL_C = kernel.c

# ----------中间文件--------------

# 二进制文件
BOOT_BIN = boot.bin
LDR_BIN = loader.bin
KERNEL_BIN = kernel.bin

# elf32文件
SYSTEM_FUNC_ELF = system_func.elf
KERNEL_ELF = kernel.elf

# ----------必须文件-------------
IMG = a.img
FLOPPY = /mnt/floppy

# ----------编译规则-------------
ASM_FLAGS = -f elf32
LD_FLAGS = -s -m elf_i386 -Ttext 0x30400

# ----------编译文件-------------
# 一般生成规则，NASM把.asm文件编译为.bin文件
# %.bin: %.asm
# 	nasm $(ASM_FLAGS) -o $*.bin -l $*.lst $*.asm


## boot.asm 和loader.asm都编译为二进制文件
$(BOOT_BIN) : $(BOOT_ASM)
	nasm -o $@ $< 
$(LDR_BIN) : $(LOADER_ASM)
	nasm -o $@ $< 

## kernel.c编译为kernel.elf文件
$(KERNEL_ELF) : $(KERNEL_C)
	gcc -c -m32 -o $@ $<

## system_func.asm首先编译为elf格式，以便后面与kernel.obj文件连接
$(SYSTEM_FUNC_ELF) : $(SYSTEM_FUNC_ASM) 
	nasm -f elf32 -o $@ $<

##
graphic.elf : graphic.c 
	gcc -fno-stack-protector -fpack-struct -c -m32 -o $@ $<

## 连接kernel.elf和system_func.elf文件，并设置入口地址，生成二进制文件
## ld -s -m elf_i386 -e main --oformat binary -Ttext 0x00 -o $@ $^
$(KERNEL_BIN) : $(KERNEL_ELF) $(SYSTEM_FUNC_ELF) graphic.elf
	ld -m elf_i386 -e main -Ttext 0x00 -o $@ $^

test: 
	make kernel.bin

# ----------拷贝到虚拟软盘---------

all: $(BOOT_BIN) $(LDR_BIN) $(KERNEL_BIN)  
	# 生成新的虚拟软盘
	dd if=/dev/zero of=$(IMG) bs=512 count=2880
	# 1. 把启动扇区的内容写入全新的虚拟软盘中
	# 注意，这一步很关键，把启动扇区写入软盘后文件格式变为MS-DOS，可以通过file命令确认
	dd if=$(BOOT_BIN) of=$(IMG) bs=512 count=1 conv=notrunc
	# 2. 把loader的内容用fat12格式复制到虚拟软盘
	sudo mount -t msdos -o loop $(IMG) $(FLOPPY)
	# 2.1 拷贝loader
	sudo cp $(LDR_BIN) $(FLOPPY) -v
	# 2.2 拷贝kernel
	sudo cp $(KERNEL_BIN) $(FLOPPY) -v
	# 3. 卸载IMG文件
	-sudo umount -vl $(FLOPPY) 

run:
	qemu -fda $(IMG)


# ----------清除文件-------------
clean:
	-sudo umount $(FLOPPY) 
	-rm $(IMG)
	-rm bochsout.txt
	-rm *.bin
	-rm *.lst
	-rm *.elf
