use std::alloc::{GlobalAlloc, Layout};

struct ZigAllocator;

unsafe impl GlobalAlloc for ZigAllocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        if layout.size() == 0 {
            return std::ptr::null_mut();
        }
        unsafe { zigAlloc(layout.size()) }
    }
    unsafe fn dealloc(&self, ptr: *mut u8, layout: Layout) {
        if !ptr.is_null() {
            unsafe {
                zigFree(ptr, layout.size());
            };
        }
    }
    unsafe fn alloc_zeroed(&self, layout: Layout) -> *mut u8 {
        if layout.size() == 0 {
            return std::ptr::null_mut();
        }
        let ptr = self.alloc(layout);
        if !ptr.is_null() {
            unsafe {
                std::ptr::write_bytes(ptr, 0, layout.size());
            }
        }
        ptr
    }
    unsafe fn realloc(&self, ptr: *mut u8, layout: Layout, new_size: usize) -> *mut u8 {
        if new_size == 0 {
            unsafe {
                zigFree(ptr, layout.size());
            }
            return std::ptr::null_mut();
        }
        let ptr = unsafe { zigRealloc(ptr, layout.size(), new_size) };
        if !ptr.is_null() {
            unsafe {
                std::ptr::copy_nonoverlapping(ptr, ptr, new_size);
            }
        }
        ptr
    }
}

#[global_allocator]
static ALLOCATOR: ZigAllocator = ZigAllocator;

fn main() {
    let mut v = Vec::with_capacity(10);
    for i in 1..=5 {
        v.push(i * 2);
    }

    v.iter().enumerate().for_each(|(index, &value)| {
        println!("Value at index {}: {}", index, value);
    });

    let sum: i32 = v.iter().sum();
    println!("Total sum of vector: {}", sum);

    #[cfg(debug_assertions)]
    unsafe {
        assert!(!leaked());
    }
}
extern "C" {
    fn zigAlloc(size: usize) -> *mut u8;
    fn zigFree(ptr: *mut u8, len: usize);
    fn zigRealloc(ptr: *mut u8, len: usize, new_size: usize) -> *mut u8;
    #[cfg(debug_assertions)]
    fn leaked() -> bool;
}
