const collections = @import("../collections.zig");
const io = @import("../io.zig");
const memory = @import("../memory.zig");

const Write = @import("Write.zig");
const Vec = collections.Vec;
const Allocator = memory.Allocator;

const Self = @This();

writer: *const Write,
buffer: Vec(u8),

pub fn deinit(self: *Self) void {
    self.buffer.deinit();
}

pub fn flush(self: *Self) io.Error!void {
    try self.writer.write(self.buffer.items);
    self.buffer.clear();
}

pub fn init(allocator: ?Allocator, writer: *const Write) Self {
    return .{
        .writer = writer,
        .buffer = Vec(u8).init(allocator)
    };
}

pub fn withCapacity(allocator: ?Allocator, writer: *const Write, cap: usize) collections.Error!Self {
    return .{
        .writer = writer,
        .buffer = try Vec(u8).withCapacity(allocator, cap)
    };
}

pub fn write(self: *Self, buffer: []const u8) collections.Error!void {
    try self.buffer.push(buffer);
}