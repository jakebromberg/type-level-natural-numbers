# Project overview

A single-file Swift project (`type-level-natural-numbers/main.swift`) that encodes the integers as types using the Peano axioms and implements arithmetic and comparison via existential metatypes.

## Building and testing

This is an Xcode command-line tool project. Build and run with:

```sh
xcodebuild -project type-level-natural-numbers.xcodeproj -scheme type-level-natural-numbers -configuration Debug build
```

Or open the `.xcodeproj` in Xcode and run. There is no separate test target -- correctness is verified by `assert` statements that execute when the program runs. A clean run with no assertion failures means all checks pass.

## Code conventions

- All code lives in a single file: `type-level-natural-numbers/main.swift`.
- Integers are represented as types (`Zero`, `AddOne<N>`, `SubOne<N>`) conforming to protocols in the `Integer` hierarchy.
- The protocol hierarchy is: `Integer` (root) -> `Natural`/`Nonpositive` -> `Positive`/`Negative`. `Zero` conforms to both `Natural` and `Nonpositive`.
- Runtime values are existential metatypes (`any Integer.Type`, `any Natural.Type`, `any Positive.Type`, etc.).
- Operator overloads use the tightest return type possible (e.g. `Positive + Natural -> Positive`).
- Recursive definitions follow Peano-style induction: base case on `Zero`, inductive step via `predecessor`/`successor`.
- Zero is detected by casting (`as? any Positive.Type`, `as? any Negative.Type`) rather than optional checks.
- Assertions serve as inline tests and are grouped immediately after the code they exercise.

## Branching

- `master` -- runtime arithmetic (addition, multiplication, comparison).
- `worktree-type-level-arithmetic` -- extends master with compile-time type-level arithmetic (`Sum`, `Product`, `NaturalExpression`, `assertEqual`).
- `worktree-integer-extension` -- extends master with negative numbers via `SubOne`, negation, subtraction, and integer-level arithmetic.
