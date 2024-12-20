#pragma once
#include <cstddef>
#include <cstdlib>
#include <new>

extern "C" {
void *zigAlloc(size_t size);
void zigFree(void *ptr, size_t len);
void *zigRealloc(void *ptr, size_t len, size_t new_size);
#ifndef NDEBUG
#include <cassert>
bool leaked();
#endif
}

void *operator new(std::size_t size) {
  void *ptr = zigAlloc(size);
  if (!ptr) {
    throw std::bad_alloc();
  }
  return ptr;
}

void *operator new[](std::size_t size) {
  void *ptr = zigAlloc(size);
  if (!ptr) {
    throw std::bad_alloc();
  }
  return ptr;
}

void operator delete(void *ptr, std::size_t size) noexcept {
  zigFree(ptr, size);
}
void operator delete[](void *ptr, std::size_t size) noexcept {
  zigFree(ptr, size);
}