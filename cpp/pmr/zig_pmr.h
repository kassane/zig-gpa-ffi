#pragma once
#include <cstddef>
#include <memory_resource>

extern "C" {
void *zigAlloc(size_t size);
void zigFree(void *ptr, size_t len);
void *zigRealloc(void *ptr, size_t len, size_t new_size);
#if 0
bool leaked();
#endif
}

namespace zig::pmr {

class GeneralPurposeAllocator : public std::pmr::memory_resource {
public:
  void *do_allocate(std::size_t bytes, [[maybe_unused]] std::size_t alignment =
                                           alignof(std::max_align_t)) override {
    return zigAlloc(bytes);
  }

  void do_deallocate(void *ptr, std::size_t bytes,
                     [[maybe_unused]] std::size_t alignment =
                         alignof(std::max_align_t)) override {
    zigFree(ptr, bytes);
  }

  bool
  do_is_equal(const std::pmr::memory_resource &other) const noexcept override {
    return this == &other;
  }
};

} // namespace zig::pmr
