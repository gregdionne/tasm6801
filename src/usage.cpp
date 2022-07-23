#include "usage.hpp"
#include <stdio.h>
#include <string.h>
#include <cstddef>

const char *validOps[] = {"-Wunused","-Wbranch","-compact","--"};

void usage(char *argv[])
{
   fprintf(stderr,"usage: %s ",argv[0]);
   
   std::size_t nopts = sizeof(validOps) / sizeof(char*);

   for (std::size_t i=0; i<nopts; i++)
      fprintf(stderr,"[%s] ",validOps[i]);

   fprintf(stderr,"file1 [file2 [file3...]]\n");
   exit(1);
}

void validateOptions(int argc, char *argv[])
{
  for (int i=1; i<argc; i++) {
    if (!strncmp(argv[i],"-",1)) {
       bool found = false;

       std::size_t nopts = sizeof(validOps) / sizeof(char*);
       for (std::size_t j=0; j < nopts; ++j)
          found |= !strcmp(argv[i],validOps[j]);

       if (!found) {
          fprintf(stderr,"%s:  unrecognized option: \"%s\"\n",argv[0],argv[i]);
          usage(argv);
       }
    }
  }
}

