; ==============================================================
; CPU从16位实模式转换为32位保护模式
; ==============================================================

%define CYLS    0xff0            ; 加载柱面数目
%define LEDS    0xff1            ; 键盘LED灯状态
%define VMODE   0xff2            ; VGA模式
%define SCRNX   0xff4            ; 屏幕x轴像素
%define SCRNY   0xff6            ; 屏幕y轴像素
%define VRAM    0xff8            ; VGA图像缓冲区起始地址

    org 0xc400
    mov ax, cs
    mov ds, ax
    mov es, ax

; 输出一行字符，看是否成功从boot.asm切换到head.asm
    mov si, msg_load_kernel
    call puts

; VGA设置为320*200的8位模式
    ; mov al, 0x13
    ; mov ah, 0x00
    ; int 0x10

    ; mov byte [VMODE], 8
    ; mov word [SCRNX], 320
    ; mov word [SCRNY], 200
    ; mov dword [VMODE], 0xa0000

    ; mov ah, 0x02                  ; 使用int 0x16获取键盘LED灯状态
    ; int 0x16
    ; mov [LEDS], al

fin:
    hlt
    jmp fin

msg_load_kernel:
    db "Kernel: load kernel success..."
    db 0x0d, 0x0a
    db 0
    
    
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

