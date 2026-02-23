@freestanding(expression)
public macro Peano(_ value: Int) -> any Integer.Type = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoMacro")

@freestanding(expression)
public macro PeanoType(_ expr: Any) -> any Integer.Type = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoTypeMacro")
