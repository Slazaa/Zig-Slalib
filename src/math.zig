pub const expo = @import("math/expo.zig");
pub const hyper = @import("math/hyper.zig");
pub const pow = @import("math/pow.zig");
pub const trigo = @import("math/trigo.zig");

const c = @cImport({
	@cInclude("math.h");
	@cInclude("stdlib.h");
});

pub const e = c.M_E;
pub const pi = c.M_PI;

pub fn abs(comptime T: type, value: T) T {
	return switch (T) {
		i32 => c.labs(value),
		isize, i64 => c.llabs(value),
		f64 => c.fabs(value),
		else => @compileError("Expected int or float, found " ++ @typeName(T))
	};
}