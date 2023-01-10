const Error = @import("../memory.zig").Error;
const Allocator = @import("allocator.zig").Allocator;
const c = @cImport({
	@cInclude("stdlib.h");
});

pub const GlobAlloc = struct {
	const Self = @This();

	pub const allocator = Allocator {
		.alloc_fn = allocFn,
		.realloc_fn = reallocFn,
		.dealloc_fn = deallocFn
	};

	// Allocator impl
	fn allocFn(allocator_iface: *const Allocator, size: usize) Error!*anyopaque {
		_ = allocator_iface;

		var ptr = c.malloc(size);

		if (ptr == null) {
			return Error.AllocationFailed;
		}

		return ptr.?;
	}

	fn reallocFn(allocator_iface: *const Allocator, ptr: *anyopaque, size: usize) Error!*anyopaque {
		_ = allocator_iface;

		var new_ptr = c.realloc(ptr, size);

		if (new_ptr == null) {
			return Error.AllocationFailed;
		}

		return new_ptr.?;
	}

	fn deallocFn(allocator_iface: *const Allocator, ptr: *anyopaque) void {
		_ = allocator_iface;
		
		c.free(ptr);
	}
};