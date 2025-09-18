# Trailing Closure

Trailing closure syntax should be used whenever possible

* **Identifier:** `trailing_closure`
* **Enabled by default:** No
* **Supports autocorrection:** Yes
* **Kind:** style
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
  <tr>
  <td>
  only_single_muted_parameter
  </td>
  <td>
  false
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
foo.map { $0 + 1 }
```

```swift
foo.bar()
```

```swift
foo.reduce(0) { $0 + 1 }
```

```swift
if let foo = bar.map({ $0 + 1 }) { }
```

```swift
foo.something(param1: { $0 }, param2: { $0 + 1 })
```

```swift
offsets.sorted { $0.offset < $1.offset }
```

```swift
foo.something({ return 1 }())
```

```swift
foo.something({ return $0 }(1))
```

```swift
foo.something(0, { return 1 }())
```

```swift
for x in list.filter({ $0.isValid }) {}
```

```swift
if list.allSatisfy({ $0.isValid }) {}
```

```swift
foo(param1: 1, param2: { _ in true }, param3: 0)
```

```swift
foo(param1: 1, param2: { _ in true }) { $0 + 1 }
```

```swift
foo(param1: { _ in false }, param2: { _ in true })
```

```swift
foo(param1: { _ in false }, param2: { _ in true }, param3: { _ in false })
```

```swift
if f({ true }), g({ true }) {
    print("Hello")
}
```

```swift
for i in h({ [1,2,3] }) {
    print(i)
}
```

## Triggering Examples

```swift
foo.map(↓{ $0 + 1 })
```

```swift
foo.reduce(0, combine: ↓{ $0 + 1 })
```

```swift
offsets.sorted(by: ↓{ $0.offset < $1.offset })
```

```swift
foo.something(0, ↓{ $0 + 1 })
```

```swift
foo.something(param1: { _ in true }, param2: 0, param3: ↓{ _ in false })
```