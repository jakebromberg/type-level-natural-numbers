import SwiftSyntax

func peanoTypeName(for n: Int) -> String {
    if n == 0 { return "Zero" }
    if n > 0 {
        return String(repeating: "AddOne<", count: n) + "Zero" + String(repeating: ">", count: n)
    }
    return String(repeating: "SubOne<", count: -n) + "Zero" + String(repeating: ">", count: -n)
}

enum EvaluationError: Error {
    case unsupportedExpression(ExprSyntax)
    case unsupportedOperator(String)
    case unsupportedFunction(String)
    case expectedComparison(ExprSyntax)
    case unsupportedComparison(String)
}

/// Evaluates a SwiftSyntax arithmetic expression to an Int.
///
/// Supports integer literals, prefix minus, binary +/-/*, negate(), and parentheses.
/// The Swift compiler folds operator precedence before macro expansion, so
/// `2 + 3 * 4` arrives already structured as `2 + (3 * 4)`.
func evaluateExpression(_ expr: ExprSyntax) throws -> Int {
    // Integer literal: 42
    if let literal = expr.as(IntegerLiteralExprSyntax.self) {
        guard let value = Int(literal.literal.text) else {
            throw EvaluationError.unsupportedExpression(expr)
        }
        return value
    }

    // Prefix minus: -3
    if let prefix = expr.as(PrefixOperatorExprSyntax.self),
       prefix.operator.text == "-" {
        return -(try evaluateExpression(prefix.expression))
    }

    // Infix operator: 2 + 3, 2 * 3, 2 - 3
    if let infix = expr.as(InfixOperatorExprSyntax.self),
       let op = infix.operator.as(BinaryOperatorExprSyntax.self) {
        let lhs = try evaluateExpression(infix.leftOperand)
        let rhs = try evaluateExpression(infix.rightOperand)
        switch op.operator.text {
        case "+": return lhs + rhs
        case "-": return lhs - rhs
        case "*": return lhs * rhs
        default: throw EvaluationError.unsupportedOperator(op.operator.text)
        }
    }

    // Function call: negate(x)
    if let call = expr.as(FunctionCallExprSyntax.self),
       let callee = call.calledExpression.as(DeclReferenceExprSyntax.self) {
        let name = callee.baseName.text
        guard name == "negate" else {
            throw EvaluationError.unsupportedFunction(name)
        }
        guard let firstArg = call.arguments.first else {
            throw EvaluationError.unsupportedExpression(expr)
        }
        return -(try evaluateExpression(firstArg.expression))
    }

    // Parenthesized expression: (2 + 3)
    if let tuple = expr.as(TupleExprSyntax.self),
       tuple.elements.count == 1,
       let element = tuple.elements.first {
        return try evaluateExpression(element.expression)
    }

    throw EvaluationError.unsupportedExpression(expr)
}

/// Evaluates a comparison expression and returns (lhs value, rhs value, operator, result).
func evaluateComparison(_ expr: ExprSyntax) throws -> (lhs: Int, rhs: Int, op: String, result: Bool) {
    guard let infix = expr.as(InfixOperatorExprSyntax.self),
          let op = infix.operator.as(BinaryOperatorExprSyntax.self) else {
        throw EvaluationError.expectedComparison(expr)
    }

    let opText = op.operator.text
    let lhs = try evaluateExpression(infix.leftOperand)
    let rhs = try evaluateExpression(infix.rightOperand)

    let result: Bool
    switch opText {
    case "==": result = lhs == rhs
    case "!=": result = lhs != rhs
    case "<":  result = lhs < rhs
    case ">":  result = lhs > rhs
    case "<=": result = lhs <= rhs
    case ">=": result = lhs >= rhs
    default: throw EvaluationError.unsupportedComparison(opText)
    }

    return (lhs, rhs, opText, result)
}
