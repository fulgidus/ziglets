//
// Base64 Encoding Tool
// -------------------
//
// This module implements a simple Base64 encoder.
// Base64 is an encoding format that transforms binary data into ASCII characters,
// making it safe for transmission through systems that handle only text.
//
// Base64 uses 64 characters (A-Z, a-z, 0-9, + and /) and the '=' character for padding.

const std = @import("std");

/// The table of characters used in Base64 encoding
const BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/// Main function that handles Base64 encoding
pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    // Display a help message if there are no arguments
    if (args.len == 0) {
        std.debug.print("Usage: ziglets base64 <text>\n", .{});
        std.debug.print("Example: ziglets base64 \"Hello, Zig!\"\n", .{});
        return;
    }

    // Join all arguments into a single string
    const input = try joinArgs(allocator, args);
    defer allocator.free(input);

    // Perform Base64 encoding
    const encoded = try base64Encode(allocator, input);
    defer allocator.free(encoded);

    // Print the result
    std.debug.print("Original text: {s}\n", .{input});
    std.debug.print("Base64 encoding: {s}\n", .{encoded});
}

/// Function that joins all arguments into a single string
fn joinArgs(allocator: std.mem.Allocator, args: []const []const u8) ![]const u8 {
    // Calculate the total length needed
    var total_len: usize = 0;
    for (args) |arg| {
        total_len += arg.len;
    }

    // Add space for spaces between words (if there are multiple arguments)
    if (args.len > 1) {
        total_len += args.len - 1;
    }

    // Allocate a buffer for the resulting string
    const result = try allocator.alloc(u8, total_len);

    // Copy the arguments into the buffer, separated by spaces
    var index: usize = 0;
    for (args, 0..) |arg, i| {
        @memcpy(result[index..][0..arg.len], arg);
        index += arg.len;

        // Add a space after each argument except the last one
        if (i < args.len - 1) {
            result[index] = ' ';
            index += 1;
        }
    }

    return result;
}

/// Function that implements Base64 encoding
fn base64Encode(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    // Calculate the output length (including padding)
    // Every 3 bytes of input produce 4 characters in output
    const output_len = (input.len + 2) / 3 * 4;

    // Allocate a buffer for the output
    const output = try allocator.alloc(u8, output_len);

    var i: usize = 0; // Index for input
    var j: usize = 0; // Index for output

    // Process the input in groups of 3 bytes
    while (i + 3 <= input.len) {
        // Combine 3 bytes of input into a 24-bit value
        const val = (@as(u24, input[i]) << 16) |
            (@as(u24, input[i + 1]) << 8) |
            @as(u24, input[i + 2]);

        // Split the 24-bit value into 4 indices of 6 bits each
        // and use these indices to select characters from the BASE64_CHARS table
        output[j] = BASE64_CHARS[(val >> 18) & 0x3F];
        output[j + 1] = BASE64_CHARS[(val >> 12) & 0x3F];
        output[j + 2] = BASE64_CHARS[(val >> 6) & 0x3F];
        output[j + 3] = BASE64_CHARS[val & 0x3F];

        i += 3;
        j += 4;
    }

    // Handle remaining bytes (0, 1 or 2)
    if (i < input.len) {
        var val: u24 = @as(u24, input[i]) << 16;
        output[j] = BASE64_CHARS[(val >> 18) & 0x3F];

        if (i + 1 < input.len) {
            // We have 2 bytes remaining
            val |= @as(u24, input[i + 1]) << 8;
            output[j + 1] = BASE64_CHARS[(val >> 12) & 0x3F];
            output[j + 2] = BASE64_CHARS[(val >> 6) & 0x3F];
            output[j + 3] = '='; // Padding
        } else {
            // We have 1 byte remaining
            output[j + 1] = BASE64_CHARS[(val >> 12) & 0x3F];
            output[j + 2] = '='; // Padding
            output[j + 3] = '='; // Padding
        }
    }

    return output;
}
