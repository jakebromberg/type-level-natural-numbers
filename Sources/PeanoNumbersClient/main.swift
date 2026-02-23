import PeanoNumbers

// MARK: - Convenience bindings

let Zip        = #Peano(0)
let One        = #Peano(1)
let Two        = #Peano(2)
let Three      = #Peano(3)
let Four       = #Peano(4)
let Five       = #Peano(5)
let Six        = #Peano(6)

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

// MARK: - Compile-time type equality assertions (verified at build time)

assertEqual(#PeanoType(0), #Peano(0))
assertEqual(#PeanoType(1 + 2), #Peano(3))
assertEqual(#PeanoType(2 * 3), #Peano(6))
assertEqual(#PeanoType(2 * 3 - 1), #Peano(5))
assertEqual(#PeanoType(3 - 5), #Peano(-2))
assertEqual(#PeanoType(0 - 2), #Peano(-2))
assertEqual(#PeanoType(1 * 1), #Peano(1))

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
