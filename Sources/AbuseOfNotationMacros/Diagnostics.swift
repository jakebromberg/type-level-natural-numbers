import SwiftDiagnostics

enum PeanoDiagnostic: String, DiagnosticMessage {
    case productConformanceRequiresMultiplier = "#ProductConformance requires an integer literal >= 2"
    case fibonacciProofRequiresPositiveInteger = "#fibonacciProof requires an integer literal >= 1"
    case piConvergenceRequiresPositiveInteger = "#piConvergenceProof requires an integer literal >= 1"

    var message: String { rawValue }
    var diagnosticID: MessageID { MessageID(domain: "AbuseOfNotationMacros", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
}
