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
    CayleyDickson.swift                      -- Cayley-Dickson construction (Algebra marker protocol, CayleyDickson type)
    ContinuedFractions.swift                 -- Fraction, GCFConvergent (CF convergents), LeibnizPartialSum (Leibniz series), Matrix2x2, Mat2, Sqrt2MatStep (matrix construction)
    Fibonacci.swift                          -- FibState, FibVerified, Fib0, FibStep (Fibonacci recurrence witnesses)
    AdditionTheorems.swift                   -- universal addition theorems (AddLeftZero, SuccLeftAdd, AddCommutative, AddAssociative via ProofSeed)
    MultiplicationTheorems.swift             -- universal multiplication theorems (MulLeftZero)
    Macros.swift                             -- macro declarations (@ProductConformance, @FibonacciProof, @PiConvergenceProof, @GoldenRatioProof, @Sqrt2ConvergenceProof)
  AbuseOfNotationMacros/                     -- .macro target: compiler plugin
    Plugin.swift                             -- CompilerPlugin entry point
    ProductConformanceMacro.swift            -- @ProductConformance(n) (peer macro for inductive multiplication)
    FibonacciProofMacro.swift                -- @FibonacciProof(upTo:) (member macro generating Fibonacci witness chains)
    PiConvergenceProofMacro.swift            -- @PiConvergenceProof(depth:) (member macro generating Brouncker-Leibniz proof)
    GoldenRatioProofMacro.swift              -- @GoldenRatioProof(depth:) (member macro generating golden ratio CF/Fibonacci proof)
    Sqrt2ConvergenceProofMacro.swift         -- @Sqrt2ConvergenceProof(depth:) (member macro generating sqrt(2) CF/matrix proof)
    ProductChainGenerator.swift              -- shared product witness chain generator (used by Pi, GoldenRatio, Sqrt2 macros)
    Diagnostics.swift                        -- PeanoDiagnostic enum
  AbuseOfNotationClient/                     -- SPM executable: witness-based proofs
    main.swift                               -- witness constructions verified by compilation, type-level arithmetic assertions
    Experiment.swift                         -- Seed<A>, _InductiveAdd, _Rebase experiments
Tests/
  AbuseOfNotationMacrosTests/                -- macro expansion tests
    ProductConformanceMacroTests.swift
    FibonacciProofMacroTests.swift
    PiConvergenceProofMacroTests.swift
    GoldenRatioProofMacroTests.swift
    Sqrt2ConvergenceProofMacroTests.swift
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
- The `@FibonacciProof(upTo:)` macro generates Fibonacci witness chains as members of the attached type.
- The `@PiConvergenceProof(depth:)` macro generates the Brouncker-Leibniz correspondence proof as members, including CF convergents, Leibniz partial sums, product/sum witnesses, and type equality assertions.
- The `@GoldenRatioProof(depth:)` macro generates the golden ratio CF / Fibonacci correspondence proof, showing that CF [1;1,1,...] convergents h_n/k_n equal F(n+2)/F(n+1).
- The `@Sqrt2ConvergenceProof(depth:)` macro generates the sqrt(2) CF / matrix correspondence proof, showing that CF [1;2,2,...] convergents match iterated left-multiplication by [[2,1],[1,0]] via Sqrt2MatStep.
- Proof-generating macros use `@attached(member, names: arbitrary)` to scope generated types inside a namespace enum (e.g., `FibProof._Fib1`, `PiProof._CF1`).
- The macro is the proof SEARCH (arbitrary integer computation at compile time); the type checker is the proof VERIFIER (structural constraint verification).
- Universal theorems use conditional conformance as structural induction: a base case on `Zero`/`PlusZero` and an inductive step on `AddOne`/`PlusSucc`. Protocols use plain associated types (no `where` clauses) following the `_TimesNk` pattern to avoid rewrite system limits; correctness is enforced structurally by the conformance definitions.
- `AddLeftZero` proves `0 + n = n` for all n. `SuccLeftAdd` proves `a + b = c => S(a) + b = S(c)` for all proofs. `AddCommutative` proves `a + b = c => b + a = c` for all proofs (combines the first two).
- `ProofSeed<P>` is a `Natural`-conforming enum that wraps a `NaturalSum` proof as a base case for inductive proof extension. Analogous to `Seed<A>` but wraps a proof instead of a number.
- `AddAssociative` proves associativity: given P witnessing `a + b = d`, `AddOne^c(ProofSeed<P>).AssocProof = PlusSucc^c(P)` witnesses `a + (b + c) = d + c`. Universality is parametric over P and inductive over c.
- `MulLeftZero` proves `0 * n = 0` for all n. Uses plain associated types (no where clauses) like the addition theorems. The inductive step uses `TimesZeroLeft` (a derived lemma) instead of `TimesSucc`, because `TimesSucc`'s where clauses trigger rewrite system explosion when composed in inductive protocols.
- `TimesZeroLeft<MulProof>` is a derived witness encoding `0 * S(B) = 0` given `0 * B = 0`. It specializes the general multiplication step `A * S(B) = A*B + A` to `A = 0`, where the arithmetic simplifies to `0 + 0 = 0`, and encodes the result directly as a `NaturalProduct`.

## Branching

- `master` -- witness-based proofs, type-level arithmetic, structural type definitions.
- `witness-based-proofs` -- PR 1: paradigm shift from runtime computation to witness-based proofs.
- `macro-cleanup` -- PR 2: removes computational macros, Xcode target, updates docs.
- `continued-fractions` -- PR 3: golden ratio CF/Fibonacci and sqrt(2) CF/matrix correspondence proofs.
- `addition-associativity` -- PR for issue #29: associativity of addition via ProofSeed.
- `multiplication-theorems` -- PR for issue #30: universal multiplication theorems (MulLeftZero).
