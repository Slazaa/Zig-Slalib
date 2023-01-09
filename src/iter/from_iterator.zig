pub fn FromIterator(comptime I: type, comptime T: type) type {
	return struct {
		const Self = @This();

		from_iter_fn: *const fn(self: *const Self, iter: I) T,

		pub fn fromIter(self: *const Self, iter: I) T {
			return self.from_iter_fn(self, iter);
		}
	};
}