# Unused Enumerated

When the index or the item is not used, `.enumerated()` can be removed.

* **Identifier:** `unused_enumerated`
* **Enabled by default:** Yes
* **Supports autocorrection:** No
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
for (idx, foo) in bar.enumerated() { }
```

```swift
for (_, foo) in bar.enumerated().something() { }
```

```swift
for (_, foo) in bar.something() { }
```

```swift
for foo in bar.enumerated() { }
```

```swift
for foo in bar { }
```

```swift
for (idx, _) in bar.enumerated().something() { }
```

```swift
for (idx, _) in bar.something() { }
```

```swift
for idx in bar.indices { }
```

```swift
for (section, (event, _)) in data.enumerated() {}
```

```swift
list.enumerated().map { idx, elem in "\(idx): \(elem)" }
```

```swift
list.enumerated().map { $0 + $1 }
```

```swift
list.enumerated().something().map { _, elem in elem }
```

```swift
list.enumerated().map { ($0.offset, $0.element) }
```

```swift
list.enumerated().map { ($0.0, $0.1) }
```

```swift
list.enumerated().map {
    $1.enumerated().forEach { print($0, $1) }
    return $0
}
```

## Triggering Examples

```swift
for (↓_, foo) in bar.enumerated() { }
```

```swift
for (↓_, foo) in abc.bar.enumerated() { }
```

```swift
for (↓_, foo) in abc.something().enumerated() { }
```

```swift
for (idx, ↓_) in bar.enumerated() { }
```

```swift
list.enumerated().map { idx, ↓_ in idx }
```

```swift
list.enumerated().map { ↓_, elem in elem }
```

```swift
list.↓enumerated().forEach { print($0) }
```

```swift
list.↓enumerated().map { $1 }
```

```swift
list.enumerated().map {
    $1.↓enumerated().forEach { print($1) }
    return $0
}
```

```swift
list.↓enumerated().map {
    $1.enumerated().forEach { print($0, $1) }
    return 1
}
```

```swift
list.↓enumerated().forEach {
    let (i, _) = $0
}
```