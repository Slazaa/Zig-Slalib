pub const allocator = @import("memory/allocator.zig");
pub const glob_alloc = @import("memory/glob_alloc.zig");

const cmp = @import("compare.zig");

const c = @cImport({
	@cInclude("string.h");
});

pub fn copy(dest: *anyopaque, src: *const anyopaque, size: usize) void {
	_ = c.memcpy(dest, src, size);
}

pub fn compare(first: *const anyopaque, second: *const anyopaque, size: usize) cmp.Ordering {
	var res = c.memcmp(first, second, size);

	return
		if (res < 0) .Less
		else if (res > 0) .Greater
		else .Equal;
}