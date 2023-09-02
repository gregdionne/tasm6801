// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_CLIOPTIONS_HPP
#define UTILS_CLIOPTIONS_HPP

#include "binaryoption.hpp"

#include <functional>
#include <vector>

namespace utils {

// parser for command-line interfaces.
// Intended to be subclassed.  Something like:
//
// #include "cliparser.hpp"
//
// class CLIOptions : public utils::CLIOptions {
// public:
//   CLIOptions();
//   BinaryOption option1;
//   BinaryOption option2;
// };
//
// CLIOptions::CLIOptions()
//     : option1{false,"option1",nullptr,"normally false option",
//               "detailed info for an option that is normally false "
//               "unless you specify '-option1' on the input"},
//       option2{true,"option2","no-option2","normally true option",
//               "option2 is 'true' unless -no-option2 is specified"} {
//   addOption(&option1);
//   addOption(&option2);
// }
//
// // When parsing, argUsage(), argDetails() and helpExample() are invoked
// // when "-help" is used on the command line.  Something like:
//
// const char * const argUsage = "[arg1 [arg2 [arg3 ...]]]\n\n";
// const char * const argDescription = "Lengthy tome.\n\n"
// const char * const helpExample = "foo -option1 file1\n"); }
//
// int main(int argc, char *argv[]) {
//   CLIOptions options;
//   auto arguments = options.parse(argc, argv,
//                                  argUsage, argDetails, helpExample);
//
//   if (options.option1.isEnabled()) {
//     printf("%s was enabled\n", options.option1.c_str());
//   }
//
//   printf("option2's state was %s\n",options.option2.c_str());
//   printf("option2 could be either %s or %s\n",
//          options.option2.onSwitch(),options.option2.offSwitch());
//   return 0;
// }
//
// ./a.out -help
// usage: ./a.out -help
//        ./a.out -help <option>
//        ./a.out [-option1] [-option2 | -no-option2]
//               [arg1 [arg2 [arg3 ...]]]
//
// DESCRIPTION
//
//  Lengthy tome.
//
// OPTIONS
//
//  -option1      normally false option
//
//  -option2      normally true option
//                (default) [-no-option2 to disable]
//
// EXAMPLE
//
//  foo -option1 file1

class CLIOptions {
public:
  std::vector<const char *> parse(int argc, const char *const argv[],
                                  const char *argUsage,
                                  const char *argDescription,
                                  const char *helpExample);
  const std::vector<BinaryOption *> &getTable() const { return table; }
  void usage(const char *progname, const char *argUsage) const;

protected:
  void addOption(BinaryOption *option) { table.push_back(option); }

private:
  BinaryOption *findOption(const char *arg);
  BinaryOption *findOnSwitch(const char *arg);
  BinaryOption *findOffSwitch(const char *arg);
  void paragraph(const char *progname, const char *text) const;
  static void helpOptionSummary(const BinaryOption *option);
  void helpOptionDetails(const char *progname,
                         const BinaryOption *option) const;
  void helpOptions() const;
  void helpTopic(const char *progname, const char *target) const;
  std::vector<BinaryOption *> table;
  const int nWrap = 65;
};

} // namespace utils

#endif
