// Copyright (C) 2022 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_MEMUTILS
#define UTILS_MEMUTILS

#include <memory>
#include <utility>

// This header provides abbreviations for unique pointers
//
//   up<T>      ==> std::unique_ptr<T>
//   makeup<T>  ==> std::make_unique<T>
//   mv(X)      ==> std::move(X)

template <typename T> using up = std::unique_ptr<T>;

template <typename T, typename... Args> inline up<T> makeup(Args &&...args) {
  return std::make_unique<T>(std::forward<Args>(args)...);
}

template <typename T>
constexpr std::remove_reference_t<T> &&mv(T &&thing) noexcept {
  return static_cast<std::remove_reference_t<T> &&>(thing);
}

#endif
