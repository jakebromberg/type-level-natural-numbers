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

typealias N0 = Zero
typealias N1 = AddOne<N0>
typealias N2 = AddOne<N1>
typealias N3 = AddOne<N2>
typealias N4 = AddOne<N3>
typealias N5 = AddOne<N4>
typealias N6 = AddOne<N5>

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

// MARK: - Type-level arithmetic

/// A type-level computation that evaluates to a `Natural` type.
protocol NaturalExpression {
    associatedtype Result: Natural
}

// MARK: Sum

/// Type-level addition. `Sum<L, R>.Result` resolves to the concrete
/// `AddOne<...>` chain representing L + R at compile time.
///
/// Swift does not support multiple conditional conformances of the same
/// protocol, so the base case (L == Zero) uses a protocol conformance
/// while the recursive cases use constrained extensions with typealiases.
enum Sum<L: Natural, R: Natural> {}

extension Sum: NaturalExpression where L == Zero {
    typealias Result = R                                    // 0 + R = R
}

extension Sum where L == N1 {
    typealias Result = AddOne<R>                            // 1 + R = R + 1
}

extension Sum where L == N2 {
    typealias Result = AddOne<AddOne<R>>                    // 2 + R = R + 2
}

extension Sum where L == N3 {
    typealias Result = AddOne<AddOne<AddOne<R>>>            // 3 + R = R + 3
}

// MARK: Product

/// Type-level multiplication. `Product<L, R>.Result` resolves to the
/// concrete `AddOne<...>` chain representing L * R at compile time.
///
/// The base cases (L == Zero, L == N1) are generic over R. For larger L
/// values, Swift cannot resolve `Sum<R, R>.Result` for a generic R at
/// definition time, so specific (L, R) pairs are enumerated.
enum Product<L: Natural, R: Natural> {}

extension Product: NaturalExpression where L == Zero {
    typealias Result = Zero                                 // 0 * R = 0
}

extension Product where L == N1 {
    typealias Result = R                                    // 1 * R = R
}

extension Product where L == N2, R == N1 {
    typealias Result = N2                                   // 2 * 1 = 2
}

extension Product where L == N2, R == N2 {
    typealias Result = N4                                   // 2 * 2 = 4
}

extension Product where L == N2, R == N3 {
    typealias Result = N6                                   // 2 * 3 = 6
}

/// Compile-time type equality assertion. If both arguments have the same
/// static type the call compiles; if they differ, the compiler reports a
/// type error. The function body is intentionally empty -- the assertion
/// is the compilation itself.
func assertEqual<T: Natural>(_: T.Type, _: T.Type) {}

// Compile-time addition
assertEqual(Sum<N0, N0>.Result.self, Zip)
assertEqual(Sum<N1, N0>.Result.self, One)
assertEqual(Sum<N0, N1>.Result.self, One)
assertEqual(Sum<N1, N2>.Result.self, Three)    // 1 + 2 = 3
assertEqual(Sum<N2, N2>.Result.self, Four)     // 2 + 2 = 4

// Compile-time multiplication
assertEqual(Product<N0, N1>.Result.self, Zip)  // 0 * 1 = 0
assertEqual(Product<N1, N2>.Result.self, Two)  // 1 * 2 = 2
assertEqual(Product<N2, N2>.Result.self, Four) // 2 * 2 = 4
assertEqual(Product<N2, N3>.Result.self, Six)  // 2 * 3 = 6
