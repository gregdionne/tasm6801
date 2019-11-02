// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "crtable.hpp"

bool CRTable::addlabel(const char *modulename, const char *labelname, int location)
{
  Label lbl(modulename, labelname); 
  lbl.expression = Expression(location);
  return addlabel(lbl);
}

bool CRTable::addlabel(Label lbl)
{
  for (int i; i<labels.size(); ++i)
    if (labels[i].name == lbl.name) {
      fprintf(stderr,"Duplicate definition of label \"%s\"\n",lbl.name.c_str());
      return false;
    }
  
  labels.push_back(lbl);
  return true;
}

void CRTable::addreference(Reference r)
{
   references.push_back(r);
}

bool CRTable::resolve(Reference& r, int& result, std::string& offender)
{
   return r.expression.evaluate(labels, offender, result);
}

int CRTable::immediatelyResolve(int reftype, Fetcher& fetcher, const char *modulename, int pc, const char *dir)
{
   Reference r(pc, reftype);
   r.expression.parse(fetcher, modulename, pc);

   int result;
   std::string offender;
   if (!resolve(r, result, offender))
      fetcher.die("%s argument must be immediately resolveable");

   return result;
}

int CRTable::tentativelyResolve(int reftype, Fetcher& fetcher, const char *modulename, int pc) 
{
   Reference r(pc, reftype);
   r.expression.parse(fetcher, modulename, pc);

   int w = tentativelyResolve(r);
   if (reftype == 0 && (w < -128 || w > 127))
      fetcher.die("branch destination $%04X out of reach from $%04X",w+pc,pc);

   return w;
}

int CRTable::tentativelyResolve(Reference& r)
{
   int result;
   std::string offender;
   if (resolve(r, result, offender)) {
      if (r.reftype == 0) {
         result -= r.location + 2;
      }
      return result;
   } 

   addreference(r);
   return r.reftype==2 ? 0xdead : 0;
}

bool CRTable::resolveReferences(int startpc, unsigned char *binary, int& failpc) {
   for (int i=0; i<references.size(); i++) {
      Reference &r = references[i];
      int result;
      std::string offender;

      if (!resolve(r, result, offender)) {
         fprintf(stderr,"label \"%s\" is unresolved at %04x\n",offender.c_str(),r.location);
         failpc = r.location;
         return false;
      }

      if (r.reftype == 2) {
        if (result < -32768 || result > 65535) {
           fprintf(stderr,"two-byte operand %i for instruction at %04x is out of range [-32768,65535].\n",result,r.location);
           failpc = r.location;
           return false;
        }
        binary[r.location - startpc + 1] = (result >> 8) & 0xff;
        binary[r.location - startpc + 2] = result & 0xff;

      } else if (r.reftype == 1) {
        if (result < -128 || result > 255) {
           fprintf(stderr,"single-byte operand %i for instruction at %04x is out of range [-128,255].\n",result,r.location);
           failpc = r.location;
           return false;
        }
        binary[r.location - startpc + 1] = result & 0xff;

      } else if (r.reftype == 0) {
        result -= r.location + 2;
        if (result < -128 || result > 127) {
           fprintf(stderr,"branch destination %4x at %04x out of range\n",result + r.location + 2, r.location);
           failpc = r.location;
           return false;
        }
        binary[r.location - startpc + 1] = result & 0xff;

      } else if (r.reftype == -1) {
        if (result < -128 || result > 255) {
           fprintf(stderr,".byte reference %i at %04x is out of range.\n",result,r.location);
           failpc = r.location;
           return false;
        }
        binary[r.location - startpc] = result & 0xff;

      } else if (r.reftype == -2) {
        if (result < -32768 || result > 65535) {
           fprintf(stderr,".word reference %i at %04x is out of range.\n",result,r.location);
           failpc = r.location;
           return false;
        }
        binary[r.location - startpc] = (result >> 8) & 0xff;
        binary[r.location - startpc + 1] = result & 0xff;
      }
   }

   return true;
}


