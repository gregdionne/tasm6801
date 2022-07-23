# Multiple File Example

This is an example of how to use multiple files with `tasm6801`.

## Background

When `tasm6801` is invoked it uses the name of the first file as the name of the executable.

The remainder of the files are then processed in order.

## Basic Procedure

This suggests the following strategy:

1. write the main routine with a filename of _progname.asm_
2. write the supporting modules with filenames of the form _modname.s_
3. invoke tasm via:

```
tasm6801 *.asm *.s
```

## Sample Makefile for user of the `make` utility

A sample _Makefile_ is provided for reference which enables all the command line options to tasm6801.

Feel free to edit to be more suitable to your liking.

## Simple IDE Support

tasm6801 outputs errors in a manner that can be parsed by some IDE environments.

For example, the 'vim' editor can invoke a local makefile by the :mak command, which by default will issue `make`.

When an error can be traced to a specific filename and linenumber, `vim` will open the offending file and move the cursor to the correct line.

You can move back and forth from one error to the next using `:cn` and `:cp` commands.

## Program Description

The program in this directory contains a version of the "pi" program contained in examples/authors/dionne/pi.

It has been split into different files where `pi.asm` is the main program and the other `.s` files each contain a single assemble module.

If you invoke the _Makefile_ you should see warnings where a `JSR` or `JMP` instruction could have been replaced by a `BSR` or `BRA` instruction, respectively.  You can change that behavior by removing the `-Wbranch` option from the list of assembler options in the _Makefile_.
