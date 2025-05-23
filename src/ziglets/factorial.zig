const std = @import("std");

/// Calculates the factorial of a number using multiple threads (limited to u128).
/// Usage: ziglets factorial <number> [num_threads]
pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    if (args.len == 0) {
        try stdout.print("Usage: ziglets factorial <number> [num_threads]\n", .{});
        return;
    }
    const n = std.fmt.parseInt(u32, args[0], 10) catch {
        try stdout.print("Invalid number: {s}\n", .{args[0]});
        return;
    };
    const num_threads: u32 = if (args.len > 1)
        (std.fmt.parseInt(u32, args[1], 10) catch 2)
    else
        2;
    if (num_threads < 1) {
        try stdout.print("Number of threads must be at least 1.\n", .{});
        return;
    }

    if (n > 34) {
        // 34! fits in u128, 35! no
        try stdout.print("Error: This factorial implementation supports up to 34! (u128 limit).\n", .{});
        return;
    }
    try stdout.print("Calculating {d}! using {d} thread(s)...\n", .{ n, num_threads });

    var handles = try allocator.alloc(std.Thread, num_threads);
    var results = try allocator.alloc(u128, num_threads);
    defer allocator.free(handles);
    defer allocator.free(results);

    const chunk: u32 = n / num_threads;
    const remainder: u32 = n % num_threads;
    var current: u32 = 1;
    for (0..num_threads) |i| {
        const start = current;
        const i_u32: u32 = @intCast(i);
        // Compute the end of the range for this thread
        var end: u32 = undefined;
        if (i == num_threads - 1) {
            end = n;
        } else {
            end = current + chunk - 1;
            if (i_u32 < remainder) end += 1;
        }
        current = end + 1;
        handles[i] = try std.Thread.spawn(std.Thread.SpawnConfig{}, threadMain, .{start, end, &results[i]});
    }
    for (handles) |*h| h.join();

    var final_result: u128 = 1;
    for (results) |res| {
        final_result *= res;
    }
    try stdout.print("Result: {d}\n", .{final_result});
}

/// Thread entry point: computes the product of [start, end] and stores in result
fn threadMain(start: u32, end: u32, result: *u128) void {
    var tmp: u128 = 1;
    var i: u32 = start;
    while (i <= end) : (i += 1) {
        if (i == 0) { // Factorial of 0 is 1, but our ranges usually start from 1.
            // If start is 0 for some reason, skip multiplying by 0.
            // However, for factorial, 0! = 1. If the range includes 0,
            // it implies calculating 0!, which is 1.
            // The loop for partial products should not multiply by 0.
            // The smallest number in any partial product range will be 1.
            // This check is more of a safeguard if logic changes.
            // For n=0, result is 1 (handled before threading).
            // For n > 0, ranges are [1..x], [x+1..y] etc.
            // So 'i' should not be 0 in normal operation.
            continue;
        }
        tmp *= i;
    }
    result.* = tmp;
}
