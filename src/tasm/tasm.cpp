// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "tasm.hpp"
#include <cstring>

static const char *const mnemonics[] = {
    /* 00 */ ".CLB", "NOP",   "SEX",  ".SETA",
    /* 04 */ "LSRD", "LSLD",  "TAP",  "TPA",
    /* 08 */ "INX",  "DEX",   "CLV",  "SEV",
    /* 0C */ "CLC",  "SEC",   "CLI",  "SEI",
    /* 10 */ "SBA",  "CBA",   ".12",  ".13",
    /* 14 */ ".14",  ".15",   "TAB",  "TBA",
    /* 18 */ ".18",  "DAA",   ".1A",  "ABA",
    /* 1C */ ".1C",  ".1D",   ".1E",  ".1F",
    /* 20 */ "BRA",  "BRN",   "BHI",  "BLS",
    /* 24 */ "BHS",  "BLO",   "BNE",  "BEQ",
    /* 28 */ "BVC",  "BVS",   "BPL",  "BMI",
    /* 2C */ "BGE",  "BLT",   "BGT",  "BLE",
    /* 30 */ "TSX",  "INS",   "PULA", "PULB",
    /* 34 */ "DES",  "TXS",   "PSHA", "PSHB",
    /* 38 */ "PULX", "RTS",   "ABX",  "RTI",
    /* 3C */ "PSHX", "MUL",   "WAI",  "SWI",
    /* 40 */ "NEGA", ".TSTA", "NGCA", "COMA",
    /* 44 */ "LSRA", ".LSRA", "RORA", "ASRA",
    /* 48 */ "LSLA", "ROLA",  "DECA", ".DECA",
    /* 4C */ "INCA", "TSTA",  ".TA",  "CLRA",
    /* 50 */ "NEGB", ".TSTB", "NGCB", "COMB",
    /* 54 */ "LSRB", ".LSRB", "RORB", "ASRB",
    /* 58 */ "LSLB", "ROLB",  "DECB", ".DECB",
    /* 5C */ "INCB", "TSTB",  ".TB",  "CLRB",
    /* 60 */ "NEG",  ".TST",  "NGC",  "COM",
    /* 64 */ "LSR",  ".LSR",  "ROR",  "ASR",
    /* 68 */ "LSL",  "ROL",   "DEC",  ".DEC",
    /* 6C */ "INC",  "TST",   "JMP",  "CLR",
    /* 70 */ "SUBA", "CMPA",  "SBCA", "SUBD",
    /* 74 */ "ANDA", "BITA",  "LDAA", "STAA",
    /* 78 */ "EORA", "ADCA",  "ORAA", "ADDA",
    /* 7C */ "CPX",  "JSR",   "LDS",  "STS",
    /* 80 */ "SUBB", "CMPB",  "SBCB", "ADDD",
    /* 84 */ "ANDB", "BITB",  "LDAB", "STAB",
    /* 88 */ "EORB", "ADCB",  "ORAB", "ADDB",
    /* 8C */ "LDD",  "STD",   "LDX",  "STX",
    /* 90 */ "BSR",  "BCC",   "BCS",  "ASLD",
    /* 94 */ "ASLA", "ASLB",  "ASL",  nullptr};

static const char *const macros[] = {"#define", nullptr};
static const char *const directives[] = {
    ".msfirst", ".org",  ".execstart", ".end",   ".equ",  ".module",
    ".text",    ".strs", ".strz",      ".byte",  ".word", ".bin",
    ".quat",    ".hex",  ".fill",      ".block", nullptr};
static const char *const pseudo_ops[] = {
    ".msfirst", "org", ".execstart", "end", "equ",  ".module",
    "fcc",      "fcs", "fcn",        "fcb", "fdb",  "bin",
    "quat",     "hex", "rzb",        "rmb", nullptr};

void Tasm::validateObj() {
  if (!nbytes) {
    startpc = pc;
    if (!startpc) {
      fetcher.setColumn(0);
      fetcher.die(".org directive missing before this line");
    }
  } else {
    int bytesMissing = pc - (startpc + nbytes);
    if (bytesMissing < 0) {
      fetcher.die("object binary pc ($%04X) out of sync with pc ($%04X)",
                  startpc + nbytes, pc);
    } else if (bytesMissing > 0) {
      while (bytesMissing--) {
        binary[nbytes++] = 0;
      }
    }
  }
}

void Tasm::writeByte(int b) {
  if (b < -128 || b > 255) {
    fetcher.die("result %i is out of range of a byte", b);
  }

  validateObj();

  b &= 0xff;
  binary[nbytes++] = static_cast<unsigned char>(b);
  pc++;
}

void Tasm::writeWord(int w) {
  if (w < -32768 || w > 65535) {
    fetcher.die("result %i is out of range of a word", w);
  }

  validateObj();

  w &= 0xffff;
  binary[nbytes++] = static_cast<unsigned char>(w >> 8);
  binary[nbytes++] = static_cast<unsigned char>(w & 0xff);
  pc += 2;
}

bool Tasm::isLabelName() { return fetcher.isAlpha() || fetcher.isChar('_'); }

void Tasm::getLabelName() {
  int n = 0;
  char *l = labelname;
  while (fetcher.isAlnum() || fetcher.isChar('_')) {
    *l++ = fetcher.getChar();
    if (++n >= MAXLABELLEN) {
      fetcher.die("label has too many characters");
    }
  }
  *l = '\0';
}

void Tasm::addLabel(const char *modulename, const char *labelname, int location,
                    const char *filename, int linenum) {
  if (!xref.addlabel(modulename, labelname, location, filename, linenum)) {
    fetcher.die("label \"%s\" redefined", labelname);
  }
}

void Tasm::addLabel(const Label &lbl) {
  if (!xref.addlabel(lbl)) {
    fetcher.die("label \"%s\" redefined", lbl.fullName.c_str());
  }
}

void Tasm::addModule(const char *modulename, const char *filename,
                     int linenum) {
  if (!xref.addmodule(modulename, filename, linenum)) {
    fetcher.die("module \"%s\" redefined", modulename);
  }
}

bool Tasm::processInherent(int opcode) {
  if (opcode < 0x20 || (opcode > 0x2f && opcode < 0x60)) {
    writeByte(opcode);
    return true;
  }

  return false;
}

bool Tasm::processImmediate(int opcode) {
  if (fetcher.skipChar('#')) {
    int nibble = opcode & 0xf;

    if (opcode < 0x70 || nibble == 0x7 || nibble == 0xd || nibble == 0xf) {
      fetcher.die("instruction does not support immediate mode");
    }

    writeByte(opcode + (opcode < 0x80 ? 0x10 : 0x40));

    if (nibble == 0x3 || nibble == 0xc || nibble == 0xe) {
      writeWord(xref.tentativelyResolve(
          2, fetcher, modulename, pc - 1, fetcher.getFilename(),
          fetcher.getLineNumber(), options.wBranch.isEnabled()));
    } else {
      writeByte(xref.tentativelyResolve(
          1, fetcher, modulename, pc - 1, fetcher.getFilename(),
          fetcher.getLineNumber(), options.wBranch.isEnabled()));
    }

    return true;
  }

  return false;
}

bool Tasm::processRelative(int opcode) {
  if (opcode < 0x30 || opcode == 0x90) {
    opcode = opcode == 0x90 ? 0x8d : opcode; // handle BSR
    writeByte(opcode);
    writeByte(xref.tentativelyResolve(
        0, fetcher, modulename, pc - 1, fetcher.getFilename(),
        fetcher.getLineNumber(), options.wBranch.isEnabled()));
    return true;
  }
  return false;
}

bool Tasm::processForcedExtended(int opcode) {
  if (fetcher.skipChar('>')) {
    opcode += opcode < 0x70 ? 0x10 : opcode < 0x80 ? 0x40 : 0x70;
    int refType = opcode == 0x7e ? 3 : opcode == 0xbd ? 4 : 2;
    int address = xref.tentativelyResolve(
        refType, fetcher, modulename, pc - 1, fetcher.getFilename(),
        fetcher.getLineNumber(), options.wBranch.isEnabled());
    writeByte(opcode);
    writeWord(address);
    return true;
  }

  return false;
}

bool Tasm::checkIndexed() {
  if (!(fetcher.skipChar(','))) {
    return false;
  }

  fetcher.skipWhitespace();

  if (!fetcher.skipChar('x')) {
    fetcher.matchChar('X');
  }

  return true;
}

void Tasm::doIndexed(int opcode, int offset) {
  opcode += opcode < 0x70 ? 0x00 : opcode < 0x80 ? 0x30 : 0x60;
  writeByte(opcode);
  writeByte(offset);
}

void Tasm::doDirect(int opcode, int address) {
  opcode += opcode < 0x80 ? 0x20 : 0x50;
  writeByte(opcode);
  writeByte(address);
}

void Tasm::doExtended(int opcode, int address) {
  opcode += opcode < 0x70 ? 0x10 : opcode < 0x80 ? 0x40 : 0x70;
  writeByte(opcode);
  writeWord(address);
}

void Tasm::doAssembly() {
  fetcher.skipWhitespace();
  if (!fetcher.skipKeyword(mnemonics)) {
    fetcher.die("assembly instruction expected");
  }

  archive.validate();

  int opcode = fetcher.lastKeyID();

  // handle aliases
  opcode = opcode == 0x91   ? 0x24
           : opcode == 0x92 ? 0x25
           : opcode == 0x93 ? 0x05
           : opcode == 0x94 ? 0x48
           : opcode == 0x95 ? 0x58
           : opcode == 0x96 ? 0x68
                            : opcode;

  if (processInherent(opcode)) {
    fetcher.matcheol();
    return;
  }

  fetcher.matchWhitespace();

  if (processImmediate(opcode) || processRelative(opcode) ||
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
  int reftype = opcode == 0x6e ? 3 : opcode == 0x7d ? 4 : 2;
  Reference r(pc, reftype, modulename, fetcher.getFilename(),
              fetcher.getLineNumber());
  r.expression.parse(fetcher, modulename, pc);
  fetcher.skipWhitespace();

  if (checkIndexed()) {
    r.reftype = 1; // only one byte required
    doIndexed(opcode,
              xref.tentativelyResolve(r, fetcher, options.wBranch.isEnabled()));
    fetcher.matcheol();
    return;
  }

  int address =
      xref.tentativelyResolve(r, fetcher, options.wBranch.isEnabled());

  if (opcode < 0x70 || address < -128 || 255 < address) {
    // 0xdead or other 16-bit address
    doExtended(opcode, address);
  } else {
    // was immedately resolved to a single-byte address
    doDirect(opcode, address);
  }

  fetcher.matcheol();
}

void Tasm::doBlock() {
  fetcher.matchWhitespace();
  pc += xref.immediatelyResolve(-1, fetcher, modulename, pc, ".block",
                                fetcher.getFilename(), fetcher.getLineNumber());
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doFill() {
  fetcher.matchWhitespace();
  int repeat =
      xref.immediatelyResolve(-1, fetcher, modulename, pc, ".fill",
                              fetcher.getFilename(), fetcher.getLineNumber());
  fetcher.skipWhitespace();
  if (fetcher.skipChar(',')) {
    fetcher.skipWhitespace();
    int w =
        xref.immediatelyResolve(-1, fetcher, modulename, pc, ".fill",
                                fetcher.getFilename(), fetcher.getLineNumber());
    while (repeat--) {
      writeByte(w);
    }
  } else {
    while (repeat--) {
      writeByte(0);
    }
  }
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doText() {
  fetcher.matchWhitespace();
  do {
    fetcher.skipWhitespace();
    char delim = fetcher.peekChar();
    if (fetcher.isQuotedChar() || (delim != '\'' && delim != '"')) {
      writeByte(xref.tentativelyResolve(
          -1, fetcher, modulename, pc, fetcher.getFilename(),
          fetcher.getLineNumber(), options.wBranch.isEnabled()));
    } else {
      fetcher.matchChar(delim);
      while (!fetcher.isChar(delim) && !fetcher.iseol()) {
        writeByte(static_cast<unsigned char>(fetcher.getEscapedChar()));
      }
      fetcher.matchChar(delim);
    }
    fetcher.skipWhitespace();
  } while (fetcher.skipChar(',') && !fetcher.isBlankLine());
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doNString() {
  fetcher.matchWhitespace();
  char delim = fetcher.peekChar();
  if (!fetcher.skipChar('\'')) {
    fetcher.matchChar('"');
  }
  while (!fetcher.isChar(delim) && !fetcher.iseol()) {
    auto c = static_cast<unsigned char>(fetcher.getEscapedChar());
    if (fetcher.isChar(delim)) {
      c |= 128;
    }
    writeByte(c);
  }
  fetcher.matchChar(delim);
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doCString() {
  doText();
  writeByte(0);
}

void Tasm::doByte() { doText(); }

void Tasm::doWord() {
  fetcher.matchWhitespace();
  do {
    writeWord(xref.tentativelyResolve(
        -2, fetcher, modulename, pc, fetcher.getFilename(),
        fetcher.getLineNumber(), options.wBranch.isEnabled()));
    fetcher.skipWhitespace();
  } while (fetcher.skipChar(',') && !fetcher.isBlankLine());
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doBin() {
  fetcher.matchWhitespace();
  do {
    int byte = fetcher.getPartialBinaryByte();
    writeByte(static_cast<unsigned char>(byte));
    fetcher.skipWhitespace();
  } while (!fetcher.isBlankLine());
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doQuat() {
  fetcher.matchWhitespace();
  do {
    int byte = fetcher.getPartialQuaternaryByte();
    writeByte(static_cast<unsigned char>(byte));
    fetcher.skipWhitespace();
  } while (!fetcher.isBlankLine());
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doHex() {
  fetcher.matchWhitespace();
  do {
    int byte = fetcher.getPartialHexadecimalByte();
    writeByte(static_cast<unsigned char>(byte));
    fetcher.skipWhitespace();
  } while (!fetcher.isBlankLine());
  fetcher.matcheol();
  archive.validate();
}

void Tasm::doEnd() {
  endReached = true;
  if (!fetcher.isBlankLine()) {
    fetcher.skipWhitespace();
    execstart =
        xref.immediatelyResolve(-1, fetcher, modulename, pc, ".end",
                                fetcher.getFilename(), fetcher.getLineNumber());
  }
}

void Tasm::doExecStart() {
  if (execstart) {
    fetcher.die("EXEC address cannot be reset.  (previous address = $%x)",
                execstart);
  }

  execstart = pc;
  fetcher.matcheol();
}

void Tasm::doOrg() {
  fetcher.matchWhitespace();
  archive.pc.back() = pc =
      xref.immediatelyResolve(-1, fetcher, modulename, pc, ".org",
                              fetcher.getFilename(), fetcher.getLineNumber());
  fetcher.matcheol();
}

void Tasm::doModule() {
  int n = 0;
  char *m = modulename;
  fetcher.matchWhitespace();
  if (!fetcher.isAlpha()) {
    fetcher.die("module name must begin with an alphabetical character");
  }

  while (fetcher.isAlnum() || fetcher.isChar('_')) {
    *m++ = fetcher.getChar();
    if (++n >= MAXLABELLEN) {
      fetcher.die("module has too many characters");
    }
  }
  *m = '\0';
  fetcher.matcheol();
  addModule(modulename, fetcher.getFilename(), fetcher.getLineNumber());
}

void Tasm::doMSFirst() { fetcher.matcheol(); }

void Tasm::doDirective() {
  if (!strcmp(directives[fetcher.lastKeyID()], ".module")) {
    doModule();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".execstart")) {
    doExecStart();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".end")) {
    doEnd();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".org")) {
    doOrg();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".block")) {
    doBlock();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".fill")) {
    doFill();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".byte")) {
    doByte();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".word")) {
    doWord();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".bin")) {
    doBin();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".quat")) {
    doQuat();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".hex")) {
    doHex();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".text")) {
    doText();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".strs")) {
    doNString();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".strz")) {
    doCString();
  } else if (!strcmp(directives[fetcher.lastKeyID()], ".msfirst")) {
    doMSFirst();
  } else {
    fetcher.die("unexpected directive");
  }
}

void Tasm::doEqu() {
  Label l(modulename, labelname, fetcher.getFilename(),
          fetcher.getLineNumber());
  l.expression.parse(fetcher, modulename, pc);
  addLabel(l);
}

void Tasm::doLabel() {
  getLabelName();

  if (fetcher.isBlankLine()) {
    addLabel(modulename, labelname, pc, fetcher.getFilename(),
             fetcher.getLineNumber());
    archive.validate();
    return;
  }

  if (!fetcher.skipChar(':')) {
    fetcher.matchWhitespace();
  } else if (fetcher.isBlankLine()) {
    addLabel(modulename, labelname, pc, fetcher.getFilename(),
             fetcher.getLineNumber());
    archive.validate();
    return;
  }

  fetcher.skipWhitespace();

  if (fetcher.skipKeyword(directives) || fetcher.skipKeyword(pseudo_ops)) {
    if (!strcmp(directives[fetcher.lastKeyID()], ".equ")) {
      fetcher.skipWhitespace();
      doEqu();
      fetcher.matcheol();
    } else if (!strcmp(directives[fetcher.lastKeyID()], ".module")) {
      doModule();
      addLabel(modulename, labelname, pc, fetcher.getFilename(),
               fetcher.getLineNumber());
      fetcher.matcheol();
    } else if (!strcmp(directives[fetcher.lastKeyID()], ".org")) {
      doOrg();
      addLabel(modulename, labelname, pc, fetcher.getFilename(),
               fetcher.getLineNumber());
      fetcher.matcheol();
    } else {
      addLabel(modulename, labelname, pc, fetcher.getFilename(),
               fetcher.getLineNumber());
      doDirective();
    }
  } else {
    addLabel(modulename, labelname, pc, fetcher.getFilename(),
             fetcher.getLineNumber());
    doAssembly();
  }
}

void Tasm::stripComment() {
  bool squote = false;
  bool dquote = false;

  // strip #defines or leading * comments
  int savecol = fetcher.getColumn();
  fetcher.skipWhitespace();
  if (fetcher.isChar('*') || fetcher.isChar('#')) {
    *fetcher.peekLine() = '\n';
  }
  fetcher.setColumn(savecol);

  for (char *c = fetcher.peekLine(); *c != '\0'; ++c) {
    squote ^= !dquote && *c == '\'';
    dquote ^= !squote && *c == '"';
    if (!squote && !dquote && *c == ';') {
      *c = '\0';
      return;
    }
  }
}

void Tasm::process() {
  stripComment();
  fetcher.expandTabs(8);
  macro.process(fetcher, macros);
  if (endReached && !fetcher.isBlankLine()) {
    fetcher.die("unexpected input beyond .end");
  }

  if (isLabelName()) {
    doLabel();
    return;
  }

  fetcher.skipWhitespace();
  if (fetcher.skipKeyword(directives) || fetcher.skipKeyword(pseudo_ops)) {
    doDirective();
  } else if (!fetcher.isBlankLine()) {
    doAssembly();
  }
}

void Tasm::resolveReferences() {
  int failpc = 0;
  if (!xref.resolveReferences(startpc, binary.data(), failpc,
                              options.wBranch.isEnabled())) {
    exit(1);
  }

  if (options.wUnused.isEnabled()) {
    xref.reportUnusedReferences();
  }

  if (options.wGlobal.isEnabled()) {
    xref.reportUnusedGlobalReferences();
  }
}

TasmObject Tasm::assemble() {
  while (fetcher.getLine()) {
    archive.push_back(fetcher.peekLine(), pc);
    process();
  }

  resolveReferences();

  return TasmObject{binary, nbytes, startpc, pc, execstart, archive, xref};
};

void Tasm::execute() {
  auto obj = assemble();
  writer.writeObj(obj);
  writer.writeC10(obj);
  writer.writeLst(obj);
  writer.writeGbl(obj);
  writer.writeSym(obj);
}
