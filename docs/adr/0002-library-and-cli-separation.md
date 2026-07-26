# ADR-0002: Reusable library and thin CLI separation

- Status: Accepted
- Date: 2026-07-26
- Decision owners: Project engineer and lead execution engineer

## Context

ProcLens will provide a command-line application for inspecting Linux
processes, threads, virtual memory, mappings, resource usage, file descriptors,
and snapshots.

The project also needs its process-inspection capabilities to remain reusable
outside one specific terminal interface.

A decision is required about whether:

1. all behavior should be implemented directly inside one CLI executable;
2. the project should use a reusable core library with a thin CLI;
3. the project should be split into many independently published libraries
   immediately.

The Milestone 0 architecture already defines these initial targets:

```text
proclens_core
proclens
proclens_smoke_tests
```

This ADR formalizes the responsibility and dependency boundaries among them.

## Decision drivers

- Core procfs behavior must be independently testable.
- Parser and domain logic must not depend on terminal presentation.
- Future tools should be able to reuse ProcLens capabilities.
- The CLI should remain easy to understand and review.
- Library tests should not require subprocess execution.
- Output formatting should not contaminate data collection.
- The initial architecture should remain simple enough for one repository.
- Public API growth must remain deliberate.
- Future Project 2 integration should occur behind a clean boundary.
- The build graph should express architectural ownership.

## Options considered

### Option 1 — Implement everything in one CLI executable

All procfs readers, parsers, models, analysis, formatting, and command handling
could be implemented directly inside the `proclens` executable.

Advantages:

- minimal initial target structure;
- fewer CMake targets;
- direct access among all implementation components;
- rapid prototypes may require less setup.

Disadvantages:

- parser logic becomes coupled to command handling;
- unit testing requires CLI-oriented code paths;
- future reuse becomes difficult;
- output concerns can leak into data models;
- command implementations may duplicate logic;
- architectural boundaries become informal;
- later refactoring into a library becomes expensive.

### Option 2 — Reusable core library with a thin CLI

The project can place core behavior in `proclens_core` and keep `proclens` as a
small coordination and presentation layer.

Advantages:

- parser and domain behavior can be tested directly;
- the CLI does not own procfs implementation;
- future tools can link against the library;
- dependencies remain directional;
- command handling remains understandable;
- alternative frontends remain possible;
- static analysis and sanitizer validation can target the core independently;
- Project 2 integration can be isolated behind an adapter.

Disadvantages:

- target and public-header design requires more care;
- incorrect public APIs can become expensive to change;
- some functionality must be clearly categorized as core or presentation;
- more CMake configuration is needed than for one executable;
- careless design could expose implementation details publicly.

### Option 3 — Create many independent libraries immediately

The project could begin with separate libraries for:

- procfs access;
- parsing;
- domain models;
- sampling;
- analysis;
- formatting;
- serialization.

Advantages:

- very explicit component boundaries;
- components could theoretically be reused independently;
- build dependencies would reveal fine-grained architecture.

Disadvantages:

- excessive complexity for Milestone 0;
- premature API freezing;
- increased build and packaging overhead;
- more difficult navigation;
- artificial boundaries may not match actual implementation needs;
- refactoring across many targets becomes cumbersome;
- the project risks appearing architecturally elaborate without measured need.

## Decision

ProcLens will use a reusable core library and a thin command-line application.

The initial dependency direction is:

```text
proclens
    ↓
proclens_core
```

The core library will own future:

- safe procfs access;
- procfs parsers;
- normalized domain models;
- unit-aware values;
- process identity;
- sampling and aggregation;
- analysis;
- snapshot data;
- serialization support where it is not CLI-specific.

The CLI will own future:

- argument parsing;
- command selection;
- terminal-oriented presentation;
- user-facing warnings;
- output destination selection;
- text versus JSON selection;
- process exit codes;
- orchestration of library operations.

The CLI must not directly parse procfs.

The core library must not depend on:

- CLI command types;
- terminal coloring;
- interactive terminal state;
- process exit codes;
- command-line parser libraries.

## Rationale

A reusable library with a thin CLI provides the strongest balance between
architectural discipline and practical project size.

ProcLens is intended to demonstrate systems-engineering capabilities, not only
command-line construction.

Separating the core allows the project to test and reason about:

- parser correctness;
- process races;
- partial results;
- units;
- snapshots;
- mapping classification;
- sampling calculations;

without involving terminal output or process-level command execution.

The thin CLI remains valuable because it gives users a direct operational
interface while preserving the option to build future:

- diagnostic tools;
- teaching examples;
- benchmarking programs;
- alternate frontends;
- integrations with other portfolio projects.

The project will avoid creating many independently published libraries until
measured architecture needs justify additional target boundaries.

## Consequences

### Positive consequences

- Core behavior is independently reusable.
- Unit tests can link directly against `proclens_core`.
- CLI command implementations remain small.
- Procfs parsing remains separated from presentation.
- Future frontends can reuse the same domain model.
- The build graph reflects the intended architecture.
- Project 2 integration can be optional and isolated.
- Sanitizer and static-analysis validation can target core code directly.

### Negative consequences

- Public versus private headers must be chosen carefully.
- The core API will require deliberate compatibility decisions.
- Some formatting or serialization ownership questions may require later ADRs.
- CMake target configuration becomes more involved.
- Developers must resist placing convenience logic in the CLI.

### Neutral or operational consequences

- `include/proclens/` contains public library headers.
- `src/` contains core implementation.
- `tools/proclens/` contains CLI implementation.
- Tests may link directly against `proclens_core`.
- Internal implementation headers should not be exposed without a clear reason.
- Additional libraries may be introduced later only when justified.
- The library and CLI may share version information through the core target.

## Rejected alternatives

A single monolithic CLI was rejected because it would couple process
inspection, parsing, analysis, and presentation and would weaken testability and
reuse.

Immediate decomposition into many libraries was rejected because the component
boundaries are not yet mature enough to justify multiple public targets.

The selected design preserves the ability to split the core later if measured
build, ownership, testing, or reuse needs demonstrate that additional target
boundaries are beneficial.

## Review triggers

Review this ADR when:

- CLI commands begin containing procfs parsing;
- the core library requires terminal-specific behavior;
- multiple applications need different subsets of core functionality;
- compile times or ownership boundaries justify additional libraries;
- serialization ownership becomes unclear;
- interactive terminal support is introduced;
- a public API must be stabilized for external consumers;
- Project 2 integration changes the dependency graph.

## Related documents

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/development/testing_strategy.md`
- `docs/adr/0001-direct-procfs-parsing.md`
