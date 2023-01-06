const assert = @import("../assert.zig");
const iter = @import("../iter.zig");
const memory = @import("../memory.zig");

const Clone = @import("../clone.zig").Clone;
const FromIterator = iter.from_iterator.FromIterator;
const Iterator = iter.iterator.Iterator;
const Allocator = memory.allocator.Allocator;
const GlobAlloc = memory.glob_alloc.GlobAlloc;
const Drop = memory.drop.Drop;

const std = @import("std");

pub fn Vec(comptime T: type, comptime A: ?*const Allocator) type {
	return struct {
		const Self = @This();

		pub const from_iter: FromIterator(Iter(Self, *const T), Self) = .{
			.from_iter_fn = fromIterFn
		};

		items: []T = &[_]T{},
		allocator: *const Allocator = &GlobAlloc.allocator,
		capacity: usize = 0,

		clone: Clone(Self) = .{
			.clone_fn = cloneFn
		},

		drop: Drop = .{
			.drop_fn = dropFn
		},

		pub fn capacity(self: *const Self) usize {
			return self.capacity;
		}

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

		pub fn getSlice(self: *const Self, start: usize, end: usize) ?[]const T {
			if (start > end or end > self.len()) {
				return null;
			}

			return self.items[start..end];
		}

		pub fn insert(self: *Self, idx: usize, elem: T) void {
			if (idx > self.len()) {
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

		pub fn iter(self: *const Self) Iter(Self, *const T) {
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

		pub fn withCapacity(cap: usize) Self {
			var self = Self.new();
			self.reserve(cap);

			return self;
		}

		// Clone impl
		fn cloneFn(clone_iface: *const Clone(Self)) Self {
			const self = @fieldParentPtr(Self, "clone", clone_iface);
			return Vec(T, A).from(self.items);
		}

		// Drop impl
		fn dropFn(drop_iface: *const Drop) void {
			const self = @fieldParentPtr(Self, "drop", drop_iface);
			self.allocator.dealloc(@ptrCast(*anyopaque, self.items));
		}

		// FromIterator impl
		fn fromIterFn(from_iter_iface: *const FromIterator(Iter(Self, *const T), Self), i: Iter(Self, *const T)) Self {
			_ = from_iter_iface;

			var res = Self.new();
			var i_mut = i;

			while (i_mut.iter.next()) |item| {
				res.push(item.*);
			}

			return res;
		}
	};
}

pub fn Iter(comptime B: type, comptime I: type) type {
	return struct {
		const Self = @This();

		target: *const B,
		idx: usize = 0,

		iter: Iterator(B, I) = .{
			.next_fn = nextFn,
			.map_fn = null
		},

		// Iterator impl
		fn nextFn(iter_iface: *Iterator(B, I)) ?I {
			const self = @fieldParentPtr(Self, "iter", iter_iface);

			var item = self.target.get(self.idx);
			self.idx += 1;

			return item;
		}
	};
}