// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_ANNOUNCER_HPP
#define UTILS_ANNOUNCER_HPP

#include "utils/binaryoption.hpp"

#include <string>

class Announcer {
public:
  explicit Announcer(const BinaryOption &opt) : option(opt) {}

  void start(int lineNumber) const;
  void say(const char *formatstr, ...) const;
  void finish(const char *formatstr, ...) const;

private:
  const BinaryOption &option;
};

#endif
