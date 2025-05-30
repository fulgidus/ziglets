const std = @import("std");
const main = @import("main.zig");

// Test to ensure the project compiles and basic functionality works
test "basic functionality tests" {
    // Test that we can import and reference our modules
    const testing = std.testing;
    
    // Basic test to ensure the test framework is working
    try testing.expect(true);
    
    // Test basic arithmetic
    try testing.expect(2 + 2 == 4);
    
    // Test that our commands array is properly defined
    try testing.expect(main.commands.len > 0);
}

test "command validation" {
    const testing = std.testing;
    
    // Test that all commands have non-empty names and descriptions
    for (main.commands) |cmd| {
        try testing.expect(cmd.name.len > 0);
        try testing.expect(cmd.description.len > 0);
    }
}
