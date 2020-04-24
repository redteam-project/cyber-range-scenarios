# Cyber Range Scenarios
Training scenarios for cloud-based cyber ranges, initially focused on utilizing [Google Cloud Platform](https://cloud.google.com)

## Available scenarios

| Scenario name | Primary OS Type | OS Versions | Vulns | CVEs |
| --- | --- | --- | --- | --- |
| [Shell Shock example](scenarios/linux/01_shell_shock_example) | Linux | RHEL 7 | Shell Shock, libfutex | CVE-2014-6271, CVE-2014-3153 |
| [overlayfs example](scenarios/linux/02_overlayfs) | Linux | Ubuntu 14.04 | 'overlayfs' Local Privilege Escalation | CVE-2015-1328 |

## Design Philosophy

We're building the plane while we fly it, here, but these are the general design principals we're trying to follow.

* For cloud frameworks use open source Infrastructure as Code tools to provision and manage the cloud infrastructure [Terraform](https://www.terraform.io/)
  * Rationale: Although Terraform build scripts are still very platform dependent, there is a much greater chance of reuse with other platforms versus platform specific build tools.
* For cloud workloads, i.e., VMs, containers, etc., use [Ansible](https://www.ansible.com)
  * Rationale: Most OSes are not tightly coupled to the cloud platform. Debian is Debian, Windows is Windows. Here it makes sense to use a standardized 3rd party tool like Ansible that won't be impacted by underlying cloud implementations.
