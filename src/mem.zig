pub const allocator = @import("mem/allocator.zig");
pub const drop = @import("mem/drop.zig");
pub const err = @import("mem/err.zig");
pub const glob_alloc = @import("mem/glob_alloc.zig");

const c = @cImport({
	@cInclude("string.h");
});

pub fn copy(dest: *anyopaque, src: *const anyopaque, size: usize) void {
	_ = c.memcpy(dest, src, size);
}