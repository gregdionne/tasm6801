// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#include "fetcher.hpp"
#include "utils/fileread.hpp"

#include <cctype>  //isxdigit
#include <cmath>   //pow
#include <cstdarg> //va_list, va_start
#include <cstdio>  //f...
#include <cstdlib> //perror
#include <cstring> //strlen

#include <string>

#ifdef _MSC_VER
#define strncasecmp _strnicmp
#define strcasecmp _stricmp
#endif

//  This file was originally a K&R C file.
//  Then it bacame ANSI C.
//  Then it became C++ (98).
//
//  The author has given it just enough attention to survive being called
//  from classes created in C++11 and then C++14.
//
//  It could use const correctness and up<> hints.
//
//  It will then need to be modernized again in another ten years.

static std::string strEscape(std::string const &in) {
  std::string out;
  const char *in_c = in.c_str();
  const char *hex_digits = "0123456789ABCDEF";
  while (char c = *in_c++) {
    out += c == '\t'   ? std::string("\t")
           : c == '\r' ? std::string("\r")
           : c == '\n' ? std::string("\n")
           : isprint(c) || (c & 0x80)
               ? std::string(1, c)
               : std::string("\\x") + hex_digits[(c & 0xf0) >> 4] +
                     hex_digits[c & 0x0f];
  }
  return out;
}

void Fetcher::sputter(const char *formatstr, va_list &vl) const {

  if (linenum) {
    int len = colnum
                  ? fprintf(stderr, "%s:%i:%i: ", filename, linenum, colnum + 1)
                  : fprintf(stderr, "%s:%i: ", filename, linenum);
    fprintf(stderr, "%s\n", strEscape(buf).c_str());
    for (int i = 0; i < len + colnum; i++) {
      fprintf(stderr, " ");
    }
    fprintf(stderr, "^\n");
  }
  vfprintf(stderr, formatstr, vl);
  fprintf(stderr, "\n");
}

void Fetcher::sputter(const char *formatstr, ...) const {
  va_list vl;
  va_start(vl, formatstr);
  sputter(formatstr, vl);
  va_end(vl);
}

void Fetcher::die(const char *formatstr, ...) const {
  va_list vl;
  va_start(vl, formatstr);
  sputter(formatstr, vl);
  va_end(vl);
  exit(1);
}

bool Fetcher::isEOF() const { return ptext >= text.size(); }

char *Fetcher::getLine() {

  while (isEOF() && loadFile()) {
    // nothing to do
  }

  if (ptext < text.size()) {
    auto ntext = ptext;
    while (ntext < text.size() && text[ntext] != '\r' && text[ntext] != '\n') {
      ++ntext;
    }

    auto length = ntext - ptext;
    strncpy(buf, text.substr(ptext, length).c_str(), BUFSIZ);
    if (length > BUFSIZ - 1) {
      die("input line too long");
    }

    auto tmplen = strlen(buf);
    buf[tmplen] = '\0';

    ptext = ntext;
    ptext += text.substr(ntext, 2) == "\r\n" ? 2 : 1;

    linelen = static_cast<int>(strlen(buf));
    colnum = 0;
    ++linenum;
    return buf;
  }

  linelen = 0;
  colnum = 0;
  buf[0] = '\0';
  return nullptr;
}

void Fetcher::expandTabs(char *b, int m, int n) {
  int i = 0;
  while (b[i] && b[i] != '\t') {
    ++i;
  }

  if (b[i] == '\t') {
    b[i] = ' ';
    expandTabs(b + i + 1, m + n - i % n, n);
  }

  do {
    b[i + m] = b[i];
  } while (i--);

  while (m) {
    b[--m] = ' ';
  }
}

void Fetcher::expandTabs(int n) { expandTabs(buf, 0, n); }

bool Fetcher::isWhitespace() const {
  char c = buf[colnum];
  return c == ' ' || c == '\t';
}

bool Fetcher::skipWhitespace() {
  bool flag = isWhitespace();
  while (isWhitespace()) {
    ++colnum;
  }
  return flag;
}

void Fetcher::matchWhitespace() {
  if (!isWhitespace()) {
    die("whitespace expected");
  }
  skipWhitespace();
}

bool Fetcher::iseol() const {
  char c = buf[colnum];
  return c == '\n' || c == '\r' || c == '\0';
}

bool Fetcher::isBlankLine() {
  int savecol = colnum;
  skipWhitespace();
  bool isblank = iseol();
  colnum = savecol;
  return isblank;
}

void Fetcher::matcheol() {
  skipWhitespace();
  if (!iseol()) {
    die("unexpected characters at end of line");
  }
}

char Fetcher::prevChar() const {
  if (!colnum) {
    die("internal error: prevChar() called at start of line");
  }
  return buf[colnum - 1];
}

char Fetcher::peekChar() const { return buf[colnum]; }

bool Fetcher::skipChar(char c) {
  if (c != buf[colnum]) {
    return false;
  }
  colnum++;
  return true;
}

char Fetcher::getChar() {
  char c = peekChar();
  if (!iseol()) {
    ++colnum;
  }
  return c;
}

void Fetcher::ungetChar() {
  if (colnum) {
    --colnum;
  }
}

void Fetcher::matchChar(char c) {
  if (c != buf[colnum]) {
    die("\"%c\" expected", c);
  }
  ++colnum;
}

bool Fetcher::isChar(char c) const { return c == buf[colnum]; }

bool Fetcher::isAlpha() const { return isalpha(buf[colnum]); }

bool Fetcher::isAlnum() const { return isalnum(buf[colnum]); }

char *Fetcher::peekLine() { return &buf[colnum]; }

void Fetcher::advance(int n) { colnum += n; }

bool Fetcher::peekKeyword(const char *const keywords[]) {
  for (int i = 0; keywords[i]; i++) {
    if (!strncasecmp(keywords[i], peekLine(), strlen(keywords[i]))) {
      keyID = i;
      return true;
    }
  }
  return false;
}

bool Fetcher::skipKeyword(const char *const keywords[]) {

  if (peekKeyword(keywords)) {
    advance(static_cast<int>(strlen(keywords[keyID])));
    return true;
  }

  return false;
}

bool Fetcher::skipToken(const char *token) {
  bool flag;

  if ((flag = !strncmp(token, peekLine(), strlen(token)))) {
    advance(static_cast<int>(strlen(token)));
  }

  return flag;
}

static int isbdigit(int c) { return static_cast<int>(c == '0' || c == '1'); }

static int isqdigit(int c) { return '0' <= c && c <= '3'; }

static int isodigit(int c) { return '0' <= c && c <= '7'; }

static int digit(int c) { return c - '0'; }

static int xdigit(int c) {
  return 'a' <= c && c <= 'f'   ? c - 'a' + 10
         : 'A' <= c && c <= 'F' ? c - 'A' + 10
                                : digit(c);
}

bool Fetcher::isNumber(int (*id)(int), int (*d)(int), int m, int limit) {
  int saveColnum = colnum;
  char c = peekChar();
  int x = 0;

  if (!id(c)) {
    return false;
  }

  while (id(c)) {
    x *= m;
    x += d(c);
    if (x > limit) {
      colnum = saveColnum;
      return false;
    }
    advance(1);
    c = peekChar();
  }
  colnum = saveColnum;
  return true;
}

bool Fetcher::isBinaryByte() { return isNumber(isbdigit, digit, 2, 0xff); }

bool Fetcher::isDecimalByte() { return isNumber(isdigit, digit, 10, 0xff); }

bool Fetcher::isHexadecimalByte() {
  return isNumber(isxdigit, digit, 10, 0xff);
}

bool Fetcher::isBinaryWord() { return isNumber(isbdigit, digit, 2, 0xffff); }

bool Fetcher::isDecimalWord() { return isNumber(isdigit, digit, 10, 0xffff); }

bool Fetcher::isHexadecimalWord() {
  return isNumber(isxdigit, xdigit, 16, 0xffff);
}

int Fetcher::getDigits(int (*id)(int), int (*d)(int), int m, int limit,
                       const char *errmsg) {
  int x = 0;

  while (limit) {
    char c = peekChar();
    if (!id(c)) {
      die(errmsg);
    }
    x *= m;
    x += d(c);
    advance(1);
    --limit;
  }

  return x;
}

int Fetcher::getPartialBinaryByte() {
  return getDigits(isbdigit, digit, 2, 8, "binary digit expected");
}

int Fetcher::getPartialQuaternaryByte() {
  return getDigits(isqdigit, digit, 4, 4, "quaternary digit expected");
}

int Fetcher::getPartialHexadecimalByte() {
  return getDigits(isxdigit, xdigit, 16, 2, "hexadecimal digit expected");
}

int Fetcher::getNumber(int (*id)(int), int (*d)(int), int m, int limit,
                       const char *errmsg) {
  char c = peekChar();
  int x = 0;

  if (!id(c)) {
    die(errmsg);
  }

  while (id(c)) {
    x *= m;
    x += d(c);
    if (x > limit) {
      die(limit == 0xff ? "Value too big to fit in one byte"
                        : "Value too big to fit in two bytes");
    }
    advance(1);
    c = peekChar();
  }
  return x;
}

int Fetcher::getBinaryByte() {
  return getNumber(isbdigit, digit, 2, 0xff, "binary digit expected");
}

int Fetcher::getBinaryWord() {
  return getNumber(isbdigit, digit, 2, 0xffff, "binary digit expected");
}

int Fetcher::getQuaternaryByte() {
  return getNumber(isqdigit, digit, 4, 0xff, "quaternary digit expected");
}

int Fetcher::getQuaternaryWord() {
  return getNumber(isqdigit, digit, 4, 0xffff, "quaternary digit expected");
}

int Fetcher::getOctalByte() {
  return getNumber(isodigit, digit, 8, 0xff, "octal digit expected");
}

int Fetcher::getOctalWord() {
  return getNumber(isodigit, digit, 8, 0xffff, "octal digit expected");
}

int Fetcher::getDecimalByte() {
  return getNumber(isdigit, digit, 10, 0xff, "decimal digit expected");
}

int Fetcher::getDecimalWord() {
  return getNumber(isdigit, digit, 10, 0xffff, "decimal digit expected");
}

int Fetcher::getHexadecimalByte() {
  return getNumber(isxdigit, xdigit, 16, 0xff, "hexadecimal digit expected");
}

int Fetcher::getHexadecimalWord() {
  return getNumber(isxdigit, xdigit, 16, 0xffff, "hexdecimal digit expected");
}

bool Fetcher::recognizePostfixedWord(int (*id)(int), int (*d)(int), int m,
                                     int limit, char postfixChar,
                                     bool postfixRequired, int &value) {
  if (isNumber(id, d, m, limit)) {
    int savecol = colnum;
    value = getNumber(id, d, m, limit, "digit expected");
    char upperPostfixChar = static_cast<char>(toupper(postfixChar));
    if (((skipChar(postfixChar) || skipChar(upperPostfixChar) ||
          !postfixRequired) &&
         !isAlnum())) {
      return true;
    }
    colnum = savecol;
  }
  return false;
}

bool Fetcher::recognizePostfixedWord(int &value) {
  return recognizePostfixedWord(isxdigit, xdigit, 16, 0xffff, 'h', true,
                                value) ||
         recognizePostfixedWord(isqdigit, digit, 4, 0xffff, 'q', true, value) ||
         recognizePostfixedWord(isbdigit, digit, 2, 0xffff, 'b', true, value) ||
         recognizePostfixedWord(isdigit, digit, 10, 0xffff, 'd', false, value);
}

bool Fetcher::isQuotedChar() {
  bool ischar = false;
  int savecol = colnum;

  if (skipChar('\'')) {
    if (skipChar('\\')) {
      getEscapedChar();
    } else if (!isBlankLine()) {
      getChar();
    }
    ischar = skipChar('\'') || isBlankLine();
  }

  colnum = savecol;
  return ischar;
}

int Fetcher::getEscapedChar() {
  if (skipChar('\\')) {
    int c = static_cast<int>(static_cast<unsigned char>(getChar()));
    if (c >= '0' && c <= '3') {
      int savecol = colnum;
      int n = digit(c);
      if (isodigit(peekChar())) {
        n = 8 * n + digit(getChar());
        if (isodigit(peekChar())) {
          c = 8 * n + digit(getChar());
          savecol = colnum;
        }
      }
      colnum = savecol;
    } else if (c == 'x' && isxdigit(peekChar())) {
      c = xdigit(getChar());
      if (isxdigit(peekChar())) {
        c = 16 * c + xdigit(getChar());
      }
    } else {
      c = c == 'n'   ? '\n'
          : c == 'r' ? '\r'
          : c == 't' ? '\t'
          : c == 'b' ? '\b'
                     : c;
    }
    return c;
  }
  return getChar();
}

bool Fetcher::isFloat() const {
  char c = peekChar();
  return isdigit(c) || c == '.';
}

double Fetcher::getFloat() {
  double v = 0;
  char c = peekChar();
  while (isdigit(c)) {
    v = v * 10 + c - '0';
    advance(1);
    c = peekChar();
  }

  if (c == '.') {
    double f = 0;
    double m = 1;
    advance(1);
    c = peekChar();
    while (isdigit(c)) {
      f = f * 10 + c - '0';
      m = m * 10;
      advance(1);
      c = peekChar();
    }
    v += f / m;
  }

  if (c == 'E') {
    advance(1);
    c = peekChar();
    int sgn = 1;
    while (c == '-' || c == '+') {
      if (c == '-') {
        sgn = -sgn;
      }
      advance(1);
      c = peekChar();
    }
    if (!isdigit(c)) {
      die("Exponent expected");
    }
    double e = getDecimalWord();
    v *= std::pow(10, sgn * e);
  }

  return v;
}

bool Fetcher::loadFile() {
  if (fileno < filenames.size()) {
    filename = filenames[fileno++];
    ptext = 0;
    linenum = 0;
    colnum = 0;
    text = fileread(progname, filename);
    return true;
  }
  return false;
}
