const collections = @import("../collections.zig");
const math = @import("../math.zig");
const memory = @import("../memory.zig");
const string = @import("../string.zig");

const char = string.char;
const str = string.str;

const utf8 = string.utf8;

const Vec = collections.Vec;
const Allocator = memory.Allocator;
const Error = string.Error;

const Self = @This();

vec: Vec(u8),
len: usize = 0,

pub fn asStr(self: *const Self) str {
    return self.vec.items;
}

pub fn clear(self: *Self) void {
    self.vec.clear();
    self.len = 0;
}

pub fn count(self: *Self, target: str) usize {
    return string.count(self.asStr(), target);
}

pub fn deinit(self: *Self) void {
    self.vec.deinit();
}

pub fn find(self: *const Self, target: str) ?usize {
    return string.find(self.asStr(), target);
}

pub fn floatToString(dest: *Self, num: f64, precision: usize, base: usize) Error!void {
    dest.clear();

    var num_val = @floatToInt(usize, math.abs(num) * math.pow.pow(@as(f64, 10), @intToFloat(f64, precision)));
    var foundNonZero = false;
    var i: usize = 0;

    while (num_val != 0) : (i += 1) {
        var ch = @truncate(char, num_val % base);

        if (foundNonZero) {
            ch += switch (ch) {
                0...9 => 48,
                10...35 => 65 - 10,
                else => 0
            };

            if (i == precision) {
                try dest.pushFront('.');
            }

            try dest.pushFront(ch);
        } else if (ch != 0) {
            foundNonZero = true;
        }

        num_val /= base;
    }

    if (num < 0) {
        try dest.pushFront('-');
    }
}

pub fn from(allocator: ?*const Allocator, target: str) Error!Self {
    return .{
        .vec = try Vec(u8).from(allocator, target),
        .len = target.len
    };
}

pub fn get(self: *const Self, idx: usize) ?char {
    return string.get(self.asStr(), idx);
}

pub fn getStr(self: *const Self, idx: usize, num: usize) ?str {
    return string.getStr(self.asStr(), idx, num);
}

pub fn init(allocator: ?*const Allocator) Self {
    return .{ .vec = Vec(u8).init(allocator) };
}

pub fn insert(self: *Self, idx: usize, target: anytype) Error!void {
    if (idx > self.len) {
        return Error.IndexOutOfBounds;
    }

    const TargetType = @TypeOf(target);

    switch (TargetType) {
        []u8,
        str => {
            var vec_idx: usize = 0;
            var i: usize = 0;

            while (true) : (i += 1) {
                if (i == idx) {
                    var j: usize = 0;

                    for (target) |byte| {
                        try self.vec.insert(vec_idx + j, byte);
                        j += 1;
                    }

                    self.len += target.len;

                    return;
                }

                vec_idx += utf8.size(self.vec.items[vec_idx]);
            }
        },
        char => {
            var char_utf8 = [_]u8{ 0 } ** 4;
            utf8.encode(&char_utf8, target);

            try self.insert(idx, @as(str, char_utf8[0..utf8.size(char_utf8[0])]));
        },
        comptime_int => try self.insert(idx, @as(char, target)),
        else => {
            const target_type_info = @typeInfo(TargetType);

            if (target_type_info == .Pointer and @typeInfo(target_type_info.Pointer.child) == .Array) {
                try self.insert(idx, @as(str, target));
            } else {
                @compileError("Expected string or char, found " ++ @typeName(TargetType));
            }
        }
    }
}

pub fn intToString(dest: *Self, num: isize, base: usize) Error!void {
    var num_val = @intCast(usize, math.abs(num));

    while (num_val != 0) {
        var ch = @truncate(char, num_val % base);
        ch += switch (ch) {
            0...9 => 48,
            10...35 => 65 - 10,
            else => 0
        };

        try dest.insert(0, ch);
        num_val /= base;
    }

    if (num < 0) try dest.insert(0, '-');
}

pub fn isEmpty(self: *const Self) bool {
    return string.isEmpty(self.asStr());
}

pub fn last(self: *const Self) ?char {
    return self.get(self.len - 1);
}

pub fn pop(self: *Self) ?char {
    if (self.len == 0) {
        return null;
    }

    return self.remove(self.len - 1) catch unreachable;
}

pub fn push(self: *Self, target: anytype) Error!void {
    try self.insert(self.len, target);
}

pub fn remove(self: *Self, idx: usize) Error!char {
    if (idx > self.len) {
        return Error.IndexOutOfBounds;
    }

    var vec_idx: usize = 0;
    var i: usize = 0;

    while (true) : (i += 1) {
        const vec_char = self.vec.items[vec_idx];
        const vec_char_size = utf8.size(vec_char);

        if (i == idx) {
            var j: usize = vec_char_size;

            while (j != 0) : (j -= 1) {
                _ = try self.vec.remove(vec_idx);
            }

            self.len -= 1;

            return vec_char;
        }

        vec_idx += vec_char_size;
    }
}

pub fn removen(self: *Self, idx: usize, num: usize) Error!void {
    if (idx > self.len) {
        return Error.IndexOutOfBounds;
    }

    var i: usize = 0;

    while (i != num) : (i += 1) {
        _ = try self.remove(idx);
    }
}

pub fn removeStr(self: *Self, idx: usize, num: usize) Error!void {
    if (idx >= self.len or idx + num > self.len) {
        return Error.IndexOutOfBounds;
    }

    var i = idx;

    while (i < idx + num) : (i += 1) {
        _ = try self.remove(idx);
    }
}

pub fn replace(self: *Self, target: str, to: str) Error!void {
    try self.replacen(target, to, string.count(self.asStr(), target));
}

pub fn replacen(self: *Self, target: str, to: str, num: usize) Error!void {
    var idx: usize = 0;
    var i: usize = 0;

    while (i < num) : (i += 1) {
        if (string.find(self.asStr()[idx..], target)) |string_idx| {
            idx += string_idx;

            try self.removeStr(idx, target.len);
            try self.insertStr(idx, to);

            idx += to.len;
        } else {
            break;
        }
    }
}

pub fn toChars(self: *const Self, dest: []char) Error!void {
    return string.toChars(self.items, dest);
}

pub fn toString(dest: *Self, target: anytype) Error!void {
    const TargetType = @TypeOf(target);
    const target_type_info = @typeInfo(TargetType);

    switch (target_type_info) {
        .Array => |info| try toString(dest, @as([]const info.child, &target)),
        .Bool => try dest.push(if (target) "true" else "false"),
        .ComptimeFloat,
        .Float => try Self.floatToString(dest, @as(f64, target), 16, 10),
        .Enum => @compileError("Not implemented yet"), // TODO
        .ComptimeInt,
        .Int => try Self.intToString(dest, @as(isize, target), 10),
        .NoReturn => try dest.push("no_return"),
        .Null => try dest.push("null"),
        .Optional => try Self.toString(dest, target.?),
        .Pointer => |info| {
            switch (TargetType) {
                []info.child,
                []const info.child => {
                    switch (info.child) {
                        u8 => try dest.push(target),
                        else => {
                            try dest.push('[');

                            var res = Self.init(null);
                            defer res.deinit();

                            for (target) |item| {
                                res.clear();

                                try dest.push(' ');
                                try toString(&res, item);

                                try dest.push(res.asStr());
                                try dest.push(',');
                            }

                            _ = try dest.pop();
                            try dest.push(" ]");
                        }
                    }
                },
                else => {
                    const array_type_info = @typeInfo(info.child);

                    if (array_type_info == .Array) {
                        try toString(dest, @as([]const array_type_info.Array.child, target));
                    } else {
                        try intToString(dest, @intCast(isize, @ptrToInt(&target)), 16);
                        try dest.insert(0, "0x");
                    }
                }
            }
        },
        .Struct => @compileError("Not implemented yet"), // TODO
        .Type => try dest.push(@typeName(target)),
        .Union => @compileError("Not implemented yet"), // TODO
        .Vector => @compileError("Not implemented yet"), // TODO
        else => @compileError("Invalid type, found " ++ @typeName(TargetType))
    }
}

pub fn trimEnd(self: *Self) void {
    while (self.last()) |ch| {
        if (string.contains(" \n\t\r", ch)) {
            _ = self.pop();
        }
    }
}
