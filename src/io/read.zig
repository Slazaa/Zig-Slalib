const io = @import("../io.zig");

const Error = io.Error;

const Self = @This();

readFn: *const fn (self: *const Self, buffer: []u8) Error!usize,

pub fn read(self: *const Self, buffer: []u8) Error!usize {
	return self.readFn(self, buffer);
}