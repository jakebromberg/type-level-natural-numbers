func peanoTypeName(for n: Int) -> String {
    if n == 0 { return "Zero" }
    if n > 0 {
        return String(repeating: "AddOne<", count: n) + "Zero" + String(repeating: ">", count: n)
    }
    return String(repeating: "SubOne<", count: -n) + "Zero" + String(repeating: ">", count: -n)
}
