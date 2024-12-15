# zig-gpa-ffi

Testing [`std.heap.GeneralPurposeAllocator`](https://ziglang.org/documentation/master/std/#std.heap.GeneralPurposeAllocator) in FFI.

## Required

- Zig 0.13.0 or master
- Rust 1.68.0 or nightly

## Some references for tests

- Rust [Global Allocator](https://doc.rust-lang.org/std/alloc/trait.GlobalAlloc.html)
- C++ [new](https://en.cppreference.com/w/cpp/memory/new/operator_new)/[delete](https://en.cppreference.com/w/cpp/memory/new/operator_delete) operators override
- C++17 [PMR](https://en.cppreference.com/w/cpp/memory/polymorphic_allocator)
