pub const Allocator = @import("memory/Allocator.zig");
pub const GeneralAlloc = @import("memory/GeneralAlloc.zig");

const assert_ = @import("assert.zig");
const collections = @import("collections.zig");
const cmp = @import("compare.zig");

const assert = assert_.assert;
const Vec = collections.Vec;
const Ordering = cmp.Ordering;

pub const Error = error {
    AllocationFailed
};

pub fn copy(comptime T: type, dest: []T, src: []const T) void {
    assert(src.len <= dest.len);

    for (src) |d, i| {
        dest[i] = d;
    }
}

pub fn compare(comptime T: type, fst: []const T, sec: [] const T) Ordering {
    assert(fst.len == sec.len);

    for (fst) |d, i| {
        if (d < sec[i]) return .Less
        else if (d > sec[i]) return .Greater;
    }

    return .Equal;
}

pub fn move(comptime T: type, dest: []T, src: []const T) collections.Error!void {
    var tmp = try Vec(T).from(null, src);
    defer tmp.deinit();

    copy(T, tmp.items, src);
    copy(T, dest, tmp.items);
}

pub fn set(comptime T: type, dest: []T, value: T) void {
    for (dest) |*d| {
        d.* = value;
    }
}
