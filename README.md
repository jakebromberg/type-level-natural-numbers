# type-level-natural-numbers

Encoding the integers as Swift types using the Peano axioms and performing arithmetic and comparison over them at runtime via existential metatypes, with Swift macros for compile-time arithmetic.

## Peano encoding

Numbers are represented as types:

- `Zero` represents 0
- `AddOne<N>` represents the successor of N (i.e. N + 1)
- `SubOne<N>` represents the predecessor of N (i.e. N - 1)

For example, `AddOne<AddOne<Zero>>` is the type-level representation of 2, and `SubOne<Zero>` is -1. Runtime metatype bindings (`Zip`, `One`, `Two`, ..., `Six`, `MinusOne`, `MinusTwo`, `MinusThree`) provide convenient handles.

## Protocols

The protocol hierarchy uses 3 protocols:

### `Integer`

The root protocol for all integer types. Declares `Successor` and `Predecessor` associated types with `successor` and `predecessor` properties.

### `Natural`

Extends `Integer` for nonnegative integers (0, 1, 2, ...). Constrains `Successor` to `Natural`. Conformed to by `Zero` and `AddOne<N>`.

### `Nonpositive`

Extends `Integer` for nonpositive integers (0, -1, -2, ...). Constrains `Predecessor` to `Nonpositive`. Conformed to by `Zero` and `SubOne<N>`.

`Zero` sits at the intersection of `Natural` and `Nonpositive`, conforming to both. Type canonicalization is enforced by the generic parameter constraints: `AddOne<N: Natural>` prevents `AddOne<SubOne<...>>`, and `SubOne<N: Nonpositive>` prevents `SubOne<AddOne<...>>`.

## Arithmetic

Free-function operators work on existential metatypes (`any Natural.Type`, `any Integer.Type`). All operators use right-hand recursion (the standard Peano form), reducing the right operand toward zero.

### Addition (`+`)

Right-hand recursive definition:

```
a + 0    = a         (base case)
a + S(b) = S(a + b)  (inductive step)
```

An integer-level overload handles mixed-sign addition by recursing on the rhs toward zero via `successor` (for negative rhs) or `predecessor` (for positive rhs).

A `Zero`-specific static overload handles `0 + 0` without recursion.

### Subtraction (`-`)

Defined as addition of the negation:

```swift
func -(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type
```

### Multiplication (`*`)

Right-hand recursive definition:

```
a * 0    = 0             (base case)
a * S(b) = a * b + a     (inductive step)
```

Static overloads on `Natural` handle the base cases (`0 * n` and `n * 0`).

An integer-level overload extends multiplication to negative numbers:

```
a * 0    = 0
a * S(b) = a * b + a     (positive rhs)
a * P(b) = a * b - a     (negative rhs)
```

### Negation

```swift
func negate(_ n: any Integer.Type) -> any Integer.Type
```

Recursively negates a number by walking toward zero and rebuilding in the opposite direction.

### Comparison (`<`, `>`, `<=`, `>=`)

Natural-level `<` uses right-hand recursion:

```
a < 0    = false
0 < S(b) = true
S(a) < S(b) = a < b
```

Integer-level `<` handles mixed signs:
- Any negative < any nonnegative
- Any nonnegative > any negative
- Both nonnegative: delegates to natural comparison
- Both negative: `SubOne<a> < SubOne<b>` iff `a < b`

`>` is the flip of `<`. `<=` and `>=` are defined as `!(rhs < lhs)` and `!(lhs < rhs)` respectively, at both the natural and integer levels.

### Type-level arithmetic (Xcode target)

A parallel compile-time arithmetic system lets the Swift type checker verify equalities statically. `Sum<L, R>` and `Product<L, R>` implement type-level addition and multiplication, verified via `assertEqual<T: Natural>(_: T.Type, _: T.Type)`.

Due to Swift's conditional conformance limitations, `Sum` supports L up to N3, and `Product` enumerates specific (L, R) pairs for L >= 2.

## Macros

Three freestanding expression macros evaluate integer arithmetic at compile time. They are implemented as a Swift compiler plugin using SwiftSyntax.

### `#Peano(n)` -- integer literal to Peano metatype

Converts an integer literal to its Peano type representation:

```swift
#Peano(0)   // expands to: Zero.self
#Peano(3)   // expands to: AddOne<AddOne<AddOne<Zero>>>.self
#Peano(-2)  // expands to: SubOne<SubOne<Zero>>.self
```

### `#PeanoType(expr)` -- compile-time arithmetic

Evaluates an arithmetic expression (`+`, `-`, `*`) at macro expansion time and emits the concrete Peano type:

```swift
#PeanoType(2 + 3)       // expands to: AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self
#PeanoType(2 * 3 - 1)   // expands to: AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self
#PeanoType(3 - 5)        // expands to: SubOne<SubOne<Zero>>.self
```

Use with `assertEqual` to verify compile-time arithmetic at the type level:

```swift
assertEqual(#PeanoType(2 + 3), #Peano(5))   // passes at runtime
```

### `#PeanoAssert(expr)` -- compile-time boolean assertion

Evaluates a comparison at macro expansion time. Passing assertions expand to `()`. Failing assertions produce a compiler error:

```swift
#PeanoAssert(2 + 3 == 5)   // compiles successfully
#PeanoAssert(2 + 3 == 7)   // compiler error: "Peano assertion failed: 2 + 3 is 5, not 7"
#PeanoAssert(-1 < 0)        // compiles successfully
```

Supports `==`, `!=`, `<`, `>`, `<=`, `>=`.

## Examples

```swift
// Convenience bindings via macros
let One   = #Peano(1)
let Two   = #Peano(2)
let Three = #Peano(3)

// Runtime assertions (existential metatype arithmetic)
assert(One + Two == Three)
assert(Two * Two == #Peano(4))
assert(Two > One)
assert(Two <= Two)
assert(Two >= One)

// Compile-time assertions (evaluated during macro expansion)
#PeanoAssert(1 + 2 == 3)
#PeanoAssert(2 * 3 == 6)
#PeanoAssert(-1 < 0)
#PeanoAssert(0 <= 0)

// Type equality via assertEqual
assertEqual(#PeanoType(2 + 3), #Peano(5))
```

## Building

### SPM

```sh
swift build                  # compile (compile-time assertions verified here)
swift run PeanoNumbersClient # run runtime assertions
swift test                   # run macro expansion tests
```

### Xcode

Open `type-level-natural-numbers.xcodeproj` in Xcode and run the target. The Xcode project is self-contained and does not use the SPM macros.
