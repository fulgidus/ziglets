const std = @import("std");

pub fn run(allocator: std.mem.Allocator, args: [][]const u8) !void {
    if (args.len < 1) {
        std.debug.print("Usage: my-zig-cli echo <args...>\n", .{});
        return error.InvalidArguments;
    }
    var echo_args = try allocator.alloc([]const u8, args.len + 1);
    echo_args[0] = "echo";
    for (args, 1..) |arg, i| {
        echo_args[i] = arg;
    }
    var child = std.process.Child.init(echo_args, allocator);
    child.stdin_behavior = .Inherit;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;
    const term = try child.spawnAndWait();
    if (term.Exited != 0) {
        std.debug.print("echo exited with code {}\n", .{term.Exited});
    }
}
