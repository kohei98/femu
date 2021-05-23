#include "screen.hpp"

screen::screen()
{
    // window = NULL;
    SDL_Init(SDL_INIT_VIDEO);
    window = SDL_CreateWindow("femu", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 256, 240, SDL_WINDOW_SHOWN);
    // SDL_Surface *screenSurface = SDL_GetWindowSurface(window);
    ScreenSurface = SDL_GetWindowSurface(window);
    render = SDL_CreateRenderer(window, -1, 0);
    SDL_RenderPresent(render);
    // SDL_SetRenderDrawColor(render, 0, 0, 0, 255);
    SDL_RenderClear(render);
}

void screen::setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data, uint8_t element_table) //ピクセルを着色
{
    uint32_t *pixels = (uint32_t *)ScreenSurface->pixels;
    // printf("x:%4x y:%4x, palette:%4x elementtable:%4x\n", x, y, (element_table >> (2 << ((std::min(2, (x % 4)) >> 2) + 2 << (std::min(2, (y % 4)) >> 2)))) & 0x3, element_table);
    //スプライトを描画
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            if (8 * x + i + 8 * 256 * y + 256 * j < 240 * 256)
            {
                uint8_t id = ((splite_data[0][j] >> (8 - i - 1)) & 1) | (((splite_data[1][j] >> (8 - i - 1) & 1)) << 1);

                // printf("%2x ", id);
                pixels[8 * x + i + 8 * 256 * y + 256 * j] = bg_palette[(element_table >> (0x2 * (std::min(0x2, (x % uint8_t(0x4))) / 0x2 + 0x2 * (std::min(0x2, (y % 0x4)) / 0x2)))) & 0x3][id]; //sp_palette[(y % 2) << 1 + (x % 2)];+
            }
        }
        // printf("\n");
    }
}

void screen::sp_setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data, uint8_t sp_type) //ピクセルを着色
{
    uint32_t *pixels = (uint32_t *)ScreenSurface->pixels;
    //スプライトを描画
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            if (x + i + 256 * y + 256 * j < 240 * 256)
            {
                uint8_t palette = sp_type & 0x00FF;
                uint8_t id = ((splite_data[0][j] >> (8 - i - 1)) & 1) + (((splite_data[1][j] >> (8 - i - 1) & 1)) << 1);
                // if (id != 0)
                // printf("id: %d", id);
                if (id != 0)
                    pixels[x + i + 256 * y + 256 * j] = sp_palette[palette][id]; //sp_palette[(y % 2) << 1 + (x % 2)];+
            }
        }
    }
}