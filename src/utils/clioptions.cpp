// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#include "clioptions.hpp"

#include <algorithm>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <regex>
#include <string>

namespace utils {

void CLIOptions::paragraph(const char *progname, const char *text) const {
  do {
    int n = 0;
    int c = 0;
    while (text[n] && c < nWrap && text[n] != '\n') {
      ++n;
      c += text[n] == '\b' ? strlen(progname) : 1;
    }

    while (text[n] && text[n] != ' ' && text[n] != '\n') {
      ++n;
    }

    auto line = std::string(text, n);

    if (text[n] == '\n') {
      ++n;
    }

    fprintf(stderr, " %s\n",
            std::regex_replace(line, std::regex("\b"), progname).c_str());

    while (text[n] == ' ') {
      ++n;
    }

    text = text + n;
  } while (*text);
}

void CLIOptions::usage(const char *progname, const char *argUsage) const {
  fprintf(stderr, "usage: %s -help\n", progname);
  fprintf(stderr, "       %s -help <option>\n", progname);
  int n = fprintf(stderr, "       %s", progname);

  for (const auto &option : table) {
    if (n > nWrap) {
      fprintf(stderr, "\n");
      n = fprintf(stderr, "%7s", "");
      for (size_t i = 0; i < strlen(progname); ++i) {
        n += fprintf(stderr, " ");
      }
    }
    n += fprintf(stderr, " [");
    if (option->onSwitch() && option->offSwitch()) {
      n +=
          fprintf(stderr, "-%s | -%s", option->onSwitch(), option->offSwitch());
    } else if (option->onSwitch()) {
      n += fprintf(stderr, "-%s", option->onSwitch());
    } else if (option->offSwitch()) {
      n += fprintf(stderr, "-%s", option->offSwitch());
    }
    n += fprintf(stderr, "]");
  }

  fprintf(stderr, "\n%7s", "");
  for (size_t i = 0; i < strlen(progname); ++i) {
    fprintf(stderr, " ");
  }
  paragraph(progname, argUsage);
}

void CLIOptions::helpOptionSummary(const BinaryOption *option) {
  if (option->onSwitch()) {
    fprintf(stderr, " -%-12s", option->onSwitch());
  }
  fprintf(stderr, " %s\n", option->summary());
  if (option->offSwitch()) {
    fprintf(stderr, "  %-12s %s[-%s to disable%s]\n", "",
            option->isEnabled() ? "(default) " : "", option->offSwitch(),
            option->isEnabled() ? "" : " (default)");
  }
  fprintf(stderr, "\n");
}

void CLIOptions::helpOptions() const {
  fprintf(stderr, "OPTIONS\n\n");
  for (const auto &option : table) {
    helpOptionSummary(option);
  }
}

void CLIOptions::helpOptionDetails(const char *progname,
                                   const BinaryOption *option) const {
  paragraph(progname, option->details());
}

void CLIOptions::helpTopic(const char *progname, const char *target) const {
  // skip any leading '-'
  if (target[0] == '-') {
    ++target;
  }

  for (const auto &option : table) {
    if (option->onSwitch() &&
        (!strcmp(option->onSwitch(), target) ||
         (option->offSwitch() && !strcmp(option->offSwitch(), target)))) {
      helpOptionSummary(option);
      helpOptionDetails(progname, option);

      return;
    }
  }
  fprintf(stderr, "%s -help: Unrecognized option \"%s\"\n", progname, target);
  exit(1);
}

BinaryOption *CLIOptions::findOption(const char *arg) {
  if (auto *opt = findOnSwitch(arg)) {
    return opt;
  }

  fprintf(stderr, "internal error: option \"%s\" not found\n", arg);
  exit(1);
}

// convert iterator idiom to pointer idiom
BinaryOption *CLIOptions::findOnSwitch(const char *arg) {
  auto op =
      std::find_if(table.begin(), table.end(), [&arg](const BinaryOption *o) {
        return arg && arg[0] && o->onSwitch() &&
               !strcmp(arg + 1, o->onSwitch());
      });

  return op == table.end() ? nullptr : *op;
}

BinaryOption *CLIOptions::findOffSwitch(const char *arg) {
  auto op =
      std::find_if(table.begin(), table.end(), [&arg](const BinaryOption *o) {
        return arg && arg[0] && o->offSwitch() &&
               !strcmp(arg + 1, o->offSwitch());
      });

  return op == table.end() ? nullptr : *op;
}

std::vector<const char *> CLIOptions::parse(int argc, const char *const argv[],
                                            const char *argUsage,
                                            const char *argDescription,
                                            const char *helpExample) {

  const char *progname = argv[0];
  if (argc == 1) {
    return {};
  }

  if (!strcmp(argv[1], "--help") || !strcmp(argv[1], "-help")) {
    if (argc == 2) {
      usage(progname, argUsage);
      fprintf(stderr, "DESCRIPTION\n\n");
      paragraph(progname, argDescription);
      helpOptions();
      fprintf(stderr, "EXAMPLES\n\n");
      paragraph(progname, helpExample);
      exit(0);
    }

    if (argc == 3) {
      helpTopic(progname, argv[2]);
      exit(0);
    }

    usage(progname, argUsage);
    exit(1);
  }

  int i = 1;
  for (; i < argc && !strncmp(argv[i], "-", 1); ++i) {
    if (auto *op = findOnSwitch(argv[i])) {
      op->setEnable(true);
    } else if (auto *op = findOffSwitch(argv[i])) {
      op->setEnable(false);
    } else {
      fprintf(stderr, "%s:  unrecognized option: \"%s\"\n", progname, argv[i]);
      usage(progname, argUsage);
      exit(1);
    }

    if (!strcmp(argv[i], "--")) {
      ++i;
      break;
    }
  }

  std::vector<const char *> filenames;
  while (i < argc) {
    filenames.push_back(argv[i++]);
  }
  return filenames;
}

} // namespace utils
