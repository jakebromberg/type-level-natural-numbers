import SwiftSyntax

func peanoTypeName(for n: Int) -> String {
    if n == 0 { return "Zero" }
    if n > 0 {
        return String(repeating: "AddOne<", count: n) + "Zero" + String(repeating: ">", count: n)
    }
    return String(repeating: "SubOne<", count: -n) + "Zero" + String(repeating: ">", count: -n)
}

func churchTypeName(for n: Int) -> String {
    if n <= 0 { return "ChurchZero" }
    return String(repeating: "ChurchSucc<", count: n) + "ChurchZero" + String(repeating: ">", count: n)
}

enum EvaluationError: Error {
    case unsupportedExpression(ExprSyntax)
    case unsupportedOperator(String)
    case unsupportedFunction(String)
    case expectedComparison(ExprSyntax)
    case unsupportedComparison(String)
}

// MARK: - Int helpers for macro evaluation

private func intPow(_ base: Int, _ exp: Int) -> Int {
    if exp == 0 { return 1 }
    var result = 1
    for _ in 0..<exp { result *= base }
    return result
}

private func fibonacciInt(_ n: Int) -> Int {
    var a = 0, b = 1
    for _ in 0..<n { (a, b) = (b, a + b) }
    return a
}

private func gcdInt(_ a: Int, _ b: Int) -> Int {
    if b == 0 { return a }
    return gcdInt(b, a % b)
}

private func factorialInt(_ n: Int) -> Int {
    (1...max(1, n)).reduce(1, *)
}

private func hyperopInt(_ n: Int, _ a: Int, _ b: Int) -> Int {
    if n == 0 { return b + 1 }
    if n == 1 && b == 0 { return a }
    if n == 2 && b == 0 { return 0 }
    if b == 0 { return 1 }
    return hyperopInt(n - 1, a, hyperopInt(n, a, b - 1))
}

private func ackermannInt(_ m: Int, _ n: Int) -> Int {
    if m == 0 { return n + 1 }
    if n == 0 { return ackermannInt(m - 1, 1) }
    return ackermannInt(m - 1, ackermannInt(m, n - 1))
}

/// Evaluates a SwiftSyntax arithmetic expression to an Int.
///
/// Supports integer literals, prefix minus, binary operators (+, -, *, **, .-, /, %),
/// function calls (negate, factorial, fibonacci, gcd, hyperop, ackermann), and parentheses.
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

    // Infix operator: 2 + 3, 2 * 3, 2 - 3, 2 ** 3, 5 .- 3, 6 / 2, 6 % 4
    if let infix = expr.as(InfixOperatorExprSyntax.self),
       let op = infix.operator.as(BinaryOperatorExprSyntax.self) {
        let lhs = try evaluateExpression(infix.leftOperand)
        let rhs = try evaluateExpression(infix.rightOperand)
        switch op.operator.text {
        case "+":  return lhs + rhs
        case "-":  return lhs - rhs
        case "*":  return lhs * rhs
        case "**": return intPow(lhs, rhs)
        case ".-": return max(lhs - rhs, 0)
        case "/":  return lhs / rhs
        case "%":  return lhs % rhs
        default: throw EvaluationError.unsupportedOperator(op.operator.text)
        }
    }

    // Function call: negate(x), factorial(x), fibonacci(x), gcd(a, b)
    if let call = expr.as(FunctionCallExprSyntax.self),
       let callee = call.calledExpression.as(DeclReferenceExprSyntax.self) {
        let name = callee.baseName.text
        let args = try call.arguments.map { try evaluateExpression($0.expression) }
        switch (name, args.count) {
        case ("negate", 1):    return -args[0]
        case ("factorial", 1): return factorialInt(args[0])
        case ("fibonacci", 1): return fibonacciInt(args[0])
        case ("gcd", 2):       return gcdInt(args[0], args[1])
        case ("hyperop", 3):   return hyperopInt(args[0], args[1], args[2])
        case ("ackermann", 2): return ackermannInt(args[0], args[1])
        default: throw EvaluationError.unsupportedFunction(name)
        }
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
