//! The `Read` structure is used for reading bytes.
//! Its methods needs to be implemented through its fields.
//!
//! # Examples
//! ```zig
//! // TODO
//! ```

const io = @import("../io.zig");

const Error = io.Error;

const Self = @This();

readFn: *const fn (self: *const Self, buffer: []u8) Error!usize,

/// Pull some bytes into the buffer and return how many bytes were read.
///
/// ```zig
/// // TODO
/// ```
pub fn read(self: *const Self, buffer: []u8) Error!usize {
    return self.readFn(self, buffer);
}
