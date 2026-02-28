// Universal multiplication theorems proved by structural induction.
//
// The flat encoding (TimesTick/TimesGroup) decomposes each multiplication
// step into individual successor operations, like PlusSucc does for addition.
// This avoids TimesSucc's where clauses, which trigger rewrite system
// explosion when composed in inductive protocols.

// MARK: - Flat multiplication witnesses

/// One successor step within a multiplication.
/// Adds 1 to Total; Left and Right unchanged.
///
/// Analogous to PlusSucc for addition: each TimesTick increments the running
/// total by 1. A "copy of Left" consists of Left-many consecutive TimesTicks.
public struct TimesTick<Proof: NaturalProduct>: NaturalProduct {
    public typealias Left = Proof.Left
    public typealias Right = Proof.Right
    public typealias Total = AddOne<Proof.Total>
}

/// One complete copy of Left has been added.
/// Adds 1 to Right; Left and Total unchanged.
///
/// After Left-many TimesTicks, a TimesGroup marks the boundary: one full
/// copy of Left has been accumulated, so Right increments by 1.
public struct TimesGroup<Proof: NaturalProduct>: NaturalProduct {
    public typealias Left = Proof.Left
    public typealias Right = AddOne<Proof.Right>
    public typealias Total = Proof.Total
}

// MARK: - Theorem 1: Left zero annihilation (0 * n = 0)

/// For any natural number N, there exists a proof that 0 * N = 0.
/// Proved by induction on N using TimesZero (base) and TimesGroup (step).
///
/// With Left = 0, each group has 0 ticks (no TimesTicks needed), so the
/// inductive step is just TimesGroup wrapping the previous proof.
public protocol MulLeftZero: Natural {
    associatedtype ZeroTimesProof: NaturalProduct
}

// Base case: 0 * 0 = 0
extension Zero: MulLeftZero {
    public typealias ZeroTimesProof = TimesZero<Zero>
}

// Inductive step: if 0 * n = 0, then 0 * S(n) = 0
// Each group has 0 ticks (Left = 0), so just wrap with TimesGroup.
extension AddOne: MulLeftZero where Predecessor: MulLeftZero {
    public typealias ZeroTimesProof = TimesGroup<Predecessor.ZeroTimesProof>
}

// MARK: - Theorem 2: Successor-left multiplication (a * b = c => S(a) * b = c + b)

/// For any flat multiplication proof that a * b = c, there exists a proof
/// that S(a) * b = c + b. Each TimesGroup gains one extra TimesTick
/// (the new successor contributes one extra unit per copy), so b groups
/// contribute b extra ticks: Total goes from c to c + b.
///
/// Structurally identical to how SuccLeftAdd wraps each PlusSucc.
public protocol SuccLeftMul: NaturalProduct {
    associatedtype Distributed: NaturalProduct
}

// Base case: TimesZero<N> witnesses N * 0 = 0
// S(N) * 0 = 0, witnessed by TimesZero<S(N)>
extension TimesZero: SuccLeftMul {
    public typealias Distributed = TimesZero<AddOne<N>>
}

// Inductive step (tick): TimesTick<P> witnesses a * b = S(c) where P: a * b' = c
// If P.Distributed witnesses S(a) * b' = d,
// then TimesTick<P.Distributed> witnesses S(a) * b = S(d)
extension TimesTick: SuccLeftMul where Proof: SuccLeftMul {
    public typealias Distributed = TimesTick<Proof.Distributed>
}

// Inductive step (group): TimesGroup<P> witnesses a * S(b) = c where P: a * b = c
// If P.Distributed witnesses S(a) * b = d,
// then TimesGroup<TimesTick<P.Distributed>> witnesses S(a) * S(b) = S(d)
// The extra TimesTick accounts for the new successor's contribution to this group.
extension TimesGroup: SuccLeftMul where Proof: SuccLeftMul {
    public typealias Distributed = TimesGroup<TimesTick<Proof.Distributed>>
}
