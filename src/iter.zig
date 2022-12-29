pub fn Iterator(comptime T: type) type {
	return struct {
		const Self = @This();

		next_fn: *const fn(self: *Self) ?T,

		pub fn next(self: *Self) ?T {
			return self.next_fn(self);
		}
	};
}