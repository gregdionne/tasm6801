// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm/tasm.hpp"
#include "tasm/tasmcliarguments.hpp"

int main(int argc, char *argv[]) {
  TasmCLIArguments args(argc, argv);

  Fetcher f(args.progname, args.filenames);
  Tasm tasm(f, args.options);

  tasm.execute();
}
