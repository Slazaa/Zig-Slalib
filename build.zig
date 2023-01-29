const std = @import("std");

pub fn create(b: *std.build.Builder, comptime path: []const u8) *std.build.LibExeObjStep {
    return b.addStaticLibrary("lib", path ++ "src/slalib.zig");
}

pub fn link(b: *std.build.Builder, step: *std.build.LibExeObjStep, comptime path: []const u8) void {
    const lib = create(b, path);
    step.linkLibrary(lib);
}

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib_tests = b.addTest("src/slalib.zig");
    lib_tests.setTarget(target);
    lib_tests.setBuildMode(mode);
    link(b, lib_tests, "");
    lib_tests.linkLibC();

    const test_step = b.step("test", "Runs the library tests.");
    test_step.dependOn(&lib_tests.step);
}
