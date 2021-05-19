#include <stdint.h>
#include <cstdlib>
#include <stdio.h>
#include "screen.hpp"
static const uint16_t pixelwidth = 1;
static const uint16_t pixelheight = 1;

struct ppuregisters
{
    uint8_t ppuctrl; //0x2000
    uint8_t ppumask; //0x2001
    uint8_t ppustatus;
    uint8_t oamaddr;
    uint8_t oamdata;
    uint8_t ppuscroll;
    uint16_t ppuaddr;
    uint8_t ppudata;
};

struct tileinfo
{
    uint8_t name_table_id;
    uint8_t element_table_id;
};

class PPU : public screen
{
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
};