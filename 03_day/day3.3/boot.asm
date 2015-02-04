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



%define INIT_SEG     0x800     ; 拷贝目的地址段地址

%define OFFSET_SEG   0x200     ; 拷贝目的地址段内偏移地址

%define CYLS         ch        ; 柱面

%define MAX_CYLS     10        ; 最大柱面数目

%define HEAD         dh        ; 磁头

%define SECTOR       cl        ; 扇区

%define SECTOR_NUM   al        ; 扇区号

%define DRIVER       dl        ; 驱动，0代表软驱



    org 0x7c00



; fat12磁盘固定格式

jmp  entry

    nop ; 这一句必不可少



    BS_OEMName      DB 'OEM NAME'       ; OEM String, 必须 8 个字节



    BPB_BytsPerSec  DW 512              ; 每扇区字节数

    BPB_SecPerClus  DB 1                ; 每簇多少扇区

    BPB_RsvdSecCnt  DW 1                ; Boot 记录占用多少扇区

    BPB_NumFATs     DB 2                ; 共有多少 FAT 表

    BPB_RootEntCnt  DW 224              ; 根目录文件数最大值

    BPB_TotSec16    DW 2880             ; 逻辑扇区总数

    BPB_Media       DB 0xF0             ; 媒体描述符

    BPB_FATSz16     DW 9                ; 每FAT扇区数

    BPB_SecPerTrk   DW 18               ; 每磁道扇区数

    BPB_NumHeads    DW 2                ; 磁头数(面数)

    BPB_HiddSec     DD 0                ; 隐藏扇区数

    BPB_TotSec32    DD 0                ; 如果 wTotalSectorCount 是 0 由这个值记录扇区数



    BS_DrvNum       DB 0                ; 中断 13 的驱动器号

    BS_Reserved1    DB 0                ; 未使用

    BS_BootSig      DB 29h              ; 扩展引导标记 (29h)

    BS_VolID        DD 0                ; 卷序列号

    BS_VolLab       DB 'lc os by lc'    ; 卷标, 必须 11 个字节

    BS_FileSysType  DB 'FAT12   '       ; 文件系统类型, 必须 8个字节  



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

    jmp 0xc400



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

    db "BOOTING: LOAD 358 SECTORS SUCCESS..."

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

