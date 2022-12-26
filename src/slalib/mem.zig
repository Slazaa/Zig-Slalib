pub const Allocator = @import("mem/allocator.zig").Allocator;
pub const Drop = @import("mem/drop.zig").Drop;
pub const Error = @import("mem/error.zig").Error;
pub const GlobAlloc = @import("mem/glob_alloc.zig").GlobAlloc;
pub const glob_alloc = @import("mem/glob_alloc.zig").glob_alloc;

const c = @cImport({
    @cInclude("string.h");
});

pub fn copy(dest: *anyopaque, src: *const anyopaque, size: usize) void {
    _ = c.memcpy(dest, src, size);
}