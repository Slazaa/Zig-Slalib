const Error = @import("../io.zig").Error;
const Read = @import("read.zig").Read;
const Write = @import("write.zig").Write;

pub const Stdin = struct {
	const Self = @This();

	pub const read = Read {
		.read_fn = readFn
	};

	fn readFn(read_iface: *const Read, buf: []u8) Error!usize {
		// TODO: - Read from stdin

		_ = read_iface;
		_ = buf;

		@panic("Function not implemented yet");
	}
};

pub const Stdout = struct {
	const Self = @This();

	pub const write = Write {
		.write_fn = writeFn,
		.flush_fn = flushFn
	};

	fn writeFn(write_iface: *const Write, buf: []const u8) Error!usize {
		// TODO: - Write to stdout

		_ = write_iface;
		_ = buf;

		@panic("Function not implemented yet");
	}

	fn flushFn(write_iface: *const Write) Error!void {
		// TODO: - Flush stdout

		_ = write_iface;

		@panic("Function not implemented yet");
	}
};

pub fn print(buf: []const u8) void {
	_ = buf;
	
	@panic("Function not implemented yet");
}

pub fn println(buf: []const u8) void {
	_ = buf;

	@panic("Function not implemented yet");
}