// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef CRTABLE_HPP
#define CRTABLE_HPP

#include <string>
#include <vector>
#include "expression.hpp"

class Reference {
public:
  Reference(int loc, int rtype) : location(loc), reftype(rtype) {}
  Expression expression;
  int location;
  int reftype; // -2 == WORD, -1 == BYTE, 0 == RELOP,  1 == BYTEOP, 2 == WORDOP 
};

class CRTable {
public:
  CRTable(void) {}
  bool addlabel(const char *modulename, const char *labelname, int location, char *filename, int linenum);
  bool addlabel(Label l);
  void addreference(Reference r);
  std::vector<Reference> references;
  bool resolve(Reference& r, int& result, std::string& offender);
  int immediatelyResolve(int reftype, Fetcher& fetcher, const char *modulename, int pc, const char *dir);
  int tentativelyResolve(int reftype, Fetcher& fetcher, const char *modulename, int pc);
  int tentativelyResolve(Reference& r);
  bool resolveReferences(int startpc, unsigned char *binary, int& failpc);
  void reportUnusedReferences(void);

private:
  std::vector<Label> labels;
};
  
#endif
