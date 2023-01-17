const c = @cImport({
	@cInclude("math.h");
});

pub fn pow(x: anytype, y: @TypeOf(x)) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.powf(x, y),
			64 => c.pow(x, y),
			128 => c.powl(x, y),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn sqrt(value: anytype) @TypeOf(value) {
	const T = @TypeOf(value);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.sqrtf(value),
			64 => c.sqrt(value),
			128 => c.sqrtl(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn cbrt(value: anytype) @TypeOf(value) {
	const T = @TypeOf(value);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.cbrtf(value),
			64 => c.cbrt(value),
			128 => c.cbrtl(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}