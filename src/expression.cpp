// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include <memory>
#include "expression.hpp"

OpTable::OpTable() {
   // C++11 has a better way...
   precedenceGroups.resize(7); // seventh (offset 6) is empty
   precedenceGroups[0].push_back(Operator("|",bit_or));
   precedenceGroups[1].push_back(Operator("^",bit_xor));
   precedenceGroups[2].push_back(Operator("&",bit_and));
   precedenceGroups[3].push_back(Operator("+",add));
   precedenceGroups[3].push_back(Operator("-",sub));
   precedenceGroups[4].push_back(Operator("<<",asl));
   precedenceGroups[4].push_back(Operator(">>",asr));
   precedenceGroups[5].push_back(Operator("*",mul));
   precedenceGroups[5].push_back(Operator("/",div));
}

int OpTable::add(int x, int y) {return x+y;}
int OpTable::sub(int x, int y) {return x-y;}
int OpTable::asl(int x, int y) {return x<<y;}
int OpTable::asr(int x, int y) {return x>>y;}
int OpTable::mul(int x, int y) {return x*y;}
int OpTable::div(int x, int y) {return x/y;}
int OpTable::bit_and(int x, int y) {return x&y;}
int OpTable::bit_xor(int x, int y) {return x^y;}
int OpTable::bit_or(int x, int y) {return x|y;}

OpTable Expression::opTable;

void Term::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   fetcher.skipWhitespace();

   while (fetcher.isChar('-') || fetcher.isChar('~')) {
      complements.push_back(fetcher.getChar());
      fetcher.skipWhitespace();
   }
  
   if (fetcher.skipChar('$')) { // PC or hex
      fetcher.skipWhitespace();
      if (fetcher.isHexadecimalWord())
         value = fetcher.getHexadecimalWord();
      else
         value = pc;
      return;
   } 

   if (fetcher.skipChar('*')) { // PC
      value = pc;
      return;
   }

   if (fetcher.skipChar('%')) {
      value = fetcher.getBinaryWord();
      return;
   }

   if (fetcher.recognizePostfixedWord(value))
      return;

   if (fetcher.skipChar('\'')) {
      value = fetcher.getEscapedChar();

      // allow auto-termination of character constant
      // if followed by whitespace
      if (!fetcher.skipWhitespace())
         fetcher.matchChar('\'');

      return;
   }

   if (fetcher.isAlpha() || fetcher.isChar('_')) {
      name = fetcher.isChar('_') ? std::string(modulename) + ":" : "";
      while (fetcher.isAlnum() || fetcher.isChar('_'))
         name = name + fetcher.getChar();
      return;
   }

   if (fetcher.skipChar('(')) {
      expression = boo::make_scared<Expression>();
      expression->parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
      fetcher.matchChar(')');
      return;
   }
   fetcher.die("Unrecognized input");
}


void ExpressionGroup::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   if (itPrecedenceGroups->begin() == itPrecedenceGroups->end()) {
      term.push_back(Term());
      term.back().parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
   } else {
      PrecedenceGroups::iterator nextGroup = itPrecedenceGroups;
      ++nextGroup;
      operands.push_back(ExpressionGroup(precedenceGroups,nextGroup));
      operands.back().parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
      bool done = false;
      while (!done) {
         done = true;
         for (PrecedenceGroup::iterator validOp = itPrecedenceGroups->begin(); validOp != itPrecedenceGroups->end(); ++validOp) {
            if (fetcher.skipToken(validOp->conjunction)) {
               done = false;
               operators.push_back(*validOp);
               operands.push_back(ExpressionGroup(precedenceGroups,nextGroup));
               operands.back().parse(fetcher, modulename, pc);
               fetcher.skipWhitespace();
            }
         }
      }
   }
}

bool ExpressionGroup::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    if (itPrecedenceGroups->begin() == itPrecedenceGroups->end())
       return term[0].evaluate(labels, offender, result);
    else {
       int answer;
       if (!operands[0].evaluate(labels, offender, answer))
          return false;

       result = answer;
       for (std::size_t i=0; i<operators.size(); ++i) {
           if (!operands[i+1].evaluate(labels, offender, answer))
               return false;

           result = operators[i].operate(result, answer);
       }
       return true;
   }
}

std::string ExpressionGroup::to_string(void)
{
    if (itPrecedenceGroups->begin() == itPrecedenceGroups->end())
       return term[0].to_string();
    else {
       std::string answer = operators.empty() ? "" : "(";

       answer += operands[0].to_string();

       std::string result = answer;
       for (std::size_t i=0; i<operators.size(); ++i) {
           answer = operands[i+1].to_string();

           result = result + operators[i].conjunction + answer;
       }

       result += operators.empty() ? "" : ")";

       return result;
   }
}

void Expression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   eg[0].parse(fetcher, modulename, pc);

   // clobber trailing comments
   if (fetcher.isChar(';'))
      *fetcher.peekLine() = '\n';
}

bool Term::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    bool success = false;
    offender = name;
    result = value;

    if (expression.get() != NULL) {
       success = expression->evaluate(labels, offender, result);
       
    } else if (name == "") 
       success = true;
    else
       for (std::size_t i=0; i<labels.size(); ++i)
          if (labels[i].name == name) {
             labels[i].used = true;
             if (labels[i].isdirty) 
                fprintf(stderr,"Circular reference found.  Label \"%s\"\n",labels[i].name.c_str());
             else {
                labels[i].isdirty = true;
                success = labels[i].expression.evaluate(labels, offender, result);
                labels[i].isdirty = false;
                break;
             }
         }

    std::size_t n = complements.size();
    for (std::size_t i=0; i<n; i++) {
       if (complements[n-i-1]=='~')
          result = ~result;
       else // (complements[n-i-1]=='-')
          result = -result;
    }

    return success;
}

std::string Term::to_string(void)
{
   std::string result = expression.get() != NULL ? expression->to_string() :
                        name             == ""   ? std::to_string(value) :
                                                   name;

   std::size_t n = complements.size();
   for (std::size_t i=0; i<n; i++) {
      result = complements[n-i-1] + result;
   }

   return result;
}

bool Expression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
   if (eg.empty()) {
      result = value;
      return true;
   } else if (eg[0].evaluate(labels, offender, result)) {
      eg.clear();
      value = result;
      return true;
   } else {
      return false;
   }
}

std::string Expression::to_string(void)
{
   return eg.empty() ? std::to_string(value) :
                       eg[0].to_string();
}

Label::Label(const char *modulename, const char *labelname, char *filename, int linenum)
{
   name = labelname[0] == '_' ? std::string(modulename) + ":" + std::string(labelname) :
                                labelname;
   isdirty = false;
   used = false;
   fileName = filename;
   lineNumber = linenum;
}

