const string = @import("../string.zig");

const char = string.char;

const String = string.String;

const Self = @This();

target: []u21,
idx: usize = 0,

pub fn next(self: *Self) ?char {
	if (self.idx >= self.target.len) {
		return null;
	}

	const res = self.target[self.idx];
	self.idx += 1;

	return res;
}