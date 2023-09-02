// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "crtable.hpp"

#include <cstring>

std::string Reference::to_string() { return expression.to_string(); }

bool CRTable::addlabel(const char *modulename, const char *labelname,
                       int location, const char *filename, int linenum) {
  Label lbl(modulename, labelname, filename, linenum);
  lbl.expression = Expression(location);
  return addlabel(lbl);
}

bool CRTable::addlabel(const Label &lbl) {
  for (auto &label : labels) {
    if (label.fullName == lbl.fullName) {
      fprintf(stderr, "%s:%i: error: redefinition of label \"%s\"\n",
              lbl.fileName, lbl.lineNumber, lbl.fullName.c_str());
      fprintf(stderr, "%s:%i: previous definition of label \"%s\"\n",
              label.fileName, label.lineNumber, lbl.fullName.c_str());
      return false;
    }
  }

  labels.push_back(lbl);
  return true;
}

bool CRTable::addmodule(const char *modulename, const char *filename,
                        int linenum) {
  Module m(modulename, filename, linenum);
  for (auto &module : modules) {
    if (module.name == m.name) {
      fprintf(stderr, "%s:%i: error: redefinition of module \"%s\"\n",
              m.fileName, m.lineNumber, m.name.c_str());
      fprintf(stderr, "%s:%i: previous definition of module \"%s\"\n",
              module.fileName, module.lineNumber, m.name.c_str());
      return false;
    }
  }

  modules.push_back(m);
  return true;
}

void CRTable::reportUnusedReferences() {
  for (auto &label : labels) {
    if (!label.used) {
      fprintf(stderr, "%s:%i: warning: unused label \'%s\' [-Wunused]\n",
              label.fileName, label.lineNumber, label.fullName.c_str());
    }
  }
}

void CRTable::reportUnusedGlobalReferences() {
  for (auto &label : labels) {
    if (strncmp(label.labelName.c_str(), "_", 1) != 0 && label.used &&
        !label.usedOutOfModule && label.moduleName.length() > 0) {
      fprintf(stderr,
              "%s:%i: warning: global label \'%s\' only used locally in module "
              "\'%s\' [-Wglobal]\n",
              label.fileName, label.lineNumber, label.fullName.c_str(),
              label.moduleName.c_str());
    }
  }
}

std::vector<std::string> CRTable::globalTable() {
  std::vector<std::string> table;
  std::string lastModule;
  for (auto &label : labels) {
    if (strncmp(label.labelName.c_str(), "_", 1) != 0) {
      if (label.moduleName != lastModule) {
        table.push_back("module " + (lastModule = label.moduleName));
      }
      table.emplace_back("  ");
      int result = 0;
      std::string offender;
      char zinc[5];
      if (lookup(label, result, offender)) {
        snprintf(zinc, 5, "%04X", result & 0xffff);
      } else {
        snprintf(zinc, 5, "----");
      }
      table.back() += zinc;
      table.back() += " ";
      table.back() += label.labelName;

      if (label.callers.empty()) {
        table.back() += " (unused)";
      } else {
        for (const auto &caller : label.callers) {
          table.back() += " " + caller;
        }
      }
    }
  }
  return table;
}

std::vector<std::string> CRTable::symbolTable() {
  std::vector<std::string> table;
  std::string lastModule;
  for (auto &label : labels) {
    if (label.moduleName != lastModule) {
      table.push_back("module " + (lastModule = label.moduleName));
    }
    table.emplace_back("  ");
    int result = 0;
    std::string offender;
    char zinc[5];
    if (lookup(label, result, offender)) {
      snprintf(zinc, 5, "%04X", result & 0xffff);
    } else {
      snprintf(zinc, 5, "----");
    }
    table.back() += zinc;
    table.back() += " ";
    table.back() += label.labelName;

    if (label.callers.empty()) {
      table.back() += " (unused)";
    }
  }
  return table;
}

void CRTable::addreference(const Reference &r) { references.push_back(r); }

bool CRTable::lookup(Label &l, int &result, std::string &offender) {
  return l.expression.evaluate(nullptr, labels, offender, result);
}

bool CRTable::resolve(Reference &r, int &result, std::string &offender) {
  return r.expression.evaluate(r.modname.c_str(), labels, offender, result);
}

int CRTable::immediatelyResolve(int reftype, Fetcher &fetcher,
                                const char *modulename, int pc, const char *dir,
                                const char *filename, int linenum) {
  Reference r(pc, reftype, modulename, filename, linenum);
  r.expression.parse(fetcher, modulename, pc);

  int result = 0;
  std::string offender;
  if (!resolve(r, result, offender)) {
    fetcher.die("label \"%s\" must be immediately resolveable when using "
                "\"%s\" or its equivalent pseudo-operation",
                offender.c_str(), dir);
  }

  return result;
}

int CRTable::tentativelyResolve(int reftype, Fetcher &fetcher,
                                const char *modulename, int pc,
                                const char *filename, int linenum,
                                bool wBranch) {
  Reference r(pc, reftype, modulename, filename, linenum);
  r.expression.parse(fetcher, modulename, pc);

  int w = tentativelyResolve(r, fetcher, wBranch);

  return w;
}

int CRTable::tentativelyResolve(Reference &r, Fetcher &fetcher, bool wBranch) {
  int result = 0;
  std::string offender;
  if (resolve(r, result, offender)) {
    if (r.reftype == 0) {
      result -= r.location + 2;
      if (result < -128 || result > 127) {
        fetcher.die("branch destination $%04X out of reach from $%04X",
                    result + r.location + 2, r.location);
      }
    }

    if (wBranch && r.reftype > 2) {
      int relAddr = result - (r.location + 2);
      if (-128 <= relAddr && relAddr <= 127) {
        fprintf(stderr, "%s:%i: warning: ", r.filename, r.lineNumber);
        fprintf(stderr,
                "%s instruction at $%04X to reference \"%s\" can be replaced "
                "by %s [-Wbranch].\n",
                r.reftype == 3 ? "JMP" : "JSR", r.location,
                r.to_string().c_str(), r.reftype == 3 ? "BRA" : "BSR");
      }
    }

    return result;
  }

  addreference(r);
  return r.reftype >= 2 ? 0xdead : 0;
}

bool CRTable::resolveReferences(int startpc, unsigned char *binary, int &failpc,
                                bool wBranch) {
  for (auto &r : references) {
    int result = 0;
    std::string offender;
    std::string refstr = r.to_string();

    if (!resolve(r, result, offender)) {
      fprintf(stderr, "%s:%i: error: ", r.filename, r.lineNumber);
      fprintf(stderr, "label \"%s\" is unresolved at %04x\n", offender.c_str(),
              r.location);
      failpc = r.location;
      return false;
    }

    if (r.reftype >= 2) {
      if (result < -32768 || result > 65535) {
        fprintf(stderr, "%s:%i: error: ", r.filename, r.lineNumber);
        fprintf(stderr,
                "two-byte operand \"%s\", evaluating to %i for instruction at "
                "%04x, is out of range [-32768,65535].\n",
                refstr.c_str(), result, r.location);
        failpc = r.location;
        return false;
      }

      if (wBranch && r.reftype > 2) {
        int relAddr = result - (r.location + 2);
        if (-128 <= relAddr && relAddr <= 127) {
          fprintf(stderr, "%s:%i: warning: ", r.filename, r.lineNumber);
          fprintf(stderr,
                  "%s instruction at $%04X to reference \"%s\" can be replaced "
                  "by %s [-Wbranch].\n",
                  r.reftype == 3 ? "JMP" : "JSR", r.location, refstr.c_str(),
                  r.reftype == 3 ? "BRA" : "BSR");
        }
      }

      binary[r.location - startpc + 1] = (result >> 8) & 0xff;
      binary[r.location - startpc + 2] = result & 0xff;

    } else if (r.reftype == 1) {
      if (result < -128 || result > 255) {
        fprintf(stderr, "%s:%i: error: ", r.filename, r.lineNumber);
        fprintf(stderr,
                "single-byte operand \"%s\", evaluating to %i for instruction "
                "at %04x, is out of range [-128,255].\n",
                refstr.c_str(), result, r.location);
        failpc = r.location;
        return false;
      }
      binary[r.location - startpc + 1] = result & 0xff;

    } else if (r.reftype == 0) {
      result -= r.location + 2;
      if (result < -128 || result > 127) {
        fprintf(stderr, "%s:%i: error: ", r.filename, r.lineNumber);
        fprintf(stderr,
                "branch destination \"%s\", evaluating to %4x at %04x, is out "
                "of range\n",
                refstr.c_str(), result + r.location + 2, r.location);
        failpc = r.location;
        return false;
      }
      binary[r.location - startpc + 1] = result & 0xff;

    } else if (r.reftype == -1) {
      if (result < -128 || result > 255) {
        fprintf(stderr, "%s:%i: error: ", r.filename, r.lineNumber);
        fprintf(stderr,
                ".byte reference \"%s\", evaluating to %i at %04x, is out of "
                "range.\n",
                refstr.c_str(), result, r.location);
        failpc = r.location;
        return false;
      }
      binary[r.location - startpc] = result & 0xff;

    } else if (r.reftype == -2) {
      if (result < -32768 || result > 65535) {
        fprintf(stderr, "%s:%i: error: ", r.filename, r.lineNumber);
        fprintf(stderr,
                ".word reference \"%s\", evaluating to %i at %04x, is out of "
                "range.\n",
                refstr.c_str(), result, r.location);
        failpc = r.location;
        return false;
      }
      binary[r.location - startpc] = (result >> 8) & 0xff;
      binary[r.location - startpc + 1] = result & 0xff;
    }
  }

  return true;
}
