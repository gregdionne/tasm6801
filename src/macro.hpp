// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef MACRO_HPP
#define MACRO_HPP

#include <stdio.h>
#include <string>
#include <vector>
#include "fetcher.hpp"

class Definition {
public:
  std::string identifier;
  std::string equivalence;
};

class Macro {
public:
  std::vector<Definition> definitions;
  void process(Fetcher& fetcher, const char *macros[]);
private:
  void addDefinition(Fetcher& fetcher);
  bool isID(std::string& id, Fetcher& fetcher);
  void doSubstitutions(Fetcher& fetcher);
};

#endif //MACRO_HPP
