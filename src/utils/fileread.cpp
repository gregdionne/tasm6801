// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#include "fileread.hpp"

#include <fstream>
#include <iostream>
#include <sstream>

std::string fileread(const char *progname, const char *filename) {

  std::ifstream myfstream;

  // open file
  myfstream.open(filename, std::ios::binary);

  if (!myfstream.is_open()) {
    fprintf(stderr, "%s: ", progname);
    perror(filename);
    exit(1);
  }

  std::ostringstream ss;

  ss << myfstream.rdbuf();
  myfstream.close();

  return ss.str();
}
