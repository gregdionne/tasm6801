// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef ARCHIVE_HPP
#define ARCHIVE_HPP

#include <vector>
#include <string>

class archive {
 public:
  archive() {};
  void push_back(const char *line, const int pc);

  std::vector<std::string> lines;
  std::vector<int> pc;
};
#endif
