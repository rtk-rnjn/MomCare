# Redundant Void Return

Returning Void in a function declaration is redundant

* **Identifier:** `redundant_void_return`
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
  include_closures
  </td>
  <td>
  true
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
func foo() {}
```

```swift
func foo() -> Int {}
```

```swift
func foo() -> Int -> Void {}
```

```swift
func foo() -> VoidResponse
```

```swift
let foo: (Int) -> Void
```

```swift
func foo() -> Int -> () {}
```

```swift
let foo: (Int) -> ()
```

```swift
func foo() -> ()?
```

```swift
func foo() -> ()!
```

```swift
func foo() -> Void?
```

```swift
func foo() -> Void!
```

```swift
struct A {
    subscript(key: String) {
        print(key)
    }
}
```

```swift
//
// include_closures: false
//

doSomething { arg -> Void in
    print(arg)
}

```

## Triggering Examples

```swift
func foo()↓ -> Void {}
```

```swift
protocol Foo {
  func foo()↓ -> Void
}
```

```swift
func foo()↓ -> () {}
```

```swift
func foo()↓ -> ( ) {}
```

```swift
protocol Foo {
  func foo()↓ -> ()
}
```

```swift
doSomething { arg↓ -> () in
    print(arg)
}
```

```swift
doSomething { arg↓ -> Void in
    print(arg)
}
```