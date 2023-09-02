// Copyright (C) 2021 Greg Dionne
// Distributed under MIT License
#ifndef UTILS_OPTIONAL
#define UTILS_OPTIONAL

#include <memory>

// non-performant syntatic convenience for C++17 std::optional
// does not require enclosed type to be trivially destructable
namespace utils {

template <typename T> class optional {
  bool initialized_;
  T value_;

public:
  optional() : initialized_(false), value_{} {} // value_{} begrudgingly added
  explicit optional(const T &value) : initialized_(true), value_{value} {}
  explicit optional(const T &&value) : initialized_(true), value_{mv(value)} {}
  explicit operator bool() const { return initialized_; }
  bool has_value() const { return initialized_; }
  const T &value() const { return value_; }

  constexpr const T *dataptr() const { return std::addressof(value_); }
  constexpr const T &operator*() const { return value_; }
  constexpr const T *operator->() const { return dataptr(); }
};

} // namespace utils

#endif
