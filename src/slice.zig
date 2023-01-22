const memory = @import("memory.zig");

pub fn count(comptime T: type, self: []const T, target: anytype) usize {
	if (self.len == 0) return 0;

	const TargetType = @TypeOf(target);

	switch (TargetType) {
		[]const T => {
			var res: usize = 0;
			var idx: usize = 0;

			while (find(T, self[idx..], target)) |target_idx| : (idx += target_idx + target.len) {
				res += 1;
			}

			return res;
		},
		T => return count(T, self, &[_]T{ target }),
		comptime_float => {
			if (@typeInfo(T) != .Float) @panic("Cannot cast comptime_float to " ++ @typeName(T));
			return count(T, self, @as(T, target));
		},
		comptime_int => {
			if (@typeInfo(T) != .Int) @panic("Cannot cast comptime_int to " ++ @typeName(T));
			return count(T, self, @as(T, target));
		},
		else => {
			const target_type_info = @typeInfo(TargetType);

			if (target_type_info == .Pointer and @typeInfo(target_type_info.Pointer.child) == .Array) return count(T, self, @as([]const T, target))
			else @panic("Expected single element or slice of element, found " ++ @typeName(TargetType));
		}
	}
}

pub fn equals(comptime T: type, self: []const T, slice: []const T) bool {
	return
		if (self.len != slice.len) false
		else if (self.ptr == slice.ptr) true
		else memory.compare(T, self, slice, self.len) == .Equal;
}

pub fn find(comptime T: type, self: []const T, target: anytype) ?usize {
	const TargetType = @TypeOf(target);

	switch (TargetType) {
		[]const T => {
			if (isEmpty(T, self) or target.len > self.len) return null;

			var i: usize = 0;
				
			while (i + target.len - 1 < self.len) : (i += 1) {
				if (equals(T, self[i..i + target.len], target)) return i;
			}
		},
		T => return find(T, self, &[_]T{ target }),
		comptime_float => {
			if (@typeInfo(T) != .Float) @panic("Cannot cast comptime_float to " ++ @typeName(T));
			return find(T, self, @as(T, target));
		},
		comptime_int => {
			if (@typeInfo(T) != .Int) @panic("Cannot cast comptime_int to " ++ @typeName(T));
			return find(T, self, @as(T, target));
		},
		else => {
			const target_type_info = @typeInfo(TargetType);

			if (target_type_info == .Pointer and @typeInfo(target_type_info.Pointer.child) == .Array) return find(T, self, @as([]const T, target))
			else @panic("Expected single element or slice of element, found " ++ @typeName(TargetType));
		}
	}

	return null;
}

pub fn isEmpty(comptime T: type, self: []const T) bool {
	return self.len == 0;
}

pub fn matches(comptime T: type, self: []const T, slices: []const []const T) bool {
	for (slices) |slice| {
		if (equals(T, self, slice)) return true;
	}

	return false;
}