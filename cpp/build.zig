const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("../zig/src/lib.zig"),
        .name = "zalloc",
    });

    buildCxx(b, .{
        .target = target,
        .optimize = optimize,
        .lib = lib,
        .name = "new_override",
        .files = &.{
            "new_override/src/app.cc",
        },
        .include_dirs = &.{"new_override"},
    });
    buildCxx(b, .{
        .target = target,
        .optimize = optimize,
        .lib = lib,
        .name = "pmr",
        .files = &.{
            "pmr/src/app.cc",
        },
        .include_dirs = &.{"pmr"},
        .cxxstd = "-std=c++17",
    });
}
fn buildCxx(b: *std.Build, options: Config) void {
    const exe = b.addExecutable(.{
        .name = options.name,
        .target = options.target,
        .optimize = options.optimize,
    });
    exe.linkLibrary(options.lib);
    for (options.include_dirs) |dir| {
        exe.addIncludePath(b.path(dir));
    }
    exe.addCSourceFiles(.{
        .files = options.files,
        .flags = &.{options.cxxstd},
    });
    if (exe.rootModuleTarget().abi != .msvc)
        exe.linkLibCpp()
    else
        exe.linkLibC();
    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run.addArgs(args);
    }
    const run_step = b.step(b.fmt("run-{s}", .{exe.name}), b.fmt("Run the {s} app", .{options.name}));
    run_step.dependOn(&run.step);
}

const Config = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    lib: *std.Build.Step.Compile,
    name: []const u8,
    files: []const []const u8,
    include_dirs: []const []const u8 = &.{},
    cxxstd: []const u8 = "-std=c++14",
};
