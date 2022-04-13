#include <time.h>

#include "cpu.hpp"

int printerr() {
    printf("malloc failed!\n");
    return 1;
}

const int HEADER_SIZE = 16;
int main(int argc, char *argv[]) {
    fpos_t ft;
    FILE *f = fopen(argv[1], "r");
    fseek(f, 0, SEEK_END);  //ファイルポインタの末尾を指す．(ファイルサイズがわかる)
    fgetpos(f, &ft);
    uint8_t *s = (uint8_t *)malloc(ft * sizeof(uint8_t));  // uint8_t は1byte
    if (s == NULL)
        printerr();
    rewind(f);  //ファイルポインタを先頭に戻す
    fread(s, sizeof(uint8_t), ft, f);
    // cout << sizeof(s) * ft << endl;
    int programROMpages = s[4];
    int characterROMpages = s[5];

    CPU cpu = CPU();
    cpu.print();
    uint8_t *programROM = (uint8_t *)malloc(programROMpages * 0x4000 * sizeof(uint8_t));
    if (programROM == NULL)
        printerr();
    uint8_t *characterROM = (uint8_t *)malloc(characterROMpages * 0x2000 * sizeof(uint8_t));
    if (characterROM == NULL)
        printerr();
    memcpy(programROM, s + 0x10, programROMpages * 0x4000);
    memcpy(characterROM, s + 0x10 + programROMpages * 0x4000, characterROMpages * 0x2000);

    memcpy(cpu.RAM + 0x8000, programROM, programROMpages * 0x4000 * sizeof(uint8_t));
    if (programROMpages == 1) {
        memcpy(cpu.RAM + 0xC000, programROM, programROMpages * 0x4000 * sizeof(uint8_t));
    }
    memcpy(cpu.VRAM, characterROM, characterROMpages * sizeof(uint8_t) * 0x2000);
    cpu.reset();
    int i = 0;
    int cnt = 0;
    bool time_reset = true;
    clock_t start;
    while (1) {
        if (time_reset) {
            start = clock();
            time_reset = false;
        }
        cnt++;
        SDL_Event ev;
        while (SDL_PollEvent(&ev)) {
            if (ev.type == SDL_QUIT)
                exit(1);
            if (ev.type == SDL_KEYDOWN || ev.type == SDL_KEYUP) {
                cpu.pad_ope(&ev);
            }
        }
        uint8_t cpu_cycle = cpu.run();
        int render_line = cpu.ppurun(3 * cpu_cycle);
        clock_t end = clock();
        if (render_line == 241 && cpu.hblank_flag && static_cast<double>(end - start) / CLOCKS_PER_SEC * 1000.0 >= 20.0) {
            cpu.PPUregister.ppustatus |= (1 << 7);
            if (!cpu.nmi_flag) {
                if (((cpu.PPUregister.ppuctrl >> 7) & 1) && !cpu.nmi_flag) {
                    cpu.NMI();
                    cpu.nmi_flag = 1;
                }
            }
        } else if (render_line == 262) {
            if (i >= 1) {
                cpu.show_window();
            }
            cpu.nmi_flag = 0;
            cpu.PPUregister.ppustatus &= 0x8F;
            time_reset = true;
            i++;
        }
    }
    free(s);
    free(programROM);
    free(characterROM);
    cpu.show_background();
    return 0;
}
