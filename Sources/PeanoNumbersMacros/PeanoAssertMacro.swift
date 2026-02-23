import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct PeanoAssertMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.expectedComparison)
            ])
        }

        let comparison: (lhs: Int, rhs: Int, op: String, result: Bool)
        do {
            comparison = try evaluateComparison(argument)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.expectedComparison)
            ])
        }

        if comparison.result {
            return "()"
        }

        // Build a helpful failure message
        let message: String
        if comparison.op == "==" {
            let lhsExpr = argument.as(InfixOperatorExprSyntax.self)!.leftOperand
            message = "Peano assertion failed: \(lhsExpr.description.trimmingCharacters(in: .whitespaces)) is \(comparison.lhs), not \(comparison.rhs)"
        } else if comparison.op == "!=" {
            message = "Peano assertion failed: \(comparison.lhs) != \(comparison.rhs) is false"
        } else {
            message = "Peano assertion failed: \(comparison.lhs) \(comparison.op) \(comparison.rhs) is false"
        }

        throw DiagnosticsError(diagnostics: [
            Diagnostic(
                node: Syntax(node),
                message: SimpleDiagnosticMessage(
                    message: message,
                    diagnosticID: MessageID(domain: "PeanoNumbersMacros", id: "assertionFailed"),
                    severity: .error
                )
            )
        ])
    }
}

struct SimpleDiagnosticMessage: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}
