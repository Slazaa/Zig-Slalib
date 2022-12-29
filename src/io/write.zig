const Error = @import("err.zig").Error;

pub const Write = struct {
	const Self = @This();

	write_fn: *const fn(self: *const Self, buf: []const u8) Error!usize,
	flush_fn: *const fn(self: *const Self) Error!void,

	pub fn write(self: *const Self, buf: []const u8) Error!usize {
		return self.write_fn(self, buf);
	}

	pub fn flush(self: *const Self) Error!void {
		try self.flush_fn(self);
	}
};