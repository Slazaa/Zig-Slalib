const collections = @import("../collections.zig");
const io = @import("../io.zig");
const memory = @import("../memory.zig");

const Vec = collections.vec.Vec;
const Error = io.Error;
const Allocator = memory.allocator.Allocator;

pub const Write = struct {
	const Self = @This();

	writeFn: *const fn(self: *Self, buffer: []const u8) Error!void,

	pub fn write(self: *Self, buffer: []const u8) Error!void {
		return self.writeFn(self, buffer);
	}
};

pub const BufWriter = struct {
	const Self = @This();

	writer: *Write,
	buffer: Vec(u8),

	pub fn flush(self: *Self) Error!void {
		try self.writer.write(self.buffer.items);
		self.buffer.clear();
	}

	pub fn init(allocator: ?*Allocator, writer: Write) Self {
		return .{
			.writer = writer,
			.buffer = Vec(u8).init(allocator)
		};
	}

	pub fn withCapacity(allocator: ?*Allocator, cap: usize) memory.allocator.Error!Self {
		var self = Self.init(allocator);
		try self.buffer.reserve(cap);

		return self;
	}

	// pub fn write(self: *Self, buffer: []const u8) memory.allocator.Error!void {
		
	// }
};