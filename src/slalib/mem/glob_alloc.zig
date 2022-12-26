const Error = @import("error.zig").Error;
const Allocator = @import("allocator.zig").Allocator;
const c = @cImport({
    @cInclude("stdlib.h");
});

pub const GlobAlloc = struct {
    const Self = @This();

    allocator: Allocator = .{
        .alloc_fn = alloc,
        .realloc_fn = realloc,
        .dealloc_fn = dealloc
    },

    // Allocator implementation
    fn alloc(allocator_iface: *const Allocator, size: usize) Error!*anyopaque {
        _ = allocator_iface;

        var ptr = c.malloc(size);

        if (ptr == null) {
            return Error.AllocationFailed;
        }

        return ptr.?;
    }

    fn realloc(allocator_iface: *const Allocator, ptr: *anyopaque, size: usize) Error!*anyopaque {
        _ = allocator_iface;

        var new_ptr = c.realloc(ptr, size);

        if (new_ptr == null) {
            return Error.AllocationFailed;
        }

        return new_ptr.?;
    }

    fn dealloc(allocator_iface: *const Allocator, ptr: *anyopaque) void {
        _ = allocator_iface;
        
        c.free(ptr);
    }
};

pub fn glob_alloc() GlobAlloc {
    return .{ };
}