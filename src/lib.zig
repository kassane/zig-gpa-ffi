// zig build-lib -OReleaseSafe -fcompiler-rt src/lib.zig --name zalloc -fPIE

// default page_allocator (backing allocation)
var gpa = std.heap.GeneralPurposeAllocator(.{
    .verbose_log = true,
}){};
const allocator = gpa.allocator();

export fn zigAlloc(size: usize) callconv(.C) ?[*]u8 {
    if (allocator.alloc(u8, size)) |buf| {
        return buf.ptr;
    } else |_| {
        return null;
    }
}

export fn zigFree(ptr: [*]u8, size: usize) callconv(.C) void {
    const buf = @as([*]u8, @ptrCast(ptr))[0..size];
    allocator.free(buf);
}

export fn zigRealloc(ptr: [*]u8, old_size: usize, new_size: usize) callconv(.C) ?[*]u8 {
    const buf = @as([*]u8, @ptrCast(ptr))[0..old_size];
    if (allocator.realloc(buf, new_size)) |new_buf| {
        return new_buf.ptr;
    } else |_| {
        return null;
    }
}

export fn leaked() callconv(.C) bool {
    return gpa.detectLeaks();
}

const std = @import("std");
