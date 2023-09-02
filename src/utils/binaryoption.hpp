// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_OPTION_HPP
#define UTILS_OPTION_HPP

class BinaryOption {
public:
  BinaryOption(bool v, const char *on, const char *off, const char *summary,
               const char *details)
      : value(v), onValue(on), offValue(off), helpSummary(summary),
        helpDetails(details) {}

  const char *c_str() const { return value ? onValue : offValue; }
  const char *onSwitch() const { return onValue; }
  const char *offSwitch() const { return offValue; }
  const char *summary() const { return helpSummary; }
  const char *details() const { return helpDetails; }
  bool isEnabled() const { return value; }
  void setEnable(bool v) { value = v; }

private:
  bool value;
  const char *const onValue;
  const char *const offValue;
  const char *const helpSummary;
  const char *const helpDetails;
};

#endif
