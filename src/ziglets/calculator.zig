const std = @import("std");

// Calculator state
const State = struct {
    value: f64 = 0,
    operand: f64 = 0,
    op: ?u8 = null, // '+', '-', '*', '/'
    entering_operand: bool = false,
};

// Print the calculator display
fn printDisplay(state: *State, writer: anytype) !void {
    if (state.entering_operand) {
        try writer.print("\r{d:.8}        ", .{state.operand});
    } else {
        try writer.print("\r{d:.8}        ", .{state.value});
    }
}

// Apply the pending operation
fn applyOp(state: *State) void {
    if (state.op) |op| {
        switch (op) {
            '+' => state.value += state.operand,
            '-' => state.value -= state.operand,
            '*' => state.value *= state.operand,
            '/' => state.value = if (state.operand != 0) state.value / state.operand else state.value,
            else => {},
        }
    }
}

pub fn run(_: std.mem.Allocator, _: []const []const u8) !void {
    var state = State{};
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();

    try stdout.print("Calculator (press Q to exit)\n", .{});
    try printDisplay(&state, stdout);

    while (true) {
        var buf: [1]u8 = undefined;

        // Leggiamo un singolo carattere
        const bytes_read = stdin.read(&buf) catch |err| {
            try stdout.print("\nError durante la lettura: {s}\n", .{@errorName(err)});
            return err;
        };

        // Se non abbiamo letto nulla, continuiamo
        if (bytes_read == 0) continue;

        const c = buf[0];

        if (c == 'q' or c == 'Q') { // Q key
            try stdout.print("\nBye!\n", .{});
            return;
        }

        if (c >= '0' and c <= '9') {
            if (!state.entering_operand) {
                state.operand = 0;
                state.entering_operand = true;
            }
            // Use switch to convert char to digit
            var digit: f64 = 0;
            switch (c) {
                '0' => digit = 0,
                '1' => digit = 1,
                '2' => digit = 2,
                '3' => digit = 3,
                '4' => digit = 4,
                '5' => digit = 5,
                '6' => digit = 6,
                '7' => digit = 7,
                '8' => digit = 8,
                '9' => digit = 9,
                else => digit = 0, // Should not happen due to the check above
            }
            state.operand = state.operand * 10 + digit;
            try printDisplay(&state, stdout);
        } else if (c == '.' or c == ',') {
            // Decimal point not implemented for simplicity
        } else if (c == '+' or c == '-' or c == '*' or c == '/') {
            if (state.entering_operand) {
                if (state.op != null) {
                    applyOp(&state);
                } else {
                    state.value = state.operand;
                }
                state.entering_operand = false;
                state.operand = 0;
            }
            state.op = c;
            try printDisplay(&state, stdout);
        } else if (c == '=' or c == '\r' or c == '\n') {
            if (state.op != null and state.entering_operand) {
                applyOp(&state);
                state.op = null;
                state.entering_operand = false;
                state.operand = 0;
                try printDisplay(&state, stdout);
            }
        } else if (c == 8 or c == 127) { // Backspace
            if (state.entering_operand) {
                state.operand = @floor(state.operand / 10);
                try printDisplay(&state, stdout);
            }
        } else if (c == 'c' or c == 'C') { // Clear
            state = State{};
            try printDisplay(&state, stdout);
        }
    }
}
