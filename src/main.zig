const std = @import("std");
const hello = @import("hello.zig");
const goodbye = @import("goodbye.zig");
const echo = @import("echo.zig");
const guess = @import("guess.zig");
const writer = @import("writer.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args_iter = std.process.args();
    var args = std.ArrayList([]const u8).init(arena.allocator());
    while (args_iter.next()) |arg| {
        try args.append(arg);
    }

    if (args.items.len < 2) {
        std.debug.print("Usage: ziglets <command>\n", .{});
        std.debug.print("Try 'ziglets help' for more information.\n", .{});
        return error.InvalidArguments;
    }

    const command = args.items[1];
    if (std.mem.eql(u8, command, "hello")) {
        hello.run();
    } else if (std.mem.eql(u8, command, "goodbye")) {
        goodbye.run();
    } else if (std.mem.eql(u8, command, "help")) {
        std.debug.print(
            \\ziglets <command>
            \\
            \\Available commands:
            \\  hello      Prints 'Hello, World!'
            \\  goodbye    Prints 'Goodbye, World!'
            \\  echo ...   Starts echo with provided arguments
            \\  guess      Play "Guess the number"
            \\  writer ... Save a string to file.txt and display its content
            \\  help       Shows this page
            \\
        , .{});
    } else if (std.mem.eql(u8, command, "echo")) {
        if (args.items.len < 3) {
            std.debug.print("Usage: ziglets echo <args...>\n", .{});
            return error.InvalidArguments;
        }
        try echo.run(arena.allocator(), args.items[2..]);
    } else if (std.mem.eql(u8, command, "guess")) {
        try guess.run();
    } else if (std.mem.eql(u8, command, "writer")) {
        if (args.items.len < 3) {
            std.debug.print("Usage: ziglets writer <text>\n", .{});
            return error.InvalidArguments;
        }
        try writer.run(arena.allocator(), args.items[2..]);
    } else {
        std.debug.print("Unknown command: {s}\n", .{command});
        std.debug.print("Try 'ziglets help' for more information.\n", .{});
        return error.UnknownCommand;
    }
}
