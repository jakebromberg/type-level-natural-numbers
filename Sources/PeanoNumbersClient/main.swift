import PeanoNumbers

// MARK: - Convenience bindings

let Zip = Zero.self

let One      = AddOne<Zero>.self
let Two      = One.successor
let Three    = Two.successor
let Four     = Three.successor
let Five     = Four.successor
let Six      = Five.successor

let MinusOne   = SubOne<Zero>.self
let MinusTwo   = SubOne<SubOne<Zero>>.self
let MinusThree = SubOne<SubOne<SubOne<Zero>>>.self

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

// MARK: - Natural addition

assert(Zip + Zip == Zip)
assert(Zip + One == One)
assert(One + Zip == One)
assert(One + Two == Three)
assert(Two + Two == Four)
assert(Two + Zip == Two)

// MARK: - Natural comparison

assert(!(Zip < Zip))
assert(One < Two)
assert(!(Two < One))
assert(Two > One)
assert(!(Zip > Zip))

// MARK: - Natural multiplication

assert(Zero.self * One == Zero.self)
assert(One * Zero.self == Zero.self)
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
