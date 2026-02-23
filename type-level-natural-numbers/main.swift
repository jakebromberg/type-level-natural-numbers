// MARK: - Protocol hierarchy

protocol Integer {
    associatedtype Successor: Integer
    associatedtype Predecessor: Integer
    static var successor: Successor.Type { get }
    static var predecessor: Predecessor.Type { get }
}

protocol Natural: Integer where Successor: Positive {}

protocol Positive: Natural where Predecessor: Natural {}

protocol Nonpositive: Integer where Predecessor: Negative {}

protocol Negative: Nonpositive where Successor: Nonpositive {}

// MARK: - Types

enum SubOne<Successor: Nonpositive>: Negative {
    typealias Predecessor = SubOne<Self>
    static var successor: Successor.Type { Successor.self }
    static var predecessor: SubOne<Self>.Type { SubOne<Self>.self }
}

enum Zero: Natural, Nonpositive {
    typealias Successor = AddOne<Zero>
    typealias Predecessor = SubOne<Zero>
    static var successor: AddOne<Zero>.Type { AddOne<Zero>.self }
    static var predecessor: SubOne<Zero>.Type { SubOne<Zero>.self }
}

let Zip = Zero.self

assert(Zip == Zip)

extension Zero {
    static func +(lhs: Zero.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

enum AddOne<Predecessor: Natural>: Positive {
    typealias Successor = AddOne<Self>
    static var predecessor: Predecessor.Type { Predecessor.self }
    static var successor: AddOne<Self>.Type { AddOne<Self>.self }
    
    func callAsFunction(_ p: Predecessor.Type) -> AddOne<Predecessor>.Type {
        return AddOne<Predecessor>.self
    }
}

let One = AddOne<Zero>.self

assert(One == One)
assert(One != Zip)
assert(One.predecessor == Zip)

let Two = One.successor

assert(Two != One)
assert(Two.predecessor == One)

// MARK: - Negative convenience bindings

let MinusOne   = SubOne<Zero>.self
let MinusTwo   = SubOne<SubOne<Zero>>.self
let MinusThree = SubOne<SubOne<SubOne<Zero>>>.self

assert(MinusOne != Zip)
assert(MinusOne != One)
assert(MinusOne.successor == Zip)
assert(MinusTwo.successor == MinusOne)

// MARK: - Natural addition

assert(Zip + Zip == Zip)
assert(Zip + One == One)
assert(One + Zip == One)

func +(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if lhs == Zero.self { return rhs }
    if rhs == Zero.self { return lhs }
    let plhs = lhs as! any Positive.Type
    return plhs.predecessor + rhs.successor
}

func +(lhs: any Natural.Type, rhs: any Positive.Type) -> any Positive.Type {
    if lhs == Zero.self {
        return rhs
    }
    let plhs = lhs as! any Positive.Type
    return plhs.predecessor + rhs.successor
}

func +(lhs: any Positive.Type, rhs: any Natural.Type) -> any Positive.Type {
    if rhs == Zero.self {
        return lhs
    }
    return lhs.predecessor + rhs.successor
}

func +(lhs: any Positive.Type, rhs: any Positive.Type) -> any Positive.Type {
    return lhs.predecessor + rhs.successor
}

let Three = Two.successor

assert(One + Two == Three)

// MARK: - Natural comparison

func <(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    switch (lhs as? any Positive.Type, rhs as? any Positive.Type) {
    case (nil, nil):         return false     // 0 < 0
    case (nil, _):           return true      // 0 < n+1
    case (_, nil):           return false     // n+1 < 0
    case let (lp?, rp?):     return lp.predecessor < rp.predecessor
    }
}

assert(!(Zip < Zip))
assert(One < Two)
assert(!(Two < One))

func >(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    rhs < lhs
}

assert(Two > One)
assert(!(Zip > Zip))
assert(Two > One)

// MARK: - Natural multiplication

extension Natural {
    static func *(lhs: Zero.Type, rhs: Self.Type) -> Zero.Type {
        Zero.self
    }

    static func *(lhs: Self.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

func *(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if lhs == Zero.self || rhs == Zero.self { return Zero.self }
    let plhs = lhs as! any Positive.Type
    if plhs.predecessor == Zero.self { return rhs }    // 1 * m = m
    return plhs.predecessor * rhs + rhs                // n * m = (n-1) * m + m
}

assert(Zero.self * One == Zero.self)
assert(One * Zero.self == Zero.self)
assert(One * Two == Two)

let Four = Three.successor

assert(Two * Two == Four)

let Five = Four.successor
let Six = Five.successor

assert(Two * Three == Six)
assert(Three * Two == Six)
assert(One * One == One)
assert(Four * One == Four)
assert(One * Four == Four)

assert(Two + Two == Four)
assert(Two + Zip == Two)

// MARK: - Negation

func negate(_ n: any Integer.Type) -> any Integer.Type {
    if n == Zero.self { return n }
    if let pos = n as? any Positive.Type {
        return negate(pos.predecessor as any Integer.Type).predecessor
    }
    let neg = n as! any Negative.Type
    return negate(neg.successor as any Integer.Type).successor
}

assert(negate(Zip) == Zip)
assert(negate(One) == MinusOne)
assert(negate(MinusOne) == One)
assert(negate(Two) == MinusTwo)
assert(negate(MinusTwo) == Two)

// MARK: - Integer addition

func +(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if lhs == Zero.self { return rhs }
    if rhs == Zero.self { return lhs }
    if let pos = lhs as? any Positive.Type {
        return (pos.predecessor as any Integer.Type) + rhs.successor   // (n+1) + m = n + (m+1)
    }
    let neg = lhs as! any Negative.Type
    return (neg.successor as any Integer.Type) + rhs.predecessor       // (n-1) + m = n + (m-1)
}

assert(One + MinusOne == Zip)
assert(MinusOne + One == Zip)
assert(MinusOne + MinusOne == MinusTwo)
assert(Three + MinusTwo == One)
assert(MinusTwo + Three == One)

// MARK: - Subtraction

func -(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    lhs + negate(rhs)
}

assert(Three - Two == One)
assert(Two - Three == MinusOne)
assert(Zip - One == MinusOne)
assert(One - Zip == One)
assert(MinusOne - MinusOne == Zip)

// MARK: - Integer multiplication

func *(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if lhs == Zero.self || rhs == Zero.self { return Zero.self }
    if let pos = lhs as? any Positive.Type {
        if pos.predecessor == Zero.self { return rhs }                        // 1 * m = m
        return (pos.predecessor as any Integer.Type) * rhs + rhs              // (n+1) * m = n*m + m
    }
    let neg = lhs as! any Negative.Type
    if neg.successor == Zero.self { return negate(rhs) }                      // (-1) * m = -m
    return (neg.successor as any Integer.Type) * rhs - rhs                    // (n-1) * m = n*m - m
}

assert(MinusOne * One == MinusOne)
assert(MinusOne * MinusOne == One)
assert(Two * MinusThree == negate(Six))
assert(MinusTwo * Three == negate(Six))
assert(MinusTwo * MinusThree == Six)

// MARK: - Integer comparison

func <(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    if lhs is any Negative.Type && !(rhs is any Negative.Type) { return true }
    if !(lhs is any Negative.Type) && rhs is any Negative.Type { return false }
    if let ln = lhs as? any Natural.Type, let rn = rhs as? any Natural.Type {
        return ln < rn  // both nonnegative -- use Natural overload
    }
    // both negative: SubOne<a> < SubOne<b> iff a < b
    return lhs.successor < rhs.successor
}

func >(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    rhs < lhs
}

assert(MinusOne < Zip)
assert(MinusTwo < MinusOne)
assert(!(MinusOne < MinusOne))
assert(MinusOne < One)
assert(!(One < MinusOne))
assert(One > MinusOne)
assert(MinusOne > MinusTwo)
