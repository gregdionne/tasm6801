TASM6801 := ../../tasm6801

SRCS := $(shell find . -name \*.asm)
MODS := $(shell find . -name \*.s)
OPTS := -Wunused -Wbranch -compact

pi.c10: $(SRCS) $(MODS) Makefile
	$(TASM6801) $(OPTS) $(SRCS) $(MODS)

.PHONY: clean

clean:
	$(RM) *.c10 *.lst *.obj


