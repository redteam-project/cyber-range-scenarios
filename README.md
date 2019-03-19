# cyber-range-scenarios
Training scenarios for cyber ranges

## Available scenarios

| Scenario name | Primary OS Type | OS Versions | Vulns | CVEs |
| --- | --- | --- | --- | --- |
| [Shell Shock example](scenarios/linux/01_shell_shock_example/README.md) | Linux | RHEL 7 | Shell Shock | CVE-2014-6271 |

## Design Philosophy

We're building the plane while we fly it, here, but these are the general design principals we're trying to follow.

* For cloud frameworks, use the native automation language, i.e., for [Google Cloud Platform](https://cloud.google.com), use [Deployment Manager](https://cloud.google.com/deployment-manager)
  * Rationale: 3rd party automation frameworks will always be behind what the cloud provider is offering, so just stick with the native capability
* For cloud workloads, i.e., VMs, containers, etc., use [Ansible](https://www.ansible.com)
  * Rationale: Most OSes are not tightly coupled to the cloud platform. Debian is Debian, Windows is Windows. Here it makes sense to use a standardized 3rd party tool like Ansible that won't be impacted by underlying cloud implementations.
