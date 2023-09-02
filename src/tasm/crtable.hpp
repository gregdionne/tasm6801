// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_CRTABLE_HPP
#define TASM_CRTABLE_HPP

#include "expression.hpp"
#include <string>
#include <vector>

class Reference {
public:
  Reference(int loc, int rtype, const char *mname, const char *fname,
            int linenum)
      : location(loc), reftype(rtype), modname(mname), filename(fname),
        lineNumber(linenum) {}
  Expression expression;
  int location;
  int reftype; // -2 == WORD, -1 == BYTE, 0 == RELOP,  1 == BYTEOP, 2 == WORDOP,
               // 3 == JMP, 4 == JSR
  std::string modname;
  const char *filename;
  int lineNumber;
  std::string to_string();
};

class Module {
public:
  Module(const char *modulename, const char *filename, int linenum)
      : name(modulename), fileName(filename), lineNumber(linenum) {}
  std::string name;
  const char *fileName;
  int lineNumber;
};

class CRTable {
public:
  CRTable() {}
  bool addlabel(const char *modulename, const char *labelname, int location,
                const char *filename, int linenum);
  bool addmodule(const char *modulename, const char *filename, int linenum);
  bool addlabel(const Label &l);
  void addreference(const Reference &r);
  std::vector<Reference> references;
  bool lookup(Label &l, int &result, std::string &offender);
  bool resolve(Reference &r, int &result, std::string &offender);
  int immediatelyResolve(int reftype, Fetcher &fetcher, const char *modulename,
                         int pc, const char *dir, const char *filename,
                         int linenum);
  int tentativelyResolve(int reftype, Fetcher &fetcher, const char *modulename,
                         int pc, const char *filename, int linenum,
                         bool wBranch);
  int tentativelyResolve(Reference &r, Fetcher &fetcher, bool wBranch);
  bool resolveReferences(int startpc, unsigned char *binary, int &failpc,
                         bool wBranch);
  void reportUnusedReferences();
  void reportUnusedGlobalReferences();
  std::vector<std::string> globalTable();
  std::vector<std::string> symbolTable();

private:
  std::vector<Label> labels;
  std::vector<Module> modules;
};

#endif
