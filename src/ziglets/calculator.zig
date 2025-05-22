const std = @import("std");
const builtin = @import("builtin");

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

// Funzioni specifiche per piattaforma per l'input senza blocco
const RawMode = if (builtin.os.tag == .windows) struct {
    const windows = std.os.windows;

    // Costanti Windows per modalità console
    const ENABLE_ECHO_INPUT = 0x0004;
    const ENABLE_LINE_INPUT = 0x0002;

    var original_mode: windows.DWORD = undefined;
    var handle: windows.HANDLE = undefined;

    pub fn enable() !void {
        handle = windows.kernel32.GetStdHandle(windows.STD_INPUT_HANDLE) orelse return error.GetStdHandleFailed;

        if (windows.kernel32.GetConsoleMode(handle, &original_mode) == 0) {
            return error.GetConsoleModeFailed;
        }

        // Disattiva la modalità canonica e l'eco
        var new_mode = original_mode;
        new_mode &= ~@as(windows.DWORD, ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT);

        if (windows.kernel32.SetConsoleMode(handle, new_mode) == 0) {
            return error.SetConsoleModeFailed;
        }
    }

    pub fn disable() !void {
        if (windows.kernel32.SetConsoleMode(handle, original_mode) == 0) {
            return error.SetConsoleModeFailed;
        }
    }
} else struct {
    const posix = std.posix;

    var original_termios: posix.termios = undefined;

    pub fn enable() !void {
        const stdin_fd = posix.STDIN_FILENO;
        original_termios = try posix.tcgetattr(stdin_fd);
        var raw = original_termios;

        // Disabilita echo e modalità canonica
        raw.lflag &= ~@as(posix.tcflag_t, posix.ECHO | posix.ICANON | posix.ISIG | posix.IEXTEN);
        raw.iflag &= ~@as(posix.tcflag_t, posix.IXON | posix.ICRNL | posix.BRKINT | posix.INPCK | posix.ISTRIP);
        raw.oflag &= ~@as(posix.tcflag_t, posix.OPOST);
        raw.cc[posix.VMIN] = 1;
        raw.cc[posix.VTIME] = 0;

        try posix.tcsetattr(stdin_fd, .FLUSH, raw);
    }

    pub fn disable() !void {
        try posix.tcsetattr(posix.STDIN_FILENO, .FLUSH, original_termios);
    }
};

pub fn run(_: std.mem.Allocator, _: []const []const u8) !void {
    var state = State{};
    var stdin = std.io.getStdIn().reader();
    var stdout = std.io.getStdOut().writer();

    // Abilita la modalità raw per l'input istantaneo
    try RawMode.enable();
    defer {
        RawMode.disable() catch {};
    }

    try stdout.print("Calculator (press Q to exit)\n", .{});
    try printDisplay(&state, stdout);

    while (true) {
        var buf: [1]u8 = undefined;

        // Leggiamo un singolo carattere (ora senza bisogno di premere Enter)
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
