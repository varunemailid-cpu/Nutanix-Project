# Release Process

Use releases to mark stable versions of the toolkit.

## Versioning

Use semantic versioning:

- `MAJOR`: Breaking script or workflow changes
- `MINOR`: New runbooks, scripts, templates, or checks
- `PATCH`: Fixes and clarifications

## Release Checklist

1. Run repository validation:

```sh
./scripts/validate_repository.sh
```

2. Review staged changes:

```sh
git diff --stat
git diff --cached --stat
```

3. Update `CHANGELOG.md`.
4. Commit changes.
5. Tag the release:

```sh
git tag -a v0.2.0 -m "Release v0.2.0"
```

6. Push branch and tags:

```sh
git push origin main
git push origin v0.2.0
```

## Release Notes

Release notes should include:

- What changed
- Who should use it
- Validation performed
- Any known risks or required follow-up
