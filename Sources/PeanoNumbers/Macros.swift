@attached(peer, names: arbitrary)
public macro ProductConformance(_ multiplier: Int) = #externalMacro(module: "PeanoNumbersMacros", type: "ProductConformanceMacro")
