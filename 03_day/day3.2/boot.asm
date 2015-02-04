; ==================================================================
; 把10个柱面[0~9]的扇区拷贝到内存0x8200开始的位置，每个柱面有2个磁头
; 每个磁头对应的柱面有18个扇区[1~18]，其中第一个扇区被自动加载，
; 所有一共有10*2*18-1 = 359个扇区被拷贝
; 
; 然后使用jmp 0xc400跳转到该位置执行
; 编译方法：
;     make all
; 运行方法：
;     make run
; windows下运行直接点击文件bochsrc.bxrc
; ==================================================================

%define INIT_SEG     0x800     ; 拷贝目的地址
%define OFFSET_SEG   0x200     ; 偏移地址
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
    nop

    db  "helloOS "
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
    dd  0
    db  0,0,0x29
    dd  0
    db  "myosudisk  "
    db  "fat12   "

entry:
    mov ax, 0
    mov ds, ax
    mov ss, ax
    mov sp, 0x7c00

    mov ax, INIT_SEG
    mov es, ax

    mov ch, 0              ; 柱面
    mov dh, 0              ; 磁头
    mov cl, 2              ; 扇区

readloop:
    mov si, 0
retry:
    mov ah, 0x02             ; int 0x13 读写磁盘的功能号
    mov bx, OFFSET_SEG       ; 缓冲区由[es: bx]指定
    mov al, 1                ; 扇区数目
    mov dl, 0                ; 驱动器，0表示软盘
    int 0x13
    
    jnc next                 ; 拷贝下一个扇区

    add si, 1                ; 拷贝失败，每个扇区最多有5次重新尝试机会
    cmp si, 5
    jae error             

    mov ah, 0x00             ; 重新尝试拷贝扇区，需要复位int 0x13
    mov dl, 0x00
    int 0x13
    jmp retry

next:
    mov ax, es               ; [es:bx]向后移动512字节，存放下一个扇区
    add ax, 0x20
    mov es, ax
 
    add cl, 1                ; 拷贝下一个扇区
    cmp cl, 18               ; 每个磁头有18个扇区[1~18]
    jbe readloop

    mov cl, 1                ; 拷贝另一面磁头的扇区，扇区恢复从1开始
    add dh, 1                ; 下一面磁头，磁头共2面[0~1]
    cmp dh, 2              
    jb  readloop     
    
    mov dh, 0                ; 拷贝下一个柱面的扇区，磁头恢复从0开始
    add ch, 1                ; 下一个柱面，共10个柱面[0~9]
    cmp ch, 10               
    jb  readloop

; 复制成功
    mov si, msg_welcome
    call puts

; 惊天一跳，这里还是在实模式下的段内跳转，所以使用jmp 0xc400也是一样的。
; 地址是0xc400(34 * 512+0x8000)，而正常的应该是c200(33*512+0x8000)，为什么多了一个扇区的问题还没解决。
    jmp 0xc40 : 0             

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
    db "BOOTING load error..."
    db 0x0d, 0x0a
    db 0

finish:
    hlt
    jmp finish

    times 510-($-$$) db 0x00
    db 0x55,0xaa
