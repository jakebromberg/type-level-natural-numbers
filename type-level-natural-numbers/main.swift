// Xcode target entry point.
//
// Protocols, types, operators, and Cayley-Dickson algebra are compiled from
// Sources/PeanoNumbers/ (PeanoTypes.swift, CayleyDickson.swift, ChurchNumerals.swift).
// This file contains:
//   1. Convenience bindings
//   2. Representative runtime assertions (verify shared sources)
//
// Type-level arithmetic (NaturalExpression, Sum, Product) lives in the SPM client
// where macros are available.

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
