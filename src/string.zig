pub const char = u21;
pub const str = []const u8;

pub const String = @import("string/string.zig");
pub const utf8 = @import("string/utf8.zig");

const math = @import("math.zig");
const memory = @import("memory.zig");
const slice = @import("slice.zig");

pub fn count(self: str, target: anytype) usize {
	return slice.count(u8, self, target);
}

pub fn equals(self: str, string: str) bool {
	return slice.equals(u8, self, string);
}

pub fn find(self: str, target: anytype) ?usize {
	return slice.find(u8, self, target);
}

pub fn floatToString(dest: *String, num: f64, precision: usize, base: usize) memory.Error!void {
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

pub fn intToString(dest: *String, num: isize, base: usize) memory.Error!void {
	var num_val = @intCast(usize, math.abs(num));

	while (num_val != 0) {
		var ch = @truncate(char, num_val % base);
		ch += switch (ch) {
			0...9 => 48,
			10...35 => 65 - 10,
			else => 0
		};

		try dest.insert(0, ch);
		num_val /= base;
	}

	if (num < 0) try dest.insert(0, '-');
}

pub fn isEmpty(self: str) bool {
	slice.isEmpty(u8, self);
}

pub fn toString(dest: *String, target: anytype) memory.Error!void {
	const TargetType = @TypeOf(target);
	const target_type_info = @typeInfo(TargetType);

	switch (target_type_info) {
		.Array => |info| try toString(dest, @as([]const info.child, &target)),
		.Bool => try dest.push(if (target) "true" else "false"),
		.ComptimeFloat,
		.Float => try floatToString(dest, @as(f64, target), 16, 10),
		.Enum => @compileError("Not implemented yet"), // TODO
		.ComptimeInt,
		.Int => try intToString(dest, @as(isize, target), 10),
		.NoReturn => try dest.push("no_return"),
		.Null => try dest.push("null"),
		.Optional => try toString(dest, target.?),
		.Pointer => |info| {
			switch (TargetType) {
				[]info.child,
				[]const info.child => {
					if (info.child == u8) {
						try dest.push(target);
					} else {
						try dest.push('[');

						var res = String.init(null);
						defer res.deinit();

						for (target) |item| {
							res.clear();

							try dest.push(' ');
							try toString(&res, item);

							try dest.push(res.asStr());
							try dest.push(',');
						}

						_ = try dest.pop();
						try dest.push(" ]");
					}
				},
				else => {
					try intToString(dest, @intCast(isize, @ptrToInt(&target)), 16);
					try dest.insert(0, "0x");
				}
			}
		},
		.Struct => @compileError("Not implemented yet"), // TODO
		.Type => try dest.push(@typeName(target)),
		.Union => @compileError("Not implemented yet"), // TODO
		.Vector => @compileError("Not implemented yet"), // TODO
		else => @compileError("Invalid type, found " ++ @typeName(TargetType))
	}
}

pub fn matches(self: str, targets: []const str) bool {
	return slice.matches(u8, self, targets);
}