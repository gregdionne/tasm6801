// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include <stdlib.h>
#include <vector>
#include <string>
#include "log.hpp"
#include <string.h>

void log::init() {
  if (!(flog=fopen("tasm.log","w"))) {
     fprintf(stderr,"Couldn't open logfile.\n");
     exit(1);
  }
}


static char output[1024];
static char scratch[1024];

void log::initline(int n, int pc)
{
   sprintf(output,"%04i   %04X ",n,pc);
}

void log::finish(std::string line)
{
   int n = strlen(output);
   while (n<24)
      output[n++] = ' ';
   output[n] = '\0';
   fprintf(flog,"%s%s",output,line.c_str());
}

void log::write(std::vector<std::string>& lines,
                std::vector<int> pc,
                int startpc,
                int endpc,
                unsigned char binary[],
                int binsize)
{
   int here = startpc;
   int byte = 0;

   for (int n=0; n<pc.size(); ++n) {
      initline(n+1,pc[n]);

      if (pc[n]==0) {
         finish(lines[n]);
         continue;
      }

      if (n<pc.size()-1) {
         int there = pc[n+1];
         if (there > endpc) {
            fprintf(stderr,"line %i: %04X %s",n+1,pc[n],lines[n].c_str());
            return;
         }
         int remaining = there - here;
         if (remaining <= 4) {
            while (remaining--) {
               ++here;
               sprintf(scratch,"%02X ",binary[byte++]);
               strcat(output,scratch);
            }
            finish(lines[n]);
            continue;
	 } else {
            int count = 8;
            while (remaining && count) {
              --remaining;
              --count;
              ++here;
              sprintf(scratch,"%02X",binary[byte++]);
              strcat(output,scratch);
            }
            finish(lines[n]);
            while (remaining) {
               initline(n+1,here);
               count = 8;
               while (remaining && count) {
                 --remaining;
                 --count;
                 ++here;
                 sprintf(scratch,"%02X",binary[byte++]);
                 strcat(output,scratch);
               }
               finish("\n");
            }
         }
      } else {
         finish(lines[n]);
      }
   }
}
      
