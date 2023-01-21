const string = @import("../string.zig");

const char = string.char;
const str = string.str;

pub fn size(header_byte: char) u3 {
	const byte_template = 0b1000_0000;
	var header_byte_val = header_byte;
	var res: u3 = 0;

	while (header_byte_val & byte_template == byte_template) {
		res += 1;
		header_byte_val <<= 1;
	}

	return
		if (res == 0) 1
		else res;
}

pub fn decode(bytes: str) ?char {
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

pub fn encode(dest: []u8, ch: char) void {
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