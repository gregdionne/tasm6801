TASM6801 = ../../../../tasm6801

SRC := pacman.asm pacmen.asm maze.asm keyboard.asm ghosties.asm music.asm letters.asm score.asm attractscreen.asm panic.asm audio.asm intermissions.asm
OBJ := pacman.obj

$(OBJ): $(SRC) Makefile
	$(TASM6801) -compact -Wglobal -Wunused -sym -gbl $(SRC)
	diff -b $(OBJ) pacman.bin

clean:
	rm $(obj)
