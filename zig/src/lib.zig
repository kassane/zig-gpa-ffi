// zig build-lib -OReleaseSafe -fcompiler-rt src/lib.zig --name zalloc -fPIE
const std = @import("std");

const alloc_metadata_len = std.mem.alignForward(usize, @alignOf(usize), @sizeOf(usize));

// default page_allocator (backing allocation)
var gpa = std.heap.GeneralPurposeAllocator(.{
    .verbose_log = true,
    .thread_safe = true,
}){};
const allocator = gpa.allocator();

export fn zigAlloc(size: usize) ?[*]u8 {
    const total_size = size + alloc_metadata_len;
    const buf = allocator.alloc(u8, total_size) catch return null;

    // Store the size before the actual data
    @as(*usize, @ptrCast(@alignCast(buf.ptr))).* = size;

    return buf.ptr + alloc_metadata_len;
}

fn getBuf(ptr: [*]u8) []u8 {
    const start = @intFromPtr(ptr) - alloc_metadata_len;
    const len = @as(*usize, @ptrFromInt(start)).*;
    // Sanity check for length to avoid nonsensical values
    if (len > 1_000_000) { // Arbitrary large number for sanity check
        std.log.err("Corrupt length in getBuf: {}", .{len});
        unreachable;
    }
    return @as([*]u8, @ptrFromInt(start))[0..(len + alloc_metadata_len)]; // Include metadata in slice
}

export fn zigFree(ptr: ?[*]u8) callconv(.C) void {
    if (ptr) |p| allocator.free(getBuf(p));
}

export fn zigRealloc(ptr: ?[*]u8, new_size: usize) callconv(.C) ?[*]u8 {
    if (new_size == 0) {
        zigFree(ptr);
        return null;
    }
    if (ptr == null) {
        return zigAlloc(new_size);
    }

    const old_buf = getBuf(ptr.?);
    // Realloc the buffer including metadata
    const new_buf = allocator.realloc(old_buf, new_size + alloc_metadata_len) catch |err| {
        std.log.err("realloc failed: {s}", .{@errorName(err)});
        return null;
    };
    // Update metadata with new size
    @as(*usize, @ptrCast(@alignCast(new_buf.ptr))).* = new_size;

    return new_buf.ptr + alloc_metadata_len;
}

export fn zigCalloc(nmemb: usize, size: usize) callconv(.C) ?[*]u8 {
    const total = std.math.mul(usize, nmemb, size) catch return null;
    const ptr = malloc(total) orelse return null;
    @memset(ptr[0..total], 0);
    return ptr;
}

export fn leaked() callconv(.C) bool {
    return gpa.detectLeaks();
}

// ----- Cstd compat -----
export fn malloc(size: usize) callconv(.C) ?[*]u8 {
    return zigAlloc(size);
}
export fn free(ptr: ?[*]u8) callconv(.C) void {
    zigFree(ptr);
}
export fn calloc(nmemb: usize, size: usize) callconv(.C) ?[*]u8 {
    return zigCalloc(nmemb, size);
}

export fn realloc(ptr: ?[*]u8, new_size: usize) callconv(.C) ?[*]u8 {
    return zigRealloc(ptr, new_size);
}
// ----- Cstd compat -----
