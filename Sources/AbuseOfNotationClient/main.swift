import AbuseOfNotation

// MARK: - Addition proofs

// Theorem: 0 + 0 = 0
assertEqual(PlusZero<N0>.Total.self, N0.self)

// Theorem: 2 + 3 = 5
typealias TwoPlusThree = PlusSucc<PlusSucc<PlusSucc<PlusZero<N2>>>>
assertEqual(TwoPlusThree.Total.self, N5.self)

// Theorem: 3 + 2 = 5  (commutativity instance)
typealias ThreePlusTwo = PlusSucc<PlusSucc<PlusZero<N3>>>
assertEqual(ThreePlusTwo.Total.self, N5.self)

// MARK: - Multiplication proofs

// Theorem: 2 * 0 = 0
assertEqual(TimesZero<N2>.Total.self, N0.self)

// Theorem: 2 * 3 = 6
// Proof chain: 2*0=0, then 0+2=2 so 2*1=2, then 2+2=4 so 2*2=4, then 4+2=6 so 2*3=6
typealias Mul2x0 = TimesZero<N2>
typealias Add0p2 = PlusSucc<PlusSucc<PlusZero<N0>>>
typealias Mul2x1 = TimesSucc<Mul2x0, Add0p2>
typealias Add2p2 = PlusSucc<PlusSucc<PlusZero<N2>>>
typealias Mul2x2 = TimesSucc<Mul2x1, Add2p2>
typealias Add4p2 = PlusSucc<PlusSucc<PlusZero<N4>>>
typealias Mul2x3 = TimesSucc<Mul2x2, Add4p2>
assertEqual(Mul2x3.Total.self, N6.self)

// MARK: - Comparison proofs

// Theorem: 0 < 1
typealias ZeroLtOne = ZeroLT<N0>

// Theorem: 2 < 5  (peel off 2 successors, then 0 < 3)
typealias TwoLtFive = SuccLT<SuccLT<ZeroLT<N2>>>

// MARK: - Type-level arithmetic (retained)

assertEqual(Sum<N1, N2>.Result.self, N3.self)
assertEqual(Sum<N2, N3>.Result.self, N5.self)
assertEqual(Product<N2, N3>.Result.self, N6.self)
assertEqual(Product<N3, N2>.Result.self, N6.self)
