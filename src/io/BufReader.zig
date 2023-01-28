const collections = @import("../collections.zig");
const io = @import("../io.zig");
const memory = @import("../memory.zig");

const Read = @import("Read.zig");
const Vec = collections.Vec;
const Allocator = memory.Allocator;

const Self = @This();

reader: *const Read,
buffer: Vec(u8),

pub fn deinit(self: *Self) void {
    self.buffer.deinit();
}

pub fn init(allocator: ?Allocator, reader: *const Read) Self {
    return .{
        .reader = reader,
        .buffer = Vec(u8).init(allocator)
    };
}

pub fn withCapacity(allocator: ?Allocator, reader: *const Read, cap: usize) collections.Error!Self {
    return .{
        .reader = reader,
        .buffer = try Vec(u8).withCapacity(allocator, cap)
    };
}
