// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm.hpp"

int main(int argc, char *argv[])
{
  tasm t(argc, argv);
  return t.execute();
}
