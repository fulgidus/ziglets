//
// Password Generator Tool
// ----------------------
//
// This module implements a simple password generator.
// It allows users to specify the length and character sets to include
// in the generated password, providing a secure and customizable way
// to create strong passwords.

// Import the standard library to use its functionality
const std = @import("std");

// Character sets for different types of characters
// These will be used to build the pool of available characters
const LOWERCASE_CHARS = "abcdefghijklmnopqrstuvwxyz";
const UPPERCASE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const NUMBER_CHARS = "0123456789";
const SYMBOL_CHARS = "!@#$%^&*()-_=+[]{}|;:,.<>?/";

/// Main entry point for the password generator tool
/// Takes an allocator for memory management and command-line arguments
pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    const stdout = std.io.getStdOut().writer();
    // Default settings for the password
    var password_length: usize = 12; // Default length
    var use_lowercase = false; // Include lowercase letters?
    var use_uppercase = false; // Include uppercase letters?
    var use_numbers = false; // Include numbers?
    var use_symbols = false; // Include special symbols?
    var show_help = false; // Show help information?

    // If no arguments provided, show help
    if (args.len == 0) {
        use_lowercase = true; // Default to lowercase if no args
        use_uppercase = true; // Default to uppercase if no args
        use_numbers = true; // Default to numbers if no args
        use_symbols = true; // Default to symbols if no args
    } else {
        // Process command-line arguments
        var i: usize = 0;
        while (i < args.len) : (i += 1) {
            const arg = args[i];

            // Parse the length parameter
            if (std.mem.eql(u8, arg, "-l") or std.mem.eql(u8, arg, "--length")) {
                // Check if there's another argument after this one to parse as the length
                if (i + 1 < args.len) {
                    i += 1; // Move to the next argument
                    password_length = try parseLength(args[i], stdout);
                }
            }
            // Parse character set flags (can be combined, e.g., -aA1&)
            else if (arg.len > 0 and arg[0] == '-') {
                // If it's -h or --help, show help
                if (std.mem.eql(u8, arg, "-h") or std.mem.eql(u8, arg, "--help")) {
                    show_help = true;
                    break;
                }

                // Examine each character in the flag
                for (arg[1..]) |char| {
                    switch (char) {
                        'a' => use_lowercase = true, // 'a' for lowercase
                        'A' => use_uppercase = true, // 'A' for uppercase
                        '1' => use_numbers = true, // '1' for numbers
                        '@' => use_symbols = true, // '&' for symbols
                        else => {}, // Ignore unknown flags
                    }
                }
            }
        }
    }

    // Display help message if requested or if no character set was selected
    if (show_help or (!use_lowercase and !use_uppercase and !use_numbers and !use_symbols)) {
        printHelp(stdout);
        return;
    }

    // Generate and display the password
    const password = try generatePassword(allocator, stdout, password_length, use_lowercase, use_uppercase, use_numbers, use_symbols);
    defer allocator.free(password);

    // Output the generated password
    try stdout.print("Generated password: {s}\n", .{password});
}

/// Parse a string into an unsigned integer for the password length
/// Handles errors and enforces minimum and maximum length constraints
fn parseLength(length_str: []const u8, writer: anytype) !usize {
    // Parse the string to an integer
    const length = std.fmt.parseInt(usize, length_str, 10) catch {
        try writer.print("Error: Invalid length value '{s}'. Using default length of 12.\n", .{length_str});
        return 12; // Return default value on error
    };

    // Enforce reasonable limits on password length
    if (length < 4) {
        try writer.print("Warning: Length too short (minimum is 4). Using length of 4.\n", .{});
        return 4;
    }

    if (length > 128) {
        try writer.print("Warning: Length too long (maximum is 128). Using length of 128.\n", .{});
        return 128;
    }

    return length;
}

/// Print help information showing how to use the password generator
fn printHelp(writer: anytype) void {
    writer.print(
        \\Password Generator Usage:
        \\  ziglets pgen [options]
        \\
        \\Options:
        \\  -l, --length NUMBER  Set password length (default: 12, min: 4, max: 128)
        \\  -a                   Include lowercase letters (a-z)
        \\  -A                   Include uppercase letters (A-Z)
        \\  -1                   Include numbers (0-9)
        \\  -@                   Include symbols (!@#$%^&*()-_=+[]{{}}|;:,.<>?/)
        \\  -h, --help           Show this help message
        \\
        \\Examples:
        \\  ziglets pgen -l 16 -aA1     Generate a 16-character password with lowercase, uppercase, and numbers
        \\  ziglets pgen -aA1@          Generate a 12-character password with all character types
        \\
    , .{}) catch |e| {
        // Handle any errors that occur while printing
        std.debug.print("Error printing help: {}\n", .{e});
    };
}

/// Generate a random password based on the specified criteria
/// This is the core function that builds and returns the password
fn generatePassword(allocator: std.mem.Allocator, writer: anytype, length: usize, use_lowercase: bool, use_uppercase: bool, use_numbers: bool, use_symbols: bool) ![]const u8 {
    // Create a character pool based on the selected options
    var char_pool = std.ArrayList(u8).init(allocator);
    defer char_pool.deinit();

    // Add the selected character sets to our pool
    if (use_lowercase) {
        try addCharsToPool(&char_pool, LOWERCASE_CHARS);
    }
    if (use_uppercase) {
        try addCharsToPool(&char_pool, UPPERCASE_CHARS);
    }
    if (use_numbers) {
        try addCharsToPool(&char_pool, NUMBER_CHARS);
    }
    if (use_symbols) {
        try addCharsToPool(&char_pool, SYMBOL_CHARS);
    }

    // Ensure we have at least some characters in the pool
    if (char_pool.items.len == 0) {
        try writer.print("Warning: No character sets selected. Using lowercase as default.\n", .{});
        try addCharsToPool(&char_pool, LOWERCASE_CHARS);
    } // Allocate space for the password
    const password = try allocator.alloc(u8, length);

    // Generate a random password using the crypto module's secure random generator
    for (0..length) |i| {
        // Get a random index within the range of the character pool
        const random_index = std.crypto.random.uintLessThan(usize, char_pool.items.len);
        // Use that random index to select a character from our pool
        password[i] = char_pool.items[random_index];
    }

    return password;
}

/// Helper function to add a set of characters to the character pool
fn addCharsToPool(pool: *std.ArrayList(u8), chars: []const u8) !void {
    for (chars) |char| {
        try pool.append(char);
    }
}
