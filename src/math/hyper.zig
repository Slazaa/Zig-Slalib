const c = @cImport({
	@cInclude("math.h");
});

pub fn acosh(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.acoshf(value),
		f64 => c.acosh(value),
		f128 => c.acoshl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn asinh(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.asinhf(value),
		f64 => c.asinh(value),
		f128 => c.asinhl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn atanh(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.atanhf(value),
		f64 => c.atanh(value),
		f128 => c.atanhl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn cosh(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.coshf(value),
		f64 => c.cosh(value),
		f128 => c.coshl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn sinh(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.sinhf(value),
		f64 => c.sinh(value),
		f128 => c.sinhl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn tanh(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.tanhf(value),
		f64 => c.tanh(value),
		f128 => c.tanhl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}