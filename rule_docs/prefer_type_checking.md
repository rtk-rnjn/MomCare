# Prefer Type Checking

Prefer `a is X` to `a as? X != nil`

* **Identifier:** `prefer_type_checking`
* **Enabled by default:** Yes
* **Supports autocorrection:** Yes
* **Kind:** idiomatic
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
let foo = bar as? Foo
```

```swift
bar is Foo
```

```swift
2*x is X
```

```swift
if foo is Bar {
    doSomeThing()
}
```

```swift
if let bar = foo as? Bar {
    foo.run()
}
```

```swift
bar as Foo != nil
```

```swift
nil != bar as Foo
```

```swift
bar as Foo? != nil
```

```swift
bar as? Foo? != nil
```

## Triggering Examples

```swift
bar ↓as? Foo != nil
```

```swift
2*x as? X != nil
```

```swift
if foo ↓as? Bar != nil {
    doSomeThing()
}
```

```swift
nil != bar ↓as? Foo
```

```swift
nil != 2*x ↓as? X
```