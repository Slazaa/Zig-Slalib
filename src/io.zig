pub const read = @import("io/read.zig");
pub const stdio = @import("io/stdio.zig");

pub const Error = error {
	FlushFailed,
	WriteFailed
};