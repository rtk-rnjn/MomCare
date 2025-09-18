# Unused Parameter

Other than unused local variable declarations, unused function/initializer/subscript parameters are not marked by the Swift compiler. Since unused parameters are code smells, they should either be removed or replaced/shadowed by a wildcard '_' to indicate that they are being deliberately disregarded.

* **Identifier:** `unused_parameter`
* **Enabled by default:** No
* **Supports autocorrection:** Yes
* **Kind:** lint
* **Analyzer rule:** No
* **Minimum Swift compiler version:** 5.0.0
* **Default configuration:**
  <table>
  <thead>
  <tr><th>Key</th><th>Value</th></tr>
  </thead>
  <tbody>
  <tr>
  <td>
  severity
  </td>
  <td>
  warning
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
func f(a: Int) {
    _ = a
}
```

```swift
func f(case: Int) {
    _ = `case`
}
```

```swift
func f(a _: Int) {}
```

```swift
func f(_: Int) {}
```

```swift
func f(a: Int, b c: String) {
    func g() {
        _ = a
        _ = c
    }
}
```

```swift
func f(a: Int, c: Int) -> Int {
    struct S {
        let b = 1
        func f(a: Int, b: Int = 2) -> Int { a + b }
    }
    return a + c
}
```

```swift
func f(a: Int?) {
    if let a {}
}
```

```swift
func f(a: Int) {
    let a = a
    return a
}
```

```swift
func f(`operator`: Int) -> Int { `operator` }
```

## Triggering Examples

```swift
func f(↓a: Int) {}
```

```swift
func f(↓a: Int, b ↓c: String) {}
```

```swift
func f(↓a: Int, b ↓c: String) {
    func g(a: Int, ↓b: Double) {
        _ = a
    }
}
```

```swift
struct S {
    let a: Int

    init(a: Int, ↓b: Int) {
        func f(↓a: Int, b: Int) -> Int { b }
        self.a = f(a: a, b: 0)
    }
}
```

```swift
struct S {
    subscript(a: Int, ↓b: Int) {
        func f(↓a: Int, b: Int) -> Int { b }
        return f(a: a, b: 0)
    }
}
```

```swift
func f(↓a: Int, ↓b: Int, c: Int) -> Int {
    struct S {
        let b = 1
        func f(a: Int, ↓c: Int = 2) -> Int { a + b }
    }
    return S().f(a: c)
}
```

```swift
func f(↓a: Int, c: String) {
    let a = 1
    return a + c
}
```