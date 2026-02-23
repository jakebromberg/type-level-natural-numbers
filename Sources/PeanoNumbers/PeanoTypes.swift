// MARK: - Protocol hierarchy

public protocol Integer {
    associatedtype Successor: Integer
    associatedtype Predecessor: Integer
    static var successor: Successor.Type { get }
    static var predecessor: Predecessor.Type { get }
}

public protocol Natural: Integer where Successor: Positive {}

public protocol Positive: Natural where Predecessor: Natural {}

public protocol Nonpositive: Integer where Predecessor: Negative {}

public protocol Negative: Nonpositive where Successor: Nonpositive {}

// MARK: - Types

public enum SubOne<Successor: Nonpositive>: Negative {
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

public enum AddOne<Predecessor: Natural>: Positive {
    public typealias Successor = AddOne<Self>
    public static var predecessor: Predecessor.Type { Predecessor.self }
    public static var successor: AddOne<Self>.Type { AddOne<Self>.self }
}

// MARK: - Natural addition

public func +(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    guard let pos = lhs as? any Positive.Type else { return rhs }  // 0 + m = m
    if rhs == Zero.self { return lhs }                              // n + 0 = n
    return pos.predecessor + rhs.successor                          // (n+1) + m = n + (m+1)
}

public func +(lhs: any Natural.Type, rhs: any Positive.Type) -> any Positive.Type {
    guard let pos = lhs as? any Positive.Type else { return rhs }
    return pos.predecessor + rhs.successor
}

public func +(lhs: any Positive.Type, rhs: any Natural.Type) -> any Positive.Type {
    if rhs == Zero.self {
        return lhs
    }
    return lhs.predecessor + rhs.successor
}

public func +(lhs: any Positive.Type, rhs: any Positive.Type) -> any Positive.Type {
    return lhs.predecessor + rhs.successor
}

// MARK: - Natural comparison

public func <(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    switch (lhs as? any Positive.Type, rhs as? any Positive.Type) {
    case (nil, nil):         return false     // 0 < 0
    case (nil, _):           return true      // 0 < n+1
    case (_, nil):           return false     // n+1 < 0
    case let (lp?, rp?):     return lp.predecessor < rp.predecessor
    }
}

public func >(lhs: any Natural.Type, rhs: any Natural.Type) -> Bool {
    rhs < lhs
}

// MARK: - Natural multiplication

public extension Natural {
    static func *(lhs: Zero.Type, rhs: Self.Type) -> Zero.Type {
        Zero.self
    }

    static func *(lhs: Self.Type, rhs: Zero.Type) -> Zero.Type {
        Zero.self
    }
}

public func *(lhs: any Natural.Type, rhs: any Natural.Type) -> any Natural.Type {
    guard let pos = lhs as? any Positive.Type else { return Zero.self }  // 0 * m = 0
    if rhs == Zero.self { return Zero.self }                              // n * 0 = 0
    if pos.predecessor == Zero.self { return rhs }                        // 1 * m = m
    return pos.predecessor * rhs + rhs                                    // (n+1) * m = n*m + m
}

// MARK: - Negation

public func negate(_ n: any Integer.Type) -> any Integer.Type {
    if n == Zero.self { return n }
    if let pos = n as? any Positive.Type {
        return negate(pos.predecessor as any Integer.Type).predecessor
    }
    let neg = n as! any Negative.Type
    return negate(neg.successor as any Integer.Type).successor
}

// MARK: - Integer addition

public func +(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if lhs == Zero.self { return rhs }
    if rhs == Zero.self { return lhs }
    if let pos = lhs as? any Positive.Type {
        return (pos.predecessor as any Integer.Type) + rhs.successor   // (n+1) + m = n + (m+1)
    }
    let neg = lhs as! any Negative.Type
    return (neg.successor as any Integer.Type) + rhs.predecessor       // (n-1) + m = n + (m-1)
}

// MARK: - Subtraction

public func -(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    lhs + negate(rhs)
}

// MARK: - Integer multiplication

public func *(lhs: any Integer.Type, rhs: any Integer.Type) -> any Integer.Type {
    if lhs == Zero.self || rhs == Zero.self { return Zero.self }
    if let pos = lhs as? any Positive.Type {
        if pos.predecessor == Zero.self { return rhs }                        // 1 * m = m
        return (pos.predecessor as any Integer.Type) * rhs + rhs              // (n+1) * m = n*m + m
    }
    let neg = lhs as! any Negative.Type
    if neg.successor == Zero.self { return negate(rhs) }                      // (-1) * m = -m
    return (neg.successor as any Integer.Type) * rhs - rhs                    // (n-1) * m = n*m - m
}

// MARK: - Integer comparison

public func <(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    if lhs is any Negative.Type && !(rhs is any Negative.Type) { return true }
    if !(lhs is any Negative.Type) && rhs is any Negative.Type { return false }
    if let ln = lhs as? any Natural.Type, let rn = rhs as? any Natural.Type {
        return ln < rn  // both nonnegative -- use Natural overload
    }
    // both negative: SubOne<a> < SubOne<b> iff a < b
    return lhs.successor < rhs.successor
}

public func >(lhs: any Integer.Type, rhs: any Integer.Type) -> Bool {
    rhs < lhs
}

// MARK: - Compile-time type equality assertion

/// Compile-time type equality assertion. Compiles only when both arguments
/// have the same concrete type. The body is intentionally empty -- the
/// assertion is the successful compilation itself.
public func assertEqual<T: Integer>(_: T.Type, _: T.Type) {}
