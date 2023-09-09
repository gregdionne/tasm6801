// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "macro.hpp"
#include <cstring>

void Macro::addDefinition(Fetcher &fetcher) {
  Definition d;
  d.identifier = "";
  fetcher.skipWhitespace();

  if (!fetcher.isAlpha()) {
    fetcher.die("identifier expected");
  }

  do {
    d.identifier += fetcher.getChar();
  } while (fetcher.isAlnum());

  fetcher.skipWhitespace();
  if (fetcher.isBlankLine()) {
    fetcher.die("equivalence required for identifier \"%s\"",
                d.identifier.c_str());
  }

  d.equivalence = "";
  do {
    d.equivalence += fetcher.getChar();
  } while (!fetcher.isBlankLine());

  definitions.push_back(d);
}

bool Macro::isID(std::string &id, Fetcher &fetcher) {
  bool found = false;
  if (!strncmp(fetcher.peekLine(), id.c_str(), id.length())) {
    int savecol = fetcher.getColumn();
    fetcher.setColumn(fetcher.getColumn() + id.length());
    found = !fetcher.isAlnum() && !fetcher.isChar('.');
    fetcher.setColumn(savecol);
  }
  return found;
}

void Macro::doSubstitutions(Fetcher &fetcher) {
  do {
    while (!fetcher.iseol() && !fetcher.isAlpha() && !fetcher.isChar('_') &&
           !fetcher.isChar('.')) {
      fetcher.getChar();
    }

    for (auto &definition : definitions) {
      std::string &id = definition.identifier;
      std::string &equ = definition.equivalence;

      if (isID(id, fetcher)) {
        std::string line = fetcher.peekLine();
        line.replace(0, id.length(), equ);
        strcpy(fetcher.peekLine(), line.c_str());
        fetcher.setColumn(fetcher.getColumn() + equ.length());
        break;
      }
    }

    while (fetcher.isAlnum() || fetcher.isChar('_') || fetcher.isChar('.')) {
      fetcher.getChar();
    }

  } while (!fetcher.iseol());
  fetcher.setColumn(0);
}
/*
void Macro::doSubstitutions(Fetcher& fetcher)
{
   std::string line = fetcher.peekLine();
   std::size_t pos = 0;
   for (int i=0; i<definitions.size(); i++) {
      std::size_t found = line.find(definitions[i].identifier,pos);
      if (found != std::string::npos) {
         fprintf(stderr,"found \"%s\"\n",definitions[i].identifier.c_str());
         line.replace(found,
                      definitions[i].identifier.length(),
                      definitions[i].equivalence);
         pos = found + definitions[i].equivalence.length();
         if (pos >= line.length())
            break;
      }
   }
   strcpy(fetcher.peekLine(),line.c_str());
}
*/

void Macro::process(Fetcher &fetcher, const char *const macros[]) {
  if (fetcher.skipKeyword(macros)) {
    addDefinition(fetcher);
  } else {
    doSubstitutions(fetcher);
  }
}
