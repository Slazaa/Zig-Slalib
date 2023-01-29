pub const char = u21;
pub const str = []const u8;

pub const String = @import("string/String.zig");
pub const StringIter = @import("string/StringIter.zig");
pub const utf8 = @import("string/utf8.zig");

const assert = @import("assert.zig");
const collections = @import("collections.zig");
const memory = @import("memory.zig");
const slice = @import("slice.zig");

pub const Error = collections.Error || error {
    BufferNotLargeEnough
};

pub fn contains(self: str, target: anytype) bool {
    return find(self, target) != null;
}

pub fn count(self: str, target: anytype) usize {
    return slice.count(u8, self, target);
}

pub fn equals(self: str, target: str) bool {
    return slice.equals(u8, self, target);
}

pub fn find(self: str, target: anytype) ?usize {
    const TargetType = @TypeOf(target);

    if (TargetType == char) {
        var buffer = [_]u8{ 0 } ** 4;
        utf8.encode(&buffer, target);

        return slice.find(u8, self, &buffer);
    } else {
        return slice.find(u8, self, target);
    }
}

pub fn get(self: str, idx: usize) ?char {
    if (getStr(self, idx, 1)) |str_res| {
        return utf8.decode(str_res);
    }

    return null;
}

pub fn getStr(self: str, idx: usize, num: usize) ?str {
    if (idx >= self.len or idx + num > self.len) {
        return null;
    }

    var start_res: usize = 0;
    var end_res: usize = 0;

    var vec_idx: usize = 0;
    var i: usize = 0;

    while (true) : (i += 1) {
        const ch = self[vec_idx];
        const vec_char_size = utf8.size(ch);

        if (i == idx) {
            start_res = vec_idx;
            end_res = start_res;
        }
        
        if (i >= idx) {
            var char_utf8 = [_]u8{ 0 } ** 4;
            utf8.encode(&char_utf8, ch);

            const char_size = utf8.size(char_utf8[0]);
            end_res += char_size;

            if (i == idx + num - 1) {
                return self[start_res..end_res];
            }
        }

        vec_idx += vec_char_size;
    }
}

pub fn isEmpty(self: str) bool {
    return slice.isEmpty(u8, self);
}

pub fn toChars(self: str, dest: []char) Error!void {
    if (dest.len < self.len) {
        return Error.BufferNotLargeEnough;
    }

    var vec_idx: usize = 0;
    var i: usize = 0;

    while (i != self.len) : (i += 1) {
        const ch = self[vec_idx];
        const vec_char_size = utf8.size(ch);

        dest[i] = utf8.decode(self[vec_idx..vec_idx + vec_char_size]) orelse unreachable;

        vec_idx += vec_char_size;
    }
}

test "getStr" {
    const string = "Hello!";

    try assert.expect(equals(getStr(string, string.len - 1, 1).?, "!"));
}
