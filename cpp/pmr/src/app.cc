
#include <iostream>
#include <unordered_map>
#include <zig_pmr.h>

class KeyPair {
public:
  KeyPair(std::pmr::string key, int value)
      : key_(std::move(key)), value_(value) {}

  void print() const {
    std::cout << "Key: " << key_ << ", Value: " << value_ << std::endl;
  }

  std::pmr::string getKey() const { return key_; }
  int getValue() const { return value_; }

private:
  std::pmr::string key_;
  int value_;
};

int main() {
  zig::pmr::GeneralPurposeAllocator gpa;
  std::pmr::set_default_resource(&gpa);

  std::pmr::unordered_map<std::pmr::string, KeyPair> hashmap{};

  hashmap.emplace("first", KeyPair("Alpha", 100));
  hashmap.emplace("second", KeyPair("Beta", 200));
  hashmap.emplace("third", KeyPair("Gamma", 300));

  for (const auto &[key, pair] : hashmap) {
    pair.print();
  }

#ifdef DEBUG
  if (leaked()) {
    std::cerr << "Memory leak detected!" << std::endl;
  }
#endif

  return 0;
}
