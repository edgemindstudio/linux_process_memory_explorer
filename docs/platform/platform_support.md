# ProcLens Platform Support

## Document status

- Project: ProcLens
- Milestone: Milestone 0
- Status: Initial platform policy
- Primary development platform: Kali Linux under WSL2
- Required product platform: Modern Linux

## 1. Purpose

This document defines the initial operating-system and environment boundaries
for ProcLens.

ProcLens depends directly on Linux procfs and documented Linux interfaces.
Version 1 is therefore Linux-specific.

The project does not claim support for every Linux distribution, kernel
version, security policy, namespace arrangement, or virtualization platform.

## 2. Audited development environment

Milestone 0 was established in the following environment:

- distribution: Kali GNU/Linux Rolling 2026.1;
- distribution family: Debian;
- architecture: x86-64;
- kernel: `6.6.87.2-microsoft-standard-WSL2`;
- environment: WSL2;
- procfs mount: `/proc`;
- procfs filesystem type: `proc`;
- page size: 4,096 bytes;
- clock ticks per second: 100;
- visible logical processors during audit: 22;
- PID maximum boundary: 4,194,304;
- Yama `ptrace_scope`: 1.

These values describe the audited machine. They must not be hard-coded as
universal Linux constants.

## 3. Verified procfs interfaces

The following representative interfaces were available for the current shell
process during Milestone 0:

- `/proc/<pid>/stat`;
- `/proc/<pid>/status`;
- `/proc/<pid>/comm`;
- `/proc/<pid>/cmdline`;
- `/proc/<pid>/maps`;
- `/proc/<pid>/smaps`;
- `/proc/<pid>/smaps_rollup`;
- `/proc/<pid>/limits`;
- `/proc/<pid>/io`;
- `/proc/<pid>/sched`;
- `/proc/<pid>/task`;
- `/proc/<pid>/fd`;
- `/proc/<pid>/fdinfo`;
- `/proc/<pid>/exe`;
- `/proc/<pid>/cwd`.

Availability for one process does not guarantee access to the same interface
for every process. Permissions, lifecycle races, namespaces, kernel
configuration, and security policies may restrict access.

## 4. Native Linux support

Native Linux is the reference operating-system model for ProcLens.

Expected capabilities include:

- process enumeration through procfs;
- process and thread metadata;
- CPU counters;
- memory accounting;
- virtual-memory mappings;
- file descriptors;
- resource limits;
- I/O counters;
- page faults;
- context switches;
- symbolic links;
- process-tree construction.

Actual behavior may vary according to:

- kernel version;
- distribution patches;
- procfs mount options;
- Yama configuration;
- user permissions;
- Linux capabilities;
- PID namespaces;
- container isolation;
- cgroups;
- security modules such as SELinux or AppArmor.

ProcLens must report unavailable or denied information rather than assume that
all native Linux systems expose identical data.

## 5. WSL2 support

WSL2 is supported as a development and functional testing environment.

WSL2 provides:

- a real Linux kernel;
- Linux processes and threads;
- procfs;
- virtual-memory mappings;
- Linux system calls;
- standard Linux compilers and development tools.

Important limitations include:

- Windows host processes are not ordinary Linux procfs entries;
- visible resources may be virtualized;
- CPU and memory assignments may change;
- device behavior may differ from native Linux;
- Windows-mounted filesystems may have different semantics and performance;
- performance monitoring facilities may be restricted;
- kernel configuration and updates are controlled separately from the Linux
  distribution;
- NUMA, cgroup, namespace, and container behavior require separate validation.

WSL2 testing must not be described as proof of universal native-Linux behavior.

## 6. Repository location policy

Development repositories should reside in the Linux filesystem.

The audited repository location is:

```text
/home/fonke/linux_process_memory_explorer
```

This is preferred over `/mnt/c` because Linux-home storage provides more
predictable:

- symbolic-link behavior;
- permissions;
- case sensitivity;
- build performance;
- filesystem notifications;
- executable-file semantics;
- temporary-file behavior.

## 7. Container environments

Containers may expose a restricted or namespaced view of procfs.

Possible differences include:

- only container-visible processes;
- remapped or isolated PIDs;
- restricted file descriptors;
- masked procfs paths;
- cgroup-imposed CPU and memory limits;
- reduced capabilities;
- security profiles;
- host information being intentionally hidden.

Container support must be documented as environment-dependent.

ProcLens must not imply that a container-visible process list represents the
entire host.

## 8. Restricted environments

Restricted systems may deny access because of:

- ownership differences;
- Yama settings;
- procfs `hidepid` mount options;
- Linux capabilities;
- security modules;
- container policies;
- namespace boundaries;
- hardened kernel configurations.

ProcLens must:

- preserve permission-denied results;
- keep partial observations usable;
- avoid requiring root by default;
- avoid recommending privilege bypass;
- document which sections were unavailable.

## 9. Toolchain support

The audited local toolchain includes:

- Clang 21.1.8;
- GCC 15.2.0;
- CMake 4.3.3;
- Ninja 1.13.2;
- clang-format 21.1.8;
- clang-tidy 21.1.8;
- Cppcheck 2.20.0;
- LLDB 21.1.8;
- GDB 17.1;
- Valgrind 3.25.1;
- strace 7.0;
- Git 2.51.0;
- GitHub CLI 2.95.0.

These are audited versions, not minimum product requirements.

The build system should use a lower, documented CMake minimum that is suitable
for supported CI environments.

## 10. Performance-tool limitations

`perf` was not installed during the initial environment audit.

The available Kali `linux-perf` package targeted a different kernel series from
the active Microsoft WSL2 kernel.

Performance-counter validation is therefore deferred until the performance
milestone.

The project must not claim `perf` support merely because a userspace package can
be installed. Kernel support and permissions must also be verified.

## 11. Validation policy

Platform behavior will be validated through:

- local WSL2 testing;
- GitHub-hosted Linux runners;
- controlled procfs fixtures;
- controlled child-process tests;
- comparison with raw procfs;
- comparison with standard Linux utilities;
- native Linux testing where practical.

Platform-specific observations must record:

- distribution;
- kernel;
- architecture;
- virtualization or container environment;
- compiler;
- build type;
- relevant security restrictions.

## 12. Unsupported platforms

Version 1 does not support:

- Microsoft Windows process inspection;
- macOS process inspection;
- BSD procfs variants;
- Solaris process interfaces;
- remote process inspection;
- cross-platform abstraction over non-Linux process APIs.

The Windows host surrounding WSL2 is not a supported ProcLens inspection
target.

## 13. Compatibility claims

ProcLens may claim support only for environments that have been meaningfully
tested.

Documentation must distinguish:

- development environment;
- CI environment;
- experimentally tested environment;
- officially supported environment;
- known limitation;
- untested assumption.

No single successful build proves compatibility with every modern Linux
system.

## 14. Milestone 0 platform conclusion

The audited WSL2 environment is suitable for ProcLens Milestone 0 and later
development of the core procfs features.

The environment exposes the representative process, thread, memory, mapping,
descriptor, limit, I/O, and scheduler interfaces required by the project.

Native Linux, containers, restricted procfs mounts, and performance-counter
support remain separate validation responsibilities.
