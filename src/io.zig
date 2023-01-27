const format = @import("format.zig");
const string = @import("string.zig");
const write = @import("io/write.zig");

const str = string.str;
const String = string.String;

pub const Read = @import("io/read.zig");
pub const Stdio = @import("io/stdio.zig");
pub const BufWriter = write.BufWriter;
pub const Write = write.Write;

pub const stdio = Stdio { };

pub const Error = format.Error || error {
	ReadingFailed,
	WritingFailed
};

pub fn input(dest: *String) Error!void {
	var buffer: [2]u8 = undefined;
	var readNum = try stdio.read.read(&buffer);

	while (readNum == buffer.len) {
		try dest.push(&buffer);
		readNum = try stdio.read.read(&buffer);
	}

	try dest.push(buffer[0..readNum]);
	dest.trimEnd();
}

pub fn print(comptime fmt: str, args: anytype) Error!void {
	var tmp = String.init(null);
	defer tmp.deinit();

	try format.format(&tmp, fmt, args);
	try stdio.write.write(tmp.asStr());
}