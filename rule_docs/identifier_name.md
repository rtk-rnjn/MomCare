# Identifier Name

Identifier names should only contain alphanumeric characters and start with a lowercase character or should only contain capital letters. In an exception to the above, variable names may start with a capital letter when they are declared as static. Variable names should not be too long or too short.

* **Identifier:** `identifier_name`
* **Enabled by default:** Yes
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
  min_length
  </td>
  <td>
  <table>
  <thead>
  <tr><th>Key</th><th>Value</th></tr>
  </thead>
  <tbody>
  <tr>
  <td>
  warning
  </td>
  <td>
  3
  </td>
  </tr>
  <tr>
  <td>
  error
  </td>
  <td>
  2
  </td>
  </tr>
  </tbody>
  </table>
  </td>
  </tr>
  <tr>
  <td>
  max_length
  </td>
  <td>
  <table>
  <thead>
  <tr><th>Key</th><th>Value</th></tr>
  </thead>
  <tbody>
  <tr>
  <td>
  warning
  </td>
  <td>
  40
  </td>
  </tr>
  <tr>
  <td>
  error
  </td>
  <td>
  60
  </td>
  </tr>
  </tbody>
  </table>
  </td>
  </tr>
  <tr>
  <td>
  excluded
  </td>
  <td>
  [&quot;^id$&quot;]
  </td>
  </tr>
  <tr>
  <td>
  allowed_symbols
  </td>
  <td>
  []
  </td>
  </tr>
  <tr>
  <td>
  unallowed_symbols_severity
  </td>
  <td>
  error
  </td>
  </tr>
  <tr>
  <td>
  validates_start_with_lowercase
  </td>
  <td>
  error
  </td>
  </tr>
  <tr>
  <td>
  additional_operators
  </td>
  <td>
  [&quot;!&quot;, &quot;%&quot;, &quot;&&quot;, &quot;*&quot;, &quot;+&quot;, &quot;-&quot;, &quot;.&quot;, &quot;/&quot;, &quot;<&quot;, &quot;=&quot;, &quot;>&quot;, &quot;?&quot;, &quot;^&quot;, &quot;|&quot;, &quot;~&quot;]
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
let myLet = 0
```

```swift
var myVar = 0
```

```swift
private let _myLet = 0
```

```swift
private func _myFunc() {}
```

```swift
fileprivate let _myLet = 0
```

```swift
fileprivate func _myFunc() {}
```

```swift
fileprivate func _myFunc() {}
```

```swift
class Abc { static let MyLet = 0 }
```

```swift
let URL: NSURL? = nil
```

```swift
let XMLString: String? = nil
```

```swift
override var i = 0
```

```swift
enum Foo { case myEnum }
```

```swift
func isOperator(name: String) -> Bool
```

```swift
func typeForKind(_ kind: SwiftDeclarationKind) -> String
```

```swift
func == (lhs: SyntaxToken, rhs: SyntaxToken) -> Bool
```

```swift
override func IsOperator(name: String) -> Bool
```

```swift
enum Foo { case `private` }
```

```swift
enum Foo { case value(String) }
```

```swift
f { $abc in }
```

```swift
class Foo {
   static let Bar = 0
}
```

```swift
class Foo {
   static var Bar = 0
}
```

```swift
//
// additional_operators: ["!", "%", "&", "*", "+", "-", ".", "/", "<", "=", ">", "?", "^", "|", "~", "√"]
//

func √ (arg: Double) -> Double { arg }

```

## Triggering Examples

```swift
class C { static let ↓_myLet = 0 }
```

```swift
class C { class let ↓MyLet = 0 }
```

```swift
class C { static func ↓MyFunc() {} }
```

```swift
class C { class func ↓MyFunc() {} }
```

```swift
private let ↓myLet_ = 0
```

```swift
let ↓myExtremelyVeryVeryVeryVeryVeryVeryLongLet = 0
```

```swift
var ↓myExtremelyVeryVeryVeryVeryVeryVeryLongVar = 0
```

```swift
private let ↓_myExtremelyVeryVeryVeryVeryVeryVeryLongLet = 0
```

```swift
let ↓i = 0
```

```swift
var ↓aa = 0
```

```swift
private let ↓_i = 0
```

```swift
if let ↓_x {}
```

```swift
guard var ↓x = x else {}
```

```swift
func myFunc(
    _ ↓s: String,
    i ↓j: Int,
    _ goodName: Double,
    name ↓n: String,
    ↓x: Int,
    abc: Double,
    _: Double,
    last _: Double
) {}
```

```swift
let (↓a, abc) = (1, 1)
```

```swift
if let ↓i {}
```

```swift
for ↓i in [] {}
```

```swift
f { ↓x in }
```

```swift
f { ↓$x in }
```

```swift
f { (x abc: Int, _ ↓x: Int) in }
```

```swift
enum E {
    case ↓c
    case case1(Int)
    case case2(↓a: Int)
    case case3(_ ↓a: Int)
}
```

```swift
class C {
    var ↓x: Int {
        get { 1 }
        set(↓y) { x = y }
    }
}
```

```swift
func ↓√ (arg: Double) -> Double { arg }
```