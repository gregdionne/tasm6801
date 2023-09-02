// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_TASM_HPP
#define TASM_TASM_HPP

#include "archive.hpp"
#include "crtable.hpp"
#include "macro.hpp"
#include "objwriter.hpp"
#include "tasmclioptions.hpp"
#include "tasmobject.hpp"
#include "utils/fetcher.hpp"

#define MAXLABELLEN 100

class Tasm {
public:
  Tasm(Fetcher f, const TasmCLIOptions &opts)
      : options(opts), fetcher(f),
        writer(f.getProgname(), f.getFilename(), opts) {}

  void execute();

private:
  void validateObj();
  void writeWord(int w);
  void writeByte(int b);

  bool isLabelName();
  void getLabelName();
  void addLabel(const char *modulename, const char *labelname, int location,
                const char *filename, int linenum);
  void addLabel(const Label &lbl);
  void addModule(const char *modulename, const char *filename, int linenum);

  bool processInherent(int opcode);
  bool processImmediate(int opcode);
  bool processRelative(int opcode);
  bool processForcedExtended(int opcode);

  bool checkIndexed();

  void doIndexed(int opcode, int offset);
  void doDirect(int opcode, int address);
  void doExtended(int opcode, int address);

  void doAssembly();

  void doBlock();
  void doFill();
  void doText();
  void doNString();
  void doCString();
  void doByte();
  void doWord();
  void doBin();
  void doQuat();
  void doHex();
  void doOrg();
  void doEnd();
  void doExecStart();
  void doModule();
  void doMSFirst();
  void doDirective();

  void doEqu();
  void doLabel();

  void stripComment();
  void process();
  void resolveReferences();

  TasmObject assemble();

  const TasmCLIOptions options;
  Fetcher fetcher;
  ObjWriter writer;
  CRTable xref;
  Macro macro;
  Archive archive;
  std::array<unsigned char, 65536> binary;
  char modulename[MAXLABELLEN] = {'\0'};
  char labelname[MAXLABELLEN] = {'\0'};
  int nbytes = 0;
  int pc = 0;
  int startpc = 0;
  int execstart = 0;
  int endReached = false;
};

#endif
