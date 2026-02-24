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
///
/// This is a convenience wrapper around `evaluateAlgebraExpression` that extracts an Int.
/// For expressions that evaluate to Cayley-Dickson pairs, use `evaluateAlgebraExpression` directly.
func evaluateExpression(_ expr: ExprSyntax) throws -> Int {
    let result = try evaluateAlgebraExpression(expr)
    guard case .integer(let value) = result else {
        throw EvaluationError.unsupportedExpression(expr)
    }
    return value
}

/// Evaluates a comparison expression and returns (lhs value, rhs value, operator, result).
func evaluateComparison(_ expr: ExprSyntax) throws -> (lhs: Int, rhs: Int, op: String, result: Bool) {
    let algebra = try evaluateAlgebraComparison(expr)
    guard case .integer(let lhs) = algebra.lhs,
          case .integer(let rhs) = algebra.rhs else {
        throw EvaluationError.expectedComparison(expr)
    }
    return (lhs, rhs, algebra.op, algebra.result)
}

// MARK: - EvalValue (algebra evaluator)

/// Recursive value type for compile-time evaluation of Cayley-Dickson expressions.
///
/// Extends the evaluator beyond plain `Int` to handle Gaussian integers, quaternions, etc.
/// - `.integer(n)`: a scalar (level 0)
/// - `.pair(a, b)`: a Cayley-Dickson pair at level `depth(a) + 1`
indirect enum EvalValue: Equatable {
    case integer(Int)
    case pair(EvalValue, EvalValue)
}

// MARK: - EvalValue helpers

private func depthEval(_ v: EvalValue) -> Int {
    switch v {
    case .integer: return 0
    case .pair(let a, _): return depthEval(a) + 1
    }
}

private func zeroEval(ofDepth d: Int) -> EvalValue {
    if d <= 0 { return .integer(0) }
    let z = zeroEval(ofDepth: d - 1)
    return .pair(z, z)
}

private func embedEval(_ v: EvalValue, toDepth d: Int) -> EvalValue {
    let current = depthEval(v)
    if current >= d { return v }
    return embedEval(.pair(v, zeroEval(ofDepth: current)), toDepth: d)
}

// MARK: - EvalValue arithmetic

private func addEval(_ lhs: EvalValue, _ rhs: EvalValue) -> EvalValue {
    let d = max(depthEval(lhs), depthEval(rhs))
    return addEvalSameDepth(embedEval(lhs, toDepth: d), embedEval(rhs, toDepth: d))
}

private func addEvalSameDepth(_ lhs: EvalValue, _ rhs: EvalValue) -> EvalValue {
    switch (lhs, rhs) {
    case (.integer(let a), .integer(let b)):
        return .integer(a + b)
    case (.pair(let a, let b), .pair(let c, let d)):
        return .pair(addEvalSameDepth(a, c), addEvalSameDepth(b, d))
    default:
        fatalError("EvalValue depth mismatch")
    }
}

private func negateEval(_ v: EvalValue) -> EvalValue {
    switch v {
    case .integer(let n): return .integer(-n)
    case .pair(let a, let b): return .pair(negateEval(a), negateEval(b))
    }
}

private func conjugateEval(_ v: EvalValue) -> EvalValue {
    switch v {
    case .integer: return v
    case .pair(let re, let im): return .pair(conjugateEval(re), negateEval(im))
    }
}

private func mulEval(_ lhs: EvalValue, _ rhs: EvalValue) -> EvalValue {
    let d = max(depthEval(lhs), depthEval(rhs))
    return mulEvalSameDepth(embedEval(lhs, toDepth: d), embedEval(rhs, toDepth: d))
}

private func mulEvalSameDepth(_ lhs: EvalValue, _ rhs: EvalValue) -> EvalValue {
    switch (lhs, rhs) {
    case (.integer(let a), .integer(let b)):
        return .integer(a * b)
    case (.pair(let a, let b), .pair(let c, let d)):
        // Standard Cayley-Dickson: (a,b)*(c,d) = (ac - conj(d)*b, da + b*conj(c))
        let ac = mulEvalSameDepth(a, c)
        let conjD_b = mulEvalSameDepth(conjugateEval(d), b)
        let da = mulEvalSameDepth(d, a)
        let b_conjC = mulEvalSameDepth(b, conjugateEval(c))
        return .pair(addEvalSameDepth(ac, negateEval(conjD_b)), addEvalSameDepth(da, b_conjC))
    default:
        fatalError("EvalValue depth mismatch")
    }
}

private func normEval(_ v: EvalValue) -> EvalValue {
    switch v {
    case .integer(let n): return .integer(n * n)
    case .pair(let re, let im):
        return addEvalSameDepth(normEval(re), normEval(im))
    }
}

/// Format an EvalValue for diagnostic messages.
func formatEvalValue(_ v: EvalValue) -> String {
    switch v {
    case .integer(let n): return "\(n)"
    case .pair(let a, let b): return "(\(formatEvalValue(a)), \(formatEvalValue(b)))"
    }
}

// MARK: - Algebra expression evaluator

/// Evaluates a SwiftSyntax expression to an EvalValue (integer or Cayley-Dickson pair).
///
/// Extends the scalar evaluator to handle `gaussian(a, b)`, `conjugate(expr)`, `norm(expr)`,
/// and arithmetic on pairs via `+`, `-`, `*`.
func evaluateAlgebraExpression(_ expr: ExprSyntax) throws -> EvalValue {
    // Integer literal: 42
    if let literal = expr.as(IntegerLiteralExprSyntax.self) {
        guard let value = Int(literal.literal.text) else {
            throw EvaluationError.unsupportedExpression(expr)
        }
        return .integer(value)
    }

    // Prefix minus: -3
    if let prefix = expr.as(PrefixOperatorExprSyntax.self),
       prefix.operator.text == "-" {
        return negateEval(try evaluateAlgebraExpression(prefix.expression))
    }

    // Infix operator: handles both scalar and pair arithmetic
    if let infix = expr.as(InfixOperatorExprSyntax.self),
       let op = infix.operator.as(BinaryOperatorExprSyntax.self) {
        let lhs = try evaluateAlgebraExpression(infix.leftOperand)
        let rhs = try evaluateAlgebraExpression(infix.rightOperand)

        func intBinaryOp(
            _ lhs: EvalValue, _ rhs: EvalValue,
            op name: String, _ f: (Int, Int) -> Int
        ) throws -> EvalValue {
            guard case .integer(let l) = lhs, case .integer(let r) = rhs else {
                throw EvaluationError.unsupportedOperator(name)
            }
            return .integer(f(l, r))
        }

        switch op.operator.text {
        case "+":  return addEval(lhs, rhs)
        case "-":  return addEval(lhs, negateEval(rhs))
        case "*":  return mulEval(lhs, rhs)
        case "**": return try intBinaryOp(lhs, rhs, op: "**", intPow)
        case ".-": return try intBinaryOp(lhs, rhs, op: ".-") { max($0 - $1, 0) }
        case "/":  return try intBinaryOp(lhs, rhs, op: "/",  /)
        case "%":  return try intBinaryOp(lhs, rhs, op: "%",  %)
        default: throw EvaluationError.unsupportedOperator(op.operator.text)
        }
    }

    // Function call
    if let call = expr.as(FunctionCallExprSyntax.self),
       let callee = call.calledExpression.as(DeclReferenceExprSyntax.self) {
        let name = callee.baseName.text

        // Cayley-Dickson constructors and operations
        switch name {
        case "gaussian":
            let args = try call.arguments.map { try evaluateAlgebraExpression($0.expression) }
            guard args.count == 2 else { throw EvaluationError.unsupportedFunction(name) }
            return .pair(args[0], args[1])
        case "conjugate":
            let args = try call.arguments.map { try evaluateAlgebraExpression($0.expression) }
            guard args.count == 1 else { throw EvaluationError.unsupportedFunction(name) }
            return conjugateEval(args[0])
        case "norm":
            let args = try call.arguments.map { try evaluateAlgebraExpression($0.expression) }
            guard args.count == 1 else { throw EvaluationError.unsupportedFunction(name) }
            return normEval(args[0])
        default:
            // Scalar-only functions
            let args = try call.arguments.map { try evaluateAlgebraExpression($0.expression) }
            let intArgs = try args.map { v -> Int in
                guard case .integer(let n) = v else {
                    throw EvaluationError.unsupportedFunction(name)
                }
                return n
            }
            switch (name, intArgs.count) {
            case ("negate", 1):    return .integer(-intArgs[0])
            case ("factorial", 1): return .integer(factorialInt(intArgs[0]))
            case ("fibonacci", 1): return .integer(fibonacciInt(intArgs[0]))
            case ("gcd", 2):       return .integer(gcdInt(intArgs[0], intArgs[1]))
            case ("hyperop", 3):   return .integer(hyperopInt(intArgs[0], intArgs[1], intArgs[2]))
            case ("ackermann", 2): return .integer(ackermannInt(intArgs[0], intArgs[1]))
            default: throw EvaluationError.unsupportedFunction(name)
            }
        }
    }

    // Parenthesized expression: (2 + 3)
    if let tuple = expr.as(TupleExprSyntax.self),
       tuple.elements.count == 1,
       let element = tuple.elements.first {
        return try evaluateAlgebraExpression(element.expression)
    }

    throw EvaluationError.unsupportedExpression(expr)
}

/// Evaluates a comparison expression on algebra values.
/// Supports `==` and `!=` for pairs; scalar comparisons also support `<`, `>`, `<=`, `>=`.
func evaluateAlgebraComparison(_ expr: ExprSyntax) throws
    -> (lhs: EvalValue, rhs: EvalValue, op: String, result: Bool) {
    guard let infix = expr.as(InfixOperatorExprSyntax.self),
          let op = infix.operator.as(BinaryOperatorExprSyntax.self) else {
        throw EvaluationError.expectedComparison(expr)
    }

    let opText = op.operator.text
    let lhs = try evaluateAlgebraExpression(infix.leftOperand)
    let rhs = try evaluateAlgebraExpression(infix.rightOperand)

    let result: Bool
    switch opText {
    case "==": result = lhs == rhs
    case "!=": result = lhs != rhs
    case "<", ">", "<=", ">=":
        // Ordering comparisons only make sense for scalars
        guard case .integer(let l) = lhs, case .integer(let r) = rhs else {
            throw EvaluationError.unsupportedComparison(opText)
        }
        switch opText {
        case "<":  result = l < r
        case ">":  result = l > r
        case "<=": result = l <= r
        case ">=": result = l >= r
        default: fatalError("unreachable")
        }
    default: throw EvaluationError.unsupportedComparison(opText)
    }

    return (lhs, rhs, opText, result)
}
