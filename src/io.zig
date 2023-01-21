const string = @import("string.zig");

const str = string.str;

pub const Stdio = @import("io/stdio.zig");

const write = @import("io/write.zig");
pub const BufWriter = write.BufWriter;
pub const Write = write.Write;

pub const Error = error {
	WritingFailed
};

pub fn print(comptime fmt: str, args: anytype) Error!void {
	_ = args;

	const stdio = Stdio { };
	try stdio.write.write(fmt);
}

pub fn println(comptime fmt: str, args: anytype) Error!void {
	try print(fmt ++ "\n", args);
}