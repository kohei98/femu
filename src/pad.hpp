// #include "screen.hpp"
#include <SDL.h>
class pad
{
public:
    uint8_t pad_key_select;
    uint8_t pad_init_flag;
    uint8_t pad_register;
    pad();
    void pad_ope(SDL_Event *e);
    void pad_init(uint8_t data);
    uint8_t send_pad_info();
};