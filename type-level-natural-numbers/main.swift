protocol Natural {
    static var Predecessor : Natural.Type { get }
}

enum Zero : Natural {
    static var Predecessor: Natural.Type { return self }
}

let Zilch = Zero.self

assert(Zilch == Zilch)
assert(Zilch.Predecessor == Zilch)

enum Positive<ConcretePredecessor: Natural> : Natural {
    static var Predecessor: Natural.Type { return ConcretePredecessor.self }
}

let One = Positive<Zero>.self

assert(One == One)
assert(One != Zilch)
assert(One.Predecessor == Zilch)

let Two = Positive<Positive<Zero>>.self

assert(Two != One)
assert(Two.Predecessor == One)

func +(lhs: Zero.Type, rhs: Zero.Type) -> Zero.Type {
    return Zero.self
}

assert(Zilch + Zilch == Zilch)

func +<T: Natural>(lhs: Zero.Type, rhs: T.Type) -> T.Type {
    return T.self
}

assert(Zilch + One == One)

func +<T: Natural>(lhs: T.Type, rhs: Zero.Type) -> T.Type {
    return T.self
}

assert(One + Zilch == One)

extension Natural {
    static var Successor: Natural.Type { return Positive<Self>.self }
}

assert(Zilch.Successor == One)
assert(One.Successor == Two)

func +(lhs: Natural.Type, rhs: Natural.Type) -> Natural.Type {
    if lhs == Zero.self {
        return rhs
    }
    
    return (lhs.Predecessor + rhs.Successor)
}

assert(One + Two == Two.Successor)
assert(One.Predecessor + One == One)

func <(lhs: Natural.Type, rhs: Natural.Type) -> Bool {
    if lhs == rhs {
        return false
    }
    
    if lhs == Zero.self {
        return true
    } else if rhs == Zero.self {
        return false
    }
    
    return (lhs.Predecessor < rhs.Predecessor)
}

assert(One < Two)

func >(lhs: Natural.Type, rhs: Natural.Type) -> Bool {
    return !(lhs.Predecessor < rhs.Predecessor)
}

assert(Two > One)
