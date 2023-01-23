//! A contiguous growable array type.
//! You can provide an allocator through the initaliazing functions, if set `null`, the GeneralAlloc will be choosen.
//!
//! # Examples
//! ```zig
//! var vec = Vec(i32).init(null);
//! defer vec.deinit();
//!
//! try vec.push(1);
//! try vec.push(2);
//!
//! assert(vec.len() == 2);
//! assert(vec.items[0] == 1);
//!
//! assert(try vec.pop() == @as(?i32, 2));
//! assert(vec.len() == 1);
//!
//! vec.items[0] = 7;
//! assert(vec.items[0] == 7);
//!
//! try vec.pushSlice(&[_]i32{1, 2, 3});
//!
//! for (vec.items) |x| {
//! 	println("{}", .{ x });
//! }
//!
//! assert(vec.equals(&[_]i32{7, 1, 2, 3}));
//! ```

const collections = @import("../collections.zig");
const memory = @import("../memory.zig");
const slice = @import("../slice.zig");

const Allocator = memory.Allocator;
const GeneralAlloc = memory.GeneralAlloc;

pub fn Vec(comptime T: type) type {
	return struct {
		const Self = @This();

		items: []T = &[_]T{ },
		allocator: *const Allocator = &GeneralAlloc.allocator,
		capacity: usize = 0,

		/// Clears the vector.
		/// Note that this method does not affect the allocated capacity of the vector.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// vec.clear();
		///
		/// assert(vec.isEmpty());
		/// ```
		pub fn clear(self: *Self) void {
			self.items.len = 0;
		}

		/// Initializes a copy of the vector.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// var cloned = try vec.clone();
		/// defer cloned.deinit();
		///
		/// assert(vec.equals(cloned.items));
		/// ```
		pub fn clone(self: *const Self) memory.Error!Self {
			return Self.from(null, self.items);
		}

		/// Returns the number of occurences of `target` in the vector.
		/// 
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3, 2, 2, 6 });
		/// defer vec.deinit();
		///
		/// assert(vec.count(2) == 3);
		/// ```
		pub fn count(self: *const Self, target: anytype) usize {
			return slice.count(T, self.items, target);
		}

		/// Releases all allocated memory.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		/// ```
		pub fn deinit(self: *Self) void {
			if (self.capacity == 0) {
				return;
			}

			self.allocator.dealloc(self.items.ptr);
		}

		/// Returns `true` if the vector and the slice are equal.
		///
		/// # Examples
		/// ```zig
		/// var first_vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer first_vec.deinit();
		///
		/// var second_vec = try first_vec.clone();
		/// defer second_vec.deinit();
		///
		/// if (first_vec.equals(second_vec.items)) {
		///		println("Both vectors are equal", .{ });
		/// }
		/// ```
		pub fn equals(self: *const Self, target: []const T) bool {
			return slice.equals(T, self.items, target);
		}

		/// Returns the position of the first occurence of the element, else returns `null`.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// assert(vec.find(2).? == 1);
		/// ```
		pub fn find(self: *const Self, to_find: anytype) ?usize {
			return slice.find(T, self.items, to_find);
		}

		/// Initializes a new vector from a slice.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// assert(vec.equals(&[_]i32{ 1, 2, 3 }));
		/// ```
		pub fn from(allocator: ?*const Allocator, target: []const T) memory.Error!Self {
			var self = try Self.withCapacity(allocator, target.len);
			self.items.len = self.capacity;
			
			memory.copy(T, self.items, target, self.len());

			return self;
		}

		/// Initializes a new vector.
		///
		/// # Examples
		/// ```zig
		/// var vec = Vec(i32).init(null);
		/// defer vec.deinit();
		/// ```
		pub fn init(allocator: ?*const Allocator) Self {
			if (allocator) |alloc| {
				return .{ .allocator = alloc };
			}

			return .{ };
		}

		/// Inserts an element at the given index in the vector, shifting all the elements after it to the right.
		/// 
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 5 });
		/// defer vec.deinit();
		///
		/// try vec.insert(1, 2);
		/// try vec.insert(2, &[_]i32{ 3, 4 });
		///
		/// assert(vec.equals(&[_]i32{ 1, 2, 3, 4, 5 }));
		/// ```
		pub fn insert(self: *Self, idx: usize, target: anytype) memory.Error!void {
			const TargetType = @TypeOf(target);

			switch (TargetType) {
				[]const T => {
					if (idx > self.len()) {
						@panic("Index out of bounds");
					}

					if (self.capacity < self.len() + target.len) {
						try self.reserve(self.capacity - self.len() + target.len);
					}

					self.items.len += target.len;

					try memory.move(T, self.items[idx + target.len..], self.items[idx..],self.len() - (idx + target.len));
					memory.copy(T, self.items[idx..], target, target.len);
				},
				T => try self.insert(idx, &[_]T{ target }),
				comptime_float => {
					if (@typeInfo(T) != .Float) {
						@compileError("Cannot cast comptime_float to " ++ @typeName(T));
					}

					try self.insert(idx, @as(T, target));
				},
				comptime_int => {
					if (@typeInfo(T) != .Int) {
						@compileError("Cannot cast comptime_int to " ++ @typeName(T));
					}

					try self.insert(idx, @as(T, target));
				},
				else => {
					const target_type_info = @typeInfo(TargetType);

					if (target_type_info != .Pointer or @typeInfo(target_type_info.Pointer.child) != .Array) {
						@compileError("Expected single element or slice of element, found " ++ @typeName(TargetType));
					}

					try self.insert(idx, @as([]const T, target));
				}
			}
		}

		/// Returns `true` if the vector contains no elements.
		///
		/// # Examples
		/// ```zig
		/// var vec = Vec(i32).init(null);
		/// defer vec.deinit();
		///
		/// assert(vec.isEmpty());
		/// ```
		pub fn isEmpty(self: *const Self) bool {
			return slice.isEmpty(T, self.items);
		}

		/// Returns the length of the vector.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// assert(vec.len() == 3);
		/// ```
		pub fn len(self: *const Self) usize {
			return self.items.len;
		}

		/// Removes the last element of the last element of the vector, or `null` if it's empty.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// assert(vec.pop() == 3);
		/// assert(vec.equals(&[_]i32{ 1, 2 }));
		/// ```
		pub fn pop(self: *Self) T {
			return self.remove(self.len() - 1);
		}

		/// Appends an element or a slice to the back of the vector.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2 });
		/// defer vec.deinit();
		///
		/// try vec.push(3);
		///
		/// assert(vec.equals(&[_]i32{ 1, 2, 3 }));
		/// ```
		pub fn push(self: *Self, target: anytype) memory.Error!void {
			try self.insert(self.len(), target);
		}

		/// Removes and returns the element at `idx` in the vector, shifting all elements after it to the left.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3 });
		/// defer vec.deinit();
		///
		/// assert(vec.remove(1) == 2);
		/// assert(vec.equals(&[_]i32{ 1, 3 }));
		/// ```
		pub fn remove(self:* Self, idx: usize) T {
			if (idx >= self.len()) {
				@panic("Index out of bounds");
			}

			var elem = self.items[idx];

			memory.copy(T, self.items[idx..self.len() - 1], self.items[idx + 1..self.len()], (self.len() - 1 - idx));
			self.items.len -= 1;

			return elem;
		}

		/// Removes `num` elements at `idx` in the vector, shifting all elements after it to the left.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 2, 3, 4, 5 });
		/// defer vec.deinit();
		///
		/// vec.removen(1, 3);
		///
		/// assert(vec.equals(&[_]i32{ 1, 5 }));
		/// ```
		pub fn removen(self: *Self, idx: usize, num: usize) void {
			if (idx >= self.len()) {
				@panic("Index out of bounds");
			}

			var i: usize = 0;
			while (i != num) : (i += 1) self.remove(idx);
		}

		/// Replaces all occurencese of `target` with `to`.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 10, 20, 5 });
		/// defer vec.deinit();
		///
		/// try vec.replace(&[_]i32{ 10 }, 2);
		/// try vec.replace(&[_]i32{ 20 }, &[_]i32{ 3, 4 });
		///
		/// assert(vec.equals(&[_]i32{ 1, 2, 3, 4, 5 }));
		/// ```
		pub fn replace(self: *Self, target: []const T, to: anytype) memory.Error!void {
			try self.replacen(target, to, self.count(target));
		}

		/// Replaces `num` occurences of `target` with `to`.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1, 10, 10, 5 });
		/// defer vec.deinit();
		///
		/// try vec.replacen(&[_]i32{ 10 }, 2, 1);
		/// try vec.replacen(&[_]i32{ 10 }, &[_]i32{ 3, 4 }, 1);
		///
		/// assert(vec.equals(&[_]i32{ 1, 2, 3, 4, 5 }));
		/// ```
		pub fn replacen(self: *Self, target: []const T, to: anytype, num: usize) memory.Error!void {
			if (num == 0) {
				return;
			}

			const ToType = @TypeOf(to);

			switch (ToType) {
				[]const T => {
					var idx: usize = 0;
					var i: usize = 0;

					while (i < num) : (i += 1) {
						if (slice.find(T, self.items[idx..], target)) |target_idx| {
							if (target.len == to.len) {
								memory.copy(T, self.items[idx + target_idx..], to, to.len);
							} else {
								memory.move(T, self.items[idx + target_idx..], self.items[idx + target_idx + target.len..], self.len() - (idx + target.len));
								self.items.len -= target.len;

								try self.insert(idx + target_idx, to);
							}

							idx += target_idx;
						} else {
							break;
						}
					}
				},
				T => try self.replacen(target, @as([]const T, &[_]T{ to }), num),
				comptime_float => {
					if (@typeInfo(T) != .Float) {
						@compileError("Cannot cast comptime_float to " ++ @typeName(T));
					}

					try self.replacen(target, @as(T, to), num);
				},
				comptime_int => {
					if (@typeInfo(T) != .Int) {
						@compileError("Cannot cast comptime_int to " ++ @typeName(T));
					}

					try self.replacen(target, @as(T, to), num);
				},
				else => {
					const to_type_info = @typeInfo(ToType);

					if (to_type_info != .Pointer or @typeInfo(to_type_info.Pointer.child) != .Array) {
						@compileError("Expected single element or slice of element, found " ++ @typeName(ToType));
					}

					try self.replacen(target, @as([]const T, to), num);
				}
			}
		}

		/// Reserves capacity for at least `additional` more elements.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).from(null, &[_]i32{ 1 });
		/// defer vec.deinit();
		///
		/// try vec.reserve(10);
		///
		/// assert(vec.capacity == 11);
		/// ```
		pub fn reserve(self: *Self, additional: usize) memory.Error!void {
			if (additional == 0) {
				return;
			}

			var old_cap = self.capacity;
			self.capacity += additional;
			
			var new_mem = if (old_cap != 0)
				self.allocator.realloc(self.items.ptr, @sizeOf(T) * self.capacity)
			else
				self.allocator.alloc(@sizeOf(T) * self.capacity);

			self.items.ptr = @ptrCast([*]T, @alignCast(@alignOf(T), try new_mem));
		}

		/// Initializes a new vector with at least the given capacity.
		///
		/// # Examples
		/// ```zig
		/// var vec = try Vec(i32).withCapacity(null, 10);
		/// defer vec.deinit();
		///
		/// assert(vec.capacity == 10);
		/// ```
		pub fn withCapacity(allocator: ?*const Allocator, cap: usize) memory.Error!Self {
			var self = Self.init(allocator);
			try self.reserve(cap);

			return self;
		}
	};
}