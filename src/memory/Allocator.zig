const memory = @import("../memory.zig");

const Error = memory.Error;

const Self = @This();

alloc_fn: *const fn(self: *const Self, size: usize) Error!*anyopaque,
realloc_fn: *const fn(self: *const Self, ptr: *anyopaque, size: usize) Error!*anyopaque,
dealloc_fn: *const fn(self: *const Self, ptr: *anyopaque) void,

pub fn alloc(self: *const Self, size: usize) Error!*anyopaque {
	return self.alloc_fn(self, size);
}

pub fn realloc(self: *const Self, ptr: *anyopaque, size: usize) Error!*anyopaque {
	return self.realloc_fn(self, ptr, size);
}

pub fn dealloc(self: *const Self, ptr: *anyopaque) void {
	self.dealloc_fn(self, ptr);
}