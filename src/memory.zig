pub const allocator = @import("memory/allocator.zig");
pub const drop = @import("memory/drop.zig");
pub const err = @import("memory/err.zig");
pub const glob_alloc = @import("memory/glob_alloc.zig");

const c = @cImport({
	@cInclude("string.h");
});

pub fn copy(dest: *anyopaque, src: *const anyopaque, size: usize) void {
	_ = c.memcpy(dest, src, size);
}