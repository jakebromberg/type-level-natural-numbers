// MARK: - Protocol hierarchy

public protocol Integer {
    associatedtype Successor: Integer
    associatedtype Predecessor: Integer
    static var successor: Successor.Type { get }
    static var predecessor: Predecessor.Type { get }
}

public protocol Natural: Integer where Successor: Natural {}

public protocol Nonpositive: Integer where Predecessor: Nonpositive {}

// MARK: - Types

public enum SubOne<Successor: Nonpositive>: Nonpositive {
    public typealias Predecessor = SubOne<Self>
    public static var successor: Successor.Type { Successor.self }
    public static var predecessor: SubOne<Self>.Type { SubOne<Self>.self }
}

public enum Zero: Natural, Nonpositive {
    public typealias Successor = AddOne<Zero>
    public typealias Predecessor = SubOne<Zero>
    public static var successor: AddOne<Zero>.Type { AddOne<Zero>.self }
    public static var predecessor: SubOne<Zero>.Type { SubOne<Zero>.self }
}

public extension Zero {
    static func +(lhs: Zero.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

public enum AddOne<Predecessor: Natural>: Natural {
    public typealias Successor = AddOne<Self>
    public static var predecessor: Predecessor.Type { Predecessor.self }
    public static var successor: AddOne<Self>.Type { AddOne<Self>.self }
}

// MARK: - Natural addition (right-hand recursion)

public func +(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self { return lhs }                              // a + 0 = a
    return (lhs + (rhs.predecessor as! any Natural.Type)).successor // a + S(b) = S(a + b)
}

// MARK: - Natural comparison (right-hand recursion)

public func <(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    if rhs == Zero.self { return false }                            // a < 0 = false
    if lhs == Zero.self { return true }                             // 0 < S(b) = true
    return (lhs.predecessor as! any Natural.Type) < (rhs.predecessor as! any Natural.Type)
}

public func >(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    rhs < lhs
}

public func <=(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    !(rhs < lhs)
}

public func >=(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    !(lhs < rhs)
}

// MARK: - Natural multiplication (right-hand recursion)

public extension Natural {
    static func *(lhs: Zero.Type, rhs: Self.Type) -> Zero.Type {
        Zero.self
    }

    static func *(lhs: Self.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

public func *(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self { return Zero.self }                        // a * 0 = 0
    return lhs * (rhs.predecessor as! any Natural.Type) + lhs      // a * S(b) = a*b + a
}

// MARK: - Negation

public func negate(_ n: any Integer.Type) -> any Integer.Type {
    if n == Zero.self { return n }
    if let nat = n as? any Natural.Type {
        return negate(nat.predecessor as any Integer.Type).predecessor
    }
    return negate(n.successor as any Integer.Type).successor
}

// MARK: - Integer addition (right-hand recursion on rhs)

public func +(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if rhs == Zero.self { return lhs }                              // a + 0 = a
    if rhs is any Natural.Type {
        return ((lhs + (rhs.predecessor as any Integer.Type)) as any Integer.Type).successor
    }
    return ((lhs + (rhs.successor as any Integer.Type)) as any Integer.Type).predecessor
}

// MARK: - Subtraction

public func -(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    lhs + negate(rhs)
}

// MARK: - Integer multiplication (right-hand recursion on rhs)

public func *(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if lhs == Zero.self || rhs == Zero.self { return Zero.self }
    if rhs is any Natural.Type {
        return (lhs * (rhs.predecessor as any Integer.Type)) + lhs  // a * S(b) = a*b + a
    }
    return (lhs * (rhs.successor as any Integer.Type)) - lhs       // a * P(b) = a*b - a
}

// MARK: - Integer comparison

public func <(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    if let ln = lhs as? any Natural.Type, let rn = rhs as? any Natural.Type {
        return ln < rn
    }
    if lhs is any Natural.Type { return false }  // nonneg >= negative
    if rhs is any Natural.Type { return true }   // negative < nonneg
    // both negative
    return lhs.successor < rhs.successor
}

public func >(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    rhs < lhs
}

public func <=(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    !(rhs < lhs)
}

public func >=(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    !(lhs < rhs)
}

// MARK: - Exponentiation (right-hand recursion on exponent)

infix operator ** : MultiplicationPrecedence

/// Int exponentiation (enables `**` in macro expressions like `#PeanoType(2 ** 3)`).
public func **(base: Int, exp: Int) -> Int {
    if exp == 0 { return 1 }
    var result = 1
    for _ in 0..<exp { result *= base }
    return result
}

/// Natural exponentiation: `a ** 0 = 1`, `a ** S(b) = a ** b * a`.
public func **(base: any Natural.Type, exp: any Natural.Type) -> any Natural.Type {
    if exp == Zero.self { return AddOne<Zero>.self }                     // a ** 0 = 1
    return (base ** (exp.predecessor as! any Natural.Type)) * base      // a ** S(b) = a**b * a
}

/// Integer exponentiation with natural exponent.
/// Negative base with natural exponent (e.g. `(-2) ** 3 = -8`).
public func **(base: any Integer.Type, exp: any Natural.Type) -> any Integer.Type {
    if exp == Zero.self { return AddOne<Zero>.self }                     // a ** 0 = 1
    return (base ** (exp.predecessor as! any Natural.Type)) * base      // a ** S(b) = a**b * a
}

// MARK: - Truncated subtraction / monus

infix operator .- : AdditionPrecedence

/// Int monus (enables `.-` in macro expressions like `#PeanoType(5 .- 3)`).
public func .-(lhs: Int, rhs: Int) -> Int {
    max(lhs - rhs, 0)
}

/// Monus (truncated subtraction): `a .- 0 = a`, `0 .- b = 0`, `S(a) .- S(b) = a .- b`.
/// Returns 0 when `rhs > lhs`.
public func .-(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    if rhs == Zero.self { return lhs }                                  // a .- 0 = a
    if lhs == Zero.self { return Zero.self }                            // 0 .- b = 0
    return (lhs.predecessor as! any Natural.Type) .- (rhs.predecessor as! any Natural.Type)
}

// MARK: - Division and modulo

/// Division and modulo via repeated subtraction.
/// Returns `(quotient, remainder)` where `a = q * b + r` and `0 <= r < b`.
/// Precondition: `b != 0`.
public func divmod(_ a: any Natural.Type, _ b: any Natural.Type) -> (any Natural.Type, any Natural.Type) {
    if a < b { return (Zero.self, a) }
    let (q, r) = divmod(a .- b, b)
    return (q + AddOne<Zero>.self, r)
}

/// Natural division (truncated). Precondition: `rhs != 0`.
public func /(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    divmod(lhs, rhs).0
}

/// Natural modulo. Precondition: `rhs != 0`.
public func %(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    divmod(lhs, rhs).1
}

// MARK: - Factorial

/// Int factorial (enables `factorial()` in macro expressions like `#PeanoType(factorial(4))`).
public func factorial(_ n: Int) -> Int {
    (1...max(1, n)).reduce(1, *)
}

/// Factorial: `fact(0) = 1`, `fact(S(n)) = S(n) * fact(n)`.
public func factorial(_ n: any Natural.Type) -> any Natural.Type {
    if n == Zero.self { return AddOne<Zero>.self }
    return n * factorial(n.predecessor as! any Natural.Type)
}

// MARK: - Fibonacci

/// Int fibonacci (enables `fibonacci()` in macro expressions like `#PeanoType(fibonacci(6))`).
public func fibonacci(_ n: Int) -> Int {
    var a = 0, b = 1
    for _ in 0..<n { (a, b) = (b, a + b) }
    return a
}

/// Fibonacci: `fib(0) = 0`, `fib(1) = 1`, `fib(n) = fib(n-1) + fib(n-2)`.
/// Uses an iterative helper with accumulators to avoid exponential recursion.
public func fibonacci(_ n: any Natural.Type) -> any Natural.Type {
    func helper(_ n: any Natural.Type, _ a: any Natural.Type, _ b: any Natural.Type) -> any Natural.Type {
        if n == Zero.self { return a }
        return helper(n.predecessor as! any Natural.Type, b, a + b)
    }
    return helper(n, Zero.self, AddOne<Zero>.self)
}

// MARK: - GCD

/// Int GCD (enables `gcd()` in macro expressions like `#PeanoType(gcd(6, 4))`).
public func gcd(_ a: Int, _ b: Int) -> Int {
    b == 0 ? a : gcd(b, a % b)
}

/// Greatest common divisor via Euclidean algorithm: `gcd(a, 0) = a`, `gcd(a, b) = gcd(b, a % b)`.
public func gcd(_ a: any Natural.Type, _ b: any Natural.Type) -> any Natural.Type {
    if b == Zero.self { return a }
    return gcd(b, a % b)
}

// MARK: - Type equality assertions

/// Compile-time type equality assertion. Compiles only when both arguments
/// have the same concrete type. The body is intentionally empty -- the
/// assertion is the successful compilation itself.
public func assertEqual<T: Integer>(_: T.Type, _: T.Type) {}

/// Runtime type equality assertion for use with existential metatypes
/// (e.g. values returned by macros). For compile-time assertions, use
/// `#PeanoAssert` instead.
public func assertEqual(_ a: any Integer.Type, _ b: any Integer.Type) {
    assert(a == b, "assertEqual failed: \(a) != \(b)")
}
