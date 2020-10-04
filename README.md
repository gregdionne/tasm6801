# tasm6801
Simple [Telemark](http://www.s100computers.com/Software%20Folder/6502%20Monitor/The%20Telemark%20Assembler%20Manual.pdf)-like assembler for the Motorola 6801/6803 processor for use with linux/OS-X.  Intended to be used in conjunction with various emulators of the TRS-80 MC-10 (most notably James Tamer's "Virtual MC-10").

## Compatibility and Extensions
Supported directives and their corresponding pseudo-op's are:

Directive  | Pseudo-op | Syntax                                                                | Description
---------  | --------- | --------------------------------------------------------------------- | -----------
.msfirst   |           |                                                                       | *ignored*
.org       | org       | *[label]* .org *address*                                              | set program counter to new address.
.end       | end       | *[label]* .end *[expr]*                                               | finalize object record.  optionally set execution start address to expression.
.execstart |           | *[label]* .execstart                                                  | set execution start address to the current program counter.
.equ       | equ       | *label* .equ *expr*                                                   | may be used to assign values to labels.  expressions may contain other labels.
.module    | module    | *[label]* .module *label*                                             | interpret labels beginning with "_" as local labels until encountering the next .module
.byte      | fcb       | *[label]* .byte *expr* *[, expr ...]*                                 | write a sequence of bytes to the object file.
.word      | fdb       | *[label]* .word *expr* *[, expr ...]*                                 | write a sequence of words (two bytes each) to the object file.
.fill      | rzb       | *[label]* .fill *num_bytes* *[, fill_value]*                          | fill a specified number of bytes with a constant value.  (zero by default)
.block     | rmb       | *[label]* .block *num_bytes*                                          | bump the program counter by the specified number of bytes without writing a value.
.text      | fcc       | *[label]* .text *(*"*string*"*\|expr)* *[, (*"*string*"*\|expr) ...]* | write a sequence of strings or byte expressions to the object file.
.strs      | fcs       | *[label]* .strs "*string*" *[, "string" ...]*                         | write a sequence of msb-terminated strings.
.strz      | fcz       | *[label]* .strz "*string*" *[, "string" ...]*                         | write a sequence of null-terminated strings.

Preprocessor macros are not yet supported, however you may use "#define" to preform simple literal substitution.

Expressions respect traditional operator precedence: (e.g. "a+b\*c" evaluates as "a + (b\*c)" instead of "(a+b) \* c")

## Instructions
Most modern linux C++ compilers should be able to build the code as-is.  Tested on Apple LLVM version 10.0.1 (clang-1001.0.46.4).

```
c++ *.cpp -o tasm6801
```

Once built, you can compile TASM assembly for the 6801 by typing:

```
tasm6801 [-Wunused] [-compact] [--] file1 [file2 [file3 ...]]
```

This will read the files (in order), compile, and output a listing file (file1.lst), an object file (file1.obj) and a MC-10 cassette (file1.c10) file.   Most MC-10 emulators can load a .c10 file into memory.  By default, the load address of the object binary is used as the execution start address for MICROCOLOR BASIC's EXEC command.  

If you are a user of the Virtual MC-10 you can load the .obj into memory at your preferred address. 

Option      | Description
------      | -----------
-Wunused    | warn about unused labels in the source files.
-compact    | suppress line numbers in the output listing.
--          | treat subsequent arguments as file input (so you can compile a file that starts with "-", like "-filename.asm") 
