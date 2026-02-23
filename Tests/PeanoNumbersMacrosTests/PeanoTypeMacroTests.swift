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

    #endif
}
