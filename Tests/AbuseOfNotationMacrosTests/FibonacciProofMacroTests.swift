import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(AbuseOfNotationMacros)
import AbuseOfNotationMacros

nonisolated(unsafe) let fibonacciProofMacros: [String: Macro.Type] = [
    "FibonacciProof": FibonacciProofMacro.self,
]
#endif

final class FibonacciProofMacroTests: XCTestCase {
    #if canImport(AbuseOfNotationMacros)

    func testUpToOne() throws {
        assertMacroExpansion(
            """
            @FibonacciProof(upTo: 1)
            enum FibProof {}
            """,
            expandedSource: """
            enum FibProof {

                typealias _FibW1 = PlusSucc<PlusZero<Zero>>

                typealias _Fib1 = FibStep<Fib0, _FibW1>
            }
            """,
            macros: fibonacciProofMacros
        )
    }

    func testUpToThree() throws {
        assertMacroExpansion(
            """
            @FibonacciProof(upTo: 3)
            enum FibProof {}
            """,
            expandedSource: """
            enum FibProof {

                typealias _FibW1 = PlusSucc<PlusZero<Zero>>

                typealias _Fib1 = FibStep<Fib0, _FibW1>

                typealias _FibW2 = PlusSucc<PlusZero<AddOne<Zero>>>

                typealias _Fib2 = FibStep<_Fib1, _FibW2>

                typealias _FibW3 = PlusSucc<PlusSucc<PlusZero<AddOne<Zero>>>>

                typealias _Fib3 = FibStep<_Fib2, _FibW3>
            }
            """,
            macros: fibonacciProofMacros
        )
    }

    func testZeroProducesDiagnostic() throws {
        assertMacroExpansion(
            """
            @FibonacciProof(upTo: 0)
            enum FibProof {}
            """,
            expandedSource: """
            enum FibProof {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "#fibonacciProof requires an integer literal >= 1", line: 1, column: 1)
            ],
            macros: fibonacciProofMacros
        )
    }

    #endif
}
