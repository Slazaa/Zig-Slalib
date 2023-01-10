const memory = @import("../memory.zig");
const chars_ = @import("chars.zig");

const str = @import("../string.zig").str;
const char = @import("../string.zig").char;

const Allocator = memory.allocator.Allocator;
const Vec = @import("../collections.zig").vec.Vec;
const Chars = chars_.Chars;

const std = @import("std");

pub fn String(comptime A: ?Allocator) type {
	return struct {
		const Self = @This();

		vec: Vec(u8, A),

		pub fn asStr(self: *const Self) str {
			return self.vec.items;
		}

		pub fn chars(self: *const Self) Chars(A) {
			return .{ .target = &self.vec };
		}

		pub fn clear(self: *Self) void {
			self.vec.clear();
		}

		pub fn deinit(self: *Self) void {
			self.vec.deinit();
		}

		pub fn from(string: str) Self {
			return .{ .vec = Vec(u8, A).from(string) };
		}

		pub fn get(self: *const Self, start: usize, end: usize) ?str {
			if (start > end or end > self.len()) {
				@panic("Index out of bounds");
			}

			var start_res: usize = 0;
			var end_res: usize = 0;

			var vec_idx: usize = 0;
			var i: usize = 0;

			while (true) : (i += 1) {
				const ch = self.vec.get(vec_idx).?.*;
				const vec_char_size = chars_.utf8Size(ch);

				if (i == start) {
					start_res = vec_idx;
					end_res = start_res;
				}
				
				if (i >= start) {
					var char_utf8 = [_]u8{ 0 } ** 4;
					chars_.encodeUtf8(&char_utf8, ch);

					const char_size = chars_.utf8Size(char_utf8[0]);
					end_res += char_size;

					if (i == end) {
						return self.vec.getSlice(start_res, end_res);
					}
				}

				vec_idx += vec_char_size;
			}
		}

		pub fn init() Self {
			return .{ .vec = Vec(u8, A).new() };
		}

		pub fn insert(self: *Self, idx: usize, ch: char) void {
			if (idx > self.len()) {
				@panic("Index out of bounds");
			}

			var vec_idx: usize = 0;
			var i: usize = 0;

			while (true) : (i += 1) {
				const vec_char_size = chars_.utf8Size(self.vec.get(vec_idx).?.*);

				if (i == idx) {
					var char_utf8 = [_]u8{ 0 } ** 4;
					chars_.encodeUtf8(&char_utf8, ch);

					const char_size = chars_.utf8Size(char_utf8[0]);
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
			var i: usize = idx;
			
			for (string) |byte| {
				self.vec.insert(i, byte);
				i += 1;
			}
		}

		pub fn isEmpty(self: *const Self) bool {
			return self.vec.isEmpty();
		}

		pub fn len(self: *const Self) usize {
			var chrs = self.chars();
			return chrs.count();
		}

		pub fn pop(self: *Self) char {
			return self.remove(self.len() - 1);
		}

		pub fn push(self: *Self, ch: char) void {
			self.insert(self.len(), ch);
		}

		pub fn pushStr(self: *Self, string: str) void {
			self.insertStr(self.len(), string);
		}

		pub fn remove(self: *Self, idx: usize) char {
			if (idx > self.len()) {
				@panic("Index out of bounds");
			}

			var vec_idx: usize = 0;
			var i: usize = 0;

			while (true) : (i += 1) {
				const vec_char = self.vec.get(vec_idx).?.*;
				const vec_char_size = chars_.utf8Size(vec_char);

				if (i == idx) {
					var j: usize = vec_char_size;

					while (j != 0) : (j -= 1) {
						_ = self.vec.remove(vec_idx);
					}

					return vec_char;
				}

				vec_idx += vec_char_size;
			}
		}

		pub fn withCapacity(cap: usize) Self {
			return .{ .vec = Vec(u8, A).withCapacity(cap) };
		}
	};
}