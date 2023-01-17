pub const char = u21;
pub const str = []const u8;

pub const string = @import("string/string.zig");
pub const utf8 = @import("string/utf8.zig");

const math = @import("math.zig");
const memory = @import("memory.zig");

const String = string.String;

pub fn countStr(self: str, target: str) usize {
	var count: usize = 0;
	var idx: usize = 0;

	while (find(self[idx..], target)) |string_idx| {
		count += 1;
		idx += string_idx + target.len;
	}

	return count;
}

pub fn find(self: str, target: str) ?usize {
	var i: usize = 0;
		
	while (i + target.len - 1 < self.len) : (i += 1) {
		if (memory.compare(self[i..i + target.len].ptr, target.ptr, target.len) == .Equal) {
			return i;
		}
	}

	return null;
}

pub fn floatToString(dest: *String, num: f64, precision: usize, base: usize) memory.allocator.Error!void {
	dest.clear();

	var num_val = @floatToInt(usize, math.abs(num) * math.pow.pow(@as(f64, 10), @intToFloat(f64, precision)));
	var foundNonZero = false;
	var i: usize = 0;

	while (num_val != 0) : (i += 1) {
		var ch = @truncate(char, num_val % base);

		if (!foundNonZero and ch != 0) {
			foundNonZero = true;
		} else if (foundNonZero) {
			ch += switch (ch) {
				0...9 => 48,
				10...35 => 65 - 10,
				else => 0
			};

			if (i == precision) {
				try dest.pushFront('.');
			}

			try dest.pushFront(ch);
		}

		num_val /= base;
	}

	if (num < 0) {
		try dest.pushFront('-');
	}
}

pub fn get(self: str, idx: usize) ?char {
	return if (getStr(self, idx, 1)) |str_res|
		utf8.decode(str_res)
	else
		null;
}

pub fn getStr(self: str, idx: usize, count: usize) ?str {
	if (idx >= self.len or idx + count > self.len) {
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

			if (i == idx + count) {
				return self[start_res..end_res];
			}
		}

		vec_idx += vec_char_size;
	}
}

pub fn intToString(dest: *String, num: isize, base: usize) memory.allocator.Error!void {
	dest.clear();

	var num_val = @intCast(usize, math.abs(num));

	while (num_val != 0) {
		var ch = @truncate(char, num_val % base);
		ch += switch (ch) {
			0...9 => 48,
			10...35 => 65 - 10,
			else => 0
		};

		try dest.pushFront(ch);
		num_val /= base;
	}

	if (num < 0) {
		try dest.pushFront('-');
	}
}

pub fn isEmpty(self: str) bool {
	return self.len == 0;
}

pub fn last(self: str) ?char {
	return self[self.len - 1];
}

pub fn toString(dest: *String, target: anytype) memory.allocator.Error!void {
	const TargetType = @TypeOf(target);
	const type_info = @typeInfo(TargetType);

	switch (type_info) {
		.Array => {
			try dest.push('[');

			var res = String.init(null);
			defer res.deinit();

			for (target) |item| {
				res.clear();

				try dest.push(' ');
				try toString(&res, item);

				try dest.pushStr(res.asStr());
				try dest.push(',');
			}

			_ = try dest.pop();
			try dest.pushStr(" ]");
		},
		.Bool => try dest.pushStr(if (target) "true" else "false"),
		.ComptimeFloat,
		.Float => try floatToString(dest, @as(f64, target), 16, 10),
		.Enum => @panic("Not implemented yet"), // TODO
		.ComptimeInt,
		.Int => try intToString(dest, @as(isize, target), 10),
		.Null => try dest.pushStr("null"),
		.Pointer => {
			try intToString(dest, @intCast(isize, @ptrToInt(target)), 16);
			try dest.pushStrFront("0x");
		},
		.Struct => @panic("Not implemented yet"), // TODO
		.Type => try dest.pushStr(@typeName(target)),
		.Undefined => try dest.pushStr("undefined"),
		.Union => @panic("Not implemented yet"), // TODO
		.Vector => @panic("Not implemented yet"), // TODO
		else => @panic("Invalid type, found " ++ @typeName(TargetType))
	}
}