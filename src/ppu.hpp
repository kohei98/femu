#include <SDL.h>
#include <stdint.h>
#include <stdio.h>

#include <cstdlib>
#include <vector>

static const uint16_t pixelwidth = 1;
static const uint16_t pixelheight = 1;

struct ppuregisters {
    uint8_t ppuctrl;  // 0x2000
    uint8_t ppumask;  // 0x2001
    uint8_t ppustatus;
    uint8_t oamaddr;
    uint8_t oamdata;
    uint8_t ppuscroll;
    uint16_t ppuaddr;
    uint8_t ppudata;
};

struct tileinfo {
    uint8_t name_table_id;
    uint8_t element_table_id;
};

class PPU {
   public:
    ppuregisters PPUregister;
    uint16_t ppuaddr_buffer;
    uint8_t ppuaddr_flag;
    uint16_t oamaddr_buffer;

    uint16_t ppu_cycle;
    uint16_t ppu_line;
    uint8_t *RAM;
    uint8_t *VRAM;
    uint8_t *SP_RAM;
    bool nmi_flag;
    bool hblank_flag;
    bool dma_flag;
    uint8_t used_window;
    bool ppuscroll_flag;
    uint8_t x_scroll;
    uint8_t y_scroll;
    std::vector<std::vector<uint8_t>> sp_data;
    std::vector<std::vector<tileinfo>> background;
    PPU();
    uint8_t vramread(uint16_t address);
    uint8_t vramread_cpu(uint16_t address);
    uint8_t sp_ramread(uint8_t address);
    void vramwrite(uint16_t address, uint8_t data);
    int ppurun(uint8_t cpu_cycle);
    void buildbackground(uint8_t Y);
    void buildtile(uint8_t X, uint8_t Y);
    void buildtile_pixel(uint8_t x, uint8_t y);
    void show_background();
    void render_splite();
    // void render_background();
    uint8_t get_elementtable(uint8_t x, uint8_t y);
    uint8_t get_nametable(uint8_t x, uint8_t y);
    void get_bg_palette();
    void get_sp_palette();
    void get_splite(uint8_t name_table);
    void get_splite_sp(uint8_t name_table);
    void show_window();
    void exec_dma(uint8_t data);
    void set_scroll(uint8_t data);

    SDL_Window *window;
    SDL_Surface *ScreenSurface;
    SDL_Renderer *render;
    uint32_t bg_palette[4][4];
    uint32_t sp_palette[4][4];

    void setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data, uint8_t element_table);  //ピクセルを着色
    void sp_setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data, uint8_t sp_type);     //ピクセルを着色
};

static const uint32_t color[64] = {
    0x808080,
    0x003DA6,
    0x0012B0,
    0x440096,
    0xA1005E,
    0xC70028,
    0xBA0600,
    0x8C1700,
    0x5C2F00,
    0x104500,
    0x054A00,
    0x00472E,
    0x004166,
    0x000000,
    0x050505,
    0x050505,
    0xC7C7C7,
    0x0077FF,
    0x2155FF,
    0x8237FA,
    0xEB2FB5,
    0xFF2950,
    0xFF2200,
    0xD63200,
    0xC46200,
    0x358000,
    0x058F00,
    0x008A55,
    0x0099CC,
    0x212121,
    0x090909,
    0x090909,
    0xFFFFFF,
    0x0FD7FF,
    0x69A2FF,
    0xD480FF,
    0xFF45F3,
    0xFF618B,
    0xFF8833,
    0xFF9C12,
    0xFABC20,
    0x9FE30E,
    0x2BF035,
    0x0CF0A4,
    0x05FBFF,
    0x5E5E5E,
    0x0D0D0D,
    0x0D0D0D,
    0xFFFFFF,
    0xA6FCFF,
    0xB3ECFF,
    0xDAABEB,
    0xFFA8F9,
    0xFFABB3,
    0xFFD2B0,
    0xFFEFA6,
    0xFFF79C,
    0xD7E895,
    0xA6EDAF,
    0xA2F2DA,
    0x99FFFC,
    0xDDDDDD,
    0x111111,
    0x111111,
};