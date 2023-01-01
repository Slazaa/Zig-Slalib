pub const Drop = struct {
	const Self = @This();

	drop_fn: *const fn(self: *const Self) void,

	pub fn drop(self: *const Self) void {
		self.drop_fn(self);
	}
};