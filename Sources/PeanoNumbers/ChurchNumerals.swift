// MARK: - Church numeral protocol

/// A Church numeral encodes a natural number as a function that applies
/// its argument n times: `church(n)(f)(x) = f^n(x)`.
///
/// This is a second encoding strategy alongside Peano types. Where Peano
/// types encode the *structure* of a number (nested successors), Church
/// numerals encode the *behavior* (function application count).
public protocol ChurchNumeral {
    /// Apply a function `n` times to a value.
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T
}

// MARK: - Church types

/// Church encoding of zero: applies `f` zero times, returning `x` unchanged.
public enum ChurchZero: ChurchNumeral {
    public static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T { x }
}

/// Church encoding of the successor: applies `f` one more time than `N`.
public enum ChurchSucc<N: ChurchNumeral>: ChurchNumeral {
    public static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T {
        f(N.apply(f, to: x))
    }
}

// MARK: - Church arithmetic (type-level)

/// Church addition: `(a + b)(f)(x) = a(f)(b(f)(x))`.
/// Applies `f` a total of `a + b` times by composing the two Church numerals.
public enum ChurchAdd<A: ChurchNumeral, B: ChurchNumeral>: ChurchNumeral {
    public static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T {
        A.apply(f, to: B.apply(f, to: x))
    }
}

/// Church multiplication: `(a * b)(f)(x) = a(b(f))(x)`.
/// Applies `b(f)` (which applies `f` b times) a total of `a` times.
public enum ChurchMul<A: ChurchNumeral, B: ChurchNumeral>: ChurchNumeral {
    public static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T {
        A.apply({ B.apply(f, to: $0) }, to: x)
    }
}
