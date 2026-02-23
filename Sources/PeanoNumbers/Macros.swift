@freestanding(expression)
public macro Peano(_ value: Int) -> any Integer.Type = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoMacro")
