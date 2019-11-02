// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "archive.hpp"

void Archive::push_back(const char *line, int pcloc)
{
  lines.push_back(line);
  pc.push_back(pcloc);
}
