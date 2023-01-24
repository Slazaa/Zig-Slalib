const memory = @import("memory.zig");
const slice = @import("slice.zig");
const string = @import("string.zig");

const char = string.char;
const str = string.str;

const Allocator = memory.Allocator;
const String = string.String;

const std = @import("std");

pub const Error = memory.Error || error {
	SingleOpenBracket,
	SingleCloseBracket,
	InvalidKind
};

const Hint = struct {
	idx: usize,
	alt: bool
};

fn checkHints(fmt_string: str) Error!usize {
	var count: usize = 0;
	var idx: usize = 0;

	while (true) : (count += 1) {
		// Check that there is both the opening and the closing braces

		const open_bracket = string.find(fmt_string[idx..], "{") orelse {
			if (string.find(fmt_string[idx..], "}")) |_| {
				return Error.SingleCloseBracket;
			} else {
				return count;
			}
		};

		const close_bracket = string.find(fmt_string[idx..], "}") orelse return Error.SingleOpenBracket;

		// Check that the closing bracket is after the opening one
		if (close_bracket < open_bracket) {
			return Error.SingleCloseBracket;
		}

		// Check that the hint kind is correct
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

	return .{
		.idx = open_bracket,
		.alt = open_bracket + 1 != close_bracket
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
			dest.removen(hint.idx, if (hint.alt) 3 else 2);

			var tmp = String.init(null);
			defer tmp.deinit();

			const ArgType = @TypeOf(arg);
			const arg_type_info = @typeInfo(ArgType);

			if (!hint.alt) {
				switch (ArgType) {
					char, comptime_int, str => try tmp.push(arg),
					else => try string.toString(&tmp, arg)
				}
			} else {
				switch (arg_type_info) {
					.ComptimeInt, .Int => try string.toString(&tmp, arg),
					else => @panic("Expected int for alt hint, found " ++ @typeName(ArgType))
				}
			}

			try dest.insert(hint.idx, tmp.asStr());
		}
	}
}