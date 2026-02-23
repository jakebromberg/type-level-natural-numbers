// MARK: - Protocol hierarchy

protocol Integer {
    associatedtype Successor: Integer
    associatedtype Predecessor: Integer
    static var successor: Successor.Type { get }
    static var predecessor: Predecessor.Type { get }
}

protocol Natural: Integer where Successor: Natural {}

protocol Nonpositive: Integer where Predecessor: Nonpositive {}

// MARK: - Types

enum SubOne<Successor: Nonpositive>: Nonpositive {
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

enum AddOne<Predecessor: Natural>: Natural {
    typealias Successor = AddOne<Self>
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

// MARK: - Negative convenience bindings

let MinusOne   = SubOne<Zero>.self
let MinusTwo   = SubOne<SubOne<Zero>>.self
let MinusThree = SubOne<SubOne<SubOne<Zero>>>.self

assert(MinusOne != Zip)
assert(MinusOne != One)
assert(MinusOne.successor == Zip)
assert(MinusTwo.successor == MinusOne)

// MARK: - Natural addition (right-hand recursion)

assert(Zip + Zip == Zip)
assert(Zip + One == One)
assert(One + Zip == One)

func +(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self { return lhs }                              // a + 0 = a
    return (lhs + (rhs.predecessor as! any Natural.Type)).successor // a + S(b) = S(a + b)
}

let Three = Two.successor

assert(One + Two == Three)

// MARK: - Natural comparison (right-hand recursion)

func <(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    if rhs == Zero.self { return false }                            // a < 0 = false
    if lhs == Zero.self { return true }                             // 0 < S(b) = true
    return (lhs.predecessor as! any Natural.Type) < (rhs.predecessor as! any Natural.Type)
}

assert(!(Zip < Zip))
assert(One < Two)
assert(!(Two < One))

func >(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    rhs < lhs
}

assert(Two > One)
assert(!(Zip > Zip))

func <=(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    !(rhs < lhs)
}

func >=(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    !(lhs < rhs)
}

assert(Zip <= Zip)
assert(One <= Two)
assert(Two <= Two)
assert(!(Two <= One))
assert(Zip >= Zip)
assert(Two >= One)
assert(Two >= Two)
assert(!(One >= Two))

// MARK: - Natural multiplication (right-hand recursion)

extension Natural {
    static func *(lhs: Zero.Type, rhs: Self.Type) -> Zero.Type {
        Zero.self
    }

    static func *(lhs: Self.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

func *(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self { return Zero.self }                        // a * 0 = 0
    return lhs * (rhs.predecessor as! any Natural.Type) + lhs      // a * S(b) = a*b + a
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
    if let nat = n as? any Natural.Type {
        return negate(nat.predecessor as any Integer.Type).predecessor
    }
    return negate(n.successor as any Integer.Type).successor
}

assert(negate(Zip) == Zip)
assert(negate(One) == MinusOne)
assert(negate(MinusOne) == One)
assert(negate(Two) == MinusTwo)
assert(negate(MinusTwo) == Two)

// MARK: - Integer addition (right-hand recursion on rhs)

func +(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if rhs == Zero.self { return lhs }                              // a + 0 = a
    if rhs is any Natural.Type {
        return ((lhs + (rhs.predecessor as any Integer.Type)) as any Integer.Type).successor
    }
    return ((lhs + (rhs.successor as any Integer.Type)) as any Integer.Type).predecessor
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

// MARK: - Integer multiplication (right-hand recursion on rhs)

func *(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if lhs == Zero.self || rhs == Zero.self { return Zero.self }
    if rhs is any Natural.Type {
        return (lhs * (rhs.predecessor as any Integer.Type)) + lhs  // a * S(b) = a*b + a
    }
    return (lhs * (rhs.successor as any Integer.Type)) - lhs       // a * P(b) = a*b - a
}

assert(MinusOne * One == MinusOne)
assert(MinusOne * MinusOne == One)
assert(Two * MinusThree == negate(Six))
assert(MinusTwo * Three == negate(Six))
assert(MinusTwo * MinusThree == Six)

// MARK: - Integer comparison

func <(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    if let ln = lhs as? any Natural.Type, let rn = rhs as? any Natural.Type {
        return ln < rn
    }
    if lhs is any Natural.Type { return false }  // nonneg >= negative
    if rhs is any Natural.Type { return true }   // negative < nonneg
    // both negative
    return lhs.successor < rhs.successor
}

func >(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    rhs < lhs
}

func <=(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    !(rhs < lhs)
}

func >=(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    !(lhs < rhs)
}

assert(MinusOne < Zip)
assert(MinusTwo < MinusOne)
assert(!(MinusOne < MinusOne))
assert(MinusOne < One)
assert(!(One < MinusOne))
assert(One > MinusOne)
assert(MinusOne > MinusTwo)

assert(MinusOne <= Zip)
assert(MinusOne <= MinusOne)
assert(!(Zip <= MinusOne))
assert(Zip >= MinusOne)
assert(MinusOne >= MinusOne)
assert(!(MinusOne >= Zip))

// MARK: - Exponentiation (right-hand recursion on exponent)

infix operator ** : MultiplicationPrecedence

func **(base: any Natural.Type, exp: any Natural.Type) -> any Natural.Type {
    if exp == Zero.self { return AddOne<Zero>.self }
    return (base ** (exp.predecessor as! any Natural.Type)) * base
}

func **(base: any Integer.Type, exp: any Natural.Type) -> any Integer.Type {
    if exp == Zero.self { return AddOne<Zero>.self }
    return (base ** (exp.predecessor as! any Natural.Type)) * base
}

assert(Two ** Three == AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>>>.self)
assert(Three ** Two == AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>>>>.self)
assert(Two ** Zip == One)
assert(Zip ** Five == Zip)
assert(One ** Six == One)

// MARK: - Monus (truncated subtraction)

infix operator .- : AdditionPrecedence

func .-(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self { return lhs }
    if lhs == Zero.self { return Zero.self }
    return (lhs.predecessor as! any Natural.Type) .- (rhs.predecessor as! any Natural.Type)
}

assert(Five .- Three == Two)
assert(Three .- Five == Zip)
assert(Three .- Zip == Three)
assert(Zip .- Five == Zip)
assert(Four .- Four == Zip)

// MARK: - Division and modulo

func divmod(_ a: any Natural.Type, _ b: any Natural.Type) -> (any Natural.Type, any Natural.Type) {
    if a < b { return (Zero.self, a) }
    let (q, r) = divmod(a .- b, b)
    return (q + AddOne<Zero>.self, r)
}

func /(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    divmod(lhs, rhs).0
}

func %(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    divmod(lhs, rhs).1
}

assert(Six / Two == Three)
assert(Six / Four == One)
assert(Six % Four == Two)
assert(Five % Three == Two)
assert(Four / Two == Two)
assert(Five / One == Five)
assert(Zip / Three == Zip)

// MARK: - Factorial

func factorial(_ n: any Natural.Type) -> any Natural.Type {
    if n == Zero.self { return AddOne<Zero>.self }
    return n * factorial(n.predecessor as! any Natural.Type)
}

assert(factorial(Zip) == One)
assert(factorial(One) == One)
assert(factorial(Three) == Six)

// MARK: - Fibonacci

func fibonacci(_ n: any Natural.Type) -> any Natural.Type {
    func helper(_ n: any Natural.Type, _ a: any Natural.Type, _ b: any Natural.Type) -> any Natural.Type {
        if n == Zero.self { return a }
        return helper(n.predecessor as! any Natural.Type, b, a + b)
    }
    return helper(n, Zero.self, AddOne<Zero>.self)
}

assert(fibonacci(Zip) == Zip)
assert(fibonacci(One) == One)
assert(fibonacci(Two) == One)
assert(fibonacci(Three) == Two)

// MARK: - GCD

func gcd(_ a: any Natural.Type, _ b: any Natural.Type) -> any Natural.Type {
    if b == Zero.self { return a }
    return gcd(b, a % b)
}

assert(gcd(Six, Four) == Two)
assert(gcd(Six, Three) == Three)
assert(gcd(Five, Three) == One)
assert(gcd(Four, Six) == Two)
assert(gcd(Six, Zero.self) == Six)
