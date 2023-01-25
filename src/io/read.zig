const io = @import("../io.zig");

const Error = io.Error;

const Self = @This();

readFn: *const fn(self: *const Self, buffer: []u8) Error!void,

pub fn read(self: *const Self, buffer: []u8) Error!void {
	return self.readFn(self, buffer);
}