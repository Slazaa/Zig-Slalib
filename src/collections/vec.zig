const memory = @import("../memory.zig");
const iter = @import("../iter.zig");
const assert = @import("../assert.zig");

const Allocator = memory.allocator.Allocator;
const GlobAlloc = memory.glob_alloc.GlobAlloc;
const Drop = memory.drop.Drop;

const std = @import("std");

pub fn Vec(comptime T: type, comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		items: []T = &[_]T{},
		allocator: *const Allocator = &GlobAlloc.allocator,
		capacity: usize = 0,

		drop: Drop = .{
			.drop_fn = dropFn
		},

		pub fn clear(self: *Self) void {
			self.items.len = 0;
		}

		pub fn from(slice: []const T) Self {
			var self = Self.withCapacity(slice.len);
			self.items.len = self.capacity;
			memory.copy(@ptrCast(*anyopaque, self.items.ptr), slice.ptr, @sizeOf(T) * self.len());

			return self;
		}

		pub fn get(self: *const Self, idx: usize) ?*const T {
			if (idx >= self.len()) {
				return null;
			}

			return if (!self.isEmpty()) &self.items[idx] else null;
		}

		pub fn getMut(self: *Self, idx: usize) ?*T {
			if (idx >= self.len()) {
				return null;
			}

			return if (!self.isEmpty()) &self.items[idx] else null;
		}

		pub fn getSlice(self: *const Self, start_idx: usize, end_idx: usize) ?[]const T {
			if (start_idx > end_idx or end_idx > self.len()) {
				return null;
			}

			return self.items[start_idx..end_idx];
		}

		pub fn insert(self: *Self, idx: usize, elem: T) void {
			if (idx >= self.len()) {
				@panic("Index out of bounds");
			}

			if (self.capacity == self.len()) {
				self.reserve(1);
			}

			self.items.len += 1;
			
			var i: usize = self.len() - 1;

			while (i > idx) : (i -= 1) {
				self.items[i] = self.items[i - 1];
			}

			self.items[idx] = elem;
		}

		pub fn isEmpty(self: *const Self) bool {
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
			return self.remove(self.len() - 1);
		}

		pub fn push(self: *Self, elem: T) void {
			self.insert(self.len(), elem);
		}

		pub fn remove(self:* Self, idx: usize) T {
			if (idx >= self.len()) {
				@panic("Index out of bounds");
			}

			var elem = self.get(idx).?.*;

			var i: usize = idx;

			while (i < self.len() - 1) : (i += 1) {
				self.items[i] = self.items[i + 1];
			}

			self.items.len -= 1;

			return elem;
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

		pub fn withCapacity(capacity: usize) Self {
			var self = Self.new();
			self.reserve(capacity);

			return self;
		}

		// Drop impl
		fn dropFn(drop_iface: *const Drop) void {
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
			.next_fn = nextFn
		},

		// Iterator impl
		fn nextFn(iter_iface: *iter.Iterator(I)) ?I {
			const self = @fieldParentPtr(Self, "iter", iter_iface);
			var item = self.target.get(self.idx);
			self.idx += 1;

			return item;
		}
	};
}