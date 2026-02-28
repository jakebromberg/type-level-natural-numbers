import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(AbuseOfNotationMacros)
import AbuseOfNotationMacros

nonisolated(unsafe) let mulCommProofMacros: [String: Macro.Type] = [
    "MulCommProof": MulCommProofMacro.self,
]
#endif

final class MulCommProofMacroTests: XCTestCase {
    #if canImport(AbuseOfNotationMacros)

    func testLeftOperandTwoDepthTwo() throws {
        assertMacroExpansion(
            """
            @MulCommProof(leftOperand: 2, depth: 2)
            enum MulComm2 {}
            """,
            expandedSource: """
            enum MulComm2 {

                typealias _Fwd0 = TimesZero<AddOne<AddOne<Zero>>>

                typealias _Rev0 = AddOne<AddOne<Zero>>.ZeroTimesProof

                typealias _Fwd1 = TimesGroup<TimesTick<TimesTick<_Fwd0>>>

                typealias _Rev1 = _Rev0.Distributed

                typealias _Fwd2 = TimesGroup<TimesTick<TimesTick<_Fwd1>>>

                typealias _Rev2 = _Rev1.Distributed
            }
            """,
            macros: mulCommProofMacros
        )
    }

    func testLeftOperandThreeDepthOne() throws {
        assertMacroExpansion(
            """
            @MulCommProof(leftOperand: 3, depth: 1)
            enum MulComm3 {}
            """,
            expandedSource: """
            enum MulComm3 {

                typealias _Fwd0 = TimesZero<AddOne<AddOne<AddOne<Zero>>>>

                typealias _Rev0 = AddOne<AddOne<AddOne<Zero>>>.ZeroTimesProof

                typealias _Fwd1 = TimesGroup<TimesTick<TimesTick<TimesTick<_Fwd0>>>>

                typealias _Rev1 = _Rev0.Distributed
            }
            """,
            macros: mulCommProofMacros
        )
    }

    func testZeroLeftOperandProducesDiagnostic() throws {
        assertMacroExpansion(
            """
            @MulCommProof(leftOperand: 0, depth: 3)
            enum MulComm0 {}
            """,
            expandedSource: """
            enum MulComm0 {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "#MulCommProof requires an integer literal >= 2", line: 1, column: 1)
            ],
            macros: mulCommProofMacros
        )
    }

    func testOneLeftOperandProducesDiagnostic() throws {
        assertMacroExpansion(
            """
            @MulCommProof(leftOperand: 1, depth: 3)
            enum MulComm1 {}
            """,
            expandedSource: """
            enum MulComm1 {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "#MulCommProof requires an integer literal >= 2", line: 1, column: 1)
            ],
            macros: mulCommProofMacros
        )
    }

    #endif
}
