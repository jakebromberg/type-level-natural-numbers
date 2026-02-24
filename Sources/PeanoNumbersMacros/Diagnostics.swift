import SwiftDiagnostics

enum PeanoDiagnostic: String, DiagnosticMessage {
    case missingArgument = "#Peano requires an integer literal argument"
    case invalidInteger = "Could not parse integer literal"
    case expectedIntegerLiteral = "#Peano requires an integer literal (e.g. #Peano(3) or #Peano(-2))"
    case expectedExpression = "#PeanoType requires an arithmetic expression"
    case unsupportedExpression = "Unsupported expression in Peano arithmetic"
    case unsupportedOperator = "Unsupported operator in Peano arithmetic"
    case unsupportedFunction = "Unsupported function in Peano arithmetic (supported: negate, factorial, fibonacci, gcd, hyperop, ackermann)"
    case expectedComparison = "#PeanoAssert requires a comparison expression (==, !=, <, >, <=, >=)"
    case unsupportedComparison = "Unsupported comparison operator"
    case churchRequiresNonnegative = "#Church requires a nonnegative integer literal (e.g. #Church(3))"
    case gaussianRequiresTwoArguments = "#Gaussian requires two integer expression arguments (e.g. #Gaussian(1, 2))"
    case productConformanceRequiresMultiplier = "#ProductConformance requires an integer literal >= 2"

    var message: String { rawValue }
    var diagnosticID: MessageID { MessageID(domain: "PeanoNumbersMacros", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
}

struct SimpleDiagnosticMessage: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
}
