const std = @import("std"); // Import the Zig standard library

pub fn run(allocator: std.mem.Allocator, args: []const []const u8) anyerror!void { // Define the 'run' function, takes an allocator and an array of string slices, returns void or error
    if (args.len < 1) { // If there are no arguments
        std.debug.print("Usage: ziglets writer <text>\n", .{}); // Print usage instructions
        return error.InvalidArguments; // Return an error for invalid arguments
    }
    // Combine the arguments into a single string
    const text = try std.mem.join(allocator, " ", args); // Join all arguments with spaces into one string

    // Write to file.txt
    const file_path = "file.txt"; // Set the file path to "file.txt"
    {
        var file = try std.fs.cwd().createFile(file_path, .{ .truncate = true, .read = true }); // Create or truncate "file.txt" for writing and reading
        defer file.close(); // Ensure the file is closed when the block ends
        try file.writer().writeAll(text); // Write the combined text to the file
    }

    // Read and display the content
    {
        var file = try std.fs.cwd().openFile(file_path, .{}); // Open "file.txt" for reading
        defer file.close(); // Ensure the file is closed when the block ends
        var buf = try allocator.alloc(u8, 1024); // Allocate a buffer of 1024 bytes
        const n = try file.reader().readAll(buf); // Read the file content into the buffer, get the number of bytes read
        try std.io.getStdOut().writer().print("file.txt content: {s}\n", .{buf[0..n]}); // Print the content of the file to standard output
    }
}
