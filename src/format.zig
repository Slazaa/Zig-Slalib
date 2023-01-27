const memory = @import("memory.zig");
const slice = @import("slice.zig");
const string = @import("string.zig");

const char = string.char;
const str = string.str;

const Allocator = memory.Allocator;
const String = string.String;
const utf8 = string.utf8;

pub const Error = string.Error || error {
    SingleOpenBracket,
    SingleCloseBracket,
    InvalidKind
};

const HintKind = enum {
    none,
    alt
};

const Hint = struct {
    idx: usize,
    kind: HintKind,
    len: usize
};

fn checkHints(fmt_string: str) Error!usize {
    var count: usize = 0;
    var idx: usize = 0;

    while (true) : (count += 1) {
        const open_bracket = string.find(fmt_string[idx..], "{") orelse {
            if (string.find(fmt_string[idx..], "}")) |_| {
                return Error.SingleCloseBracket;
            } else {
                return count;
            }
        };

        const close_bracket = string.find(fmt_string[idx..], "}") orelse return Error.SingleOpenBracket;

        if (close_bracket < open_bracket) {
            return Error.SingleCloseBracket;
        }

        if (
            open_bracket + 1 != close_bracket and
            !string.equals(fmt_string[idx + open_bracket + 1..close_bracket], "#")
        ) {
            return Error.InvalidKind;
        }

        idx += close_bracket + 1;
    }
}

fn findHint(fmt_string: str) ?Hint {
    const open_bracket = string.find(fmt_string, "{") orelse return null;
    const close_bracket = string.find(fmt_string, "}") orelse unreachable;

    const kind: HintKind = if (open_bracket + 1 == close_bracket) .none else .alt;

    return .{
        .idx = open_bracket,
        .kind = kind,
        .len = if (kind == .none) 2 else 3
    };
} 

pub fn format(dest: *String, comptime fmt: str, args: anytype) Error!void {
    const ArgsType = @TypeOf(args);

    if (@typeInfo(ArgsType) != .Struct) {
        @compileError("Expected tuple, found " ++ @typeName(ArgsType));
    }

    const hint_count = comptime checkHints(fmt) catch |e| 
        @compileError(switch (e) {
            Error.SingleOpenBracket => "Expected '}' after '{'",
            Error.SingleCloseBracket => "Expected '{' before '}'",
            Error.InvalidKind => "Invalid format kind",
            else => unreachable
        });

    if (hint_count != args.len) {
        @compileError("Invalid number of arguments");
    }

    try dest.push(fmt);

    inline for (args) |arg| {
        if (findHint(fmt)) |hint| {
            try dest.removen(hint.idx, hint.len);

            var tmp = String.init(null);
            defer tmp.deinit();

            const ArgType = @TypeOf(arg);
            const arg_type_info = @typeInfo(ArgType);

            if (hint.kind == .none) {
                switch (ArgType) {
                    char, comptime_int, str => try tmp.push(arg),
                    else => try string.String.toString(&tmp, arg)
                }
            } else if (hint.kind == .alt) {
                switch (arg_type_info) {
                    .ComptimeInt, .Int => try string.String.toString(&tmp, arg),
                    else => @compileError("Expected int for alt hint, found " ++ @typeName(ArgType))
                }
            }

            try dest.insert(hint.idx, tmp.asStr());
        }
    }
}
