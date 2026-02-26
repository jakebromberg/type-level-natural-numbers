import AbuseOfNotation

// ============================================================
// Seed<A>: non-constant base case for induction
// ============================================================

enum Seed<A: Natural>: Natural {
    public typealias Successor = AddOne<Self>
    public typealias Predecessor = SubOne<Zero>
}

// _InductiveAdd: counts successors above a Seed.
// Seed<A>._Sum = A (non-constant base!)
// AddOne<P>._Sum = S(P._Sum)
protocol _InductiveAdd: Natural {
    associatedtype _Sum: Natural
    associatedtype _Base: Natural   // the A in the Seed<A> at the bottom
}

extension Seed: _InductiveAdd {
    typealias _Sum = A
    typealias _Base = A
}

extension AddOne: _InductiveAdd where Predecessor: _InductiveAdd {
    typealias _Sum = AddOne<Predecessor._Sum>
    typealias _Base = Predecessor._Base
}

// Concrete tests:
typealias _Exp_3p2 = AddOne<AddOne<Seed<N3>>>    // 3 + 2 = 5
typealias _Exp_7p1 = AddOne<Seed<N7>>            // 7 + 1 = 8
typealias _Exp_5p0 = Seed<N5>                    // 5 + 0 = 5

// ============================================================
// The "rebase" operation: given B (a chain of AddOnes over Zero),
// produce a chain of AddOnes over Seed<A> instead.
//
// Rebase(Zero, A) = Seed<A>
// Rebase(S(n), A) = S(Rebase(n, A))
//
// This maps B to a _InductiveAdd type whose _Sum = A + B.
// ============================================================

protocol _Rebase: Natural {
    associatedtype _Rebased: _InductiveAdd
}

// Base case: Zero rebases to Seed<???>.
// The seed value A must come from SOMEWHERE.
// Zero can only conform once, so A would be fixed.
//
// UNLESS: we use Seed ITSELF as the base of the rebase induction!
// Instead of rebasing Zero → Seed<A>, we rebase Seed<A> → Seed<A> (identity).

extension Seed: _Rebase {
    typealias _Rebased = Seed<A>  // identity: already a Seed
}

extension AddOne: _Rebase where Predecessor: _Rebase {
    typealias _Rebased = AddOne<Predecessor._Rebased>
}

// This compiles! But it only works for types already built on Seed<A>.
// For a standard natural like N3 = AddOne<AddOne<AddOne<Zero>>>,
// Zero doesn't conform to _Rebase, so the chain breaks.

// To rebase N3 onto Seed<N5>, we'd need Zero._Rebased = Seed<N5>.
// But Zero can only conform to _Rebase ONCE.

