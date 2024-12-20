
#include <iostream>
#include <vector>
#include <zig_alloc.h>

int main() {
  std::vector<int> v;
  v.reserve(10);
  for (int i = 1; i <= 5; ++i) {
    v.push_back(i * 2);
  }

  for (size_t index = 0; index < v.size(); ++index) {
    std::cout << "Value at index " << index << ": " << v[index] << std::endl;
  }

  int sum = 0;
  for (int value : v) {
    sum += value;
  }
  std::cout << "Total sum of vector: " << sum << std::endl;

#ifndef NDEBUG
  assert(leaked());
#endif

  return 0;
}