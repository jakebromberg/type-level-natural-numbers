import AbuseOfNotation

// ============================================================================
// Abuse of Notation: A tutorial
//
// This file is a guided tour through encoding natural numbers as Swift types.
// Every statement below is verified by the compiler -- if this file compiles,
// every theorem here is correct. There is no runtime computation; the program
// exits immediately. The proof is the compilation itself.
// ============================================================================

// MARK: - 1. Peano types

// The natural numbers are built from two primitives:
//   Zero       -- the number 0
//   AddOne<N>  -- the successor of N (i.e. N + 1)
//
// Every natural number is a unique nesting of AddOne around Zero:
//   0 = Zero
//   1 = AddOne<Zero>
//   2 = AddOne<AddOne<Zero>>
//   3 = AddOne<AddOne<AddOne<Zero>>>
//
// Type aliases N0 through N9 provide shorthand:

assertEqual(N0.self, Zero.self)
assertEqual(N1.self, AddOne<Zero>.self)
assertEqual(N2.self, AddOne<AddOne<Zero>>.self)
assertEqual(N3.self, AddOne<AddOne<AddOne<Zero>>>.self)

// assertEqual is a function with an empty body. Its signature requires both
// arguments to have the same type:
//
//   func assertEqual<T: Integer>(_: T.Type, _: T.Type) {}
//
// If the two types differ, the compiler rejects the call. If they match,
// it compiles -- and that successful compilation IS the assertion.

// MARK: - 2. Addition witnesses

// A witness is a type whose existence proves a mathematical fact. The
// NaturalSum protocol witnesses that Left + Right = Total.
//
// Two constructors encode the Peano axioms for addition:
//   PlusZero<N>    -- proves N + 0 = N                     (base case)
//   PlusSucc<P>    -- if P proves A + B = C,               (inductive step)
//                     proves A + S(B) = S(C)

// Theorem: 0 + 0 = 0
assertEqual(PlusZero<N0>.Total.self, N0.self)

// Theorem: 3 + 0 = 3
assertEqual(PlusZero<N3>.Total.self, N3.self)

// Theorem: 2 + 1 = 3
// Start with 2 + 0 = 2 (PlusZero), then peel one successor onto the right:
//   2 + 0 = 2  =>  2 + S(0) = S(2)  =>  2 + 1 = 3
typealias TwoPlusOne = PlusSucc<PlusZero<N2>>
assertEqual(TwoPlusOne.Total.self, N3.self)

// Theorem: 2 + 3 = 5
// Each PlusSucc moves a successor from the right operand to the total:
//   2 + 0 = 2  =>  2 + 1 = 3  =>  2 + 2 = 4  =>  2 + 3 = 5
typealias TwoPlusThree = PlusSucc<PlusSucc<PlusSucc<PlusZero<N2>>>>
assertEqual(TwoPlusThree.Total.self, N5.self)

// Theorem: 3 + 2 = 5  (commutativity instance)
// A different proof arriving at the same Total:
typealias ThreePlusTwo = PlusSucc<PlusSucc<PlusZero<N3>>>
assertEqual(ThreePlusTwo.Total.self, N5.self)

// Both witnesses prove different facts (2+3=5 vs 3+2=5) but their Totals
// agree -- we can assert this directly:
assertEqual(TwoPlusThree.Total.self, ThreePlusTwo.Total.self)

// MARK: - 3. Multiplication witnesses

// Multiplication extends addition. The NaturalProduct protocol witnesses
// that Left * Right = Total, using two constructors:
//   TimesZero<N>            -- proves N * 0 = 0             (base case)
//   TimesSucc<Mul, Add>     -- if Mul proves A * B = C      (inductive step)
//                              and Add proves C + A = D,
//                              then A * S(B) = D
//
// The inductive step encodes the Peano axiom: a * S(b) = a*b + a.
// Each step requires BOTH a multiplication witness AND a sum witness.

// Theorem: 2 * 0 = 0
assertEqual(TimesZero<N2>.Total.self, N0.self)

// Theorem: 2 * 1 = 2
// Step 1: 2 * 0 = 0 (base)
// Step 2: 0 + 2 = 2 (sum witness), so 2 * S(0) = 2, i.e. 2 * 1 = 2
typealias Mul2x0 = TimesZero<N2>
typealias Add0p2 = PlusSucc<PlusSucc<PlusZero<N0>>>
typealias Mul2x1 = TimesSucc<Mul2x0, Add0p2>
assertEqual(Mul2x1.Total.self, N2.self)

// Theorem: 2 * 2 = 4
// 2 * 1 = 2 (from above), and 2 + 2 = 4, so 2 * 2 = 4
typealias Add2p2 = PlusSucc<PlusSucc<PlusZero<N2>>>
typealias Mul2x2 = TimesSucc<Mul2x1, Add2p2>
assertEqual(Mul2x2.Total.self, N4.self)

// Theorem: 2 * 3 = 6
// 2 * 2 = 4 (from above), and 4 + 2 = 6, so 2 * 3 = 6
typealias Add4p2 = PlusSucc<PlusSucc<PlusZero<N4>>>
typealias Mul2x3 = TimesSucc<Mul2x2, Add4p2>
assertEqual(Mul2x3.Total.self, N6.self)

// Each multiplication proof is a chain of TimesSucc steps, each composing
// the previous product with a new sum. The structure mirrors how you'd
// prove 2*3 = 6 by hand using the Peano axioms.

// MARK: - 4. Comparison witnesses

// The NaturalLessThan protocol witnesses that Left < Right:
//   ZeroLT<N>      -- proves 0 < S(N)                      (base case)
//   SuccLT<P>      -- if P proves A < B,                    (inductive step)
//                     proves S(A) < S(B)

// Theorem: 0 < 1
// Direct from the base case: 0 < S(0).
typealias ZeroLtOne = ZeroLT<N0>

// Theorem: 0 < 3
// Also direct: 0 < S(S(S(0))), i.e. 0 < S(N2).
typealias ZeroLtThree = ZeroLT<N2>

// Theorem: 2 < 5
// Peel off successors from both sides until the left reaches zero:
//   0 < 3  =>  S(0) < S(3)  =>  S(S(0)) < S(S(3))  =>  2 < 5
typealias TwoLtFive = SuccLT<SuccLT<ZeroLT<N2>>>

// MARK: - 5. Type-level arithmetic

// Writing witness chains by hand is explicit but verbose. Type-level
// arithmetic provides a more concise notation:
//
//   Sum<L, R>.Result     -- the type representing L + R
//   Product<L, R>.Result -- the type representing L * R
//
// These use constrained extensions to compute at the type level.
// The compiler resolves the Result associated type during compilation.

// Addition:
assertEqual(Sum<N0, N5>.Result.self, N5.self)
assertEqual(Sum<N1, N2>.Result.self, N3.self)
assertEqual(Sum<N2, N3>.Result.self, N5.self)
assertEqual(Sum<N3, N3>.Result.self, N6.self)

// Multiplication:
assertEqual(Product<N0, N7>.Result.self, N0.self)
assertEqual(Product<N1, N5>.Result.self, N5.self)
assertEqual(Product<N2, N3>.Result.self, N6.self)
assertEqual(Product<N3, N3>.Result.self, N9.self)

// Commutativity:
assertEqual(Product<N2, N3>.Result.self, Product<N3, N2>.Result.self)

// MARK: - 6. Inductive multiplication (conditional conformance as induction)

// How does Product<N2, R> work for ANY R, not just specific values?
// The answer is conditional conformance -- Swift's mechanism for structural
// induction.
//
// The _TimesN2 protocol defines a type-level function via two conformances:
//
//   extension Zero: _TimesN2 {
//       typealias _TimesN2Result = Zero              // base: 2 * 0 = 0
//   }
//   extension AddOne: _TimesN2 where Predecessor: _TimesN2 {
//       typealias _TimesN2Result = AddOne<AddOne<Predecessor._TimesN2Result>>
//   }                                                // step: 2 * S(n) = S(S(2*n))
//
// This is a proof by induction: Zero is the base case, and the AddOne
// conformance is the inductive step. For any concrete natural N, the
// compiler chains from AddOne down to Zero, resolving the result.
//
// The @ProductConformance macro generates these conformances automatically.
// Product<N2, R> and Product<N3, R> both work for any R thanks to this.

assertEqual(Product<N2, N4>.Result.self, N8.self)
assertEqual(Product<N3, N2>.Result.self, N6.self)

// MARK: - 7. Cayley-Dickson construction: higher-dimensional algebras

// The Cayley-Dickson construction builds algebras by pairing elements.
// Starting from integers (level 0), each level doubles the dimension:
//
//   Level 0: Integers          -- 1-dimensional scalars
//   Level 1: Gaussian integers -- 2D (a + bi), like complex numbers over Z
//   Level 2: Quaternions       -- 4D (a + bi + cj + dk)
//   Level 3: Octonions         -- 8D
//
// The Algebra marker protocol tags types that participate in this hierarchy.
// Integer types (Zero, AddOne, SubOne) conform as level-0 scalars.
// CayleyDickson<Re, Im> pairs two Algebra types to form the next level.

// A Gaussian integer: 3 + 2i
typealias ThreePlus2i = CayleyDickson<N3, N2>

// Another: 1 + 0i (a real integer embedded in the Gaussian integers)
typealias OnePlus0i = CayleyDickson<N1, N0>

// A quaternion: (1 + 2i) + (3 + 4i)j, represented as a pair of pairs.
// This is the quaternion 1 + 2i + 3j + 4k.
typealias Quat1234 = CayleyDickson<CayleyDickson<N1, N2>, CayleyDickson<N3, N4>>

// The construction is purely structural at the type level -- it encodes
// the algebraic *shape* (which components exist and how they nest) without
// computing operations like multiplication or conjugation. This reflects
// the project's philosophy: the type system encodes structure and proves
// relationships; it doesn't compute values.

// MARK: - 8. Negative integers and the full hierarchy

// The Integer protocol sits at the root, with Natural and Nonpositive
// as refinements. SubOne<N> mirrors AddOne<N> on the nonpositive side:
//
//   ... SubOne<SubOne<Zero>> = -2
//       SubOne<Zero>         = -1
//       Zero                 =  0
//       AddOne<Zero>         =  1
//       AddOne<AddOne<Zero>> =  2 ...
//
// Zero conforms to BOTH Natural and Nonpositive -- it's the unique element
// at the intersection, just as 0 is both nonneg and nonpos.

typealias Neg1 = SubOne<Zero>
typealias Neg2 = SubOne<Neg1>

// The Successor/Predecessor associated types thread through the hierarchy:
assertEqual(Zero.Successor.self, N1.self)
assertEqual(N1.Successor.self, N2.self)
assertEqual(Zero.Predecessor.self, Neg1.self)

// MARK: - 9. Continued fractions and pi (macro-generated proof)

// Two classical formulas approximate pi from opposite directions:
//
//   Brouncker's continued fraction for 4/pi:
//     4/pi = 1 + 1^2/(2 + 3^2/(2 + 5^2/(2 + 7^2/(2 + ...))))
//
//   Leibniz series for pi/4:
//     pi/4 = 1 - 1/3 + 1/5 - 1/7 + ...
//
// At every depth n, the CF convergent h_n/k_n equals 1/S_{n+1}, where
// S_{n+1} is the (n+1)-th Leibniz partial sum. Proving this correspondence
// at the type level demonstrates that both representations converge to the
// same value: pi.
//
// The #piConvergenceProof macro computes everything at compile time:
//   1. CF convergents h_i/k_i via the standard recurrence
//   2. Leibniz partial sums S_k as fractions
//   3. All NaturalProduct and NaturalSum witness chains
//   4. Type equality assertions proving the correspondence
//
// The macro is the proof SEARCH (arbitrary integer computation). The type
// checker is the proof VERIFIER (structural constraint verification). If
// any witness chain is wrong, compilation fails -- the macro cannot lie.

@PiConvergenceProof(depth: 3)
enum PiProof {}

// The macro generated CF convergents _CF0..._CF3 and Leibniz partial sums
// _LS1..._LS4, plus all intermediate multiplication and addition witnesses,
// as members of PiProof. Verify the computed values:

assertEqual(PiProof._CF0.P.self, N1.self)    // h_0 = 1
assertEqual(PiProof._CF0.Q.self, N1.self)    // k_0 = 1
assertEqual(PiProof._CF1.P.self, N3.self)    // h_1 = 3
assertEqual(PiProof._CF1.Q.self, N2.self)    // k_1 = 2
assertEqual(PiProof._CF2.P.self, N15.self)   // h_2 = 15
assertEqual(PiProof._CF2.Q.self, N13.self)   // k_2 = 13
assertEqual(PiProof._CF3.P.self, N105.self)  // h_3 = 105
assertEqual(PiProof._CF3.Q.self, N76.self)   // k_3 = 76

assertEqual(PiProof._LS1.P.self, N1.self)    // S_1 = 1/1
assertEqual(PiProof._LS1.Q.self, N1.self)
assertEqual(PiProof._LS2.P.self, N2.self)    // S_2 = 2/3
assertEqual(PiProof._LS2.Q.self, N3.self)
assertEqual(PiProof._LS3.P.self, N13.self)   // S_3 = 13/15
assertEqual(PiProof._LS3.Q.self, N15.self)
assertEqual(PiProof._LS4.P.self, N76.self)   // S_4 = 76/105
assertEqual(PiProof._LS4.Q.self, N105.self)

// The macro also generated _piCorrespondenceCheck(), a function whose
// compilation verifies the Brouncker-Leibniz correspondence at each depth:
//   assertEqual(_CF1.P, _LS2.Q)  -- h_1 = S_2 denominator (3 = 3)
//   assertEqual(_CF1.Q, _LS2.P)  -- k_1 = S_2 numerator   (2 = 2)
//   assertEqual(_CF2.P, _LS3.Q)  -- h_2 = S_3 denominator (15 = 15)
//   assertEqual(_CF2.Q, _LS3.P)  -- k_2 = S_3 numerator   (13 = 13)
//   assertEqual(_CF3.P, _LS4.Q)  -- h_3 = S_4 denominator (105 = 105)
//   assertEqual(_CF3.Q, _LS4.P)  -- k_3 = S_4 numerator   (76 = 76)
//
// These type equalities prove that Brouncker's CF for 4/pi and the Leibniz
// series for pi/4 produce reciprocal rational approximations at each depth.
// Since both sequences converge, and their values agree, they converge to
// the same limit: pi.

// MARK: - 10. Non-constant base case: Seed<A>

// The _TimesN2 pattern has a constant base case: Zero._TimesN2Result = Zero.
// By introducing Seed<A> — a parameterized type that conforms to Natural —
// we get a non-constant base case: Seed<A>._Sum = A.
// AddOne chains on top of Seed<A> then compute A + B via _InductiveAdd.

assertEqual(_Exp_5p0._Sum.self, N5.self)  // 5 + 0 = 5
assertEqual(_Exp_7p1._Sum.self, N8.self)  // 7 + 1 = 8
assertEqual(_Exp_3p2._Sum.self, N5.self)  // 3 + 2 = 5

// The base case is genuinely non-constant: different Seed<A> values
// produce different results through the same _InductiveAdd conformance.
assertEqual(Seed<N0>._Sum.self, N0.self)
assertEqual(Seed<N9>._Sum.self, N9.self)
assertEqual(AddOne<AddOne<AddOne<Seed<N4>>>>._Sum.self, N7.self)  // 4 + 3 = 7

// MARK: - 11. Fibonacci at the type level (macro-generated proof)

// The FibVerified protocol uses a where clause on its SumWitness
// associated type to force Next == Prev + Current. Each FibStep
// carries a NaturalSum witness proving the Fibonacci recurrence.
//
// Writing witness chains by hand is tedious -- the #fibonacciProof macro
// computes Fibonacci numbers as regular integers at compile time, then
// emits PlusSucc/PlusZero witness chains that the type checker verifies.

@FibonacciProof(upTo: 10)
enum FibProof {}

// The macro generated FibStep chains _Fib1 through _Fib10 as members
// of FibProof. Verify:
assertEqual(Fib0.Current.self, N0.self)            // F(0) = 0
assertEqual(Fib0.Next.self, N1.self)               // F(1) = 1
assertEqual(FibProof._Fib1.Current.self, N1.self)  // F(1) = 1
assertEqual(FibProof._Fib2.Current.self, N1.self)  // F(2) = 1
assertEqual(FibProof._Fib3.Current.self, N2.self)  // F(3) = 2
assertEqual(FibProof._Fib4.Current.self, N3.self)  // F(4) = 3
assertEqual(FibProof._Fib5.Current.self, N5.self)  // F(5) = 5
assertEqual(FibProof._Fib6.Current.self, N8.self)  // F(6) = 8

// MARK: - 12. Golden ratio and Fibonacci (macro-generated proof)

// The golden ratio phi = (1 + sqrt(5))/2 has the simplest continued fraction:
//   phi = [1; 1, 1, 1, ...]
//
// The CF recurrence with a=1, b=1 is just h_n = h_{n-1} + h_{n-2} -- the
// Fibonacci recurrence. The convergents h_n/k_n satisfy:
//   h_n = F(n+2),  k_n = F(n+1)
//
// The @GoldenRatioProof macro constructs both sequences independently:
//   1. FibStep witness chains proving F(i-1) + F(i) = F(i+1)
//   2. GCFConvStep convergents for the all-ones CF
// Then generates assertEqual calls verifying the correspondence.

@GoldenRatioProof(depth: 5)
enum GoldenRatioProof {}

// Verify CF convergents match Fibonacci values:
assertEqual(GoldenRatioProof._CF0.P.self, N1.self)   // h_0 = 1 = F(2)
assertEqual(GoldenRatioProof._CF0.Q.self, N1.self)   // k_0 = 1 = F(1)
assertEqual(GoldenRatioProof._CF1.P.self, N2.self)   // h_1 = 2 = F(3)
assertEqual(GoldenRatioProof._CF1.Q.self, N1.self)   // k_1 = 1 = F(2)
assertEqual(GoldenRatioProof._CF2.P.self, N3.self)   // h_2 = 3 = F(4)
assertEqual(GoldenRatioProof._CF2.Q.self, N2.self)   // k_2 = 2 = F(3)
assertEqual(GoldenRatioProof._CF3.P.self, N5.self)   // h_3 = 5 = F(5)
assertEqual(GoldenRatioProof._CF3.Q.self, N3.self)   // k_3 = 3 = F(4)
assertEqual(GoldenRatioProof._CF4.P.self, N8.self)   // h_4 = 8 = F(6)
assertEqual(GoldenRatioProof._CF4.Q.self, N5.self)   // k_4 = 5 = F(5)
assertEqual(GoldenRatioProof._CF5.P.self, N13.self)  // h_5 = 13 = F(7)
assertEqual(GoldenRatioProof._CF5.Q.self, N8.self)   // k_5 = 8 = F(6)

// MARK: - 13. sqrt(2) CF and matrix construction (macro-generated proof)

// The continued fraction for sqrt(2) is [1; 2, 2, 2, ...]:
//   sqrt(2) = 1 + 1/(2 + 1/(2 + 1/(2 + ...)))
//
// The CF recurrence with a=1, b=2 gives:
//   h_n = 2*h_{n-1} + h_{n-2},  k_n = 2*k_{n-1} + k_{n-2}
//
// Equivalently, left-multiplying by the matrix M = [[2,1],[1,0]]:
//   [[h_n, k_n], [h_{n-1}, k_{n-1}]] = M * [[h_{n-1}, k_{n-1}], [h_{n-2}, k_{n-2}]]
//
// The @Sqrt2ConvergenceProof macro constructs both representations:
//   1. CF convergents via GCFConvStep (three-term recurrence)
//   2. Matrix powers via Sqrt2MatStep (iterated left-multiplication)
// Then generates assertEqual calls proving they produce the same values.

@Sqrt2ConvergenceProof(depth: 3)
enum Sqrt2Proof {}

// Verify CF convergents:
assertEqual(Sqrt2Proof._CF0.P.self, N1.self)    // h_0 = 1
assertEqual(Sqrt2Proof._CF0.Q.self, N1.self)    // k_0 = 1
assertEqual(Sqrt2Proof._CF1.P.self, N3.self)    // h_1 = 3
assertEqual(Sqrt2Proof._CF1.Q.self, N2.self)    // k_1 = 2
assertEqual(Sqrt2Proof._CF2.P.self, N7.self)    // h_2 = 7
assertEqual(Sqrt2Proof._CF2.Q.self, N5.self)    // k_2 = 5
assertEqual(Sqrt2Proof._CF3.P.self, N17.self)   // h_3 = 17
assertEqual(Sqrt2Proof._CF3.Q.self, N12.self)   // k_3 = 12

// Verify matrix entries match:
assertEqual(Sqrt2Proof._MAT0.A.self, N1.self)   // MAT0 top-left = h_0 = 1
assertEqual(Sqrt2Proof._MAT0.B.self, N1.self)   // MAT0 top-right = k_0 = 1
assertEqual(Sqrt2Proof._MAT1.A.self, N3.self)   // MAT1 top-left = h_1 = 3
assertEqual(Sqrt2Proof._MAT1.B.self, N2.self)   // MAT1 top-right = k_1 = 2
assertEqual(Sqrt2Proof._MAT2.A.self, N7.self)   // MAT2 top-left = h_2 = 7
assertEqual(Sqrt2Proof._MAT2.B.self, N5.self)   // MAT2 top-right = k_2 = 5
assertEqual(Sqrt2Proof._MAT3.A.self, N17.self)  // MAT3 top-left = h_3 = 17
assertEqual(Sqrt2Proof._MAT3.B.self, N12.self)  // MAT3 top-right = k_3 = 12

// MARK: - 14. Universal addition theorems (structural induction)
//
// Unlike the proofs above (which verify specific values), these theorems
// hold for ALL natural numbers. The proof is conditional conformance:
// a base case on Zero/PlusZero and an inductive step on AddOne/PlusSucc.
//
// The protocols follow the _TimesNk pattern: plain associated types (no
// where clauses) whose correctness is enforced structurally by the
// conformance definitions. The generic functions below prove universality
// -- the compiler accepts ANY natural or ANY proof -- and the assertEqual
// calls verify the structural properties on concrete instances.

// Theorem 1: 0 + n = n (left zero identity)
// Proved by: extension Zero: AddLeftZero + extension AddOne: AddLeftZero
//
// The generic constraint proves universality: every Natural satisfies
// AddLeftZero, so there exists a ZeroPlusProof for every n.
func useLeftZero<N: AddLeftZero>(_: N.Type) {}
useLeftZero(N0.self)
useLeftZero(N5.self)
useLeftZero(N9.self)

// Verify structural correctness on concrete instances:
assertEqual(N0.ZeroPlusProof.Left.self, Zero.self)    // 0 + 0 = 0
assertEqual(N0.ZeroPlusProof.Right.self, N0.self)
assertEqual(N0.ZeroPlusProof.Total.self, N0.self)

assertEqual(N5.ZeroPlusProof.Left.self, Zero.self)    // 0 + 5 = 5
assertEqual(N5.ZeroPlusProof.Right.self, N5.self)
assertEqual(N5.ZeroPlusProof.Total.self, N5.self)

assertEqual(N9.ZeroPlusProof.Left.self, Zero.self)    // 0 + 9 = 9
assertEqual(N9.ZeroPlusProof.Right.self, N9.self)
assertEqual(N9.ZeroPlusProof.Total.self, N9.self)

// Theorem 2: a + b = c => S(a) + b = S(c) (successor-left shift)
// Proved by: extension PlusZero: SuccLeftAdd + extension PlusSucc: SuccLeftAdd
func useSuccLeftAdd<P: SuccLeftAdd>(_: P.Type) {}
useSuccLeftAdd(PlusZero<N3>.self)
useSuccLeftAdd(PlusSucc<PlusSucc<PlusZero<N2>>>.self)

// 3+0=3 => 4+0=4
assertEqual(PlusZero<N3>.Shifted.Left.self, N4.self)
assertEqual(PlusZero<N3>.Shifted.Right.self, N0.self)
assertEqual(PlusZero<N3>.Shifted.Total.self, N4.self)

// 2+2=4 => 3+2=5
typealias TwoPlusTwo = PlusSucc<PlusSucc<PlusZero<N2>>>
assertEqual(TwoPlusTwo.Shifted.Left.self, N3.self)
assertEqual(TwoPlusTwo.Shifted.Right.self, N2.self)
assertEqual(TwoPlusTwo.Shifted.Total.self, N5.self)

// Theorem 3: a + b = c => b + a = c (commutativity)
// Proved by: extension PlusZero: AddCommutative + extension PlusSucc: AddCommutative
func useCommutativity<P: AddCommutative>(_: P.Type) {}
useCommutativity(PlusZero<N7>.self)
useCommutativity(PlusSucc<PlusSucc<PlusZero<N2>>>.self)
useCommutativity(PlusSucc<PlusSucc<PlusSucc<PlusZero<N3>>>>.self)

// 7+0=7 => 0+7=7
assertEqual(PlusZero<N7>.Commuted.Left.self, N0.self)
assertEqual(PlusZero<N7>.Commuted.Right.self, N7.self)
assertEqual(PlusZero<N7>.Commuted.Total.self, N7.self)

// 2+2=4 => 2+2=4 (symmetric case)
assertEqual(TwoPlusTwo.Commuted.Left.self, N2.self)
assertEqual(TwoPlusTwo.Commuted.Right.self, N2.self)
assertEqual(TwoPlusTwo.Commuted.Total.self, N4.self)

// 3+3=6 => 3+3=6 (symmetric case)
typealias ThreePlusThree = PlusSucc<PlusSucc<PlusSucc<PlusZero<N3>>>>
assertEqual(ThreePlusThree.Commuted.Left.self, N3.self)
assertEqual(ThreePlusThree.Commuted.Right.self, N3.self)
assertEqual(ThreePlusThree.Commuted.Total.self, N6.self)

// MARK: - Epilogue
//
// If you're reading this, the program compiled and exited cleanly. That
// means every assertEqual call above unified its type arguments and every
// witness type satisfied its protocol constraints. The compiler verified
// 90+ mathematical facts about natural numbers, their arithmetic,
// continued fractions, the Leibniz series, the golden ratio / Fibonacci
// correspondence, the sqrt(2) CF / matrix construction, and three
// universal addition theorems (left zero identity, successor-left shift,
// commutativity) -- all without executing a single computation at runtime.
//
// See docs/future-work-inductive-proofs-and-irrationals.md for what
// comes next: universal proofs for multiplication, coinductive streams
// for irrational numbers, and macro-automated proof construction.
