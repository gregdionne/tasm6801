// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_MACRO_HPP
#define TASM_MACRO_HPP

#include "utils/fetcher.hpp"
#include <stdio.h>
#include <string>
#include <vector>

class Definition {
public:
  std::string identifier;
  std::string equivalence;
};

class Macro {
public:
  std::vector<Definition> definitions;
  void process(Fetcher &fetcher, const char *const macros[]);

private:
  void addDefinition(Fetcher &fetcher);
  static bool isID(std::string &id, Fetcher &fetcher);
  void doSubstitutions(Fetcher &fetcher);
};

#endif // MACRO_HPP
