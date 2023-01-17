const memory = @import("memory.zig");
const string = @import("string.zig");

const str = string.str;

const Allocator = memory.allocator.Allocator;
const String = string.string.String;

const std = @import("std");

pub fn format(dest: *String, comptime fmt: str, args: anytype) memory.allocator.Error!void {
	if (@typeInfo(@TypeOf(args)) != .Struct) {
		@panic("Expected tuple, found" ++ @typeName(@TypeOf(args)));
	}

	if (args.len != string.countStr(fmt, "{}") - string.countStr(fmt, "{{")) {
		@panic("Invalid number of arguments");
	}

	dest.clear();
	try dest.pushStr(fmt);

	inline for (args) |arg| {
		var string_arg = String.init(null);
		defer string_arg.deinit();

		_ = arg;

		// TODO
	}
}