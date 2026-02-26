@freestanding(expression)
public macro Peano(_ value: Int) -> any Integer.Type = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoMacro")

@freestanding(expression)
public macro PeanoType(_ expr: Any) -> any Integer.Type = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoTypeMacro")

@freestanding(expression)
public macro PeanoAssert(_ expr: Any) = #externalMacro(module: "PeanoNumbersMacros", type: "PeanoAssertMacro")

@freestanding(expression)
public macro Church(_ value: Int) -> any ChurchNumeral.Type = #externalMacro(module: "PeanoNumbersMacros", type: "ChurchMacro")

@attached(peer, names: arbitrary)
public macro ProductConformance(_ multiplier: Int) = #externalMacro(module: "PeanoNumbersMacros", type: "ProductConformanceMacro")
