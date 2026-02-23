# type-level-natural-numbers

Encoding the integers as Swift types using the Peano axioms and performing arithmetic and comparison over them at runtime via existential metatypes.

## Peano encoding

Numbers are represented as types:

- `Zero` represents 0
- `AddOne<N>` represents the successor of N (i.e. N + 1)
- `SubOne<N>` represents the predecessor of N (i.e. N - 1)

For example, `AddOne<AddOne<Zero>>` is the type-level representation of 2, and `SubOne<Zero>` is -1. Runtime metatype bindings (`Zip`, `One`, `Two`, ..., `Six`, `MinusOne`, `MinusTwo`, `MinusThree`) provide convenient handles.

## Protocols

### `Integer`

The root protocol for all integer types. Declares `Successor` and `Predecessor` associated types with `successor` and `predecessor` properties.

### `Natural`

Extends `Integer` for nonnegative integers (0, 1, 2, ...). Constrains `Successor` to `Positive`. Conformed to by `Zero` and `AddOne<N>`.

### `Positive`

A refinement of `Natural` for numbers >= 1. Constrains `Predecessor` to `Natural`. `AddOne<N>` conforms to `Positive` for any `N: Natural`.

### `Nonpositive`

Extends `Integer` for nonpositive integers (0, -1, -2, ...). Constrains `Predecessor` to `Negative`. Conformed to by `Zero` and `SubOne<N>`.

### `Negative`

A refinement of `Nonpositive` for numbers <= -1. Constrains `Successor` to `Nonpositive`. `SubOne<N>` conforms to `Negative` for any `N: Nonpositive`.

`Zero` sits at the intersection of `Natural` and `Nonpositive`, conforming to both.

## Arithmetic

Free-function operators work on existential metatypes (`any Natural.Type`, `any Positive.Type`, `any Integer.Type`). They are defined recursively using `predecessor` and `successor`.

### Addition (`+`)

Natural-level overloads provide tighter return types:

| Signature | Return type |
|---|---|
| `(any Natural.Type, any Natural.Type)` | `any Natural.Type` |
| `(any Natural.Type, any Positive.Type)` | `any Positive.Type` |
| `(any Positive.Type, any Natural.Type)` | `any Positive.Type` |
| `(any Positive.Type, any Positive.Type)` | `any Positive.Type` |

An integer-level overload handles mixed-sign addition:

| `(any Integer.Type, any Integer.Type)` | `any Integer.Type` |

A `Zero`-specific static overload handles `0 + 0` without recursion.

### Subtraction (`-`)

Defined as addition of the negation:

```swift
func -(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type
```

### Multiplication (`*`)

Static overloads on `Natural` handle the base cases (`0 * n` and `n * 0`). A free-function recursive definition covers the general case:

```
(n+1) * m = n * m + m
```

with a short-circuit for `1 * m = m`.

An integer-level overload extends multiplication to negative numbers:

```
(-1) * m = -m
(n-1) * m = n * m - m
```

### Negation

```swift
func negate(_ n: any Integer.Type) -> any Integer.Type
```

Recursively negates a number by walking toward zero and rebuilding in the opposite direction.

### Comparison (`<`, `>`)

Natural-level `<` recurses on predecessors:

```
0 < 0       = false
0 < (n+1)   = true
(n+1) < 0   = false
(n+1) < (m+1) = n < m
```

Integer-level `<` handles mixed signs:
- Any negative < any nonnegative
- Any nonnegative > any negative
- Both nonnegative: delegates to natural comparison
- Both negative: `SubOne<a> < SubOne<b>` iff `a < b`

`>` is defined as the flip of `<` at both levels.

## Examples

```swift
let One   = AddOne<Zero>.self
let Two   = One.successor
let Three = Two.successor

assert(One + Two == Three)
assert(Two * Two == Four)
assert(Two > One)
assert(!(Zip < Zip))

let MinusOne = SubOne<Zero>.self
assert(One + MinusOne == Zip)
assert(Three - Two == One)
assert(Two - Three == MinusOne)
assert(MinusOne * MinusOne == One)
assert(MinusOne < Zip)
```

## Building

Open `type-level-natural-numbers.xcodeproj` in Xcode and run the target. The program exercises every operation via `assert` statements -- a successful run means all checks pass.
