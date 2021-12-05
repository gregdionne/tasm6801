// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef CRTABLE_HPP
#define CRTABLE_HPP

#include <string>
#include <vector>
#include "expression.hpp"

class Reference {
public:
  Reference(int loc, int rtype, char *fname, int linenum) : location(loc), reftype(rtype), filename(fname), lineNumber(linenum) {}
  Expression expression;
  int location;
  int reftype; // -2 == WORD, -1 == BYTE, 0 == RELOP,  1 == BYTEOP, 2 == WORDOP 
  char *filename;
  int lineNumber;
  std::string to_string(void);
};

class Module {
public:
  Module(const char *modulename, char *filename, int linenum) : name(modulename), fileName(filename), lineNumber(linenum) {}
  std::string name;
  char *fileName;
  int lineNumber;
};

class CRTable {
public:
  CRTable(void) {}
  bool addlabel(const char *modulename, const char *labelname, int location, char *filename, int linenum);
  bool addmodule(const char *modulename, char *filename, int linenum);
  bool addlabel(Label l);
  void addreference(Reference r);
  std::vector<Reference> references;
  bool resolve(Reference& r, int& result, std::string& offender);
  int immediatelyResolve(int reftype, Fetcher& fetcher, const char *modulename, int pc, const char *dir, char *filename, int linenum);
  int tentativelyResolve(int reftype, Fetcher& fetcher, const char *modulename, int pc, char *filename, int linenum);
  int tentativelyResolve(Reference& r);
  bool resolveReferences(int startpc, unsigned char *binary, int& failpc);
  void reportUnusedReferences(void);

private:
  std::vector<Label> labels;
  std::vector<Module> modules;
};
  
#endif
