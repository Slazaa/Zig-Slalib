const c = @cImport({
	@cInclude("math.h");
});

pub fn exp(comptime T: type, x: T) T {
	return switch (T) {
		f32 => c.expf(x),
		f64 => c.exp(x),
		f128 => c.expl(x),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn exp2(comptime T: type, x: T) T {
	return switch (T) {
		f32 => c.exp2f(x),
		f64 => c.exp2(x),
		f128 => c.exp2l(x),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn expm1(comptime T: type, x: T) T {
	return switch (T) {
		f32 => c.expm1f(x),
		f64 => c.expm1(x),
		f128 => c.expm1l(x),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn log(comptime T: type, x: T) T {
	return switch (T) {
		f32 => c.logf(x),
		f64 => c.log(x),
		f128 => c.logl(x),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn log2(comptime T: type, x: T) T {
	return switch (T) {
		f32 => c.log2f(x),
		f64 => c.log2(x),
		f128 => c.log2l(x),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn log10(comptime T: type, x: T) T {
	return switch (T) {
		f32 => c.log10f(x),
		f64 => c.log10(x),
		f128 => c.log10l(x),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}