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
    MultiplicationTheorems.swift             -- flat multiplication witnesses (TimesTick, TimesGroup), universal theorems (MulLeftZero, SuccLeftMul, MulComm)
    Streams.swift                            -- CFStream protocol, periodic irrationals (PhiCF, Sqrt2CF), unfold theorems, assertStreamEqual
    Macros.swift                             -- macro declarations (@ProductConformance, @FibonacciProof, @PiConvergenceProof, @GoldenRatioProof, @Sqrt2ConvergenceProof, @MulCommProof)
  AbuseOfNotationMacros/                     -- .macro target: compiler plugin
    Plugin.swift                             -- CompilerPlugin entry point
    ProductConformanceMacro.swift            -- @ProductConformance(n) (peer macro for inductive multiplication)
    FibonacciProofMacro.swift                -- @FibonacciProof(upTo:) (member macro generating Fibonacci witness chains)
    PiConvergenceProofMacro.swift            -- @PiConvergenceProof(depth:) (member macro generating Brouncker-Leibniz proof)
    GoldenRatioProofMacro.swift              -- @GoldenRatioProof(depth:) (member macro generating golden ratio CF/Fibonacci proof)
    Sqrt2ConvergenceProofMacro.swift         -- @Sqrt2ConvergenceProof(depth:) (member macro generating sqrt(2) CF/matrix proof)
    MulCommProofMacro.swift                  -- @MulCommProof(leftOperand:depth:) (member macro generating paired commutativity proofs)
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
    MulCommProofMacroTests.swift
```

## Building and testing

```sh
swift build                      # compile (compilation = proof)
swift run AbuseOfNotationClient  # exits cleanly (no runtime computation)
swift test                       # run macro expansion tests
```

### Testing conventions

- Arithmetic correctness is verified by witness construction: if the types compile, the proof is valid.
- `assertEqual<T: Integer>(_: T.Type, _: T.Type)` asserts type equality at compile time (empty body -- compilation is the assertion). `assertStreamEqual<T: CFStream>` does the same for stream types.
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
- The flat multiplication encoding (`TimesTick`/`TimesGroup`) decomposes each multiplication step into individual successor operations, like `PlusSucc` does for addition. This avoids `TimesSucc`'s where clauses, which trigger rewrite system explosion when composed in inductive protocols. The two encodings coexist -- both conform to `NaturalProduct`. `TimesSucc` is used by macro-generated proofs; the flat encoding enables universal theorems.
- `TimesTick<P>` adds 1 to Total (one successor within a "copy of Left"). No where clauses. `TimesGroup<P>` adds 1 to Right (one complete copy of Left added). No where clauses. For `a * b`, the proof has b groups of a ticks each.
- `MulLeftZero` proves `0 * n = 0` for all n. `ZeroTimesProof: NaturalProduct & SuccLeftMul` -- the strengthened constraint enables chaining into commutativity proofs. With Left = 0, each group has 0 ticks, so the inductive step is just `TimesGroup` wrapping the previous proof.
- `SuccLeftMul` proves `a * b = c => S(a) * b = c + b` for all flat multiplication proofs. `Distributed: NaturalProduct & SuccLeftMul` -- the strengthened self-referential constraint ensures the output is itself distributable, enabling inductive chaining. Each `TimesGroup` gains one extra `TimesTick` (the new successor contributes one extra unit per copy), so b groups contribute b extra ticks. Structurally identical to how `SuccLeftAdd` wraps each `PlusSucc`.
- `_MulCommN2` / `_MulCommN3` prove `Nk * b = b * Nk` for all b (per-A commutativity). Each protocol carries paired proofs: `FwdProof` (A * b, hardcoded A ticks per group) and `RevProof` (b * A, chained via `SuccLeftMul.Distributed`). Seed types (`_MulCommN2Seed`, `_MulCommN3Seed`) provide the base case (b = 0). Full universality (for all a AND b simultaneously) requires generic associated types; per-A universality follows the `_TimesNk` pattern.
- The `@MulCommProof(leftOperand: A, depth: D)` macro generates bounded-depth paired commutativity proofs as members of a namespace enum. For each b from 0 to D, `_FwdK` witnesses `A * b` (flat encoding: A ticks per group) and `_RevK` witnesses `b * A` (via `SuccLeftMul.Distributed`). The type checker verifies that both Totals match. This complements the universal per-A protocols: the manual protocols prove commutativity for all b, while the macro proves it for specific b values up to the given depth for any A >= 2.
- `CFStream` is a coinductive stream protocol with `Head: Natural` and `Tail: CFStream`. For periodic continued fractions, self-referential types create productive fixed points (e.g., `PhiCF.Tail = PhiCF`). Swift resolves these lazily -- `.Tail.Tail...Head` always terminates.
- `PhiCF` represents the golden ratio CF [1; 1, 1, ...] (entirely periodic, self-referential). `Sqrt2Periodic` represents [2; 2, 2, ...] (periodic tail). `Sqrt2CF` represents sqrt(2) = [1; 2, 2, ...] (transient head + periodic tail).
- `PhiUnfold` / `Sqrt2PeriodicUnfold` prove that periodic streams unfold to themselves at any depth, using the Seed-based induction pattern. `PhiUnfoldSeed` / `Sqrt2PeriodicUnfoldSeed` provide the base case (depth 0); `AddOne` applies `.Tail` for the inductive step.
- `assertStreamEqual<T: CFStream>(_: T.Type, _: T.Type)` provides compile-time type equality assertions for `CFStream` types, analogous to `assertEqual` for `Integer` types.
- Universal convergent extraction from streams is not possible: the CF recurrence `h_{n+1} = a*h_n + h_{n-1}` requires adding two abstract naturals in one step, which Swift's conditional conformance cannot express. Convergent computation remains bounded-depth via macros. The streams encode the *identity* of the irrational number (its coefficient sequence), not the *computation*.

## Branching

- `master` -- witness-based proofs, type-level arithmetic, structural type definitions.
- `witness-based-proofs` -- PR 1: paradigm shift from runtime computation to witness-based proofs.
- `macro-cleanup` -- PR 2: removes computational macros, Xcode target, updates docs.
- `continued-fractions` -- PR 3: golden ratio CF/Fibonacci and sqrt(2) CF/matrix correspondence proofs.
- `addition-associativity` -- PR for issue #29: associativity of addition via ProofSeed.
- `multiplication-theorems` -- PR for issue #30: universal multiplication theorems (MulLeftZero, SuccLeftMul via flat encoding).
- `coinductive-streams` -- PR for issue #31: coinductive CF streams for irrational numbers (PhiCF, Sqrt2CF, unfold theorems).
- `mul-comm-macro` -- PR for issue #32: @MulCommProof macro for automated commutativity proof generation.
