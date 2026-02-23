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
