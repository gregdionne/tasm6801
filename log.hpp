// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef LOG_HPP
#define LOG_HPP

#include <stdio.h>
#include <string>
#include <vector>

class log {
 public:
  int argc;
  char **argv;
  log(int argc, char *argv[]) :
       argc(argc), argv(argv)
  {init();}

  void init(void);
  void initline(int n, int pc);
  void finish(std::string line);
  void write(std::vector<std::string>& lines, std::vector<int> pc, int startpc, int endpc, unsigned char binary[], int binsize); 
private:
  FILE *flog;
};
#endif
