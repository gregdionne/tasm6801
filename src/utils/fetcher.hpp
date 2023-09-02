// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_FETCHER_HPP
#define UTILS_FETCHER_HPP

//  This file was originally a K&R C file.
//  Then it bacame ANSI C.
//  Then it became C++ (98).
//
//  The author has given it just enough attention to survive being called
//  from classes created in C++11 and then C++14.
//
//  It could use const correctness.
//
//  It will then need to be modernized again in another ten years.

#include <cstdarg>
#include <cstdio>
#include <string>
#include <vector>

class Fetcher {
public:
  Fetcher(const char *progName, const char *fileName,
          const std::string fileText)
      : progname(progName), filename(fileName), text(fileText) {}

  Fetcher(const char *progName, std::vector<const char *> fileNames)
      : progname(progName), filenames(fileNames) {
    loadFile();
  }

  char *getLine();
  void sputter(const char *formatstr, va_list &vl) const;
  void sputter(const char *formatstr, ...) const;
  void die(const char *formatstr, ...) const;
  void expandTabs(int n);
  bool isWhitespace() const;
  bool skipWhitespace();
  void matchWhitespace();
  bool iseol() const;
  bool isBlankLine();
  void matcheol();
  char prevChar() const;
  char peekChar() const;
  bool skipChar(char c);
  char getChar();
  void ungetChar();
  void matchChar(char c);
  bool isChar(char c) const;
  bool isAlpha() const;
  bool isAlnum() const;
  char *peekLine();
  void advance(int n);
  bool peekKeyword(const char *const keywords[]);
  bool skipKeyword(const char *const keywords[]);
  bool skipToken(const char *token);
  bool isBinaryByte();
  bool isDecimalByte();
  bool isHexadecimalByte();
  bool isBinaryWord();
  bool isDecimalWord();
  bool isHexadecimalWord();
  int getPartialBinaryByte();
  int getPartialQuaternaryByte();
  int getPartialHexadecimalByte();
  int getBinaryByte();
  int getBinaryWord();
  int getQuaternaryByte();
  int getQuaternaryWord();
  int getOctalByte();
  int getOctalWord();
  int getHexadecimalByte();
  int getHexadecimalWord();
  int getDecimalByte();
  int getDecimalWord();
  bool isQuotedChar();
  int getEscapedChar();

  bool recognizePostfixedWord(int &value);

  bool isFloat() const;
  double getFloat();

  // accessors
  int lastKeyID() const { return keyID; }
  int getColumn() const { return colnum; }
  void setColumn(int n) { colnum = n; }
  const char *getProgname() const { return progname; }
  const char *getFilename() const { return filename; }
  int getLineNumber() const { return linenum; }

private:
  bool isEOF() const;
  void expandTabs(char *b, int m, int n);
  int getDigits(int (*id)(int), int (*d)(int), int m, int limit,
                const char *errmsg);
  int getNumber(int (*id)(int), int (*d)(int), int m, int limit,
                const char *errmsg);
  bool isNumber(int (*id)(int), int (*d)(int), int m, int limit);
  bool recognizePostfixedWord(int (*id)(int), int (*d)(int), int m, int limit,
                              char postfixChar, bool postfixRequired,
                              int &value);
  bool loadFile();
  const char *progname;
  const char *filename;
  const std::vector<const char *> filenames;
  std::string text;

  char buf[BUFSIZ];
  int linenum{0};
  int linelen{0};
  int colnum{0};
  int keyID{0};
  std::size_t fileno{0};
  std::size_t ptext{0};
};
#endif
