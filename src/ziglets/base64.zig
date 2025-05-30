//
// Base64 Encoding Tool
// -------------------
//
// This module implements a simple Base64 encoder.
// Base64 is an encoding format that transforms binary data into ASCII characters,
// making it safe for transmission through systems that handle only text.
//
// Base64 uses 64 characters (A-Z, a-z, 0-9, + and /) and the '=' character for padding.

// Import the standard library to use its functionality
const std = @import("std");

/// The table of characters used in Base64 encoding
// This string contains all 64 characters used in Base64 encoding in their specific order
const BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/// Main function that handles Base64 encoding
// This is the entry point for the base64 command
// It takes an allocator for memory management and command-line arguments
pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    // Check if there are any arguments provided
    if (args.len == 0) {
        // If no arguments, show usage information to guide the user
        std.debug.print("Usage: ziglets base64 <text>\n", .{});
        // Provide an example to clarify how to use the command
        std.debug.print("Example: ziglets base64 \"Hello, Zig!\"\n", .{});
        // Exit the function early since we can't proceed without input
        return;
    }

    // Join all provided arguments into a single text string
    const input = try joinArgs(allocator, args);
    // Schedule cleanup of the allocated memory when this function exits
    defer allocator.free(input);

    // Convert the input string to its Base64 representation
    const encoded = try base64Encode(allocator, input);
    // Schedule cleanup of the encoded result when this function exits
    defer allocator.free(encoded);

    // Display the original text for comparison
    std.debug.print("Original text: {s}\n", .{input});
    // Display the Base64 encoded result
    std.debug.print("Base64 encoding: {s}\n", .{encoded});
}

/// Function that joins all arguments into a single string
// This helper function combines multiple command line arguments into one text
fn joinArgs(allocator: std.mem.Allocator, args: []const []const u8) ![]const u8 {
    // Initialize a counter to track the total characters needed
    var total_len: usize = 0;
    // Iterate through each argument to add up their lengths
    for (args) |arg| {
        // Add the length of this argument to our running total
        total_len += arg.len;
    }

    // If we have multiple arguments, we'll need spaces between them
    if (args.len > 1) {
        // Add space for one space character between each pair of arguments
        total_len += args.len - 1;
    }

    // Request a block of memory from the allocator to hold our combined string
    const result = try allocator.alloc(u8, total_len);

    // Keep track of our current position in the result buffer
    var index: usize = 0;
    // Loop through each argument with its index
    for (args, 0..) |arg, i| {
        // Copy the current argument into the result buffer at the current position
        @memcpy(result[index..][0..arg.len], arg);
        // Move our position index forward by the length of the argument we just copied
        index += arg.len;

        // Add a space after every argument except the last one
        if (i < args.len - 1) {
            // Insert a space character at the current position
            result[index] = ' ';
            // Move the position index forward by one for the space we just added
            index += 1;
        }
    }

    // Return the fully constructed string containing all arguments
    return result;
}

/// Function that implements Base64 encoding
// This is the core function that performs the actual Base64 encoding algorithm
fn base64Encode(allocator: std.mem.Allocator, input: []const u8) ![]const u8 {
    // Calculate the output length based on the Base64 formula: ceil(n/3)*4
    // We add 2 to input.len before dividing to ensure proper rounding up
    const output_len = (input.len + 2) / 3 * 4;

    // Allocate memory for the encoded output string
    const output = try allocator.alloc(u8, output_len);

    // Initialize input position tracker
    var i: usize = 0;
    // Initialize output position tracker
    var j: usize = 0;

    // Process complete groups of 3 input bytes (which convert to 4 output bytes)
    while (i + 3 <= input.len) {
        // Combine 3 bytes into a single 24-bit value for efficient processing
        // First byte shifted to most significant position (bits 16-23)
        const val = (@as(u24, input[i]) << 16) |
            // Second byte placed in middle position (bits 8-15)
            (@as(u24, input[i + 1]) << 8) |
            // Third byte in least significant position (bits 0-7)
            @as(u24, input[i + 2]);

        // Extract first 6 bits (bits 18-23) and use as an index into the character table
        output[j] = BASE64_CHARS[(val >> 18) & 0x3F];
        // Extract second 6 bits (bits 12-17) and use as an index
        output[j + 1] = BASE64_CHARS[(val >> 12) & 0x3F];
        // Extract third 6 bits (bits 6-11) and use as an index
        output[j + 2] = BASE64_CHARS[(val >> 6) & 0x3F];
        // Extract fourth 6 bits (bits 0-5) and use as an index
        output[j + 3] = BASE64_CHARS[val & 0x3F];

        // Move input position forward by 3 bytes (processed)
        i += 3;
        // Move output position forward by 4 bytes (generated)
        j += 4;
    }

    // Handle remaining bytes (0, 1 or 2)
    if (i < input.len) {
        // We have at least one remaining byte, shift it to the high bits
        var val: u24 = @as(u24, input[i]) << 16;
        // Use the first 6 bits to get the first output character
        output[j] = BASE64_CHARS[(val >> 18) & 0x3F];

        if (i + 1 < input.len) {
            // We have 2 bytes remaining (need 2 characters + 1 padding)
            // Add the second byte to our 24-bit value
            val |= @as(u24, input[i + 1]) << 8;
            // Extract the next 6 bits for the second output character
            output[j + 1] = BASE64_CHARS[(val >> 12) & 0x3F];
            // Extract the next 6 bits for the third output character
            output[j + 2] = BASE64_CHARS[(val >> 6) & 0x3F];
            // Add padding for the fourth position (since we only had 2 input bytes)
            output[j + 3] = '='; // Padding
        } else {
            // We have only 1 byte remaining (need 1 character + 2 paddings)
            // Extract the middle 6 bits for the second output character
            output[j + 1] = BASE64_CHARS[(val >> 12) & 0x3F];
            // Add padding for the third position
            output[j + 2] = '='; // Padding
            // Add padding for the fourth position
            output[j + 3] = '='; // Padding
        }
    }

    // Return the completed Base64 encoded string
    return output;
}
