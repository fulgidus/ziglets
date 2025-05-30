# Release Notes

## Ziglets v0.1.0 - Initial Release

**Release Date**: May 30, 2025

### 🎉 Introduction

Welcome to the first official release of **Ziglets**! This collection of simple Zig CLI applications is designed to help developers learn the Zig programming language through practical, easy-to-understand examples.

### 🚀 What's Included

Ziglets provides 11 different command-line utilities, each demonstrating different aspects of Zig programming:

#### Core Commands
- **`hello`** - Classic "Hello, World!" example
- **`goodbye`** - Simple goodbye message
- **`echo`** - Echo arguments back to the console
- **`help`** - Display comprehensive help information

#### Interactive Applications
- **`guess`** - Number guessing game with random number generation
- **`calculator`** - Real-time interactive calculator with keyboard input
- **`writer`** - File writing and reading demonstration

#### Utility Commands
- **`base64`** - Base64 encoding utility
- **`pgen`** - Secure password generator with customizable options
- **`touch`** - File creation utility (Unix-style touch command)
- **`factorial`** - Factorial calculation with large number support

### 📦 Download Options

This release provides pre-compiled binaries for multiple platforms and architectures:

#### Linux
- x86_64 (GNU libc)
- x86_64 (musl libc) 
- ARM64 (GNU libc)
- ARM64 (musl libc)

#### Windows
- x86_64 (GNU toolchain)
- x86_64 (MSVC toolchain)
- ARM64

#### macOS
- x86_64 (Intel Macs)
- ARM64 (Apple Silicon)

### 🔧 System Requirements

- **Linux**: glibc 2.17+ or musl libc
- **Windows**: Windows 10+ (x64) or Windows 11 (ARM64)
- **macOS**: macOS 10.15+ (Catalina)

### 🛠️ Building from Source

If you prefer to build from source, you'll need:
- Zig 0.14.0 or later
- Git for cloning the repository

```bash
git clone https://github.com/fulgidus/ziglets.git
cd ziglets
zig build -Doptimize=ReleaseFast
```

### 📋 Quick Start

After downloading and extracting the appropriate binary for your platform:

```bash
# Make executable (Linux/macOS only)
chmod +x ziglets

# Display all available commands
./ziglets help

# Try some examples
./ziglets hello
./ziglets echo "Welcome to Ziglets!"
./ziglets guess
./ziglets pgen -l 16 -aA1#
```

### 🎯 Educational Value

Each command in Ziglets demonstrates specific Zig programming concepts:

- **Memory Management**: Safe allocation and deallocation patterns
- **Error Handling**: Zig's unique error handling model
- **Cross-platform Code**: Platform-specific implementations
- **Standard Library**: Usage of Zig's standard library features
- **Modularity**: Clean code organization and module structure
- **Performance**: Efficient algorithms and data structures

### 🔒 Security & Verification

All release binaries include SHA256 checksums for verification. Download the `checksums.txt` file and verify your binary:

```bash
# Linux/macOS
sha256sum -c checksums.txt

# Windows PowerShell
Get-FileHash <filename> -Algorithm SHA256
```

### 🐛 Known Issues

- Calculator requires terminal with raw input support
- Some Unicode characters may not display correctly on older Windows terminals

### 📖 Documentation

- Complete source code documentation available in the repository
- Each command includes inline help with `ziglets <command> --help`
- Examples and usage patterns in the README

### 🤝 Contributing

We welcome contributions! See our contributing guidelines and coding standards in the repository.

### 📄 License

Ziglets is released under the MIT License. See LICENSE file for details.

### 🔗 Links

- **Repository**: https://github.com/fulgidus/ziglets
- **Issues**: https://github.com/fulgidus/ziglets/issues
- **Zig Language**: https://ziglang.org/

---

**Thank you for trying Ziglets!** We hope this project helps you learn and explore the Zig programming language.

For support, questions, or feedback, please open an issue on our GitHub repository.
