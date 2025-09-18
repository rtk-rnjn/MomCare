# One Declaration per File

Only a single declaration is allowed in a file

* **Identifier:** `one_declaration_per_file`
* **Enabled by default:** No
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
actor Foo {}
```

```swift
class Foo {}
extension Foo {}
```

```swift
struct S {
    struct N {}
}
```

## Triggering Examples

```swift
class Foo {}
↓class Bar {}
```

```swift
protocol Foo {}
↓enum Bar {}
```

```swift
struct Foo {}
↓struct Bar {}
```