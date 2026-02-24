# Project overview

A Swift project that encodes the integers as types using the Peano axioms and implements arithmetic and comparison via existential metatypes, with Swift macros for compile-time arithmetic.

## Project structure

The project has both an Xcode command-line tool and an SPM package:

```
Package.swift                            -- SPM package definition
type-level-natural-numbers.xcodeproj     -- Xcode project (standalone, does not use SPM)
type-level-natural-numbers/main.swift    -- Xcode target entry point (convenience bindings, assertions, type-level arithmetic)
Sources/
  PeanoNumbers/                          -- library: types, operators, macro declarations
    PeanoTypes.swift                     -- protocols, Zero, AddOne, SubOne, operators, assertEqual
    ChurchNumerals.swift                 -- Church numeral encoding (ChurchNumeral, ChurchZero, ChurchSucc, ChurchAdd, ChurchMul)
    CayleyDickson.swift                  -- Cayley-Dickson construction (Algebra, AlgebraValue, CayleyDickson, gaussian, quaternion, sign-parameterized multiply/norm)
    Macros.swift                         -- @freestanding macro declarations
  PeanoNumbersMacros/                    -- .macro target: compiler plugin
    Plugin.swift                         -- CompilerPlugin entry point
    PeanoMacro.swift                     -- #Peano(n) implementation
    PeanoTypeMacro.swift                 -- #PeanoType(expr) implementation
    PeanoAssertMacro.swift               -- #PeanoAssert(expr) implementation
    ChurchMacro.swift                    -- #Church(n) implementation
    GaussianMacro.swift                  -- #Gaussian(re, im) implementation
    ExpressionEvaluator.swift            -- shared arithmetic/algebra evaluator (EvalValue, evaluateAlgebraExpression)
    Diagnostics.swift                    -- PeanoDiagnostic enum, SimpleDiagnosticMessage
  PeanoNumbersClient/                    -- SPM executable: exercises everything
    main.swift                           -- convenience bindings, runtime + compile-time assertions
Tests/
  PeanoNumbersMacrosTests/               -- macro expansion tests
    PeanoMacroTests.swift
    PeanoTypeMacroTests.swift
    PeanoAssertMacroTests.swift
    ChurchMacroTests.swift
    GaussianMacroTests.swift
```

## Building and testing

### SPM (primary)

```sh
swift build                  # compile everything (compile-time assertions verified here)
swift run PeanoNumbersClient # run all runtime assertions
swift test                   # run macro expansion tests
```

### Xcode (standalone)

```sh
xcodebuild -project type-level-natural-numbers.xcodeproj -scheme type-level-natural-numbers -configuration Debug build
```

The Xcode target is self-contained -- it does not depend on the SPM package. It compiles the shared library sources (PeanoTypes.swift, CayleyDickson.swift, ChurchNumerals.swift) directly, and main.swift adds convenience bindings, representative assertions, and Xcode-exclusive type-level arithmetic (NaturalExpression, Sum, Product).

### Testing conventions

- Runtime correctness is verified by `assert` statements in the executable targets.
- Macro expansion correctness is verified by `assertMacroExpansion` in `swift test`.
- A clean `swift build && swift run PeanoNumbersClient && swift test` means all checks pass.

## Code conventions

- Integers are represented as types (`Zero`, `AddOne<N>`, `SubOne<N>`) conforming to protocols in the `Integer` hierarchy.
- The protocol hierarchy has 3 protocols: `Integer` (root) -> `Natural` and `Nonpositive`. `Zero` conforms to both `Natural` and `Nonpositive`.
- Runtime values are existential metatypes (`any Integer.Type`, `any Natural.Type`, `any Nonpositive.Type`).
- Operator overloads use the tightest return type available (e.g. `Natural + Natural -> Natural`, `Integer + Integer -> Integer`).
- All operators use right-hand recursion (standard Peano form): base case when `rhs == Zero`, inductive step peels the successor off the right operand.
- Zero is detected by `== Zero.self` comparison. Non-zero naturals are detected by `as? any Natural.Type` cast after excluding zero.
- Assertions serve as inline tests and are grouped immediately after the code they exercise.

## Branching

- `master` -- runtime arithmetic (addition, multiplication, comparison).
- `worktree-type-level-arithmetic` -- extends master with compile-time type-level arithmetic (`Sum`, `Product`, `NaturalExpression`, `assertEqual`).
- `worktree-integer-extension` -- extends master with negative numbers via `SubOne`, negation, subtraction, and integer-level arithmetic.
- `worktree-macros` -- extends integer-extension with Swift macros (`#Peano`, `#PeanoType`, `#PeanoAssert`) for compile-time arithmetic.
- `worktree-simplify-protocols` -- extends macros: simplifies to 3 protocols, switches to right-hand recursion, adds `<=`/`>=`.
- `worktree-arithmetic-extensions` -- extends simplify-protocols: adds exponentiation, monus, division/modulo, factorial, fibonacci, GCD; extends macro evaluator.
- `worktree-advanced-extensions` -- extends arithmetic-extensions: adds hyperoperation, Ackermann function, Church numeral encoding with `#Church` macro.
- `worktree-cayley-dickson` -- extends advanced-extensions: adds Cayley-Dickson construction (Algebra protocol, AlgebraValue, CayleyDickson type, Gaussian integers, quaternions).
- `worktree-cayley-dickson-macros` -- extends cayley-dickson: adds `#Gaussian` macro, sign-parameterized multiplication/norm (split-complex, dual numbers), and Cayley-Dickson evaluator for `#PeanoAssert`.
- `worktree-cleanup-refactoring` -- extends master: consolidates evaluator code, adds library-level `one` constant, relocates diagnostic type, deduplicates Xcode target.
