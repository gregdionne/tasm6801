# tasm6801
Simple TASM-like cross-assembler for the Motorola 6801/6803 processor for use with linux/OS-X.  Intended to be used in conjunction with various emulators of the TRS80 MC-10 (most notably James Tamer's "Virtual MC-10").

Most modern linux C++ compilers should be able to use the code as-is.  Tested on Apple LLVM version 10.0.1 (clang-1001.0.46.4).

c++ *.cpp -o tasm6801

Once built, you can compile TASM assembly for the 6801.  

Supported directives are:
.msfirst
.org
.end
.equ
.module
.byte
.word
.fill

To use it, you can just type:

tasm6801 file1 [file2 file3 ...]


This will read the files (in order), compile, and output a "tasm.obj" and a "tasm.log" file.  If you are a user of the Virtual MC-10 you can load the .obj into memory at your preferred address.
