const mem = @import("../mem.zig");
const glob_alloc = @import("../mem/glob_alloc.zig");
const GlobAlloc = glob_alloc.glob_alloc().allocator;

pub fn Vec(comptime T: type) type {
    return struct {
        const Self = @This();

        buf: ?[*]T,
        capacity: usize,
        len: usize,

        drop: mem.Drop = .{
            .drop_fn = drop
        },

        pub fn clear(self: *Self) void {
            self.len = 0;
        }

        pub fn from(slice: []const T) Self {
            var self = Self.with_capacity(slice.len);
            mem.copy(@ptrCast(*anyopaque, self.buf), slice.ptr, @sizeOf(T) * self.len);

            return self;
        }

        pub fn get(self: *Self, idx: usize) ?T {
            return if (self.buf) |buf| buf[idx] else null;
        }

        pub fn new() Self {
            return .{
                .buf = null,
                .capacity = 0,
                .len = 0
            };
        }

        pub fn push(self: *Self, value: T) void {
            if (self.capacity == self.len) {
                self.reserve(1);
            }

            self.len += 1;
            self.buf.?[self.len - 1] = value;
        }

        pub fn reserve(self: *Self, additional: usize) void {
            self.capacity += additional;
            
            var ptr = if (self.buf) |buf|
                GlobAlloc.realloc(buf, @sizeOf(T) * self.capacity)
            else
                GlobAlloc.alloc(@sizeOf(T) * self.capacity);

            self.buf = @ptrCast([*]T, @alignCast(@alignOf(T), ptr catch @panic("Failed allocating")));
        }

        pub fn with_capacity(capacity: usize) Self {
            var self = Self.new();
            self.reserve(capacity);

            return self;
        }

        // Drop implementation
        pub fn drop(drop_iface: *const mem.Drop) void {
            const self = @fieldParentPtr(Self, "drop", drop_iface);
            GlobAlloc.dealloc(@ptrCast(*anyopaque, self.buf));
        }
    };
}