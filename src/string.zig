pub const char = u21;
pub const str = []const u8;

pub const String = @import("string/string.zig");
pub const utf8 = @import("string/utf8.zig");

const memory = @import("memory.zig");
const slice = @import("slice.zig");

const std = @import("std");

pub fn count(self: str, target: anytype) usize {
	return slice.count(u8, self, target);
}

pub fn equals(self: str, string: str) bool {
	return slice.equals(u8, self, string);
}

pub fn find(self: str, target: anytype) ?usize {
	return slice.find(u8, self, target);
}

pub fn get(self: str, idx: usize) ?char {
	if (getStr(self, idx, 1)) |str_res| {
		return utf8.decode(str_res);
	}

	return null;
}

pub fn getStr(self: str, idx: usize, num: usize) ?str {
	if (idx >= self.len or idx + num > self.len) {
		return null;
	}

	var start_res: usize = 0;
	var end_res: usize = 0;

	var vec_idx: usize = 0;
	var i: usize = 0;

	while (true) : (i += 1) {
		const ch = self[vec_idx];
		const vec_char_size = utf8.size(ch);

		if (i == idx) {
			start_res = vec_idx;
			end_res = start_res;
		}
		
		if (i >= idx) {
			var char_utf8 = [_]u8{ 0 } ** 4;
			utf8.encode(&char_utf8, ch);

			const char_size = utf8.size(char_utf8[0]);
			end_res += char_size;

			if (i == idx + num) {
				return self[start_res..end_res];
			}
		}

		vec_idx += vec_char_size;
	}
}

pub fn isEmpty(self: str) bool {
	slice.isEmpty(u8, self);
}