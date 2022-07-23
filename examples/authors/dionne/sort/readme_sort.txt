This folder contains a version classic bubblesort and quicksort algorithms that may be run on a TRS80 MC-10.

These will run in MICROCOLOR BASIC:

bsort.bas
qsort.bas

If you use the Virtual MC-10 you can use the "quicktype" feature to load and RUN the programs.
The "cassette" branch of Mike Tinnes' MC-10 emulator can be used in a similar fashion.

To get a sense of the speed difference between BASIC and assembly, you can compile the two
transliterated assembly versions.

tasm6801 bsort.asm
tasm6801 qsort.asm

That should generate .c10 files that can be loaded into an emulator.  
CLOADM and EXEC as you would a normal machine language program.


