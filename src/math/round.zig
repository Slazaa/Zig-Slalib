const c = @cImport({
	@cInclude("math.h");
});

pub fn ceil(value: anytype) @TypeOf(value) {
	const T = @TypeOf(value);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.ceilf(value),
			64 => c.ceil(value),
			128 => c.ceill(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn floor(value: anytype) @TypeOf(value) {
	const T = @TypeOf(value);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.floorf(value),
			64 => c.floor(value),
			128 => c.floorl(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn round(value: anytype) @TypeOf(value) {
	const T = @TypeOf(value);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.roundf(value),
			64 => c.round(value),
			128 => c.roundl(value),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}