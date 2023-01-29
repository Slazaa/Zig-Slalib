const collections = @import("../collections.zig");
const io = @import("../io.zig");
const memory = @import("../memory.zig");

const Vec = collections.Vec;
const Error = io.Error;
const Allocator = memory.Allocator;

const Self = @This();

writeFn: *const fn (self: *const Self, buffer: []const u8) Error!void,

pub fn write(self: *const Self, buffer: []const u8) Error!void {
    return self.writeFn(self, buffer);
}