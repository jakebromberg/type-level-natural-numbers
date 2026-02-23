# type-level-natural-numbers

Abusing the type system to define the Naturals and perform arithmetic and boolean operations over them.

## Peano encoding

Natural numbers are encoded as types using the [Peano axioms](https://en.wikipedia.org/wiki/Peano_axioms):

- `Zero` represents 0
- `AddOne<N>` represents the successor of N (i.e. N + 1)

For example, `AddOne<AddOne<Zero>>` is the type-level representation of 2. Convenience aliases `N0`..`N6` and runtime metatype bindings (`Zip`, `One`, `Two`, ..., `Six`) are provided.

## Runtime arithmetic

Free-function operators `+`, `*`, `<`, `>` work on existential metatype values (`any Natural.Type`). These are resolved at runtime via dynamic dispatch on `predecessorOrNil` / `successor`.

```swift
assert(One + Two == Three)
assert(Two > One)
```

## Type-level arithmetic

A parallel compile-time arithmetic system lets the Swift type checker verify equalities statically.

### `NaturalExpression`

```swift
protocol NaturalExpression {
    associatedtype Result: Natural
}
```

A type-level computation that evaluates to a `Natural` type.

### `Sum<L, R>`

```swift
assertEqual(Sum<N2, N2>.Result.self, Four)  // 2 + 2 = 4
```

`Sum<L, R>.Result` resolves to the concrete `AddOne<...>` chain representing L + R at compile time. The base case (`L == Zero`) conforms `Sum` to `NaturalExpression`; recursive cases use constrained extensions.

### `Product<L, R>`

```swift
assertEqual(Product<N2, N3>.Result.self, Six)  // 2 * 3 = 6
```

`Product<L, R>.Result` resolves to L * R. The base cases (`L == Zero`, `L == N1`) are generic over R. For larger L values, specific (L, R) pairs are enumerated because Swift's type system cannot resolve a generic `Sum<R, R>.Result` at definition time (there are no generic associated types).

### `assertEqual`

```swift
func assertEqual<T: Natural>(_: T.Type, _: T.Type) {}
```

A compile-time type equality assertion. If both arguments have the same static type the call compiles; if they differ, the compiler reports a type error. The function body is intentionally empty -- the assertion is the compilation itself.

### How it differs from runtime arithmetic

| | Runtime | Type-level |
|---|---|---|
| Values | Existential metatypes (`any Natural.Type`) | Concrete generic types (`N3.Type`) |
| Dispatch | Dynamic (`predecessorOrNil` checks) | Static (type checker resolves `AddOne<...>` chains) |
| Errors | Runtime assertion failures | Compile-time type errors |
| Generality | Works for any natural number | `Sum` supports L up to N3; `Product` enumerates specific pairs for L >= 2 |

### Why conditional conformance is limited

Swift does not allow multiple conditional conformances of the same protocol on a single type. The natural encoding of type-level Peano addition would use two conformances of `Sum` to `NaturalExpression` (one for `L == Zero`, another for `L: Positive`), but the compiler rejects this. The workaround uses a single protocol conformance for the base case and plain constrained-extension typealiases for the recursive cases. This means `Sum<L, R>` only conforms to `NaturalExpression` when `L == Zero`, but `Sum<L, R>.Result` is available for any supported L value via the constrained extensions.
