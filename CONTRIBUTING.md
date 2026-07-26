# Contributing to ProcLens

Thank you for contributing to ProcLens.

ProcLens is a Linux process and virtual-memory exploration project developed
with a strong emphasis on correctness, reproducibility, security, testing, and
clear architecture.

## Current development stage

ProcLens is currently in Milestone 0.

Milestone 0 permits work on:

- project structure;
- documentation;
- CMake;
- compiler policies;
- formatting;
- static analysis;
- sanitizers;
- smoke tests;
- CI;
- version and platform foundation.

Milestone 0 does not permit substantive procfs parser implementation.

Check `ROADMAP.md` before beginning work.

## Engineering principles

Contributions must preserve these rules:

1. Core process data is read directly from Linux interfaces.
2. The CLI does not parse procfs.
3. The reusable library does not depend on CLI behavior.
4. Partial results preserve usable information.
5. Unavailable information is distinct from zero.
6. Process disappearance is handled as a normal observation outcome.
7. PID reuse must be considered across observations.
8. Sensitive information is minimized by default.
9. Process environments are not collected automatically.
10. WSL2 testing does not prove universal native-Linux compatibility.
11. Project 2 integration remains optional.
12. Concurrency requires demonstrated need and architecture review.

## Repository layout

```text
.github/workflows/       Continuous-integration workflows
cmake/                   Reusable CMake configuration
docs/                    Engineering and architecture documentation
examples/                Controlled demonstrations
fixtures/                Sanitized deterministic test data
include/proclens/        Public library headers
schemas/                 Versioned schemas
scripts/                 Developer and CI utilities
src/                     Core library implementation
tests/                   Automated tests
tools/proclens/          CLI implementation
```

## Development environment

The primary development environment is Linux.

The audited local environment is Kali Linux under WSL2.

Development repositories should be stored in the Linux filesystem, such as:

```text
/home/fonke/linux_process_memory_explorer
```

rather than under `/mnt/c`.

See `docs/platform/platform_support.md`.

## Required tools

The project uses:

- a C++20 compiler;
- CMake;
- Ninja;
- Git;
- clang-format;
- clang-tidy;
- Cppcheck;
- CTest;
- sanitizers.

Both Clang and GCC builds must remain supported.

## Branch policy

Use a focused branch for substantial changes.

Example:

```bash
git switch -c feature/short-description
```

Branch names should be descriptive:

```text
feature/add-version-foundation
fix/correct-cmake-warning-policy
docs/clarify-wsl-boundary
test/add-smoke-validation
```

Avoid vague names such as:

```text
changes
work
fix
new
```

## Change scope

Each change should have one coherent purpose.

A contribution should avoid combining unrelated:

- implementation changes;
- formatting changes;
- documentation rewrites;
- refactoring;
- dependency updates;
- generated artifacts.

Small, focused changes are easier to review and verify.

## Architecture Decision Records

Create or update an ADR when a contribution changes:

- public architecture;
- dependency direction;
- platform support;
- security boundaries;
- privacy defaults;
- serialization compatibility;
- concurrency;
- an external dependency;
- an accepted design decision.

See `docs/adr/README.md`.

Do not silently contradict an accepted ADR.

## Public API policy

Public headers belong in:

```text
include/proclens/
```

Implementation details should remain private unless external consumers require
them.

Before adding a public type or function, consider:

- whether it must be public;
- ownership semantics;
- error behavior;
- unit representation;
- lifetime requirements;
- thread-safety expectations;
- compatibility consequences;
- testability.

Public APIs should not be frozen prematurely.

## CLI policy

The CLI belongs in:

```text
tools/proclens/
```

The CLI may:

- parse arguments;
- select commands;
- call the core library;
- choose text or JSON output;
- render diagnostics;
- return process exit codes.

The CLI must not:

- parse procfs directly;
- contain duplicated domain logic;
- define core process models;
- expose terminal behavior to `proclens_core`.

## Coding style

The project follows `.clang-format` and `.editorconfig`.

Format changed C++ files before review.

Example:

```bash
clang-format -i path/to/changed_file.cpp
```

Avoid formatting unrelated files in the same change.

Names should communicate intent.

Prefer:

```text
process_start_time_ticks
read_symbolic_link
parse_process_status
```

Avoid:

```text
x
data2
doStuff
helper
```

unless the scope makes the name unambiguous.

## Compiler warnings

Compiler warnings are treated as errors in validated configurations.

Do not silence warnings through:

- unsafe casts;
- broad compiler suppression;
- unused-variable tricks;
- disabling warnings globally.

Fix the underlying issue or document a narrow suppression.

## Static analysis

The project uses:

- clang-tidy;
- Cppcheck.

A static-analysis finding must be:

1. understood;
2. fixed when valid;
3. suppressed narrowly when demonstrably inappropriate;
4. documented when the suppression remains permanent.

Do not disable an entire analysis family merely to obtain a clean result.

## Sanitizers

The project uses separate validation configurations for:

- AddressSanitizer;
- UndefinedBehaviorSanitizer;
- ThreadSanitizer when concurrency is introduced.

AddressSanitizer and ThreadSanitizer must not be combined in one configuration.

Sanitizer failures block completion unless the environment limitation is
explicitly documented and reviewed.

## Testing requirements

Every contribution must include appropriate testing.

Possible categories include:

- unit;
- fixture-based;
- integration;
- regression;
- golden;
- stress.

Every confirmed defect should receive a regression test.

Tests should describe behavior.

Preferred:

```text
version_components_are_nonnegative
process_id_rejects_zero
maps_parser_rejects_reversed_range
```

Avoid:

```text
test1
basic_test
works
```

## Live process tests

Live procfs tests must not depend unnecessarily on unrelated system processes.

Prefer controlled child processes.

Tests must not assume:

- stable process identifiers;
- exact process counts;
- exact scheduling;
- exact CPU percentages;
- unrestricted access to unrelated processes;
- root privileges.

Live tests supplement deterministic fixtures. They do not replace them.

## Fixture policy

Fixtures must be:

- deterministic;
- sanitized;
- documented;
- reviewable;
- free of real secrets.

Fixtures must not contain:

- passwords;
- API keys;
- access tokens;
- private keys;
- uncontrolled environments;
- real customer data;
- private production paths;
- confidential hostnames.

Captured procfs data must first be written to an ignored location and reviewed
before entering `fixtures/`.

## Security and privacy

ProcLens is read-only.

Contributions must not introduce:

- arbitrary process-memory reading;
- process-memory modification;
- `ptrace` attachment;
- code injection;
- signaling;
- process termination;
- privilege escalation;
- permission bypass;
- automatic security-policy changes;
- shell execution using inspected process data.

Paths, command lines, symbolic links, and process-provided strings are untrusted
input.

See `docs/security/privacy_and_permissions.md`.

## Environment-variable policy

Ordinary ProcLens commands must not read:

```text
/proc/<pid>/environ
```

Environment inspection requires explicit architecture and privacy review.

Milestone 0 contains no environment-reading implementation.

## Documentation requirements

Documentation must distinguish:

- implemented behavior;
- planned behavior;
- experimental behavior;
- unsupported behavior;
- deferred ideas.

Do not claim that future roadmap features already exist.

When adding or changing behavior, update relevant:

- README;
- roadmap;
- architecture;
- platform documentation;
- privacy policy;
- testing strategy;
- ADRs;
- changelog.

## Commit preparation

Before staging, inspect:

```bash
git status --short
git diff
```

Stage intentionally:

```bash
git add path/to/file
```

or, when normalizing tracked deletions and additions:

```bash
git add -A
```

Then inspect the staged change:

```bash
git diff --cached --stat
git diff --cached
```

Never rely solely on `.gitignore` to protect sensitive information.

## Commit messages

Use an imperative, focused subject.

Preferred examples:

```text
Establish ProcLens architecture foundation
Add strict compiler warning policies
Document Linux and WSL2 support boundary
Create Milestone 0 smoke test
```

Avoid:

```text
updates
changes
fix stuff
work in progress
```

A commit should describe one coherent engineering result.

## Pull-request expectations

A pull request should explain:

- what changed;
- why it changed;
- architectural impact;
- tests performed;
- platform used;
- known limitations;
- security or privacy implications;
- related ADRs;
- documentation updates.

A change is not ready merely because it compiles locally.

## Validation evidence

Before requesting review, provide relevant evidence such as:

```text
Compiler:
Build type:
Preset:
CTest result:
Formatting result:
clang-tidy result:
Cppcheck result:
Sanitizer result:
CI result:
Platform:
Known skips:
```

Milestone-completion work also requires fresh-clone validation.

## Generated files

Do not commit generated:

- build directories;
- CMake caches;
- compiler outputs;
- logs;
- profiler output;
- traces;
- live snapshots;
- captured procfs trees;
- sanitizer output;
- temporary test files.

Only reviewed and intentionally versioned generated artifacts may enter Git.

## Dependency policy

New dependencies require justification.

Consider:

- necessity;
- maintenance status;
- licensing;
- security history;
- API stability;
- build-system impact;
- package availability;
- CI support;
- effect on standalone builds.

Project 2 ELF integration must remain optional.

## Performance changes

Performance changes require evidence.

Document:

- benchmark workload;
- hardware;
- kernel;
- compiler;
- build type;
- sample count;
- measurement method;
- before result;
- after result;
- variability.

Do not trade away correctness or safety for unmeasured speed.

## Review checklist

Before submitting a change, confirm:

- [ ] The change belongs to the authorized milestone.
- [ ] The scope is focused.
- [ ] Architecture boundaries remain intact.
- [ ] Public API additions are justified.
- [ ] Formatting passes.
- [ ] Clang and GCC builds pass where applicable.
- [ ] Tests pass.
- [ ] Static analysis passes.
- [ ] Sanitizers pass where applicable.
- [ ] Documentation matches actual behavior.
- [ ] Sensitive information is absent.
- [ ] Generated artifacts are absent.
- [ ] Relevant ADRs are updated.
- [ ] The staged diff has been reviewed.

## Code of conduct

Contributors should communicate professionally, review technical claims
carefully, and focus criticism on code, architecture, evidence, and documented
requirements.

Disagreement should be resolved through:

- reproducible evidence;
- source documentation;
- tests;
- benchmarks;
- architecture review;
- explicit tradeoff analysis.

## Questions and proposals

Significant proposals should begin with:

- the problem being solved;
- why current behavior is insufficient;
- alternatives considered;
- expected architectural impact;
- testing approach;
- privacy and security considerations.

Large implementation changes should not begin before the proposal and milestone
scope are understood.
