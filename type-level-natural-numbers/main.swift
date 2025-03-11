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

func +(lhs: any Natural.Type, rhs: any Positive.Type) -> any Natural.Type {
    if lhs == Zero.self {
        return rhs
    }
    
    return lhs.successor + rhs.predecessor
}

func +(lhs: any Positive.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self {
        return lhs
    }
    
    return lhs.predecessor + rhs.successor
}

func +(lhs: any Positive.Type, rhs: any Positive.Type) -> any Natural.Type {
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
