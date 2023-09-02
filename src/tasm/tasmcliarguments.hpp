// Copyright (C) 2022 Greg Dionne
// Distributed under MIT License
#ifndef TASM_TASMCLIARGUMENTS_HPP
#define TASM_TASMCLIARGUMENTS_HPP

#include "tasmclioptions.hpp"

struct TasmCLIArguments {
  TasmCLIArguments(int argc, const char *const argv[]);
  const char *progname;
  std::vector<const char *> filenames;
  TasmCLIOptions options;
};

#endif
