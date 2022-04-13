#include "ppu.hpp"

#include <iostream>

PPU::PPU() {
    PPUregister = {0x08, 0x1E, 0x00, 0, 0, 0, 0, 0};
    oamaddr_buffer = 0;
    ppuaddr_buffer = 0;
    ppuaddr_flag = 0;
    ppu_cycle = 0;
    ppu_line = 241;
    background.resize(33, std::vector<tileinfo>(31));
    RAM = (uint8_t *)calloc(0xFFFF, sizeof(uint8_t));
    VRAM = (uint8_t *)calloc(0xFFFF, sizeof(uint8_t));
    SP_RAM = (uint8_t *)calloc((1 << 8), sizeof(uint8_t));
    memset(SP_RAM, 0xFF, (1 << 8));
    sp_data.resize(2, std::vector<uint8_t>(8));
    nmi_flag = false;
    hblank_flag = false;
    dma_flag = false;
    ppuscroll_flag = false;
    SDL_Init(SDL_INIT_VIDEO);
    window = SDL_CreateWindow("femu", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 256, 240, SDL_WINDOW_SHOWN);
    // SDL_Surface *screenSurface = SDL_GetWindowSurface(window);
    ScreenSurface = SDL_GetWindowSurface(window);
    render = SDL_CreateRenderer(window, -1, 0);
}
uint8_t PPU::vramread(uint16_t address) {
    return *(VRAM + address);
}

uint8_t PPU::vramread_cpu(uint16_t address) {
    if (address == 0x0000) {
        return PPUregister.ppuctrl;
    }
    if (address == 0x0001) {
        return PPUregister.ppumask;
    }
    if (address == 0x0002) {
        uint8_t status = (PPUregister.ppustatus);
        PPUregister.ppustatus &= ~(1 << 7);

        return status;
    }
    if (address == 0x0007) {
        uint8_t data = PPUregister.ppudata;
        // printf("2006:%4x\n", PPUregister.ppuaddr);
        PPUregister.ppudata = *(VRAM + (PPUregister.ppuaddr));  //バッファに格納
        if ((PPUregister.ppuctrl >> 2) & 1)
            PPUregister.ppuaddr += 32;
        else {
            PPUregister.ppuaddr++;
        }
        return data;  //送るのは一つ前のデータ
    }

    // printf("vramread: %d\n", VRAM + PPUregister.ppuaddr);
    return *(VRAM + (PPUregister.ppuaddr));
}

void PPU::vramwrite(uint16_t address, uint8_t data) {
    if (address == 0x2000) {
        PPUregister.ppuctrl = data;
    }
    if (address == 0x2001) {
        PPUregister.ppumask = data;
    }
    if (address == 0x2002) {
        PPUregister.ppustatus = data;
    }
    if (address == 0x2005) {
        PPUregister.ppuscroll = data;
    }

    if (address == 0x2007) {
        // printf("2006:%4x\n", PPUregister.ppuaddr);
        *(VRAM + (PPUregister.ppuaddr)) = data;

        if (PPUregister.ppuaddr == 0x3f10 || PPUregister.ppuaddr == 0x3f14 || PPUregister.ppuaddr == 0x3f18 || PPUregister.ppuaddr == 0x3f1c) {
            *(VRAM + PPUregister.ppuaddr - 0x10) = data;
        }
        if (PPUregister.ppuaddr == 0x3f00 || PPUregister.ppuaddr == 0x3f04 || PPUregister.ppuaddr == 0x3f08 || PPUregister.ppuaddr == 0x3f0c) {
            *(VRAM + PPUregister.ppuaddr + 0x10) = data;
        }
        if ((PPUregister.ppuctrl >> 2) & 1)
            PPUregister.ppuaddr += 32;
        else {
            PPUregister.ppuaddr++;
        }
    } else if (address == 0x2004) {
        *(SP_RAM + PPUregister.oamaddr) = data;
        PPUregister.oamaddr++;
    }

    return;
}

int PPU::ppurun(uint8_t cpu_cycle) {
    ppu_cycle += cpu_cycle;
    // printf("%d\n", ppu_cycle);
    // 1ライン分のサイクルが溜まったとき
    if (ppu_cycle >= 341) {
        hblank_flag = true;
        ppu_cycle -= 341;
        ppu_line++;

        if (int(sp_ramread(0) + 8)) {
            PPUregister.ppustatus |= 1 << 6;
        }

        // printf("%d, %d\n", ppu_line, ppu_cycle);
        if (ppu_line <= 240 && ppu_line % 8 == 0) {  // 1ラインを描画

            buildbackground(ppu_line / 8 - 1);  // y座標のラインを描画
        }
        if (ppu_line == 262) {
            render_splite();
            ppu_line = 0;
            PPUregister.ppustatus &= (0xBF);
            return 262;
        }
    } else {
        hblank_flag = false;
    }
    return ppu_line;
}

void PPU::buildbackground(uint8_t Y) {
    get_bg_palette();
    get_sp_palette();
    for (uint8_t X = 0; X < 32; X++) {
        buildtile(X, Y);
    }
}
void PPU::buildtile(uint8_t X, uint8_t Y) {
    // printf("==============\n");
    uint8_t name_table = get_nametable(X, Y);
    uint8_t element_table = get_elementtable(X, Y);
    get_splite(name_table);
    background[X][Y].name_table_id = name_table;
    background[X][Y].element_table_id = element_table;
    setpixelcolor(X, Y, sp_data, element_table);
    return;
}

void PPU::show_background() {
    for (int i = 0; i < 30; i++) {
        for (int j = 0; j < 32; j++) {
            printf("%4x %4x|", background[j][i].name_table_id, background[j][i].element_table_id);
        }
        printf("\n");
    }
}

uint8_t PPU::get_nametable(uint8_t x, uint8_t y) {
    uint8_t window = PPUregister.ppuctrl & 0x03;
    // if (x_scroll > 0) printf("%u\n", x_scroll);
    uint16_t new_x = x * 8 + x_scroll;
    if (window & 1) new_x += 256;
    // printf("x : %u y : %u\n", new_x, y);
    if (new_x >= 256 && new_x < 2 * 256) {
        return vramread(0x2400 + 32 * y + (new_x - 256) / 8);
    }
    new_x /= 8;
    new_x %= (256 / 8 * 2);
    return vramread(0x2000 + 32 * y + new_x);
}

uint8_t PPU::get_elementtable(uint8_t x, uint8_t y) {
    uint8_t window = PPUregister.ppuctrl & 0x03;
    uint16_t new_x = x * 8 + x_scroll;
    if (window & 1) new_x += 256;

    if (new_x >= 256 && new_x < 2 * 256) {
        return vramread(0x27c0 + ((new_x - 256) / 8) / 4 + (8 * (y / 4)));
    }
    new_x /= 8;
    new_x %= (256 / 8 * 2);
    return vramread(0x23c0 + (new_x / 4) + (8 * (y / 4)));
}

void PPU::get_splite(uint8_t name_table) {
    uint16_t ofs = 0;
    if ((PPUregister.ppuctrl >> 4) & 1) {
        ofs = 0x1000;
    }
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
            sp_data[i][j] = vramread(ofs + (16 * name_table) + 8 * i + j);
            if (sp_data[i][j] != 0) {
                // printf("read: %d,%d => %d\n", i, j, sp_data[i][j]);
            }
        }
    }
    return;
}

void PPU::get_splite_sp(uint8_t name_table) {
    uint16_t ofs = 0;
    if ((PPUregister.ppuctrl >> 3) & 1) {
        ofs = 0x1000;
    }
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 8; j++) {
            sp_data[i][j] = vramread(ofs + (16 * name_table) + 8 * i + j);
        }
    }
    return;
}

void PPU::show_window() {
    // printf("call show_window\n");
    SDL_UpdateWindowSurface(window);
    SDL_RenderPresent(render);
}

void PPU::get_bg_palette() {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            if (j == 0) {
                bg_palette[i][j] = color[vramread(0x3f00)];
            } else
                bg_palette[i][j] = color[vramread(0x3f00 + 4 * i + j)];
            // printf("bg : i:%d,j:%d,color:%6x\n", i, j, bg_palette[i][j]);
        }
    }
}

void PPU::get_sp_palette() {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            sp_palette[i][j] = color[vramread(0x3f10 + 4 * i + j)];
            // printf("sp : i:%d,j:%d,color:%6x\n", i, j, sp_palette[i][j]);
        }
    }
}

void PPU::render_splite() {
    for (int i = 0; i < 256; i += 4) {
        uint8_t x = sp_ramread(i + 3);
        uint8_t y = sp_ramread(i);
        uint8_t index = sp_ramread(i + 1);
        get_splite_sp(index);
        uint8_t sp_type = sp_ramread(i + 2);

        if (!((sp_type >> 5) & 1)) {  //スプライトを優先描画する場合
            // // printf("index %x\n", index);
            // // printf("x:%u,y:%usplite:%4x\n", x, y, sp_ramread(i + 1));
            // if (index == 0) {
            //     //     if (((PPUregister.ppumask >> 4) & 1) && ((PPUregister.ppumask >> 3) & 1))
            //     // PPUregister.ppustatus |= 1 << 6;
            // }
            sp_setpixelcolor(x, y, sp_data, sp_type);
        }
    }
}

uint8_t PPU::sp_ramread(uint8_t address) {
    return *(SP_RAM + address);
}

void PPU::exec_dma(uint8_t data) {
    for (uint16_t i = 0; i < 256; i++) {
        uint8_t dma_data = *(RAM + ((data << 8) & 0xFF00) + i);
        *(SP_RAM + i) = dma_data;
    }
    dma_flag = true;
    return;
}

void PPU::set_scroll(uint8_t data) {
    if (!ppuscroll_flag) {
        x_scroll = data;
        ppuscroll_flag = true;
        return;
    } else {
        y_scroll = data;
        ppuscroll_flag = false;
        return;
    }
}

void PPU::setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data, uint8_t element_table)  //ピクセルを着色
{
    uint32_t *pixels = (uint32_t *)ScreenSurface->pixels;
    //スプライトを描画
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            if (8 * x + i + 8 * 256 * y + 256 * j < 240 * 256) {
                uint8_t id = ((splite_data[0][j] >> (8 - i - 1)) & 1) | (((splite_data[1][j] >> (8 - i - 1) & 1)) << 1);
                pixels[8 * x + i + 8 * 256 * y + 256 * j] = bg_palette[(element_table >> (0x2 * (std::min(0x2, (x % uint8_t(0x4))) / 0x2 + 0x2 * (std::min(0x2, (y % 0x4)) / 0x2)))) & 0x3][id];  // sp_palette[(y % 2) << 1 + (x % 2)];+
            }
        }
    }
}

void PPU::sp_setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data, uint8_t sp_type)  //ピクセルを着色
{
    const int dict[8] = {7, 6, 5, 4, 3, 2, 1, 0};
    uint32_t *pixels = (uint32_t *)ScreenSurface->pixels;
    //スプライトを描画
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            if (x + i + 256 * y + 256 * j < 240 * 256) {
                uint8_t palette = sp_type & 0x03;
                uint8_t id = ((splite_data[0][j] >> (8 - i - 1)) & 1) + (((splite_data[1][j] >> (8 - i - 1) & 1)) << 1);
                if (id != 0)
                    if (((sp_type >> 6) & 1) && ((sp_type >> 7) & 1)) {
                        pixels[x + dict[i] + 256 * y + 256 * dict[j]] = sp_palette[palette][id];  // 水平かつ垂直反転
                    } else if (((sp_type >> 6) & 1)) {
                        pixels[x + dict[i] + 256 * y + 256 * j] = sp_palette[palette][id];  // 水平反転
                    } else if (((sp_type >> 7) & 1)) {
                        pixels[x + i + 256 * y + 256 * dict[j]] = sp_palette[palette][id];  // 垂直反転
                    } else {
                        pixels[x + i + 256 * y + 256 * j] = sp_palette[palette][id];
                    }
            }
        }
    }
}