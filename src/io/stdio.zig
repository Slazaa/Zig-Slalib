const bultin = @import("builtin");

const io = @import("../io.zig");

const Error = io.Error;
const Write = io.Write;
const BufWriter = io.BufWriter;

const Self = @This();

write: Write = .{
	.writeFn = writeFn
},

fn writeFn(iface: *const Write, buffer: []const u8) Error!void {
	_ = iface;
	
	switch (bultin.os.tag) {
		.windows => {
			const windows = @cImport({ @cInclude("windows.h"); });

			const std_out = windows.GetStdHandle(windows.STD_OUTPUT_HANDLE);
			if (std_out == null or std_out == windows.INVALID_HANDLE_VALUE) return Error.WritingFailed;

			var written: u32 = 0;
			_ = windows.WriteConsoleA(std_out, buffer.ptr, @intCast(c_ulong, buffer.len), &written, null);
		},
		else => @panic("OS not supported")
	}
}