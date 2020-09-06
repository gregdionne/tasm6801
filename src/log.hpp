// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef LOG_HPP
#define LOG_HPP

#include <stdio.h>
#include <string>
#include <vector>

class Log {
 public:
  int argc_;
  char **argv_;
  Log(int argc, char *argv[]) :
       argc_(argc), argv_(argv) {}

  void init(void);
  void initline(std::size_t n, int pc, int remaining);
  void finish(std::string line);
  void writeObj(unsigned char *binary, size_t nbytes);
  void writeC10(unsigned char *binary, size_t nbytes, int loadaddr, int execaddr);
  void writeLst(std::vector<std::string>& lines, std::vector<int> pc, int startpc, int endpc, unsigned char binary[], int binsize); 
private:
  void processOpts(void);
  void writeFmt(int count, const char *fmt, std::string line, int& remaining, unsigned char binary[], int& byte, int& here);
  void writeRemaining(std::size_t n, int& remaining, unsigned char binary[], int& byte, int& here);
  void putchar(unsigned char c);
  void putchk(unsigned char c);
  void spitleader(void);
  void spitblock(unsigned char *buf, std::size_t buflen, int blocktype);
  void filenameblock(char *filearg, int start_addr, int load_addr);
  void datablock(unsigned char *buf, std::size_t bufcnt);
  void eofblock(void);
  FILE *flist;
  FILE *fobj;
  FILE *fc10;
  int chksum;
  int isListCompact;
  int wUnused;
  int argcnt;
};
#endif
