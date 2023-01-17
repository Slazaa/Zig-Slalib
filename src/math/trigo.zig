const c = @cImport({
	@cInclude("math.h");
});

pub fn acos(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.acosf(x),
			64 => c.acos(x),
			128 => c.acosl(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn asin(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.asinf(x),
			64 => c.asin(x),
			128 => c.asinl(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn atan(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.atanf(x),
			64 => c.atan(x),
			128 => c.atanl(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn atan2(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.atan2f(x),
			64 => c.atan2(x),
			128 => c.atan2l(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn cos(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.cosf(x),
			64 => c.cos(x),
			128 => c.cosl(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn sin(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.sinf(x),
			64 => c.sin(x),
			128 => c.sinl(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}

pub fn tan(x: anytype) @TypeOf(x) {
	const T = @TypeOf(x);
	const type_info = @typeInfo(T);

	return switch (type_info) {
		.Float => |float_type| switch (float_type.bits) {
			32 => c.tanf(x),
			64 => c.tan(x),
			128 => c.tanl(x),
			else => @compileError("Invalid bits for type " ++ @typeName(T))
		},
		else => @compileError("Expected float, found " ++ @typeName(T))
	};
}