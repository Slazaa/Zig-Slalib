const allocator = @import("allocator.zig");

const Allocator = allocator.Allocator;
const Error = allocator.Error;

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
		return if (c.malloc(size)) |p| p else Error.AllocationFailed;
	}

	fn reallocFn(allocator_iface: *const Allocator, ptr: *anyopaque, size: usize) Error!*anyopaque {
		_ = allocator_iface;
		return if (c.realloc(ptr, size)) |p| p else Error.AllocationFailed;
	}

	fn deallocFn(allocator_iface: *const Allocator, ptr: *anyopaque) void {
		_ = allocator_iface;
		c.free(ptr);
	}
};