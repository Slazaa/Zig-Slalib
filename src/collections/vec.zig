const mem = @import("../mem.zig");
const iter = @import("../iter.zig");
const assert = @import("../assert.zig");

const Allocator = mem.allocator.Allocator;
const GlobAlloc = mem.glob_alloc.GlobAlloc;
const Drop = mem.drop.Drop;

pub fn Vec(comptime T: type, comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		items: []T = &[_]T{},
		allocator: *const Allocator = &GlobAlloc.allocator,
		capacity: usize = 0,

		drop: Drop = .{
			.drop_fn = drop_fn
		},

		pub fn clear(self: *Self) void {
			self.items.len = 0;
		}

		pub fn dedup(self: *Self) void {
			// TODO

			_ = self;

			@panic("Function not implemented yet");
		}

		pub fn from(slice: []const T) Self {
			var self = Self.with_capacity(slice.len);
			self.items.len = self.capacity;
			mem.copy(@ptrCast(*anyopaque, self.items.ptr), slice.ptr, @sizeOf(T) * self.len());

			return self;
		}

		pub fn get(self: *const Self, idx: usize) ?*const T {
			if (idx >= self.len()) {
				return null;
			}

			return if (!self.is_empty()) &self.items[idx] else null;
		}

		pub fn get_mut(self: *Self, idx: usize) ?*T {
			if (idx >= self.len()) {
				return null;
			}

			return if (!self.is_empty()) &self.items[idx] else null;
		}

		pub fn get_slice(self: *const Self, start_idx: usize, end_idx: usize) ?[]const T {
			if (start_idx > end_idx or end_idx >= self.len()) {
				return null;
			}

			return self.items[start_idx..end_idx];
		}

		pub fn insert(self: *Self, idx: usize, elem: T) void {
			// TODO

			_ = self;
			_ = idx;
			_ = elem;

			@panic("Function not implemented yet");
		}

		pub fn is_empty(self: *const Self) bool {
			return self.len() == 0;
		}

		pub fn iter(self: *const Self) Iter(T, *const T, A) {
			return .{ .target = self };
		}

		pub fn last(self: *const Self) ?*const T {
			return self.get(self.len() - 1);
		}

		pub fn len(self: *const Self) usize {
			return self.items.len;
		}

		pub fn new() Self {
			return if (A) |Alloc| .{ .allocator = Alloc } else .{ };
		}

		pub fn pop(self: *Self) ?T {
			var item = self.last() orelse return null;
			self.items.len -= 1;
			
			return item.*;
		}

		pub fn push(self: *Self, value: T) void {
			if (self.capacity == self.len()) {
				self.reserve(1);
			}

			self.items.len += 1;
			self.items[self.len() - 1] = value;
		}

		pub fn remove(self:* Self, idx: usize) T {
			// TODO

			_ = self;
			_ = idx;

			@panic("Function not implemented yet");
		}

		

		pub fn reserve(self: *Self, additional: usize) void {
			var old_cap = self.capacity;
			self.capacity += additional;
			
			var new_mem = if (old_cap != 0)
				self.allocator.realloc(self.items.ptr, @sizeOf(T) * self.capacity)
			else
				self.allocator.alloc(@sizeOf(T) * self.capacity);

			self.items.ptr = @ptrCast([*]T, @alignCast(@alignOf(T), new_mem catch @panic("Failed allocating")));
		}

		pub fn with_capacity(capacity: usize) Self {
			var self = Self.new();
			self.reserve(capacity);

			return self;
		}

		// Drop impl
		fn drop_fn(drop_iface: *const Drop) void {
			const self = @fieldParentPtr(Self, "drop", drop_iface);
			self.allocator.dealloc(@ptrCast(*anyopaque, self.items));
		}
	};
}

pub fn Iter(comptime T: type, comptime I: type, comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		target: *const Vec(T, A),
		idx: usize = 0,

		iter: iter.Iterator(I) = .{
			.next_fn = next_fn
		},

		// Iterator impl
		fn next_fn(iter_iface: *iter.Iterator(I)) ?I {
			const self = @fieldParentPtr(Self, "iter", iter_iface);
			var item = self.target.get(self.idx);
			self.idx += 1;

			return item;
		}
	};
}