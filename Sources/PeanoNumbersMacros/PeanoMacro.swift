import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PeanoMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.missingArgument)
            ])
        }

        let value: Int

        if let literal = argument.as(IntegerLiteralExprSyntax.self) {
            guard let parsed = Int(literal.literal.text) else {
                throw DiagnosticsError(diagnostics: [
                    Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.invalidInteger)
                ])
            }
            value = parsed
        } else if let prefix = argument.as(PrefixOperatorExprSyntax.self),
                  prefix.operator.text == "-",
                  let literal = prefix.expression.as(IntegerLiteralExprSyntax.self),
                  let parsed = Int(literal.literal.text) {
            value = -parsed
        } else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.expectedIntegerLiteral)
            ])
        }

        let typeName = peanoTypeName(for: value)
        return "\(raw: typeName).self"
    }
}
