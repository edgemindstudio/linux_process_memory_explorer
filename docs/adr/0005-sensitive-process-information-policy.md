# ADR-0005: Sensitive process-information policy

- Status: Accepted
- Date: 2026-07-26
- Decision owners: Project engineer and lead execution engineer

## Context

ProcLens will inspect Linux process information that may include:

- command-line arguments;
- executable paths;
- current working directories;
- open-file paths;
- memory-mapping paths;
- file-descriptor targets;
- process identifiers;
- usernames and group identifiers;
- generated snapshots;
- diagnostic output;
- potentially process environments.

Although ProcLens is read-only, read-only inspection can still expose secrets
or private information.

Environment variables and command-line arguments may contain:

- passwords;
- API keys;
- access tokens;
- database connection strings;
- private paths;
- internal hostnames;
- temporary credentials.

A decision is required about whether ProcLens should:

1. collect all available process information by default;
2. collect only minimally sensitive fields and require explicit requests for
   more sensitive information;
3. avoid all potentially sensitive process information entirely.

## Decision drivers

- ProcLens must remain useful for real process inspection.
- Read-only access does not eliminate privacy risk.
- Environment data is especially likely to contain credentials.
- Command lines and paths are useful but may still be sensitive.
- Generated snapshots may outlive the inspected process.
- Fixtures and logs must remain safe to commit.
- Users must understand when sensitive information is collected.
- Permission-denied behavior must remain visible.
- Normal operation must not require elevated privileges.
- Inspected text must never be executed or interpolated into shell commands.

## Options considered

### Option 1 — Collect all available information by default

ProcLens could read every supported procfs interface whenever a process is
inspected.

Advantages:

- maximum information is immediately available;
- snapshots contain comprehensive process state;
- fewer command-specific collection paths;
- users do not need to request additional sections.

Disadvantages:

- unnecessary exposure of sensitive data;
- process environments may reveal credentials;
- snapshots become more dangerous to store or share;
- collection cost increases;
- permission failures increase;
- commands read data unrelated to their purpose;
- privacy expectations become difficult to understand;
- committed fixtures are more likely to contain secrets.

### Option 2 — Minimize collection and require explicit sensitive-data requests

ProcLens can collect only the sections needed for the requested operation and
require explicit user action for sensitive categories.

Advantages:

- reduces accidental exposure;
- aligns collection with command intent;
- avoids complete environments by default;
- snapshots can document included sections;
- fewer unnecessary procfs reads;
- permission failures remain localized;
- users can make informed decisions;
- fixture sanitization becomes more manageable.

Disadvantages:

- some users must request additional information explicitly;
- command behavior requires clear documentation;
- snapshot options become more detailed;
- redaction and warning behavior may require additional design;
- different commands may collect different subsets.

### Option 3 — Avoid all potentially sensitive information

ProcLens could refuse to display command lines, paths, descriptors, mappings,
or related information.

Advantages:

- minimal privacy risk;
- simpler output review;
- fewer sensitive fixtures;
- reduced need for redaction.

Disadvantages:

- process identification becomes weak;
- mapping and descriptor inspection becomes largely useless;
- important diagnostics disappear;
- the product cannot meet its intended scope;
- users would still rely on other tools for the same information.

## Decision

ProcLens will use data minimization by default.

Each command will collect only the process information needed to perform its
documented function.

The initial policy is:

```text
ordinary process inspection
    ↓
collect necessary metadata only
    ↓
avoid unrelated sensitive sections
```

Complete process environments will not be collected by default.

Access to:

```text
/proc/<pid>/environ
```

must require explicit user action and a documented warning.

Milestone 0 will not read process environments at all.

Other potentially sensitive information, including command lines, paths,
descriptor targets, and snapshots, may be exposed when relevant to the
requested command, but must be:

- treated as potentially sensitive;
- handled as untrusted text;
- excluded from unrelated operations;
- escaped appropriately for output;
- documented when stored;
- sanitized before becoming a committed fixture.

Generated snapshots must be considered potentially confidential.

## Rationale

Data minimization provides the best balance between utility and privacy.

ProcLens cannot avoid all potentially sensitive information because process
names, paths, mappings, and descriptors are central to its diagnostic purpose.

However, reading all available information for every command would expose data
that the user did not request and that the operation does not need.

Environment variables deserve stronger protection because they frequently
contain credentials and are rarely required for ordinary process inspection.

Explicit access ensures that:

- the user knows sensitive data may be exposed;
- ordinary commands remain safer;
- snapshots avoid unnecessary secrets;
- fixtures and diagnostics are easier to sanitize;
- permission failures are limited to requested data.

## Consequences

### Positive consequences

- Ordinary commands expose less sensitive information.
- Environment data is protected by default.
- Collection cost is reduced.
- Permission failures remain localized.
- Snapshots can describe exactly which sections were included.
- Test fixtures are less likely to contain secrets.
- Users retain access to advanced information when explicitly requested.
- Privacy expectations become easier to document.

### Negative consequences

- Some diagnostic workflows require additional options.
- Sensitive-data warnings must be designed carefully.
- Commands need explicit collection plans.
- Snapshot configuration becomes more complex.
- Future redaction behavior requires tests and documentation.
- Users may incorrectly assume all visible procfs data is harmless unless
  warnings remain prominent.

### Neutral or operational consequences

- The CLI must document sensitive options.
- The core library should not automatically broaden collection.
- Environment values must not appear in ordinary snapshots.
- Fixture-capture workflows must use ignored locations first.
- Human review is required before captured data enters Git.
- Diagnostics should avoid printing complete command lines unless needed.
- Terminal rendering must escape control characters from inspected text.
- JSON output must preserve sensitive fields only when explicitly requested.

## Rejected alternatives

Collecting all available information by default was rejected because it would
expose unnecessary sensitive data and violate the principle of least
collection.

Avoiding all potentially sensitive information was rejected because it would
make core ProcLens features such as mapping, descriptor, and command-line
inspection ineffective.

The selected policy preserves useful inspection while minimizing accidental
exposure.

## Review triggers

Review this ADR when:

- environment inspection is implemented;
- command-line redaction is introduced;
- file-descriptor inspection is implemented;
- snapshot defaults are defined;
- terminal escaping is implemented;
- JSON schema includes sensitive fields;
- fixture capture is automated;
- users request broader default collection;
- a security review identifies a new sensitive-data category.

## Related documents

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/security/privacy_and_permissions.md`
- `docs/security/risk_register.md`
- `docs/development/testing_strategy.md`
- `docs/adr/0004-partial-results-and-diagnostics.md`
