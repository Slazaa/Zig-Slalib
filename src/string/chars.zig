const iter = @import("../iter.zig");
const memory = @import("../memory.zig");

const Allocator = memory.allocator.Allocator;
const Vec = @import("../collections.zig").vec.Vec;
const String = @import("string.zig").String;
const char = @import("../string.zig").char;
const str = @import("../string.zig").str;

const std = @import("std");

pub fn Chars(comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		target: *const Vec(u8, A),
		idx: usize = 0,

		iter: iter.Iterator(char) = . {
			.next_fn = nextFn
		},

		fn utf8Size(header_byte: u8) u3 {
			const byte_template = 0b10000000;
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

		fn utf8ToChar(bytes: []const u8) ?char {
			if (bytes.len == 0) {
				return null;
			}

			if (bytes.len == 1) {
				return bytes[0];
			}

			var res: char = 0;

			const byte_template = 0b00000001;
			var shift_left: u3 = 6;

			var bytes_left: u2 = @intCast(u2, bytes.len - 1);
			var byte: u8 = undefined;

			while (bytes_left != 0) : (bytes_left -= 1) {
				shift_left = 6;
				byte = bytes[bytes_left];

				while (shift_left != 0) : (shift_left -= 1) {
					res <<= 1;
					res |= byte & byte_template;
					byte >>= 1;
				}
			}

			shift_left = @intCast(u3, 6 - (bytes.len + 1));
			byte = bytes[0];

			while (shift_left != 0) : (shift_left -= 1) {
				res <<= 1;
				res |= byte & byte_template;
				byte >>= 1;
			}

			return res;
		}

		pub fn asStr(self: *const Self) str {
			return self.target.items;
		}

		pub fn get(self: *const Self, idx: usize) ?char {
			// TODO

			_ = self;
			_ = idx;

			@panic("Function not implemented yet");
		}

		// Iterator impl
		pub fn nextFn(iter_iface: *iter.Iterator(char)) ?char {
			const self = @fieldParentPtr(Self, "iter", iter_iface);
			const byte = self.target.get(self.idx) orelse return null;
			const char_size = Self.utf8Size(byte.*);

			const curr_idx = self.idx;
			self.idx += char_size;

			return Self.utf8ToChar(self.target.getSlice(curr_idx, curr_idx + char_size) orelse return null);
		}
	};
}