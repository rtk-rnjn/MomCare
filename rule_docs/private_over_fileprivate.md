# Private over Fileprivate

Prefer `private` over `fileprivate` declarations

* **Identifier:** `private_over_fileprivate`
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
  <tr>
  <td>
  validate_extensions
  </td>
  <td>
  false
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
extension String {}
```

```swift
private extension String {}
```

```swift
public protocol P {}
```

```swift
open extension 
 String {}
```

```swift
internal extension String {}
```

```swift
package typealias P = Int
```

```swift
extension String {
  fileprivate func Something(){}
}
```

```swift
class MyClass {
  fileprivate let myInt = 4
}
```

```swift
actor MyActor {
  fileprivate let myInt = 4
}
```

```swift
class MyClass {
  fileprivate(set) var myInt = 4
}
```

```swift
struct Outer {
  struct Inter {
    fileprivate struct Inner {}
  }
}
```

## Triggering Examples

```swift
↓fileprivate enum MyEnum {}
```

```swift
↓fileprivate class MyClass {
  fileprivate(set) var myInt = 4
}
```

```swift
↓fileprivate actor MyActor {
  fileprivate let myInt = 4
}
```

```swift
    ↓fileprivate func f() {}
    ↓fileprivate var x = 0
```