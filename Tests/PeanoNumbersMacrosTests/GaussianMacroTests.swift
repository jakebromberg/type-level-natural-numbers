import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(PeanoNumbersMacros)
import PeanoNumbersMacros

nonisolated(unsafe) let gaussianMacros: [String: Macro.Type] = [
    "Gaussian": GaussianMacro.self,
]
#endif

final class GaussianMacroTests: XCTestCase {
    #if canImport(PeanoNumbersMacros)

    func testBothPositive() throws {
        assertMacroExpansion(
            "#Gaussian(1, 2)",
            expandedSource: "gaussian(AddOne<Zero>.self, AddOne<AddOne<Zero>>.self)",
            macros: gaussianMacros
        )
    }

    func testBothNegative() throws {
        assertMacroExpansion(
            "#Gaussian(-1, -2)",
            expandedSource: "gaussian(SubOne<Zero>.self, SubOne<SubOne<Zero>>.self)",
            macros: gaussianMacros
        )
    }

    func testMixedSigns() throws {
        assertMacroExpansion(
            "#Gaussian(3, -1)",
            expandedSource: "gaussian(AddOne<AddOne<AddOne<Zero>>>.self, SubOne<Zero>.self)",
            macros: gaussianMacros
        )
    }

    func testZeros() throws {
        assertMacroExpansion(
            "#Gaussian(0, 0)",
            expandedSource: "gaussian(Zero.self, Zero.self)",
            macros: gaussianMacros
        )
    }

    func testExpressionArguments() throws {
        assertMacroExpansion(
            "#Gaussian(1 + 2, 3 * -1)",
            expandedSource: "gaussian(AddOne<AddOne<AddOne<Zero>>>.self, SubOne<SubOne<SubOne<Zero>>>.self)",
            macros: gaussianMacros
        )
    }

    func testRealWithZeroImaginary() throws {
        assertMacroExpansion(
            "#Gaussian(5, 0)",
            expandedSource: "gaussian(AddOne<AddOne<AddOne<AddOne<AddOne<Zero>>>>>.self, Zero.self)",
            macros: gaussianMacros
        )
    }

    func testPureImaginary() throws {
        assertMacroExpansion(
            "#Gaussian(0, 1)",
            expandedSource: "gaussian(Zero.self, AddOne<Zero>.self)",
            macros: gaussianMacros
        )
    }

    #endif
}
