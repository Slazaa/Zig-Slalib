const mem = @import("../mem.zig");
const str = @import("../string.zig").str;

const Allocator = mem.allocator.Allocator;
const Drop = mem.drop.Drop;
const Vec = @import("../collections.zig").vec.Vec;
const Chars = @import("chars.zig").Chars;

pub fn String(comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		vec: Vec(u8, A),

		drop: Drop = .{
			.drop_fn = drop_fn
		},

		pub fn chars(self: *const Self) Chars(A) {
			return .{ .target = &self.vec };
		}

		pub fn from(string: str) Self {
			return .{ .vec = Vec(u8, A).from(string) };
		}

		pub fn new() Self {
			return .{ .vec = Vec(u8, A).new() };
		}

		// Drop impl
		fn drop_fn(drop_iface: *const Drop) void {
			const self = @fieldParentPtr(Self, "drop", drop_iface);
			self.vec.drop.drop();
		}
	};
}