# Git Workflow Rules

## Branch Naming

```
feature/[issue-id]-short-description
bugfix/[issue-id]-short-description
hotfix/[issue-id]-short-description
refactor/short-description
docs/short-description
```

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `docs`: Documentation
- `test`: Adding tests
- `chore`: Maintenance

### Examples
```
feat(auth): add JWT token refresh
fix(api): handle null response gracefully
refactor(utils): simplify date formatting
```

## Commit Rules

- One logical change per commit
- Keep commits small and focused
- Write meaningful commit messages
- Never commit directly to main/master

## Pull Request Guidelines

- Link related issues
- Write clear description
- Include test plan
- Request appropriate reviewers
- Address all review comments

## Protected Branches

```
main/master - production code
develop - integration branch

Rules:
- Require PR reviews
- Require status checks
- No force push
```

## Before Committing

```bash
# Check status
git status

# Review changes
git diff

# Stage specific files (not git add .)
git add <specific-files>

# Run pre-commit checks
npm run lint
npm test
```
