const c = @cImport({
    @cInclude("math.h");
});

pub fn acos(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.acoshf(x),
            64 => c.acosh(x),
            128 => c.acoshl(x),
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
            32 => c.asinhf(x),
            64 => c.asinh(x),
            128 => c.asinhl(x),
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
            32 => c.atanhf(x),
            64 => c.atanh(x),
            128 => c.atanhl(x),
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
            32 => c.coshf(x),
            64 => c.cosh(x),
            128 => c.coshl(x),
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
            32 => c.sinhf(x),
            64 => c.sinh(x),
            128 => c.sinhl(x),
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
            32 => c.tanhf(x),
            64 => c.tanh(x),
            128 => c.tanhl(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}
