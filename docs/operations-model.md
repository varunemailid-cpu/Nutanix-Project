# Operating Model

Use this repository as a field delivery workspace for NKP and NAI work.

## Delivery Lifecycle

1. Prepare the bastion and toolchain.
2. Copy the example environment file for the selected kit.
3. Replace placeholders with customer-specific values in the local ignored env file.
4. Run validation scripts before deployment.
5. Execute deployment or troubleshooting steps.
6. Save only sanitized learnings back into the repository.
7. Update changelog and documentation when the workflow improves.

## Roles

| Role | Responsibility |
| --- | --- |
| Deployment engineer | Runs scripts, validates outputs, and captures sanitized findings. |
| Reviewer | Checks scripts, templates, and safety before merge. |
| Maintainer | Curates roadmap, releases, and repository standards. |

## Evidence Collection

Capture sanitized evidence for issues and pull requests:

- Command run
- Expected result
- Actual result
- Version and platform context
- Sanitized logs or screenshots
- Decision or fix applied

## Field Notes Standard

Every new runbook should answer:

- When should I use this?
- What do I need before starting?
- What command do I run?
- What does success look like?
- What should I check when it fails?
