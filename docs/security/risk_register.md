# ProcLens Risk Register

## Document status

- Project: ProcLens
- Repository: `linux_process_memory_explorer`
- Milestone: Milestone 0
- Status: Initial risk assessment
- Review frequency: At every milestone boundary and before release

## 1. Purpose

This register identifies technical, security, privacy, correctness, platform,
testing, and delivery risks associated with ProcLens.

A risk describes something that may occur. It is not proof that a defect
currently exists.

Each risk includes:

- likelihood;
- impact;
- mitigation;
- verification method;
- review trigger.

Risk ratings use:

- Low;
- Medium;
- High;
- Critical.

## 2. Risk summary

| ID | Risk | Likelihood | Impact | Initial priority |
|---|---|---:|---:|---:|
| R-001 | Process disappears during inspection | High | Medium | High |
| R-002 | PID is reused between observations | Medium | High | High |
| R-003 | Procfs content is malformed or unexpected | Medium | High | High |
| R-004 | Permission restrictions cause incomplete data | High | Medium | High |
| R-005 | Sensitive process information is exposed | Medium | High | High |
| R-006 | Memory units are interpreted incorrectly | Medium | High | High |
| R-007 | CPU utilization is calculated incorrectly | Medium | High | High |
| R-008 | Integer conversion or arithmetic overflows | Medium | High | High |
| R-009 | Mapping classification is overstated | Medium | Medium | Medium |
| R-010 | Symbolic-link targets change during inspection | Medium | Medium | Medium |
| R-011 | Live-only tests are nondeterministic | High | High | High |
| R-012 | WSL behavior is treated as universal Linux behavior | Medium | High | High |
| R-013 | Static analysis creates excessive noise | Medium | Medium | Medium |
| R-014 | Sanitizer configurations are incompatible | Low | Medium | Medium |
| R-015 | CLI logic becomes coupled to procfs parsing | Medium | High | High |
| R-016 | Snapshot schema changes break compatibility | Medium | High | High |
| R-017 | Live monitoring consumes unbounded resources | Medium | High | High |
| R-018 | Project 2 integration creates tight coupling | Medium | Medium | Medium |
| R-019 | Generated snapshots enter version control | Medium | High | High |
| R-020 | Scope expands into process control or debugging | Low | Critical | High |

## 3. Detailed risks

### R-001 — Process disappears during inspection

**Description:** A process may terminate after ProcLens discovers its PID but
before one or more procfs files are opened or read.

**Likelihood:** High

**Impact:** Medium

**Possible consequences:**

- missing files;
- short reads;
- partial snapshots;
- inconsistent sections;
- crashes if disappearance is treated as exceptional program failure.

**Mitigation:**

- treat disappearance as a normal observation outcome;
- preserve already collected data;
- report partial results;
- avoid assumptions that consecutive reads observe one frozen state;
- test with controlled child processes that exit during inspection.

**Verification:**

- integration tests;
- process-churn stress tests;
- regression tests for every disappearance-related defect.

**Review trigger:** Introduction of every new multi-file process inspection.

### R-002 — PID reuse between observations

**Description:** Linux may assign a previously used PID to a different process.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- samples from unrelated processes are combined;
- snapshot differences become invalid;
- CPU and I/O deltas are misattributed;
- process monitoring silently switches targets.

**Mitigation:**

- combine PID with process start time;
- verify identity before calculating deltas;
- reject samples when identity changes;
- document identity boundaries.

**Verification:**

- synthetic identity tests;
- controlled process restart tests;
- process-churn stress tests.

**Review trigger:** Process identity implementation and every sampling feature.

### R-003 — Unexpected or malformed procfs content

**Description:** Procfs text may differ because of kernel versions, optional
fields, truncation, races, or unusual process names and paths.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- parser failure;
- incorrect field alignment;
- integer conversion errors;
- crashes;
- silently incorrect results.

**Mitigation:**

- use bounded parsing;
- validate field counts and ranges;
- preserve unknown fields where appropriate;
- distinguish malformed content from unavailable interfaces;
- maintain malformed fixtures;
- avoid unsafe tokenization assumptions.

**Verification:**

- fixture-based unit tests;
- fuzzing in a later milestone;
- regression tests;
- sanitizer validation.

**Review trigger:** Every new procfs parser.

### R-004 — Permission-restricted information

**Description:** Linux security policies may deny access to process metadata,
links, mappings, descriptors, environments, or other interfaces.

**Likelihood:** High

**Impact:** Medium

**Possible consequences:**

- incomplete inspection;
- inconsistent behavior between users or environments;
- misleading zero values;
- pressure to require root unnecessarily.

**Mitigation:**

- preserve permission-denied diagnostics;
- represent unavailable data separately from zero;
- keep partial snapshots usable;
- avoid requiring root for ordinary workflows;
- document security-policy effects.

**Verification:**

- inspect unrelated processes where permitted;
- controlled permission tests;
- CI tests for error formatting.

**Review trigger:** Every newly supported sensitive procfs interface.

### R-005 — Sensitive information exposure

**Description:** Command lines, environments, paths, file descriptors, and
snapshots may contain credentials, tokens, usernames, private filenames, or
other sensitive data.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- accidental disclosure;
- sensitive fixtures committed to Git;
- terminal output copied into reports or issue trackers;
- unsafe default behavior.

**Mitigation:**

- omit complete environments by default;
- require explicit options for sensitive fields;
- minimize and redact where practical;
- ignore generated snapshots and captured fixtures;
- document privacy implications;
- sanitize committed fixtures.

**Verification:**

- privacy review;
- Git status checks;
- fixture review;
- golden tests for redaction behavior.

**Review trigger:** Environment, command-line, descriptor, and snapshot features.

### R-006 — Incorrect memory-unit interpretation

**Description:** Linux memory interfaces report values in bytes, KiB, pages,
and accounting-specific metrics.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- values off by factors of 1,024 or page size;
- virtual and resident values conflated;
- incorrect snapshot comparisons;
- misleading reports.

**Mitigation:**

- use explicit unit-aware types;
- obtain page size from the operating system;
- document every source unit;
- use overflow-checked conversion;
- keep unavailable values separate from zero.

**Verification:**

- synthetic conversion tests;
- comparison with raw procfs and `pmap`;
- boundary-value tests.

**Review trigger:** Memory-summary and mapping milestones.

### R-007 — Incorrect CPU-utilization calculation

**Description:** CPU percentage requires repeated samples, clock-tick
conversion, elapsed time, and a documented multicore convention.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- percentages greater or smaller than expected;
- disagreement with reference tools;
- single counters presented incorrectly as utilization;
- invalid results after PID reuse.

**Mitigation:**

- use monotonic timestamps;
- sample process and system counters;
- document formulas and units;
- define single-core and whole-machine conventions;
- test synthetic counters;
- verify process identity between samples.

**Verification:**

- deterministic arithmetic tests;
- controlled CPU workloads;
- comparison with `pidstat`, `ps`, and `top`.

**Review trigger:** CPU-sampling design and implementation.

### R-008 — Integer overflow and narrowing

**Description:** Addresses, counters, sizes, timestamps, and conversions may
exceed smaller integer representations.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- wrapped addresses;
- negative-looking sizes;
- incorrect deltas;
- undefined behavior;
- corrupted JSON output.

**Mitigation:**

- use explicit fixed-width or suitably wide integer types;
- perform checked arithmetic;
- reject invalid ranges;
- retain strict conversion warnings;
- test maximum and overflow values.

**Verification:**

- boundary-value unit tests;
- UBSan;
- static analysis;
- malformed fixtures.

**Review trigger:** Every parser or conversion function.

### R-009 — Mapping-classification uncertainty

**Description:** Mapping categories are inferred from permissions, paths,
labels, executable identity, and other incomplete evidence.

**Likelihood:** Medium

**Impact:** Medium

**Possible consequences:**

- anonymous memory misclassified;
- shared libraries confused with ordinary mapped files;
- deleted mappings misunderstood;
- conclusions presented with unjustified certainty.

**Mitigation:**

- preserve raw mapping data;
- provide unknown or uncertain categories;
- document classification rules;
- avoid claiming classifications prove memory defects.

**Verification:**

- controlled mapping tests;
- fixture tests;
- comparison with `pmap` and raw maps.

**Review trigger:** Mapping-classification design or rule changes.

### R-010 — Symbolic-link race and unusual targets

**Description:** Procfs symbolic links can change, disappear, contain unusual
text, or point to deleted objects.

**Likelihood:** Medium

**Impact:** Medium

**Possible consequences:**

- stale executable or working-directory information;
- truncated link values;
- unsafe shell interpolation;
- inconsistent descriptor classification.

**Mitigation:**

- use direct system APIs rather than shell commands;
- resize buffers safely where needed;
- treat results as untrusted text;
- preserve deleted-target markers;
- accept disappearance as a normal race.

**Verification:**

- controlled link tests;
- deleted-file tests;
- process-exit integration tests.

**Review trigger:** Symbolic-link and descriptor-reader implementation.

### R-011 — Nondeterministic live testing

**Description:** Live process data varies across executions, machines, kernels,
and timing windows.

**Likelihood:** High

**Impact:** High

**Possible consequences:**

- flaky CI;
- tests that pass only on one machine;
- unrepeatable parser defects;
- unreliable golden output.

**Mitigation:**

- make fixtures the primary parser-testing mechanism;
- use controlled child processes for integration tests;
- limit assertions on volatile fields;
- separate live validation from deterministic unit tests.

**Verification:**

- repeated CI runs;
- stress tests;
- fixture reproducibility checks.

**Review trigger:** Every live integration or golden test.

### R-012 — WSL assumptions generalized to Linux

**Description:** WSL2 differs from native Linux in process visibility,
resources, kernel configuration, devices, performance counters, and filesystems.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- unsupported portability claims;
- hidden native-Linux defects;
- misleading performance results;
- incorrect container or namespace assumptions.

**Mitigation:**

- document WSL as the development environment;
- use Linux CI;
- record platform details with measurements;
- validate native Linux where practical;
- avoid universal compatibility claims.

**Verification:**

- GitHub Actions Linux runners;
- future native-Linux testing;
- platform-specific documentation.

**Review trigger:** Platform support claims and releases.

### R-013 — Static-analysis noise

**Description:** Broad clang-tidy and Cppcheck configurations may report
low-value findings or conflict with deliberate low-level code.

**Likelihood:** Medium

**Impact:** Medium

**Possible consequences:**

- valuable warnings ignored;
- global suppressions;
- development slowed by false positives;
- inconsistent policy.

**Mitigation:**

- suppress narrowly;
- document suppressions;
- review checks when low-level interfaces are introduced;
- never disable all warnings to achieve a clean build.

**Verification:**

- static-analysis CI;
- review of suppression changes.

**Review trigger:** New suppression or disabled check.

### R-014 — Incompatible sanitizer configurations

**Description:** Some sanitizers cannot be combined, and support differs by
compiler and environment.

**Likelihood:** Low

**Impact:** Medium

**Possible consequences:**

- configuration failure;
- linker errors;
- misleading validation claims.

**Mitigation:**

- separate AddressSanitizer and ThreadSanitizer configurations;
- combine ASan with UBSan only where supported;
- fail clearly for incompatible options;
- document platform limitations.

**Verification:**

- dedicated sanitizer presets;
- CI sanitizer workflows.

**Review trigger:** New sanitizer or compiler configuration.

### R-015 — CLI and parser coupling

**Description:** Procfs parsing may drift into command implementations for
short-term convenience.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- library reuse becomes difficult;
- parser tests require CLI execution;
- output concerns contaminate domain logic;
- commands duplicate parsing behavior.

**Mitigation:**

- enforce architecture invariants;
- keep the CLI thin;
- review dependencies between targets;
- test library behavior independently.

**Verification:**

- code review;
- target dependency inspection;
- unit tests that do not invoke the CLI.

**Review trigger:** Every new CLI command.

### R-016 — Snapshot-schema incompatibility

**Description:** JSON field or unit changes may break stored snapshots and
automation.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- old snapshots cannot be compared;
- downstream scripts fail;
- unavailable values become ambiguous;
- schema version becomes meaningless.

**Mitigation:**

- version the schema;
- use stable field names;
- preserve explicit units;
- document compatibility policy;
- validate snapshots against the schema.

**Verification:**

- schema validation;
- golden tests;
- compatibility fixtures.

**Review trigger:** Every serialized-field change.

### R-017 — Unbounded live-monitoring resources

**Description:** Watch modes may retain unlimited samples, allocate repeatedly,
or refresh too aggressively.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- ProcLens consumes excessive memory or CPU;
- the observer materially affects the observed system;
- long-running monitoring becomes unstable.

**Mitigation:**

- bound history;
- support configurable intervals;
- reuse buffers where justified;
- measure observer overhead;
- shut down cleanly.

**Verification:**

- extended watch tests;
- memory profiling;
- performance benchmarks;
- sanitizer runs.

**Review trigger:** Live monitoring and terminal-interface implementation.

### R-018 — Tight Project 2 coupling

**Description:** Direct ELF integration may introduce unstable APIs or make
ProcLens difficult to build independently.

**Likelihood:** Medium

**Impact:** Medium

**Possible consequences:**

- circular portfolio dependencies;
- complicated build setup;
- ProcLens blocked by Project 2 changes;
- unclear ownership of mapping correlation.

**Mitigation:**

- use an optional adapter;
- require a stable Project 2 API;
- keep standalone builds possible;
- record the integration decision in an ADR.

**Verification:**

- standalone build in CI;
- optional-integration build when introduced.

**Review trigger:** Proposed Project 2 dependency.

### R-019 — Generated snapshots committed accidentally

**Description:** Live captures may be added to Git and expose sensitive or
machine-specific data.

**Likelihood:** Medium

**Impact:** High

**Possible consequences:**

- privacy disclosure;
- unstable repository history;
- oversized Git objects;
- nonreproducible tests.

**Mitigation:**

- ignore generated snapshot directories;
- commit only reviewed and sanitized fixtures;
- inspect staged changes before every commit;
- document fixture-capture procedures.

**Verification:**

- `git status`;
- staged-diff review;
- CI checks where practical.

**Review trigger:** Snapshot and fixture-capture implementation.

### R-020 — Scope expansion into control or debugging

**Description:** Process inspection could expand into signaling, tracing,
memory reading, injection, or access-control bypass.

**Likelihood:** Low

**Impact:** Critical

**Possible consequences:**

- violation of the project charter;
- greatly increased security risk;
- unclear ethical and operational boundaries;
- portfolio focus lost.

**Mitigation:**

- preserve explicit version 1 non-goals;
- reject process-control features;
- require formal architecture review for scope changes;
- keep ProcLens read-only.

**Verification:**

- milestone review;
- security review;
- release acceptance review.

**Review trigger:** Any proposed process-control, tracing, injection, or
privilege-related feature.

## 4. Risk ownership

The project engineer owns implementation and evidence collection.

The lead execution engineer owns:

- architectural review;
- milestone-gate review;
- risk-priority review;
- acceptance of mitigations;
- approval of scope changes.

Security and privacy risks require explicit review before release.

## 5. Review policy

This risk register must be reviewed:

- at every milestone completion;
- after every confirmed race-related defect;
- after every security or privacy concern;
- before introducing a new procfs interface;
- before introducing concurrency;
- before Project 2 integration;
- before versioning the JSON schema;
- before performance claims;
- before release tagging.

Newly discovered risks must receive:

- a unique identifier;
- likelihood and impact ratings;
- mitigation;
- verification evidence;
- an owner;
- a review trigger.

## 6. Milestone 0 risk acceptance

Milestone 0 accepts that substantive risk mitigations are not yet implemented.

Milestone 0 must nevertheless establish:

- the read-only boundary;
- strict build and analysis policies;
- deterministic-fixture architecture;
- platform limitations;
- ignored generated snapshots;
- partial-result direction;
- PID-reuse awareness;
- explicit review checkpoints.

No core procfs implementation may begin until these foundation controls exist.
