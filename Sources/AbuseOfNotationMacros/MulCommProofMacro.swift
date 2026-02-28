import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `@MulCommProof(leftOperand: A, depth: D)` -- generates paired forward/reverse
/// multiplication proof chains showing `A * b = b * A` for `b = 0` through `D`.
///
/// Attach to a namespace enum:
/// ```swift
/// @MulCommProof(leftOperand: 4, depth: 5)
/// enum MulComm4 {}
/// ```
///
/// Each expansion generates `D+1` paired typealiases:
/// ```swift
/// enum MulComm4 {
///     typealias _Fwd0 = TimesZero<N4>
///     typealias _Rev0 = N4.ZeroTimesProof
///     typealias _Fwd1 = TimesGroup<TimesTick<TimesTick<TimesTick<TimesTick<_Fwd0>>>>>
///     typealias _Rev1 = _Rev0.Distributed
///     // ...
/// }
/// ```
///
/// The forward proof (`_FwdK`) witnesses `A * K` using the flat encoding:
/// each step wraps in A `TimesTick`s plus one `TimesGroup`.
/// The reverse proof (`_RevK`) witnesses `K * A` via `SuccLeftMul.Distributed`.
/// The type checker verifies that `_FwdK.Total == _RevK.Total` when asserted.
public struct MulCommProofMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.mulCommProofRequiresMultiplier)
            ])
        }

        // Parse labeled arguments: leftOperand and depth
        var leftOperand: Int?
        var depth: Int?

        for arg in arguments {
            let label = arg.label?.text
            guard let literal = arg.expression.as(IntegerLiteralExprSyntax.self),
                  let value = Int(literal.literal.text) else {
                continue
            }
            switch label {
            case "leftOperand":
                leftOperand = value
            case "depth":
                depth = value
            default:
                break
            }
        }

        guard let a = leftOperand, a >= 2, let d = depth, d >= 1 else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: Syntax(node), message: PeanoDiagnostic.mulCommProofRequiresMultiplier)
            ])
        }

        let peano = peanoTypeName(for: a)
        var decls: [DeclSyntax] = []

        // Base case (b = 0): A * 0 = 0 and 0 * A = 0
        decls.append("typealias _Fwd0 = TimesZero<\(raw: peano)>")
        decls.append("typealias _Rev0 = \(raw: peano).ZeroTimesProof")

        // Inductive steps (b = 1 through d)
        for b in 1...d {
            let prev = "_Fwd\(b - 1)"

            // Forward: TimesGroup<TimesTick^A<prev>>
            let fwd = "TimesGroup<"
                + String(repeating: "TimesTick<", count: a)
                + prev
                + String(repeating: ">", count: a + 1)

            // Reverse: prev.Distributed
            let rev = "_Rev\(b - 1).Distributed"

            decls.append("typealias _Fwd\(raw: String(b)) = \(raw: fwd)")
            decls.append("typealias _Rev\(raw: String(b)) = \(raw: rev)")
        }

        return decls
    }
}
