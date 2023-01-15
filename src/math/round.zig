const c = @cImport({
	@cInclude("math.h");
});

pub fn ceil(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.ceilf(value),
		f64 => c.ceil(value),
		f128 => c.ceill(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn floor(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.floorf(value),
		f64 => c.floor(value),
		f128 => c.floorl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn round(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.roundf(value),
		f64 => c.round(value),
		f128 => c.roundl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}