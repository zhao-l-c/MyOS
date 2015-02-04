# 这是用GNU汇编实现的hello。
.global main
.code16

main:
    jmp entry
    # 定义fat12文件格式
    .byte 0x00
    .ascii "hello_os"
    .word 512
    .byte 1
    .word 1
    .byte 2
    .word 223
    .word 2880
    .byte 0xf0
    .word 9
    .word 18
    .word 2
    .long 0
    .long 2880
    .byte 0, 0, 0x29
    .long 0xffffffff
    .ascii "my_os_disk"
    .ascii "fat12   "
    .fill 18

entry:
    mov $0, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7c00, %sp

    mov $msg_bootloader, %si
    call puts
    mov $msg_welcome, %si
    call puts

# 输出字符串函数
puts:
    movb (%si), %al            # al存放字符串地址
    add $1, %si
    cmp $0, %al                # 用\0作为字符串输出结束标记
    je finish
    movb $0x0e, %ah
    movw $15, %bx
    int $0x10
    jmp puts

finish:
    hlt
    ret

msg_bootloader:
    .asciz "\r\n bootloader is running..."
msg_welcome:
    .asciz "\r\n Welcome to my Operating System"

.org 510
.word 0xaa55

