const std = @import("std");

/// Main entry point for the touch command
/// allocator: memory allocator for allocations
/// args: command-line arguments (should contain at least one filename)
pub fn run(_: std.mem.Allocator, args: []const []const u8) !void {
    const stdout = std.io.getStdOut().writer(); // Get the standard output writer

    // If no filename is provided, print usage and return
    if (args.len == 0) {
        try stdout.print("Usage: ziglets touch <filename> [more files...]\n", .{});
        return;
    }

    // For each filename provided as argument
    for (args) |filename| {
        // Try to create the file (write mode, create if not exists, truncate if exists)
        var file = std.fs.cwd().createFile(filename, .{ .truncate = true }) catch |err| {
            // If there is an error, print a message and continue with the next file
            try stdout.print("Could not create file '{s}': {s}\n", .{ filename, @errorName(err) });
            continue;
        };
        // Close the file immediately (we just want to create/truncate it)
        file.close();
    }
}
