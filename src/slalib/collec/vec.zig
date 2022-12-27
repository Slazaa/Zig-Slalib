const mem = @import("../mem.zig");
const iter = @import("../iter.zig");
const std = @import("std");

pub fn Vec(comptime T: type, comptime A: ?*const mem.Allocator) type {
    return struct {
        const Self = @This();

        items: ?[*]T = null,
        allocator: *const mem.Allocator = &mem.GlobAlloc.allocator,
        capacity: usize = 0,
        len: usize = 0,

        drop: mem.Drop = .{
            .drop_fn = drop_fn
        },

        pub fn clear(self: *Self) void {
            self.len = 0;
        }

        pub fn from(slice: []const T) Self {
            var self = Self.with_capacity(slice.len);
            self.len = self.capacity;
            mem.copy(@ptrCast(*anyopaque, self.items.?), slice.ptr, @sizeOf(T) * self.len);

            return self;
        }

        pub fn get(self: *const Self, idx: usize) ?*const T {
            if (idx >= self.len) {
                return null;
            }

            return if (self.items) |items| &items[idx] else null;
        }

        pub fn get_mut(self: *Self, idx: usize) ?*T {
            if (idx >= self.len) {
                return null;
            }

            return if (self.items) |items| &items[idx] else null;
        }

        pub fn iter(self: *const Self) Iter(T, A) {
            return .{ .target = self };
        }

        pub fn last(self: *const Self) ?*const T {
            return self.get(self.len - 1);
        }

        pub fn new() Self {
            return if (A) |Alloc| .{ .allocator = Alloc } else .{ };
        }

        pub fn pop(self: *Self) ?T {
            var item = self.last() orelse return null;
            self.len -= 1;
            
            return item.*;
        }

        pub fn push(self: *Self, value: T) void {
            if (self.capacity == self.len) {
                self.reserve(1);
            }

            self.len += 1;
            self.items.?[self.len - 1] = value;
        }

        pub fn reserve(self: *Self, additional: usize) void {
            self.capacity += additional;
            
            var ptr = if (self.items) |items|
                self.allocator.realloc(items, @sizeOf(T) * self.capacity)
            else
                self.allocator.alloc(@sizeOf(T) * self.capacity);

            self.items = @ptrCast([*]T, @alignCast(@alignOf(T), ptr catch @panic("Failed allocating")));
        }

        pub fn with_capacity(capacity: usize) Self {
            var self = Self.new();
            self.reserve(capacity);

            return self;
        }

        // Drop impl
        fn drop_fn(drop_iface: *const mem.Drop) void {
            const self = @fieldParentPtr(Self, "drop", drop_iface);
            self.allocator.dealloc(@ptrCast(*anyopaque, self.items));
        }
    };
}

pub fn Iter(comptime T: type, comptime A: ?*const mem.Allocator) type {
    return struct {
        const Self = @This();

        target: *const Vec(T, A),
        idx: usize = 0,

        iter: iter.Iterator(T) = .{
            .next_fn = next_fn
        },

        // Iterator impl
        fn next_fn(iter_iface: *iter.Iterator(T)) ?*const T {
            const self = @fieldParentPtr(Self, "iter", iter_iface);
            var item = self.target.get(self.idx);
            self.idx += 1;

            return item;
        }
    };
}