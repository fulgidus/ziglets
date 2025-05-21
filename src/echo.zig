const std = @import("std"); // Import the Zig standard library

pub fn run(_: std.mem.Allocator, args: []const []const u8) !void { // Define the 'run' function, takes an allocator (unused) and an array of string slices as arguments, returns void or error
    if (args.len == 0) { // If there are no arguments
        std.debug.print("\n", .{}); // Print a newline
        return; // Exit the function
    }
    for (args, 0..) |arg, i| { // Iterate over each argument and its index
        std.debug.print("{s}", .{arg}); // Print the argument as a string
        if (i != args.len - 1) { // If this is not the last argument
            std.debug.print(" ", .{}); // Print a space
        }
    }
    std.debug.print("\n", .{}); // Print a newline at the end
}
