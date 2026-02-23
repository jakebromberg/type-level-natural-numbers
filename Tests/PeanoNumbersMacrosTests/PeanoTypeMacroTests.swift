import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PeanoNumbersMacros)
import PeanoNumbersMacros

nonisolated(unsafe) let peanoTypeMacros: [String: Macro.Type] = [
    "PeanoType": PeanoTypeMacro.self,
]
#endif

final class PeanoTypeMacroTests: XCTestCase {
    #if canImport(PeanoNumbersMacros)

    func testLiteral() throws {
        assertMacroExpansion(
            "#PeanoType(3)",
            expandedSource: "AddOne<AddOne<AddOne<Zero>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testNegativeLiteral() throws {
        assertMacroExpansion(
            "#PeanoType(-2)",
            expandedSource: "SubOne<SubOne<Zero>>.self",
            macros: peanoTypeMacros
        )
    }

    func testAddition() throws {
        assertMacroExpansion(
            "#PeanoType(2 + 3)",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testSubtraction() throws {
        assertMacroExpansion(
            "#PeanoType(2 - 5)",
            expandedSource: "SubOne<SubOne<SubOne<Zero>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testMultiplication() throws {
        assertMacroExpansion(
            "#PeanoType(2 * 3)",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testNegate() throws {
        assertMacroExpansion(
            "#PeanoType(negate(3))",
            expandedSource: "SubOne<SubOne<SubOne<Zero>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testParentheses() throws {
        assertMacroExpansion(
            "#PeanoType((2 + 3))",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testComplex() throws {
        // 2 * 3 - 1 = 5
        assertMacroExpansion(
            "#PeanoType(2 * 3 - 1)",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testZeroResult() throws {
        assertMacroExpansion(
            "#PeanoType(3 - 3)",
            expandedSource: "Zero.self",
            macros: peanoTypeMacros
        )
    }

    func testExponentiation() throws {
        // 2 ** 3 = 8
        assertMacroExpansion(
            "#PeanoType(2 ** 3)",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testMonus() throws {
        // 5 .- 3 = 2
        assertMacroExpansion(
            "#PeanoType(5 .- 3)",
            expandedSource: "AddOne<AddOne<Zero>>.self",
            macros: peanoTypeMacros
        )
    }

    func testMonusClampsToZero() throws {
        // 3 .- 5 = 0
        assertMacroExpansion(
            "#PeanoType(3 .- 5)",
            expandedSource: "Zero.self",
            macros: peanoTypeMacros
        )
    }

    func testDivision() throws {
        // 6 / 2 = 3
        assertMacroExpansion(
            "#PeanoType(6 / 2)",
            expandedSource: "AddOne<AddOne<AddOne<Zero>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testModulo() throws {
        // 6 % 4 = 2
        assertMacroExpansion(
            "#PeanoType(6 % 4)",
            expandedSource: "AddOne<AddOne<Zero>>.self",
            macros: peanoTypeMacros
        )
    }

    func testFactorial() throws {
        // factorial(4) = 24
        assertMacroExpansion(
            "#PeanoType(factorial(4))",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>>>>>>>>>>>>>>>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testFibonacci() throws {
        // fibonacci(6) = 8
        assertMacroExpansion(
            "#PeanoType(fibonacci(6))",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>>>>.self",
            macros: peanoTypeMacros
        )
    }

    func testGcd() throws {
        // gcd(6, 4) = 2
        assertMacroExpansion(
            "#PeanoType(gcd(6, 4))",
            expandedSource: "AddOne<AddOne<Zero>>.self",
            macros: peanoTypeMacros
        )
    }

    #endif
}
