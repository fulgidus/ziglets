const std = @import("std");

pub fn run() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const secret = std.crypto.random.intRangeAtMost(u32, 1, 100);
    try stdout.print("Indovina il numero (1-100):\n", .{});
    while (true) {
        try stdout.print("> ", .{});
        var buf: [16]u8 = undefined;
        const line = try stdin.readUntilDelimiterOrEof(&buf, '\n');
        if (line == null) break;
        const guess = std.fmt.parseInt(u32, line.?, 10) catch {
            try stdout.print("Per favore inserisci un numero valido.\n", .{});
            continue;
        };
        if (guess < secret) {
            try stdout.print("Troppo basso!\n", .{});
        } else if (guess > secret) {
            try stdout.print("Troppo alto!\n", .{});
        } else {
            try stdout.print("Bravo! Il numero era {d}.\n", .{secret});
            break;
        }
    }
}
