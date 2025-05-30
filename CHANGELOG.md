# Changelog

All notable changes to the Ziglets project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Cross-platform CI/CD pipeline with GitHub Actions
- Automated multi-platform releases for Windows, Linux, and macOS
- Deployment scripts for Linux (`deploy-linux.sh`) and Windows (`deploy-windows.ps1`)
- Semantic versioning validation in release pipeline
- Comprehensive testing across multiple platforms and architectures
- Cross-compilation support for multiple target architectures
- Automated code formatting checks with `zig fmt`
- Release artifacts with SHA256 checksums for verification
- Automated release notes generation

### Changed
- Enhanced build system with better cross-platform support
- Improved project structure with organized scripts directory
- Updated documentation to reflect new CI/CD capabilities

### Security
- Added checksum verification for all release artifacts
- Implemented secure deployment pipeline with proper validation

## [0.1.0] - 2025-05-30

### Added
- Initial release of Ziglets CLI application collection
- Basic commands: hello, goodbye, echo, guess, writer, base64, pgen, calculator, touch, factorial, help
- Cross-platform support for Windows, Linux, and macOS
- Interactive calculator with real-time key input
- Password generator with customizable options
- Base64 encoding functionality
- Number guessing game
- File creation and manipulation utilities
- Comprehensive help system
- MIT license and project documentation

### Technical Details
- Built with Zig 0.14.0
- Support for multiple target architectures
- Memory-safe implementation
- Minimal dependencies
- Educational code examples for Zig learning
