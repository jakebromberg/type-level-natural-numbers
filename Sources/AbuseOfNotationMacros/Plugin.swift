import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AbuseOfNotationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ProductConformanceMacro.self,
    ]
}
