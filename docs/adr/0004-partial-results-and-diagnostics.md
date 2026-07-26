# ADR-0004: Partial results and diagnostic direction

- Status: Accepted
- Date: 2026-07-26
- Decision owners: Project engineer and lead execution engineer

## Context

Linux process inspection is inherently non-atomic.

A process may:

- exit between two procfs reads;
- change state during observation;
- deny access to some interfaces;
- expose optional fields on one kernel but not another;
- provide malformed or truncated content because of races;
- allow metadata access while denying mappings or descriptors.

ProcLens therefore cannot assume that every requested process section will
always be available simultaneously.

A decision is required about whether ProcLens should:

1. fail the entire inspection when any requested field fails;
2. silently omit unavailable information;
3. preserve usable data while attaching structured diagnostics.

The architecture must also distinguish unavailable information from legitimate
numeric zero and empty collections.

## Decision drivers

- Procfs observations are live and racy.
- Process disappearance is expected behavior.
- Permission restrictions may affect only some interfaces.
- Successfully collected data should not be discarded unnecessarily.
- Users must understand which sections are incomplete.
- Unavailable values must remain distinct from zero.
- Errors must be testable without terminal parsing.
- CLI exit behavior should reflect overall command outcome.
- JSON and text output must preserve the same semantic distinctions.
- Strict workflows may still require all requested sections.

## Options considered

### Option 1 — Fail the entire inspection on the first error

ProcLens could stop immediately when one file, field, directory, or symbolic
link cannot be read.

Advantages:

- simple control flow;
- one clear success-or-failure result;
- fewer partial-state models;
- strict callers receive immediate failure.

Disadvantages:

- useful information is discarded;
- normal process races appear catastrophic;
- one denied section prevents all other inspection;
- live monitoring becomes fragile;
- errors reveal little about what was collected successfully;
- behavior would not reflect the nature of procfs;
- users may be encouraged to run with unnecessary privileges.

### Option 2 — Silently omit failed or unavailable sections

ProcLens could retain successful information but leave out fields that could
not be collected.

Advantages:

- output remains compact;
- users see available information;
- implementation may appear simpler than explicit diagnostics.

Disadvantages:

- omission is ambiguous;
- unavailable values may look like zero or empty values;
- permission denial is hidden;
- process disappearance may go unnoticed;
- JSON consumers cannot distinguish unsupported, denied, and absent data;
- debugging becomes difficult;
- silent data loss undermines trust.

### Option 3 — Preserve partial results with structured diagnostics

ProcLens can retain successfully collected information while recording errors,
warnings, unavailable sections, and observation status.

Advantages:

- useful data survives localized failures;
- permission and lifecycle races remain visible;
- unavailable values remain distinct from zero;
- callers can choose tolerant or strict behavior;
- text and JSON output can preserve the same semantics;
- tests can verify exact diagnostic categories;
- live monitoring remains resilient;
- users are less likely to misinterpret missing information.

Disadvantages:

- the domain model becomes more complex;
- aggregation rules must account for incomplete samples;
- output may require warnings and status summaries;
- callers must decide how to handle partial results;
- exit-code design requires careful policy;
- serialization must represent unavailable fields explicitly.

## Decision

ProcLens will preserve usable partial results and attach structured diagnostics.

The conceptual observation result is:

```text
collected data
+
section availability
+
diagnostics
+
overall observation status
```

A process snapshot may therefore be:

- complete;
- partial;
- unavailable;
- invalid.

Individual sections may be:

- available;
- permission denied;
- process disappeared;
- interface unavailable;
- malformed;
- unsupported on the observed kernel;
- failed because of another I/O error.

A legitimate zero value must remain distinguishable from an unavailable value.

For example:

```text
swap_bytes = 0
```

means the value was observed successfully and is zero.

```text
swap_bytes = unavailable
```

means ProcLens could not obtain the value.

Strict mode may convert selected partial outcomes into command failure, but the
underlying library result must still preserve any data collected before the
failure.

## Rationale

Partial results best reflect the behavior of live Linux process interfaces.

ProcLens observes changing processes rather than reading immutable files.
Between two reads, a process may terminate, create threads, close descriptors,
change mappings, or cross a permission boundary.

Treating every localized failure as total failure would make the tool fragile
and would hide valid observations.

Silently dropping unavailable information would be worse because users and
automation could incorrectly interpret missing data as:

- zero;
- empty;
- unsupported;
- successfully checked and absent.

Structured diagnostics provide a precise model that supports:

- human-readable warnings;
- machine-readable JSON;
- tolerant interactive inspection;
- strict automated workflows;
- regression testing;
- future snapshot comparison.

## Consequences

### Positive consequences

- Successfully collected data is preserved.
- Process disappearance does not automatically destroy the observation.
- Permission failures remain visible.
- Zero, empty, denied, and unavailable remain distinct.
- JSON consumers can reason about completeness.
- Tests can validate exact error categories.
- Strict and tolerant command modes can share one library model.
- Live monitoring becomes more resilient.

### Negative consequences

- Result types require more design.
- Every section must define availability semantics.
- Formatters must display partial status clearly.
- Snapshot comparison must account for missing sections.
- Aggregation may need to reject or annotate incomplete samples.
- Exit-code policy becomes more nuanced.

### Neutral or operational consequences

- The library must not print diagnostics directly.
- Diagnostic rendering belongs to presentation layers.
- Errors should carry concise context without unnecessary sensitive data.
- Multiple diagnostics may exist for one observation.
- Diagnostics should remain stable enough for testing but not expose internal
  implementation unnecessarily.
- Strict mode behavior will be decided at the CLI-policy stage.
- Exact public error types remain deferred until Milestone 1.

## Rejected alternatives

Fail-fast inspection was rejected because it would discard useful information
and make expected procfs races appear as application-wide failures.

Silent omission was rejected because it would make denied, unavailable, empty,
and zero states ambiguous.

The selected approach preserves both utility and honesty.

## Review triggers

Review this ADR when:

- the public diagnostic type is frozen;
- strict mode is implemented;
- JSON snapshot schema is versioned;
- snapshot comparison rules are defined;
- sampling aggregation encounters incomplete observations;
- one diagnostic model becomes too costly or unclear;
- external consumers require stable machine-readable error codes;
- terminal output cannot communicate partial status effectively.

## Related documents

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/development/testing_strategy.md`
- `docs/security/privacy_and_permissions.md`
- `docs/security/risk_register.md`
- `docs/adr/0001-direct-procfs-parsing.md`
- `docs/adr/0002-library-and-cli-separation.md`
