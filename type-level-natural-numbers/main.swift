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

let Four = Three.successor
let Five = Four.successor
let Six = Five.successor

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
