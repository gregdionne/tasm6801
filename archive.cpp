// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "archive.hpp"

void archive::push_back(const char *line, const int pcloc)
{
  lines.push_back(line);
  pc.push_back(pcloc);
}
