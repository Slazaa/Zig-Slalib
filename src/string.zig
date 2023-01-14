pub const char = u21;
pub const str = []const u8;

pub const string = @import("string/string.zig");

const memory = @import("memory.zig");

const String = string.String;

const std = @import("std");

// ----- UTF-8 -----
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

pub fn encodeUtf8(dest: []u8, ch: char) void {
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
		dest[0] = @truncate(u8, ch);
		return;
	}

	ch_value = ch;
	
	var char_idx = char_size - 1;

	while (char_idx != 0) : (char_idx -= 1) {
		dest[char_idx] = 0b1000_0000 | (@truncate(u8, ch_value) & 0b0011_1111);
		ch_value >>= 6;
	}

	dest[char_idx] = switch (char_size) {
		2 => 0b1100_0000 | (@truncate(u8, ch_value) & 0b0001_1111),
		3 => 0b1110_0000 | (@truncate(u8, ch_value) & 0b0000_1111),
		4 => 0b1111_0000 | (@truncate(u8, ch_value) & 0b0000_0111),
		else => @panic("Invalid char index")
	};
}

// ----- Str -----
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

pub fn get(self: str, idx: usize) ?char {
	return getStr(self, idx, 1);
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
		const vec_char_size = utf8Size(ch);

		if (i == idx) {
			start_res = vec_idx;
			end_res = start_res;
		}
		
		if (i >= idx) {
			var char_utf8 = [_]u8{ 0 } ** 4;
			encodeUtf8(&char_utf8, ch);

			const char_size = utf8Size(char_utf8[0]);
			end_res += char_size;

			if (i == idx + count) {
				return self[start_res..end_res];
			}
		}

		vec_idx += vec_char_size;
	}
}

pub fn intToString(dest: *String, num: usize, base: usize) memory.allocator.Error!void {
	dest.clear();

	var num_val = num; 

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
		.ComptimeInt, .Int => try intToString(dest, @as(usize, target), 10),
		.Null => try dest.pushStr("null"),
		.Pointer => {
			try intToString(dest, @ptrToInt(target), 16);
			try dest.pushStrFront("0x");
		},
		.Struct => {
			const struct_type = @typeName(TargetType);

			if (memory.compare(struct_type, "string.string.String", struct_type.len) == .Equal) {
				try dest.pushStr(target.asStr());
			}
		},
		.Type => try dest.pushStr(@typeName(target)),
		else => @panic("Invalid type, found " ++ @typeName(TargetType))
	}
}