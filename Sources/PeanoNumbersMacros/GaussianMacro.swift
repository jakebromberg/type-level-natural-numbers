import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `#Gaussian(re, im)` -- evaluates two integer expressions at compile time and
/// expands to a `gaussian(...)` call with Peano types.
///
/// ```swift
/// #Gaussian(1, 2)           // expands to: gaussian(AddOne<Zero>.self, AddOne<AddOne<Zero>>.self)
/// #Gaussian(2 + 1, 3 * -1)  // expands to: gaussian(AddOne<AddOne<AddOne<Zero>>>.self, SubOne<SubOne<SubOne<Zero>>>.self)
/// ```
public struct GaussianMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        let args = Array(node.arguments)
        guard args.count == 2 else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.gaussianRequiresTwoArguments)
            ])
        }

        let re: Int
        let im: Int
        do {
            re = try evaluateExpression(args[0].expression)
            im = try evaluateExpression(args[1].expression)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.unsupportedExpression)
            ])
        }

        let reName = peanoTypeName(for: re)
        let imName = peanoTypeName(for: im)
        return "gaussian(\(raw: reName).self, \(raw: imName).self)"
    }
}
