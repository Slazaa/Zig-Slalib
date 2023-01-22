const memory = @import("memory.zig");
const slice = @import("slice.zig");
const string = @import("string.zig");

const char = string.char;
const str = string.str;

const Allocator = memory.Allocator;
const String = string.String;

pub const Error = memory.Error || error {
	SingleOpenBracket,
	SingleCloseBracket,
	InvalidKind
};

const Hint = struct {
	idx: usize,
	alt: bool
};

fn checkHints(fmt_string: str) Error!void {
	var idx: usize = 0;

	while (true) {
		// Check that there is both the opening and the closing braces
		const open_bracket = string.find(fmt_string[idx..], "{") orelse return
			if (string.find(fmt_string[idx..], "}") != null) Error.SingleCloseBracket;

		const close_bracket = string.find(fmt_string[idx..], "}") orelse return Error.SingleOpenBracket;

		// Check that the closing bracket is after the opening one
		if (close_bracket < open_bracket) return Error.SingleCloseBracket;

		// Check that the hint kind is correct
		if (
			open_bracket + 1 != close_bracket and
			!string.equals(fmt_string[idx + open_bracket + 1..close_bracket], ".")
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

	if (@typeInfo(ArgsType) != .Struct) @panic("Expected tuple, found" ++ @typeName(ArgsType));

	comptime checkHints(fmt) catch |e| 
		@compileError(switch (e) {
			Error.SingleOpenBracket => "Expected '}' after '{'",
			Error.SingleCloseBracket => "Expected '{' before '}'",
			Error.InvalidKind => "Invalid format kind",
			else => unreachable
		});

	try dest.push(fmt);

	inline for (args) |arg| {
		if (findHint(fmt)) |hint| {
			dest.removen(hint.idx, if (hint.alt) 3 else 2);

			var tmp = String.init(null);
			defer tmp.deinit();

			try string.toString(&tmp, arg);

			try dest.insert(hint.idx, tmp.asStr());
		} else {
			unreachable;
		}
	}
}