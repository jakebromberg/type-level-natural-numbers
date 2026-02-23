@freestanding(expression)
public macro Peano(_ value: Int) -> Any = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoMacro")
