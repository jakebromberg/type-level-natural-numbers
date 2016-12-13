protocol Natural {
    static var Predecessor : Natural.Type { get }
}

enum Positive<ConcretePredecessor: Natural> : Natural {
    static var Predecessor: Natural.Type { return ConcretePredecessor.self }
}

enum Zero : Natural {
    static var Predecessor: Natural.Type { return self }
}

extension Natural {
    static var Successor: Natural.Type { return Positive<Self>.self }
}

let Zilch = Zero.self
let One = Positive<Zero>.self
let Two = Positive<Positive<Zero>>.self

assert(One == Two.Predecessor)
assert(One.Successor == Two)

func +(lhs: Natural.Type, rhs: Natural.Type) -> Natural.Type {
    if lhs == Zero.self {
        return rhs
    } else if rhs == Zero.self {
        return lhs
    }
    
    return (lhs.Predecessor + rhs.Successor)
}

assert(Zilch + Zilch == Zilch)
assert(Zilch + One == One)
assert(One + Zilch == One)
assert(Zilch + One == One)
assert(One + Zilch == One)

let Three = Two.Successor
let Four = Three.Successor

assert(Two + Two == Four)
