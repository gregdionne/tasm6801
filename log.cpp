// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include <stdlib.h>
#include <vector>
#include <string>
#include "log.hpp"
#include <string.h>

void Log::init() {
  std::string filename = argv_[1];
  std::string head = filename.substr(0, filename.rfind("."));
  filename = head + ".lst";
  if (!(flist=fopen(filename.c_str(),"w"))) {
     fprintf(stderr,"Couldn't open list file.\n");
     exit(1);
  }
  filename = head + ".obj";
  if (!(fobj=fopen(filename.c_str(),"w"))) {
     fprintf(stderr,"Couldn't open object file.\n");
     exit(1);
  }
  filename = head + ".c10";
  if (!(fc10=fopen(filename.c_str(),"w"))) {
     fprintf(stderr,"Couldn't open object file.\n");
     exit(1);
  }
}


static char output[1024];
static char scratch[1024];

void Log::initline(std::size_t n, int pc)
{
   sprintf(output,"%04lu   %04X ",n,pc);
}

void Log::finish(std::string line)
{
   std::size_t n = strlen(output);
   while (n<24) // 32 is arguably better
      output[n++] = ' ';
   output[n] = '\0';
   fprintf(flist,"%s%s",output,line.c_str());
}

void Log::writeFmt(int count, const char *fmt, std::string line, int& remaining, unsigned char binary[], int& byte, int& here)
{
   while (remaining && count) {
     --remaining;
     --count;
     ++here;
     sprintf(scratch,fmt,binary[byte++]);
     strcat(output,scratch);
   }
   finish(line);
}

void Log::writeRemaining(std::size_t n, int& remaining, unsigned char binary[], int& byte, int& here)
{
   while (remaining) {
      initline(n+1,here);
      writeFmt(8, "%02X", "\n", remaining, binary, byte, here);
   }
}

void Log::writeLst(std::vector<std::string>& lines,
                   std::vector<int> pc,
                   int startpc,
                   int endpc,
                   unsigned char binary[],
                   int binsize)
{
   int here = startpc;
   int byte = 0;

   if (endpc-startpc >= binsize)
      endpc = startpc+binsize;

   for (std::size_t n=0; n<pc.size(); ++n) {
      initline(n+1,pc[n]);

      if (pc[n]==0) {
         finish(lines[n]);
         continue;
      }

      if (n<pc.size()-1) {

         int there = pc[n+1];
         if (there > endpc) 
            there = endpc;
         
         int remaining = there - here;
         if (remaining<0)
            remaining = 0;

	 if (remaining>0 && pc[n] != here) {
            finish(lines[n]);
            writeRemaining(n,remaining,binary,byte,here);
            continue;
         }

         if (remaining <= 4) {
            writeFmt(4,"%02X ", lines[n], remaining, binary, byte, here);
	 } else {
            // 6 preserves tab spacing at the expense of eight-byte block alignment
            writeFmt(8, "%02X", lines[n], remaining, binary, byte, here);
            writeRemaining(n,remaining,binary,byte,here);
         }
      } else {
         finish(lines[n]);
      }
   }

   fclose(flist);
}

void Log::writeObj(unsigned char *binary, size_t nbytes)
{
  fwrite(binary,1,nbytes,fobj);
  fclose(fobj);
}

void Log::writeC10(unsigned char *binary, size_t nbytes, int load_addr, int exec_addr)
{
   if (!exec_addr)
      exec_addr = load_addr;

   spitleader();
   filenameblock(argv_[1],exec_addr,load_addr);

   spitleader();

   while (nbytes > 0) {
     std::size_t bufcnt = nbytes<256 ? nbytes : 255;
     datablock(binary, bufcnt);
     binary += bufcnt;
     nbytes -= bufcnt;
   }

   eofblock();
}

void Log::putchar(unsigned char c)
{
    fputc(c, fc10);
}

void Log::putchk(unsigned char c)
{
    putchar(c);
    chksum += c;
}

void Log::spitleader()
{
   for (int i=0; i<128; i++)
     putchar(0x55);
}

void Log::spitblock(unsigned char *buf, std::size_t buflen, int blocktype)
{
   putchar(0x55);   // magic1
   putchar(0x3c);   // magic2
   chksum = 0;
   putchk(static_cast<unsigned char>(blocktype));   // data block type
   putchk(static_cast<unsigned char>(buflen)); // data length
   for (std::size_t i=0; i<buflen; i++)
     putchk(buf[i]);
   putchar(static_cast<unsigned char>(chksum & 0xff)); // checksum
   putchar(0x55); // end of block
}

void Log::filenameblock(char *filearg, int start_addr, int load_addr)
{
   std::size_t i;
   unsigned char buf[15];
   std::string filename = filearg;
   std::string head = filename.substr(0,filename.rfind("."));

   const char *fname = head.c_str();
   for (i=0; i<strlen(fname) && i<8; i++) 
     buf[i] = static_cast<unsigned char>(toupper(fname[i]));
   for (; i<8; i++)
     buf[i] = ' ';

   buf[i++] = 0x02; // Machine language
   buf[i++] = 0x00; // continuous gap flag
   buf[i++] = 0x00; // continuous gap flag

   buf[i++] = static_cast<unsigned char>(start_addr>>8);
   buf[i++] = static_cast<unsigned char>(start_addr&0xff);

   buf[i++] = static_cast<unsigned char>(load_addr>>8);
   buf[i++] = static_cast<unsigned char>(load_addr&0xff);

   spitblock(buf, i, 0x00);
}

void Log::datablock(unsigned char *buf, std::size_t bufcnt)
{
   spitblock(buf, bufcnt, 0x01);
}

void Log::eofblock()
{
   spitblock(NULL, 0, 0xff);
}
