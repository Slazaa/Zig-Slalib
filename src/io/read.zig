const Error = @import("../io.zig").Error;

pub const Read = struct {
	const Self = @This();

	read_fn: *const fn(self: *const Self, buf: []u8) Error!usize,

	pub fn read(self: *const Self, buf: []u8) Error!usize {
		return self.read_fn(self, buf);
	}
};