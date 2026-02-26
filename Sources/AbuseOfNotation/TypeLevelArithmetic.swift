// MARK: - Type-level arithmetic expression

public protocol NaturalExpression {
    associatedtype Result: Natural
}

// MARK: - Type aliases

public typealias N0 = Zero
public typealias N1 = AddOne<N0>
public typealias N2 = AddOne<N1>
public typealias N3 = AddOne<N2>
public typealias N4 = AddOne<N3>
public typealias N5 = AddOne<N4>
public typealias N6 = AddOne<N5>
public typealias N7 = AddOne<N6>
public typealias N8 = AddOne<N7>
public typealias N9 = AddOne<N8>

// MARK: - Sum

/// Type-level addition: `Sum<L, R>.Result` is the sum of `L` and `R`.
///
/// Defined by constrained extensions for each left operand value.
public enum Sum<L: Natural, R: Natural> {}

extension Sum: NaturalExpression where L == N0 {
    public typealias Result = R
}
extension Sum where L == N1 {
    public typealias Result = AddOne<R>
}
extension Sum where L == N2 {
    public typealias Result = AddOne<AddOne<R>>
}
extension Sum where L == N3 {
    public typealias Result = AddOne<AddOne<AddOne<R>>>
}

// MARK: - Product

/// Inductive multiplication helper protocols.
///
/// Each `_TimesNk` protocol threads recursion through `AddOne`'s `Predecessor`,
/// letting a single constrained extension handle any `R`.

public protocol _TimesN2: Natural {
    associatedtype _TimesN2Result: Natural
}
extension Zero: _TimesN2 {
    public typealias _TimesN2Result = Zero
}
extension AddOne: _TimesN2 where Predecessor: _TimesN2 {
    public typealias _TimesN2Result = AddOne<AddOne<Predecessor._TimesN2Result>>
}

public protocol _TimesN3: Natural {
    associatedtype _TimesN3Result: Natural
}
extension Zero: _TimesN3 {
    public typealias _TimesN3Result = Zero
}
extension AddOne: _TimesN3 where Predecessor: _TimesN3 {
    public typealias _TimesN3Result = AddOne<AddOne<AddOne<Predecessor._TimesN3Result>>>
}

/// Type-level multiplication: `Product<L, R>.Result` is the product of `L` and `R`.
///
/// Defined by constrained extensions using inductive `_TimesNk` protocols.
public enum Product<L: Natural, R: Natural> {}

extension Product: NaturalExpression where L == N0 {
    public typealias Result = Zero
}
extension Product where L == N1 {
    public typealias Result = R
}
extension Product where L == N2, R: _TimesN2 {
    public typealias Result = R._TimesN2Result
}
extension Product where L == N3, R: _TimesN3 {
    public typealias Result = R._TimesN3Result
}
