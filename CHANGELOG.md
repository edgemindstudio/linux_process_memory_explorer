# Changelog

All notable changes to ProcLens will be documented in this file.

The format is based on Keep a Changelog principles, and the project intends to
follow semantic versioning once public releases begin.

## Unreleased

### Added

- Placeholder for changes not yet included in a release.

### Changed

- None.

### Fixed

- None.

### Security

- None.

## 0.1.0 - 2026-07-26

### Added

- Initial ProcLens repository structure.
- Milestone 0 project charter.
- System architecture and architectural invariants.
- Linux and WSL2 platform-support policy.
- Security and privacy policy.
- Initial risk register with twenty tracked risks.
- Testing strategy covering deterministic and live validation.
- Architecture Decision Record framework.
- ADR-0001 selecting direct procfs parsing.
- ADR-0002 establishing reusable library and thin CLI separation.
- ADR-0003 defining Linux-only scope and the WSL2 boundary.
- ADR-0004 defining partial results and structured diagnostics.
- ADR-0005 defining sensitive process-information defaults.
- ADR-0006 defining optional Project 2 ELF integration.
- Initial project README.
- Version 1 engineering roadmap.
- Contribution and review workflow.
- Compiler-warning CMake policy.
- Sanitizer CMake policy.
- Static-analysis CMake policy.
- clang-format configuration.
- clang-tidy configuration.
- EditorConfig configuration.
- Git ignore policy.
- MIT License.

### Changed

- Replaced directory placeholders with substantive documentation and CMake
  modules where foundation work has been completed.

### Fixed

- Removed an unsupported clang-tidy configuration key discovered during
  environment validation.
- Corrected ADR index update commands during documentation validation.

### Security

- Established a read-only process-inspection boundary.
- Prohibited privilege bypass, process control, code injection, arbitrary
  process-memory access, and shell execution using inspected data.
- Established data minimization for sensitive process information.
- Disabled process-environment collection by default.
- Required sanitization and review before captured procfs data enters Git.
- Required generated snapshots and live captures to remain ignored by default.

### Known limitations

- No substantive procfs parser is implemented.
- No process discovery or inspection commands are implemented.
- No CPU, memory, mapping, descriptor, thread, snapshot, or monitoring
  functionality is implemented.
- Build targets, presets, smoke tests, and CI are still being completed as part
  of Milestone 0.
- Native Linux compatibility beyond tested environments is not yet claimed.
- Performance-counter validation is deferred.
- Project 2 ELF integration is not implemented.

## Release policy

Future release entries should contain relevant sections from:

```text
Added
Changed
Deprecated
Removed
Fixed
Security
Known limitations
```

Every release entry must reflect actual repository behavior.

Planned features must not be recorded as released functionality.

## Versioning direction

The intended versioning model is:

```text
MAJOR.MINOR.PATCH
```

Where:

- `MAJOR` represents incompatible public API, CLI, or schema changes after
  stability commitments exist;
- `MINOR` represents backward-compatible capability additions;
- `PATCH` represents backward-compatible fixes and documentation corrections.

Before Version 1, the project may make breaking changes while architecture and
public interfaces are still evolving.

Any public compatibility promise must be documented explicitly rather than
inferred from version numbers alone.
