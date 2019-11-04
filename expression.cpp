// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#include "expression.hpp"

Term::~Term()
{
   if (expression && !--expression->refcnt) {
      delete expression;
      expression = NULL;
   }
}

Term::Term(const Term& t) 
{
   name = t.name;
   value = t.value;
   complements = t.complements;
   expression = t.expression;
   if (expression) 
      ++expression->refcnt;
}

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

   if (fetcher.isHexadecimalWord()) {
      int c = fetcher.colnum;
      int w = fetcher.getHexadecimalWord();
      if ((fetcher.skipChar('h') || fetcher.skipChar('H')) && !fetcher.isAlnum()) {
         value = w;
         return;
      }
      fetcher.colnum = c;
   }     

   if (fetcher.isBinaryWord()) {
      int c = fetcher.colnum;
      int w = fetcher.getBinaryWord();
      if ((fetcher.skipChar('b') || fetcher.skipChar('B')) && !fetcher.isAlnum()) {
         value = w;
         return;
      }
      fetcher.colnum = c;
   }     
      
   if (fetcher.isQuaternaryWord()) {
      int c = fetcher.colnum;
      int w = fetcher.getQuaternaryWord();
      if ((fetcher.skipChar('q') || fetcher.skipChar('Q')) && !fetcher.isAlnum()) {
         value = w;
         return;
      }
      fetcher.colnum = c;
   }     

   if (fetcher.isDecimalWord()) {
      value = fetcher.getDecimalWord();
      return;
   }

   if (fetcher.skipChar('\'')) {
      value = fetcher.getQuotedLiteral();

      // allow auto-termination of character constant
      // if followed by whitespace
      if (!fetcher.skipWhitespace())
         fetcher.matchChar('\'');

      return;
   }

   if (fetcher.isAlpha() || fetcher.isChar('_')) {
      if (fetcher.isChar('_'))
         name = modulename;
      else
         name = "";
      while (fetcher.isAlnum() || fetcher.isChar('_'))
         name = name + fetcher.getChar();
      return;
   }

   if (fetcher.skipChar('(')) {
      expression = new Expression;
      expression->refcnt = 1;
      expression->parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
      fetcher.matchChar(')');
      return;
   }
   fetcher.die("Unrecognized input");
}

void MulExpression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   multiplicands.push_back(Term());
   multiplicands.back().parse(fetcher, modulename, pc);
   fetcher.skipWhitespace();
  
   while (fetcher.isChar(conjunction) || fetcher.isChar(inverse)) 
      if (fetcher.skipChar(conjunction)) {
         multiplicands.push_back(Term());
         multiplicands.back().parse(fetcher, modulename, pc);
         fetcher.skipWhitespace();
      } else {
         fetcher.matchChar(inverse);
         divisors.push_back(Term());
         divisors.back().parse(fetcher, modulename, pc);
         fetcher.skipWhitespace();
      }
}

void AddExpression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   addends.push_back(MulExpression());
   addends.back().parse(fetcher, modulename, pc);
   fetcher.skipWhitespace();
  
   while (fetcher.isChar(conjunction) || fetcher.isChar(inverse)) 
      if (fetcher.skipChar(conjunction)) {
         addends.push_back(MulExpression());
         addends.back().parse(fetcher, modulename, pc);
         fetcher.skipWhitespace();
      } else {
         fetcher.matchChar(inverse);
         subtrahends.push_back(MulExpression());
         subtrahends.back().parse(fetcher, modulename, pc);
         fetcher.skipWhitespace();
      }
}

bool ShiftExpression::getDirection(Fetcher& fetcher, char& direction)
{
   int savecol = fetcher.colnum;
   if (fetcher.skipChar(conjunction) && fetcher.skipChar(conjunction)) {
      direction = conjunction;
      return true;
   }

   fetcher.colnum = savecol;
   if (fetcher.skipChar(inverse) && fetcher.skipChar(inverse)) {
      direction = inverse;
      return true;
   }

   fetcher.colnum = savecol;
   return false;
}

void ShiftExpression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   operands.push_back(AddExpression());
   operands.back().parse(fetcher, modulename, pc);
   fetcher.skipWhitespace();
   
   char direction;
   while (getDirection(fetcher, direction)) {
      directions.push_back(direction);
      fetcher.skipWhitespace();
      operands.push_back(AddExpression());
      operands.back().parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
   }
}

void AndExpression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   do {
      operands.push_back(ShiftExpression());
      operands.back().parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
   } while (fetcher.skipChar(conjunction));
}

void XorExpression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   do {
      operands.push_back(AndExpression());
      operands.back().parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
   } while (fetcher.skipChar(conjunction));
}

void Expression::parse(Fetcher& fetcher, const char *modulename, int pc)
{
   do {
      operands.push_back(XorExpression());
      operands.back().parse(fetcher, modulename, pc);
      fetcher.skipWhitespace();
   } while (fetcher.skipChar(conjunction));

   // clobber trailing comments
   if (fetcher.isChar(';'))
      *fetcher.peekLine() = '\n';
}

bool Term::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    bool success = false;
    offender = name;
    result = value;

    if (expression != NULL) {
       success = expression->evaluate(labels, offender, result);
       
    } else if (name == "") 
       success = true;
    else
       for (int i=0; i<labels.size(); ++i)
          if (labels[i].name == name) {
             if (labels[i].isdirty) 
                fprintf(stderr,"Circular reference found.  Label \"%s\"\n",labels[i].name.c_str());
             else {
                labels[i].isdirty = true;
                success = labels[i].expression.evaluate(labels, offender, result);
                labels[i].isdirty = false;
                break;
             }
         }

    int n = complements.size();
    for (int i=0; i<n; i++) {
       if (complements[n-i-1]=='~')
          result = ~result;
       else // (complements[n-i-1]=='-')
          result = -result;
    }

    return success;
}

bool MulExpression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    int numerator = 1;
    for (int i=0; i<multiplicands.size(); ++i) {
        int answer;
        if (!multiplicands[i].evaluate(labels, offender, answer))
            return false;
        numerator *= answer;
    }

    int denominator = 1;
    for (int i=0; i<divisors.size(); ++i) {
        int answer;
        if (!divisors[i].evaluate(labels, offender, answer))
            return false;
        denominator *= answer;
    }
    result = numerator / denominator;
    return true;
}

bool AddExpression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    result = 0;
    for (int i=0; i<addends.size(); ++i) {
        int answer;
        if (!addends[i].evaluate(labels, offender, answer))
            return false;
        result += answer;
    }
    for (int i=0; i<subtrahends.size(); ++i) {
        int answer;
        if (!subtrahends[i].evaluate(labels, offender, answer))
            return false;
        result -= answer;
    }
    return true;
}

bool ShiftExpression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    int answer;
    if (operands.empty() || !operands[0].evaluate(labels, offender, answer))
       return false;

    result = answer;
    for (int i=1; i<operands.size(); ++i) {
        if (!operands[i].evaluate(labels, offender, answer))
            return false;

        if (directions[i-1]==conjunction)
           result <<= answer;
        else
           result >>= answer;
    }
    return true;
}

bool AndExpression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    result = -1;
    for (int i=0; i<operands.size(); ++i) {
        int answer;
        if (!operands[i].evaluate(labels, offender, answer))
            return false;
        result &= answer;
    }
    return true;
}

bool XorExpression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    int answer;
    if (operands.empty() || !operands[0].evaluate(labels, offender, answer))
       return false;

    result = answer;
    for (int i=1; i<operands.size(); ++i) {
        int answer;
        if (!operands[i].evaluate(labels, offender, answer))
            return false;
        result ^= answer;
    }
    return true;
}

bool Expression::evaluate(std::vector<Label>& labels, std::string& offender, int& result)
{
    if (operands.size() > 0) {
       result = 0;
       for (int i=0; i<operands.size(); ++i) {
          int answer;
          if (!operands[i].evaluate(labels, offender, answer))
             return false;
          result |= answer;
       }
       operands.clear();
       value = result;
    }

    result = value;
    return true;
}


Label::Label(const char *modulename, const char *labelname)
{
   name = labelname[0] == '_' ? std::string(modulename) + std::string(labelname) :
                                labelname;
   isdirty = false;
}

