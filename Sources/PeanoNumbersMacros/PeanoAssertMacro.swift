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

        let comparison: (lhs: EvalValue, rhs: EvalValue, op: String, result: Bool)
        do {
            comparison = try evaluateAlgebraComparison(argument)
        } catch {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(argument), message: PeanoDiagnostic.expectedComparison)
            ])
        }

        if comparison.result {
            return "()"
        }

        // Build a helpful failure message
        let lhsStr = formatEvalValue(comparison.lhs)
        let rhsStr = formatEvalValue(comparison.rhs)
        let message: String
        if comparison.op == "==" {
            let lhsExpr = argument.as(InfixOperatorExprSyntax.self)!.leftOperand
            message = "Peano assertion failed: \(lhsExpr.description.trimmingCharacters(in: .whitespaces)) is \(lhsStr), not \(rhsStr)"
        } else if comparison.op == "!=" {
            message = "Peano assertion failed: \(lhsStr) != \(rhsStr) is false"
        } else {
            message = "Peano assertion failed: \(lhsStr) \(comparison.op) \(rhsStr) is false"
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
