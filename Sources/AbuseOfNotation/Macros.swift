@attached(peer, names: arbitrary)
public macro ProductConformance(_ multiplier: Int) = #externalMacro(module: "AbuseOfNotationMacros", type: "ProductConformanceMacro")

@attached(member, names: arbitrary)
public macro FibonacciProof(upTo n: Int) = #externalMacro(module: "AbuseOfNotationMacros", type: "FibonacciProofMacro")

@attached(member, names: arbitrary)
public macro PiConvergenceProof(depth n: Int) = #externalMacro(module: "AbuseOfNotationMacros", type: "PiConvergenceProofMacro")
