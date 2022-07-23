// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm.hpp"
#include "string.h"

static const char *mnemonics[]={
    /*00*/ ".CLB","NOP","SEX",".SETA","LSRD","LSLD","TAP","TPA",
    /*08*/ "INX","DEX","CLV","SEV", "CLC","SEC","CLI","SEI",
    /*10*/ "SBA","CBA",".12",".13",".14",".15", "TAB","TBA",
    /*18*/ ".18","DAA",".1A","ABA",".1C",".1D",".1E",".1F",
    /*20*/ "BRA","BRN","BHI","BLS","BHS","BLO","BNE","BEQ",
    /*28*/ "BVC","BVS","BPL","BMI","BGE","BLT","BGT","BLE",
    /*30*/ "TSX","INS","PULA","PULB","DES","TXS","PSHA","PSHB",
    /*38*/ "PULX","RTS","ABX","RTI","PSHX","MUL","WAI","SWI",
    /*40*/ "NEGA",".TSTA","NGCA","COMA","LSRA",".LSRA","RORA","ASRA",
    /*48*/ "LSLA","ROLA","DECA",".DECA","INCA","TSTA",".TA","CLRA",
    /*50*/ "NEGB",".TSTB","NGCB","COMB","LSRB",".LSRB","RORB","ASRB",
    /*58*/ "LSLB","ROLB","DECB",".DECB","INCB","TSTB",".TB","CLRB",
    /*60*/ "NEG",".TST","NGC","COM","LSR",".LSR","ROR","ASR",
    /*68*/ "LSL","ROL","DEC",".DEC","INC","TST","JMP","CLR",
    /*70*/ "SUBA","CMPA","SBCA","SUBD","ANDA","BITA","LDAA","STAA",
    /*78*/ "EORA","ADCA","ORAA","ADDA","CPX","JSR","LDS","STS",
    /*80*/ "SUBB","CMPB","SBCB","ADDD","ANDB","BITB","LDAB","STAB",
    /*88*/ "EORB","ADCB","ORAB","ADDB","LDD", "STD","LDX","STX",
    /*90*/ "BSR","BCC","BCS","ASLD","ASLA","ASLB","ASL",0};

static const char *macros[]={"#define",0};
static const char *directives[]={".msfirst",".org",".execstart",".end",".equ",".module",".text",".strs",".strz",".byte",".word",".fill",".block",0};
static const char *pseudo_ops[]={".msfirst","org",".execstart","end","equ",".module","fcc","fcs","fcn","fcb","fdb","rzb","rmb",0};

void Tasm::processOpts(void)
{
   argcnt = 1;
   wUnused = false;
   while (argcnt < argc_ && !strncmp(argv_[argcnt],"-",1) && strcmp(argv_[argcnt],"--")) {
      wUnused |= !strcmp(argv_[argcnt],"-Wunused");
      wBranch |= !strcmp(argv_[argcnt],"-Wbranch");
      argcnt++;
   }

   if (argcnt < argc_ && !strcmp(argv_[argcnt],"--"))
      argcnt++;
}

void Tasm::validateObj()
{
   if (!nbytes) {
      startpc = pc;
      if (!startpc) {
         fetcher.colnum = 0;
         fetcher.die(".org directive missing before this line");
      }
   } else {
      int bytesMissing = pc - (startpc + nbytes);
      if (bytesMissing < 0) 
         fetcher.die("object binary pc ($%04X) out of sync with pc ($%04X)",startpc+nbytes,pc);
      else if (bytesMissing > 0) {
         while (bytesMissing--)
            binary[nbytes++] = 0;
      }
   }
}

void Tasm::writeByte(int b)
{
   if (b<-128 || b>255) 
      fetcher.die("result %i is out of range of a byte",b);

   validateObj();

   b &= 0xff;
   binary[nbytes++] = static_cast<unsigned char>(b);
   pc ++;
}

void Tasm::writeWord(int w)
{
   if (w < -32768 || w > 65535) 
      fetcher.die("result %i is out of range of a word",w);

   validateObj();

   w &= 0xffff;
   binary[nbytes++] = static_cast<unsigned char>(w>>8);
   binary[nbytes++] = static_cast<unsigned char>(w&0xff);
   pc += 2;
}

bool Tasm::isLabelName(void) {
   return fetcher.isAlpha() || fetcher.isChar('_');
}

void Tasm::getLabelName(void) {
   int n = 0;
   char *l = labelname;
   while (fetcher.isAlnum() || fetcher.isChar('_')) {
     *l++ = fetcher.getChar();
     if (++n >= MAXLABELLEN)
        fetcher.die("label has too many characters");
   }
   *l = '\0';
}

void Tasm::addLabel(const char *modulename, const char *labelname, int location, char *filename, int linenum) {
  if (!xref.addlabel(modulename, labelname, location, filename, linenum)) {
    fetcher.die("label \"%s\" redefined", labelname);
  }
}

void Tasm::addLabel(Label lbl) {
  if (!xref.addlabel(lbl)) {
    fetcher.die("label \"%s\" redefined", lbl.name.c_str());
  }
}

void Tasm::addModule(const char *modulename, char *filename, int linenum) {
  if (!xref.addmodule(modulename, filename, linenum)) {
    fetcher.die("module \"%s\" redefined", modulename);
  }
}


bool Tasm::processInherent(int opcode)
{
   if (opcode<0x20 || (opcode>0x2f && opcode<0x60)) {
      writeByte(opcode);
      return true;
   } 

   return false;
}
   
bool Tasm::processImmediate(int opcode)
{
   if (fetcher.skipChar('#')) {
      int nibble = opcode&0xf;

      if (opcode < 0x70 || nibble==0x7 || nibble==0xd || nibble==0xf)
         fetcher.die("instruction does not support immediate mode");

      writeByte(opcode + (opcode<0x80 ? 0x10 : 0x40));

      if (nibble==0x3 || nibble==0xc || nibble==0xe) 
         writeWord(xref.tentativelyResolve(2,fetcher,modulename,pc-1,fetcher.currentFilename(),fetcher.linenum,wBranch));
      else
         writeByte(xref.tentativelyResolve(1,fetcher,modulename,pc-1,fetcher.currentFilename(),fetcher.linenum,wBranch));

      return true;
   }

   return false;
}

bool Tasm::processRelative(int opcode)
{
   if (opcode < 0x30 || opcode == 0x90) {
      opcode = opcode == 0x90 ? 0x8d : opcode; // handle BSR
      writeByte(opcode);
      writeByte(xref.tentativelyResolve(0,fetcher,modulename,pc-1,fetcher.currentFilename(),fetcher.linenum,wBranch));
      return true;
   }
   return false;
}

bool Tasm::processForcedExtended(int opcode)
{
   if (fetcher.skipChar('>')) {
      opcode += opcode<0x70 ? 0x10 :
                opcode<0x80 ? 0x40 :
                              0x70;
      int refType = opcode == 0x7e ? 3 :
                              0xbd ? 4 :
                              2;
      int address = xref.tentativelyResolve(refType,fetcher,modulename,pc-1,fetcher.currentFilename(),fetcher.linenum,wBranch);
      writeByte(opcode);
      writeWord(address);
      return true;
   }

   return false;
}

bool Tasm::checkIndexed() {
   if (!(fetcher.skipChar(',')))
      return false;

   fetcher.skipWhitespace();

   if (!fetcher.skipChar('x'))
      fetcher.matchChar('X');
   
   return true;
}

void Tasm::doIndexed(int opcode, int offset) {
   opcode += opcode<0x70 ? 0x00 :
             opcode<0x80 ? 0x30 :
                           0x60;
   writeByte(opcode);
   writeByte(offset);
}

void Tasm::doDirect(int opcode, int address) {
   opcode += opcode < 0x80 ? 0x20 : 0x50;
   writeByte(opcode);
   writeByte(address);
}

void Tasm::doExtended(int opcode, int address) {
   opcode += opcode<0x70 ? 0x10 :
             opcode<0x80 ? 0x40 :
                           0x70;
   writeByte(opcode);
   writeWord(address);
}

void Tasm::doAssembly(void) {
   fetcher.skipWhitespace();
   if (!fetcher.skipKeyword(mnemonics))
      fetcher.die("assembly instruction expected");

   archive.validate();

   int opcode = fetcher.keyID;

   // handle aliases
   opcode = opcode == 0x91 ? 0x24 :
            opcode == 0x92 ? 0x25 :
            opcode == 0x93 ? 0x05 :
            opcode == 0x94 ? 0x48 :
            opcode == 0x95 ? 0x58 :
            opcode == 0x96 ? 0x68 :
                             opcode;

   if (processInherent(opcode)) {
      fetcher.matcheol();
      return;
   }

   fetcher.matchWhitespace();

   if (processImmediate(opcode) ||
       processRelative(opcode)  ||
       processForcedExtended(opcode)) { 
      fetcher.matcheol();
      return;
   }

   if (checkIndexed()) {
      doIndexed(opcode, 0);
      fetcher.matcheol();
      return;
   }

   // tentatively get reference with two bytes
   int reftype = opcode == 0x6e ? 3 :
                 opcode == 0x7d ? 4 :
                                  2;

   Reference r(pc, reftype, fetcher.currentFilename(), fetcher.linenum);
   r.expression.parse(fetcher, modulename, pc);
   fetcher.skipWhitespace();

   if (checkIndexed()) {
      r.reftype = 1; // only one byte required
      doIndexed(opcode, xref.tentativelyResolve(r, fetcher, wBranch));
      fetcher.matcheol();
      return;
   }

   int address = xref.tentativelyResolve(r, fetcher, wBranch);

   if (opcode < 0x70 || address < -128 || 255 < address) {
      // 0xdead or other 16-bit address
      doExtended(opcode, address);
   } else {
      // was immedately resolved to a single-byte address
      doDirect(opcode, address);
   }

   fetcher.matcheol();
   return;
}

void Tasm::doBlock(void) {
   fetcher.matchWhitespace();
   pc += xref.immediatelyResolve(-1, fetcher, modulename, pc, ".block", fetcher.currentFilename(), fetcher.linenum);
   fetcher.matcheol();
   archive.validate();
}

void Tasm::doFill(void) {
   fetcher.matchWhitespace();
   int repeat = xref.immediatelyResolve(-1, fetcher, modulename, pc, ".fill", fetcher.currentFilename(), fetcher.linenum);
   fetcher.skipWhitespace();
   if (fetcher.skipChar(',')) {
      fetcher.skipWhitespace();
      int w = xref.immediatelyResolve(-1, fetcher, modulename, pc, ".fill", fetcher.currentFilename(), fetcher.linenum);
      while (repeat--)
        writeByte(w);
   } else {
      while (repeat--)
        writeByte(0);
   }
   fetcher.matcheol();
   archive.validate();
}

void Tasm::doText(void) {
   fetcher.matchWhitespace();
   do {
     fetcher.skipWhitespace();
     char delim = fetcher.peekChar();
     if (fetcher.isQuotedChar() || (delim != '\'' && delim != '"')) {
        writeByte(xref.tentativelyResolve(-1,fetcher,modulename,pc,fetcher.currentFilename(),fetcher.linenum,wBranch));
     } else {
        fetcher.matchChar(delim);
        while (!fetcher.isChar(delim) && !fetcher.iseol())
           writeByte(static_cast<unsigned char>(fetcher.getEscapedChar()));
        fetcher.matchChar(delim);
     }
     fetcher.skipWhitespace();
   } while (fetcher.skipChar(',') && !fetcher.isBlankLine());
   fetcher.matcheol();
   archive.validate();
}

void Tasm::doNString(void) {
   fetcher.matchWhitespace();
   char delim = fetcher.peekChar();
   if (!fetcher.skipChar('\''))
      fetcher.matchChar('"');
   while (!fetcher.isChar(delim) && !fetcher.iseol()) {
      unsigned char c = static_cast<unsigned char>(fetcher.getEscapedChar());
      if (fetcher.isChar(delim))
         c |= 128;
      writeByte(c);
   }
   fetcher.matchChar(delim);
   fetcher.matcheol();
   archive.validate();
}

void Tasm::doCString(void) {
   doText();
   writeByte(0);
}

void Tasm::doByte(void) {
   doText();
}

void Tasm::doWord(void) {
   fetcher.matchWhitespace();
   do {
      writeWord(xref.tentativelyResolve(-2,fetcher,modulename,pc,fetcher.currentFilename(),fetcher.linenum,wBranch));
      fetcher.skipWhitespace();
   } while (fetcher.skipChar(',') && !fetcher.isBlankLine());
   fetcher.matcheol();
   archive.validate();
}

void Tasm::doEnd(void) {
   endReached = true;
   if (!fetcher.isBlankLine()) {
       fetcher.skipWhitespace();
       execstart = xref.immediatelyResolve(-1, fetcher, modulename, pc, ".end", fetcher.currentFilename(), fetcher.linenum);
   }
}

void Tasm::doExecStart(void) {
   if (execstart)
      fetcher.die("EXEC address cannot be reset.  (previous address = $%x)",execstart);

   execstart = pc;
   fetcher.matcheol();
}

void Tasm::doOrg(void) {
   fetcher.matchWhitespace();
   archive.pc.back() = pc = xref.immediatelyResolve(-1, fetcher, modulename, pc, ".org", fetcher.currentFilename(), fetcher.linenum);
   fetcher.matcheol();
}


void Tasm::doModule(void) {
   int n = 0;
   char *m = modulename;
   fetcher.matchWhitespace();
   if (!fetcher.isAlpha())
     fetcher.die("module name must begin with an alphabetical character");
   
   while (fetcher.isAlnum() || fetcher.isChar('_')) {
     *m++ = fetcher.getChar();
     if (++n >= MAXLABELLEN)
        fetcher.die("module has too many characters");
   }
   *m = '\0';
   fetcher.matcheol();
   addModule(modulename,fetcher.currentFilename(),fetcher.linenum);
}

void Tasm::doMSFirst(void) {
   fetcher.matcheol();
}

void Tasm::doDirective(void) {
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
   else if (!strcmp(directives[fetcher.keyID],".strs"))
      doNString();
   else if (!strcmp(directives[fetcher.keyID],".strz"))
      doCString();
   else if (!strcmp(directives[fetcher.keyID],".msfirst"))
      doMSFirst();
   else
      fetcher.die("unexpected directive");
}

void Tasm::doEqu(void) {
   Label l(modulename, labelname, fetcher.currentFilename(), fetcher.linenum);
   l.expression.parse(fetcher, modulename, pc);
   addLabel(l);
}

void Tasm::doLabel(void) {
   getLabelName();

   if (fetcher.isBlankLine()) {
      addLabel(modulename,labelname,pc,fetcher.currentFilename(),fetcher.linenum);
      archive.validate();
      return;
   }

   if (!fetcher.skipChar(':'))
      fetcher.matchWhitespace();
   else if (fetcher.isBlankLine()) {
      addLabel(modulename,labelname,pc,fetcher.currentFilename(),fetcher.linenum);
      archive.validate();
      return;
   } 

   fetcher.skipWhitespace();

   if (fetcher.skipKeyword(directives) || fetcher.skipKeyword(pseudo_ops))
      if (!strcmp(directives[fetcher.keyID],".equ")) {
         fetcher.skipWhitespace();
         doEqu();
         fetcher.matcheol();
      } else if (!strcmp(directives[fetcher.keyID],".module")) {
         doModule();
         addLabel(modulename,labelname,pc,fetcher.currentFilename(),fetcher.linenum);
         fetcher.matcheol();
      } else if (!strcmp(directives[fetcher.keyID],".org")) {
         doOrg();
         addLabel(modulename,labelname,pc,fetcher.currentFilename(),fetcher.linenum);
         fetcher.matcheol();
      } else {
         addLabel(modulename,labelname,pc,fetcher.currentFilename(),fetcher.linenum);
         doDirective();
   } else {
      addLabel(modulename,labelname,pc,fetcher.currentFilename(),fetcher.linenum);
      doAssembly();
   }
}

void Tasm::stripComment(void) {
  bool squote = false;
  bool dquote = false;

  // strip #defines or leading * comments
  int savecol = fetcher.colnum;
  fetcher.skipWhitespace();
  if (fetcher.isChar('*') || fetcher.isChar('#'))
     *fetcher.peekLine() = '\n';
  fetcher.colnum = savecol;

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

void Tasm::process(void) {
   stripComment();
   fetcher.expandTabs(8);
   macro.process(fetcher,macros);
   if (endReached && !fetcher.isBlankLine())
      fetcher.die("unexpected input beyond .end");

   if (isLabelName()) {
       doLabel();
       return;
   }
   
   fetcher.skipWhitespace();
   if (fetcher.skipKeyword(directives) || fetcher.skipKeyword(pseudo_ops))
       doDirective();
   else if (!fetcher.isBlankLine())
       doAssembly();
}

void Tasm::failReference(int endpc)
{
  log.init();
  log.writeLst(archive, startpc, endpc, binary, nbytes);
  exit(1);
}

void Tasm::resolveReferences(void) {
  int failpc;
  if (!xref.resolveReferences(startpc, binary, failpc, wBranch))
     failReference(failpc);

  if (wUnused)
     xref.reportUnusedReferences();
}


int Tasm::execute(void) {
  while (fetcher.getLine()) {
    archive.push_back(fetcher.peekLine(),pc);
    process();
  }

  resolveReferences();

  log.init();
  log.writeLst(archive, startpc, pc, binary, nbytes);
  log.writeObj(binary,static_cast<std::size_t>(nbytes));
  log.writeC10(binary,static_cast<std::size_t>(nbytes),startpc,execstart);

  return 0;
}

