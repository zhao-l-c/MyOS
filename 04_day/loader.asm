; **************************************************
; CPU从16位实模式转换为32位保护模式
; **************************************************

; ==================================================
; 宏定义 
; ==================================================

CYLS  equ  0xff0            ; 加载柱面数目
LEDS  equ  0xff1            ; 键盘LED灯状态
VMODE equ  0xff2            ; VGA模式
SCRNX equ  0xff4            ; 屏幕x轴像素
SCRNY equ  0xff6            ; 屏幕y轴像素
VRAM  equ  0xff8            ; VGA图像缓冲区起始地址

KERNEL_ADDR equ 0x280000    ; 代码段的基地址，用来存放内核代码
FLOPPY_ADDR equ 0x100000    ; 这里用来存放启动扇区和loader的代码
LOADER_ADDR equ 0x8200      ; loader(即10个柱面中的内容)中的代码存放在内存中的位置

; fat12格式的文件中可执行代码的位置，暂时不知道为什么不是0x4200！！
; 如果一个错应该另一个也是错的，但这里文件名的位置是对的，还是在0x2600处！！
FAT12_ENTRY equ 0x4400      

; ==================================================
; loader被加载到内存的位置 
; 34 * 512 + 0x8000 = 0xc400
; ==================================================
    org 0xc400

; 设置寄存器值（应该可以不用，《30天》没有设置，《Oranges》设置了）
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00               ; 栈顶指向前面使用过的0x7c00

; 输出一行字符，看是否成功从boot.asm切换到head.asm
;    mov si, msg_load_kernel
;    call puts

; 设置显示器模式为320*200的8位模式，地址在0xa0000
    mov al, 0x13
    mov ah, 0x00
    int 0x10

; 保存柱面数（源书代码中并没有保存！！）
    mov byte [CYLS], 10

; 保存显示器参数
    mov byte [VMODE], 8
    mov word [SCRNX], 320
    mov word [SCRNY], 200
    mov dword [VMODE], 0xa0000

; 获取并保存键盘LED灯状态
    mov ah, 0x02                  ; 使用int 0x16获取键盘LED灯状态
    int 0x16
    mov [LEDS], al
    
; 准备切换模式，此时需要PIC屏蔽所有中断，并清除EFLAGS的IF位
    mov al, 0xff
    out 0x21, al
    nop
    out 0xa1, al
    cli

; 下面开始切换到32为模式
; 开启A20GATE
    call waitkbdout
    mov al, 0xd1
    out 0x64, al
    call waitkbdout
    mov al, 0xdf
    out 0x60, al
    call waitkbdout


; 设置临时的GDT
    lgdt [GDTR0]

; 设置cr0寄存器
    mov eax, cr0
    and eax, 0x7fffffff    ; PG位为0，机制分页
    or  eax, 0x00000001    ; PE位为1，启动分段
    mov cr0, eax
    jmp flush              ; 需要跳转一下完成切换
flush:

; 重新设置各个段寄存器的值，除了cs
    mov ax, 1000b
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

; 拷贝内核代码到KERNEL_ADDR，这是进入内核后才会设置的GDT代码段的基地址
; 内核代码在loader的下一个扇区，即0xc400+0x200=0xc600
    mov esi, 0xc600
    mov edi, KERNEL_ADDR
    mov ecx, 512 * 1024 / 4
    call memcpy

; 拷贝启动扇区512字节代码到FLOPPY_ADDR
    mov esi, 0x7c00
    mov edi, FLOPPY_ADDR
    mov ecx, 512 / 4
    call memcpy

; 继续拷贝剩余的内容到FLOPPY_ADDR + 512
    mov esi, LOADER_ADDR 
    mov edi, FLOPPY_ADDR + 512
    mov ecx, 0
    mov cl, byte [CYLS]
    imul ecx, 512 * 18 * 2 / 4
    sub  ecx, 512 / 4
    call memcpy
    
; ?????????????????????????????????????????????????
; 下面代码的作用还没完全搞明白
; 暂时不写，因为现在运行没问题
; 直接设置sp的值
; ?????????????????????????????????????????????????
;     mov ebx, KERNEL_ADDR
;     mov ecx, [ebx+16]    ; 共0x11a8，调试发现ecx此时为0（作用未知）
;     add ecx, 3           
;     shr ecx, 2           
;     jz  skip             ; ecx是否是zero，若是则跳转
;     mov esi, [ebx + 20]    ; 0x10c8
;     add esi, ebx
;     mov edi, [ebx + 12]    ; 0x310000
;     call memcpy
; skip:
;     mov esp, [ebx + 12]
    mov esp, 0x310000

; 跳转到内核代码处执行！！
; 10000b 表示的就是代码段。
    jmp dword 10000b : 0

; ==================================================
; 功能函数
; ==================================================

; --------------------------------------------------
; 初始化键盘控制电路
; --------------------------------------------------
waitkbdout:
    in al, 0x64
    and al, 0x02
    jnz waitkbdout
    ret


; --------------------------------------------------
; 字节拷贝函数，每次拷贝4个字节
; --------------------------------------------------
memcpy:
    mov eax, [esi]
    add esi, 4
    mov [edi], eax
    add edi, 4
    sub ecx, 1
    jnz memcpy
    ret

; ==================================================
; 变量定义
; ==================================================


; --------------------------------------------------
; 字符串
; --------------------------------------------------
msg_load_kernel:
    db "Kernel: load kernel success..."
    db 0x0d, 0x0a
    db 0

align 32
; --------------------------------------------------
; GDT
; --------------------------------------------------
GDT0:
    dw 0, 0, 0, 0 ; 空描述符
    
    ; 数据段描述符（92）
    dw 0xffff
    dw 0x0000
    dw 0x9200
    dw 0x00cf

    ; 代码段描述符（9a）
    dw 0xffff
    dw 0x0000
    dw 0x9a28
    dw 0x0047

    dw 0

GDTR0:
    dw 8*3-1             ; GDT表的长度
    dd GDT0              ; GDT表的基地址

align 32

; 调试发现这里是c560
kernel_start:
