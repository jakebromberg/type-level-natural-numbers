import PeanoNumbers

// MARK: - Convenience bindings

// Natural bindings are typed as `any Natural.Type` so they work with natural-only
// operations (exponentiation, monus, division, factorial, fibonacci, gcd).
// Since `Natural: Integer`, they also work with integer operations via covariance.
let Zip: any Natural.Type   = Zero.self
let One: any Natural.Type   = AddOne<Zero>.self
let Two: any Natural.Type   = One.successor
let Three: any Natural.Type = Two.successor
let Four: any Natural.Type  = Three.successor
let Five: any Natural.Type  = Four.successor
let Six: any Natural.Type   = Five.successor

let MinusOne   = #Peano(-1)
let MinusTwo   = #Peano(-2)
let MinusThree = #Peano(-3)

// MARK: - Basic identity assertions

assert(Zip == Zip)
assert(One == One)
assert(One != Zip)
assert(One.predecessor == Zip)
assert(Two != One)
assert(Two.predecessor == One)

assert(MinusOne != Zip)
assert(MinusOne != One)
assert(MinusOne.successor == Zip)
assert(MinusTwo.successor == MinusOne)

// MARK: - Addition

assert(Zip + Zip == Zip)
assert(Zip + One == One)
assert(One + Zip == One)
assert(One + Two == Three)
assert(Two + Two == Four)
assert(Two + Zip == Two)

// MARK: - Comparison

assert(!(Zip < Zip))
assert(One < Two)
assert(!(Two < One))
assert(Two > One)
assert(!(Zip > Zip))

// MARK: - Comparison (<=, >=)

assert(Zip <= Zip)
assert(One <= Two)
assert(Two <= Two)
assert(!(Two <= One))
assert(Zip >= Zip)
assert(Two >= One)
assert(Two >= Two)
assert(!(One >= Two))

// MARK: - Multiplication

assert(Zip * One == Zip)
assert(One * Zip == Zip)
assert(One * Two == Two)
assert(Two * Two == Four)
assert(Two * Three == Six)
assert(Three * Two == Six)
assert(One * One == One)
assert(Four * One == Four)
assert(One * Four == Four)

// MARK: - Negation

assert(negate(Zip) == Zip)
assert(negate(One) == MinusOne)
assert(negate(MinusOne) == One)
assert(negate(Two) == MinusTwo)
assert(negate(MinusTwo) == Two)

// MARK: - Integer addition

assert(One + MinusOne == Zip)
assert(MinusOne + One == Zip)
assert(MinusOne + MinusOne == MinusTwo)
assert(Three + MinusTwo == One)
assert(MinusTwo + Three == One)

// MARK: - Subtraction

assert(Three - Two == One)
assert(Two - Three == MinusOne)
assert(Zip - One == MinusOne)
assert(One - Zip == One)
assert(MinusOne - MinusOne == Zip)

// MARK: - Integer multiplication

assert(MinusOne * One == MinusOne)
assert(MinusOne * MinusOne == One)
assert(Two * MinusThree == negate(Six))
assert(MinusTwo * Three == negate(Six))
assert(MinusTwo * MinusThree == Six)

// MARK: - Integer comparison

assert(MinusOne < Zip)
assert(MinusTwo < MinusOne)
assert(!(MinusOne < MinusOne))
assert(MinusOne < One)
assert(!(One < MinusOne))
assert(One > MinusOne)
assert(MinusOne > MinusTwo)

// MARK: - Integer comparison (<=, >=)

assert(MinusOne <= Zip)
assert(MinusOne <= MinusOne)
assert(!(Zip <= MinusOne))
assert(Zip >= MinusOne)
assert(MinusOne >= MinusOne)
assert(!(MinusOne >= Zip))

// MARK: - Exponentiation

assert(Two ** Three == #Peano(8))
assert(Three ** Two == #Peano(9))
assert(Two ** Zip == One)
assert(Zip ** Five == Zip)
assert(One ** Six == One)

// MARK: - Integer exponentiation

assert((MinusTwo as any Integer.Type) ** Three == #Peano(-8))
assert((MinusTwo as any Integer.Type) ** Two == Four)

// MARK: - Monus (truncated subtraction)

assert(Five .- Three == Two)
assert(Three .- Five == Zip)
assert(Three .- Zip == Three)
assert(Zip .- Five == Zip)
assert(Four .- Four == Zip)

// MARK: - Division and modulo

assert(Six / Two == Three)
assert(Six / Four == One)
assert(Six % Four == Two)
assert(Five % Three == Two)
assert(Four / Two == Two)
assert(Five / One == Five)
assert(Zip / Three == Zip)

// MARK: - Factorial

assert(factorial(Zip) == One)
assert(factorial(One) == One)
assert(factorial(Three) == Six)
assert(factorial(Four) == #Peano(24))

// MARK: - Fibonacci

assert(fibonacci(Zip) == Zip)
assert(fibonacci(One) == One)
assert(fibonacci(Two) == One)
assert(fibonacci(Three) == Two)
assert(fibonacci(Six) == #Peano(8))

// MARK: - GCD

assert(gcd(Six, Four) == Two)
assert(gcd(Six, Three) == Three)
assert(gcd(Five, Three) == One)
assert(gcd(Four, Six) == Two)
assert(gcd(Six, Zero.self) == Six)

// MARK: - Hyperoperations

assert(hyperop(Zip, Two, Three) == Four)              // H(0, a, b) = S(b)
assert(hyperop(One, Two, Three) == Five)               // H(1, a, b) = a + b
assert(hyperop(Two, Two, Three) == Six)                // H(2, a, b) = a * b
assert(hyperop(Three, Two, Three) == #Peano(8))        // H(3, a, b) = a ** b
assert(hyperop(One, Zip, Zip) == Zip)                  // H(1, 0, 0) = 0
assert(hyperop(Two, Three, Zip) == Zip)                // H(2, a, 0) = 0
assert(hyperop(Three, Two, Zip) == One)                // H(3, a, 0) = 1

// MARK: - Ackermann function

assert(ackermann(Zip, Zip) == One)                     // A(0, 0) = 1
assert(ackermann(Zip, Three) == Four)                  // A(0, n) = n + 1
assert(ackermann(One, One) == Three)                   // A(1, 1) = 3
assert(ackermann(Two, Two) == #Peano(7))               // A(2, 2) = 7
assert(ackermann(Three, One) == #Peano(13))            // A(3, 1) = 13

// MARK: - Church numerals

let c0 = ChurchZero.self
let c1 = ChurchSucc<ChurchZero>.self
let c2 = ChurchSucc<ChurchSucc<ChurchZero>>.self
let c3 = ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self

assert(churchToInt(c0) == 0)
assert(churchToInt(c1) == 1)
assert(churchToInt(c2) == 2)
assert(churchToInt(c3) == 3)

// Church addition: 2 + 3 = 5
assert(churchToInt(ChurchAdd<ChurchSucc<ChurchSucc<ChurchZero>>, ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>>.self) == 5)

// Church multiplication: 2 * 3 = 6
assert(churchToInt(ChurchMul<ChurchSucc<ChurchSucc<ChurchZero>>, ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>>.self) == 6)

// Church macro
assert(churchToInt(#Church(0)) == 0)
assert(churchToInt(#Church(3)) == 3)
assert(churchToInt(#Church(5)) == 5)

// MARK: - Compile-time type equality assertions (verified at build time)

assertEqual(#PeanoType(0), #Peano(0))
assertEqual(#PeanoType(1 + 2), #Peano(3))
assertEqual(#PeanoType(2 * 3), #Peano(6))
assertEqual(#PeanoType(2 * 3 - 1), #Peano(5))
assertEqual(#PeanoType(3 - 5), #Peano(-2))
assertEqual(#PeanoType(0 - 2), #Peano(-2))
assertEqual(#PeanoType(1 * 1), #Peano(1))
assertEqual(#PeanoType(2 ** 3), #Peano(8))
assertEqual(#PeanoType(5 .- 3), #Peano(2))
assertEqual(#PeanoType(6 / 2), #Peano(3))
assertEqual(#PeanoType(6 % 4), #Peano(2))
assertEqual(#PeanoType(factorial(4)), #Peano(24))
assertEqual(#PeanoType(fibonacci(6)), #Peano(8))
assertEqual(#PeanoType(gcd(6, 4)), #Peano(2))
assertEqual(#PeanoType(hyperop(3, 2, 3)), #Peano(8))
assertEqual(#PeanoType(ackermann(2, 2)), #Peano(7))

// MARK: - Compile-time assertions (verified at macro expansion time)

#PeanoAssert(1 + 2 == 3)
#PeanoAssert(2 * 3 == 6)
#PeanoAssert(2 * 3 - 1 == 5)
#PeanoAssert(3 - 5 == -2)
#PeanoAssert(0 - 1 == -1)
#PeanoAssert(1 < 2)
#PeanoAssert(2 > 1)
#PeanoAssert(-1 < 0)
#PeanoAssert(0 <= 0)
#PeanoAssert(3 >= 2)
#PeanoAssert(5 != 3)
#PeanoAssert(2 ** 3 == 8)
#PeanoAssert(5 .- 3 == 2)
#PeanoAssert(3 .- 5 == 0)
#PeanoAssert(6 / 2 == 3)
#PeanoAssert(6 % 4 == 2)
#PeanoAssert(factorial(3) == 6)
#PeanoAssert(fibonacci(6) == 8)
#PeanoAssert(gcd(6, 4) == 2)
#PeanoAssert(hyperop(3, 2, 3) == 8)
#PeanoAssert(hyperop(1, 2, 3) == 5)
#PeanoAssert(ackermann(2, 2) == 7)
#PeanoAssert(ackermann(0, 3) == 4)
