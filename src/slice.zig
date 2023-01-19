const memory = @import("memory.zig");

pub fn countSub(comptime T: type, self: []const T, slice: []const T) usize {
	var count: usize = 0;
	var idx: usize = 0;

	while (find(self[idx..], slice)) |slice_idx| {
		count += 1;
		idx += slice_idx + slice.len;
	}

	return count;
}

pub fn equals(comptime T: type, self: []const T, slice: []const T) bool {
	return memory.compare(self.ptr, slice.ptr, self.len * @sizeOf(T)) == .Equal;
}

pub fn find(comptime T: type, self: []const T, to_find: T) ?usize {
	return findSlice(T, self, &[_]T{ to_find });
}

pub fn findSlice(comptime T: type, self: []const T, slice: []const T) ?usize {
	var i: usize = 0;
		
	while (i + slice.len - 1 < self.len) : (i += 1) {
		if (memory.compare(self[i..i + slice.len].ptr, slice.ptr, slice.len) == .Equal) {
			return i;
		}
	}

	return null;
}

pub fn isEmpty(comptime T: type, self: []const T) bool {
	return self.len == 0;
}

pub fn matches(comptime T: type, self: []const T, slices: [][]const T) bool {
	for (slices) |slice| {
		if (memory.compare(self, slice) == .Equal) {
			return true;
		}
	}

	return false;
}