const memory = @import("../memory.zig");

const Allocator = memory.allocator.Allocator;
const GlobAlloc = memory.glob_alloc.GlobAlloc;

const std = @import("std");

pub fn Vec(comptime T: type, comptime A: ?Allocator) type {
	return struct {
		const Self = @This();

		items: []T = &[_]T{},
		allocator: Allocator = GlobAlloc.allocator,
		capacity: usize = 0,

		pub fn capacity(self: *const Self) usize {
			return self.capacity;
		}

		pub fn clear(self: *Self) void {
			self.items.len = 0;
		}

		pub fn copy(self: *const Self) Self {
			return Self.from(self.items);
		}

		pub fn deinit(self: *Self) void {
			self.allocator.dealloc(@ptrCast(*anyopaque, self.items));
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

		pub fn init() Self {
			return if (A) |Alloc|
				.{
					.allocator = Alloc
				}
			else
				.{ };
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

		pub fn last(self: *const Self) ?*const T {
			return self.get(self.len() - 1);
		}

		pub fn len(self: *const Self) usize {
			return self.items.len;
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
			var self = Self.init();
			self.reserve(cap);

			return self;
		}
	};
}