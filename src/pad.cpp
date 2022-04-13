#include "pad.hpp"
pad::pad() {
    pad_init_flag = 0;
    pad_key_select = 0;
    pad_register = 0;
}
void pad::pad_init(uint8_t data) {
    // pad_register = data;
    if (data == 0x01) {
        pad_init_flag = 1;
    } else if (data == 0x00) {
        if (pad_init_flag == 1) {
            pad_key_select = 0;
        }
        pad_init_flag = 0;
    } else {
        pad_init_flag = 0;
    }
    // else
    // {
    //     pad_register = data;
    // }
    return;
}

uint8_t pad::send_pad_info() {
    // uint8_t retval = pad_register;
    // if ((pad_register >> (pad_key_select)) & 0x01)
    // {
    //     printf("send_pad_info\n");
    //     // exit(1);
    // }
    uint8_t retval = (pad_register >> pad_key_select) & 0x01;
    // if (retval != 0 && pad_key_select == 3)
    // printf("call send\n");
    pad_key_select++;
    pad_key_select %= 8;
    return retval;
}

void pad::pad_ope(SDL_Event *e) {
    if (e->type == SDL_KEYDOWN) {
        switch (e->key.keysym.sym) {
            case SDLK_SPACE: {  // a
                pad_register |= 1;

                break;
            }
            case SDLK_b: {  // b
                pad_register |= (1 << 1);
                break;
            }
            case SDLK_BACKSPACE:  // select
            {
                pad_register |= (1 << 2);
                break;
            }
            case SDLK_RETURN:  // start
            {
                pad_register |= (1 << 3);
                break;
            }
            case SDLK_w: {  // up
                pad_register |= (1 << 4);
                break;
            }
            case SDLK_s: {  // down
                pad_register |= (1 << 5);
                printf("down pad_register : %4x!\n", pad_register);
                break;
            }
            case SDLK_a: {  // left
                pad_register |= (1 << 6);
                break;
            }
            case SDLK_d: {  // right
                pad_register |= (1 << 7);
                break;
            }
            default:
                break;
        }
    } else if (e->type == SDL_KEYUP) {
        switch (e->key.keysym.sym) {
            case SDLK_SPACE: {  // a
                pad_register &= ~1;
                break;
            }
            case SDLK_b: {  // b
                pad_register &= ~(1 << 1);
                break;
            }
            case SDLK_BACKSPACE:  // select
            {
                pad_register &= ~(1 << 2);
                break;
            }
            case SDLK_RETURN:  // start
            {
                pad_register &= ~(1 << 3);
                break;
            }
            case SDLK_w: {  // up
                pad_register &= ~(1 << 4);
                break;
            }
            case SDLK_s: {  // down
                pad_register &= ~(1 << 5);
                break;
            }
            case SDLK_a: {  // left
                pad_register &= ~(1 << 6);
                break;
            }
            case SDLK_d: {  // right
                pad_register &= ~(1 << 7);
                break;
            }
            default:
                break;
        }
    }
    return;
}