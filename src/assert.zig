pub const Error = error {
    TestFailed
};

pub fn assert(ok: bool) void {
    if (!ok) {
        unreachable;
    }
}

pub fn expect(ok: bool) Error!void {
    if (!ok) {
        return Error.TestFailed;
    }
}
