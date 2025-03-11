protocol Natural {
    static var predecessor: Natural.Type { get }
}

enum Zero: Natural {
    static var predecessor: Natural.Type { return self }
}

let Zip = Zero.self

assert(Zip == Zip)
assert(Zip.predecessor == Zip)

enum AddOne<Predecessor: Natural>: Natural {
    static var predecessor: Natural.Type { Predecessor.self }
}

let One = AddOne<Zero>.self

assert(One == One)
assert(One != Zip)
assert(One.predecessor == Zip)

let Two = AddOne<AddOne<Zero>>.self

assert(Two != One)
assert(Two.predecessor == One)

assert(Zip + Zip == Zip)
assert(Zip + One == One)

assert(One + Zip == One)

extension Natural {
    static var successor: Natural.Type { AddOne<Self>.self }
}

assert(Zip.successor == One)
assert(One.successor == Two)

func +(lhs: Natural.Type, rhs: Natural.Type) -> Natural.Type {
    if lhs == Zero.self {
        return rhs
    } else if rhs == Zero.self {
        return lhs
    }
    
    return lhs.predecessor + rhs.successor
}

let Three = Two.successor

assert(One + Two == Three)

func <(lhs: Natural.Type, rhs: Natural.Type) -> Bool {
    if lhs == rhs {
        return false
    }
    
    if lhs == Zero.self {
        return true
    } else if rhs == Zero.self {
        return false
    }
    
    return lhs.predecessor < rhs.predecessor
}

assert(Zip < Zip)
assert(One < Two)
assert(!(Two < One))

extension Natural {
    static func >(lhs: Self.Type, rhs: Natural.Type) -> Bool {
        rhs < lhs
    }
}

assert(Two > One)
assert(!(Zip > Zip))
assert(Two > One)
