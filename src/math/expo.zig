const c = @cImport({
    @cInclude("math.h");
});

pub fn exp(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.expf(x),
            64 => c.exp(x),
            128 => c.expl(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}

pub fn exp2(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.exp2f(x),
            64 => c.exp2(x),
            128 => c.exp2l(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}

pub fn expm1(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.expm1f(x),
            64 => c.expm1(x),
            128 => c.expm1l(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}

pub fn log(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.logf(x),
            64 => c.log(x),
            128 => c.logl(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}

pub fn log2(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.log2f(x),
            64 => c.log2(x),
            128 => c.log2l(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}

pub fn log10(x: anytype) @TypeOf(x) {
    const T = @TypeOf(x);
    const type_info = @typeInfo(T);

    return switch (type_info) {
        .Float => |float_type| switch (float_type.bits) {
            32 => c.log10f(x),
            64 => c.log10(x),
            128 => c.log10l(x),
            else => @compileError("Invalid bits for type " ++ @typeName(T))
        },
        else => @compileError("Expected float, found " ++ @typeName(T))
    };
}
