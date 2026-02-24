import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct PeanoNumbersPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PeanoMacro.self,
        PeanoTypeMacro.self,
        PeanoAssertMacro.self,
        ChurchMacro.self,
        GaussianMacro.self,
    ]
}
