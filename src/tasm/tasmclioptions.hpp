// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_CLIOPTIONS
#define TASM_CLIOPTIONS

#include "utils/clioptions.hpp"

class TasmCLIOptions : public utils::CLIOptions {
public:
  TasmCLIOptions();
  BinaryOption compact;
  BinaryOption obj;
  BinaryOption c10;
  BinaryOption lst;
  BinaryOption sym;
  BinaryOption gbl;
  BinaryOption wBranch;
  BinaryOption wGlobal;
  BinaryOption wUnused;
  BinaryOption dash;
};

#endif
