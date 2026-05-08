# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-05-08

### Changed

- `weekly` command no longer copies output to clipboard; it prints the summary directly to stdout
- Removed `--split` flag from `weekly` command

## [1.1.0] - 2026-03-24

### Added

- `--skip-duplicate` flag for the `add` command: silently skips adding a task if the exact same text already exists for the target date

## [1.0.0] - 2026-02-27

### Added

- Initial release of CLI tool