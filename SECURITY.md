# Security Policy

## Sensitive Data Rules

Do not commit:

- Passwords, tokens, API keys, or NGC keys
- Kubeconfigs
- Private keys or generated certificates
- Signed download URLs
- Customer IP plans, hostnames, or private registry URLs
- Raw customer logs that include sensitive values

Use placeholders such as `CHANGE_ME_PRISM_CENTRAL`, `CHANGE_ME_TOKEN`, and `CHANGE_ME_CLUSTER_NAME`.

## Reporting Security Issues

Do not open a public issue with secrets or customer-sensitive data.

If a secret is accidentally committed:

1. Revoke or rotate the secret immediately.
2. Remove the value from the repository.
3. Review logs and workflow output for exposure.
4. Document the fix using sanitized language.

## Supported Branch

Security fixes are applied to `main`.

## Recommended Local Checks

Run before publishing:

```sh
./scripts/validate_repository.sh
```
