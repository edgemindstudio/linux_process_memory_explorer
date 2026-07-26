# ProcLens Project Charter

## Document status

- Project: Linux Process and Virtual Memory Explorer
- Product name: ProcLens
- Repository: `linux_process_memory_explorer`
- Language standard: C++20
- Primary platform: Linux
- Primary development environment: Kali Linux under WSL2
- Milestone: Milestone 0 — Discovery, Environment, and Project Charter
- Status: Draft foundation charter

## 1. Mission

ProcLens is a read-only Linux process-inspection library and command-line tool
for examining process metadata, threads, CPU accounting, virtual-memory state,
memory mappings, file descriptors, resource limits, I/O counters, and related
runtime information through Linux procfs and documented operating-system
interfaces.

The project exists to provide both:

1. a useful systems-observability tool; and
2. credible industrial exposure to Linux process and runtime engineering.

ProcLens will inspect operating-system state directly rather than wrapping
commands such as `ps`, `top`, `pmap`, or `lsof`.

## 2. Problem statement

Linux exposes extensive process and virtual-memory information through procfs,
but those interfaces are:

- distributed across many files;
- textual and parser-sensitive;
- kernel-version dependent;
- subject to permission restrictions;
- live and inherently race-prone;
- expressed using different units and accounting conventions;
- difficult to correlate into one normalized process model.

ProcLens will provide safe access, parsing, normalization, analysis, and
presentation while preserving uncertainty and partial failure.

## 3. Target users

ProcLens is intended for:

- C and C++ systems programmers;
- compiler and runtime engineers;
- Linux developers;
- performance engineers;
- observability engineers;
- HPC and research-computing developers;
- students studying processes and virtual memory;
- developers diagnosing controlled local workloads.

ProcLens version 1 is not intended to be a production fleet-monitoring system.

## 4. Career and engineering purpose

The project will demonstrate experience with:

- Linux procfs;
- kernel-to-user-space interfaces;
- C++20 library and CLI architecture;
- process and thread lifecycles;
- virtual address spaces;
- CPU and memory accounting;
- sampling and monotonic time;
- process-observation races;
- partial-result handling;
- permission and privacy boundaries;
- deterministic fixture-based testing;
- system-tool validation;
- strict compilation and static analysis;
- sanitizers and debugging;
- continuous integration;
- performance measurement;
- technical documentation and release engineering.

## 5. Relationship to earlier projects

### Project 1 — Memory Arena and Allocator Laboratory

Project 1 studies allocation mechanisms inside a program. ProcLens will later
show how allocator activity appears in a process address space through:

- heap growth;
- anonymous mappings;
- resident-memory changes;
- page faults;
- mapping creation and removal;
- process-level memory accounting.

No direct code dependency on Project 1 is required for version 1. Controlled
allocator workloads may later be used as ProcLens experiments or integration
fixtures.

### Project 2 — Binary Object and Executable Inspector

Project 2 studies ELF binaries before execution. ProcLens continues the
lifecycle from an ELF file to a running Linux process by examining:

- executable mappings;
- loadable-segment relationships;
- shared-library mappings;
- runtime relocation;
- address-space layout randomization;
- executable and writable permissions.

Project 2 integration will remain optional until its public API is stable and
the dependency provides clear value.

## 6. Product outputs

The project will ultimately produce:

1. `proclens_core` — a reusable C++ Linux process-inspection library;
2. `proclens` — a command-line diagnostic tool;
3. stable text and JSON output;
4. a versioned process-snapshot schema;
5. deterministic procfs fixtures;
6. unit, integration, regression, golden, and stress tests;
7. architecture, security, platform, and performance documentation.

Milestone 0 will produce only the foundation-level library, CLI, and smoke test.

## 7. Version 1 functional scope

Version 1 is expected to support:

- process enumeration;
- static process metadata;
- process hierarchy;
- thread inspection;
- interval-based CPU sampling;
- memory summaries;
- virtual-memory maps;
- mapping classification;
- optional ELF-to-memory correlation;
- file-descriptor inspection;
- resource-limit inspection;
- process I/O statistics;
- page-fault and context-switch reporting;
- live watch modes;
- process snapshots;
- snapshot comparison;
- search and filtering;
- human-readable text and JSON output;
- educational explanations for major Linux process concepts.

Every capability must tolerate processes disappearing during observation.

## 8. Explicit non-goals

Version 1 will not provide:

- process termination;
- signal injection;
- process control;
- `ptrace`-based debugging;
- arbitrary process-memory reading;
- process-memory modification;
- code injection;
- privilege escalation;
- access-control bypass;
- kernel modules;
- eBPF instrumentation;
- container orchestration;
- remote fleet monitoring;
- automatic memory-leak diagnosis;
- complete scheduler analysis;
- cross-platform Windows or macOS process inspection;
- replacement of `top`, `htop`, `ps`, `perf`, or `strace`.

## 9. Architectural principles

ProcLens will follow these principles:

1. Parse procfs directly for core functionality.
2. Keep Linux access separate from parsing.
3. Keep parsing separate from presentation.
4. Preserve raw observations when normalization occurs.
5. Represent unavailable data separately from zero.
6. Treat process disappearance as a normal observation outcome.
7. Support partial snapshots with explicit diagnostics.
8. Avoid overclaiming inferred mapping classifications.
9. Preserve units and prevent arithmetic overflow.
10. Keep the reusable library independent of terminal presentation.
11. Make sensitive information opt-in where appropriate.
12. Never execute data obtained from an inspected process.
13. Prefer deterministic fixtures for parser tests.
14. Validate representative output against standard Linux tools.

## 10. Safety and privacy policy

ProcLens must respect Linux permissions and security boundaries.

The tool must:

- operate without root for normal use;
- report permission denial clearly;
- never attempt privilege bypass;
- avoid reading complete process environments by default;
- treat command lines, paths, and descriptors as potentially sensitive;
- avoid committing live captures or generated snapshots accidentally;
- safely handle symbolic-link targets and unusual filenames;
- never execute commands derived from inspected data;
- never read arbitrary process memory;
- document when information is missing because of platform restrictions.

## 11. Platform scope

The required operating system is modern Linux.

The primary development environment is:

- Kali GNU/Linux Rolling 2026.1;
- WSL2;
- kernel `6.6.87.2-microsoft-standard-WSL2`;
- x86-64;
- 4 KiB base pages;
- `CLK_TCK` value of 100 in the audited environment.

The project will document differences among:

- native Linux;
- WSL2;
- containers;
- restricted or namespace-isolated environments.

ProcLens will not claim universal compatibility with every kernel,
distribution, procfs configuration, or security policy.

## 12. Quality requirements

The repository must:

- use C++20;
- build with Clang and GCC;
- use CMake and Ninja;
- apply strict compiler warnings;
- support warnings as errors;
- use clang-format;
- use clang-tidy and Cppcheck;
- support AddressSanitizer and UndefinedBehaviorSanitizer;
- use ThreadSanitizer where concurrency later justifies it;
- register tests through CTest;
- run validation through GitHub Actions;
- maintain deterministic fixtures;
- document known limitations;
- support clean-clone reproducibility.

## 13. Testing strategy summary

Testing will use multiple layers:

- unit tests for parsing, arithmetic, models, and classification;
- fixture tests for deterministic procfs content;
- controlled child-process integration tests;
- regression tests for every confirmed defect;
- golden tests for stable text and JSON output;
- stress tests for process churn and repeated observation;
- sanitizer and static-analysis validation;
- comparison with standard Linux tools.

Live procfs tests will supplement, not replace, deterministic fixtures.

## 14. Milestone 0 scope

Milestone 0 is limited to:

- environment discovery;
- procfs capability inspection;
- repository architecture;
- governance documents;
- architecture documentation;
- platform and security boundaries;
- initial ADRs;
- formatting and analysis configuration;
- reusable CMake modules;
- CMake presets;
- a zero-feature reusable library;
- a zero-feature CLI;
- one smoke test;
- initial CI;
- fresh-clone verification.

No substantive procfs parser will be implemented during Milestone 0.

## 15. Milestone 0 completion gate

Milestone 0 is complete only when:

- the project charter exists;
- architecture and platform boundaries are documented;
- the risk register exists;
- foundational ADRs are recorded;
- Clang Debug and Release builds pass;
- GCC Debug and Release builds pass;
- sanitizer validation passes;
- static analysis passes;
- the zero-feature CLI runs;
- the smoke test passes through CTest;
- GitHub Actions passes;
- all changes are committed and pushed;
- a fresh clone configures, builds, and tests successfully;
- the working tree is clean.

## 16. Success criteria for version 1

ProcLens version 1 will be successful when it provides a professional,
read-only, reusable, well-tested process-inspection system whose behavior,
limitations, security boundaries, accounting conventions, and architecture can
be clearly explained and independently reproduced.

## 17. Change control

Material changes to project scope, security boundaries, supported platforms,
public architecture, snapshot compatibility, or Project 2 integration must be
recorded through an Architecture Decision Record.

The roadmap may evolve, but version 1 non-goals must not be weakened without an
explicit reviewed decision.
