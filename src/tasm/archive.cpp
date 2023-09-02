// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "archive.hpp"

void Archive::push_back(const char *line, int pcloc) {
  lines.emplace_back(line);
  pc.push_back(pcloc);
  valid.push_back(false);
}

void Archive::validate() { valid.back() = true; }
