// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_HPP
#define TASM_HPP

#include "fetcher.hpp"
#include "crtable.hpp"
#include "macro.hpp"
#include "log.hpp"
#include "archive.hpp"

#define MAXLABELLEN 100

class Tasm {
public:
  Tasm(int argc, char *argv[]) : fetcher(argc, argv), log(argc,argv) {
     nbytes = 0; 
     pc = 0; 
     execstart = 0;
     endReached = false;
     *labelname = *modulename = '\0';
  }
  
  int execute(void);

private:
  void validateObj(void);
  void writeWord(int w);
  void writeByte(int b);

  bool isLabelName(void);
  void getLabelName(void);
  int getLabelExpression(void);

  bool processInherent(int opcode);
  bool processImmediate(int opcode);
  bool processRelative(int opcode);
  bool processForcedExtended(int opcode);

  bool checkIndexed(void);

  void doIndexed(int opcode, int offset);
  void doDirect(int opcode, int address);
  void doExtended(int opcode, int address);

  void doAssembly(void);

  void doString(void);
  void doBlock(void);
  void doFill(void);
  void doText(void);
  void doByte(void);
  void doWord(void);
  void doOrg(void);
  void doEnd(void);
  void doExecStart(void);
  void doModule(void);
  void doMSFirst(void);
  void doDirective(void);

  void doEqu(const char *labelname);
  void doLabel(void);

  void stripComment(void);
  void process(void);
  void resolveReferences(void);
  void failReference(int refloc);

  Fetcher fetcher;
  CRTable xref;
  Macro macro;
  Log log;
  Archive archiver;
  unsigned char binary[65536];
  char modulename[MAXLABELLEN];
  char labelname[MAXLABELLEN];
  int nbytes;
  int pc;
  int startpc;
  int execstart;
  int endReached;
};

#endif
