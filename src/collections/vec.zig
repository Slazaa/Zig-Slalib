//! A contiguous growable array type.
//! You can provide an allocator through the initaliazing functions, if set `null`, the GlobAlloc will be choosen.
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
//! try vec.pushSlice(&[_]i32{ 1, 2, 3 });
//!
//! for (vec.items) |x| {
//! 	println("{}", .{ x });
//! }
//!
//! assert(vec.equals(&[_]i32{ 7, 1, 2, 3 }));
//! ```

const collections = @import("../collections.zig");
const memory = @import("../memory.zig");

const Allocator = memory.Allocator;
const GlobAlloc = memory.GlobAlloc;

pub fn Vec(comptime T: type) type {
	return struct {
		const Self = @This();

		items: []T = &[_]T{ },
		allocator: *const Allocator = &GlobAlloc.allocator,
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
		pub fn equals(self: *const Self, slice: []const T) bool {
			return memory.compare(self.items.ptr, slice.ptr, self.len() * @sizeOf(T)) == .Equal;
		}

		/// Initializes a new vector from a slice.
		pub fn from(allocator: ?*const Allocator, slice: []const T) memory.Error!Self {
			var self = try Self.withCapacity(allocator, slice.len);
			self.items.len = self.capacity;
			
			memory.copy(self.items.ptr, slice.ptr, @sizeOf(T) * self.len());

			return self;
		}

		/// Initializes a new vector.
		pub fn init(allocator: ?*const Allocator) Self {
			return if (allocator) |alloc|
				.{
					.allocator = alloc
				}
			else
				.{ };
		}

		/// Inserts an element at the given index in the vector, shifting all the elements after it to the right.
		pub fn insert(self: *Self, idx: usize, elem: T) memory.Error!void {
			try self.insertSlice(idx, &[_]T{ elem });
		}

		/// Inserts a slice at the given index in the vector, shifting all the elements after it to the right.
		pub fn insertSlice(self: *Self, idx: usize, slice: []const T) memory.Error!void {
			if (idx > self.len()) {
				@panic("Index out of bounds");
			}

			if (self.capacity < self.len() + slice.len) {
				try self.reserve(self.capacity - self.len() + slice.len);
			}

			self.items.len += slice.len;

			memory.copy(self.items[idx + slice.len..self.len()].ptr, self.items[idx..self.len() - slice.len].ptr, (self.len() - slice.len - idx) * @sizeOf(T));
			memory.copy(self.items[idx..idx + slice.len].ptr, slice.ptr, slice.len * @sizeOf(T));
		}

		/// Returns `true` if the vector contains no elements.
		pub fn isEmpty(self: *const Self) bool {
			return self.len() == 0;
		}

		/// Returns the length of the vector.
		pub fn len(self: *const Self) usize {
			return self.items.len;
		}

		/// Removes the last element of the last element of the vector, or `null` if it's empty.
		pub fn pop(self: *Self) memory.Error!?T {
			return
				if (self.isEmpty()) null
				else try self.remove(self.len() - 1);
		}

		/// Appends an element to the back of the vector.
		pub fn push(self: *Self, elem: T) memory.Error!void {
			try self.insert(self.len(), elem);
		}

		/// Appends a slice to the back of the vector.
		pub fn pushSlice(self: *Self, slice: []const T) memory.Error!void {
			try self.insertSlice(self.len(), slice);
		}

		/// Removes and returns the element at the given index in the vector, shifting all elements after it to the left.
		pub fn remove(self:* Self, idx: usize) memory.Error!T {
			if (idx >= self.len()) {
				@panic("Index out of bounds");
			}

			var elem = self.items[idx];
			var i: usize = idx;

			while (i < self.len() - 1) : (i += 1) {
				self.items[i] = self.items[i + 1];
			}

			self.items.len -= 1;

			return elem;
		}

		/// Reserves capacity for at least `additional` more elements.
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
		pub fn withCapacity(allocator: ?*const Allocator, cap: usize) memory.Error!Self {
			var self = Self.init(allocator);
			try self.reserve(cap);

			return self;
		}
	};
}