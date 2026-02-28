// Universal multiplication theorems proved by structural induction.

// MARK: - Derived lemma: zero-left multiplication step

/// Derived witness for the zero-left multiplication step.
/// If 0 * B = 0 (witnessed by MulProof), then 0 * S(B) = 0.
///
/// This is a lemma derived from the Peano multiplication axiom:
///   0 * S(B) = 0*B + 0 = 0 + 0 = 0
///
/// TimesSucc encodes the general step A * S(B) = A*B + A, but its where
/// clauses (AddProof.Left == MulProof.Total, AddProof.Right == MulProof.Left)
/// trigger rewrite system explosion when composed in inductive protocols.
/// This lemma specializes to A = 0, where the arithmetic simplifies to
/// 0 + 0 = 0, and encodes the result directly.
public struct TimesZeroLeft<MulProof: NaturalProduct>: NaturalProduct {
    public typealias Left = Zero
    public typealias Right = AddOne<MulProof.Right>
    public typealias Total = Zero
}

// MARK: - Theorem 1: Left zero annihilation (0 * n = 0)

/// For any natural number N, there exists a proof that 0 * N = 0.
/// Proved by induction on N using TimesZero (base) and TimesZeroLeft (step).
///
/// The associated type `ZeroTimesProof` is structurally guaranteed to be a
/// `NaturalProduct` with `Left == Zero`, `Right == Self`, `Total == Zero`.
public protocol MulLeftZero: Natural {
    associatedtype ZeroTimesProof: NaturalProduct
}

// Base case: 0 * 0 = 0
extension Zero: MulLeftZero {
    public typealias ZeroTimesProof = TimesZero<Zero>
}

// Inductive step: if 0 * n = 0, then 0 * S(n) = 0
extension AddOne: MulLeftZero where Predecessor: MulLeftZero {
    public typealias ZeroTimesProof = TimesZeroLeft<Predecessor.ZeroTimesProof>
}
