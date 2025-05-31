//! Terminal clock implementation that displays current time and updates every second

const std = @import("std");

/// Display a live clock in the terminal that updates every second
/// Press Ctrl+C to exit
pub fn run(allocator: std.mem.Allocator, args: []const []const u8) !void {
    _ = allocator; // allocator not used in this implementation
    _ = args; // args not used in this implementation

    const stdout = std.io.getStdOut().writer();

    // Print initial message
    try stdout.print("Terminal Clock - Press Ctrl+C to exit\n\n", .{});

    // Simple implementation that works on all platforms
    while (true) {
        // Clear the current line and move cursor to beginning
        try stdout.print("\r", .{});

        // Get current time
        const timestamp = std.time.timestamp();
        const epoch_seconds = @as(u64, @intCast(timestamp));

        // Convert to broken down time (UTC)
        const epoch_day = epoch_seconds / std.time.s_per_day;
        const day_seconds = epoch_seconds % std.time.s_per_day;

        const hours = day_seconds / std.time.s_per_hour;
        const minutes = (day_seconds % std.time.s_per_hour) / std.time.s_per_min;
        const seconds = day_seconds % std.time.s_per_min;

        // Calculate date from epoch day
        const year = calculateYear(epoch_day);
        const day_of_year = calculateDayOfYear(epoch_day, year);
        const month_day = calculateMonthDay(day_of_year, isLeapYear(year));

        // Display formatted time and date with emojis
        try stdout.print("{d:0>4}-{d:0>2}-{d:0>2} {d:0>2}:{d:0>2}:{d:0>2} UTC", .{ year, month_day.month, month_day.day, hours, minutes, seconds });

        // Sleep for 1 second
        std.time.sleep(1 * std.time.ns_per_s);
    }
}

/// Calculate year from days since Unix epoch
pub fn calculateYear(epoch_day: u64) u32 {
    // Start from 1970 (Unix epoch)
    var year: u32 = 1970;
    var remaining_days = epoch_day;

    while (true) {
        const days_in_year: u32 = if (isLeapYear(year)) 366 else 365;
        if (remaining_days < days_in_year) break;
        remaining_days -= days_in_year;
        year += 1;
    }

    return year;
}

/// Calculate day of year from epoch day and year
pub fn calculateDayOfYear(epoch_day: u64, year: u32) u32 {
    var remaining_days = epoch_day;
    var check_year: u32 = 1970;

    while (check_year < year) {
        const days_in_year: u32 = if (isLeapYear(check_year)) 366 else 365;
        remaining_days -= days_in_year;
        check_year += 1;
    }

    return @as(u32, @intCast(remaining_days)) + 1; // Day of year is 1-indexed
}

/// Check if a year is a leap year
pub fn isLeapYear(year: u32) bool {
    return (year % 4 == 0 and year % 100 != 0) or (year % 400 == 0);
}

/// Month and day structure
pub const MonthDay = struct {
    month: u8,
    day: u8,
};

/// Calculate month and day from day of year
pub fn calculateMonthDay(day_of_year: u32, is_leap: bool) MonthDay {
    const days_in_months = if (is_leap)
        [_]u8{ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    else
        [_]u8{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    var remaining_days = day_of_year;
    var month: u8 = 1;

    for (days_in_months) |days_in_month| {
        if (remaining_days <= days_in_month) break;
        remaining_days -= days_in_month;
        month += 1;
    }

    return MonthDay{
        .month = month,
        .day = @as(u8, @intCast(remaining_days)),
    };
}
