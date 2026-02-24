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

// MARK: - Hyperoperation

func hyperop(_ n: any Natural.Type, _ a: any Natural.Type, _ b: any Natural.Type) -> any Natural.Type {
    if n == Zero.self { return b.successor }                                      // H(0, a, b) = S(b)
    let nPred = n.predecessor as! any Natural.Type
    if b == Zero.self {
        if nPred == Zero.self { return a }                                        // H(1, a, 0) = a
        if nPred == AddOne<Zero>.self { return Zero.self }                        // H(2, a, 0) = 0
        return AddOne<Zero>.self                                                  // H(n>=3, a, 0) = 1
    }
    return hyperop(nPred, a, hyperop(n, a, b.predecessor as! any Natural.Type))  // H(S(n), a, S(b)) = H(n, a, H(S(n), a, b))
}

assert(hyperop(Zip, Two, Three) == Four)              // H(0, a, b) = S(b)
assert(hyperop(One, Two, Three) == Five)               // H(1, a, b) = a + b
assert(hyperop(Two, Two, Three) == Six)                // H(2, a, b) = a * b
let Eight = Two ** Three
assert(hyperop(Three, Two, Three) == Eight)            // H(3, a, b) = a ** b
assert(hyperop(One, Zip, Zip) == Zip)                  // H(1, 0, 0) = 0
assert(hyperop(Two, Three, Zip) == Zip)                // H(2, a, 0) = 0
assert(hyperop(Three, Two, Zip) == One)                // H(3, a, 0) = 1

// MARK: - Ackermann function

func ackermann(_ m: any Natural.Type, _ n: any Natural.Type) -> any Natural.Type {
    if m == Zero.self { return n.successor }                                      // A(0, n) = S(n)
    let mPred = m.predecessor as! any Natural.Type
    if n == Zero.self { return ackermann(mPred, AddOne<Zero>.self) }              // A(S(m), 0) = A(m, 1)
    return ackermann(mPred, ackermann(m, n.predecessor as! any Natural.Type))    // A(S(m), S(n)) = A(m, A(S(m), n))
}

assert(ackermann(Zip, Zip) == One)                     // A(0, 0) = 1
assert(ackermann(Zip, Three) == Four)                  // A(0, n) = n + 1
assert(ackermann(One, One) == Three)                   // A(1, 1) = 3

// MARK: - Church numerals

protocol ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T
}

enum ChurchZero: ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T { x }
}

enum ChurchSucc<N: ChurchNumeral>: ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T {
        f(N.apply(f, to: x))
    }
}

enum ChurchAdd<A: ChurchNumeral, B: ChurchNumeral>: ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T {
        A.apply(f, to: B.apply(f, to: x))
    }
}

enum ChurchMul<A: ChurchNumeral, B: ChurchNumeral>: ChurchNumeral {
    static func apply<T>(_ f: @escaping (T) -> T, to x: T) -> T {
        A.apply({ B.apply(f, to: $0) }, to: x)
    }
}

func churchToInt<N: ChurchNumeral>(_: N.Type) -> Int {
    N.apply({ $0 + 1 }, to: 0)
}

let c0 = ChurchZero.self
let c1 = ChurchSucc<ChurchZero>.self
let c2 = ChurchSucc<ChurchSucc<ChurchZero>>.self
let c3 = ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self

assert(churchToInt(c0) == 0)
assert(churchToInt(c1) == 1)
assert(churchToInt(c2) == 2)
assert(churchToInt(c3) == 3)

// Church addition: 2 + 3 = 5
assert(churchToInt(ChurchAdd<ChurchSucc<ChurchSucc<ChurchZero>>, ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>>.self) == 5)

// Church multiplication: 2 * 3 = 6
assert(churchToInt(ChurchMul<ChurchSucc<ChurchSucc<ChurchZero>>, ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>>.self) == 6)

// MARK: - Algebra protocol (Cayley-Dickson construction)

/// Root protocol for types in the Cayley-Dickson algebra hierarchy.
///
/// The Cayley-Dickson construction builds higher-dimensional algebras from pairs:
///   Level 0: Integers (scalars)
///   Level 1: Gaussian integers (complex integers: a + bi)
///   Level 2: Quaternions (a + bi + cj + dk)
///   Level 3: Octonions (8 dimensions)
///
/// Each level doubles the dimension. Algebraic properties are progressively lost:
/// commutativity at quaternions (level 2), associativity at octonions (level 3).
protocol Algebra {
    static var algebraValue: AlgebraValue { get }
}

// MARK: - AlgebraValue (runtime representation)

/// Runtime representation of a Cayley-Dickson algebra element.
///
/// Swift cannot construct binary generic types (`CayleyDickson<A, B>.self`) from
/// two independently computed type parameters at runtime. This enum provides the
/// runtime arithmetic that the type-level representation cannot.
indirect enum AlgebraValue {
    case scalar(any Integer.Type)
    case pair(AlgebraValue, AlgebraValue)
}

/// Manual Equatable conformance because auto-synthesis cannot handle `any Integer.Type`.
/// Scalar comparison uses metatype equality (`==`), which is structural in Swift.
/// Operands at different depths are auto-embedded to matching depth before comparison.
extension AlgebraValue: Equatable {
    static func ==(lhs: AlgebraValue, rhs: AlgebraValue) -> Bool {
        let d = max(depth(lhs), depth(rhs))
        let l = embed(lhs, toDepth: d)
        let r = embed(rhs, toDepth: d)
        return equalSameDepth(l, r)
    }
}

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
/// Use for compile-time type construction; for runtime arithmetic, use AlgebraValue.
enum CayleyDickson<Re: Algebra, Im: Algebra>: Algebra {
    static var algebraValue: AlgebraValue {
        .pair(Re.algebraValue, Im.algebraValue)
    }
}

// MARK: - Integer Algebra conformances

extension Zero: Algebra {
    static var algebraValue: AlgebraValue { .scalar(Zero.self) }
}

extension AddOne: Algebra {
    static var algebraValue: AlgebraValue { .scalar(Self.self) }
}

extension SubOne: Algebra {
    static var algebraValue: AlgebraValue { .scalar(Self.self) }
}

// MARK: - Depth, embedding, and zero construction

/// Depth of a value in the Cayley-Dickson hierarchy.
func depth(_ v: AlgebraValue) -> Int {
    switch v {
    case .scalar: return 0
    case .pair(let a, _): return depth(a) + 1
    }
}

/// The zero element at a given depth.
func zero(ofDepth d: Int) -> AlgebraValue {
    if d <= 0 { return .scalar(Zero.self) }
    let z = zero(ofDepth: d - 1)
    return .pair(z, z)
}

/// Embed a value to a target depth by wrapping as `(value, 0)` recursively.
func embed(_ v: AlgebraValue, toDepth d: Int) -> AlgebraValue {
    let current = depth(v)
    if current >= d { return v }
    return embed(.pair(v, zero(ofDepth: current)), toDepth: d)
}

// MARK: - Conjugation

/// Cayley-Dickson conjugation.
/// Scalars: `conj(n) = n`. Pairs: `conj(a, b) = (conj(a), -b)`.
func conjugate(_ a: AlgebraValue) -> AlgebraValue {
    switch a {
    case .scalar:
        return a
    case .pair(let re, let im):
        return .pair(conjugate(re), negate(im))
    }
}

// MARK: - AlgebraValue negation

/// Negate an AlgebraValue: flip the sign of every scalar component.
func negate(_ a: AlgebraValue) -> AlgebraValue {
    switch a {
    case .scalar(let n):
        return .scalar(negate(n))
    case .pair(let re, let im):
        return .pair(negate(re), negate(im))
    }
}

// MARK: - AlgebraValue addition

/// Cayley-Dickson addition: component-wise at every level.
/// Operands at different depths are auto-embedded to matching depth.
func +(lhs: AlgebraValue, rhs: AlgebraValue) -> AlgebraValue {
    let d = max(depth(lhs), depth(rhs))
    return addSameDepth(embed(lhs, toDepth: d), embed(rhs, toDepth: d))
}

private func addSameDepth(_ lhs: AlgebraValue, _ rhs: AlgebraValue) -> AlgebraValue {
    switch (lhs, rhs) {
    case (.scalar(let a), .scalar(let b)):
        return .scalar((a as any Integer.Type) + (b as any Integer.Type))
    case (.pair(let a, let b), .pair(let c, let d)):
        return .pair(addSameDepth(a, c), addSameDepth(b, d))
    default:
        fatalError("AlgebraValue depth mismatch in addSameDepth")
    }
}

// MARK: - AlgebraValue subtraction

/// Cayley-Dickson subtraction: `lhs + negate(rhs)`.
func -(lhs: AlgebraValue, rhs: AlgebraValue) -> AlgebraValue {
    lhs + negate(rhs)
}

// MARK: - AlgebraValue multiplication

/// Cayley-Dickson multiplication.
/// `(a, b) * (c, d) = (a*c - conj(d)*b, d*a + b*conj(c))`
/// Operands at different depths are auto-embedded to matching depth.
func *(lhs: AlgebraValue, rhs: AlgebraValue) -> AlgebraValue {
    let d = max(depth(lhs), depth(rhs))
    return mulSameDepth(embed(lhs, toDepth: d), embed(rhs, toDepth: d))
}

private func mulSameDepth(_ lhs: AlgebraValue, _ rhs: AlgebraValue) -> AlgebraValue {
    switch (lhs, rhs) {
    case (.scalar(let a), .scalar(let b)):
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
/// `N(scalar) = scalar²`, `N(a, b) = N(a) + N(b)`.
/// Returns a scalar AlgebraValue.
func norm(_ a: AlgebraValue) -> AlgebraValue {
    switch a {
    case .scalar(let n):
        return .scalar((n as any Integer.Type) * (n as any Integer.Type))
    case .pair(let re, let im):
        let nRe = norm(re)
        let nIm = norm(im)
        return addSameDepth(nRe, nIm)
    }
}

// MARK: - Convenience constructors

/// Construct a Gaussian integer (complex integer): `a + bi`.
func gaussian(_ re: any Integer.Type, _ im: any Integer.Type) -> AlgebraValue {
    .pair(.scalar(re), .scalar(im))
}

/// Construct a quaternion: `a + bi + cj + dk` as `((a, b), (c, d))`.
func quaternion(
    _ a: any Integer.Type,
    _ b: any Integer.Type,
    _ c: any Integer.Type,
    _ d: any Integer.Type
) -> AlgebraValue {
    .pair(gaussian(a, b), gaussian(c, d))
}

// MARK: - AlgebraValue equality assertion

func assertEqual(_ a: AlgebraValue, _ b: AlgebraValue) {
    assert(a == b, "assertEqual failed: \(a) != \(b)")
}

// MARK: - Cayley-Dickson assertions

// -- Gaussian integer construction --

let z1 = gaussian(One, Two)         // 1 + 2i
let z2 = gaussian(Three, MinusOne)  // 3 - i

// -- Gaussian integer addition: (1+2i) + (3-i) = 4+i --

assert(z1 + z2 == gaussian(Four, One))

// -- Gaussian integer multiplication --
// (1+2i)(3-i) = 3 - i + 6i - 2i² = 3 + 5i + 2 = 5 + 5i

assert(z1 * z2 == gaussian(Five, Five))

// -- Conjugation: conj(1+2i) = 1-2i --

assert(conjugate(z1) == gaussian(One, MinusTwo))

// -- Negation: -(1+2i) = -1-2i --

assert(negate(z1) == gaussian(MinusOne, MinusTwo))

// -- Norm: |1+2i|² = 1² + 2² = 5 --

assert(norm(z1) == AlgebraValue.scalar(Five))

// -- Scalar embedding: 3 + (1+2i) = 4+2i --

assert(AlgebraValue.scalar(Three) + z1 == gaussian(Four, Two))

// -- Scalar multiplication: 2 * (1+2i) = 2+4i --

assert(AlgebraValue.scalar(Two) * z1 == gaussian(Two, Four))

// -- Imaginary unit: i² = -1 --

let cdI = gaussian(Zip, One)
assert(cdI * cdI == gaussian(MinusOne, Zip))

// -- Type-level construction bridges to AlgebraValue --

assertEqual(CayleyDickson<AddOne<Zero>, AddOne<AddOne<Zero>>>.algebraValue, gaussian(One, Two))

// -- Quaternion non-commutativity --

let qi = quaternion(Zip, One, Zip, Zip)   // i
let qj = quaternion(Zip, Zip, One, Zip)   // j
assert(qi * qj != qj * qi)

// -- Quaternion norm: |1+2i+3j+4k|² = 1+4+9+16 = 30 --

let q1 = quaternion(One, Two, Three, Four)
let Thirty = AlgebraValue.scalar(Six * Five)
assert(norm(q1) == Thirty)

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
