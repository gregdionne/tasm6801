// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm.hpp"

int main(int argc, char *argv[])
{
  Tasm tasm(argc, argv);
  return tasm.execute();
}
