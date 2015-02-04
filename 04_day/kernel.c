#include "system_func.h"
#include "graphic.h"

void main(void) {
    init_palette();
    init_window((unsigned char*)0xa0000, 320, 200);
    while(1) {
        _io_hlt();
    }
}

