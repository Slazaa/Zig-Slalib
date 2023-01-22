const format_ = @import("format.zig");
const string = @import("string.zig");

const str = string.str;

const format = format_.format;
const String = string.String;

pub const Stdio = @import("io/stdio.zig");

const write = @import("io/write.zig");
pub const BufWriter = write.BufWriter;
pub const Write = write.Write;

pub const Error = format_.Error || error {
	WritingFailed
};

pub fn print(comptime fmt: str, args: anytype) Error!void {
	var tmp = String.init(null);
	defer tmp.deinit();

	try format(&tmp, fmt, args);

	const stdio = Stdio { };
	try stdio.write.write(tmp.asStr());
}

pub fn println(comptime fmt: str, args: anytype) Error!void {
	try print(fmt ++ "\n", args);
}