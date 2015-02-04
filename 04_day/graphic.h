#define COL_BACK               0   //  0:黑 
#define COL_BRIGHT_RED         1   //  1:亮红 
#define COL_BRIGHT_GREEN       2   //  2:亮绿 
#define COL_BRIGHT_YELLOW      3   //  3:亮黄 
#define COL_BRIGHT_BLUE        4   //  4:亮蓝
#define COL_BRIGHT_PURPLE      5   //  5:亮紫 
#define COL_LIGHT_BRIGHT_BLUE  6   //  6:浅亮蓝 
#define COL_WHITE              7   //  7:白
#define COL_BRIGHT_GREY        8   //  8:亮灰 
#define COL_DARK_RED           9   //  9:暗红 
#define COL_DARK_GREEN         10  // 10:暗绿 
#define COL_DARK_YELLOW        11  // 11:暗黄 
#define COL_DARK_BLUE          12  // 12:暗蓝
#define COL_DARK_PURPLE        13  // 13:暗紫 
#define COL_LIGHT_DARK_BLUE    14  // 14:浅暗蓝 
#define COL_DARK_GREY          15  // 15:暗灰 

void set_palette(int start_index, int end_index, unsigned char *colors);
void init_palette();
void draw_rectangle(unsigned char *vram, int scrnx, unsigned char color, int x0, int y0, int x1, int y1);
void init_window(unsigned char *vram, int scrnx, int scrny);
