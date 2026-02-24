// Xcode target entry point.
//
// Protocols, types, operators, and Cayley-Dickson algebra are compiled from
// Sources/PeanoNumbers/ (PeanoTypes.swift, CayleyDickson.swift, ChurchNumerals.swift).
// This file contains:
//   1. Convenience bindings
//   2. Representative runtime assertions (verify shared sources)
//   3. Type-level arithmetic (Xcode-exclusive: NaturalExpression, Sum, Product)

// MARK: - Type aliases for type-level arithmetic

typealias N0 = Zero
typealias N1 = AddOne<N0>
typealias N2 = AddOne<N1>
typealias N3 = AddOne<N2>
typealias N4 = AddOne<N3>
typealias N5 = AddOne<N4>
typealias N6 = AddOne<N5>

// MARK: - Convenience bindings

let Zip = Zero.self

let One = AddOne<Zero>.self
let Two = One.successor
let Three = Two.successor
let Four = Three.successor
let Five = Four.successor
let Six = Five.successor

let MinusOne   = SubOne<Zero>.self
let MinusTwo   = SubOne<SubOne<Zero>>.self
let MinusThree = SubOne<SubOne<SubOne<Zero>>>.self

// MARK: - Runtime assertions (verify shared sources)

// Natural arithmetic
assert(One + Two == Three)
assert(Two * Three == Six)
assert(Two ** Three == AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>>>.self)

// Integer arithmetic
assert(negate(Two) == MinusTwo)
assert(Three - Five == MinusTwo)
assert(MinusTwo * MinusThree == Six)

// Comparison
assert(One < Two)
assert(Two >= One)
assert(MinusOne < Zip)

// Extended arithmetic
assert(Five .- Three == Two)
assert(Six / Two == Three)
assert(Six % Four == Two)
assert(factorial(Three) == Six)
assert(fibonacci(Three) == Two)
assert(gcd(Six, Four) == Two)
assert(hyperop(Two, Two, Three) == Six)
assert(ackermann(One, One) == Three)

// Church numerals
let c0 = ChurchZero.self
let c1 = ChurchSucc<ChurchZero>.self
let c2 = ChurchSucc<ChurchSucc<ChurchZero>>.self
let c3 = ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self

assert(churchToInt(c0) == 0)
assert(churchToInt(c1) == 1)
assert(churchToInt(c2) == 2)
assert(churchToInt(c3) == 3)
assert(churchToInt(ChurchAdd<ChurchSucc<ChurchSucc<ChurchZero>>, ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>>.self) == 5)
assert(churchToInt(ChurchMul<ChurchSucc<ChurchSucc<ChurchZero>>, ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>>.self) == 6)

// Cayley-Dickson construction
let z1 = gaussian(One, Two)
let z2 = gaussian(Three, MinusOne)
assert(z1 + z2 == gaussian(Four, One))
assert(z1 * z2 == gaussian(Five, Five))
assert(conjugate(z1) == gaussian(One, MinusTwo))
assert(norm(z1) == AlgebraValue.scalar(Five))

assertEqual(CayleyDickson<AddOne<Zero>, AddOne<AddOne<Zero>>>.algebraValue, gaussian(One, Two))

let qi = quaternion(Zip, One, Zip, Zip)
let qj = quaternion(Zip, Zip, One, Zip)
assert(qi * qj != qj * qi)

let splitJ = gaussian(Zip, One)
assert(multiply(splitJ, splitJ, sign: .split) == gaussian(One, Zip))
assert(multiply(splitJ, splitJ, sign: .standard) == gaussian(MinusOne, Zip))
assert(multiply(splitJ, splitJ, sign: .dual) == gaussian(Zip, Zip))

// MARK: - Type-level arithmetic (Xcode-exclusive)

/// A type-level computation that evaluates to a `Natural` type.
protocol NaturalExpression {
    associatedtype Result: Natural
}

// MARK: Sum

/// Type-level addition. `Sum<L, R>.Result` resolves to the concrete
/// `AddOne<...>` chain representing L + R at compile time.
///
/// Swift does not support multiple conditional conformances of the same
/// protocol, so the base case (L == Zero) uses a protocol conformance
/// while the recursive cases use constrained extensions with typealiases.
enum Sum<L: Natural, R: Natural> {}

extension Sum: NaturalExpression where L == Zero {
    typealias Result = R                                    // 0 + R = R
}

extension Sum where L == N1 {
    typealias Result = AddOne<R>                            // 1 + R = R + 1
}

extension Sum where L == N2 {
    typealias Result = AddOne<AddOne<R>>                    // 2 + R = R + 2
}

extension Sum where L == N3 {
    typealias Result = AddOne<AddOne<AddOne<R>>>            // 3 + R = R + 3
}

// MARK: Product

/// Type-level multiplication. `Product<L, R>.Result` resolves to the
/// concrete `AddOne<...>` chain representing L * R at compile time.
///
/// The base cases (L == Zero, L == N1) are generic over R. For larger L
/// values, Swift cannot resolve `Sum<R, R>.Result` for a generic R at
/// definition time, so specific (L, R) pairs are enumerated.
enum Product<L: Natural, R: Natural> {}

extension Product: NaturalExpression where L == Zero {
    typealias Result = Zero                                 // 0 * R = 0
}

extension Product where L == N1 {
    typealias Result = R                                    // 1 * R = R
}

extension Product where L == N2, R == N1 {
    typealias Result = N2                                   // 2 * 1 = 2
}

extension Product where L == N2, R == N2 {
    typealias Result = N4                                   // 2 * 2 = 4
}

extension Product where L == N2, R == N3 {
    typealias Result = N6                                   // 2 * 3 = 6
}

// Compile-time addition
assertEqual(Sum<N0, N0>.Result.self, Zip)
assertEqual(Sum<N1, N0>.Result.self, One)
assertEqual(Sum<N0, N1>.Result.self, One)
assertEqual(Sum<N1, N2>.Result.self, Three)    // 1 + 2 = 3
assertEqual(Sum<N2, N2>.Result.self, Four)     // 2 + 2 = 4

// Compile-time multiplication
assertEqual(Product<N0, N1>.Result.self, Zip)  // 0 * 1 = 0
assertEqual(Product<N1, N2>.Result.self, Two)  // 1 * 2 = 2
assertEqual(Product<N2, N2>.Result.self, Four) // 2 * 2 = 4
assertEqual(Product<N2, N3>.Result.self, Six)  // 2 * 3 = 6
