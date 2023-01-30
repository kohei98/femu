src = $(wildcard src/*.cpp)
obj = $(src:.cpp=.o) 
CXX = g++
CC = gcc
# INCLUDE = -I/usr/library/include -I/usr/local/include/SDL2 -I/usr/X11R6/include 
# INCLUDE = -I/usr/local/include/SDL2 -I/opt/X11/include
# LIBS = -I/usr/library/include -I/opt/homebrew/Cellar/sdl2
CPPFLAGS = -I/usr/library/include -I/opt/homebrew/Cellar/sdl2 -Os -O3 -Ofast
INCLUDE =  -I/usr/local/Cellar/sdl2/2.0.14_1/include/SDL2 -I/opt/X11/include
LDFLAGS = -lSDL2 -L/opt/homebrew/lib 
femu: $(obj)
	$(CXX) -o $@ $^ $(LDFLAGS) $(INCLUDE)
.PHONY: clean
clean:
	rm -f $(obj) femu
