import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PeanoNumbersMacros)
import PeanoNumbersMacros

nonisolated(unsafe) let churchMacros: [String: Macro.Type] = [
    "Church": ChurchMacro.self,
]
#endif

final class ChurchMacroTests: XCTestCase {
    #if canImport(PeanoNumbersMacros)

    func testZero() throws {
        assertMacroExpansion(
            "#Church(0)",
            expandedSource: "ChurchZero.self",
            macros: churchMacros
        )
    }

    func testOne() throws {
        assertMacroExpansion(
            "#Church(1)",
            expandedSource: "ChurchSucc<ChurchZero>.self",
            macros: churchMacros
        )
    }

    func testThree() throws {
        assertMacroExpansion(
            "#Church(3)",
            expandedSource: "ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self",
            macros: churchMacros
        )
    }

    #endif
}
