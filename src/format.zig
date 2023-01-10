const memory = @import("memory.zig");
const string = @import("string.zig");

const str = string.str;

const Allocator = memory.allocator.Allocator;
const String = string.String;

pub fn format(comptime A: ?Allocator, comptime fmt: str, args: anytype) String(A) {
	var res = String(A).new();
	
	_ = fmt;
	_ = args;

	return res;
}