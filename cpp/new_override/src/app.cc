
#include <iostream>
#include <vector>
#include <zig_alloc.h>

int main() {

  std::vector<int> numbers;
  for (int i = 1; i <= 6; ++i) {
    numbers.push_back(i);
  }

  for (const auto &num : numbers) {
    std::cout << num << " ";
  }
  std::cout << std::endl;

#ifdef DEBUG
  bool leaked();
#endif

  return 0;
}