# Constitution: <system>

Status: draft | approved
Scope: <packages/folders covered, plus tests and CI>

These are the non-negotiable principles for the project. A change that breaks one of them needs an ADR that amends this document first.

## Architectural principles
- **P-001: <short name>.** <Principle.> (<evidence: file or ADR link>)

## Testing strategy
- <frameworks, naming convention, where tests live>
- Every acceptance criterion in a spec is covered by at least one test, and the spec names that test.
- <CI gate>

## Conventions
- <language of code/docs, style, folder layout, commit format referencing REQ/TASK IDs>

## Versioning and release
- <versioning scheme, release trigger>

## Mandatory non-functional requirements
- **NFR-001:** <verifiable metric>

## Change process
1. Update or create `docs/specs/<capability>/spec.md`.
2. Write `plan.md` for non-trivial changes, and promote architectural decisions to an ADR.
3. Write `tasks.md` when the change spans more than one PR or task.
4. Implement with tests that name the REQ/AC they cover.

## Open questions
- [NEEDS CLARIFICATION: ...]
