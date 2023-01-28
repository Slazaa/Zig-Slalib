const std = @import("std");

pub fn add(exe: *std.build.LibExeObjStep, b: *std.build.Builder, comptime path: []const u8) void {
    const lib = b.addStaticLibrary("lib", path ++ "src/slalib.zig");
    lib.linkLibC();

    exe.linkLibrary(lib);
}

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib_tests = b.addTest("src/slalib.zig");
    add(lib_tests, b, "");
    lib_tests.setTarget(target);
    lib_tests.setBuildMode(mode);

    const test_step = b.step("test", "Runs the library tests.");
    test_step.dependOn(&lib_tests.step);
}
