const memory = @import("memory.zig");
const string = @import("string.zig");

const str = string.str;

const Allocator = memory.allocator.Allocator;
const String = string.string.String;

const HintError = error {
	SingleOpenBracket,
	SingleCloseBracket,
	InvalidKind
};

pub const ErrorKind = enum {
	Alloc,
	Hint
};

pub const Error = union(ErrorKind) {
	alloc: memory.allocator.Error,
	hint: HintError
};

const HindKind = enum {
	None,
	Char,
	Pointer,
	String
};

const Hint = struct {
	idx: usize,
	kind: HindKind,
	size: usize
};

fn checkHints(fmt_string: str) ?HintError {
	// Check that there is both the opening and the closing braces
	const open_bracket = string.find(fmt_string, "{") orelse return
		if (string.find(fmt_string, "}")) .SingleCloseBracket
		else null;

	const close_bracket = string.find(fmt_string, "}") orelse return .SingleOpenBracket;

	// Check that the closing bracket is after the opening one
	if (close_bracket < open_bracket) {
		return .SingleCloseBracket;
	}

	// Check that the hint kind is correct
	if (
		open_bracket + 1 != close_bracket and
		!string.matches(&fmt_string[open_bracket + 1..close_bracket], &[_]str{ "c", "p", "s" })
	) {
		return .InvalidKind;
	}

	return checkHints(&fmt_string[close_bracket + 1..]);
}

// fn findHint(fmt_string: str) ?Hint {
// 	const open_bracket = string.find(fmt_string, "{") orelse return null;
// 	const close_bracket = string.find(fmt_string, "}") orelse unreachable;

	
// } 

pub fn format(dest: *String, comptime fmt: str, args: anytype) Error!void {
	if (@typeInfo(@TypeOf(args)) != .Struct) {
		@panic("Expected tuple, found" ++ @typeName(@TypeOf(args)));
	}

	checkHints(fmt) catch |e| return .{ .hint = e }; // comptime ?

	dest.pushStr(fmt) catch |e| return .{ .alloc = e };

	// var fmt_slice = &dest[0..];
	// var double_open_braces = false;

	// while (string.find(fmt_slice, "{")) |hint| {
	// 	// Checks if there is a dangling closing bracket
	// 	if (string.find(fmt_slice, "}")) |close_bracket| {
	// 		if (close_bracket < hint and string.get(fmt_slice, close_bracket + 1) != '}') {
	// 			@panic("Expected '{' before '}'");
	// 		}
	// 	}

	// 	if (string.get(fmt_slice, hint + 1)) |next_char| {
	// 		if (next_char == '{') {
	// 			fmt_slice = &fmt_slice[next_char..];
	// 			double_open_braces = true;

	// 			continue;
	// 		}

	// 		if (next_char == '}') {
	// 			var to_insert = String.init(null);
	// 			defer to_insert.deinit();

	// 			try string.toString(&to_insert, );
	// 		}
	// 	} else {
	// 		@panic("Excpected '}' after '{'");
	// 	}
	// }
}