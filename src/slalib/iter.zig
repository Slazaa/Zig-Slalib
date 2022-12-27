pub fn Iterator(comptime T: type) type {
    return struct {
        const Self = @This();

        next_fn: *const fn(self: *Self) ?*const T,

        pub fn next(self: *Self) ?*const T {
            return self.next_fn(self);
        }
    };
}