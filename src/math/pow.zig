const c = @cImport({
	@cInclude("math.h");
});

pub fn pow(comptime T: type, x: T, y: T) T {
	return switch (T) {
		f32 => c.powf(x, y),
		f64 => c.pow(x, y),
		f128 => c.powl(x, y),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn sqrt(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.sqrtf(value),
		f64 => c.sqrt(value),
		f128 => c.sqrtl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}