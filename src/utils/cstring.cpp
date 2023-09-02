// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#include "cstring.hpp"

#include <cstring>

namespace utils {

bool ends_with(const char *string, const char *suffix) {
  auto srclen = strlen(string);
  auto tgtlen = strlen(suffix);

  return srclen >= tgtlen && !strcmp(string + srclen - tgtlen, suffix);
}

std::size_t strlcat(char *dst, const char *src, std::size_t n) {
  auto srclen = strlen(src);
  auto dstlen = strlen(dst);

  if (n) {
    dst += dstlen;
    n -= dstlen;

    while (--n && *src) {
      *dst++ = *src++;
    }

    *dst = '\0';
  }

  return dstlen + srclen;
}

} // namespace utils
