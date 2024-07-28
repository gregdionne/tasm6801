This program checks the behavior of various opcodes against checksums
generated via the ROM of the original MICROCOLOR BASIC ROM and the 
MC6803 processor (a MC6801 running in mode 3) from a stock TRS-80 MC-10.

All opcodes that do not involve the stack are tested.  Those that
involve the stack are deliberately skipped.

To use it first CLOADM the .C10 file into your favorite emulator.
If you are using a real MC-10 the test will take some time.

EXEC

The program will loop through each opcode and run tests.

The upper half of the screen shows the status of each single-byte
opcode sorted in row-major order.  Where, for each opcode:
   .  The opcode has not yet run.
   S  The opcode was deliberately skipped.
   P  The opcode passed its checksum test.
   f  The opcode failed the checksum test.

The lower half of the screen shows a history of the past six
opcodes and the opcode currently under test.

The lower right portion of the screen is used as storage for
the condition code register, as well as the current argument
to the opcode.

All opcodes involving single-byte and double-byte data are tested
exhaustively with condition codes and the following (non-exhaustive)
bit patterns for source and data:

    0000  4000  8000  C000
    0001  4001  8001  C001
    3FFE  7FFE  BFFE  FFFE
    3FFF  7FFF  BFFF  FFFF

