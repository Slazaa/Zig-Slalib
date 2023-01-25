const bultin = @import("builtin");

const io = @import("../io.zig");

const Error = io.Error;
const Read = io.Read;
const Write = io.Write;
const BufWriter = io.BufWriter;

const Self = @This();

read: Read = .{
	.readFn = readFn
},

write: Write = .{
	.writeFn = writeFn
},

fn readFn(iface: *const Read, buffer: []u8) Error!void {
	_ = iface;

	switch (bultin.os.tag) {
		.windows => {
			const windows = @cImport({
				@cInclude("windows.h");
			});

			const std_out = windows.GetStdHandle(windows.STD_OUTPUT_HANDLE);

			if (std_out == null or std_out == windows.INVALID_HANDLE_VALUE) {
				return Error.ReadingFailed;
			}

			var readNum: u32 = 0;

			if (windows.ReadConsoleA(std_out, buffer.ptr, @intCast(c_ulong, buffer.len), &readNum, null) == 0) {
				return Error.ReadingFailed;
			}
		},
		else => @compileError("OS not supported")
	}
}

fn writeFn(iface: *const Write, buffer: []const u8) Error!void {
	_ = iface;
	
	switch (bultin.os.tag) {
		.windows => {
			const windows = @cImport({
				@cInclude("windows.h");
			});

			const std_out = windows.GetStdHandle(windows.STD_OUTPUT_HANDLE);

			if (std_out == null or std_out == windows.INVALID_HANDLE_VALUE) {
				return Error.WritingFailed;
			}

			var written: u32 = 0;

			if (windows.WriteConsoleA(std_out, buffer.ptr, @intCast(c_ulong, buffer.len), &written, null) == 0) {
				return Error.WritingFailed;
			}
		},
		else => @compileError("OS not supported")
	}
}