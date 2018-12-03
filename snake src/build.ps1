.././rgbasm.exe -o ../build/Game.o Game.asm
.././rgblink.exe -o ../build/Game.gb ../build/Game.o
.././rgbfix.exe -v -p0 ../build/Game.gb
