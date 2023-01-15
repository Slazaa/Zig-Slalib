const c = @cImport({
	@cInclude("math.h");
});

pub fn acos(comptime T: type, cosinus: T) T {
	return switch (T) {
		f32 => c.acosf(cosinus),
		f64 => c.acos(cosinus),
		f128 => c.acosl(cosinus),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn asin(comptime T: type, sinus: T) T {
	return switch (T) {
		f32 => c.asinf(sinus),
		f64 => c.asin(sinus),
		f128 => c.asinl(sinus),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn atan(comptime T: type, value: T) T {
	return switch (T) {
		f32 => c.atanf(value),
		f64 => c.atan(value),
		f128 => c.atanl(value),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn atan2(comptime T: type, x: T, y: T) T {
	return switch (T) {
		f32 => c.atan2f(x, y),
		f64 => c.atan2(x, y),
		f128 => c.atan2l(x, y),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn cos(comptime T: type, angle: T) T {
	return switch (T) {
		f32 => c.cosf(angle),
		f64 => c.cos(angle),
		f128 => c.cosl(angle),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn sin(comptime T: type, angle: T) T {
	return switch (T) {
		f32 => c.sinf(angle),
		f64 => c.sin(angle),
		f128 => c.sinl(angle),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn tan(comptime T: type, angle: T) T {
	return switch (T) {
		f32 => c.tanf(angle),
		f64 => c.tan(angle),
		f128 => c.tanl(angle),
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}