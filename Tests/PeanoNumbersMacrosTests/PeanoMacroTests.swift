import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PeanoNumbersMacros)
import PeanoNumbersMacros

nonisolated(unsafe) let peanoMacros: [String: Macro.Type] = [
    "Peano": PeanoMacro.self,
]
#endif

final class PeanoMacroTests: XCTestCase {
    #if canImport(PeanoNumbersMacros)

    func testZero() throws {
        assertMacroExpansion(
            "#Peano(0)",
            expandedSource: "Zero.self",
            macros: peanoMacros
        )
    }

    func testPositiveIntegers() throws {
        assertMacroExpansion(
            "#Peano(1)",
            expandedSource: "AddOne<Zero>.self",
            macros: peanoMacros
        )
        assertMacroExpansion(
            "#Peano(3)",
            expandedSource: "AddOne<AddOne<AddOne<Zero>>>.self",
            macros: peanoMacros
        )
        assertMacroExpansion(
            "#Peano(5)",
            expandedSource: "AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self",
            macros: peanoMacros
        )
    }

    func testNegativeIntegers() throws {
        assertMacroExpansion(
            "#Peano(-1)",
            expandedSource: "SubOne<Zero>.self",
            macros: peanoMacros
        )
        assertMacroExpansion(
            "#Peano(-2)",
            expandedSource: "SubOne<SubOne<Zero>>.self",
            macros: peanoMacros
        )
        assertMacroExpansion(
            "#Peano(-3)",
            expandedSource: "SubOne<SubOne<SubOne<Zero>>>.self",
            macros: peanoMacros
        )
    }

    #endif
}
