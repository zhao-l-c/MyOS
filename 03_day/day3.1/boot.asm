; ==================================================================
; 把10个柱面[0~9]的扇区拷贝到内存0x8000开始的位置，每个柱面有2个磁头
; 每个磁头对应的柱面有18个扇区[1~18]，其中第一个扇区被自动加载，
; 所有一共有10*2*18-1 = 359个扇区被拷贝
; 
; 然后使用jmp 0x800:0x00跳转到该位置执行
; 编译方法：
;     nasm -f bin boot.asm -o boot.o
;     nasm -f bin head.asm -o head.o
;     dd if=./boot.o of=./boot.img count=1 bs=512 conv=notrunc
;     dd if=./head.o of=./boot.img seek=1 count=1
; ==================================================================

%define INIT_SEG     0x800     ; 拷贝目的地址起始位置
%define OFFSET_SEG   0x200     ; !!这里可以是其它值，但最好是0x200的整数倍，否则拷贝扇区时会出现错误
%define CYLS         ch        ; 柱面
%define MAX_CYLS     10        ; 最大柱面数目
%define HEAD         dh        ; 磁头
%define SECTOR       cl        ; 扇区
%define SECTOR_NUM   al        ; 扇区号
%define DRIVER       dl        ; 驱动，0代表软驱

section .text
    global _start
_start:

    org 0x7c00

; fat12磁盘固定格式
jmp  entry
    db 0x00
    db  "helloOS"
    dw  512
    db  1
    dw  1
    db  2
    dw  224
    dw  2880
    db  0xf0
    dw  9
    dw  18
    dw  2
    dd  0
    dd  2880
    db  0,0,0x29
    dd  0xffffffff
    db  "myosudisk  "
    db  "fat12   "
    dw  0,0,0,0,0,0,0,0,0

entry:
    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00

    mov ax, INIT_SEG
    mov es, ax

    mov CYLS, 0              ; 柱面
    mov HEAD, 0              ; 磁头
    mov SECTOR, 2            ; 扇区

readloop:
    mov si, 0
retry:
    mov ah, 0x02             ; int 0x13 读写磁盘的功能号
    mov bx, OFFSET_SEG       ; 缓冲区有[es: bx]指定
    mov SECTOR_NUM, 1        ; 扇区数目
    mov DRIVER, 0            ; 驱动器，0表示软盘
    int 0x13
    
    jnc next                 ; 拷贝下一个扇区

    add si, 1                ; 拷贝失败，每个扇区最多有5次重新尝试机会
    cmp si, 5
    jae error             

    mov ah, 0x00             ; 重新尝试拷贝扇区，需要复位int 0x13
    mov DRIVER, 0x00
    int 0x13
    jmp retry

next:
    mov ax, es               ; [es:bx]向后移动512字节，存放下一个扇区
    add ax, 0x20
    mov es, ax

    add SECTOR, 1            ; 拷贝下一个扇区
    cmp SECTOR, 18           ; 每个磁头有18个扇区
    jbe readloop

    mov SECTOR, 1            ; 拷贝另一面磁头的扇区，此时扇区恢复从1开始
    add HEAD, 1
    cmp HEAD, 2              ; 磁头共2面
    jb  readloop     
    
    mov HEAD, 0              ; 拷贝下一个柱面的扇区，磁头恢复从0开始
    add CYLS, 1              
    cmp CYLS, MAX_CYLS       ; 共10个柱面[0~9]
    jb  readloop

; 复制成功
    mov si, msg_welcome
    call puts
; 惊天一跳
    jmp INIT_SEG : OFFSET_SEG

; 拷贝失败
error:
    mov si, msg_load_error
    call puts
    jmp finish

;==============================
; 字符串输出函数
;==============================
puts:
    mov al, byte [si]
    add si, 1
    cmp al, 0
    je  over
    mov ah, 0x0e
    mov bx, 15
    int 0x10
    jmp puts
over:
    ret

; 输出字符串信息
msg_welcome:
    db "Booting: load 358 sectors success..."
    db 0x0d, 0x0a
    db 0

msg_load_error:
    db "Booting: load error..."
    db 0x0d, 0x0a
    db 0

finish:
    hlt
    jmp finish

    times 510-($-$$) db 0x00
    db 0x55,0xaa
