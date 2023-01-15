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