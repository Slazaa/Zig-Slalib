const memory = @import("../memory.zig");

const Allocator = memory.allocator.Allocator;
const GlobAlloc = memory.glob_alloc.GlobAlloc;

const std = @import("std");

pub fn Vec(comptime T: type) type {
	return struct {
		const Self = @This();

		items: []T = &[_]T{ },
		allocator: Allocator = GlobAlloc.allocator,
		capacity: usize = 0,

		pub fn clear(self: *Self) void {
			self.items.len = 0;
		}

		pub fn copy(self: *const Self) Self {
			return Self.from(self.items);
		}

		pub fn deinit(self: *Self) void {
			if (self.capacity == 0) {
				return;
			}

			self.allocator.dealloc(self.items.ptr);
		}

		pub fn from(allocator: ?Allocator, slice: []const T) memory.allocator.Error!Self {
			var self = try Self.withCapacity(allocator, slice.len);
			self.items.len = self.capacity;
			
			memory.copy(self.items.ptr, slice.ptr, @sizeOf(T) * self.len());

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

		pub fn getSlice(self: *const Self, idx: usize, count: usize) ?[]const T {
			if (idx >= self.len() or count == 0 or idx + count >= self.len()) {
				return null;
			}

			return self.items[idx..idx + count];
		}

		pub fn init(allocator: ?Allocator) Self {
			return if (allocator) |alloc|
				.{
					.allocator = alloc
				}
			else
				.{ };
		}

		pub fn insert(self: *Self, idx: usize, elem: T) memory.allocator.Error!void {
			if (idx > self.len()) {
				@panic("Index out of bounds");
			}

			if (self.capacity == self.len()) {
				try self.reserve(1);
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

		pub fn pop(self: *Self) memory.allocator.Error!?T {
			return try self.remove(self.len() - 1);
		}

		pub fn push(self: *Self, elem: T) memory.allocator.Error!void {
			try self.insert(self.len(), elem);
		}

		pub fn remove(self:* Self, idx: usize) memory.allocator.Error!T {
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

		pub fn reserve(self: *Self, additional: usize) memory.allocator.Error!void {
			var old_cap = self.capacity;
			self.capacity += additional;
			
			var new_mem = if (old_cap != 0)
				self.allocator.realloc(self.items.ptr, @sizeOf(T) * self.capacity)
			else
				self.allocator.alloc(@sizeOf(T) * self.capacity);

			self.items.ptr = @ptrCast([*]T, @alignCast(@alignOf(T), try new_mem));
		}

		pub fn withCapacity(allocator: ?Allocator, cap: usize) memory.allocator.Error!Self {
			var self = Self.init(allocator);
			try self.reserve(cap);

			return self;
		}
	};
}