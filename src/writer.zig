const std = @import("std");

pub fn run(allocator: std.mem.Allocator, args: [][]const u8) !void {
    if (args.len < 1) {
        std.debug.print("Usage: ziglets writer <text>\n", .{});
        return error.InvalidArguments;
    }
    // Unisci gli argomenti in una singola stringa
    const text = try std.mem.join(allocator, " ", args);

    // Scrivi su file.txt
    const file_path = "file.txt";
    {
        var file = try std.fs.cwd().createFile(file_path, .{ .truncate = true, .read = true });
        defer file.close();
        try file.writer().writeAll(text);
    }

    // Rileggi e mostra il contenuto
    {
        var file = try std.fs.cwd().openFile(file_path, .{});
        defer file.close();
        var buf = try allocator.alloc(u8, 1024);
        const n = try file.reader().readAll(buf);
        try std.io.getStdOut().writer().print("file.txt content: {s}\n", .{buf[0..n]});
    }
}
