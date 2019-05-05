// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef CRTABLE_HPP
#define CRTABLE_HPP

#include <string>
#include <vector>

std::string catlabel(const char *modulename, const char *labelname);

struct monomial {
public:
  std::string name;
  int multiplier;
};

class reference {
public:
  reference(int loc, int rtype) : location(loc), reftype(rtype) {};
  std::vector<monomial> polynomial;
  int location;
  int reftype; // 0 == OP,  1 == BYTE, 2 == WORD 
};

struct label {
public:
  label(const char *modulename, const char *labelname);
  std::string name;
  std::vector<monomial> polynomial;
  bool isdirty;
};

class crtable {
public:
  crtable(void) {};
  bool addlabel(const char *modulename, const char *labelname, int location);
  bool addlabel(label l);
  bool findlabel(std::string name, int &ilbl);
  bool findlabel(const char *modulename, const char *labelname, int& ilbl);
  void addreference(reference r);
  bool resolve(reference &r, int &location, std::string& offender);
  bool resolve(const std::string name, int &location);
  std::vector<reference> references;

private:
  std::vector<label> labels;
};
  
#endif
