# ADR-0003: Linux-only scope and WSL2 support boundary

- Status: Accepted
- Date: 2026-07-26
- Decision owners: Project engineer and lead execution engineer

## Context

ProcLens depends directly on Linux procfs and documented Linux interfaces for
process, thread, virtual-memory, resource, descriptor, and runtime inspection.

The primary development environment is Kali Linux running under WSL2.

A decision is required about whether ProcLens should:

1. target multiple operating systems from the beginning;
2. target Linux while treating WSL2 as a supported development environment;
3. target only the exact audited WSL2 environment.

The project must distinguish between:

- operating-system scope;
- development environment;
- CI environment;
- experimentally validated environment;
- officially supported environment.

## Decision drivers

- Procfs is central to the project’s learning objectives.
- Linux process interfaces differ fundamentally from Windows and macOS APIs.
- Cross-platform abstraction would add substantial non-core complexity.
- WSL2 provides a real Linux kernel and usable procfs.
- WSL2 differs from native Linux in resources, devices, filesystems, and kernel
  configuration.
- The project must make conservative compatibility claims.
- GitHub-hosted Linux runners can supplement local WSL2 testing.
- Native Linux and container behavior require separate validation.
- Platform-specific restrictions must remain visible.
- Milestone 0 must avoid hard-coding audited machine values.

## Options considered

### Option 1 — Cross-platform support from the beginning

ProcLens could define a generic process-inspection interface and implement
separate backends for:

- Linux;
- Windows;
- macOS;
- BSD-family systems.

Advantages:

- broader theoretical user base;
- common high-level interface;
- future portability work begins early;
- some domain concepts could be shared.

Disadvantages:

- operating systems expose very different process models;
- Linux-specific learning objectives would be diluted;
- platform abstractions could collapse important procfs semantics;
- implementation and testing scope would expand substantially;
- Windows and macOS development environments would be required;
- lowest-common-denominator models could weaken the design;
- Milestone 0 would become unnecessarily complex.

### Option 2 — Linux-only product with WSL2 development support

ProcLens can target Linux interfaces directly and support WSL2 as a development
and functional testing environment.

Advantages:

- architecture remains faithful to Linux procfs;
- project scope stays aligned with systems-learning goals;
- local development can use the audited WSL2 environment;
- Linux CI can provide additional validation;
- native Linux and container testing can be added deliberately;
- platform-specific behavior remains explicit;
- no premature cross-platform abstraction is required.

Disadvantages:

- Windows host processes cannot be inspected;
- macOS and BSD users cannot run Version 1 natively;
- WSL2-specific behavior may differ from native Linux;
- additional environments are required before broad compatibility claims;
- performance-tool support may be limited under WSL2.

### Option 3 — Support only the exact audited WSL2 environment

ProcLens could claim support only for Kali Linux 2026.1 under the audited
Microsoft WSL2 kernel.

Advantages:

- extremely narrow and easily described scope;
- no immediate need to reason about other Linux environments;
- local behavior is directly reproducible by the project engineer.

Disadvantages:

- unnecessarily restrictive;
- GitHub Linux CI would fall outside the stated scope;
- procfs is not unique to WSL2;
- the project would fail to recognize native Linux as the reference model;
- the portfolio value would be reduced;
- valid Linux portability work would be discouraged.

## Decision

ProcLens Version 1 will be Linux-specific.

Native Linux is the reference operating-system model.

WSL2 is supported as:

- the primary development environment;
- a functional testing environment;
- a source of valid Linux procfs observations;
- a practical environment for build, test, sanitizer, and static-analysis work.

WSL2 validation must not be presented as proof of universal native-Linux
compatibility.

The initial platform model is:

```text
Linux product scope
    ├── WSL2 development and functional testing
    ├── GitHub-hosted Linux CI
    ├── native Linux validation where practical
    └── container-specific validation when introduced
```

Version 1 will not implement native process-inspection backends for:

- Microsoft Windows;
- macOS;
- BSD systems;
- Solaris;
- other non-Linux operating systems.

## Rationale

Linux-only scope best supports the project mission.

ProcLens is intended to expose and explain Linux process and virtual-memory
interfaces rather than hide them behind a cross-platform abstraction.

Supporting WSL2 is appropriate because WSL2 provides:

- a real Linux kernel;
- Linux processes;
- procfs;
- Linux system calls;
- standard Linux compilers and tools.

However, WSL2 differs from native Linux in important areas such as:

- visibility of Windows host processes;
- virtualized CPU and memory resources;
- kernel configuration;
- devices;
- performance counters;
- Windows-mounted filesystem behavior;
- container and namespace validation.

The project therefore treats WSL2 as a valid Linux environment with documented
limitations, not as a universal substitute for every Linux deployment.

## Consequences

### Positive consequences

- The project remains focused on Linux systems engineering.
- Procfs behavior can be modeled directly.
- No artificial cross-platform abstraction is required.
- Local WSL2 development remains valid.
- Linux CI can provide clean-checkout verification.
- Platform limitations remain documented.
- Native Linux support can improve incrementally through evidence.
- Audited machine values are not treated as universal constants.

### Negative consequences

- Version 1 cannot inspect Windows host processes.
- Non-Linux operating systems are unsupported.
- WSL2 testing cannot validate all native-Linux behavior.
- Additional environments are required for broader support claims.
- Performance validation may require a native Linux system.
- Container and namespace behavior require separate work.

### Neutral or operational consequences

- Platform documentation must record distribution, kernel, architecture, and
  virtualization context.
- Page size and clock ticks must be queried at runtime.
- Kernel-specific fields must be treated as optional where appropriate.
- CI success proves only the tested runner configuration.
- Container-visible processes must not be described as the full host process
  set.
- Repository development should remain under the Linux filesystem rather than
  `/mnt/c`.

## Rejected alternatives

Cross-platform support was rejected because it would add major design,
implementation, and testing complexity while weakening the project’s direct
Linux focus.

Support for only the exact audited WSL2 environment was rejected because native
Linux is the actual reference operating-system model and the architecture should
remain portable across meaningfully tested Linux environments.

## Review triggers

Review this ADR when:

- a non-Linux backend becomes a formal product requirement;
- native Linux testing reveals an architectural incompatibility;
- WSL2 no longer exposes required Linux interfaces;
- container support becomes an official compatibility claim;
- namespace or cgroup behavior changes the domain model;
- performance work requires kernel facilities unavailable under WSL2;
- supported distribution or kernel minimums are established;
- the project introduces platform-specific source trees.

## Related documents

- `docs/project_charter.md`
- `docs/architecture/system_architecture.md`
- `docs/platform/platform_support.md`
- `docs/development/testing_strategy.md`
- `docs/security/risk_register.md`
