pub const Allocator = @import("memory/allocator.zig");
pub const GeneralAlloc = @import("memory/general_alloc.zig");

const assert_ = @import("assert.zig");
const collections = @import("collections.zig");
const compare_ = @import("compare.zig");

const assert = assert_.assert;
const Vec = collections.Vec;
const Ordering = compare_.Ordering;

pub const Error = error {
	AllocationFailed
};

pub fn copy(comptime T: type, dest: []T, src: []const T, size: usize) void {
	assert(dest.len >= size and src.len >= size);

	var i: usize = 0;

	while (i != size) : (i += 1) {
		dest[i] = src[i];
	}
}

pub fn compare(comptime T: type, first: []const T, second: [] const T, size: usize) Ordering {
	assert(first.len >= size and second.len >= size);

	var i: usize = 0;

	while (i != size) : (i += 1) {
		if (first[i] < second[i]) return .Less
		else if (first[i] > second[i]) return .Greater;
	}

	return .Equal;
}

pub fn move(comptime T: type, dest: []T, src: []const T, size: usize) Error!void {
	var tmp = try Vec(T).from(null, src[0..size]);
	defer tmp.deinit();

	copy(T, tmp.items, src, size);
	copy(T, dest, tmp.items, size);
}