import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PeanoNumbersPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ProductConformanceMacro.self,
    ]
}
