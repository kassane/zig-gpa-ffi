
#include <iostream>
#include <vector>
#include <zig_pmr.h>

class ComplexObject {
public:
  ComplexObject(std::string name, int value)
      : name_(std::move(name)), value_(value) {}

  void print() const {
    std::cout << "Name: " << name_ << ", Value: " << value_ << std::endl;
  }

private:
  std::string name_;
  int value_;
};

void pmr_complex_example() {
  zig::pmr::GeneralPurposeAllocator gpa;

  // Use the memory resource for vector allocation
  std::pmr::vector<ComplexObject> objects{&gpa};

  // Add objects using the custom memory resource
  objects.emplace_back("Alpha", 100);
  objects.emplace_back("Beta", 200);
  objects.emplace_back("Gamma", 300);

  // Print objects
  for (const auto &obj : objects) {
    obj.print();
  }

#ifdef DEBUG
  if (leaked()) {
    std::cerr << "Memory leak detected!" << std::endl;
  }
#endif
}

int main() {
  pmr_complex_example();
  return 0;
}
