// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "objwriter.hpp"
#include "utils/cstring.hpp"

#include <cstdlib>
#include <cstring>
#include <string>
#include <utility>
#include <vector>

void ObjWriter::initline(std::size_t n, int pc, int remaining) {
  if (options.compact.isEnabled() && remaining) {
    snprintf(output, BUFSIZ, " %04X | ", pc);
  } else if (options.compact.isEnabled()) {
    snprintf(output, BUFSIZ, "      | ");
  } else {
    snprintf(output, BUFSIZ, "%04lu   %04X ", n, pc);
  }
}

void ObjWriter::finish(const std::string &line) {
  std::size_t n = strlen(output);
  while (n < 24) { // 32 is arguably better
    output[n++] = ' ';
  }
  output[n] = '\0';
  fprintf(flist, "%s%s\n", output, line.c_str());
}

void ObjWriter::writeFmt(int count, const char *fmt, const std::string &line,
                         int &remaining, const unsigned char binary[],
                         int &byte, int &here) {
  while (remaining && count) {
    --remaining;
    --count;
    ++here;
    snprintf(scratch, BUFSIZ, fmt, binary[byte++]);
    if (utils::strlcat(output, scratch, BUFSIZ) > BUFSIZ) {
      fprintf(stderr, "%s: buffer overrun when writing format\n", progname);
    }
  }
  finish(line);
}

void ObjWriter::writeRemaining(std::size_t n, int &remaining,
                               const unsigned char binary[], int &byte,
                               int &here) {
  while (remaining) {
    initline(n + 1, here, remaining);
    if (options.compact.isEnabled()) {
      writeFmt(5, "%02X ", "", remaining, binary, byte, here);
    } else {
      writeFmt(8, "%02X", "", remaining, binary, byte, here);
    }
  }
}

void ObjWriter::writeLst(const TasmObject &obj) {

  if (options.lst.isEnabled()) {
    std::string filename = objfname;
    std::string head = filename.substr(0, filename.rfind('.'));
    filename = head + ".lst";

    flist = fopen(filename.c_str(), "w");

    if (!flist) {
      fprintf(stderr, "Couldn't open list file.\n");
      exit(1);
    }

    int here = obj.startpc;
    int byte = 0;

    int endpc = obj.endpc;
    if (endpc - obj.startpc >= obj.binsize) {
      endpc = obj.startpc + obj.binsize;
    }

    for (std::size_t n = 0; n < obj.archive.pc.size(); ++n) {

      int there = n < obj.archive.pc.size() - 1 ? obj.archive.pc[n + 1] : endpc;
      if (there > endpc) {
        there = endpc;
      }

      int remaining = there - here;
      if (remaining < 0) {
        remaining = 0;
      }

      initline(n + 1, obj.archive.pc[n], obj.archive.valid[n]);

      if (remaining > 0 && obj.archive.pc[n] != here) {
        finish(obj.archive.lines[n]);
        writeRemaining(n, remaining, obj.binary.data(), byte, here);
      } else if (options.compact.isEnabled() && remaining <= 5) {
        writeFmt(5, "%02X ", obj.archive.lines[n], remaining, obj.binary.data(),
                 byte, here);
      } else if (options.compact.isEnabled()) {
        writeFmt(5, "%02X ", obj.archive.lines[n], remaining, obj.binary.data(),
                 byte, here);
        writeRemaining(n, remaining, obj.binary.data(), byte, here);
      } else if (remaining <= 4) {
        writeFmt(4, "%02X ", obj.archive.lines[n], remaining, obj.binary.data(),
                 byte, here);
      } else {
        // 6 preserves tab spacing at the expense of eight-byte block alignment
        writeFmt(8, "%02X", obj.archive.lines[n], remaining, obj.binary.data(),
                 byte, here);
        writeRemaining(n, remaining, obj.binary.data(), byte, here);
      }
    }

    fclose(flist);
  }
}

void ObjWriter::writeObj(const TasmObject &obj) {
  if (options.obj.isEnabled()) {
    std::string filename = objfname;
    std::string head = filename.substr(0, filename.rfind('.'));
    filename = head + ".obj";

    if (FILE *fobj = fopen(filename.c_str(), "wb")) {
      fwrite(obj.binary.data(), 1, obj.binsize, fobj);
      fclose(fobj);
      return;
    }

    fprintf(stderr, "Couldn't open object file.\n");
    perror(filename.c_str());
    exit(1);
  }
}

void ObjWriter::writeC10(const TasmObject &obj) {

  if (options.c10.isEnabled()) {
    std::string filename = objfname;
    std::string head = filename.substr(0, filename.rfind('.'));
    filename = head + ".c10";

    fc10 = fopen(filename.c_str(), "wb");
    if (!fc10) {
      fprintf(stderr, "Couldn't open object file.\n");
      perror(filename.c_str());
      exit(1);
    }

    int exec_addr = obj.execstart;

    if (!exec_addr) {
      exec_addr = obj.startpc;
    }

    spitleader();
    filenameblock(objfname, exec_addr, obj.startpc);

    spitleader();

    std::size_t nbytes = obj.binsize;
    const unsigned char *binary = obj.binary.data();
    while (nbytes > 0) {
      std::size_t bufcnt = nbytes < 256 ? nbytes : 255;
      datablock(binary, bufcnt);
      binary += bufcnt;
      nbytes -= bufcnt;
    }

    eofblock();

    fclose(fc10);
  }
}

void ObjWriter::writeGbl(TasmObject &obj) {

  if (options.gbl.isEnabled()) {
    std::string filename = objfname;
    std::string head = filename.substr(0, filename.rfind('.'));
    filename = head + ".gbl";

    if (FILE *fgbl = fopen(filename.c_str(), "wb")) {
      for (const auto &i : obj.xref.globalTable()) {
        fprintf(fgbl, "%s\n", i.c_str());
      }

      fclose(fgbl);
      return;
    }

    fprintf(stderr, "Couldn't open global table file.\n");
    perror(filename.c_str());
    exit(1);
  }
}

void ObjWriter::writeSym(TasmObject &obj) {

  if (options.sym.isEnabled()) {
    std::string filename = objfname;
    std::string head = filename.substr(0, filename.rfind('.'));
    filename = head + ".sym";

    if (FILE *fsym = fopen(filename.c_str(), "wb")) {
      for (const auto &i : obj.xref.symbolTable()) {
        fprintf(fsym, "%s\n", i.c_str());
      }

      fclose(fsym);
      return;
    }

    fprintf(stderr, "Couldn't open symbol table file.\n");
    perror(filename.c_str());
    exit(1);
  }
}

void ObjWriter::putchar(unsigned char c) { fputc(c, fc10); }

void ObjWriter::putchk(unsigned char c) {
  putchar(c);
  chksum += c;
}

void ObjWriter::spitleader() {
  for (int i = 0; i < 128; i++) {
    putchar(0x55);
  }
}

void ObjWriter::spitblock(const unsigned char *buf, std::size_t buflen,
                          int blocktype) {
  putchar(0x55); // magic1
  putchar(0x3c); // magic2
  chksum = 0;
  putchk(static_cast<unsigned char>(blocktype)); // data block type
  putchk(static_cast<unsigned char>(buflen));    // data length
  for (std::size_t i = 0; i < buflen; i++) {
    putchk(buf[i]);
  }
  putchar(static_cast<unsigned char>(chksum & 0xff)); // checksum
  putchar(0x55);                                      // end of block
}

void ObjWriter::filenameblock(const char *filearg, int start_addr,
                              int load_addr) {
  unsigned char buf[15];
  std::string filename = filearg;
  std::size_t backs = filename.rfind('\\'); // dos
  std::size_t slash = filename.rfind('/');  // linux
  filename = filename.substr(
      backs == std::string::npos && slash == std::string::npos ? 0
      : backs == std::string::npos                             ? slash + 1
      : slash == std::string::npos                             ? backs + 1
      : backs > slash                                          ? backs + 1
                                                               : slash + 1,
      std::string::npos);

  filename = filename.substr(0, filename.rfind('.'));

  const char *fname = filename.c_str();

  std::size_t i = 0;
  for (i = 0; i < strlen(fname) && i < 8; i++) {
    buf[i] = static_cast<unsigned char>(toupper(fname[i]));
  }
  for (; i < 8; i++) {
    buf[i] = ' ';
  }

  buf[i++] = 0x02; // Machine language
  buf[i++] = 0x00; // continuous gap flag
  buf[i++] = 0x00; // continuous gap flag

  buf[i++] = static_cast<unsigned char>(start_addr >> 8);
  buf[i++] = static_cast<unsigned char>(start_addr & 0xff);

  buf[i++] = static_cast<unsigned char>(load_addr >> 8);
  buf[i++] = static_cast<unsigned char>(load_addr & 0xff);

  spitblock(buf, i, 0x00);
}

void ObjWriter::datablock(const unsigned char *buf, std::size_t bufcnt) {
  spitblock(buf, bufcnt, 0x01);
}

void ObjWriter::eofblock() { spitblock(nullptr, 0, 0xff); }
