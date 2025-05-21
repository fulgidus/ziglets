const std = @import("std");

pub fn run() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const secret = std.crypto.random.intRangeAtMost(u32, 1, 100);
    try stdout.print("Guess the number (1-100):\n", .{});
    while (true) {
        try stdout.print("> ", .{});
        var buf: [16]u8 = undefined;
        const line = try stdin.readUntilDelimiterOrEof(&buf, '\n');
        if (line == null) break;
        const guess = std.fmt.parseInt(u32, line.?, 10) catch {
            try stdout.print("Please enter a valid number.\n", .{});
            continue;
        };
        if (guess < secret) {
            try stdout.print("Too low!\n", .{});
        } else if (guess > secret) {
            try stdout.print("Too high!\n", .{});
        } else {
            try stdout.print("Nice! The number was {d}.\n", .{secret});
            break;
        }
    }
}
