const std = @import("std");
const main = @import("main.zig");
const clock = @import("ziglets/clock.zig");

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

test "clock date calculation functions" {
    const testing = std.testing;

    // Test leap year calculation
    try testing.expect(clock.isLeapYear(2020) == true); // Divisible by 4 and 400
    try testing.expect(clock.isLeapYear(2021) == false); // Not divisible by 4
    try testing.expect(clock.isLeapYear(1900) == false); // Divisible by 100 but not 400
    try testing.expect(clock.isLeapYear(2000) == true); // Divisible by 400
    try testing.expect(clock.isLeapYear(2024) == true); // Divisible by 4 but not 100

    // Test year calculation (basic test with known epoch day)
    // January 1, 1971 (1 year after epoch) = 365 days
    try testing.expect(clock.calculateYear(365) == 1971);

    // Test year calculation for a leap year boundary
    // January 2, 1972 = 365 + 365 + 1 = 731 days
    try testing.expect(clock.calculateYear(731) == 1972);

    // Test day of year calculation
    // For year 1970, day 0 should return day 1 (January 1st)
    try testing.expect(clock.calculateDayOfYear(0, 1970) == 1);

    // Test month and day calculation
    const jan_1 = clock.calculateMonthDay(1, false); // January 1st (non-leap year)
    try testing.expect(jan_1.month == 1);
    try testing.expect(jan_1.day == 1);

    const feb_29_leap = clock.calculateMonthDay(60, true); // February 29th (leap year)
    try testing.expect(feb_29_leap.month == 2);
    try testing.expect(feb_29_leap.day == 29);

    const dec_31_non_leap = clock.calculateMonthDay(365, false); // December 31st (non-leap year)
    try testing.expect(dec_31_non_leap.month == 12);
    try testing.expect(dec_31_non_leap.day == 31);

    const dec_31_leap = clock.calculateMonthDay(366, true); // December 31st (leap year)
    try testing.expect(dec_31_leap.month == 12);
    try testing.expect(dec_31_leap.day == 31);
}
