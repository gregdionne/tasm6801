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
       argc(argc), argv(argv) {}

  void init(void);
  void initline(int n, int pc);
  void finish(std::string line);
  void write(unsigned char *binary, size_t nbytes);
  void write(unsigned char *binary, size_t nbytes, int loadaddr, int execaddr);
  void write(std::vector<std::string>& lines, std::vector<int> pc, int startpc, int endpc, unsigned char binary[], int binsize); 
private:
  void writeFmt(int count, const char *fmt, std::string line, int& remaining, unsigned char binary[], int& byte, int& here);
  void writeRemaining(int n, int& remaining, unsigned char binary[], int& byte, int& here);
  void putchar(char c);
  void putchk(char c);
  void spitleader(void);
  void spitblock(unsigned char *buf, int buflen, int blocktype);
  void filenameblock(char *filearg, int start_addr, int load_addr);
  void datablock(unsigned char *buf, int bufcnt);
  void eofblock(void);
  FILE *flist;
  FILE *fobj;
  FILE *fc10;
  int chksum;
};
#endif
