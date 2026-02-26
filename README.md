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

## Church numerals

A second encoding strategy alongside Peano types. Where Peano types encode the *structure* of a number (nested successors), Church numerals encode the *behavior* (function application count): `church(n)(f)(x) = f^n(x)`.

```swift
protocol ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T
}
```

Church arithmetic is defined at the type level:
- `ChurchAdd<A, B>`: applies `f` a total of `a + b` times
- `ChurchMul<A, B>`: applies `b(f)` a total of `a` times

## Cayley-Dickson construction

The Cayley-Dickson construction builds higher-dimensional algebras from pairs. The type-level representation `CayleyDickson<Re, Im>` encodes the structure:

| Level | Algebra | Dimensions |
|-------|---------|------------|
| 0 | Integers | 1 |
| 1 | Gaussian integers | 2 |
| 2 | Quaternions | 4 |
| 3 | Octonions | 8 |

Integer types (`Zero`, `AddOne`, `SubOne`) conform to the `Algebra` marker protocol as level-0 scalars.

## Building

```sh
swift build                      # compile (compilation = proof)
swift run AbuseOfNotationClient  # exits cleanly
swift test                       # run macro expansion tests
```
