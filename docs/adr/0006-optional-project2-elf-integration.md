# ADR-0006: Optional Project 2 ELF integration

- Status: Accepted
- Date: 2026-07-26
- Decision owners: Project engineer and lead execution engineer

## Context

ProcLens will inspect runtime process mappings and executable paths.

Project 2 in the portfolio provides binary-object and ELF inspection
capabilities.

A future integration could correlate:

```text
runtime executable or mapped-file path
+
ELF loadable-segment metadata
+
runtime virtual-memory mappings
```

This could help explain:

- how ELF loadable segments correspond to runtime mappings;
- why mappings have particular permissions;
- where executable and writable regions originate;
- how file offsets relate to mapped addresses;
- how the loader transforms ELF metadata into a running process image.

A decision is required about whether ProcLens should:

1. depend directly on Project 2 from the beginning;
2. duplicate ELF parsing inside ProcLens;
3. keep ELF correlation optional through a clean adapter boundary;
4. exclude all Project 2 integration permanently.

## Decision drivers

- ProcLens must remain independently buildable.
- Project 2 may not yet expose a stable public API.
- ELF parsing is not a core Milestone 0 requirement.
- Runtime mappings and ELF metadata represent related but distinct concepts.
- Duplicate ELF parsers should be avoided.
- Portfolio projects should demonstrate clean integration boundaries.
- Optional capabilities must not complicate ordinary ProcLens use.
- Dependency direction must remain understandable.
- Project 2 changes must not silently break ProcLens.
- Integration should provide clear diagnostic value before being introduced.

## Options considered

### Option 1 — Make Project 2 a mandatory dependency

ProcLens could require Project 2 for every build and use its ELF inspection
logic directly.

Advantages:

- immediate reuse of existing ELF work;
- no duplicate parsing;
- runtime and binary inspection become closely connected;
- one consistent ELF interpretation may be shared.

Disadvantages:

- ProcLens cannot build independently;
- Project 2 API instability could block ProcLens;
- installation and CI become more complex;
- ordinary process inspection would depend on unrelated ELF functionality;
- portfolio projects could develop circular or tightly coupled dependencies;
- Project 2 defects could affect unrelated ProcLens commands.

### Option 2 — Duplicate ELF parsing inside ProcLens

ProcLens could implement its own ELF reader specifically for mapping
correlation.

Advantages:

- no external project dependency;
- implementation can be tailored to ProcLens;
- all behavior remains inside one repository.

Disadvantages:

- duplicates Project 2 functionality;
- increases maintenance burden;
- creates risk of inconsistent ELF interpretation;
- weakens portfolio reuse;
- expands ProcLens beyond its core process-inspection scope;
- requires additional parser testing and security review.

### Option 3 — Optional adapter to a stable Project 2 interface

ProcLens can define an optional integration boundary and enable it only when a
stable Project 2 API is available.

Advantages:

- ProcLens remains independently buildable;
- ELF functionality is reused rather than duplicated;
- integration can be enabled only when useful;
- dependency direction remains explicit;
- ordinary ProcLens commands remain unaffected;
- Project 2 and ProcLens can evolve independently;
- portfolio integration demonstrates modular architecture.

Disadvantages:

- adapter code and optional build configuration are required;
- two build modes must be tested;
- API compatibility must be managed;
- users may receive different capabilities depending on configuration;
- integration documentation must remain clear.

### Option 4 — Permanently exclude Project 2 integration

ProcLens could treat runtime mappings and ELF metadata as entirely separate.

Advantages:

- simplest dependency model;
- no cross-project compatibility work;
- ProcLens scope remains narrow;
- fewer CI configurations.

Disadvantages:

- loses a valuable runtime-to-binary correlation feature;
- reduces portfolio integration opportunities;
- users must manually compare tools;
- ELF knowledge cannot enrich mapping analysis.

## Decision

Project 2 ELF integration will be optional.

ProcLens will remain fully buildable and usable without Project 2.

The future dependency model may be:

```text
proclens
    ↓
proclens_core
    ↓
optional ELF adapter
    ↓
stable Project 2 public API
```

The adapter may provide ELF metadata to ProcLens domain or analysis layers, but
Project 2 types must not spread through the ordinary public ProcLens API unless
a later ADR explicitly approves that design.

The integration must remain disabled unless:

- Project 2 exposes a stable public API;
- its licensing is compatible;
- dependency management is reproducible;
- standalone ProcLens builds remain available;
- integration tests cover enabled and disabled builds;
- the capability provides clear diagnostic value.

Milestone 0 introduces no Project 2 dependency.

## Rationale

Optional integration provides the strongest balance between reuse and
independence.

Runtime process mappings and ELF program headers are closely related, but they
are not identical.

ProcLens must avoid incorrect assumptions such as:

```text
ELF section
=
runtime mapping
```

The Linux loader primarily uses ELF program headers and loadable segments when
constructing runtime mappings. Sections serve different binary-analysis
purposes and may not correspond directly to memory mappings.

A dedicated adapter can translate stable Project 2 results into the narrower
information ProcLens needs without coupling every process-inspection feature to
the binary-inspection project.

This approach also preserves the educational value of showing how separate
systems tools can cooperate through deliberate interfaces.

## Consequences

### Positive consequences

- ProcLens remains independently buildable.
- Project 2 ELF logic can be reused later.
- Duplicate ELF parsing is avoided.
- Ordinary ProcLens commands remain lightweight.
- Enabled and disabled integration modes are explicit.
- Dependency direction remains controlled.
- Runtime-to-binary correlation can become a strong portfolio demonstration.
- Project 2 types can remain isolated behind an adapter.

### Negative consequences

- Optional build configuration adds complexity.
- Two dependency modes require CI coverage.
- Project 2 API changes may require adapter updates.
- Some users may not have ELF-correlation capabilities.
- Integration cannot begin until Project 2 has a stable interface.
- Packaging and version compatibility require documentation.

### Neutral or operational consequences

- ProcLens must provide a standalone default build.
- The adapter should live behind a dedicated target or source boundary.
- CMake must report integration state clearly.
- Runtime mapping analysis must work without ELF metadata.
- ELF correlation must preserve uncertainty.
- Project 2 should not depend back on ProcLens.
- Future integration requires a dedicated ADR review before implementation.

## Rejected alternatives

Mandatory Project 2 dependency was rejected because it would make ordinary
ProcLens functionality dependent on another portfolio project and would weaken
standalone build guarantees.

Duplicating ELF parsing was rejected because it would waste effort and create
inconsistent binary interpretations.

Permanent exclusion was rejected because optional ELF correlation could provide
meaningful diagnostic and educational value once Project 2 exposes a stable
interface.

## Review triggers

Review this ADR when:

- Project 2 exposes a stable reusable library;
- the Project 2 public API changes;
- ELF correlation becomes a milestone requirement;
- dependency-management tooling is selected;
- package or license compatibility changes;
- ProcLens public APIs begin exposing Project 2 types;
- standalone builds become difficult to preserve;
- runtime mapping analysis requires ELF data for correctness rather than
  optional enrichment.

## Related documents

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/platform/platform_support.md`
- `docs/development/testing_strategy.md`
- `docs/adr/0001-direct-procfs-parsing.md`
- `docs/adr/0002-library-and-cli-separation.md`
