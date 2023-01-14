const collections = @import("../collections.zig");
const memory = @import("../memory.zig");
const string_ = @import("../string.zig");

const char = string_.char;
const str = string_.str;

const Vec = collections.vec.Vec;
const Allocator = memory.allocator.Allocator;

const std = @import("std");

pub const String = struct {
	const Self = @This();

	vec: Vec(u8),
	len: usize = 0,

	pub fn asStr(self: *const Self) str {
		return self.vec.items;
	}

	pub fn clear(self: *Self) void {
		self.vec.clear();
		self.len = 0;
	}

	pub fn countStr(self: *Self, target: str) usize {
		return string_.countStr(self.asStr(), target);
	}

	pub fn deinit(self: *Self) void {
		self.vec.deinit();
	}

	pub fn find(self: *const Self, target: str) ?usize {
		return string_.find(self.asStr(), target);
	}

	pub fn from(allocator: ?Allocator, string: string_.str) memory.allocator.Error!Self {
		return .{
			.vec = try Vec(u8).from(allocator, string),
			.len = string.len
		};
	}

	pub fn get(self: *const Self, idx: usize) ?char {
		return string_.get(self.asStr(), idx);
	}

	pub fn getStr(self: *const Self, idx: usize, count: usize) ?str {
		return string_.getStr(self.asStr(), idx, count);
	}

	pub fn init(allocator: ?Allocator) Self {
		return .{
			.vec = Vec(u8).init(allocator)
		};
	}

	pub fn insert(self: *Self, idx: usize, ch: char) memory.allocator.Error!void {
		var char_utf8 = [_]u8{ 0 } ** 4;
		string_.encodeUtf8(&char_utf8, ch);

		try self.insertStr(idx, char_utf8[0..string_.utf8Size(char_utf8[0])]);
	}

	pub fn insertStr(self: *Self, idx: usize, string: str) memory.allocator.Error!void {
		if (idx > self.len) {
			@panic("Index out of bounds");
		}

		var vec_idx: usize = 0;
		var i: usize = 0;

		while (true) : (i += 1) {
			if (i == idx) {
				var j: usize = 0;

				for (string) |byte| {
					try self.vec.insert(vec_idx + j, byte);
					j += 1;
				}

				self.len += string.len;

				return;
			}

			vec_idx += string_.utf8Size(self.vec.get(vec_idx).?.*);
		}
	}

	pub fn isEmpty(self: *const Self) bool {
		return string_.isEmpty(self.asStr());
	}

	pub fn last(self: *const Self) ?char {
		return string_.last(self.asStr());
	}

	pub fn pop(self: *Self) memory.allocator.Error!char {
		return try self.remove(self.len - 1);
	}

	pub fn push(self: *Self, ch: char) memory.allocator.Error!void {
		try self.insert(self.len, ch);
	}

	pub fn pushFront(self: *Self, ch: char) memory.allocator.Error!void {
		try self.insert(0, ch);
	}

	pub fn pushStr(self: *Self, string: str) memory.allocator.Error!void {
		try self.insertStr(self.len, string);
	}
	
	pub fn pushStrFront(self: *Self, string: str) memory.allocator.Error!void {
		try self.insertStr(0, string);
	}

	pub fn remove(self: *Self, idx: usize) memory.allocator.Error!char {
		if (idx > self.len) {
			@panic("Index out of bounds");
		}

		var vec_idx: usize = 0;
		var i: usize = 0;

		while (true) : (i += 1) {
			const vec_char = self.vec.get(vec_idx).?.*;
			const vec_char_size = string_.utf8Size(vec_char);

			if (i == idx) {
				var j: usize = vec_char_size;

				while (j != 0) : (j -= 1) {
					_ = try self.vec.remove(vec_idx);
				}

				self.len -= 1;

				return vec_char;
			}

			vec_idx += vec_char_size;
		}
	}

	pub fn removeStr(self: *Self, idx: usize, count: usize) memory.allocator.Error!void {
		if (idx >= self.len or idx + count > self.len) {
			@panic("Index out of range");
		}

		var i = idx;

		while (i < idx + count) : (i += 1) {
			_ = try self.remove(idx);
		}
	}

	pub fn replace(self: *Self, string: str, to: str) memory.allocator.Error!void {
		try self.replacen(string, to, string_.countStr(self.asStr(), string));
	}

	pub fn replacen(self: *Self, string: str, to: str, count: usize) memory.allocator.Error!void {
		var idx: usize = 0;
		var i: usize = 0;

		while (i < count) : (i += 1) {
			if (string_.find(self.asStr()[idx..], string)) |string_idx| {
				idx += string_idx;
				try self.removeStr(idx, string.len);
				try self.insertStr(idx, to);
				idx += to.len;
			} else {
				break;
			}
		}
	}

	pub fn replaceOnce(self: *Self, string: str, to: str) memory.allocator.Error!void {
		try self.replacen(string, to, 1);
	}
};