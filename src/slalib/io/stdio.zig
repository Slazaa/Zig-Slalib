const Error = @import("error.zig").Error;
const Read = @import("read.zig").Read;
const Write = @import("write.zig").Write;

const builtin = @import("builtin");
const c = @cImport({
    @cInclude("stdio.h");
});

const c_stdout = c.stdout;

pub fn stdin() type {
    return struct {
        const Self = @This();

        read: Read = .{
            .read_fn = read
        },

        fn read(read_iface: *const Read, buf: []u8) Error!usize {
            // TODO: - Read from Stdin

            _ = read_iface;
            _ = buf;

            @panic("Function not implemented yet");
        }
    };
}

pub fn stdout() type {
    return struct {
        const Self = @This();

        write: Write = .{
            .write_fn = write,
            .flush_fn = flush
        },

        fn write(write_iface: *const Write, buf: []const u8) Error!usize {
            _ = write_iface;
            _ = buf;

            @panic("Function not implemented yet");
        }

        fn flush(write_iface: *const Write) Error!void {
            _ = write_iface;

            if (c.fflush(c_stdout) == c.EOF) {
                return Error.FlushFailed;
            }
        }
    };
}

pub fn print(buf: []const u8) void {
    _ = stdout().write.write(buf) catch @panic("Failed to write");
    stdout().write.flush() catch @panic("Failed to flush");
}

pub fn println(buf: []const u8) void {
    _ = stdout().write.write(buf) catch @panic("Failed to write");
    _ = stdout().write.write("\n") catch @panic("Failed to write");
    stdout().write.flush() catch @panic("Failed to flush");
}