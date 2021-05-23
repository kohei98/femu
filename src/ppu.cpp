#include <iostream>
#include "ppu.hpp"

PPU::PPU()
{
    PPUregister = {0x10, 0, 0x00, 0, 0, 0, 0, 0};
    oamaddr_buffer = 0;
    ppuaddr_buffer = 0;
    ppuaddr_flag = 0;
    ppu_cycle = 0;
    ppu_line = 0;
    background.resize(33, std::vector<tileinfo>(31));
    RAM = (uint8_t *)malloc(sizeof(uint8_t) * 0xFFFF);
    VRAM = (uint8_t *)malloc(sizeof(uint8_t) * 0xFFFF);
    SP_RAM = (uint8_t *)calloc((1 << 8), sizeof(uint8_t));
    memset(SP_RAM, 0xFF, (1 << 8));
    sp_data.resize(2, std::vector<uint8_t>(8));
    nmi_flag = false;
    hblank_flag = false;
}
uint8_t PPU::vramread(uint16_t address)
{

    return *(VRAM + address);
}

uint8_t PPU::vramread_cpu(uint16_t address)
{
    if (address == 0x0000)
    {
        return PPUregister.ppuctrl;
    }
    if (address == 0x0001)
    {
    }
    if (address == 0x0002)
    {
        uint8_t status = (PPUregister.ppustatus);
        PPUregister.ppustatus &= ~(1 << 7);

        return status;
    }
    if (address == 0x0007)
    {
        uint8_t data = PPUregister.ppudata;
        // printf("2006:%4x\n", PPUregister.ppuaddr);
        PPUregister.ppudata = *(VRAM + (PPUregister.ppuaddr)); //バッファに格納
        if ((PPUregister.ppuctrl >> 2) & 1)
            PPUregister.ppuaddr += 32;
        else
        {
            PPUregister.ppuaddr++;
        }
        return data; //送るのは一つ前のデータ
    }

    // printf("vramread: %d\n", VRAM + PPUregister.ppuaddr);
    return *(VRAM + (PPUregister.ppuaddr));
}

void PPU::vramwrite(uint16_t address, uint8_t data)
{
    if (address == 0x2000)
    {
        PPUregister.ppuctrl = data;
    }
    if (address == 0x2007)
    {
        // printf("2006:%4x\n", PPUregister.ppuaddr);
        *(VRAM + (PPUregister.ppuaddr)) = data;
        if ((PPUregister.ppuctrl >> 2) & 1)
            PPUregister.ppuaddr += 32;
        else
        {
            PPUregister.ppuaddr++;
        }
    }
    else if (address == 0x2004)
    {
        *(SP_RAM + PPUregister.oamaddr) = data;
        PPUregister.oamaddr++;
    }

    return;
}

int PPU::ppurun(uint8_t cpu_cycle)
{
    ppu_cycle += cpu_cycle;
    // printf("%d\n", ppu_cycle);
    //1ライン分のサイクルが溜まったとき
    if (ppu_cycle >= 341)
    {
        hblank_flag = true;
        ppu_cycle -= 341;
        ppu_line++;
        // printf("%d, %d\n", ppu_line, ppu_cycle);
        if (ppu_line <= 240 && ppu_line % 8 == 0)
        {                                      //1ラインを描画
            buildbackground(ppu_line / 8 - 1); //y座標のラインを描画
        }
        else if (ppu_line == 262)
        {
            render_splite();
            // show_background();
            // show_window();
            // render_background();
            ppu_line = 0;
            return 262;
        }
    }
    else
    {
        hblank_flag = false;
    }
    return ppu_line;
}

void PPU::buildbackground(uint8_t Y)
{
    get_bg_palette();
    get_sp_palette();
    for (uint8_t X = 0; X < 32; X++)
    {
        buildtile(X, Y);
    }
}
void PPU::buildtile(uint8_t X, uint8_t Y)
{
    // printf("==============\n");
    uint8_t name_table = get_nametable(X, Y);
    uint8_t element_table = get_elementtable(X, Y);
    get_splite(name_table);
    background[X][Y].name_table_id = name_table;
    background[X][Y].element_table_id = element_table;
    setpixelcolor(X, Y, sp_data, element_table);
    // if (0x2000 + 32 * Y + X == 0x21c9)
    // {
    //     show_background();
    // }
    // if (0x2000 + 32 * Y + X == 0x21c9)
    // printf("4x, %4x\n", name_table_id, element_table_id);
    return;
}

void PPU::show_background()
{
    for (int i = 0; i < 30; i++)
    {
        for (int j = 0; j < 32; j++)
        {
            printf("%4x %4x|", background[j][i].name_table_id, background[j][i].element_table_id);
        }
        printf("\n");
    }
}

uint8_t PPU::get_nametable(uint8_t x, uint8_t y)
{
    return vramread(0x2000 + 32 * y + x);
}

uint8_t PPU::get_elementtable(uint8_t x, uint8_t y)
{
    return vramread(0x23c0 + (x / 4) + (8 * (y / 4)));
}

void PPU::get_splite(uint8_t name_table)
{
    uint16_t ofs = 0;
    if ((PPUregister.ppuctrl >> 4) & 1)
    {
        ofs = 0x1000;
    }
    for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            sp_data[i][j] = vramread(ofs + (16 * name_table) + 8 * i + j);
            if (sp_data[i][j] != 0)
            {
                // printf("read: %d,%d => %d\n", i, j, sp_data[i][j]);
            }
        }
    }
    return;
}

void PPU::get_splite_sp(uint8_t name_table)
{
    uint16_t ofs = 0;
    if ((PPUregister.ppuctrl >> 3) & 1)
    {
        ofs = 0x1000;
    }
    for (int i = 0; i < 2; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            sp_data[i][j] = vramread(ofs + (16 * name_table) + 8 * i + j);
            // if (sp_data[i][j] != 0)
            // {
            //     printf("read: %d,%d => %d", i, j, sp_data[i][j]);
            // }
        }
    }
    return;
}

void PPU::show_window()
{
    // printf("call show_window\n");
    SDL_UpdateWindowSurface(window);
    SDL_RenderPresent(render);
}

void PPU::get_bg_palette()
{
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            // printf("%4x\n", vramread(0x3f00 + 4 * i + j));
            // printf("%4x\n", 0x3f00 + 4 * i + j);
            bg_palette[i][j] = color[vramread(0x3f00 + 4 * i + j)];
            if (j == 0)
            {
                bg_palette[i][j] = color[vramread(0x3f00 + j + 0x0010)];
            }
            // printf("i:%d,j:%d,color:%6x\n", i, j, bg_palette[i][j]);
        }
    }
}

void PPU::get_sp_palette()
{
    for (int i = 0; i < 4; i++)
    {
        for (int j = 0; j < 4; j++)
        {
            sp_palette[i][j] = color[vramread(0x3f10 + 4 * i + j)];
            if (j == 0)
            {
                sp_palette[i][j] = color[vramread(0x3f00)];
            }
        }
    }
}

void PPU::render_splite()
{

    for (int i = 0; i < 256; i += 4)
    {
        uint8_t x = sp_ramread(i + 3);
        uint8_t y = sp_ramread(i);
        get_splite_sp(sp_ramread(i + 1));
        uint8_t sp_type = sp_ramread(i + 2);
        // printf("x:%4x,y:%4xsplite:%4x\n", x, y, sp_ramread(i + 1));

        // exit(1);
        if (!((sp_type >> 5) & 1))
        {
            // PPUregister.ppustatus |= 1 << 6;
            sp_setpixelcolor(x, y, sp_data, sp_type);
        }
    }
}

uint8_t PPU::sp_ramread(uint8_t address)
{
    return *(SP_RAM + address);
}

void PPU::exec_dma(uint8_t data)
{
    for (uint16_t i = 0; i < 256; i++)
    {
        uint8_t dma_data = *(RAM + ((data << 8) & 0xFF00) + i);
        *(SP_RAM + i) = dma_data;
    }
    return;
}