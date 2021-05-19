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
    //スプライトを描画
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            if (8 * x + i + 8 * 256 * y + 256 * j < 240 * 256)
            {
                uint8_t id = ((splite_data[0][j] >> (8 - i - 1)) & 1) + (((splite_data[1][j] >> (8 - i - 1) & 1)) << 1);

                // printf("id: %2x ", id);
                pixels[8 * x + i + 8 * 256 * y + 256 * j] = bg_palette[element_table >> (2 * ((x % 4) / 2 + ((y % 4) / 2) << 1)) & 0x03][id]; //sp_palette[(y % 2) << 1 + (x % 2)];+
            }
        }
        // printf("\n");
    }
}

void screen::sp_setpixelcolor(uint8_t x, uint8_t y, std::vector<std::vector<uint8_t>> &splite_data) //ピクセルを着色
{
    uint32_t *pixels = (uint32_t *)ScreenSurface->pixels;
    //スプライトを描画
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            if (x + i + 256 * y + 256 * j < 240 * 256)
            {
                uint8_t id = ((splite_data[0][j] >> (8 - i - 1)) & 1) + (((splite_data[1][j] >> (8 - i - 1) & 1)) << 1);
                // if (id != 0)
                // printf("id: %d", id);
                pixels[x + i + 256 * y + 256 * j] = sp_palette[0][id]; //sp_palette[(y % 2) << 1 + (x % 2)];+
            }
        }
    }
}