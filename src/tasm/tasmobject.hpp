// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_TASMOBJECT_HPP
#define TASM_TASMOBJECT_HPP

#include "archive.hpp"
#include "crtable.hpp"

#include <array>

struct TasmObject {
  std::array<unsigned char, 65536> binary;
  int binsize;
  int startpc;
  int endpc;
  int execstart;
  Archive archive;
  CRTable xref;
};

#endif
