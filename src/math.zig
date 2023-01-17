pub const expo = @import("math/expo.zig");
pub const hyper = @import("math/hyper.zig");
pub const pow = @import("math/pow.zig");
pub const round = @import("math/round.zig");
pub const trigo = @import("math/trigo.zig");

const c = @cImport({
	@cInclude("math.h");
	@cInclude("stdlib.h");
});

pub const e = c.M_E;
pub const pi = c.M_PI;

pub fn abs(value: anytype) @TypeOf(value) {
	const T = @TypeOf(value);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			64 => c.fabs(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		.Int => |int_type| switch (int_type.bits) {
			32 => c.labs(value),
			64 => c.llabs(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected int or float, found " ++ @typeName(T))
	};
}