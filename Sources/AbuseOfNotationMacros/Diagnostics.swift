import SwiftDiagnostics

enum PeanoDiagnostic: String, DiagnosticMessage {
    case productConformanceRequiresMultiplier = "#ProductConformance requires an integer literal >= 2"

    var message: String { rawValue }
    var diagnosticID: MessageID { MessageID(domain: "AbuseOfNotationMacros", id: rawValue) }
    var severity: DiagnosticSeverity { .error }
}
