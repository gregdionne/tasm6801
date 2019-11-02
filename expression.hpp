// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef EXPRESSION_HPP
#define EXPRESSION_HPP

#include <vector>
#include <string>
#include "fetcher.hpp"

class Expression;
class Label;

class Term {
public:
  Term() : expression(NULL),multiplier(1) {}
  Term(const Term& t);
  ~Term();
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
private:
  std::string name;
  int multiplier;
  Expression *expression; // because C++
};

class NaryExpression {
public:
  char conjunction;
};

class NaryInvertableExpression : public NaryExpression {
public:
  char inverse;
};

class MulExpression : public NaryInvertableExpression {
public:
  MulExpression() {conjunction = '*'; inverse='/';}
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
private:
  std::vector<Term> multiplicands;
  std::vector<Term> divisors;
};

class AddExpression : public NaryInvertableExpression {
public:
  AddExpression() {conjunction = '+'; inverse='-';}
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
private:
  std::vector<MulExpression> addends;
  std::vector<MulExpression> subtrahends;
};

class AndExpression : public NaryInvertableExpression {
public:
  AndExpression() {conjunction='&';}
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
private:
  std::vector<AddExpression> operands;
};

class Expression : public NaryExpression {
public:
  Expression() : refcnt(0) {conjunction='|';}
  Expression(int location) : refcnt(0),value(location) {conjunction='|';}
  void parse(Fetcher& fetcher, const char *modulename, int pc);
  bool evaluate(std::vector<Label>& labels, std::string& offender, int& result);
  int refcnt;
private:
  std::vector<AndExpression> operands;
  int value;
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
