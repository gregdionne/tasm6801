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

You may specify quaternary constants by prefixing with '&' or postfixing with 'Q' or 'q' in the same fashion as binary, octal, and hexadecimal constants (prefixed by '%', '@', and '$'; or postfixed by 'B' or 'b', 'O' or 'o', and 'H' or 'h'; respectively).

## Compilation

### MacOS (Darwin)

Requires C++14.  Tested on Apple clang version 12.0.0 (clang-1200.0.32.28).
The simple makefile should work on most systems.

If you'd rather compile without make, navigate to the "src" directory and enter:
`c++ -std=c++14 -I. */*.cpp */*/*.cpp -o ../tasm6801`

This should compile the program and put the executable in the parent directory.

### Windows 10

Some attempt has been made to make the source compatible with Windows Visual Studio 2017.  What works is to launch the Visual Studio "developer command prompt" by following the instructions [here](https://docs.microsoft.com/en-us/cpp/build/walkthrough-compile-a-c-program-on-the-command-line).  If the link fails, try searching the internet for "Walkthrough:  Compile a C program on the command line".

Once you have the developer command prompt open, navigate to the "src" directory of tasm6801, then run the `vscompile.bat` script by typing:

`vscompile`

You should see `tasm.exe` created in the src directory.

## Usage

You should be comfortable using either a shell program (in linux) or a command prompt (in Windows) and know how to place an executable on your path.  Once it is on your path, you may invoke it like any other command line utility.

Save your assembly program as a text file.  You may use any extension (e.g., ".txt" or ".asm").
Once you have your assembly program, you may assemble it via:

```
tasm6801 [options] <yourprogram.asm>
```

Where [options] can be:

Option      | Description
------      | -----------
&#8209;help          | display help.
&#8209;help <option> | display help for a particular option.
&#8209;compact       | suppress line numbers in the output listing.
&#8209;obj           | output object file (.obj) (default) [-no-obj to disable]
&#8209;c10           | output cassette file (.c10) (default) [-no-c10 to disable]
&#8209;lst           | output list file (.lst) (default) [-no-lst to disable]
&#8209;sym           | output symbol table (.sym)
&#8209;gbl           | output global table (.gbl) with useage by other modules
&#8209;Wbranch       | warn when JMP or JSR can be replaced by BRA or BSR, respectively.
&#8209;Wglobal       | warn about global labels unused by any other module.
&#8209;Wunused       | warn about unused labels in the source files.
&#8209;&#8209;       | treat subsequent arguments as file input (so you can compile a file that starts with "-", like "-filename.asm")

You can also compile multiple files via:

```
tasm6801 [options] file1.asm file2.asm ...
```

This will read the files (in order), compile, and output a listing file (file1.lst), an object file (file1.obj) and a MC-10 cassette (file1.c10) file.   Most MC-10 emulators can load a .c10 file into memory.  By default, the load address of the object binary is used as the execution start address for MICROCOLOR BASIC's EXEC command.

If you are a user of the Virtual MC-10 you can load the .obj into memory at your preferred address.
