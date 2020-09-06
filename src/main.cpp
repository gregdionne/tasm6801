// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm.hpp"
#include "usage.hpp"

int main(int argc, char *argv[])
{
  validateOptions(argc, argv);

  Tasm tasm(argc, argv);
  return tasm.execute();
}
