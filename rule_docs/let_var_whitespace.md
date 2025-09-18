# Variable Declaration Whitespace

Variable declarations should be separated from other statements by a blank line

* **Identifier:** `let_var_whitespace`
* **Enabled by default:** No
* **Supports autocorrection:** No
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
  </tbody>
  </table>

## Non Triggering Examples

```swift
class C {
let a = 0
var x = 1

var y = 2
}
```

```swift
class C {
let a = 5

var x = 1
}
```

```swift
class C {
var a = 0
}
```

```swift
class C {
let a = 1 +
    2
let b = 5
}
```

```swift
class C {
var x: Int {
    return 0
}
}
```

```swift
class C {
var x: Int {
    let a = 0

    return a
}
}
```

```swift
class C {
#if os(macOS)
let a = 0

func f() {}
#endif
}
```

```swift
class C {
#warning("TODO: remove it")
let a = 0
#warning("TODO: remove it")
let b = 0
}
```

```swift
class C {
#error("TODO: remove it")
let a = 0
}
```

```swift
class C {
@available(swift 4)
let a = 0
}
```

```swift
class C {
@objc
var s: String = ""
}
```

```swift
class C {
@objc
func a() {}
}
```

```swift
class C {
var x = 0
lazy
var y = 0
}
```

```swift
class C {
@available(OSX, introduced: 10.6)
@available(*, deprecated)
var x = 0
}
```

```swift
class C {
// swiftlint:disable superfluous_disable_command
// swiftlint:disable force_cast

let x = bar as! Bar
}
```

```swift
class C {
@available(swift 4)
@UserDefault("param", defaultValue: true)
var isEnabled = true

@Attribute
func f() {}
}
```

```swift
class C {
var x: Int {
    let a = 0
    return a
}
}
```

```swift
a = 2
```

```swift
a = 2

var b = 3
```

```swift
#warning("message")
let a = 2
```

```swift
#if os(macOS)
let a = 2
#endif
```

```swift
f {
    let a = 1
    return a
}
```

```swift
func f() {
    #if os(macOS)
    let a = 2
    return a
    #else
    return 1
    #endif
}
```

## Triggering Examples

```swift
class C {
let a
↓func x() {}
}
```

```swift
class C {
var x = 0
↓@objc func f() {}
}
```

```swift
class C {
var x = 0
↓@objc
func f() {}
}
```

```swift
class C {
@objc func f() {
}
↓var x = 0
}
```

```swift
class C {
func f() {}
↓@Wapper
let isNumber = false
@Wapper
var isEnabled = true
↓func g() {}
}
```

```swift
class C {
#if os(macOS)
let a = 0
↓func f() {}
#endif
}
```

```swift
let a = 2
↓b = 1
```