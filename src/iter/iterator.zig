pub fn Iterator(comptime B: type, comptime T: type) type {
	return struct {
		const Self = @This();

		next_fn: *const fn(self: *Self) ?T,

		map_fn: ?*const fn(self: *const Self, *const fn(T) T) B,

		pub fn next(self: *Self) ?T {
			return self.next_fn(self);
		}

		pub fn map(self: *const Self, f: *const fn(T) T) B {
			if (self.map_fn) |map_fn| {
				return map_fn(self);
			}

			_ = f;

			@panic("TODO");
		}
	};
}