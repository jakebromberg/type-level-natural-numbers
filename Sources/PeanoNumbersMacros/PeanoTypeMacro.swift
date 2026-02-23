import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PeanoTypeMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.expectedExpression)
            ])
        }

        let value: Int
        do {
            value = try evaluateExpression(argument)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.unsupportedExpression)
            ])
        }

        let typeName = peanoTypeName(for: value)
        return "\(raw: typeName).self"
    }
}
