TASM6801 := ../../../../tasm6801

SRC := tetris.asm score.asm text.asm sound.asm
OBJ := tetris.obj

$(OBJ): $(SRC) Makefile
	$(TASM6801) -compact -Wglobal -Wunused -sym -gbl $(SRC)
	diff -b $(OBJ) tetris.bin

clean:
	$(RM) *.obj *.lst *.c10 *.gbl *.sym
