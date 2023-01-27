const collections = @import("../collections.zig");
const io = @import("../io.zig");
const memory = @import("../memory.zig");

const Vec = collections.Vec;
const Error = io.Error;
const Allocator = memory.Allocator;

pub const Write = struct {
	const Self = @This();

	writeFn: *const fn (self: *const Self, buffer: []const u8) Error!void,

	pub fn write(self: *const Self, buffer: []const u8) Error!void {
		return self.writeFn(self, buffer);
	}
};

pub const BufWriter = struct {
	const Self = @This();

	writer: *const Write,
	buffer: Vec(u8),

	pub fn deinit(self: *Self) void {
		self.buffer.deinit();
	}

	pub fn flush(self: *Self) Error!void {
		try self.writer.write(self.buffer.items);
		self.buffer.clear();
	}

	pub fn init(allocator: ?*Allocator, writer: *const Write) Self {
		return .{
			.writer = writer,
			.buffer = Vec(u8).init(allocator)
		};
	}

	pub fn withCapacity(allocator: ?*Allocator, writer: *const Write, cap: usize) memory.Error!Self {
		return .{
			.writer = writer,
			.buffer = try Vec(u8).withCapacity(allocator, cap)
		};
	}

	pub fn write(self: *Self, buffer: []const u8) memory.Error!void {
		try self.buffer.push(buffer);
	}
};