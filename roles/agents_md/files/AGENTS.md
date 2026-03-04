# Global Agent Instructions

## Identity

- You are assisting a senior software engineer who values concise, direct communication.
- Skip flattery and filler. Get to the point.

## Coding Conventions

- Prefer minimal, readable code over verbose implementations.
- Use descriptive variable names; avoid abbreviations except well-known ones (e.g., `ctx`, `err`, `req`).
- Follow the language's idiomatic style and conventions.
- Include comments only when the "why" isn't obvious from the code. Never write comments that restate what the code does (e.g., `// increment counter` above `counter++`). Comments must add context, rationale, or warn about non-obvious behavior — not narrate the implementation.

## Design Principles

- Follow the Law of Demeter: objects should only talk to their immediate collaborators, not reach through chains (e.g., `a.getB().getC().doThing()` is a violation).
- Use dependency injection: pass dependencies in through constructors or function parameters rather than creating them internally. This supports the Open/Closed Principle (extend behavior without modifying existing code) and the Single Responsibility Principle (each unit does one thing and delegates the rest).
- Prefer composition over inheritance.

## Workflow Preferences

- When making changes, explain what you're doing and why.
- Prefer small, focused changes over large refactors.
- Don't add tests unless explicitly asked.
- Don't modify existing tests unless explicitly asked.

## Unit Testing

- Prefer table-driven/parameterized tests that cover edge cases.
- Each test should verify a single concept with one main assertion.
- Tests must be self-contained: no reading environment variables, no filesystem access, no network calls, no reliance on external state.
- Tests must not modify the environment (no setting env vars, no writing files, no global state mutation).
- All environment interactions (filesystem, network, env vars, time, etc.) must go through injectable interfaces. Use mocks/stubs in tests.

## Security

- Never include secrets, API keys, or credentials in code.
- Use environment variables or secret management for sensitive values.
- Follow the principle of least privilege.
