import SwiftSyntax

/// Collects needed product witness chains and generates `TimesZero`/`TimesSucc`
/// typealias declarations.
///
/// Multiple proof macros need the same pattern: emit `_M{factor}x0 = TimesZero<peano(factor)>`
/// followed by `_M{factor}x{m} = TimesSucc<..., PlusSuccChain>` up to a maximum multiplier.
/// This struct deduplicates that logic.
///
/// Each macro expansion creates its own local instance. Since member macros emit
/// declarations inside a namespace enum, the `_M{f}x{n}` names are scoped per enum.
struct ProductChainGenerator {
    private var products: [Int: Int] = [:]  // products[factor] = max multiplier

    mutating func need(factor: Int, multiplier: Int) {
        products[factor] = max(products[factor] ?? 0, multiplier)
    }

    func declarations() -> [DeclSyntax] {
        var decls: [DeclSyntax] = []
        for factor in products.keys.sorted() {
            let maxMul = products[factor]!
            decls.append("typealias _M\(raw: String(factor))x0 = TimesZero<\(raw: peanoTypeName(for: factor))>")
            for m in 1...maxMul {
                let addWitness = plusSuccChain(left: factor * (m - 1), right: factor)
                decls.append("typealias _M\(raw: String(factor))x\(raw: String(m)) = TimesSucc<_M\(raw: String(factor))x\(raw: String(m - 1)), \(raw: addWitness)>")
            }
        }
        return decls
    }

    static func name(factor: Int, multiplier: Int) -> String {
        "_M\(factor)x\(multiplier)"
    }
}
