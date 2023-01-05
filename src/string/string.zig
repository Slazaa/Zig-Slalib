const memory = @import("../memory.zig");
const chars = @import("chars.zig");

const str = @import("../string.zig").str;
const char = @import("../string.zig").char;

const Clone = @import("../clone.zig").Clone;
const Allocator = memory.allocator.Allocator;
const Drop = memory.drop.Drop;
const Vec = @import("../collections.zig").vec.Vec;
const Chars = chars.Chars;

const std = @import("std");

pub fn String(comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		vec: Vec(u8, A),

		clone: Clone(Self) = .{
			.clone_fn = cloneFn
		},

		drop: Drop = .{
			.drop_fn = dropFn
		},

		pub fn asChars(self: *const Self) Chars(A) {
			return .{ .target = &self.vec };
		}

		pub fn asStr(self: *const Self) str {
			return self.vec.items;
		}

		pub fn clear(self: *Self) void {
			self.vec.clear();
		}

		pub fn from(string: str) Self {
			return .{ .vec = Vec(u8, A).from(string) };
		}

		pub fn insert(self: *Self, idx: usize, ch: char) void {
			if (idx > self.len()) {
				@panic("Index out of bounds");
			}

			var vec_idx: usize = 0;
			var i: usize = 0;

			while (true) : (i += 1) {
				const vec_char_size = chars.utf8Size(self.vec.get(vec_idx).?.*);

				if (i == idx) {
					var char_utf8 = [_]u8{ 0 } ** 4;
					chars.encodeUtf8(&char_utf8, ch);

					const char_size = chars.utf8Size(char_utf8[0]);
					var j: usize = char_size;

					while (j != 0) : (j -= 1) {
						self.vec.insert(vec_idx, char_utf8[j - 1]);
					}

					return;
				}

				vec_idx += vec_char_size;
			}
		}

		pub fn insertStr(self: *Self, idx: usize, string: str) void {
			// TODO

			_ = self;
			_ = idx;
			_ = string;

			@panic("Function not implemented yet");
		}

		pub fn isEmpty(self: *const Self) bool {
			return self.vec.isEmpty();
		}

		pub fn len(self: *const Self) usize {
			var chrs = self.asChars();
			return chrs.count();
		}

		pub fn new() Self {
			return .{ .vec = Vec(u8, A).new() };
		}

		pub fn pop(self: *Self) char {
			// TODO

			_ = self;

			@panic("Function not implemented yet");
		}

		pub fn push(self: *Self, ch: char) void {
			// TODO

			_ = self;
			_ = ch;

			@panic("Function not implemented yet");
		}

		pub fn pushStr(self: *Self, string: str) void {
			// TODO

			_ = self;
			_ = string;

			@panic("Function not implemented yet");
		}

		pub fn remove(self: *Self, idx: usize) char {
			// TODO

			_ = self;
			_ = idx;

			@panic("Function not implemented yet");
		}

		// Clone impl
		fn cloneFn(clone_iface: *const Clone(Self)) Self {
			const self = @fieldParentPtr(Self, "clone", clone_iface);
			return Self.from(self.asStr());
		}

		// Drop impl
		fn dropFn(drop_iface: *const Drop) void {
			const self = @fieldParentPtr(Self, "drop", drop_iface);
			self.vec.drop.drop();
		}
	};
}