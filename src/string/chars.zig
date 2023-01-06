const memory = @import("../memory.zig");

const char = @import("../string.zig").char;
const str = @import("../string.zig").str;

const Clone = @import("../clone.zig").Clone;
const Iterator = @import("../iter.zig").iterator.Iterator;
const Allocator = memory.allocator.Allocator;
const Vec = @import("../collections.zig").vec.Vec;
const String = @import("string.zig").String;

const std = @import("std");

pub fn Chars(comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		target: *const Vec(u8, A),
		idx: usize = 0,

		clone: Clone(Self) = .{
			.clone_fn = cloneFn
		},

		iter: Iterator(char) = .{
			.next_fn = nextFn
		},

		pub fn asStr(self: *const Self) str {
			return self.target.items;
		}

		pub fn count(self: *Self) usize {
			var i: usize = 0;

			while (self.iter.next()) |_| {
				i += 1;
			}

			return i;
		}

		pub fn get(self: *Self, idx: usize) ?char {
			var i: usize = 0;

			while (self.iter.next()) |ch| {
				if (i == idx) {
					return ch;
				}

				i += 1;
			}
		}

		pub fn last(self: *Self) ?char {
			var res = null;

			while (self.iter.next()) |ch| {
				res = ch;
			}

			return res;
		}

		// Clone impl
		fn cloneFn(clone_iface: *const Clone(Self)) Self {
			const self = @fieldParentPtr(Self, "clone", clone_iface);
			return .{
				.target = self.target,
				.idx = self.idx
			};
		}

		// Iterator impl
		fn nextFn(iter_iface: *Iterator(Self, char)) ?char {
			const self = @fieldParentPtr(Self, "iter", iter_iface);
			const byte = self.target.get(self.idx) orelse return null;
			const char_size = utf8Size(byte.*);

			const curr_idx = self.idx;
			self.idx += char_size;

			return decodeUtf8(self.target.getSlice(curr_idx, curr_idx + char_size) orelse return null);
		}
	};
}

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