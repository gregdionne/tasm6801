// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_OBJWRITER_HPP
#define TASM_OBJWRITER_HPP

#include "archive.hpp"
#include "tasmclioptions.hpp"
#include "tasmobject.hpp"

#include <stdio.h>
#include <string>
#include <vector>

class ObjWriter {
public:
  ObjWriter(const char *pname, const char *fname, const TasmCLIOptions &opts)
      : progname(pname), objfname(fname), options(opts) {}

  void writeObj(const TasmObject &obj);
  void writeC10(const TasmObject &obj);
  void writeLst(const TasmObject &obj);
  void writeGbl(TasmObject &obj);
  void writeSym(TasmObject &obj);

private:
  void processOpts(void);
  void initline(std::size_t n, int pc, int remaining);
  void finish(const std::string &line);
  void writeFmt(int count, const char *fmt, const std::string &line,
                int &remaining, const unsigned char binary[], int &byte,
                int &here);
  void writeRemaining(std::size_t n, int &remaining,
                      const unsigned char binary[], int &byte, int &here);
  void putchar(unsigned char c);
  void putchk(unsigned char c);
  void spitleader(void);
  void spitblock(const unsigned char *buf, std::size_t buflen, int blocktype);
  void filenameblock(const char *filearg, int start_addr, int load_addr);
  void datablock(const unsigned char *buf, std::size_t bufcnt);
  void eofblock(void);

  const char *progname;
  const char *objfname;
  const TasmCLIOptions &options;

  FILE *flist = nullptr;
  FILE *fc10 = nullptr;
  int chksum = 0;

  // for lst writer
  char output[BUFSIZ];
  char scratch[BUFSIZ];
};
#endif
