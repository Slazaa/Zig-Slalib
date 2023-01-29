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

fn readFn(iface: *const Read, buffer: []u8) Error!usize {
    _ = iface;

    switch (bultin.os.tag) {
        .windows => {
            const c = @cImport({
                @cInclude("windows.h");
            });

            const stdin = c.GetStdHandle(c.STD_INPUT_HANDLE);

            if (stdin == null or stdin == c.INVALID_HANDLE_VALUE) {
                return Error.ReadingFailed;
            }

            var readNum: c_ulong = 0;

            if (c.ReadConsoleA(stdin, buffer.ptr, @intCast(c_ulong, buffer.len), &readNum, null) == 0) {
                return Error.ReadingFailed;
            }

            return readNum;
        },
        else => @compileError("OS not supported")
    }
}

fn writeFn(iface: *const Write, buffer: []const u8) Error!void {
    _ = iface;
    
    switch (bultin.os.tag) {
        .windows => {
            const c = @cImport({
                @cInclude("windows.h");
            });

            const stdout = c.GetStdHandle(c.STD_OUTPUT_HANDLE);

            if (stdout == null or stdout == c.INVALID_HANDLE_VALUE) {
                return Error.WritingFailed;
            }

            if (c.SetConsoleOutputCP(65001) == 0) {
                return Error.WritingFailed;
            }

            var written: c_ulong = 0;

            if (c.WriteConsoleA(stdout, buffer.ptr, @intCast(c_ulong, buffer.len), &written, null) == 0) {
                return Error.WritingFailed;
            }
        },
        else => @compileError("OS not supported")
    }
}
