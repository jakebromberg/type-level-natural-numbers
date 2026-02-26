# Project overview

A Swift project that encodes the natural numbers as types using the Peano axioms. Arithmetic facts are proved by constructing witness types whose existence demonstrates the relationship. Compilation is the proof.

## Project structure

```
Package.swift                                -- SPM package definition
Sources/
  AbuseOfNotation/                           -- library: types, witnesses, type-level arithmetic
    PeanoTypes.swift                         -- protocols (Integer, Natural, Nonpositive), Zero, AddOne, SubOne, assertEqual
    Witnesses.swift                          -- witness protocols and constructors (NaturalSum, NaturalProduct, NaturalLessThan)
    TypeLevelArithmetic.swift                -- NaturalExpression, type aliases (N0-N105), Sum, Product, _TimesNk protocols
    ChurchNumerals.swift                     -- Church numeral encoding (ChurchNumeral, ChurchZero, ChurchSucc, ChurchAdd, ChurchMul)
    CayleyDickson.swift                      -- Cayley-Dickson construction (Algebra marker protocol, CayleyDickson type)
    ContinuedFractions.swift                 -- Fraction, GCFConvergent (CF convergents), LeibnizPartialSum (Leibniz series)
    Macros.swift                             -- @ProductConformance macro declaration
  AbuseOfNotationMacros/                     -- .macro target: compiler plugin
    Plugin.swift                             -- CompilerPlugin entry point
    ProductConformanceMacro.swift            -- @ProductConformance(n) implementation (peer macro for inductive multiplication)
    Diagnostics.swift                        -- PeanoDiagnostic enum
  AbuseOfNotationClient/                     -- SPM executable: witness-based proofs
    main.swift                               -- witness constructions verified by compilation, type-level arithmetic assertions
Tests/
  AbuseOfNotationMacrosTests/                -- macro expansion tests
    ProductConformanceMacroTests.swift
```

## Building and testing

```sh
swift build                      # compile (compilation = proof)
swift run AbuseOfNotationClient  # exits cleanly (no runtime computation)
swift test                       # run macro expansion tests
```

### Testing conventions

- Arithmetic correctness is verified by witness construction: if the types compile, the proof is valid.
- `assertEqual<T: Integer>(_: T.Type, _: T.Type)` asserts type equality at compile time (empty body -- compilation is the assertion).
- Macro expansion correctness is verified by `assertMacroExpansion` in `swift test`.
- A clean `swift build && swift run AbuseOfNotationClient && swift test` means all checks pass.

## Code conventions

- Integers are represented as types (`Zero`, `AddOne<N>`, `SubOne<N>`) conforming to protocols in the `Integer` hierarchy.
- The protocol hierarchy has 3 protocols: `Integer` (root) -> `Natural` and `Nonpositive`. `Zero` conforms to both `Natural` and `Nonpositive`.
- Type aliases `N0` through `N9` provide convenient shorthand for small naturals.
- Witness protocols (`NaturalSum`, `NaturalProduct`, `NaturalLessThan`) encode arithmetic relationships as associated type constraints.
- Witness constructors follow Peano axioms: base case (e.g. `PlusZero<N>` for `N + 0 = N`) and inductive step (e.g. `PlusSucc<Proof>` for `A + S(B) = S(C)` given `A + B = C`).
- `TimesSucc` composes a product witness with a sum witness via `where` constraints, encoding `a * S(b) = a*b + a`.
- Type-level `Sum` and `Product` use constrained extensions for small left operands.
- The `@ProductConformance(n)` macro generates inductive protocols and conformances for `Product`.

## Branching

- `master` -- witness-based proofs, type-level arithmetic, structural type definitions.
- `witness-based-proofs` -- PR 1: paradigm shift from runtime computation to witness-based proofs.
- `macro-cleanup` -- PR 2: removes computational macros, Xcode target, updates docs.
