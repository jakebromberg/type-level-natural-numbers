import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PeanoNumbersMacros)
import PeanoNumbersMacros

nonisolated(unsafe) let peanoAssertMacros: [String: Macro.Type] = [
    "PeanoAssert": PeanoAssertMacro.self,
]
#endif

final class PeanoAssertMacroTests: XCTestCase {
    #if canImport(PeanoNumbersMacros)

    // MARK: - Passing assertions

    func testEqualityPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 + 3 == 5)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testInequalityPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 + 3 != 7)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testLessThanPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(1 < 2)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testGreaterThanPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(3 > 1)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testLessOrEqualPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 <= 2)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testGreaterOrEqualPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(5 >= 3)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testNegativeComparisonPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(-1 < 0)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    // MARK: - Failing assertions (compile-time errors)

    func testEqualityFails() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 + 3 == 7)",
            expandedSource: "#PeanoAssert(2 + 3 == 7)",
            diagnostics: [
                DiagnosticSpec(message: "Peano assertion failed: 2 + 3 is 5, not 7", line: 1, column: 1),
            ],
            macros: peanoAssertMacros
        )
    }

    func testInequalityFails() throws {
        assertMacroExpansion(
            "#PeanoAssert(3 != 3)",
            expandedSource: "#PeanoAssert(3 != 3)",
            diagnostics: [
                DiagnosticSpec(message: "Peano assertion failed: 3 != 3 is false", line: 1, column: 1),
            ],
            macros: peanoAssertMacros
        )
    }

    func testLessThanFails() throws {
        assertMacroExpansion(
            "#PeanoAssert(5 < 3)",
            expandedSource: "#PeanoAssert(5 < 3)",
            diagnostics: [
                DiagnosticSpec(message: "Peano assertion failed: 5 < 3 is false", line: 1, column: 1),
            ],
            macros: peanoAssertMacros
        )
    }

    func testComplexExpressionFails() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 * 3 == 7)",
            expandedSource: "#PeanoAssert(2 * 3 == 7)",
            diagnostics: [
                DiagnosticSpec(message: "Peano assertion failed: 2 * 3 is 6, not 7", line: 1, column: 1),
            ],
            macros: peanoAssertMacros
        )
    }

    // MARK: - Arithmetic extension assertions

    func testExponentiationPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 ** 3 == 8)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testMonusPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(5 .- 3 == 2)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testDivisionPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(6 / 2 == 3)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testModuloPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(6 % 4 == 2)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testFactorialPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(factorial(3) == 6)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testFibonacciPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(fibonacci(6) == 8)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testGcdPasses() throws {
        assertMacroExpansion(
            "#PeanoAssert(gcd(6, 4) == 2)",
            expandedSource: "()",
            macros: peanoAssertMacros
        )
    }

    func testExponentiationFails() throws {
        assertMacroExpansion(
            "#PeanoAssert(2 ** 3 == 9)",
            expandedSource: "#PeanoAssert(2 ** 3 == 9)",
            diagnostics: [
                DiagnosticSpec(message: "Peano assertion failed: 2 ** 3 is 8, not 9", line: 1, column: 1),
            ],
            macros: peanoAssertMacros
        )
    }

    #endif
}
