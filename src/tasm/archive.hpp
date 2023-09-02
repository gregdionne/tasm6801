// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef TASM_ARCHIVE_HPP
#define TASM_ARCHIVE_HPP

#include <string>
#include <vector>

class Archive {
public:
  Archive() {}
  void push_back(const char *line, int pc);
  void validate();

  std::vector<std::string> lines;
  std::vector<int> pc;
  std::vector<bool> valid;
};
#endif
