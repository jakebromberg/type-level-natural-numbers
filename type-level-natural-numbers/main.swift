protocol Natural {
    associatedtype Successor: Positive
    static var successor: Successor.Type { get }
}

protocol Positive: Natural {
    associatedtype Predecessor: Natural
    static var predecessor: Predecessor.Type { get }
}

enum Zero: Natural {
    static var successor: AddOne<Zero>.Type { AddOne<Zero>.self }
}

let Zip = Zero.self

assert(Zip == Zip)

extension Zero {
    static func +(lhs: Zero.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

enum AddOne<Predecessor: Natural>: Positive {
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

func <<T: Natural, U: Natural>(lhs: T.Type, rhs: U.Type) -> Bool {
    if lhs == rhs {
        return false
    }
    
    if lhs == Zero.self {
        return true
    } else if rhs == Zero.self {
        return false
    }
    
    fatalError()
}

func <<T: Positive, U: Positive>(lhs: T.Type, rhs: U.Type) -> Bool {
    if lhs == rhs {
        return false
    }
    
    return lhs.predecessor < rhs.predecessor
}

assert(!(Zip < Zip))
assert(One < Two)
assert(!(Two < One))

func ><T: Natural, U: Natural>(lhs: T.Type, rhs: U.Type) -> Bool {
    rhs < lhs
}

func ><T: Positive, U: Positive>(lhs: T.Type, rhs: U.Type) -> Bool {
    rhs < lhs
}

assert(Two > One)
assert(!(Zip > Zip))
assert(Two > One)

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
