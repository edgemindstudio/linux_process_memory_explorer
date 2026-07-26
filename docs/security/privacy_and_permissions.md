# ProcLens Privacy and Permissions Policy

## Document status

- Project: ProcLens
- Repository: `linux_process_memory_explorer`
- Milestone: Milestone 0
- Status: Initial security and privacy policy
- Product boundary: Read-only Linux process inspection

## 1. Purpose

This document defines how ProcLens handles operating-system permissions,
potentially sensitive process information, generated artifacts, diagnostics,
and user expectations.

ProcLens is read-only, but read-only process inspection can still expose
sensitive information. The absence of process modification does not eliminate
privacy risk.

## 2. Security principle

ProcLens may inspect only information that the operating system permits the
current user to access.

ProcLens must never:

- bypass permission checks;
- recommend privilege escalation as the default solution;
- attach with `ptrace`;
- read arbitrary process memory;
- modify process memory;
- inject code;
- send signals;
- terminate processes;
- execute commands derived from inspected data;
- weaken system security settings automatically.

Permission denial is a valid observation result, not a defect to bypass.

## 3. Potentially sensitive information

The following process information may be sensitive:

- command-line arguments;
- environment variables;
- executable paths;
- current working directories;
- open-file paths;
- deleted-file names;
- socket and pipe descriptions;
- usernames and group information;
- process identifiers;
- snapshot timestamps;
- container or namespace information;
- memory-mapping paths;
- diagnostic logs;
- generated JSON snapshots.

Sensitive data may include:

- passwords;
- authentication tokens;
- API keys;
- database connection strings;
- private filenames;
- user directory names;
- internal service names;
- temporary secrets passed through command-line arguments;
- environment-based credentials.

ProcLens must not assume that information exposed through procfs is safe to
publish or commit.

## 4. Default collection policy

ProcLens should collect only the information needed for the requested command.

Examples:

- `proclens list` should not read complete environments;
- `proclens memory <pid>` should not enumerate file descriptors unless needed;
- `proclens maps <pid>` should not capture unrelated process sections;
- `proclens snapshot <pid>` must document which sensitive sections are included.

Broad collection for convenience should be avoided.

## 5. Environment-variable policy

Complete process environments are highly sensitive.

Version 1 must:

- omit environment-variable collection by default;
- require an explicit user action to request environment data;
- warn that environment values may contain secrets;
- preserve permission failures;
- avoid storing environment data in fixtures;
- avoid including environment data in ordinary snapshots;
- support future redaction or name-only views before exposing values broadly.

No Milestone 0 code will read `/proc/<pid>/environ`.

## 6. Command-line policy

Process command lines may contain sensitive values.

ProcLens may expose command-line information because it is useful for process
identification, but documentation and output design must acknowledge the risk.

Future safeguards may include:

- truncation in process-list views;
- explicit detailed-output modes;
- optional redaction;
- JSON fields that preserve availability without forcing display;
- warnings before snapshot capture.

Golden tests must use synthetic command lines without real secrets.

## 7. Path and symbolic-link policy

Paths and procfs symbolic-link targets are untrusted text.

ProcLens must:

- read symbolic links through operating-system APIs;
- avoid shell interpolation;
- avoid command execution;
- handle deleted-target markers;
- handle unusual characters;
- handle disappearing targets;
- avoid assuming a link remains stable after it is read;
- preserve permission and I/O errors.

A path displayed by ProcLens is descriptive data, not an instruction.

## 8. File-descriptor policy

File descriptors can reveal:

- private files;
- devices;
- sockets;
- pipes;
- deleted files;
- anonymous kernel objects.

Descriptor inspection must:

- respect permissions;
- avoid opening the descriptor target;
- avoid following discovered paths for additional access unless explicitly
  required by a documented feature;
- treat symbolic-link text as untrusted;
- distinguish unavailable information from an empty descriptor set.

## 9. Snapshot policy

Process snapshots may contain sensitive or machine-specific information.

Generated snapshots must:

- be written only when explicitly requested;
- use explicit output paths;
- document included sections;
- include a schema version;
- preserve unavailable values;
- avoid complete environments by default;
- avoid being committed accidentally;
- be treated as potentially confidential.

The repository ignores generated snapshot locations.

Only sanitized, reviewed snapshots may be committed as fixtures.

## 10. Fixture policy

Committed fixtures must be deterministic and sanitized.

Fixtures must not contain:

- real authentication tokens;
- real passwords;
- private keys;
- production hostnames;
- personal home-directory details unless fictionalized;
- real customer or organization data;
- uncontrolled process environments;
- sensitive command-line values.

Fixture capture scripts must write first to an ignored location.

A human review is required before captured data is moved into a tracked fixture
directory.

## 11. Logging and diagnostics

Diagnostics must provide enough information to debug failures without exposing
unnecessary sensitive data.

Diagnostics should prefer:

- process identifier;
- interface name;
- error category;
- operating-system error code;
- concise context.

Diagnostics should avoid printing:

- full environments;
- entire command lines unless requested;
- arbitrary file contents;
- secret-looking values;
- large unbounded procfs input.

Verbose mode may provide additional context but must still respect the privacy
policy.

## 12. Permission outcomes

ProcLens must distinguish at least:

- permission denied;
- process not found;
- process exited during inspection;
- interface unavailable;
- malformed content;
- I/O failure;
- partial result.

A denied section must not be represented as:

- zero;
- empty;
- successful;
- unsupported without evidence.

Partial results should preserve successfully collected information.

## 13. Root and elevated privileges

Normal ProcLens operation must not require root.

Some users may choose to run ProcLens with elevated privileges, but the project
must clearly warn that elevated access can reveal substantially more sensitive
information.

Documentation must not present root execution as the standard fix for denied
access.

ProcLens must never attempt to obtain elevated privileges itself.

## 14. Security-setting policy

ProcLens must not automatically change:

- Yama `ptrace_scope`;
- procfs `hidepid` settings;
- Linux capabilities;
- SELinux policy;
- AppArmor policy;
- container security profiles;
- namespace configuration;
- file permissions.

The tool may explain that such policies affect visibility, but it must not
weaken them.

## 15. Output policy

Human-readable and JSON output must:

- preserve unavailable values explicitly;
- avoid implying denied values are zero;
- use stable field names;
- identify units;
- indicate partial results;
- avoid uncontrolled terminal escape sequences from inspected text;
- support future no-color and machine-readable modes.

Inspected process text must be escaped or sanitized appropriately for its output
format.

## 16. Terminal safety

Process names, command lines, and paths may contain unusual or control
characters.

Terminal presentation must eventually:

- escape non-printable characters;
- prevent inspected text from injecting terminal control sequences;
- avoid interpreting process data as formatting instructions;
- keep table layout stable;
- provide raw data only through clearly documented machine-readable output.

## 17. Version-control policy

Before every commit, the project engineer must inspect:

```text
git status
git diff --cached
```

Generated snapshots, captured procfs directories, logs, traces, and profiler
artifacts must not enter Git unless intentionally sanitized and reviewed.

The `.gitignore` file is a safeguard, not a substitute for staged-diff review.

## 18. Incident response

If sensitive information is committed accidentally:

1. stop further distribution;
2. identify the exposed information;
3. rotate or revoke affected secrets where necessary;
4. remove the material from the current tree;
5. determine whether Git history must be rewritten;
6. document the incident privately;
7. add a preventive test, ignore rule, or workflow control.

Deleting a file in a later commit does not remove it from earlier Git history.

## 19. Review checkpoints

Privacy and permissions must be reviewed before:

- command-line inspection;
- environment inspection;
- file-descriptor inspection;
- snapshot implementation;
- JSON serialization;
- terminal rendering;
- fixture capture;
- Project 2 executable-path integration;
- public releases.

## 20. Milestone 0 policy conclusion

Milestone 0 establishes the privacy and permission boundaries before process
inspection begins.

No substantive procfs implementation is authorized until:

- sensitive information is identified;
- generated artifacts are ignored;
- permission denial is modeled explicitly;
- partial results are required;
- shell execution from inspected data is prohibited;
- environment collection is disabled by default;
- fixture sanitization requirements are documented.
