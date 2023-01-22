const collections = @import("../collections.zig");
const memory = @import("../memory.zig");
const string_ = @import("../string.zig");

const char = string_.char;
const str = string_.str;

const utf8 = string_.utf8;

const Vec = collections.Vec;
const Allocator = memory.Allocator;

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

pub fn count(self: *Self, target: str) usize {
	return string_.count(self.asStr(), target);
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

pub fn getStr(self: *const Self, idx: usize, num: usize) ?str {
	return string_.getStr(self.asStr(), idx, num);
}

pub fn init(allocator: ?*const Allocator) Self {
	return .{ .vec = Vec(u8).init(allocator) };
}

pub fn insert(self: *Self, idx: usize, target: anytype) memory.Error!void {
	if (idx > self.len) @panic("Index out of bounds");

	const TargetType = @TypeOf(target);

	switch (TargetType) {
		str => {
			var vec_idx: usize = 0;
			var i: usize = 0;

			while (true) : (i += 1) {
				if (i == idx) {
					var j: usize = 0;

					for (target) |byte| {
						try self.vec.insert(vec_idx + j, byte);
						j += 1;
					}

					self.len += target.len;

					return;
				}

				vec_idx += utf8.size(self.vec.items[vec_idx]);
			}
		},
		char => {
			var char_utf8 = [_]u8{ 0 } ** 4;
			utf8.encode(&char_utf8, target);

			try self.insert(idx, @as(str, char_utf8[0..utf8.size(char_utf8[0])]));
		},
		else => {
			const target_type_info = @typeInfo(TargetType);

			if (target_type_info == .Pointer and @typeInfo(target_type_info.Pointer.child) == .Array) {
				try self.insert(idx, @as(str, target));
			} else {
				@panic("Expected string or char, found " ++ @typeName(TargetType));
			}
		}
	}
}

pub fn isEmpty(self: *const Self) bool {
	return string_.isEmpty(self.asStr());
}

pub fn pop(self: *Self) memory.Error!char {
	return try self.remove(self.len - 1);
}

pub fn push(self: *Self, target: anytype) memory.Error!void {
	try self.insert(self.len, target);
}

pub fn remove(self: *Self, idx: usize) char {
	if (idx > self.len) @panic("Index out of bounds");

	var vec_idx: usize = 0;
	var i: usize = 0;

	while (true) : (i += 1) {
		const vec_char = self.vec.items[vec_idx];
		const vec_char_size = utf8.size(vec_char);

		if (i == idx) {
			var j: usize = vec_char_size;

			while (j != 0) : (j -= 1) {
				_ = self.vec.remove(vec_idx);
			}

			self.len -= 1;

			return vec_char;
		}

		vec_idx += vec_char_size;
	}
}

pub fn removen(self: *Self, idx: usize, num: usize) void {
	if (idx > self.len) @panic("Index out of bounds");

	var i: usize = 0;
	while (i != num) : (i += 1) _ = self.remove(idx);
}

pub fn removeStr(self: *Self, idx: usize, num: usize) memory.Error!void {
	if (idx >= self.len or idx + num > self.len) @panic("Index out of range");

	var i = idx;

	while (i < idx + num) : (i += 1) {
		_ = try self.remove(idx);
	}
}

pub fn replace(self: *Self, string: str, to: str) memory.Error!void {
	try self.replacen(string, to, string_.count(self.asStr(), string));
}

pub fn replacen(self: *Self, string: str, to: str, num: usize) memory.Error!void {
	var idx: usize = 0;
	var i: usize = 0;

	while (i < num) : (i += 1) {
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