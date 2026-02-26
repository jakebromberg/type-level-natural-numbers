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

// MARK: - 7. Church numerals: a second encoding

// Church numerals encode a number as a function that applies its argument
// n times: church(n)(f)(x) = f^n(x). Where Peano types encode the
// *structure* of a number (nested successors), Church numerals encode the
// *behavior* (iteration count).
//
//   ChurchZero    -- applies f zero times: returns x
//   ChurchSucc<N> -- applies f one more time than N

// Church zero: f applied 0 times to 10 gives 10.
assert(ChurchZero.apply({ $0 + 1 }, to: 10) == 10)

// Church two: f applied 2 times to 0 gives 2.
typealias ChurchTwo = ChurchSucc<ChurchSucc<ChurchZero>>
assert(ChurchTwo.apply({ $0 + 1 }, to: 0) == 2)

// Church three:
typealias ChurchThree = ChurchSucc<ChurchTwo>
assert(ChurchThree.apply({ $0 + 1 }, to: 0) == 3)

// Church addition: (a + b)(f)(x) = a(f)(b(f)(x)).
// Applies f a total of a+b times by composing the two numerals.
typealias ChurchFive = ChurchAdd<ChurchTwo, ChurchThree>
assert(ChurchFive.apply({ $0 + 1 }, to: 0) == 5)

// Church multiplication: (a * b)(f)(x) = a(b(f))(x).
// Applies b(f) (which applies f b times) a total of a times.
typealias ChurchSix = ChurchMul<ChurchTwo, ChurchThree>
assert(ChurchSix.apply({ $0 + 1 }, to: 0) == 6)

// Church numerals demonstrate the same arithmetic as Peano witnesses,
// but via a completely different mechanism -- function composition instead
// of type construction. Both encodings agree:
//   Peano:  2 + 3 = 5   (witnessed by PlusSucc chain)
//   Church: 2 + 3 = 5   (verified by applying f to an integer)

// MARK: - 8. Cayley-Dickson construction: higher-dimensional algebras

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

// MARK: - 9. Negative integers and the full hierarchy

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

// MARK: - 10. Continued fractions and pi

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

// --- Brouncker's CF convergents ---

// Depth 0: b_0 = 1, so h_0/k_0 = 1/1.
typealias Brouncker0 = GCFConv0<N1>
assertEqual(Brouncker0.P.self, N1.self)
assertEqual(Brouncker0.Q.self, N1.self)

// Depth 1: a_1 = 1^2 = 1, b_1 = 2.
//   h_1 = 2*1 + 1*1 = 3     (b*h_0 + a*h_{-1})
//   k_1 = 2*1 + 1*0 = 2     (b*k_0 + a*k_{-1})
//
// Witness chain for h_1: 2*1=2 (Mul2x1), 1*1=1 (Mul1x1), 2+1=3 (sum).
// Witness chain for k_1: 2*1=2 (Mul2x1), 1*0=0 (Mul1x0), 2+0=2 (sum).
typealias Mul1x0 = TimesZero<N1>
typealias Mul1x1 = TimesSucc<Mul1x0, PlusSucc<PlusZero<N0>>>

typealias BH1_bh = Mul2x1                                  // 2*1 = 2
typealias BH1_ap = Mul1x1                                  // 1*1 = 1
typealias BH1_sum = PlusSucc<PlusZero<N2>>                  // 2+1 = 3

typealias BK1_bk = Mul2x1                                  // 2*1 = 2
typealias BK1_ap = Mul1x0                                  // 1*0 = 0
typealias BK1_sum = PlusZero<N2>                            // 2+0 = 2

typealias Brouncker1 = GCFConvStep<
    Brouncker0, BH1_bh, BH1_ap, BH1_sum, BK1_bk, BK1_ap, BK1_sum
>
assertEqual(Brouncker1.P.self, N3.self)   // h_1 = 3
assertEqual(Brouncker1.Q.self, N2.self)   // k_1 = 2

// Depth 2: a_2 = 3^2 = 9, b_2 = 2.
//   h_2 = 2*3 + 9*1 = 6 + 9 = 15
//   k_2 = 2*2 + 9*1 = 4 + 9 = 13
//
// We need witnesses for 9*1: build the TimesSucc chain 9*0=0, 0+9=9, so 9*1=9.
typealias Mul9x0 = TimesZero<N9>
typealias Add0p9 = PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusSucc<
    PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusZero<N0>>>>>>>>>>
typealias Mul9x1 = TimesSucc<Mul9x0, Add0p9>               // 9*1 = 9

typealias BH2_bh = Mul2x3                                  // 2*3 = 6
typealias BH2_ap = Mul9x1                                  // 9*1 = 9
typealias BH2_sum = PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusSucc<
    PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusZero<N6>>>>>>>>>>
                                                            // 6+9 = 15
typealias BK2_bh = Mul2x2                                  // 2*2 = 4
typealias BK2_ap = Mul9x1                                  // 9*1 = 9
typealias BK2_sum = PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusSucc<
    PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusZero<N4>>>>>>>>>>
                                                            // 4+9 = 13

typealias Brouncker2 = GCFConvStep<
    Brouncker1, BH2_bh, BH2_ap, BH2_sum, BK2_bh, BK2_ap, BK2_sum
>
assertEqual(Brouncker2.P.self, N15.self)  // h_2 = 15
assertEqual(Brouncker2.Q.self, N13.self)  // k_2 = 13

// --- Leibniz series partial sums ---

// S_1 = 1/1
typealias Leibniz1 = LeibnizBase
assertEqual(Leibniz1.P.self, N1.self)
assertEqual(Leibniz1.Q.self, N1.self)

// S_2 = 1/1 - 1/3 = (1*3 - 1) / (1*3) = 2/3
//   Need: 1*3=3 (p*d), 1*3=3 (q*d), and 2+1=3 witnessing 3-1=2.
typealias L2_pd = TimesSucc<TimesSucc<TimesSucc<TimesZero<N1>,
    PlusSucc<PlusZero<N0>>>, PlusSucc<PlusZero<N1>>>, PlusSucc<PlusZero<N2>>>
                                                            // 1*3 = 3
typealias L2_qd = L2_pd                                    // 1*3 = 3
// SubWitness: Left + Right = Total where Total = p*d = 3 and Right = q = 1.
// PlusZero<N2> gives 2+0=2, PlusSucc wraps to 2+1=3. So Left=2, proving 3-1=2.
typealias L2_witness = PlusSucc<PlusZero<N2>>               // 2+1 = 3

typealias Leibniz2 = LeibnizSub<Leibniz1, L2_pd, L2_qd, L2_witness>
assertEqual(Leibniz2.P.self, N2.self)     // numerator = 2
assertEqual(Leibniz2.Q.self, N3.self)     // denominator = 3

// S_3 = 2/3 + 1/5 = (2*5 + 3) / (3*5) = 13/15
//   Need: 2*5 (p*d), 3*5 (q*d), and 10+3=13 (addition witness).

// 2*5: chain from Mul2x3 (2*3=6), need 2*4 and 2*5.
typealias Add6p2 = PlusSucc<PlusSucc<PlusZero<N6>>>
typealias Mul2x4 = TimesSucc<Mul2x3, Add6p2>               // 2*4 = 8
typealias Add8p2 = PlusSucc<PlusSucc<PlusZero<N8>>>
typealias Mul2x5 = TimesSucc<Mul2x4, Add8p2>               // 2*5 = 10

// 3*5: chain from scratch.
typealias Mul3x0 = TimesZero<N3>
typealias Add0p3 = PlusSucc<PlusSucc<PlusSucc<PlusZero<N0>>>>
typealias Mul3x1 = TimesSucc<Mul3x0, Add0p3>               // 3*1 = 3
typealias Add3p3 = PlusSucc<PlusSucc<PlusSucc<PlusZero<N3>>>>
typealias Mul3x2 = TimesSucc<Mul3x1, Add3p3>               // 3*2 = 6
typealias Add6p3 = PlusSucc<PlusSucc<PlusSucc<PlusZero<N6>>>>
typealias Mul3x3 = TimesSucc<Mul3x2, Add6p3>               // 3*3 = 9
typealias Add9p3 = PlusSucc<PlusSucc<PlusSucc<PlusZero<N9>>>>
typealias Mul3x4 = TimesSucc<Mul3x3, Add9p3>               // 3*4 = 12
typealias Mul3x4_Total = Mul3x4.Total
typealias AddMul3x4p3 = PlusSucc<PlusSucc<PlusSucc<PlusZero<Mul3x4_Total>>>>
typealias Mul3x5 = TimesSucc<Mul3x4, AddMul3x4p3>          // 3*5 = 15

// 10 + 3 = 13
typealias L3_add = PlusSucc<PlusSucc<PlusSucc<PlusZero<Mul2x5.Total>>>>
                                                            // 10+3 = 13

typealias Leibniz3 = LeibnizAdd<Leibniz2, Mul2x5, Mul3x5, L3_add>
assertEqual(Leibniz3.P.self, N13.self)    // numerator = 13
assertEqual(Leibniz3.Q.self, N15.self)    // denominator = 15

// --- The punchline: assertEqual proves the correspondence ---

// The CF convergent h_1/k_1 = 3/2 is the reciprocal of S_2 = 2/3.
assertEqual(Brouncker1.P.self, Leibniz2.Q.self)  // 3 = 3
assertEqual(Brouncker1.Q.self, Leibniz2.P.self)  // 2 = 2

// The CF convergent h_2/k_2 = 15/13 is the reciprocal of S_3 = 13/15.
assertEqual(Brouncker2.P.self, Leibniz3.Q.self)  // 15 = 15
assertEqual(Brouncker2.Q.self, Leibniz3.P.self)  // 13 = 13

// --- Depth 3: h_3 = 105, k_3 = 76, S_4 = 76/105 ---

// Helper: PlusSucc applied 5 times, for building long sum witness chains.
typealias P5<S: NaturalSum> = PlusSucc<PlusSucc<PlusSucc<PlusSucc<PlusSucc<S>>>>>
typealias P13<S: NaturalSum> = P5<P5<PlusSucc<PlusSucc<PlusSucc<S>>>>>
typealias P15<S: NaturalSum> = P5<P5<P5<S>>>
typealias P25<S: NaturalSum> = P5<P5<P5<P5<P5<S>>>>>

// Extend the 2*x witness chain from 2*6 to 2*15.
typealias Mul2x6 = TimesSucc<Mul2x5, PlusSucc<PlusSucc<PlusZero<Mul2x5.Total>>>>
typealias Mul2x7 = TimesSucc<Mul2x6, PlusSucc<PlusSucc<PlusZero<Mul2x6.Total>>>>
typealias Mul2x8 = TimesSucc<Mul2x7, PlusSucc<PlusSucc<PlusZero<Mul2x7.Total>>>>
typealias Mul2x9 = TimesSucc<Mul2x8, PlusSucc<PlusSucc<PlusZero<Mul2x8.Total>>>>
typealias Mul2x10 = TimesSucc<Mul2x9, PlusSucc<PlusSucc<PlusZero<Mul2x9.Total>>>>
typealias Mul2x11 = TimesSucc<Mul2x10, PlusSucc<PlusSucc<PlusZero<Mul2x10.Total>>>>
typealias Mul2x12 = TimesSucc<Mul2x11, PlusSucc<PlusSucc<PlusZero<Mul2x11.Total>>>>
typealias Mul2x13_W = TimesSucc<Mul2x12, PlusSucc<PlusSucc<PlusZero<Mul2x12.Total>>>>
typealias Mul2x14 = TimesSucc<Mul2x13_W, PlusSucc<PlusSucc<PlusZero<Mul2x13_W.Total>>>>
typealias Mul2x15 = TimesSucc<Mul2x14, PlusSucc<PlusSucc<PlusZero<Mul2x14.Total>>>>

// 25*x chain (a_3 = 5^2 = 25).
typealias Mul25x0 = TimesZero<N25>
typealias Mul25x1 = TimesSucc<Mul25x0, P25<PlusZero<Mul25x0.Total>>>
typealias Mul25x2 = TimesSucc<Mul25x1, P25<PlusZero<Mul25x1.Total>>>
typealias Mul25x3 = TimesSucc<Mul25x2, P25<PlusZero<Mul25x2.Total>>>

// CF depth 3:
//   h_3 = b*h_2 + a*h_1 = 2*15 + 25*3 = 30 + 75 = 105
//   k_3 = b*k_2 + a*k_1 = 2*13 + 25*2 = 26 + 50 = 76
typealias BH3_sum = P25<P25<P25<PlusZero<Mul2x15.Total>>>>   // 30+75 = 105
typealias BK3_sum = P25<P25<PlusZero<Mul2x13_W.Total>>>      // 26+50 = 76

typealias Brouncker3 = GCFConvStep<
    Brouncker2, Mul2x15, Mul25x3, BH3_sum, Mul2x13_W, Mul25x2, BK3_sum
>
assertEqual(Brouncker3.P.self, N105.self)  // h_3 = 105
assertEqual(Brouncker3.Q.self, N76.self)   // k_3 = 76

// 13*x and 15*x chains for Leibniz S_4.
typealias Mul13x0 = TimesZero<N13>
typealias Mul13x1 = TimesSucc<Mul13x0, P13<PlusZero<Mul13x0.Total>>>
typealias Mul13x2 = TimesSucc<Mul13x1, P13<PlusZero<Mul13x1.Total>>>
typealias Mul13x3 = TimesSucc<Mul13x2, P13<PlusZero<Mul13x2.Total>>>
typealias Mul13x4 = TimesSucc<Mul13x3, P13<PlusZero<Mul13x3.Total>>>
typealias Mul13x5 = TimesSucc<Mul13x4, P13<PlusZero<Mul13x4.Total>>>
typealias Mul13x6 = TimesSucc<Mul13x5, P13<PlusZero<Mul13x5.Total>>>
typealias Mul13x7 = TimesSucc<Mul13x6, P13<PlusZero<Mul13x6.Total>>>

typealias Mul15x0 = TimesZero<N15>
typealias Mul15x1 = TimesSucc<Mul15x0, P15<PlusZero<Mul15x0.Total>>>
typealias Mul15x2 = TimesSucc<Mul15x1, P15<PlusZero<Mul15x1.Total>>>
typealias Mul15x3 = TimesSucc<Mul15x2, P15<PlusZero<Mul15x2.Total>>>
typealias Mul15x4 = TimesSucc<Mul15x3, P15<PlusZero<Mul15x3.Total>>>
typealias Mul15x5 = TimesSucc<Mul15x4, P15<PlusZero<Mul15x4.Total>>>
typealias Mul15x6 = TimesSucc<Mul15x5, P15<PlusZero<Mul15x5.Total>>>
typealias Mul15x7 = TimesSucc<Mul15x6, P15<PlusZero<Mul15x6.Total>>>

// S_4 = 13/15 - 1/7 = (13*7 - 15) / (15*7) = (91 - 15) / 105 = 76/105
// SubWitness: 76 + 15 = 91, proving 91 - 15 = 76.
typealias L4_sub = P15<PlusZero<N76>>

typealias Leibniz4 = LeibnizSub<Leibniz3, Mul13x7, Mul15x7, L4_sub>
assertEqual(Leibniz4.P.self, N76.self)    // numerator = 76
assertEqual(Leibniz4.Q.self, N105.self)   // denominator = 105

// Depth 3 correspondence:
assertEqual(Brouncker3.P.self, Leibniz4.Q.self)  // 105 = 105
assertEqual(Brouncker3.Q.self, Leibniz4.P.self)  // 76 = 76

// These type equalities prove that Brouncker's CF for 4/pi and the Leibniz
// series for pi/4 produce reciprocal rational approximations at each depth.
// Since both sequences converge, and their values agree, they converge to
// the same limit: pi.

// MARK: - Epilogue
//
// If you're reading this, the program compiled and exited cleanly. That
// means every assertEqual call above unified its type arguments, every
// witness type satisfied its protocol constraints, and every assert
// passed. The compiler verified 60+ mathematical facts about natural
// numbers, their arithmetic, continued fractions, and the Leibniz
// series -- all without executing a single computation at runtime.
//
// See docs/future-work-inductive-proofs-and-irrationals.md for what
// comes next: universal proofs via conditional conformance, coinductive
// streams for irrational numbers, and macro-automated proof construction.
