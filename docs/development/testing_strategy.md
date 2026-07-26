# ProcLens Testing Strategy

## Document status

- Project: ProcLens
- Repository: `linux_process_memory_explorer`
- Milestone: Milestone 0
- Status: Initial testing strategy
- Primary test platform: Linux
- Primary local environment: Kali Linux under WSL2

## 1. Purpose

This document defines how ProcLens will verify correctness, safety,
reproducibility, platform behavior, output stability, and resilience.

ProcLens reads live Linux process information. Live kernel interfaces are
valuable for integration testing but are not sufficiently deterministic to
serve as the only test source.

The testing strategy therefore combines:

1. deterministic fixtures;
2. controlled child processes;
3. live system validation;
4. regression tests;
5. golden-output tests;
6. stress testing;
7. static analysis and sanitizers.

## 2. Testing principles

ProcLens testing follows these principles:

1. Parser correctness should be testable without live procfs.
2. Live tests should control the observed process where practical.
3. Volatile fields should not be asserted with exact values unnecessarily.
4. Process disappearance is a normal scenario and must be tested.
5. Permission denial must remain distinguishable from empty or zero data.
6. Every confirmed defect should receive a permanent regression test.
7. Text and JSON output should remain stable through golden tests.
8. Platform-specific assumptions must be documented.
9. Test failures must provide useful diagnostic context.
10. Tests must not require root during normal development or CI.

## 3. Test categories

### 3.1 Unit tests

Unit tests verify isolated components such as:

- process-ID validation;
- path construction;
- bounded file reading;
- symbolic-link result handling;
- procfs parsers;
- unit conversions;
- checked arithmetic;
- CPU calculations;
- mapping permissions;
- mapping classification;
- snapshot comparison;
- error categorization;
- unavailable-value behavior.

Unit tests should not depend on arbitrary live processes.

### 3.2 Fixture-based parser tests

Fixture tests provide deterministic procfs input.

Planned fixture groups include:

```text
fixtures/procfs/
    valid/
    malformed/
    truncated/
    optional-fields/
    permission-model/
    kernel-variants/
```

Fixtures may represent:

- `/proc/<pid>/stat`;
- `/proc/<pid>/status`;
- `/proc/<pid>/maps`;
- `/proc/<pid>/smaps`;
- `/proc/<pid>/smaps_rollup`;
- `/proc/<pid>/limits`;
- `/proc/<pid>/io`;
- `/proc/stat`;
- thread-related files;
- descriptor metadata.

Each fixture must be:

- sanitized;
- deterministic;
- documented;
- small enough to review;
- paired with expected behavior.

### 3.3 Integration tests

Integration tests exercise real Linux behavior using controlled child
processes.

Controlled workloads will eventually:

- sleep;
- consume CPU;
- allocate memory;
- grow memory over time;
- create threads;
- map files;
- create anonymous mappings;
- open regular files;
- create pipes;
- perform I/O;
- hold deleted files open;
- exit during inspection.

Integration tests should inspect processes created by the test suite rather
than unrelated system processes whenever possible.

### 3.4 Regression tests

Every confirmed defect involving:

- parsing;
- arithmetic;
- process races;
- PID reuse;
- permissions;
- incorrect output;
- crashes;
- resource leaks;
- schema compatibility;
- platform-specific behavior;

must receive a permanent regression test before closure.

The regression test must fail before the fix and pass afterward.

### 3.5 Golden tests

Golden tests verify stable output for:

- human-readable tables;
- detailed text output;
- JSON output;
- diagnostics;
- partial-result rendering;
- snapshot serialization.

Golden inputs must be deterministic.

Golden tests must avoid volatile values such as:

- current timestamps;
- real process identifiers;
- machine-specific paths;
- kernel-specific values;

unless those values are normalized before comparison.

### 3.6 Stress tests

Stress tests will cover:

- repeated process enumeration;
- rapid process creation and destruction;
- process disappearance during reads;
- repeated snapshots;
- large but safe thread counts;
- mapping-heavy controlled processes;
- long-running watch loops;
- bounded memory use;
- repeated symbolic-link reads;
- repeated formatter execution.

Stress tests must remain safe for developer machines and CI runners.

### 3.7 Static-analysis validation

The project uses:

- compiler warnings;
- clang-tidy;
- Cppcheck.

Static-analysis findings must be:

- investigated;
- fixed where valid;
- suppressed narrowly where justified;
- documented when suppression is permanent.

Static analysis does not replace runtime testing.

### 3.8 Sanitizer validation

The project supports:

- AddressSanitizer;
- UndefinedBehaviorSanitizer;
- ThreadSanitizer when concurrency is introduced;
- LeakSanitizer where supported;
- Valgrind for selected workflows.

AddressSanitizer and ThreadSanitizer must use separate configurations.

Sanitizer success does not prove functional correctness, but sanitizer failures
must block milestone completion unless explicitly documented as unsupported.

## 4. Milestone 0 tests

Milestone 0 contains only one zero-feature smoke-test executable.

The smoke test must prove that:

- the public ProcLens header can be included;
- `proclens_core` compiles;
- the test links against `proclens_core`;
- version values are internally consistent;
- the executable runs successfully;
- CTest can discover and execute the test.

Milestone 0 does not test real procfs parsing because no parser is authorized
yet.

## 5. Test isolation

Tests must avoid:

- depending on unrelated system processes;
- assuming stable process IDs;
- assuming exact CPU percentages;
- requiring a specific process count;
- depending on private user files;
- reading process environments;
- requiring root;
- changing global security settings;
- leaving child processes running after completion.

Controlled children must be cleaned up even when tests fail.

## 6. Time and sampling tests

Sampling tests must use:

- monotonic clocks;
- synthetic counters for arithmetic tests;
- tolerances for live timing;
- explicit sample intervals;
- identity verification between samples.

Tests must not assume that a requested sleep duration produces an exact elapsed
time.

CPU calculation tests should separate:

- counter arithmetic;
- clock-tick conversion;
- elapsed-time calculation;
- multicore display policy.

## 7. Memory tests

Memory tests must distinguish:

- virtual size;
- resident memory;
- proportional set size;
- unique set size when derived;
- shared estimates;
- anonymous memory;
- file-backed memory;
- allocator-requested memory;
- actual resident pages.

Synthetic tests should use explicit units.

Live memory tests should use controlled allocations and avoid expecting every
allocated byte to become resident immediately.

## 8. Mapping tests

Mapping parser tests must cover:

- valid address ranges;
- invalid ranges;
- read, write, and execute permissions;
- private and shared mappings;
- offsets;
- device numbers;
- inodes;
- anonymous mappings;
- paths containing spaces;
- deleted mapped files;
- special mappings;
- malformed lines;
- classification uncertainty.

Mapping tests must preserve raw input even when classification is unknown.

## 9. Permission tests

Permission tests must verify that denied access is represented as:

- permission denied;
- partial result;
- unavailable section;

as appropriate.

Tests must not weaken system security settings merely to manufacture access.

Some permission behavior may require platform-specific or manual validation.

## 10. Process-lifecycle tests

Lifecycle tests must cover:

- process exists throughout inspection;
- process exits before inspection;
- process exits between reads;
- process exits during directory enumeration;
- parent exits before child;
- missing parent;
- possible PID reuse;
- thread exits during task enumeration.

Disappearance must not crash ProcLens.

## 11. Output testing

Text output tests must verify:

- stable headings;
- stable columns;
- explicit units;
- unavailable-value rendering;
- partial-result warnings;
- no uncontrolled terminal sequences.

JSON tests must verify:

- valid syntax;
- stable field names;
- schema version;
- explicit units;
- unavailable versus zero;
- deterministic ordering where required;
- snapshot-schema validation.

## 12. System-tool validation

Representative output will be compared with:

- raw procfs files;
- `ps`;
- `top`;
- `pidstat`;
- `pmap`;
- `lsof`;
- `strace`;
- Project 2 ELF information when integration exists.

Differences may arise because tools use different:

- sampling intervals;
- data sources;
- rounding;
- accounting formulas;
- permissions;
- aggregation policies.

A difference must be investigated before it is labeled a defect.

## 13. Platform validation

Testing should record:

- distribution;
- kernel;
- architecture;
- WSL, native, or container environment;
- compiler;
- build type;
- sanitizer state;
- security restrictions.

Local WSL2 validation must be supplemented by Linux CI.

Native Linux and container-specific behavior should be tested where practical.

## 14. CTest organization

Tests should use labels such as:

```text
unit
integration
regression
golden
stress
sanitizer
```

Examples:

```bash
ctest --test-dir build/debug-clang --output-on-failure
ctest --test-dir build/debug-clang -L unit --output-on-failure
ctest --test-dir build/debug-clang -L integration --output-on-failure
```

Long-running stress tests should not run in every quick local build unless
explicitly enabled.

## 15. Test naming

Test names should describe behavior.

Preferred examples:

```text
process_id_rejects_negative_values
stat_parser_handles_names_with_spaces
snapshot_preserves_unavailable_mappings
cpu_calculator_rejects_identity_change
maps_parser_rejects_reversed_range
```

Avoid names such as:

```text
test1
parser_test
works
basic
```

## 16. Test-data privacy

Test data must not contain:

- real secrets;
- uncontrolled process environments;
- private keys;
- real production hostnames;
- confidential paths;
- real customer data.

Captured procfs material must be written first to an ignored directory and
reviewed before becoming a fixture.

## 17. Continuous-integration strategy

Initial CI will verify:

- Clang Debug;
- Clang Release;
- GCC Debug;
- GCC Release;
- tests;
- warnings as errors;
- formatting;
- static analysis;
- sanitizers.

Later CI may include:

- integration tests;
- golden tests;
- schema validation;
- selected stress tests;
- native container tests;
- ThreadSanitizer.

CI must remain reproducible from a clean checkout.

## 18. Test failure policy

A failing required test blocks milestone completion.

Flaky tests must not simply be retried indefinitely.

When a test is flaky:

1. reproduce the failure;
2. identify nondeterministic assumptions;
3. isolate volatile behavior;
4. replace live inputs with fixtures where appropriate;
5. document unavoidable platform variability;
6. add regression coverage.

Disabling a test requires a documented reason and review.

## 19. Evidence required at milestone completion

Milestone completion evidence should include:

- configure command or preset;
- compiler and build type;
- build result;
- CTest result;
- sanitizer result;
- static-analysis result;
- relevant integration output;
- CI run status;
- known skipped or platform-specific tests;
- clean working-tree status.

## 20. Milestone 0 completion criteria

Milestone 0 testing is complete when:

- the smoke test exists;
- the smoke test passes with Clang;
- the smoke test passes with GCC;
- CTest discovers the smoke test;
- sanitizer execution passes;
- static analysis runs successfully;
- CI executes the test;
- a fresh clone reproduces the result.

No substantive parser correctness is claimed during Milestone 0.
