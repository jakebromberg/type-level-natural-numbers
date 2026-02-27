# Abuse of Notation

Encoding the natural numbers as Swift types using the Peano axioms, with witness-based proofs that verify arithmetic facts at compile time. A successful `swift build` is the proof.

## Peano encoding

Numbers are represented as types:

- `Zero` represents 0
- `AddOne<N>` represents the successor of N (i.e. N + 1)
- `SubOne<N>` represents the predecessor of N (i.e. N - 1)

For example, `AddOne<AddOne<Zero>>` is the type-level representation of 2, and `SubOne<Zero>` is -1. Type aliases `N0` through `N9` provide convenient shorthand.

## Protocols

The protocol hierarchy uses 3 protocols:

### `Integer`

The root protocol for all integer types. Declares `Successor` and `Predecessor` associated types.

### `Natural`

Extends `Integer` for nonnegative integers (0, 1, 2, ...). Constrains `Successor` to `Natural`. Conformed to by `Zero` and `AddOne<N>`.

### `Nonpositive`

Extends `Integer` for nonpositive integers (0, -1, -2, ...). Constrains `Predecessor` to `Nonpositive`. Conformed to by `Zero` and `SubOne<N>`.

`Zero` sits at the intersection of `Natural` and `Nonpositive`, conforming to both.

## Witness-based proofs

Arithmetic facts are proved by constructing types whose existence demonstrates the relationship. The proofs are verified by the Swift type checker at compile time.

### Addition witnesses (`NaturalSum`)

The `NaturalSum` protocol witnesses that `Left + Right = Total`:

- `PlusZero<N>`: proves `N + 0 = N` (base case)
- `PlusSucc<Proof>`: if `A + B = C`, proves `A + S(B) = S(C)` (inductive step)

```swift
// Proof that 2 + 3 = 5
typealias TwoPlusThree = PlusSucc<PlusSucc<PlusSucc<PlusZero<N2>>>>
assertEqual(TwoPlusThree.Total.self, N5.self)  // compiles only if correct
```

### Multiplication witnesses (`NaturalProduct`)

The `NaturalProduct` protocol witnesses that `Left * Right = Total`:

- `TimesZero<N>`: proves `N * 0 = 0` (base case)
- `TimesSucc<MulProof, AddProof>`: if `A * B = C` and `C + A = D`, proves `A * S(B) = D` (inductive step)

```swift
// Proof that 2 * 3 = 6
// Chain: 2*0=0, 0+2=2 so 2*1=2, 2+2=4 so 2*2=4, 4+2=6 so 2*3=6
typealias Mul2x0 = TimesZero<N2>
typealias Add0p2 = PlusSucc<PlusSucc<PlusZero<N0>>>
typealias Mul2x1 = TimesSucc<Mul2x0, Add0p2>
typealias Add2p2 = PlusSucc<PlusSucc<PlusZero<N2>>>
typealias Mul2x2 = TimesSucc<Mul2x1, Add2p2>
typealias Add4p2 = PlusSucc<PlusSucc<PlusZero<N4>>>
typealias Mul2x3 = TimesSucc<Mul2x2, Add4p2>
assertEqual(Mul2x3.Total.self, N6.self)
```

### Comparison witnesses (`NaturalLessThan`)

The `NaturalLessThan` protocol witnesses that `Left < Right`:

- `ZeroLT<N>`: proves `0 < S(N)`
- `SuccLT<Proof>`: if `A < B`, proves `S(A) < S(B)`

```swift
// Proof that 2 < 5 (peel off 2 successors, then 0 < 3)
typealias TwoLtFive = SuccLT<SuccLT<ZeroLT<N2>>>
```

### Type-level arithmetic (`Sum`, `Product`)

For convenience, `Sum<L, R>.Result` and `Product<L, R>.Result` compute type-level addition and multiplication via constrained extensions:

```swift
assertEqual(Sum<N2, N3>.Result.self, N5.self)
assertEqual(Product<N2, N3>.Result.self, N6.self)
```

The `@ProductConformance(n)` macro generates the inductive protocols and conformances needed for `Product` to handle a given multiplier.

## Macros as proof generators

Writing witness chains by hand is explicit but tedious -- a proof of `F(10) = 55` requires threading 10 `PlusSucc`/`PlusZero` witnesses through `FibStep` chains. Swift macros automate this by computing arithmetic at compile time and emitting the witness types that the type checker independently verifies.

The architecture has three layers:

1. **Protocol** (human-authored) -- states the theorem (e.g., `FibVerified` requires `SumWitness` proving `Prev + Current = Next`)
2. **Macro** (proof search) -- computes integers at compile time and emits witness chains as typealiases
3. **Type checker** (proof verifier) -- structurally verifies every `where` constraint. If the macro emits a wrong witness, compilation fails.

Both proof-generating macros use `@attached(member, names: arbitrary)`, generating all witnesses as members of a namespace enum:

```swift
@FibonacciProof(upTo: 10)
enum FibProof {}

assertEqual(FibProof._Fib5.Current.self, N5.self)  // F(5) = 5
assertEqual(FibProof._Fib6.Current.self, N8.self)  // F(6) = 8
```

## Cayley-Dickson construction

The Cayley-Dickson construction builds higher-dimensional algebras from pairs. The type-level representation `CayleyDickson<Re, Im>` encodes the structure:

| Level | Algebra | Dimensions |
|-------|---------|------------|
| 0 | Integers | 1 |
| 1 | Gaussian integers | 2 |
| 2 | Quaternions | 4 |
| 3 | Octonions | 8 |

Integer types (`Zero`, `AddOne`, `SubOne`) conform to the `Algebra` marker protocol as level-0 scalars.

## Continued fractions and pi

Two classical formulas approximate pi from opposite directions:

- **Brouncker's continued fraction** for 4/pi: `1 + 1/(2 + 9/(2 + 25/(2 + ...)))`
- **Leibniz series** for pi/4: `1 - 1/3 + 1/5 - 1/7 + ...`

At every depth n, the CF convergent h_n/k_n equals 1/S_{n+1}, where S_{n+1} is the (n+1)-th Leibniz partial sum. The `@PiConvergenceProof(depth:)` macro constructs both sequences independently -- `GCFConvergent` for CF convergents via the standard recurrence, `LeibnizPartialSum` for alternating series via fraction arithmetic -- plus all intermediate product and sum witnesses, then generates `assertEqual` calls to verify the correspondence:

```swift
@PiConvergenceProof(depth: 3)
enum PiProof {}

// CF convergent h_2/k_2 = 15/13 is the reciprocal of Leibniz S_3 = 13/15
assertEqual(PiProof._CF2.P.self, PiProof._LS3.Q.self)  // 15 = 15
assertEqual(PiProof._CF2.Q.self, PiProof._LS3.P.self)  // 13 = 13
```

Since both sequences converge and their values agree at every depth, they converge to the same limit. The compilation itself is the proof.

## Golden ratio and Fibonacci

The golden ratio phi = (1 + sqrt(5))/2 has the simplest continued fraction: [1; 1, 1, 1, ...]. The CF recurrence with a=1, b=1 is just h_n = h_{n-1} + h_{n-2} -- the Fibonacci recurrence. The `@GoldenRatioProof(depth:)` macro proves that h_n = F(n+2) and k_n = F(n+1) by constructing both Fibonacci witness chains and CF convergents independently, then asserting type equality:

```swift
@GoldenRatioProof(depth: 5)
enum GoldenRatioProof {}

assertEqual(GoldenRatioProof._CF5.P.self, N13.self)  // h_5 = 13 = F(7)
assertEqual(GoldenRatioProof._CF5.Q.self, N8.self)   // k_5 = 8  = F(6)
```

## sqrt(2) CF and matrix construction

The sqrt(2) continued fraction [1; 2, 2, 2, ...] has convergents that can be computed either by the three-term recurrence (h_n = 2h_{n-1} + h_{n-2}) or by iterated left-multiplication by the matrix [[2,1],[1,0]]. The `@Sqrt2ConvergenceProof(depth:)` macro constructs both representations and proves they agree:

```swift
@Sqrt2ConvergenceProof(depth: 3)
enum Sqrt2Proof {}

assertEqual(Sqrt2Proof._MAT3.A.self, Sqrt2Proof._CF3.P.self)  // 17 = 17
assertEqual(Sqrt2Proof._MAT3.B.self, Sqrt2Proof._CF3.Q.self)  // 12 = 12
```

## Building

```sh
swift build                      # compile (compilation = proof)
swift run AbuseOfNotationClient  # exits cleanly
swift test                       # run macro expansion tests
```
