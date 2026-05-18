# Contributing

Thank you for improving this Nutanix deployment toolkit. The goal is to keep every contribution operationally useful, safe to share, and easy to reuse in customer environments.

## Contribution Guidelines

- Use placeholders for all project-specific values.
- Never commit credentials, API keys, kubeconfigs, private certificates, signed URLs, or customer IP plans.
- Keep scripts idempotent where possible and fail early when required variables are missing.
- Prefer clear runbook steps over clever automation.
- Add validation commands for every deployment command.
- Update `CHANGELOG.md` when a user-facing workflow changes.

## Local Checks

Run:

```sh
./scripts/validate_repository.sh
```

This checks shell syntax, JSON syntax, YAML syntax, and common secret patterns.

## Pull Request Checklist

- Explain the operational use case.
- Link any related issue.
- Confirm examples use placeholders.
- Confirm generated files are not committed.
- Include validation output or a short validation summary.

## Documentation Style

- Write for an engineer working from a bastion during a real deployment.
- Keep commands copyable.
- Include what success looks like.
- Include the next troubleshooting step when a command fails.
- Avoid customer names unless the file is private and explicitly intended for that customer.
