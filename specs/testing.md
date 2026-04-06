# Testing Rules

## Coverage Requirements

| Type | Minimum | Target |
|:---|:---|:---|
| Unit Tests | 70% | 85% |
| Integration | 50% | 70% |
| E2E | Critical paths | Happy paths |

## Test Structure

```
Arrange → Act → Assert

describe('Component/Function', () => {
  describe('method/feature', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

## Naming Convention

```
Test files: *.test.ts, *.spec.ts
Test names: "should [verb] when [condition]"
```

## What to Test

### Must Test
- Business logic
- Edge cases
- Error handling
- Public APIs

### Don't Over-Test
- Implementation details
- Third-party libraries
- Simple getters/setters
- Framework internals

## Mocking Guidelines

- Mock external dependencies
- Avoid mocking internal modules
- Use factories for test data
- Reset mocks between tests

## Verification Commands

```bash
# Unit tests
npm test

# Coverage report
npm test -- --coverage

# Integration tests
npm run test:integration

# E2E tests
npm run test:e2e
```
