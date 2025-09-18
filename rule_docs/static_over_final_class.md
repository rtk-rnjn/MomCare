# Static Over Final Class

Prefer `static` over `class` when the declaration is not allowed to be overridden in child classes due to its context being final. Likewise, the compiler complains about `open` being used in `final` classes.

* **Identifier:** `static_over_final_class`
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
class C {
    static func f() {}
}
```

```swift
class C {
    static var i: Int { 0 }
}
```

```swift
class C {
    static subscript(_: Int) -> Int { 0 }
}
```

```swift
class C {
    class func f() {}
}
```

```swift
final class C {}
```

```swift
final class C {
    class D {
      class func f() {}
    }
}
```

## Triggering Examples

```swift
class C {
    ↓final class func f() {}
}
```

```swift
class C {
    ↓final class var i: Int { 0 }
}
```

```swift
class C {
    ↓final class subscript(_: Int) -> Int { 0 }
}
```

```swift
final class C {
    ↓class func f() {}
}
```

```swift
class C {
    final class D {
        ↓class func f() {}
    }
}
```