# ADR-0001: Direct procfs parsing versus external commands

- Status: Accepted
- Date: 2026-07-26
- Decision owners: Project engineer and lead execution engineer

## Context

ProcLens is intended to inspect Linux processes, threads, virtual memory,
resource accounting, file descriptors, and related runtime information.

Much of this information is exposed through Linux procfs interfaces such as:

- `/proc/<pid>/stat`;
- `/proc/<pid>/status`;
- `/proc/<pid>/maps`;
- `/proc/<pid>/smaps`;
- `/proc/<pid>/limits`;
- `/proc/<pid>/io`;
- `/proc/<pid>/task`;
- `/proc/<pid>/fd`;
- `/proc/stat`.

Existing Linux commands such as `ps`, `top`, `pmap`, `lsof`, and `pidstat`
already present some of this information.

A decision is required about whether ProcLens should obtain its core data by:

1. invoking and parsing external command output;
2. using a high-level process-inspection library;
3. reading Linux procfs and documented system interfaces directly.

## Decision drivers

- The project must provide genuine exposure to Linux process interfaces.
- Core behavior must not depend on external command formatting.
- ProcLens should remain usable on systems where optional utilities are absent.
- Parser behavior must be deterministic and fixture-testable.
- Permission and process-disappearance errors must be represented precisely.
- The reusable library must not require shell execution.
- Inspected process data must not be interpolated into commands.
- Standard Linux tools should remain available as validation references.
- Platform limitations must remain visible rather than hidden by wrappers.

## Options considered

### Option 1 — Invoke standard Linux commands

ProcLens could execute tools such as:

```text
ps
pmap
lsof
pidstat
```

and parse their textual output.

Advantages:

- rapid initial implementation;
- mature tools already handle many kernel details;
- output can be compared easily with familiar utilities;
- less initial parser code.

Disadvantages:

- output formats may vary by tool version, distribution, locale, and options;
- required commands may not be installed;
- subprocess creation increases overhead;
- parsing command output introduces another compatibility layer;
- precise permission and race outcomes may be hidden;
- shell construction creates avoidable safety risks;
- the project would provide less exposure to procfs and kernel interfaces;
- reusable library behavior would depend on external executables.

### Option 2 — Use a high-level process-inspection library

ProcLens could depend on an existing library that abstracts Linux process
information.

Advantages:

- reduced implementation effort;
- potentially broader platform compatibility;
- existing abstractions may already handle common interfaces;
- fewer parsers to maintain.

Disadvantages:

- core learning objectives would be hidden;
- library abstractions may collapse unavailable, denied, and zero values;
- dependency behavior may be difficult to inspect;
- platform differences may be concealed;
- public architecture would inherit another library's model;
- the project would provide weaker evidence of direct Linux systems work.

### Option 3 — Parse procfs and documented Linux interfaces directly

ProcLens can implement its own bounded readers, parsers, domain models, and
diagnostics.

Advantages:

- direct understanding of Linux process interfaces;
- precise control over parsing and error categories;
- deterministic fixture-based testing;
- no dependency on command output formats;
- no shell execution for core functionality;
- explicit handling of process disappearance and partial results;
- clear preservation of units and raw observations;
- reusable library remains self-contained;
- stronger compiler, runtime, and systems-engineering relevance.

Disadvantages:

- substantially more implementation work;
- kernel variations must be researched and documented;
- parsers require careful testing;
- malformed and unusual input must be handled safely;
- compatibility claims must remain conservative;
- maintenance responsibility belongs to ProcLens.

## Decision

ProcLens will parse Linux procfs and documented Linux system interfaces
directly for its core functionality.

The implementation will use:

```text
Linux procfs
    ↓
safe access layer
    ↓
interface-specific parsers
    ↓
normalized domain models
    ↓
analysis and presentation
```

ProcLens will not use external commands or high-level process-inspection
libraries as the source of truth for its core process data.

## Rationale

Direct procfs parsing best satisfies the project mission.

The primary purpose of ProcLens is not merely to display process information.
It is also to demonstrate professional understanding of:

- Linux kernel-to-user-space interfaces;
- process-observation races;
- parser design;
- unit conversion;
- partial failure;
- process identity;
- virtual-memory accounting;
- permission boundaries;
- deterministic systems testing.

Invoking existing commands would delegate many of these responsibilities to
other programs and weaken the engineering value of the project.

A direct implementation also allows ProcLens to preserve distinctions that
external command output may hide, including:

- permission denied;
- interface unavailable;
- process exited during observation;
- field absent on this kernel;
- malformed content;
- legitimate zero;
- partial snapshot.

## Consequences

### Positive consequences

- ProcLens gains direct control over Linux interface parsing.
- The library does not depend on optional system utilities.
- Core functionality avoids shell execution.
- Parser tests can use committed deterministic fixtures.
- Error and partial-result behavior can remain explicit.
- Raw values and units can be preserved.
- The project provides credible Linux systems-engineering evidence.
- Reference tools can be used independently for comparison.

### Negative consequences

- More source code and tests are required.
- Kernel-version differences must be handled deliberately.
- Procfs syntax must be researched carefully.
- Parser defects become ProcLens’s responsibility.
- Development will take longer than a wrapper-based approach.
- Compatibility claims must remain narrow until validated.

### Neutral or operational consequences

- Each supported procfs interface should receive a dedicated parser or reader.
- Fixtures must be sanitized before entering the repository.
- Live validation remains necessary even when fixture tests pass.
- Documentation must identify source fields, units, and kernel assumptions.
- External commands may still appear in development scripts used for
  comparison, but not as the core implementation.

## Rejected alternatives

Invoking standard Linux utilities was rejected because it would make ProcLens
dependent on external command availability and presentation formats while
hiding important process-observation behavior.

Using a high-level process library was rejected for core functionality because
it would obscure the project’s principal Linux systems-learning objectives and
constrain ProcLens to another library's error and data model.

Neither rejected alternative is prohibited for validation experiments.
ProcLens may compare its results with standard utilities and may study other
libraries when evaluating design choices.

## Review triggers

Review this ADR when:

- Linux procfs no longer provides a required capability;
- a documented Linux system API is more suitable than a procfs text interface;
- an optional dependency provides a capability outside the project’s core
  learning objectives;
- portability beyond Linux becomes a formal requirement;
- maintenance cost of a parser becomes disproportionate;
- security analysis identifies a problem with the selected access method.

## Related documents

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/development/testing_strategy.md`
- `docs/platform/platform_support.md`
- `docs/security/privacy_and_permissions.md`
- `docs/security/risk_register.md`
