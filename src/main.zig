const std = @import("std");
const hello = @import("ziglets/hello.zig");
const goodbye = @import("ziglets/goodbye.zig");
const echo = @import("ziglets/echo.zig");
const guess = @import("ziglets/guess.zig");
const writer = @import("ziglets/writer.zig");

const CommandFn = *const fn (allocator: std.mem.Allocator, args: []const []const u8) anyerror!void;

const Command = struct {
    name: []const u8,
    description: []const u8,
    handler: CommandFn,
};

fn helpHandler(_: std.mem.Allocator, _: []const []const u8) !void {
    std.debug.print(
        \\ziglets <command>
        \\
        \\Available commands:
        \\  hello      Prints 'Hello, World!'
        \\  goodbye    Prints 'Goodbye, World!'
        \\  echo ...   Starts echo with provided arguments
        \\  guess      Play "Guess the number"
        \\  writer ... Save a string to file.txt and display its content
        \\  calculator Interactive calculator (press keys, Esc to exit)
        \\  help       Shows this page
        \\
    , .{});
}

const commands = [_]Command{
    .{ .name = "hello", .description = "Prints 'Hello, World!'", .handler = struct {
        pub fn run(_: std.mem.Allocator, _: []const []const u8) !void {
            hello.run();
        }
    }.run },
    .{ .name = "goodbye", .description = "Prints 'Goodbye, World!'", .handler = struct {
        pub fn run(_: std.mem.Allocator, _: []const []const u8) !void {
            goodbye.run();
        }
    }.run },
    .{ .name = "echo", .description = "Starts echo with provided arguments", .handler = echo.run },
    .{ .name = "guess", .description = "Play \"Guess the number\"", .handler = struct {
        pub fn run(_: std.mem.Allocator, _: []const []const u8) !void {
            try guess.run();
        }
    }.run },
    .{ .name = "writer", .description = "Save a string to file.txt and display its content", .handler = writer.run },
    .{ .name = "calculator", .description = "Interactive calculator (press keys, Esc to exit)", .handler = @import("ziglets/calculator.zig").run },
    .{ .name = "help", .description = "Shows this page", .handler = helpHandler },
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args_iter = try std.process.argsWithAllocator(arena.allocator());
    var args = std.ArrayList([]const u8).init(arena.allocator());

    while (true) {
        const arg = args_iter.next();
        if (arg == null) break;
        try args.append(arg.?);
    }

    if (args.items.len < 2) {
        std.debug.print("Usage: ziglets <command>\n", .{});
        std.debug.print("Try 'ziglets help' for more information.\n", .{});
        return error.InvalidArguments;
    }

    const command = args.items[1];
    for (commands) |cmd| {
        if (std.mem.eql(u8, command, cmd.name)) {
            try cmd.handler(arena.allocator(), args.items[2..]);
            return;
        }
    }

    std.debug.print("Unknown command: {s}\n", .{command});
    std.debug.print("Try 'ziglets help' for more information.\n", .{});
    return error.UnknownCommand;
}
