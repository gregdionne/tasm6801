// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_CSTRING_HPP
#define UTILS_CSTRING_HPP

#include <cstddef>

namespace utils {

// like C++20, but with C strings
bool ends_with(const char *string, const char *suffix);

// like strncat() but null-terminates when result doesn't fit.
// both src and dst must be valid null-terminated strings
std::size_t strlcat(char *dst, const char *src, std::size_t n);

} // namespace utils

#endif
