// zig build-lib -OReleaseSafe -fcompiler-rt src/lib.zig --name zalloc -fPIE

// default page_allocator (backing allocation)
var gpa = std.heap.GeneralPurposeAllocator(.{
    .verbose_log = true,
    .thread_safe = true,
}){};
const allocator = gpa.allocator();

const alloc_align = std.mem.page_size;
const alloc_metadata_len = std.mem.alignForward(usize, alloc_align, @sizeOf(usize));

export fn zigAlloc(size: usize) callconv(.C) ?[*]align(alloc_align) u8 {
    const full_len = alloc_metadata_len + size;

    const buf = allocator.alignedAlloc(u8, alloc_align, full_len) catch return null;
    @as(*usize, @ptrCast(buf.ptr)).* = full_len;
    return @as([*]align(alloc_align) u8, @ptrFromInt(@intFromPtr(buf.ptr) + alloc_metadata_len));
}

export fn malloc(size: usize) callconv(.C) ?[*]align(alloc_align) u8 {
    return zigAlloc(size);
}

export fn zigFree(ptr: [*]u8, size: usize) callconv(.C) void {
    allocator.free(ptr[0..size]);
}

fn getGpaBuf(ptr: [*]u8) []align(alloc_align) u8 {
    const start = @intFromPtr(ptr) - alloc_metadata_len;
    const len = @as(*usize, @ptrFromInt(start)).*;
    return @alignCast(@as([*]u8, @ptrFromInt(start))[0..len]);
}

export fn free(ptr: ?[*]align(alloc_align) u8) callconv(.C) void {
    if (ptr) |p| allocator.free(getGpaBuf(p));
}

export fn realloc(ptr: ?[*]align(alloc_align) u8, size: usize) callconv(.C) ?[*]align(alloc_align) u8 {
    return zigRealloc(ptr, size);
}

export fn calloc(nmemb: usize, size: usize) callconv(.C) ?[*]align(alloc_align) u8 {
    return zigCalloc(nmemb, size);
}

export fn zigCalloc(nmemb: usize, size: usize) callconv(.C) ?[*]align(alloc_align) u8 {
    const total = std.math.mul(usize, nmemb, size) catch return null;
    const ptr = malloc(total) orelse return null;
    @memset(ptr[0..total], 0);
    return ptr;
}

export fn zigRealloc(ptr: ?[*]align(alloc_align) u8, size: usize) callconv(.C) ?[*]align(alloc_align) u8 {
    const gpa_buf = getGpaBuf(ptr orelse return malloc(size));
    if (size == 0) {
        allocator.free(gpa_buf);
        return null;
    }

    const gpa_size = alloc_metadata_len + size;
    if (allocator.rawResize(gpa_buf, std.math.log2(alloc_align), gpa_size, @returnAddress())) {
        @as(*usize, @ptrCast(gpa_buf.ptr)).* = gpa_size;
        return ptr;
    }

    const new_buf = allocator.reallocAdvanced(
        gpa_buf,
        gpa_size,
        @returnAddress(),
    ) catch return null;

    @as(*usize, @ptrCast(new_buf.ptr)).* = gpa_size;

    return @as([*]align(alloc_align) u8, @ptrFromInt(@intFromPtr(new_buf.ptr) + alloc_metadata_len));
}

export fn leaked() callconv(.C) bool {
    return gpa.detectLeaks();
}

const std = @import("std");
