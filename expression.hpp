// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef EXPRESSION_HPP
#define EXPRESSION_HPP

#include <vector>
#include <string>
#include "fetcher.hpp"

class Operator {
public:
  Operator(const char *conj, int (*oper)(int x,int y)) : conjunction(conj), operate(oper) {}
  const char *conjunction;
  int (*operate)(int x, int y);
};

typedef std::vector<Operator> PrecedenceGroup;
typedef std::vector<PrecedenceGroup> PrecedenceGroups;

class OpTable {
public:
 OpTable();
 PrecedenceGroups precedenceGroups;
 static int add(int x, int y);
 static int sub(int x, int y);
 static int asl(int x, int y);
 static int asr(int x, int y);
 static int mul(int x, int y);
 static int div(int x, int y);
 static int bit_and(int x, int y);
 static int bit_xor(int x, int y);
 static int bit_or(int x, int y);
};

class Expression;
class Label;

class Term {
public:
  Term() : expression(NULL) {}
  Term(const Term& t);
  ~Term();
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
private:
  std::string name;
  int value;
  std::vector<char> complements;
  Expression* expression; // because C++11 unavail
};

class ExpressionGroup {
public:
 ExpressionGroup(PrecedenceGroups* precedenceGroups, PrecedenceGroups::iterator itPrecedenceGroups) 
   : precedenceGroups(precedenceGroups), itPrecedenceGroups(itPrecedenceGroups) {}
 void parse(Fetcher& fetcher, const char *modulename, int pc);
 bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
private:
 std::vector<Term> term;
 std::vector<ExpressionGroup> operands;
 std::vector<Operator> operators;
 PrecedenceGroups* precedenceGroups;
 PrecedenceGroups::iterator itPrecedenceGroups;
};

class Expression {
public:
  Expression() : refcnt(0) {eg.push_back(ExpressionGroup(&opTable.precedenceGroups, opTable.precedenceGroups.begin()));}
  Expression(int location) : refcnt(0),value(location) {}
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
  int refcnt;
private:
  std::vector<ExpressionGroup> eg;
  int value;
  static OpTable opTable;
};

class Label {
public:
  Label(const char *modulename, const char *labelname);
  std::string name;
  Expression expression;
  int result;
  bool isdirty;
};
#endif
