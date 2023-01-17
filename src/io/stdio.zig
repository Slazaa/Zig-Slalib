const io = @import("../io.zig");
const write_ = @import("write.zig");

const Error = io.Error;
const Write = write_.Write;
const BufWrite = write_.BufWrite;

pub const Stdio = struct {
	const Self = @This();

	write: Write = .{
		.writeFn = writeFn
	},

	fn writeFn(iface: *Write, buffer: []const u8) Error!void {
		_ = iface;
		_ = buffer;

		// TODO
	}
};