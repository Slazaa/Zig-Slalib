pub const allocator = @import("memory/allocator.zig");
pub const glob_alloc = @import("memory/glob_alloc.zig");

const c = @cImport({
	@cInclude("string.h");
});

pub const Error = error {
	AllocationFailed
};

pub fn copy(dest: *anyopaque, src: *const anyopaque, size: usize) void {
	_ = c.memcpy(dest, src, size);
}