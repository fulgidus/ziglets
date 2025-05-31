const std = @import("std");
const hello = @import("ziglets/hello.zig");
const goodbye = @import("ziglets/goodbye.zig");
const echo = @import("ziglets/echo.zig");
const guess = @import("ziglets/guess.zig");
const writer = @import("ziglets/writer.zig");
const base64 = @import("ziglets/base64.zig");
const calc = @import("ziglets/calculator.zig");
const pgen = @import("ziglets/pgen.zig");
const touch = @import("ziglets/touch.zig");
const factorial = @import("ziglets/factorial.zig");
const clock = @import("ziglets/clock.zig");

const CommandFn = *const fn (allocator: std.mem.Allocator, args: []const []const u8) anyerror!void;

const Command = struct {
    name: []const u8,
    description: []const u8,
    handler: CommandFn,
};

pub const commands = [_]Command{
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
    .{ .name = "base64", .description = "Encode text to Base64", .handler = base64.run },
    .{ .name = "pgen", .description = "Generate a random password", .handler = pgen.run },
    .{ .name = "calculator", .description = "Interactive calculator (press keys, Esc to exit)", .handler = calc.run },
    .{ .name = "touch", .description = "Create empty file(s)", .handler = touch.run },
    .{ .name = "factorial", .description = "Calculate factorial of a number", .handler = factorial.run },
    .{ .name = "clock", .description = "Display a live terminal clock (Ctrl+C to exit)", .handler = clock.run },
    .{ .name = "help", .description = "Shows this page", .handler = helpHandler },
};

fn helpHandler(_: std.mem.Allocator, _: []const []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print(
        \\ziglets <command>
        \\
        \\Available commands:
        \\
    , .{});
    for (commands) |cmd| {
        // Print the command name, padded to 10 chars, and its description
        try stdout.print("  {s: <12} {s}\n", .{ cmd.name, cmd.description });
    }
    try stdout.print("\n", .{});
}

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
