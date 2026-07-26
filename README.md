# ProcLens

ProcLens is a Linux process and virtual-memory exploration tool designed to
inspect and explain live process state through Linux procfs and documented
Linux system interfaces.

The project is being developed as part of a compiler, runtime, and systems
engineering portfolio.

## Current status

ProcLens is currently at **Milestone 0: Discovery and Engineering Foundation**.

Milestone 0 establishes:

- the project charter;
- system architecture;
- Linux and WSL2 platform boundaries;
- security and privacy policies;
- testing strategy;
- risk register;
- Architecture Decision Records;
- strict C++ build policies;
- sanitizers;
- static analysis;
- formatting;
- automated tests;
- continuous integration.

Milestone 0 does not yet implement substantive process inspection.

## Project goals

ProcLens is intended to provide direct engineering experience with:

- Linux process interfaces;
- procfs parsing;
- process lifecycle races;
- PID reuse;
- process and thread metadata;
- CPU accounting;
- virtual-memory mappings;
- resident and virtual memory;
- page faults;
- resource limits;
- file descriptors;
- I/O counters;
- snapshot capture and comparison;
- partial results;
- deterministic systems testing;
- terminal-oriented diagnostics.

## Planned Version 1 capabilities

Planned commands include capabilities for:

- listing processes;
- inspecting process metadata;
- viewing process trees;
- examining threads;
- sampling CPU usage;
- inspecting memory accounting;
- examining virtual-memory mappings;
- inspecting file descriptors;
- viewing resource limits;
- inspecting I/O activity;
- capturing snapshots;
- comparing snapshots;
- rendering text and JSON output.

These capabilities are planned and are not yet implemented.

## Core engineering principles

ProcLens follows several architectural rules:

1. Core process data is read directly from Linux procfs and documented Linux
   interfaces.
2. The reusable library remains separate from the command-line interface.
3. The CLI does not parse procfs.
4. Partial results preserve usable data and attach diagnostics.
5. Unavailable information is not represented as numeric zero.
6. Process disappearance is treated as an expected observation outcome.
7. PID reuse is considered whenever observations span time.
8. Sensitive process data is minimized by default.
9. Process environments are not read automatically.
10. Project 2 ELF integration remains optional.
11. WSL2 validation is not treated as universal native-Linux validation.
12. Concurrency is introduced only when measured requirements justify it.

## Architecture

The initial dependency structure is:

```text
proclens
    ↓
proclens_core
```

Planned data flow:

```text
Linux procfs
    ↓
safe procfs access
    ↓
interface-specific parsers
    ↓
normalized domain models
    ↓
sampling and analysis
    ↓
text or JSON presentation
```

The project begins with three targets:

- `proclens_core` — reusable C++ library;
- `proclens` — thin command-line application;
- `proclens_smoke_tests` — Milestone 0 build and linkage proof.

See:

- `docs/project_charter.md`;
- `docs/architecture/system_architecture.md`;
- `docs/adr/README.md`.

## Platform scope

ProcLens Version 1 is Linux-specific.

The primary development environment is:

- Kali GNU/Linux Rolling 2026.1;
- x86-64;
- WSL2;
- Microsoft Linux kernel `6.6.87.2-microsoft-standard-WSL2`.

Native Linux is the reference operating-system model.

WSL2 is supported for development and functional testing, but WSL2 validation
does not prove compatibility with every native Linux system.

See `docs/platform/platform_support.md`.

## Security and privacy

ProcLens is a read-only inspection tool.

It does not:

- modify process memory;
- read arbitrary process memory;
- attach with `ptrace`;
- inject code;
- send signals;
- terminate processes;
- bypass permissions;
- weaken system security settings;
- require root for normal operation.

Process command lines, paths, descriptors, mappings, and snapshots may contain
sensitive information.

Complete process environments are not collected by default.

See:

- `docs/security/privacy_and_permissions.md`;
- `docs/security/risk_register.md`.

## Testing strategy

ProcLens combines:

- deterministic fixture tests;
- unit tests;
- controlled child-process integration tests;
- regression tests;
- golden-output tests;
- stress tests;
- compiler warnings;
- clang-tidy;
- Cppcheck;
- sanitizers;
- live comparison with standard Linux tools.

Live procfs tests supplement deterministic fixtures. They do not replace them.

See `docs/development/testing_strategy.md`.

## Repository structure

```text
.github/workflows/       Continuous-integration workflows
cmake/                   Reusable CMake policies
docs/                    Architecture and engineering documentation
examples/                Controlled demonstrations
fixtures/                Sanitized deterministic test data
include/proclens/        Public library headers
schemas/                 Versioned data schemas
scripts/                 Developer and CI workflows
src/                     Core library implementation
tests/                   Automated tests
tools/proclens/          CLI implementation
```

## Build requirements

The planned build requires:

- a C++20 compiler;
- CMake;
- Ninja or another supported CMake generator;
- Git.

The audited local toolchain includes:

- Clang 21.1.8;
- GCC 15.2.0;
- CMake 4.3.3;
- Ninja 1.13.2;
- clang-format 21.1.8;
- clang-tidy 21.1.8;
- Cppcheck 2.20.0.

Audited versions are not necessarily minimum supported versions.

## Planned build workflow

Once the Milestone 0 build files are complete, the expected workflow will use
CMake presets such as:

```bash
cmake --preset debug-clang
cmake --build --preset debug-clang
ctest --preset debug-clang
```

Additional presets will cover:

- Clang Debug and Release;
- GCC Debug and Release;
- sanitizers;
- static analysis;
- benchmarks in later milestones.

The exact preset names remain subject to final Milestone 0 validation.

## Documentation

Important documents include:

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/platform/platform_support.md`
- `docs/security/risk_register.md`
- `docs/security/privacy_and_permissions.md`
- `docs/development/testing_strategy.md`
- `docs/adr/README.md`

## Architecture Decision Records

Accepted Milestone 0 decisions include:

- direct procfs parsing rather than command-output parsing;
- reusable library and thin CLI separation;
- Linux-only scope with a documented WSL2 boundary;
- structured partial results and diagnostics;
- sensitive-data minimization;
- optional Project 2 ELF integration.

See `docs/adr/README.md` for the full index.

## Project relationship

ProcLens is Project 3 in a larger compiler, runtime, and systems engineering
portfolio.

Project relationships include:

- Project 1 allocator workloads may provide controlled memory experiments;
- Project 2 ELF analysis may later enrich runtime mapping inspection through an
  optional adapter.

Neither Project 1 nor Project 2 is a mandatory ProcLens dependency.

## Development policy

Substantive procfs implementation begins only after the Milestone 0 foundation
passes:

- Clang and GCC builds;
- Debug and Release configurations;
- warnings as errors;
- formatting validation;
- clang-tidy;
- Cppcheck;
- sanitizer validation;
- CTest;
- GitHub Actions;
- fresh-clone reproduction.

## License

ProcLens is licensed under the MIT License.

See `LICENSE`.
