/**
 * 图形显示函数
 *
 */

#include "system_func.h"
#include "graphic.h"

/**
 * 设置调色板。
 */
void set_palette(int start, int end, unsigned char *colors) {
    int i, eflags;
    eflags = _load_eflags();
    _cli();
    _out8(0x03c8, start);
    for(i = start; i <= end; i++) {
        _out8(0x03c9, colors[0] >> 2);  // ? 为什么要除4，测试结果表明不除4也是正确的
        _out8(0x03c9, colors[1] >> 2);  
        _out8(0x03c9, colors[2] >> 2);  
        colors += 3;
    }
    _store_eflags(eflags);
    return;
}

/**
 * 初始化调色板，这里设置了16种颜色。可以根据需要设置最多256种颜色
 */
void init_palette() {
    unsigned char rgb[16 * 3] = {
        0x00, 0x00, 0x00,   /*  0:黑 */
        0xff, 0x00, 0x00,   /*  1:亮红 */
        0x00, 0xff, 0x00,   /*  2:亮绿 */
        0xff, 0xff, 0x00,   /*  3:亮黄 */
        0x00, 0x00, 0xff,   /*  4:亮蓝*/
        0xff, 0x00, 0xff,   /*  5:亮紫 */
        0x00, 0xff, 0xff,   /*  6:浅亮蓝 */
        0xff, 0xff, 0xff,   /*  7:白*/
        0xc6, 0xc6, 0xc6,   /*  8:亮灰 */
        0x84, 0x00, 0x00,   /*  9:暗红 */
        0x00, 0x84, 0x00,   /* 10:暗绿 */
        0x84, 0x84, 0x00,   /* 11:暗黄 */
        0x00, 0x00, 0x84,   /* 12:暗青 */
        0x84, 0x00, 0x84,   /* 13:暗紫 */
        0x00, 0x84, 0x84,   /* 14:浅暗蓝 */
        0x84, 0x84, 0x84    /* 15:暗灰 */
    };
    set_palette(0, 15, rgb);
    return;
}


/**
 * 绘制矩形
 */
void draw_rectangle(unsigned char *vram, int scrnx, unsigned char color, int x0, int y0, int x1, int y1) {
    int x, y;
    for(y = y0; y <= y1; y++) {
        for(x = x0; x <= x1; x++) {
            vram[scrnx * y + x] = color;
        }
    }
    return;
}


/**
 * 绘制类似Windows的图形.
 */
void init_window(unsigned char *vram, int scrnx, int scrny) {
    draw_rectangle(vram, scrnx, COL_LIGHT_DARK_BLUE, 0,          0, scrnx -  1, scrny - 29);
    draw_rectangle(vram, scrnx, COL_BRIGHT_GREY,     0, scrny - 28, scrnx -  1, scrny - 28);
    draw_rectangle(vram, scrnx, COL_WHITE,           0, scrny - 27, scrnx -  1, scrny - 27);
    draw_rectangle(vram, scrnx, COL_BRIGHT_GREY,     0, scrny - 26, scrnx -  1, scrny -  1);

    draw_rectangle(vram, scrnx, COL_WHITE,           3, scrny - 24,         59, scrny - 24);
    draw_rectangle(vram, scrnx, COL_WHITE,           2, scrny - 24,          2, scrny -  4);
    draw_rectangle(vram, scrnx, COL_DARK_GREY,       3, scrny -  4,         59, scrny -  4);
    draw_rectangle(vram, scrnx, COL_DARK_GREY,      59, scrny - 23,         59, scrny -  5);
    draw_rectangle(vram, scrnx, COL_BACK,            2, scrny -  3,         59, scrny -  3);
    draw_rectangle(vram, scrnx, COL_BACK,           60, scrny - 24,         60, scrny -  3);

    draw_rectangle(vram, scrnx, COL_DARK_GREY, scrnx - 47, scrny - 24, scrnx -  4, scrny - 24);
    draw_rectangle(vram, scrnx, COL_DARK_GREY, scrnx - 47, scrny - 23, scrnx - 47, scrny -  4);
    draw_rectangle(vram, scrnx, COL_WHITE,     scrnx - 47, scrny -  3, scrnx -  4, scrny -  3);
    draw_rectangle(vram, scrnx, COL_WHITE,     scrnx -  3, scrny - 24, scrnx -  3, scrny -  3);
    return;
}


