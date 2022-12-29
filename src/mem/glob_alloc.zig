const Error = @import("err.zig").Error;
const Allocator = @import("allocator.zig").Allocator;
const c = @cImport({
	@cInclude("stdlib.h");
});

pub const GlobAlloc = struct {
	const Self = @This();

	pub const allocator = Allocator {
		.alloc_fn = alloc_fn,
		.realloc_fn = realloc_fn,
		.dealloc_fn = dealloc_fn
	};

	// Allocator impl
	fn alloc_fn(allocator_iface: *const Allocator, size: usize) Error!*anyopaque {
		_ = allocator_iface;

		var ptr = c.malloc(size);

		if (ptr == null) {
			return Error.AllocationFailed;
		}

		return ptr.?;
	}

	fn realloc_fn(allocator_iface: *const Allocator, ptr: *anyopaque, size: usize) Error!*anyopaque {
		_ = allocator_iface;

		var new_ptr = c.realloc(ptr, size);

		if (new_ptr == null) {
			return Error.AllocationFailed;
		}

		return new_ptr.?;
	}

	fn dealloc_fn(allocator_iface: *const Allocator, ptr: *anyopaque) void {
		_ = allocator_iface;
		
		c.free(ptr);
	}
};