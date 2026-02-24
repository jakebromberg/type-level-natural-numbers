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

### Exponentiation (`**`)

Right-hand recursive on the exponent:

```
a ** 0    = 1
a ** S(b) = a ** b * a
```

Natural-only for the base and exponent. An integer-level overload handles negative bases with natural exponents (e.g. `(-2) ** 3 = -8`).

### Truncated subtraction / monus (`.-`)

```
a .- 0    = a
0 .- b    = 0
S(a) .- S(b) = a .- b
```

Returns 0 when `rhs > lhs`. The standard Peano "monus" operation -- subtraction that stays in the naturals.

### Division and modulo (`/`, `%`, `divmod`)

Natural division and modulo via repeated subtraction:

```swift
func divmod(_ a: any Natural.Type, _ b: any Natural.Type) -> (any Natural.Type, any Natural.Type)
func /(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type
func %(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type
```

`divmod` returns `(quotient, remainder)` where `a = q * b + r` and `0 <= r < b`. `/` and `%` delegate to `divmod`.

### Factorial

```
fact(0) = 1
fact(S(n)) = S(n) * fact(n)
```

### Fibonacci

```
fib(0) = 0, fib(1) = 1, fib(n) = fib(n-1) + fib(n-2)
```

Uses an iterative helper with accumulator pair to avoid exponential recursion.

### GCD

Euclidean algorithm:

```
gcd(a, 0) = a
gcd(a, b) = gcd(b, a % b)
```

### Hyperoperation (`hyperop`)

The hyperoperation sequence generalizes successor, addition, multiplication, and exponentiation into a single recursive function:

```
H(0, a, b)       = S(b)          (successor)
H(1, a, b)       = a + b         (addition)
H(2, a, b)       = a * b         (multiplication)
H(3, a, b)       = a ** b        (exponentiation)
H(4, a, b)       = a ↑↑ b        (tetration)

H(S(n), a, 0)    = identity(n)   -- a for n=0, 0 for n=1, 1 for n>=2
H(S(n), a, S(b)) = H(n, a, H(S(n), a, b))
```

Natural-only by definition.

### Ackermann function (`ackermann`)

A total computable function that grows faster than any primitive recursive function:

```
A(0, n)       = S(n)
A(S(m), 0)    = A(m, 1)
A(S(m), S(n)) = A(m, A(S(m), n))
```

Natural-only by definition. Only small inputs are practical (the function grows extremely fast).

### Church numerals

A second encoding strategy alongside Peano types. Where Peano types encode the *structure* of a number (nested successors), Church numerals encode the *behavior* (function application count): `church(n)(f)(x) = f^n(x)`.

```swift
protocol ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T
}

enum ChurchZero: ChurchNumeral { ... }   // applies f zero times
enum ChurchSucc<N: ChurchNumeral>: ChurchNumeral { ... }  // applies f one more time
```

Church arithmetic is defined at the type level:
- `ChurchAdd<A, B>`: applies `f` a total of `a + b` times
- `ChurchMul<A, B>`: applies `b(f)` a total of `a` times

Convert to `Int` via `churchToInt(_:)`.

### Type-level arithmetic (Xcode target)

A parallel compile-time arithmetic system lets the Swift type checker verify equalities statically. `Sum<L, R>` and `Product<L, R>` implement type-level addition and multiplication, verified via `assertEqual<T: Natural>(_: T.Type, _: T.Type)`.

Due to Swift's conditional conformance limitations, `Sum` supports L up to N3, and `Product` enumerates specific (L, R) pairs for L >= 2.

## Macros

Four freestanding expression macros evaluate integer arithmetic at compile time. They are implemented as a Swift compiler plugin using SwiftSyntax.

### `#Peano(n)` -- integer literal to Peano metatype

Converts an integer literal to its Peano type representation:

```swift
#Peano(0)   // expands to: Zero.self
#Peano(3)   // expands to: AddOne<AddOne<AddOne<Zero>>>.self
#Peano(-2)  // expands to: SubOne<SubOne<Zero>>.self
```

### `#PeanoType(expr)` -- compile-time arithmetic

Evaluates an arithmetic expression at macro expansion time and emits the concrete Peano type. Supports `+`, `-`, `*`, `**`, `.-`, `/`, `%`, `negate()`, `factorial()`, `fibonacci()`, `gcd()`, `hyperop()`, `ackermann()`:

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

### `#Church(n)` -- integer literal to Church numeral type

Converts a nonnegative integer literal to its Church numeral type representation:

```swift
#Church(0)  // expands to: ChurchZero.self
#Church(3)  // expands to: ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self
```

## Examples

```swift
// Convenience bindings
let Two: any Natural.Type = AddOne<AddOne<Zero>>.self
let Three: any Natural.Type = Two.successor

// Runtime arithmetic
assert(Two + Three == #Peano(5))
assert(Two ** Three == #Peano(8))
assert(factorial(Three) == #Peano(6))
assert(fibonacci(Three) == Two)
assert(gcd(#Peano(6) as! any Natural.Type, #Peano(4) as! any Natural.Type) == Two)

// Hyperoperations and Ackermann
assert(hyperop(Three, Two, Three) == #Peano(8))   // H(3,2,3) = 2^3 = 8
assert(ackermann(Two, Two) == #Peano(7))           // A(2,2) = 7

// Church numerals
let c3 = ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self
assert(churchToInt(c3) == 3)
assert(churchToInt(#Church(5)) == 5)

// Compile-time assertions
#PeanoAssert(2 ** 3 == 8)
#PeanoAssert(factorial(4) == 24)
#PeanoAssert(gcd(6, 4) == 2)
#PeanoAssert(hyperop(3, 2, 3) == 8)
#PeanoAssert(ackermann(2, 2) == 7)
assertEqual(#PeanoType(fibonacci(6)), #Peano(8))
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
