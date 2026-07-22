# Security Gatekeeper

A lightweight Bash-based security scanning tool that helps identify potential vulnerabilities in shell scripts before they reach production.

## Problem

While working on a deployment workflow, a security issue was discovered where a shell script contained a hardcoded password. The script would have successfully passed the CI pipeline because there were no execution errors, but the exposed credential created a security risk.

This led to the idea of building **Security Gatekeeper** — a simple tool that acts as an additional security layer before deployment by scanning scripts and warning developers about possible vulnerabilities.

---

## What does Security Gatekeeper do?

Security Gatekeeper scans shell scripts and checks for common security issues such as:

* Hardcoded passwords
* Exposed API keys
* Tokens and sensitive credentials
* Unsafe scripting practices
* Potential security risks before deployment

Instead of blocking the pipeline completely, it provides warnings so developers can review and fix issues before releasing code.

---

## Why use Security Gatekeeper?

Traditional CI pipelines mainly verify whether an application builds or runs successfully. They may not detect insecure coding practices.

Security Gatekeeper helps by:

* Adding an extra security check before deployment
* Detecting accidental credential exposure
* Reducing the chance of sensitive information reaching production
* Providing simple security feedback without complex dependencies

---

## Features

* Lightweight Bash implementation
* Zero external dependencies
* Works with Linux, macOS, Docker, and WSL
* Generates security scan reports
* Uses native POSIX utilities
* Easy integration with CI/CD pipelines

---

## Requirements

* Bash 4.0 or higher
* POSIX-compatible environment

Required utilities:

* `find`
* `grep`
* `mkdir`
* `date`
* `read`

No third-party security scanners are required.

---

## How to Run

### 1. Give execution permission

```bash
chmod +x security_gatekeeper.sh
```

### 2. Run the security scan

```bash
./security_gatekeeper.sh
```

or

```bash
bash security_gatekeeper.sh
```

---

## Output

After scanning, the tool generates reports containing:

* Detected security warnings
* Possible credential leaks
* Scan summary

Reports are stored in:

```
.gatekeeper_logs/
```

---

## Customization

By default, the scanner checks files from the current directory.

To scan a specific project folder, update the scanning path.

Example:

```bash
find ./src -type f
```

instead of:

```bash
find . -type f
```

---

## Future Improvements

* Add severity levels (Low, Medium, High)
* Add Git pre-commit hook support
* Add automatic CI/CD pipeline integration
* Generate HTML security reports
* Add support for more programming languages

---

## License

This project is built for learning and demonstrates Bash scripting, Linux automation, and DevSecOps practices and learnings.
