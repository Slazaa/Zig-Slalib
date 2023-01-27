const memory = @import("memory.zig");

pub const Vec = @import("collections/vec.zig").Vec;

pub const Error = memory.Error || error {
    IndexOutOfBounds
};
