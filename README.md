# Ziglets

**Ziglets** is a collection of simple Zig CLI applications, designed as educational examples for learning the Zig programming language.

## Purpose

The goal of this project is to provide minimal, easy-to-read code samples for common CLI patterns in Zig. Each command is implemented in its own file and demonstrates basic Zig features such as argument parsing, modularity, and interaction with the standard library.

## Building

To build the project, make sure you have [Zig](https://ziglang.org/download/) installed (tested with Zig 0.14.0):

```sh
zig build
```

The resulting binary will be located in `zig-out/bin/ziglets`.

## Usage

Run the CLI with:

```sh
zig-out/bin/ziglets <command> [args...]
```

### Show help

```sh
zig-out/bin/ziglets help
```

### Available commands

- `hello` &mdash; Prints "Hello, World!"
- `goodbye` &mdash; Prints "Goodbye, World!"
- `echo ...` &mdash; Runs the system `echo` command with the provided arguments
- `guess` &mdash; Play a "Guess the number" game
- `writer ...` &mdash; Save a string to `file.txt` and display its content
- `calculator` &mdash; Interactive calculator (press keys, Esc to exit)
- `help` &mdash; Shows the help page

### Example

```sh
zig-out/bin/ziglets hello
zig-out/bin/ziglets echo Zig is fun!
zig-out/bin/ziglets guess
zig-out/bin/ziglets writer Hello from Zig!
zig-out/bin/ziglets calculator
```

## Educational value

Each command is implemented in its own Zig file and imported in `main.zig`.  
You can explore the source code in the `src/` directory to see how each feature is implemented.

## Notes

- The file `file.txt` used by the `writer` command is ignored by git (see `.gitignore`).

