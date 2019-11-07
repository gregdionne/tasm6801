// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef FETCHER_HPP
#define FETCHER_HPP

#include <stdio.h>
class Fetcher {
 public:
  char buf[BUFSIZ];
  char token[BUFSIZ];
  int argc;
  char **argv;
  int filecnt;
  int linenum;
  int linelen;
  int colnum;
  int keyID;
  Fetcher(int argc, char *argv[]) :
      argc(argc), argv(argv), filecnt(0), linenum(0), linelen(0), colnum(0) 
  {init();}

  char *getLine(void);
  void spitLine(void);
  void die(const char *formatstr, ...);
  void expandTabs(int n);
  bool isWhitespace(void);
  bool skipWhitespace(void);
  void matchWhitespace(void);
  bool iseol(void);
  bool isBlankLine(void);
  void matcheol(void);
  char prevChar(void);
  char peekChar(void);
  bool skipChar(char c);
  char getChar(void);
  void ungetChar(void);
  void matchChar(char c);
  bool isChar(char c);
  bool isAlpha(void);
  bool isAlnum(void);
  char *peekLine(void);
  void advance(int n);
  bool peekKeyword(const char *keywords[]);
  bool skipKeyword(const char *keywords[]);
  bool skipToken(const char *token);
  bool isNumber(int (*id)(int),int (*d)(int), int m, int limit);
  bool isBinaryByte(void);
  bool isQuaternaryByte(void);
  bool isOctalByte(void);
  bool isDecimalByte(void);
  bool isHexadecimalByte(void);
  bool isBinaryWord(void);
  bool isQuaternaryWord(void);
  bool isDecimalWord(void);
  bool isHexadecimalWord(void);
  int getNumber(int (*id)(int),int (*d)(int), int m, int limit, const char *errmsg);
  int getBinaryByte(void);
  int getBinaryWord(void);
  int getQuaternaryByte(void);
  int getQuaternaryWord(void);
  int getOctalByte(void);
  int getHexadecimalByte(void);
  int getHexadecimalWord(void);
  int getDecimalByte(void);
  int getDecimalWord(void);
  int getQuotedLiteral(void);

private:
  FILE *fp;
  bool openNext(void);
  void init(void);
  void expandTabs(char *b, int m, int n);
};
#endif
