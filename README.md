# zig-gpa-ffi

Testing [`std.heap.DebugAllocator`](https://ziglang.org/documentation/master/std/#std.heap.DebugAllocator) in FFI.

## Required

- Zig 0.14.0 or master
- Rust 1.82.0 or nightly

It is also possible to preload in the posix environment.

```console
zig build-lib -dynamic zig/src/lib.zig --name zalloc
```

```bash
LD_PRELOAD=libzalloc.so {app}
```

## Some references for tests

- Rust [Global Allocator](https://doc.rust-lang.org/std/alloc/trait.GlobalAlloc.html)
- C++ [new](https://en.cppreference.com/w/cpp/memory/new/operator_new)/[delete](https://en.cppreference.com/w/cpp/memory/new/operator_delete) operators override
- C++17 [PMR](https://en.cppreference.com/w/cpp/memory/polymorphic_allocator)
