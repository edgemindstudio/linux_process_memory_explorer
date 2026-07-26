# ProcLens Roadmap

## Document status

- Project: ProcLens
- Repository: `linux_process_memory_explorer`
- Product direction: Linux process and virtual-memory exploration
- Current milestone: Milestone 0
- Roadmap status: Initial engineering plan

## 1. Purpose

This roadmap defines the planned development sequence for ProcLens.

The roadmap is organized around engineering capabilities rather than calendar
deadlines.

A milestone is complete only when its implementation, tests, documentation,
analysis, and validation criteria have been satisfied.

Future milestone contents may change through architecture review and
Architecture Decision Records.

## 2. Roadmap principles

ProcLens development follows these rules:

1. Establish the engineering foundation before implementing procfs features.
2. Build deterministic parser tests before relying on live-system tests.
3. Introduce process identity before calculating values across time.
4. Preserve units and partial results from the beginning.
5. Keep the reusable library separate from the CLI.
6. Add one coherent capability area at a time.
7. Validate against raw procfs and established Linux tools.
8. Add regression tests for every confirmed defect.
9. Introduce concurrency only after measured need.
10. Make performance claims only after reproducible measurement.
11. Review privacy before adding sensitive data sources.
12. Preserve standalone ProcLens builds.

## 3. Milestone overview

| Milestone | Name | Primary outcome |
|---|---|---|
| 0 | Discovery and Engineering Foundation | Reproducible professional project foundation |
| 1 | Procfs Access and Core Domain Types | Safe access layer and foundational types |
| 2 | Process Discovery and Metadata | Enumerate and inspect process identity and metadata |
| 3 | Process Trees and Thread Inspection | Parent-child and task relationships |
| 4 | CPU Accounting and Sampling | Correct repeated-sample CPU analysis |
| 5 | Memory Summary and Page-Fault Accounting | Process-level memory and fault metrics |
| 6 | Virtual-Memory Mapping Inspection | Parse and classify runtime mappings |
| 7 | File Descriptors, Limits, and I/O | Inspect descriptors, limits, and counters |
| 8 | Snapshots and Comparison | Stable capture, serialization, and diffing |
| 9 | Terminal Monitoring Interface | Interactive and repeated observation |
| 10 | Performance, Stress, and Hardening | Measure overhead and strengthen resilience |
| 11 | Version 1 Release Readiness | Documentation, packaging, and release evidence |

## 4. Milestone 0 — Discovery and Engineering Foundation

### Goal

Create a clean, reproducible, professional C++ project foundation without
implementing substantive process inspection.

### Scope

- environment discovery;
- procfs interface survey;
- project charter;
- architecture;
- risk register;
- platform policy;
- privacy and permissions policy;
- testing strategy;
- Architecture Decision Records;
- repository layout;
- CMake target structure;
- compiler-warning policies;
- sanitizers;
- static analysis;
- formatting;
- zero-feature library;
- zero-feature CLI;
- smoke test;
- CTest;
- GitHub Actions;
- fresh-clone verification.

### Completion criteria

- Clang Debug and Release builds pass;
- GCC Debug and Release builds pass;
- warnings-as-errors builds pass;
- formatting validation passes;
- clang-tidy passes;
- Cppcheck passes;
- sanitizer validation passes;
- CTest discovers and runs the smoke test;
- CI passes from a clean checkout;
- documentation reflects the actual repository;
- working tree is clean after the final commit;
- no substantive procfs parser exists.

## 5. Milestone 1 — Procfs Access and Core Domain Types

### Goal

Create the safe foundational layer required by all later procfs features.

### Planned scope

- validated process identifier type;
- procfs root abstraction;
- safe path construction;
- bounded text-file reading;
- bounded binary-like procfs reading where required;
- symbolic-link reading;
- operating-system error capture;
- foundational result and diagnostic types;
- unavailable-value representation;
- explicit unit types;
- checked arithmetic;
- page-size and clock-tick discovery;
- fixture-backed access;
- initial malformed and boundary fixtures.

### Key decisions

This milestone must resolve:

- public error model;
- process-ID representation;
- partial-result representation;
- internal versus public unit types;
- maximum read policies;
- procfs root injection for tests.

### Completion criteria

- access behavior is testable without live `/proc`;
- invalid paths and identifiers are rejected;
- short reads and disappearing files are handled;
- permission errors are preserved;
- integer conversions are checked;
- public headers remain minimal;
- no CLI command contains procfs access logic.

## 6. Milestone 2 — Process Discovery and Metadata

### Goal

Enumerate Linux processes and build trustworthy process metadata observations.

### Planned scope

- process-directory enumeration;
- `/proc/<pid>/stat` parsing;
- `/proc/<pid>/status` parsing;
- `/proc/<pid>/comm`;
- `/proc/<pid>/cmdline`;
- executable and current-working-directory links;
- user and group identifiers;
- process state;
- parent process identifier;
- process start time;
- PID reuse detection foundation;
- metadata text and JSON presentation;
- `list` and `inspect` command foundations.

### Testing emphasis

- process names containing spaces or parentheses;
- disappearing processes;
- malformed stat input;
- optional status fields;
- empty command lines;
- permission-denied links;
- kernel variation fixtures.

### Completion criteria

- controlled child processes can be enumerated and inspected;
- PID plus start time forms the observation identity;
- unavailable fields are not represented as zero;
- output clearly identifies partial observations;
- list and inspect commands remain thin.

## 7. Milestone 3 — Process Trees and Thread Inspection

### Goal

Model process relationships and inspect Linux tasks.

### Planned scope

- parent-child process relationships;
- process-tree construction;
- missing-parent handling;
- orphaned and reparented-process behavior;
- `/proc/<pid>/task` enumeration;
- thread metadata;
- thread state;
- thread names;
- thread lifecycle races;
- tree and thread output.

### Testing emphasis

- controlled process hierarchies;
- parent exit before child;
- threads created and destroyed during inspection;
- malformed or incomplete task metadata;
- process disappearance during tree construction.

### Completion criteria

- process trees tolerate missing and changing nodes;
- thread enumeration tolerates task disappearance;
- cycles or invalid relationships cannot crash rendering;
- output distinguishes process IDs from thread IDs clearly.

## 8. Milestone 4 — CPU Accounting and Sampling

### Goal

Provide correct, documented CPU accounting based on repeated observations.

### Planned scope

- process CPU counters;
- thread CPU counters;
- system CPU counters;
- clock-tick conversion;
- monotonic sample timing;
- process-identity verification across samples;
- user and system CPU time;
- CPU percentage;
- multicore display convention;
- configurable sample intervals;
- controlled CPU workloads.

### Required ADRs

- CPU-utilization formula;
- multicore percentage convention;
- sampling timestamp policy;
- behavior when identity changes;
- incomplete sample policy.

### Validation

Results will be compared with:

- raw `/proc` counters;
- `ps`;
- `top`;
- `pidstat`.

Differences must be explained in terms of sampling windows, rounding, units, or
accounting formulas.

## 9. Milestone 5 — Memory Summary and Page-Fault Accounting

### Goal

Explain process-level memory accounting without conflating distinct metrics.

### Planned scope

- virtual memory;
- resident memory;
- shared estimates;
- proportional set size where available;
- unique set size where derivable;
- anonymous and file-backed memory summaries;
- swap;
- minor and major page faults;
- memory growth observations;
- Project 1 controlled allocator workloads.

### Engineering rules

ProcLens must distinguish:

- reserved virtual address space;
- committed or mapped memory;
- resident physical pages;
- allocator-requested bytes;
- shared pages;
- proportional accounting;
- unavailable values.

### Completion criteria

- every displayed memory value includes an explicit unit;
- source interfaces are documented;
- controlled workloads demonstrate expected directional changes;
- results are compared with raw procfs and `pmap`;
- unavailable metrics remain explicit.

## 10. Milestone 6 — Virtual-Memory Mapping Inspection

### Goal

Parse, represent, classify, and explain process virtual-memory mappings.

### Planned scope

- `/proc/<pid>/maps`;
- `/proc/<pid>/smaps`;
- `/proc/<pid>/smaps_rollup`;
- address ranges;
- mapping permissions;
- private and shared mappings;
- offsets;
- device and inode fields;
- anonymous mappings;
- special mappings;
- deleted mapped files;
- classification confidence;
- mapping summaries;
- optional Project 2 ELF correlation review.

### Required safeguards

- address arithmetic must be checked;
- malformed ranges must be rejected;
- paths remain untrusted text;
- classification must preserve uncertainty;
- ELF sections must not be confused with runtime mappings.

### Completion criteria

- deterministic mapping fixtures pass;
- controlled file-backed and anonymous mappings are recognized;
- deleted mappings are preserved correctly;
- classification rules are documented;
- raw mapping fields remain available.

## 11. Milestone 7 — File Descriptors, Limits, and I/O

### Goal

Inspect operational resources associated with a process.

### Planned scope

- file-descriptor enumeration;
- descriptor symbolic links;
- descriptor metadata;
- regular files;
- pipes;
- sockets;
- anonymous kernel objects;
- deleted files;
- `/proc/<pid>/limits`;
- `/proc/<pid>/io`;
- context switches;
- controlled file and pipe workloads;
- permission-aware partial results.

### Privacy review

This milestone requires explicit review because descriptors and paths may expose
private information.

### Completion criteria

- descriptor targets are never executed or opened unnecessarily;
- disappearing descriptors are handled;
- limits retain soft, hard, and unlimited semantics;
- I/O counters retain source units;
- permission denial does not invalidate unrelated metadata.

## 12. Milestone 8 — Snapshots and Comparison

### Goal

Capture stable, versioned process observations and compare them meaningfully.

### Planned scope

- snapshot domain model;
- JSON serialization;
- schema versioning;
- explicit units;
- partial-result serialization;
- snapshot metadata;
- deterministic field ordering;
- snapshot comparison;
- identity validation;
- changed, added, removed, and unavailable fields;
- sanitized example snapshots.

### Required ADRs

- JSON schema versioning;
- compatibility policy;
- timestamp policy;
- snapshot completeness;
- sensitive-field defaults;
- comparison semantics.

### Completion criteria

- snapshots validate against the schema;
- old compatibility fixtures remain readable according to policy;
- unavailable and zero remain distinct;
- comparisons reject unrelated process identities unless explicitly overridden;
- generated snapshots remain ignored by default.

## 13. Milestone 9 — Terminal Monitoring Interface

### Goal

Provide repeated observation and a usable terminal-oriented experience.

### Planned scope

- watch mode;
- configurable refresh interval;
- stable screen updates;
- terminal-size handling;
- no-color mode;
- non-interactive fallback;
- sorting and filtering;
- bounded history;
- graceful interruption;
- terminal text escaping;
- observer-overhead measurement.

### Architecture review

A terminal library must not be selected before reviewing:

- portability;
- licensing;
- maintenance;
- testability;
- terminal capability handling;
- dependency size.

### Completion criteria

- inspected text cannot inject terminal control sequences;
- shutdown is deterministic;
- memory use remains bounded;
- refresh behavior does not overwhelm the inspected system;
- the core library remains independent of terminal state.

## 14. Milestone 10 — Performance, Stress, and Hardening

### Goal

Measure ProcLens overhead and strengthen behavior under demanding conditions.

### Planned scope

- repeated enumeration benchmarks;
- parser benchmarks;
- mapping-heavy processes;
- high process churn;
- high thread churn;
- long-running sampling;
- long-running watch mode;
- bounded allocation analysis;
- profiling;
- Valgrind workflows;
- sanitizer expansion;
- fuzzing where appropriate;
- observer-effect analysis.

### Performance policy

Performance claims must include:

- hardware and environment;
- kernel;
- compiler;
- build type;
- sample size;
- methodology;
- warm-up behavior;
- uncertainty or variability;
- WSL versus native-Linux context.

### Completion criteria

- no unbounded growth in long-running modes;
- race-heavy stress tests do not crash;
- representative parser throughput is measured;
- major bottlenecks are documented;
- optimizations include before-and-after evidence.

## 15. Milestone 11 — Version 1 Release Readiness

### Goal

Prepare a credible, reproducible Version 1 release.

### Planned scope

- complete user documentation;
- command reference;
- examples;
- installation instructions;
- platform-support statement;
- privacy warnings;
- schema documentation;
- release notes;
- packaging review;
- license verification;
- dependency review;
- clean-clone validation;
- release CI;
- version tagging.

### Release criteria

Version 1 may be tagged only when:

- all required milestone tests pass;
- known limitations are documented;
- supported platforms are evidence-based;
- no critical security or privacy risk remains unresolved;
- generated sensitive artifacts are absent from Git;
- public APIs and schemas have documented compatibility policies;
- clean-clone reproduction succeeds;
- release documentation matches actual behavior.

## 16. Deferred possibilities

The following ideas are intentionally deferred and are not Version 1
commitments:

- remote process inspection;
- daemon or agent mode;
- native Windows inspection;
- native macOS inspection;
- graphical user interface;
- process signaling;
- debugger functionality;
- arbitrary process-memory reading;
- code injection;
- automatic privilege escalation;
- kernel modules;
- eBPF-based tracing;
- distributed monitoring;
- permanent background data collection.

Any future consideration requires explicit scope, security, privacy, and
architecture review.

## 17. Roadmap change policy

The roadmap may change when:

- implementation evidence invalidates an assumption;
- a risk becomes more significant;
- Linux interface research changes the design;
- milestone dependencies become clearer;
- testing reveals missing foundation work;
- scope must be reduced to protect quality;
- an ADR changes an architectural decision.

Roadmap changes must preserve:

- the project charter;
- read-only scope;
- Linux focus;
- deterministic testing;
- partial-result honesty;
- privacy defaults;
- library and CLI separation.

## 18. Current authorization

The project is currently authorized to complete Milestone 0 only.

Substantive procfs implementation must not begin until Milestone 0 has passed
its complete local, CI, and fresh-clone validation gate.
