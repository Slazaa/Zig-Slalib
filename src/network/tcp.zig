const sla = @import("../sla.zig");
const str = sla.str;

pub const TcpListener = struct {
	const Self = @This();

	pub fn bind(addr: str) !Self {
		_ = addr;

		@panic("Function not implemented yet");
	}
};