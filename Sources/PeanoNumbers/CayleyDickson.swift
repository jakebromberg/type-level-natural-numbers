// MARK: - Algebra protocol

/// Root protocol for types in the Cayley-Dickson algebra hierarchy.
///
/// The Cayley-Dickson construction builds higher-dimensional algebras from pairs:
///   Level 0: Integers (scalars)
///   Level 1: Gaussian integers (complex integers: a + bi)
///   Level 2: Quaternions (a + bi + cj + dk)
///   Level 3: Octonions (8 dimensions)
///   Level n+1: Pairs of level-n elements, recursively
///
/// Each level doubles the dimension. Algebraic properties are progressively lost:
/// commutativity at quaternions (level 2), associativity at octonions (level 3).
///
/// Integer types conform as level-0 scalars; `CayleyDickson` pairs as level n+1.
public protocol Algebra {
    /// Convert this type's static representation to a runtime AlgebraValue.
    static var algebraValue: AlgebraValue { get }
}

// MARK: - AlgebraValue (runtime representation)

/// Runtime representation of a Cayley-Dickson algebra element.
///
/// Swift cannot construct binary generic types (`CayleyDickson<A, B>.self`) from
/// two independently computed type parameters at runtime. This enum provides the
/// runtime arithmetic that the type-level representation cannot.
///
/// - `.scalar(n)`: an integer metatype (level 0)
/// - `.pair(a, b)`: a Cayley-Dickson pair `(a, b)` at level `depth(a) + 1`
public indirect enum AlgebraValue {
    case scalar(any Integer.Type)
    case pair(AlgebraValue, AlgebraValue)
}

// MARK: - AlgebraValue: Equatable

/// Manual Equatable conformance because auto-synthesis cannot handle `any Integer.Type`.
/// Scalar comparison uses metatype equality (`==`), which is structural in Swift:
/// `AddOne<AddOne<AddOne<Zero>>>.self == Three` is true because they are the same
/// concrete type, regardless of how the binding was obtained.
///
/// Operands at different depths are auto-embedded to matching depth before comparison,
/// so `.scalar(Two) == gaussian(Two, Zip)` is true (scalar embeds as `(2, 0)`).
extension AlgebraValue: Equatable {
    public static func ==(lhs: AlgebraValue, rhs: AlgebraValue) -> Bool {
        let d = max(depth(lhs), depth(rhs))
        let l = embed(lhs, toDepth: d)
        let r = embed(rhs, toDepth: d)
        return equalSameDepth(l, r)
    }
}

/// Compare two AlgebraValues known to be at the same depth.
private func equalSameDepth(_ lhs: AlgebraValue, _ rhs: AlgebraValue) -> Bool {
    switch (lhs, rhs) {
    case (.scalar(let a), .scalar(let b)):
        return a == b
    case (.pair(let a, let b), .pair(let c, let d)):
        return equalSameDepth(a, c) && equalSameDepth(b, d)
    default:
        return false
    }
}

// MARK: - CayleyDickson type (type-level representation)

/// Cayley-Dickson pair at the type level: represents `(Re, Im)`.
///
/// Use for compile-time type construction where both components are statically known.
/// For runtime arithmetic with dynamically computed operands, use `AlgebraValue` directly.
///
/// Examples:
///   `CayleyDickson<AddOne<Zero>, AddOne<AddOne<Zero>>>` represents `1 + 2i`
///   `CayleyDickson<CayleyDickson<A, B>, CayleyDickson<C, D>>` represents a quaternion
public enum CayleyDickson<Re: Algebra, Im: Algebra>: Algebra {
    public static var algebraValue: AlgebraValue {
        .pair(Re.algebraValue, Im.algebraValue)
    }
}

// MARK: - Integer Algebra conformances

/// Integers are level-0 (scalar) elements in the Cayley-Dickson hierarchy.
/// Their algebraValue wraps the metatype in `.scalar(...)`.

extension Zero: Algebra {
    public static var algebraValue: AlgebraValue { .scalar(Zero.self) }
}

extension AddOne: Algebra {
    public static var algebraValue: AlgebraValue { .scalar(Self.self) }
}

extension SubOne: Algebra {
    public static var algebraValue: AlgebraValue { .scalar(Self.self) }
}

// MARK: - Depth, embedding, and zero construction

/// Depth of a value in the Cayley-Dickson hierarchy.
/// Scalars have depth 0; pairs have depth `depth(component) + 1`.
public func depth(_ v: AlgebraValue) -> Int {
    switch v {
    case .scalar: return 0
    case .pair(let a, _): return depth(a) + 1
    }
}

/// The zero element at a given depth.
/// - Depth 0: `.scalar(Zero.self)`
/// - Depth n+1: `.pair(zero, zero)` where each component is zero at depth n.
public func zero(ofDepth d: Int) -> AlgebraValue {
    if d <= 0 { return .scalar(Zero.self) }
    let z = zero(ofDepth: d - 1)
    return .pair(z, z)
}

/// Embed a value to a target depth by wrapping as `(value, 0)` recursively.
///
/// A scalar `n` embedded to depth 1 becomes `(n, 0)` -- the standard embedding
/// of integers into the Gaussian integers. Embedding to depth 2 gives
/// `((n, 0), (0, 0))` -- integers inside quaternions.
///
/// If the value is already at or above the target depth, it is returned unchanged.
public func embed(_ v: AlgebraValue, toDepth d: Int) -> AlgebraValue {
    let current = depth(v)
    if current >= d { return v }
    // Wrap as (value, zero-at-current-depth) and recurse
    return embed(.pair(v, zero(ofDepth: current)), toDepth: d)
}

// MARK: - Conjugation

/// Cayley-Dickson conjugation.
///
/// - Scalars: `conj(n) = n` (trivial conjugation for integers).
/// - Pairs: `conj(a, b) = (conj(a), -b)`.
///
/// This is the standard involution that makes the norm multiplicative.
/// At the complex level, this is ordinary complex conjugation: `conj(a + bi) = a - bi`.
public func conjugate(_ a: AlgebraValue) -> AlgebraValue {
    switch a {
    case .scalar:
        return a   // integers are self-conjugate
    case .pair(let re, let im):
        return .pair(conjugate(re), negate(im))
    }
}

// MARK: - Negation

/// Negate an AlgebraValue: flip the sign of every scalar component.
///
/// - Scalars: delegates to the existing Peano `negate(_ n: any Integer.Type)`.
/// - Pairs: `-(a, b) = (-a, -b)`.
public func negate(_ a: AlgebraValue) -> AlgebraValue {
    switch a {
    case .scalar(let n):
        return .scalar(negate(n))
    case .pair(let re, let im):
        return .pair(negate(re), negate(im))
    }
}

// MARK: - Addition

/// Cayley-Dickson addition: component-wise at every level.
///
/// `(a, b) + (c, d) = (a + c, b + d)`
///
/// Operands at different depths are auto-embedded to matching depth.
public func +(lhs: AlgebraValue, rhs: AlgebraValue) -> AlgebraValue {
    let d = max(depth(lhs), depth(rhs))
    return addSameDepth(embed(lhs, toDepth: d), embed(rhs, toDepth: d))
}

/// Add two AlgebraValues known to be at the same depth.
private func addSameDepth(_ lhs: AlgebraValue, _ rhs: AlgebraValue) -> AlgebraValue {
    switch (lhs, rhs) {
    case (.scalar(let a), .scalar(let b)):
        // Delegate to Peano integer addition
        return .scalar((a as any Integer.Type) + (b as any Integer.Type))
    case (.pair(let a, let b), .pair(let c, let d)):
        return .pair(addSameDepth(a, c), addSameDepth(b, d))
    default:
        fatalError("AlgebraValue depth mismatch in addSameDepth")
    }
}

// MARK: - Subtraction

/// Cayley-Dickson subtraction: `lhs + negate(rhs)`.
///
/// `(a, b) - (c, d) = (a - c, b - d)`
public func -(lhs: AlgebraValue, rhs: AlgebraValue) -> AlgebraValue {
    lhs + negate(rhs)
}

// MARK: - Multiplication

/// Cayley-Dickson multiplication.
///
/// The recursive formula that defines the entire hierarchy:
///
///   `(a, b) * (c, d) = (a*c - conj(d)*b, d*a + b*conj(c))`
///
/// At each level of the construction:
/// - Level 0 (scalars): ordinary integer multiplication
/// - Level 1 (Gaussian integers): `(a+bi)(c+di) = (ac-db) + (da+bc)i`
///   (since conj is trivial on integers)
/// - Level 2 (quaternions): non-commutative multiplication emerges
/// - Level 3 (octonions): non-associative multiplication emerges
///
/// Operands at different depths are auto-embedded to matching depth.
public func *(lhs: AlgebraValue, rhs: AlgebraValue) -> AlgebraValue {
    let d = max(depth(lhs), depth(rhs))
    return mulSameDepth(embed(lhs, toDepth: d), embed(rhs, toDepth: d))
}

/// Multiply two AlgebraValues known to be at the same depth.
///
/// Uses the Cayley-Dickson product formula:
///   `(a, b) * (c, d) = (a*c - conj(d)*b, d*a + b*conj(c))`
private func mulSameDepth(_ lhs: AlgebraValue, _ rhs: AlgebraValue) -> AlgebraValue {
    switch (lhs, rhs) {
    case (.scalar(let a), .scalar(let b)):
        // Delegate to Peano integer multiplication
        return .scalar((a as any Integer.Type) * (b as any Integer.Type))
    case (.pair(let a, let b), .pair(let c, let d)):
        // (a, b) * (c, d) = (a*c - conj(d)*b, d*a + b*conj(c))
        let ac = mulSameDepth(a, c)
        let conjD_b = mulSameDepth(conjugate(d), b)
        let da = mulSameDepth(d, a)
        let b_conjC = mulSameDepth(b, conjugate(c))
        return .pair(addSameDepth(ac, negate(conjD_b)), addSameDepth(da, b_conjC))
    default:
        fatalError("AlgebraValue depth mismatch in mulSameDepth")
    }
}

// MARK: - Norm

/// Cayley-Dickson norm (squared modulus).
///
/// Returns a scalar `AlgebraValue` representing the sum of squares of all components:
/// - `N(scalar) = scalar * scalar`
/// - `N(a, b) = N(a) + N(b)`
///
/// The norm is always a nonnegative integer. It is multiplicative: `N(x*y) = N(x)*N(y)`.
///
/// For Gaussian integers: `N(a + bi) = a² + b²`.
/// For quaternions: `N(a + bi + cj + dk) = a² + b² + c² + d²`.
public func norm(_ a: AlgebraValue) -> AlgebraValue {
    switch a {
    case .scalar(let n):
        return .scalar((n as any Integer.Type) * (n as any Integer.Type))
    case .pair(let re, let im):
        let nRe = norm(re)
        let nIm = norm(im)
        // Both norms are scalars, so we can add them directly
        return addSameDepth(nRe, nIm)
    }
}

// MARK: - Convenience constructors

/// Construct a Gaussian integer (complex integer) from real and imaginary parts.
///
/// `gaussian(a, b)` represents `a + bi` as an `AlgebraValue.pair`.
///
/// Example: `gaussian(One, Two)` is the Gaussian integer `1 + 2i`.
public func gaussian(_ re: any Integer.Type, _ im: any Integer.Type) -> AlgebraValue {
    .pair(.scalar(re), .scalar(im))
}

/// Construct a quaternion from four integer components.
///
/// `quaternion(a, b, c, d)` represents `a + bi + cj + dk` as a nested pair:
/// `((a, b), (c, d))` -- a pair of two Gaussian integers.
///
/// Example: `quaternion(One, Two, Three, Four)` is `1 + 2i + 3j + 4k`.
public func quaternion(
    _ a: any Integer.Type,
    _ b: any Integer.Type,
    _ c: any Integer.Type,
    _ d: any Integer.Type
) -> AlgebraValue {
    .pair(gaussian(a, b), gaussian(c, d))
}

// MARK: - AlgebraValue equality assertion

/// Runtime equality assertion for AlgebraValues.
public func assertEqual(_ a: AlgebraValue, _ b: AlgebraValue) {
    assert(a == b, "assertEqual failed: \(a) != \(b)")
}
