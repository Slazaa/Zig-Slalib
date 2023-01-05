pub fn Clone(comptime T: type) type {
	return struct {
		const Self = @This();

		clone_fn: *const fn(self: *const Self) T,

		pub fn clone(self: *const Self) T {
			return self.clone_fn(self);
		}
	};
}