// Copyright (C) 2022 Greg Dionne
// Distributed under MIT License
#include "tasmcliarguments.hpp"

static const char *const argUsage = "file1 [file2 [file3 ...]]\n\n";
static const char *const argDescription =
    "\b can be used to assemble assembly "
    "programs written for the TRS-80 MC-10.\n\n"
    "To use it, save your assembly program as a text file "
    "(e.g., program.asm).\n"
    "Once you have your program, assemble it via:\n\n"
    "\b program.asm\n\n"
    "It will then generate a .c10 file: <yourprogram.c10>\n"
    "You can load the .c10 file in an emulator via CLOADM.\n\n"
    "For playback into a real TRS-80 MC-10 you can try "
    "compiling Cirian Anscomb's cas2wav program to convert "
    "a .c10 file to a .wav.\n\n"
    "See:  https://www.6809.org.uk/dragon/cas2wav-0.8.tar.gz\n\n";

static const char *const helpExample =
    "If you have a text file called hello.bas with the "
    "following contents:\n\n"
    "\t.org\t$4C00\t; originate towards end of on-board memory\n"
    "\tjsr\t$FBD4\t; call BASIC clear screen\n"
    "\tldd\t#$1001\t; load ACCA with 16 (pitch), ACCB with 1 (duration)\n"
    "\tjmp\t$FFAB\t; jump to BASIC sound routine\n"
    "\t.end\n\n"
    "Compile the program by typing:\n\n"
    "\b hello.asm\n\n"
    "if all went well, you should see hello.c10 in the "
    "same directory as hello.asm\n\n";

TasmCLIArguments::TasmCLIArguments(int argc, const char *const argv[])
    : progname(argv[0]) {

  filenames = options.parse(argc, argv, argUsage, argDescription, helpExample);

  if (filenames.empty()) {
    options.usage(progname, argUsage);
    exit(1);
  }
}
