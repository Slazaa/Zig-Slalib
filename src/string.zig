pub const char = u21;
pub const str = []const u8;

const memory = @import("memory.zig");
const collections = @import("collections.zig");

const Allocator = memory.allocator.Allocator;
const Vec = collections.vec.Vec;

const std = @import("std");

pub fn utf8Size(header_byte: u8) u3 {
	const byte_template = 0b1000_0000;
	var header_byte_val = header_byte;
	var size: u3 = 0;

	while (header_byte_val & byte_template == byte_template) {
		size += 1;
		header_byte_val <<= 1;
	}

	if (size == 0) {
		return 1;
	}

	return size;
}

pub fn decodeUtf8(bytes: []const u8) ?char {
	switch (bytes.len) {
		0 => return null,
		1 => return bytes[0],
		else => { }
	}

	var res: char = 0;

	var byte = bytes[0];
	var shift_left: u3 = @intCast(u3, 6 - (bytes.len + 1));

	while (shift_left != 0) : (shift_left -= 1) {
		res <<= 1;
		res |= byte & 0x0000_0001;
		byte >>= 1;
	}

	var i: u3 = 1;

	while (i != bytes.len) : (i += 1) {
		res <<= 6;
		res |= bytes[i] & 0b0011_1111;
	}

	return res;
}

pub fn encodeUtf8(dst: []u8, ch: char) void {
	var ch_value = ch;
	var zero_count: u5 = 0;

	while (ch_value & 0x10_00_00 == 0) : (zero_count += 1) {
		ch_value <<= 1;
	}

	var char_size: u5 = switch (21 - zero_count) {
		0       => return,
		1...7   => 1,
		8...11  => 2,
		12...16 => 3,
		17...21 => 4,
		else => @panic("Invalid char size")
	};

	if (char_size == 1) {
		dst[0] = @truncate(u8, ch);
		return;
	}

	ch_value = ch;
	
	var char_idx = char_size - 1;

	while (char_idx != 0) : (char_idx -= 1) {
		dst[char_idx] = 0b1000_0000 | (@truncate(u8, ch_value) & 0b0011_1111);
		ch_value >>= 6;
	}

	dst[char_idx] = switch (char_size) {
		2 => 0b1100_0000 | (@truncate(u8, ch_value) & 0b0001_1111),
		3 => 0b1110_0000 | (@truncate(u8, ch_value) & 0b0000_1111),
		4 => 0b1111_0000 | (@truncate(u8, ch_value) & 0b0000_0111),
		else => @panic("Invalid char index")
	};
}

pub const String = struct {
	const Self = @This();

	vec: Vec(u8),
	len: usize = 0,

	pub fn asStr(self: *const Self) str {
		return self.vec.items;
	}

	pub fn clear(self: *Self) void {
		self.vec.clear();
	}

	pub fn deinit(self: *Self) void {
		self.vec.deinit();
	}

	// pub fn find(self: *Self, string: str) usize {

	// }

	pub fn from(allocator: ?Allocator, string: str) memory.allocator.Error!Self {
		return .{
			.vec = try Vec(u8).from(allocator, string),
			.len = string.len
		};
	}

	pub fn get(self: *const Self, idx: usize) ?char {
		if (idx > self.len) {
			@panic("Index out of bounds");
		}

		var vec_idx: usize = 0;
		var i: usize = 0;

		while (true) : (i += 1) {
			const ch = self.vec.get(vec_idx).?.*;
			const vec_char_size = utf8Size(ch);

			if (i == idx) {
				return decodeUtf8(self.vec.getSlice(vec_idx, vec_idx + vec_char_size).?);
			}

			vec_idx += vec_char_size;
		}
	}

	pub fn getStr(self: *const Self, start: usize, end: usize) ?str {
		if (start > end or end > self.len) {
			@panic("Index out of bounds");
		}

		var start_res: usize = 0;
		var end_res: usize = 0;

		var vec_idx: usize = 0;
		var i: usize = 0;

		while (true) : (i += 1) {
			const ch = self.vec.get(vec_idx).?.*;
			const vec_char_size = utf8Size(ch);

			if (i == start) {
				start_res = vec_idx;
				end_res = start_res;
			}
			
			if (i >= start) {
				var char_utf8 = [_]u8{ 0 } ** 4;
				encodeUtf8(&char_utf8, ch);

				const char_size = utf8Size(char_utf8[0]);
				end_res += char_size;

				if (i == end) {
					return self.vec.getSlice(start_res, end_res);
				}
			}

			vec_idx += vec_char_size;
		}
	}

	pub fn init(allocator: ?Allocator) Self {
		return .{
			.vec = Vec(u8).new(allocator)
		};
	}

	pub fn insert(self: *Self, idx: usize, ch: char) memory.allocator.Error!void {
		if (idx > self.len) {
			@panic("Index out of bounds");
		}

		var vec_idx: usize = 0;
		var i: usize = 0;

		while (true) : (i += 1) {
			const vec_char_size = utf8Size(self.vec.get(vec_idx).?.*);

			if (i == idx) {
				var char_utf8 = [_]u8{ 0 } ** 4;
				encodeUtf8(&char_utf8, ch);

				const char_size = utf8Size(char_utf8[0]);
				var j: usize = char_size;

				while (j != 0) : (j -= 1) {
					try self.vec.insert(vec_idx, char_utf8[j - 1]);
				}

				return;
			}

			vec_idx += vec_char_size;
		}
	}

	pub fn insertStr(self: *Self, idx: usize, string: str) memory.allocator.Error!void {
		var i: usize = idx;
		
		for (string) |byte| {
			try self.vec.insert(i, byte);
			i += 1;
		}
	}

	pub fn isEmpty(self: *const Self) bool {
		return self.vec.isEmpty();
	}

	pub fn last(self: *const Self) ?char {
		return self.get(self.len - 1);
	}

	pub fn pop(self: *Self) memory.allocator.Error!char {
		return try self.remove(self.len - 1);
	}

	pub fn push(self: *Self, ch: char) memory.allocator.Error!void {
		try self.insert(self.len, ch);
	}

	pub fn pushStr(self: *Self, string: str) memory.allocator.Error!void {
		try self.insertStr(self.len, string);
	}

	pub fn remove(self: *Self, idx: usize) memory.allocator.Error!char {
		if (idx > self.len) {
			@panic("Index out of bounds");
		}

		var vec_idx: usize = 0;
		var i: usize = 0;

		while (true) : (i += 1) {
			const vec_char = self.vec.get(vec_idx).?.*;
			const vec_char_size = utf8Size(vec_char);

			if (i == idx) {
				var j: usize = vec_char_size;

				while (j != 0) : (j -= 1) {
					_ = try self.vec.remove(vec_idx);
				}

				return vec_char;
			}

			vec_idx += vec_char_size;
		}
	}

	// pub fn replace(self: *Self, from: str, to: str) memory.allocator.Error!void {

	// }
};