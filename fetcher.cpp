// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "fetcher.hpp"
#include <stdio.h>  //f...
#include <stdlib.h> //perror
#include <string.h> //strlen
#include <ctype.h>  //isxdigit
#include <stdarg.h> //va_list, va_start

void Fetcher::init(void)
{
   if (argc>1)
      openNext();
   else {
      fprintf(stderr,"usage: %s file1 [file2 [file3 ...]]\n",argv[0]);
      exit(1);
   }
}

void Fetcher::spitLine(void)
{
  if (linenum && filecnt && filecnt<argc) 
    fprintf(stderr,"%s(%i): %s",argv[filecnt],linenum,buf);
}

void Fetcher::die(const char *formatstr, ...)
{
   va_list vl;
   va_start(vl, formatstr);

   if (linenum && filecnt && filecnt<argc) {
     int len = fprintf(stderr,"%s(%i): ",argv[filecnt],linenum);
     fprintf(stderr,"%s",buf);
     for (int i=0; i<len+colnum; i++)
       fprintf(stderr," ");
     fprintf(stderr,"^\n");
   }
   vfprintf(stderr,formatstr,vl);
   fprintf(stderr,"\n");
   exit(1);
}
  
bool Fetcher::openNext(void)
{
  if (++filecnt<argc) {
    fp = fopen(argv[filecnt],"r");
    if (!fp) {
      perror(argv[filecnt]);
      exit(1);
    }
    return true;
  } else { 
    filecnt = 0;
    return false;
  }
}

char *Fetcher::getLine(void)
{
  while (!fgets(buf, BUFSIZ, fp)) {
    fclose(fp);
    linenum = 0;
    if (!openNext())
      return NULL;
  }
  
  if (fp) {
    ++linenum;
    linelen = strlen(buf);
    colnum = 0;
  }
  return buf;
}

void Fetcher::expandTabs(char *b, int m, int n)
{
   int i=0;
   while (b[i] && b[i] != '\t')
     ++i;

   if (b[i] == '\t') {
      b[i] = ' ';
      expandTabs(b+i+1, m+n-i%n, n);
   }

   do 
     b[i+m] = b[i];
   while (i--);

   while (m)
     b[--m] = ' ';     
}

void Fetcher::expandTabs(int n)
{
   expandTabs(buf, 0, n);
}

bool Fetcher::isWhitespace(void)
{
   char c=buf[colnum];
   return c==' ' || c == '\t';
}

bool Fetcher::skipWhitespace(void)
{
   bool flag = isWhitespace();
   while (isWhitespace())
     ++colnum;
   return flag;
}

void Fetcher::matchWhitespace(void)
{
   if (!isWhitespace())
     die("whitespace expected");
   skipWhitespace();
}

bool Fetcher::iseol(void)
{
   char c = buf[colnum];
   return c=='\n' || c=='\r' || c=='\0';
}

bool Fetcher::isBlankLine(void)
{
   int savecol = colnum;
   skipWhitespace();
   bool isblank = iseol();
   colnum = savecol;
   return isblank;
}

void Fetcher::matcheol(void)
{
   skipWhitespace();
   if (!iseol())
      die("unexpected characters at end of line");
}

char Fetcher::prevChar(void)
{
   if (colnum==0)
      die("internal error: prevChar() called at start of line");
   return buf[colnum-1];
}

char Fetcher::peekChar(void)
{
   return buf[colnum];
}

bool Fetcher::skipChar(char c)
{
   if (c!=buf[colnum])
      return false;
   else {
      colnum++;
      return true;
   }
}

char Fetcher::getChar(void)
{
   char c = peekChar();
   if (!iseol())
      ++colnum;
   return c;
}
     
void Fetcher::ungetChar(void)
{
   if (colnum)
     --colnum;
}

void Fetcher::matchChar(char c)
{
   if (c != buf[colnum]) {
     die("\"%c\" expected",c);
   }
   ++colnum;
}

bool Fetcher::isChar(char c)
{
   return c == buf[colnum];
}

bool Fetcher::isAlpha()
{
   return isalpha(buf[colnum]);
}

bool Fetcher::isAlnum()
{
   return isalnum(buf[colnum]);
}

char *Fetcher::peekLine(void)
{
   return &buf[colnum];
}

void Fetcher::advance(int n)
{
   colnum += n;
}

bool Fetcher::peekKeyword(const char *keywords[])
{
   for (int i=0; keywords[i]; i++)
     if (!strncasecmp(keywords[i],peekLine(),strlen(keywords[i]))) {
        keyID = i;
        return true;
     }
   return false;
}

bool Fetcher::skipKeyword(const char *keywords[])
{
   bool flag;   

   if ((flag=peekKeyword(keywords)))
      advance(strlen(keywords[keyID]));

   return flag;
}

bool Fetcher::skipToken(const char *string)
{
   bool flag;

   if ((flag=!strncmp(string,peekLine(),strlen(string))))
      advance(strlen(string));

   return flag;
}

static int isbdigit(int c)
{
   return c=='0' || c=='1';
}

static int isqdigit(int c)
{
   return '0' <= c && c <= '3';
}

static int isodigit(int c)
{
   return '0' <= c && c <= '7';
}

static int digit(int c)
{
   return c-'0';
}

static int xdigit(int c)
{
   return 'a' <= c && c <= 'f' ? c-'a'+10 :
          'A' <= c && c <= 'F' ? c-'A'+10 :
                                 digit(c);
}

bool Fetcher::isNumber(int (*id)(int),int (*d)(int), int m, int limit)
{
   int saveColnum = colnum;
   int c = peekChar();
   int x = 0;

   if (!id(c))
     return false;

   while (id(c)) {
     x *= m;
     x += d(c);
     if (x>limit) {
        colnum = saveColnum;
        return false;
     }
     advance(1);
     c = peekChar();
   }
   colnum = saveColnum;
   return true;
}

bool Fetcher::isBinaryByte(void)
{
   return isNumber(isbdigit, digit,   2, 0xff);
}

bool Fetcher::isQuaternaryByte(void)
{
   return isNumber(isqdigit,  digit,  4, 0xff);
}

bool Fetcher::isOctalByte(void)
{
   return isNumber(isodigit,  digit,  8, 0xff);
}

bool Fetcher::isDecimalByte(void)
{
   return isNumber(isdigit,  digit,  10, 0xff);
}

bool Fetcher::isHexadecimalByte(void)
{
   return isNumber(isxdigit,  digit,  10, 0xff);
}

bool Fetcher::isBinaryWord(void)
{
   return isNumber(isbdigit, digit,   2, 0xffff);
}

bool Fetcher::isQuaternaryWord(void)
{
   return isNumber(isqdigit, digit,   4, 0xffff);
}

bool Fetcher::isDecimalWord(void)
{
   return isNumber(isdigit,  digit,  10, 0xffff);
}

bool Fetcher::isHexadecimalWord(void)
{
  return isNumber(isxdigit, xdigit, 16, 0xffff);
}

int Fetcher::getNumber(int (*id)(int),int (*d)(int), int m, int limit, const char* errmsg)
{
   int c = peekChar();
   int x = 0;

   if (!id(c))
     die(errmsg);

   while (id(c)) {
     x *= m;
     x += d(c);
     if (x>limit)
        die(limit == 0xff ? "Value too big to fit in one byte" :
                            "Value too big to fit in two bytes");
     advance(1);
     c = peekChar();
   }
   return x;
}
   
   

int Fetcher::getBinaryByte(void)
{
   return getNumber(isbdigit, digit, 2, 0xff, "binary digit expected");
}

int Fetcher::getBinaryWord(void)
{
   return getNumber(isbdigit, digit, 2, 0xffff, "binary digit expected");
} 

int Fetcher::getQuaternaryByte(void)
{
   return getNumber(isqdigit, digit, 4, 0xff, "quaternary digit expected");
}

int Fetcher::getQuaternaryWord(void)
{
   return getNumber(isqdigit, digit, 4, 0xffff, "quaternary digit expected");
}

int Fetcher::getOctalByte(void)
{
   return getNumber(isodigit, digit, 8, 0xff, "octal digit expected");
}

int Fetcher::getDecimalByte(void)
{
   return getNumber(isdigit, digit, 10, 0xff, "decimal digit expected");
} 

int Fetcher::getDecimalWord(void)
{
   return getNumber(isdigit, digit, 10, 0xffff, "decimal digit expected");
} 

int Fetcher::getHexadecimalByte(void)
{
   return getNumber(isxdigit, xdigit, 16, 0xff, "hexadecimal digit expected");
} 

int Fetcher::getHexadecimalWord(void)
{
   return getNumber(isxdigit, xdigit, 16, 0xffff, "hexdecimal digit expected");
} 

int Fetcher::getQuotedLiteral(void)
{
   if (skipChar('\\')) {
      int c = getChar();
      if (c == '0' && c <= '3') {
         int savecol = colnum;
         int n = digit(c);
         if (isodigit(peekChar())) {
             n = 8*n + digit(getChar());
             if (isodigit(peekChar())) {
                c = 8*n + digit(getChar());
                savecol = colnum;
             }
         }
         colnum = savecol;
      } else {
         c = c == 'n' ? '\n' :
             c == 'r' ? '\r' :
             c == 't' ? '\t' :
             c == 'b' ? '\b' :
                        c;
      }
      return c;
   } else {
      return getChar();
   }
}

