// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "crtable.hpp"

std::string catlabel(const char *modulename, const char *labelname)
{
   return labelname[0] == '_' ? std::string(modulename) + std::string(labelname) :
                                labelname;
}

label::label(const char *modulename, const char *labelname) 
{
   name = catlabel(modulename, labelname);
}

bool crtable::findlabel(std::string name, int &i)
{
   for (i=0; i<labels.size(); i++)
     if (labels[i].name == name) 
       return true;

   return false;
}

bool crtable::findlabel(const char *modulename, const char *labelname, int &i)
{
   return findlabel(catlabel(modulename, labelname), i);
}

bool crtable::addlabel(const char *modulename, const char *labelname, int location)
{
  label lbl(modulename, labelname); 
  monomial m;
  m.multiplier = location;
  lbl.polynomial.push_back(m);
  return addlabel(lbl);
}

bool crtable::addlabel(label lbl)
{
  int i;
  if (findlabel(lbl.name, i)) {
    fprintf(stderr,"Duplicate definition of label \"%s\"\n",lbl.name.c_str());
    return false;
  }
  
  labels.push_back(lbl);
  return true;
}

void crtable::addreference(reference r)
{
   references.push_back(r);
}

bool crtable::resolve(const std::string name, int& location)
{
  int i;
  
  if (!findlabel(name, i))
     return false;
  label &l = labels[i];

  if (l.isdirty) {
     fprintf(stderr,"circular reference found %s\n",l.name.c_str());
     return false;
  }

  l.isdirty = true;
  bool gotit = true;

  location = 0;
  for (int i=0; i<l.polynomial.size(); i++) {
     monomial &m = l.polynomial[i];

     if (m.name == "") 
        location += m.multiplier;
     else {
        int value;
        bool gotit = resolve(m.name, value);
        location += m.multiplier * value;
        if (!gotit)
           break;
     }
  }
  l.isdirty = false;
  return gotit;
}

bool crtable::resolve(reference& r, int& location, std::string& offender)
{
  location = 0;
  for (int i=0; i<r.polynomial.size(); i++) {
    monomial &m = r.polynomial[i];
    int mlocation;
    if (m.name == "") {
      location += m.multiplier;
    } else {
      int loc;
      if (resolve(m.name,loc)) {
         location += loc * m.multiplier;
      } else {
         offender = m.name;
         return false;
      }
    }
  }
  return true; 
} 
