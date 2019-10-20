// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm.hpp"

const char *mnemonics[]={/*00*/".CLB", "NOP", "SEX", ".SETA","LSRD","LSLD","TAP", "TPA",
                         /*08*/"INX","DEX","CLV","SEV", "CLC","SEC","CLI","SEI",
                         /*10*/"SBA","CBA",".12",".13",".14",".15", "TAB", "TBA",
                         /*18*/".18","DAA",".1A","ABA",".1C",".1D",".1E",".1F",
                         /*20*/"BRA","BRN","BHI","BLS","BHS","BLO","BNE","BEQ",
                         /*28*/"BVC","BVS","BPL","BMI","BGE","BLT","BGT","BLE",
                         /*30*/"TSX","INS","PULA","PULB","DES","TXS","PSHA","PSHB",
                         /*38*/"PULX","RTS", "ABX", "RTI", "PSHX","MUL", "WAI", "SWI",
                         /*40*/"NEGA",".TSTA","NGCA","COMA","LSRA",".LSRA","RORA","ASRA",
                         /*48*/"LSLA","ROLA","DECA",".DECA","INCA","TSTA",".TA","CLRA",
                         /*50*/"NEGB",".TSTB","NGCB","COMB","LSRB",".LSRB","RORB","ASRB",
                         /*58*/"LSLB","ROLB","DECB",".DECB","INCB","TSTB",".TB","CLRB",
                         /*60*/"NEG",".TST","NGC","COM","LSR",".LSR","ROR","ASR",
                         /*68*/"LSL","ROL","DEC",".DEC","INC","TST","JMP","CLR",
                         /*70*/"SUBA","CMPA","SBCA","SUBD","ANDA","BITA","LDAA","STAA",
                         /*78*/"EORA","ADCA","ORAA","ADDA","CPX","JSR","LDS","STS",
                         /*80*/"SUBB","CMPB","SBCB","ADDD","ANDB","BITB","LDAB","STAB",
                         /*88*/"EORB","ADCB","ORAB","ADDB","LDD", "STD","LDX","STX",
                         /*90*/"BSR","BCC","BCS","ASLD","ASLA","ASLB",0};

const char *directives[]={".msfirst",".org",".execstart",".end",".equ",".module",".text",".byte",".word",".fill",".block",0};

void tasm::validateObj()
{
   if (!nbytes)
      startpc = pc;
   else {
      int bytesMissing = pc - (startpc + nbytes);
      if (bytesMissing < 0) 
         fetcher.die("object binary pc ($%04X) out of sync with pc ($%04X)",startpc+nbytes,pc);
      else if (bytesMissing > 0) {
         while (bytesMissing--)
            binary[nbytes++] = 0;
      }
   }
}

void tasm::writeByte(int b)
{
   if (b<-128 || b>255) 
      fetcher.die("result %i is out of range of a byte",b);

   validateObj();

   b &= 0xff;
   binary[nbytes++] = b;
   pc ++;
}

void tasm::writeWord(int w)
{
   if (w < -32768 || w > 65535) 
      fetcher.die("result %i is out of range of a word",w);

   validateObj();

   w &= 0xffff;
   binary[nbytes++] = w>>8;
   binary[nbytes++] = w&0xff;
   pc += 2;
}

int tasm::getWord(void) {
  return fetcher.skipChar('%') ? fetcher.getBinaryWord() :
         fetcher.skipChar('$') ? fetcher.getHexadecimalWord() :
                                 fetcher.getDecimalWord();
}

bool tasm::isWord(void) {
   return fetcher.isChar('%') ||
          fetcher.isChar('$') ||
          fetcher.isDecimalWord();
}

int tasm::getPC(void) {
   if (!fetcher.skipChar('*'))
      fetcher.matchChar('$');
   return pc;
}

bool tasm::isPC(void) {
   int savecol = fetcher.colnum;
   if (fetcher.skipChar('*') || fetcher.skipChar('$')) {
      fetcher.skipWhitespace();
      bool flag = fetcher.isBinaryWord() || fetcher.isHexadecimalWord() || fetcher.isDecimalWord();
      fetcher.colnum = savecol;
      return !flag;
   }
   return false; 
}

bool tasm::isLabelName(void) {
   return fetcher.isAlpha() || fetcher.isChar('_');
}

void tasm::getLabelName(void) {
   char *c = labelname;
   if (!isLabelName())
      fetcher.die("label expected");
   while (fetcher.isChar('_') || fetcher.isAlnum())
      *c++ = fetcher.getChar();
   *c = '\0';
}

bool tasm::isMonomial() {
   return fetcher.isChar('+') || fetcher.isChar('-') || fetcher.isChar('\'') || isLabelName() || isPC() || isWord();
}

monomial tasm::getMonomial() {
   monomial m;
   m.multiplier = 1;

   do {
      fetcher.skipWhitespace();
      m.multiplier *= fetcher.skipChar('+') ?  1 :
                      fetcher.skipChar('-') ? -1 :
                                               1;
      fetcher.skipWhitespace();
      if (fetcher.skipChar('\'')) {
         m.multiplier *= fetcher.getQuotedLiteral();
         fetcher.matchChar('\'');
      } else if (isPC()) {
         m.multiplier *= getPC();
      } else if (isWord()) {
         m.multiplier *= getWord();
      } else if (isLabelName()) {
         getLabelName();
         int value;
         if (xref.resolve(catlabel(modulename, labelname), value))
            m.multiplier *= value;
         else if (m.name == "")
            m.name = catlabel(modulename, labelname);
         else
            fetcher.die("multiplication requires at least one reference to be resolvable");
      } else 
          fetcher.die("unrecognized input");
      fetcher.skipWhitespace();
   } while (fetcher.skipChar('*'));
   return m;
}

reference tasm::getReference(int reftype) {
   reference r(pc, reftype);
   do {
      r.polynomial.push_back(getMonomial());
      fetcher.skipWhitespace();
   } while (fetcher.isChar('+') || fetcher.isChar('-'));
   return r;
}

void tasm::getLabelEquivalence(const char *labelname) {
   label l(modulename, labelname);
   do {
     l.polynomial.push_back(getMonomial());
     fetcher.skipWhitespace();
   } while (fetcher.isChar('+') || fetcher.isChar('-'));
   xref.addlabel(l);
}

bool tasm::getReferenceNow(int& result, std::string &offender) {
   reference r = getReference(-1);
   return xref.resolve(r, result, offender);
}
  
int tasm::getExpression(int reftype) {
   reference r = getReference(reftype);
   int result;
   std::string offender;
   if (xref.resolve(r, result, offender))
      return result;
   else {
      xref.addreference(r);
      return 0xdead; // return padding.
   }
}

int tasm::getRelativeExpression(void) {
   reference r = getReference(0);
   int result;
   std::string offender;
   if (xref.resolve(r, result, offender)) {
      result -= pc + 2;
      if (result < -128 || result > 127)
         fetcher.die("branch destination out of reach");
      return result;
   } else {
      xref.addreference(r);
      return 0x00; // return padding.
   }
}

void tasm::getorg(void) {
  stripComment();
  fetcher.expandTabs(8);

  if (isLabelName()) {
    getLabel();
    fetcher.matchWhitespace();
    if (!fetcher.skipKeyword(directives))
       fetcher.die("\".org\" or \".equ\" expected");
    if (strcmp(directives[fetcher.keyID],".equ"))
       fetcher.die("\".equ\" expected");
 
    fetcher.skipWhitespace();
    getLabelEquivalence(labelname);
    fetcher.matcheol();
    fetcher.colnum = 0;
    return;
  }

  fetcher.skipWhitespace();
  if (fetcher.iseol() || fetcher.isChar(';')) {
    fetcher.colnum = 0;
    return;
  }

  if (fetcher.skipKeyword(directives))
    if (!strcmp(directives[fetcher.keyID],".msfirst")) {
      fetcher.colnum = 0;
      return;
    } else if (!strcmp(directives[fetcher.keyID],".org")) {
      fetcher.matchWhitespace();
      pc = getWord();
      archiver.pc.end()[-1] = pc;
    } else
      fetcher.die("unexpected or unsupported directive");
  else
    fetcher.die("assembly must start with \".org\" directive"); 
  
  fetcher.colnum = 0;
}

void tasm::stripComment(void) {
  bool squote = false;
  bool dquote = false;

  for (char *c = fetcher.peekLine(); *c != '\n'; ++c) {
    squote ^= !dquote && *c == '\'';
    dquote ^= !squote && *c == '"';
    if (!squote && !dquote && *c==';') {
       *c++ = '\n';
       *c = '\0';
       return;
    }
  }
}

bool tasm::checkIndexed() {
   if (!(fetcher.skipChar(',')))
      return false;

   fetcher.skipWhitespace();

   if (!fetcher.skipChar('x'))
      fetcher.matchChar('X');
   
   return true;
}

void tasm::doAssembly(void) {
   fetcher.skipWhitespace();
   if (!fetcher.skipKeyword(mnemonics))
      fetcher.die("assembly instruction expected");

   int opcode = fetcher.keyID;

   // handle aliases
   opcode = opcode == 0x91 ? 0x24 :
            opcode == 0x92 ? 0x25 :
            opcode == 0x93 ? 0x05 :
            opcode == 0x94 ? 0x48 :
            opcode == 0x95 ? 0x58 :
                             opcode;

   // inherent   
   if (opcode<0x20 || (opcode>0x2f && opcode<0x60)) {
      writeByte(opcode);
      fetcher.matcheol();
      return;
   } 

   fetcher.matchWhitespace();

   // immediate
   if (fetcher.skipChar('#')) {
      int nibble = opcode&0xf;
      if (opcode < 0x70 || nibble==0x7 || nibble==0xd || nibble==0xf)
         fetcher.die("instruction does not support immediate mode");
      int w = getExpression(0);
      writeByte(opcode + (opcode<0x80 ? 0x10 : 0x40));
      if (nibble==0x3 || nibble==0xc || nibble==0xe)
         writeWord(w);
      else
         writeByte(w);
      fetcher.matcheol();
      return;
   }

   // relative branch
   if (opcode < 0x30 || opcode == 0x90) {
      opcode = opcode == 0x90 ? 0x8d : opcode; // handle BSR
      int w = getRelativeExpression();
      writeByte(opcode);
      writeByte(w);
      fetcher.matcheol();
      return;
   }

   // is forced extended?
   bool isForcedExtended = fetcher.skipChar('>');
   bool isIndexed = false;
   int w = 0;

   if (isForcedExtended) {
      w = getExpression(0);
   } else {
      // get operand and indexed status
      isIndexed = checkIndexed();
      if (!isIndexed) {
        w = getExpression(0);
        fetcher.skipWhitespace();
        isIndexed = checkIndexed();
      }
   }
   fetcher.matcheol();

   // indexed
   if (isIndexed) {
      writeByte(opcode + (opcode<0x70 ? 0x00 :
                          opcode<0x80 ? 0x30 :
                                        0x60));
      writeByte(w);
      return;
   }

   // force extended for single ops (inc, dec, etc.)
   if (opcode < 0x70) {
      writeByte(opcode + 0x10);
      writeWord(w);
      return;
   } 

   // if resolvable to a byte...
   if (!isForcedExtended && -128 <= w && w < 256) {
      // direct
      writeByte(opcode + (opcode < 0x80 ? 0x20 : 0x50));
      writeByte(w);
   } else {
      // force extended
      writeByte(opcode + (opcode<0x70 ? 0x10 :
                          opcode<0x80 ? 0x40 :
                                        0x70));
      writeWord(w);
   }
}

void tasm::doBlock(void) {
   fetcher.matchWhitespace();
   int repeat;
   std::string offender;
   if (!getReferenceNow(repeat, offender))
      fetcher.die(".block argument must be immediately resolvable");
   fetcher.matcheol();
   pc += repeat;
}

void tasm::doFill(void) {
   fetcher.matchWhitespace();
   int repeat;
   std::string offender;
   if (!getReferenceNow(repeat, offender))
      fetcher.die(".fill argument must be immediately resolvable");
   fetcher.skipWhitespace();
   if (fetcher.skipChar(',')) {
      fetcher.skipWhitespace();
      int w;
      if (!getReferenceNow(w, offender))
         fetcher.die(".fill argument must be immediately resolvable");
      while (repeat--)
        writeByte(w);
   } else {
      while (repeat--)
        writeByte(0);
   }
   fetcher.matcheol();
}

void tasm::doText(void) {
   fetcher.matchWhitespace();
   fetcher.matchChar('"');
   while (!fetcher.skipChar('"') && !fetcher.iseol())
      writeByte(fetcher.getQuotedLiteral());

   fetcher.matcheol();
}

void tasm::doByte(void) {
   fetcher.matchWhitespace();
   do {
     if (fetcher.skipChar('"'))
       while (!fetcher.skipChar('"') && !fetcher.iseol())
          writeByte(fetcher.getChar());
     else if (fetcher.skipChar('\'')) {
          writeByte(fetcher.getQuotedLiteral());
          fetcher.matchChar('\'');
     } else
        writeByte(getExpression(1));
     fetcher.skipWhitespace();
   } while (fetcher.skipChar(',') && !fetcher.isBlankLine());
   fetcher.matcheol();
}

void tasm::doWord(void) {
   fetcher.matchWhitespace();
   do {
      writeWord(getExpression(2));
      fetcher.skipWhitespace();
   } while (fetcher.skipChar(',') && !fetcher.isBlankLine());
   fetcher.matcheol();
}

void tasm::doEnd(void) {
   endReached = true;
}

void tasm::doExecStart(void) {
   if (execstart)
      fetcher.die("EXEC address cannot be reset.  (previous address = $%x)",execstart);

   execstart = pc;
   fetcher.matcheol();
}

void tasm::doOrg(void) {
   fetcher.matchWhitespace();
   pc = getWord();
   fetcher.matcheol();
   archiver.pc.end()[-1] = pc;
}


void tasm::doModule(void) {
   char n;
   char *m = modulename;
   fetcher.matchWhitespace();
   while (fetcher.isAlnum()) {
     *m++ = fetcher.getChar();
     if (++n >= MAXLABELLEN)
        fetcher.die("module has too many characters");
   }
   *m = '\0';
   fetcher.matcheol();
}

void tasm::doMSFirst(void) {
   fetcher.matcheol();
}

void tasm::doDirective(void) {
   if (!strcmp(directives[fetcher.keyID],".module"))
      doModule();
   else if (!strcmp(directives[fetcher.keyID],".execstart"))
      doExecStart();
   else if (!strcmp(directives[fetcher.keyID],".end"))
      doEnd();
   else if (!strcmp(directives[fetcher.keyID],".org"))
      doOrg();
   else if (!strcmp(directives[fetcher.keyID],".block"))
      doBlock();
   else if (!strcmp(directives[fetcher.keyID],".fill"))
      doFill();
   else if (!strcmp(directives[fetcher.keyID],".byte"))
      doByte();
   else if (!strcmp(directives[fetcher.keyID],".word"))
      doWord();
   else if (!strcmp(directives[fetcher.keyID],".text"))
      doText();
   else if (!strcmp(directives[fetcher.keyID],".msfirst"))
      doMSFirst();
   else
      fetcher.die("unexpected directive");
}

void tasm::getLabel(void) {
   char c;
   int n = 0;
   char *l = labelname;
   while (isalnum(c=fetcher.peekChar()) || c=='_') {
     fetcher.matchChar(c);
     *l++ = c;
     if (++n >= MAXLABELLEN)
        fetcher.die("label has too many characters");
   }
   *l = '\0';
}

void tasm::doLabel(void) {
   getLabel();

   if (fetcher.isBlankLine()) {
      xref.addlabel(modulename,labelname,pc);
      return;
   }

   if (!fetcher.skipChar(':'))
      fetcher.matchWhitespace();
   else if (fetcher.isBlankLine()) {
      xref.addlabel(modulename,labelname,pc);
      return;
   } 

   fetcher.skipWhitespace();

   if (fetcher.skipKeyword(directives))
      if (!strcmp(directives[fetcher.keyID],".equ")) {
         fetcher.skipWhitespace();
         getLabelEquivalence(labelname);
         fetcher.matcheol();
      } else if (!strcmp(directives[fetcher.keyID],".module")) {
         doModule();
         xref.addlabel(modulename,labelname,pc);
         fetcher.matcheol();
      } else {
      xref.addlabel(modulename,labelname,pc);
      doDirective();
   } else {
      xref.addlabel(modulename,labelname,pc);
      doAssembly();
   }
}

void tasm::process(void) {
   stripComment();
   fetcher.expandTabs(8);
   if (endReached && !fetcher.isBlankLine())
      fetcher.die("unexpected input beyond .end");

   if (isLabelName()) {
       doLabel();
       return;
   }
   
   fetcher.skipWhitespace();
   if (fetcher.skipKeyword(directives))
       doDirective();
   else if (!fetcher.isBlankLine())
       doAssembly();
}

void tasm::failReference(int endpc)
{
  logger.init();
  logger.write(archiver.lines, archiver.pc, startpc, endpc, binary, nbytes);
  exit(1);
}

void tasm::resolveReferences(void) {
   for (int i=0; i<xref.references.size(); i++) {
      reference &r = xref.references[i];
      int result;
      std::string offender;
      if (!xref.resolve(r, result, offender))
         fprintf(stderr,"label \"%s\" is unresolved at %04x\n",offender.c_str(),r.location);
      if (r.reftype == 0) {
         int refbyte = r.location - startpc;
         if (refbyte < 0 || refbyte > nbytes) {
            fprintf(stderr,"reference at %04x (%i)  is out of range of binary\n",r.location, result);
            failReference(r.location);
         }
         int opcode = binary[refbyte];
         if (opcode < 0x20 || (opcode >= 0x30 && opcode < 0x60)) {
            fprintf(stderr,"internal error: reference at %04x with argument %i for an inherent instruction: %02x\n",
                    r.location, result, opcode);
            failReference(r.location);
         } else if (opcode < 0x30 || opcode == 0x8d) {
            result -= r.location + 2;
            if (result < -128 || result > 127) {
               fprintf(stderr,"branch destination %4x at %04x out of range\n",result + r.location + 1, r.location);
               failReference(r.location);
            }
            binary[r.location - startpc + 1] = result & 0xff;
         } else if ((opcode & 0x30) == 0x20) {
            if (result<0 || result>255) {
               fprintf(stderr,"result %i for indexed instruction %02x at %04x is out of range 0-255\n",
                       result, opcode, r.location);
               failReference(r.location);
            }
            binary[r.location - startpc + 1] = result & 0xff;
         } else if ((opcode & 0x30) == 0x10) {
            if (result<0 || result>255) {
              fprintf(stderr,"result %i for direct instruction %02x at %04x is out of range 0-255\n",
                      result, opcode, r.location);
              failReference(r.location);
            }
            binary[r.location - startpc + 1] = result & 0xff;
         } else if ((opcode & 0x30) == 0x30) {
            if (result < 0 || result > 65535) {
               fprintf(stderr,"result %i for extended instruction %02x at %04x is out of range 0-65535\n",
                       result, opcode, r.location);
               failReference(r.location);
            }
            binary[r.location - startpc + 1] = (result >> 8)  & 0xff;
            binary[r.location - startpc + 2] = result & 0xff;
         } else if ((opcode & 0xf) == 0x3 || (opcode & 0xf) == 0xC || (opcode & 0xf) == 0xE) {
            if (result < -32768 || result > 65535) {
               fprintf(stderr,"result %i for immediate instruction %02x at %04x is out of range [-32768,65535]\n",
                       result, opcode, r.location);
               failReference(r.location);
            }
            binary[r.location - startpc + 1] = (result >> 8)  & 0xff;
            binary[r.location - startpc + 2] = result & 0xff;
         } else {
            if (result < -128 || result > 255) {
               fprintf(stderr,"result %i for immediate instruction %02x at %04x is out of range [-128,255]\n",
                       result, opcode, r.location);
               failReference(r.location);
            }
            binary[r.location - startpc + 1] = result & 0xff;
         }
      } else if (r.reftype == 1) {
        if (result < -128 || result > 255) {
           fprintf(stderr,".byte reference %i at %04x is out of range.\n",result,r.location);
           failReference(r.location);
        }
        binary[r.location - startpc] = result & 0xff;
      } else if (r.reftype == 2) {
        if (result < -32768 || result > 65535) {
           fprintf(stderr,".word reference %i at %04x is out of range.\n",result,r.location);
           failReference(r.location);
        }
        binary[r.location - startpc] = (result >> 8) & 0xff;
        binary[r.location - startpc + 1] = result & 0xff;
      }
   }
}

int tasm::execute(void) {
  while (!pc && fetcher.getLine()) {
    archiver.push_back(fetcher.peekLine(),pc);
    getorg();
  }

  while (fetcher.getLine()) {
    archiver.push_back(fetcher.peekLine(),pc);
    process();
  }

  resolveReferences();

  logger.init();
  logger.write(archiver.lines, archiver.pc, startpc, pc, binary, nbytes);
  logger.write(binary,nbytes);
  logger.write(binary,nbytes,startpc,execstart);

  return 0;
}

