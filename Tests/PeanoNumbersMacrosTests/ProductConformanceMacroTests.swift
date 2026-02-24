import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PeanoNumbersMacros)
import PeanoNumbersMacros

nonisolated(unsafe) let productConformanceMacros: [String: Macro.Type] = [
    "ProductConformance": ProductConformanceMacro.self,
]
#endif

final class ProductConformanceMacroTests: XCTestCase {
    #if canImport(PeanoNumbersMacros)

    func testTimesTwo() throws {
        assertMacroExpansion(
            """
            @ProductConformance(2)
            enum Product<L: Natural, R: Natural> {}
            """,
            expandedSource: """
            enum Product<L: Natural, R: Natural> {}

            protocol _TimesN2: Natural {
                associatedtype _TimesN2Result: Natural
            }

            extension Zero: _TimesN2 {
                typealias _TimesN2Result = Zero
            }

            extension AddOne: _TimesN2 where Predecessor: _TimesN2 {
                typealias _TimesN2Result = AddOne<AddOne<Predecessor._TimesN2Result>>
            }

            extension Product where L == AddOne<AddOne<Zero>>, R: _TimesN2 {
                typealias Result = R._TimesN2Result
            }
            """,
            macros: productConformanceMacros
        )
    }

    func testTimesThree() throws {
        assertMacroExpansion(
            """
            @ProductConformance(3)
            enum Product<L: Natural, R: Natural> {}
            """,
            expandedSource: """
            enum Product<L: Natural, R: Natural> {}

            protocol _TimesN3: Natural {
                associatedtype _TimesN3Result: Natural
            }

            extension Zero: _TimesN3 {
                typealias _TimesN3Result = Zero
            }

            extension AddOne: _TimesN3 where Predecessor: _TimesN3 {
                typealias _TimesN3Result = AddOne<AddOne<AddOne<Predecessor._TimesN3Result>>>
            }

            extension Product where L == AddOne<AddOne<AddOne<Zero>>>, R: _TimesN3 {
                typealias Result = R._TimesN3Result
            }
            """,
            macros: productConformanceMacros
        )
    }

    func testZeroProducesDiagnostic() throws {
        assertMacroExpansion(
            """
            @ProductConformance(0)
            enum Product<L: Natural, R: Natural> {}
            """,
            expandedSource: """
            enum Product<L: Natural, R: Natural> {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "#ProductConformance requires an integer literal >= 2", line: 1, column: 1)
            ],
            macros: productConformanceMacros
        )
    }

    func testOneProducesDiagnostic() throws {
        assertMacroExpansion(
            """
            @ProductConformance(1)
            enum Product<L: Natural, R: Natural> {}
            """,
            expandedSource: """
            enum Product<L: Natural, R: Natural> {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "#ProductConformance requires an integer literal >= 2", line: 1, column: 1)
            ],
            macros: productConformanceMacros
        )
    }

    #endif
}
