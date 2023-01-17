pub const vec = @import("collections/vec.zig");

const memory = @import("memory.zig");

pub const CollectionError = error {
	IndexOutOfBound
};

pub const ErrorKind = enum {
	Collection,
	Allocator
};

pub const Error = union(ErrorKind) {
	collection: CollectionError,
	allocator: memory.allocator.Error
};