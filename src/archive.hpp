// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef ARCHIVE_HPP
#define ARCHIVE_HPP

#include <vector>
#include <string>

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
