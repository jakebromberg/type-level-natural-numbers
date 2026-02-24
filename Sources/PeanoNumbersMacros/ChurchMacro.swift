import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `#Church(n)` -- converts a nonnegative integer literal to its Church numeral type.
///
/// ```swift
/// #Church(0)  // expands to: ChurchZero.self
/// #Church(3)  // expands to: ChurchSucc<ChurchSucc<ChurchSucc<ChurchZero>>>.self
/// ```
public struct ChurchMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.missingArgument)
            ])
        }

        guard let literal = argument.as(IntegerLiteralExprSyntax.self),
              let value = Int(literal.literal.text) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.expectedIntegerLiteral)
            ])
        }

        guard value >= 0 else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.churchRequiresNonnegative)
            ])
        }

        let typeName = churchTypeName(for: value)
        return "\(raw: typeName).self"
    }
}
