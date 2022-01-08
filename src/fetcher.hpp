// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef FETCHER_HPP
#define FETCHER_HPP

#include <stdio.h>
class Fetcher {
 public:
  char buf[BUFSIZ];
  char token[BUFSIZ];
  int argc_;
  char **argv_;
  int argcnt;
  int linenum;
  int colnum;
  int argfile;
  int keyID;
  Fetcher(int argc, char *argv[]) :
      argc_(argc), argv_(argv), linenum(0), colnum(0), argfile(0) 
  {init();}

  char *currentFilename(void);
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
  void advance(size_t n);
  bool peekKeyword(const char *keywords[]);
  bool skipKeyword(const char *keywords[]);
  bool skipToken(const char *token);
  bool isBinaryByte(void);
  bool isQuaternaryByte(void);
  bool isOctalByte(void);
  bool isDecimalByte(void);
  bool isHexadecimalByte(void);
  bool isBinaryWord(void);
  bool isQuaternaryWord(void);
  bool isDecimalWord(void);
  bool isHexadecimalWord(void);
  bool isQuotedChar(void);
  int getBinaryByte(void);
  int getBinaryWord(void);
  int getQuaternaryByte(void);
  int getQuaternaryWord(void);
  int getOctalByte(void);
  int getOctalWord(void);
  int getHexadecimalByte(void);
  int getHexadecimalWord(void);
  int getDecimalByte(void);
  int getDecimalWord(void);
  int getEscapedChar(void);

  bool recognizePostfixedWord(int &value);
private:
  FILE *fp;
  void processOpts(void);
  bool openNext(void);
  void init(void);
  void expandTabs(char *b, int m, int n);
  int getNumber(int (*id)(int),int (*d)(int), int m, int limit, const char *errmsg);
  bool isNumber(int (*id)(int),int (*d)(int), int m, int limit);
  bool recognizePostfixedWord(int (*id)(int),int (*d)(int), int m, int limit, 
                                     char postfixChar, bool postfixRequired, int &value);
};
#endif
