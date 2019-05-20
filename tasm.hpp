// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_HPP
#define TASM_HPP

#include "fetch.hpp"
#include "crtable.hpp"
#include "log.hpp"
#include "archive.hpp"

#define MAXLABELLEN 100

class tasm {
public:
  tasm(int argc, char *argv[]) : fetcher(argc, argv), logger(argc,argv) {
     nbytes = 0; 
     pc = 0; 
     execstart = 0;
     endReached = false;
     *labelname = *modulename = '\0';
  }
  
  int execute(void);

private:
  void writeWord(int w);
  void writeByte(int b);

  bool isWord(void);
  bool isLabelName(void);
  bool isMonomial(void);

  int getWord(void);
  void getLabelName(void);
  monomial getMonomial(void);
  reference getReference(int reftype);
  int getLabelExpression(void);
  int getExpression(int reftype);
  void getLabelEquivalence(const char *labelname);
  bool getReferenceNow(int &result, std::string &offender);
  int getRelativeExpression(void);

  void stripComment(void);

  bool isIndexed(void);
  bool isImmediate(void);
  bool isExtended(void);
  bool isDirect(void);

  bool checkIndexed(void);
  void doAssembly(void);

  void doString(void);
  void doFill(void);
  void doByte(void);
  void doWord(void);
  void doEnd(void);
  void doExecStart(void);
  void doModule(void);
  void doDirective(void);

  void getLabel(void);
  void doLabel(void);

  void getorg(void);
  void process(void);
  void failReference(int refloc);
  void resolveReferences(void);

  fetch fetcher;
  crtable xref;
  log logger;
  archive archiver;
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
