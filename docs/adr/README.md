# ProcLens Architecture Decision Records

## Purpose

Architecture Decision Records document significant technical, architectural,
security, compatibility, and operational decisions made during ProcLens
development.

An ADR records:

- the context that required a decision;
- the options considered;
- the selected decision;
- the rationale;
- the consequences;
- rejected alternatives where useful.

ADRs explain why the repository has its current architecture. They are not
general documentation and should not merely repeat implementation details.

## Status values

Each ADR uses one of these statuses:

- Proposed;
- Accepted;
- Superseded;
- Deprecated;
- Rejected.

An accepted ADR remains part of the architectural record even if a later ADR
supersedes it.

## Numbering policy

ADRs use sequential three-digit identifiers:

```text
0001-direct-procfs-parsing.md
0002-library-and-cli-separation.md
0003-linux-and-wsl-support-boundary.md
```

Numbers are never reused.

## Required structure

Each ADR must contain:

1. title;
2. status;
3. date;
4. decision owners;
5. context;
6. decision drivers;
7. options considered;
8. decision;
9. rationale;
10. consequences;
11. rejected alternatives;
12. review triggers;
13. related documents.

## Initial Milestone 0 ADRs

The initial foundation ADR set is:

| ADR | Decision | Status |
|---|---|---|
| 0001 | Direct procfs parsing versus external commands | Accepted |
| 0002 | Reusable library and thin CLI separation | Accepted |
| 0003 | Linux-only scope and WSL2 support boundary | Accepted |
| 0004 | Partial results and diagnostic direction | Accepted |
| 0005 | Sensitive process-information policy | Accepted |
| 0006 | Optional Project 2 ELF integration | Accepted |

Later milestones are expected to add ADRs for:

- process identity and PID reuse;
- CPU-utilization calculations;
- unit and memory representation;
- live-sampling architecture;
- mapping classification;
- JSON snapshot schema;
- terminal-interface selection;
- concurrency.

Those decisions should not be frozen prematurely during Milestone 0.

## Creating a new ADR

Copy the template:

```bash
cp docs/adr/template.md \
   docs/adr/NNNN-short-decision-name.md
```

Then replace all placeholders.

An ADR should be committed together with, or before, the implementation that
depends on it.

## Superseding an ADR

When a decision changes:

1. create a new ADR;
2. mark the old ADR as `Superseded`;
3. link the old and new records;
4. explain why the previous decision no longer fits;
5. preserve both records in Git history and the repository.

Do not rewrite accepted historical decisions to make them appear as though the
new decision was always intended.

## Review policy

ADRs must be reviewed when:

- public architecture changes;
- security boundaries change;
- supported platforms change;
- serialization compatibility changes;
- a new external dependency is introduced;
- concurrency is introduced;
- implementation contradicts an accepted ADR;
- a milestone gate requires a previously deferred decision.

## Index

| ADR | Title | Status |
|---|---|---|
| 0001 | Direct procfs parsing versus external commands | Accepted |
| 0002 | Reusable library and thin CLI separation | Accepted |
| 0003 | Linux-only scope and WSL2 support boundary | Accepted |
| 0004 | Partial results and diagnostic direction | Accepted |
| 0005 | Sensitive process-information policy | Accepted |
| 0006 | Optional Project 2 ELF integration | Accepted |
