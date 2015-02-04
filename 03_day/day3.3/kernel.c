#include "system_func.h"

void main(void) {
    // 设置屏幕颜色
    int i;
    for(i = 0xa0000; i < 0xaffff; i++) {
        *((char *)i) = i & 0x0f;
    }
    while(1) {
        _io_hlt();
    }
}

