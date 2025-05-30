# Ziglets

<div align="center">
    <img src="img/zero.png" alt="Ziglets Logo" width="200"/>
</div>

**Ziglets** is a collection of simple Zig CLI applications, designed as educational examples for learning the Zig programming language.

[![Zig](https://img.shields.io/badge/Zig-0.14.0-orange.svg)](https://ziglang.org/download/)
[![License](https://img.shields.io/badge/GPL-3.0-blue.svg)](https://opensource.org/licenses/GPL-3.0)
![GitHub Stars](https://img.shields.io/github/stars/fulgidus/ziglets.svg?style=social)
[![Latest Release](https://img.shields.io/github/v/release/fulgidus/ziglets)](https://github.com/fulgidus/ziglets/releases/latest)
[![CI](https://github.com/fulgidus/ziglets/workflows/CI/badge.svg)](https://github.com/fulgidus/ziglets/actions/workflows/ci.yml)
[![Release](https://github.com/fulgidus/ziglets/workflows/Release/badge.svg)](https://github.com/fulgidus/ziglets/actions/workflows/release.yml)

## Purpose

The goal of this project is to provide minimal, easy-to-read code samples for common CLI patterns in Zig. Each command is implemented in its own file and demonstrates basic Zig features such as argument parsing, modularity, and interaction with the standard library.

## Building

To build the project, make sure you have [Zig](https://ziglang.org/download/) installed (tested with Zig 0.14.0):

```sh
zig build
```

The resulting binary will be located in `zig-out/bin/ziglets`.

## Downloads

Pre-built binaries are available for multiple platforms and architectures. Visit the [Releases page](https://github.com/fulgidus/ziglets/releases/latest) to download:

### Supported Platforms
- **Linux**: x86_64 and ARM64 (both glibc and musl)
- **Windows**: x86_64 and ARM64 (GNU and MSVC toolchains)
- **macOS**: x86_64 (Intel) and ARM64 (Apple Silicon)

### Release Pipeline
- Automated releases are created when tags following semantic versioning (`v*.*.*`) are pushed to the main branch
- All binaries include SHA256 checksums for verification
- Cross-platform builds are tested on every release

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
- `base64 ...` &mdash; Encode text to Base64
- `pgen ...` &mdash; Generate a random password
- `calculator` &mdash; Interactive calculator (press keys, Q to exit)
- `touch ...` &mdash; Create empty file(s)
- `factorial <number> [num_threads]` &mdash; Calculate the factorial of a number using multiple threads
- `help` &mdash; Shows the help page

### Example

```sh
zig-out/bin/ziglets hello
zig-out/bin/ziglets echo Zig is fun!
zig-out/bin/ziglets guess
zig-out/bin/ziglets writer Hello from Zig!
zig-out/bin/ziglets base64 "Hello, Base64!"
zig-out/bin/ziglets pgen -l 16 -aA1&
zig-out/bin/ziglets calculator
zig-out/bin/ziglets touch file.txt
zig-out/bin/ziglets factorial 20 4
```

## Educational value

Each command is implemented in its own Zig file and imported in `main.zig`.  
You can explore the source code in the `src/` directory to see how each feature is implemented.

## Notes

- The file `file.txt` used by the `writer` command is ignored by git (see `.gitignore`).

