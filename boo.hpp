// Copyright (C) 2019 Greg Dionne
// Distributed under MIT License
#ifndef BOO
#define BOO

// simpleton C++98 replacement for std::shared_ptr

namespace boo {

template < typename T >
class scared_ptr {
public:
 scared_ptr() {
    rawPtr = nullptr;
    refCnt = new scared_ptr::RefCnt;
 }

 scared_ptr(T* raw_ptr) {
    rawPtr = raw_ptr;
    refCnt = new scared_ptr::RefCnt;
 }

 scared_ptr(const scared_ptr<T>& scaryPtr) {
    rawPtr = scaryPtr.rawPtr;
    refCnt = scaryPtr.refCnt;
    refCnt->addRef();
 }

 ~scared_ptr() {
    release();
 }

 T& operator*() {
     return *rawPtr;
 }

 T* operator->() {
    return rawPtr;
 }

 scared_ptr<T>& operator=(const scared_ptr<T>& scaryPtr) {
    if (this != &scaryPtr) {
       release();
       addRef(scaryPtr);
    }
    return *this;
 }

 T* get() {
    return rawPtr;
 }

private:
 void release() {
    if (refCnt->release() == 0) {
       delete rawPtr;
       delete refCnt;
    }
 }

 void addRef(const scared_ptr<T>& scaryPtr) {
     rawPtr = scaryPtr.rawPtr;
     refCnt = scaryPtr.refCnt;
     refCnt->addRef();
 }

 class RefCnt {
  public:
   RefCnt() : refcnt(1) {}
   void addRef() {
      ++refcnt;
   }
   int release() {
      return --refcnt;
   }
  private:
   int refcnt;
  };

  RefCnt* refCnt;
  T* rawPtr;
};

// this really isn't a make_shared replacement
// it's just so we can write:
//
//     pScared = boo::make_scared<T>();
//
// instead of
//
//     pScared = boo::scared_ptr<T> = new T; 
//

template < typename T >
scared_ptr<T> make_scared() {
   return scared_ptr<T>(new T());
}

template < typename T, typename Arg1 >
scared_ptr<T> make_scared(const Arg1& arg1) {
   return scared_ptr<T>(new T(arg1));
}

template < typename T, typename Arg1, typename Arg2 >
scared_ptr<T> make_scared(const Arg1& arg1, const Arg2& arg2) {
   return scared_ptr<T>(new T(arg1, arg2));
}
}
#endif
