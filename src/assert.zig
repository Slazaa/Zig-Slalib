pub const Error = error {
	Failed
};

pub fn assert(ok: bool) Error!void {
	if (!ok) {
		return Error.Failed;
	}
}