# No Magic Numbers

Magic numbers should be replaced by named constants

* **Identifier:** `no_magic_numbers`
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
  <tr>
  <td>
  test_parent_classes
  </td>
  <td>
  [&quot;QuickSpec&quot;, &quot;XCTestCase&quot;]
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
var foo = 123
```

```swift
static let bar: Double = 0.123
```

```swift
let a = b + 1.0
```

```swift
array[0] + array[1] 
```

```swift
let foo = 1_000.000_01
```

```swift
// array[1337]
```

```swift
baz("9999")
```

```swift
func foo() {
    let x: Int = 2
    let y = 3
    let vector = [x, y, -1]
}
```

```swift
class A {
    var foo: Double = 132
    static let bar: Double = 0.98
}
```

```swift
@available(iOS 13, *)
func version() {
    if #available(iOS 13, OSX 10.10, *) {
        return
    }
}
```

```swift
enum Example: Int {
    case positive = 2
    case negative = -2
}
```

```swift
class FooTests: XCTestCase {
    let array: [Int] = []
    let bar = array[42]
}
```

```swift
class FooTests: XCTestCase {
    class Bar {
        let array: [Int] = []
        let bar = array[42]
    }
}
```

```swift
class MyTest: XCTestCase {}
extension MyTest {
    let a = Int(3)
}
```

```swift
extension MyTest {
    let a = Int(3)
}
class MyTest: XCTestCase {}
```

```swift
let foo = 1 << 2
```

```swift
let foo = 1 >> 2
```

```swift
let foo = 2 >> 2
```

```swift
let foo = 2 << 2
```

```swift
let a = b / 100.0
```

```swift
let range = 2 ..< 12
```

```swift
let range = ...12
```

```swift
let range = 12...
```

```swift
let (lowerBound, upperBound) = (400, 599)
```

```swift
let a = (5, 10)
```

```swift
let notFound = (statusCode: 404, description: "Not Found", isError: true)
```

```swift
#Preview {
    ContentView(value: 5)
}
```

## Triggering Examples

```swift
foo(↓321)
```

```swift
bar(↓1_000.005_01)
```

```swift
array[↓42]
```

```swift
let box = array[↓12 + ↓14]
```

```swift
let a = b + ↓2.0
```

```swift
let range = 2 ... ↓12 + 1
```

```swift
let range = ↓2*↓6...
```

```swift
let slice = array[↓2...↓4]
```

```swift
for i in ↓3 ..< ↓8 {}
```

```swift
let n: Int = Int(r * ↓255) << ↓16 | Int(g * ↓255) << ↓8
```

```swift
Color.primary.opacity(isAnimate ? ↓0.1 : ↓1.5)
```

```swift
        class MyTest: XCTestCase {}
        extension NSObject {
            let a = Int(↓3)
        }
```

```swift
if (fileSize > ↓1000000) {
    return
}
```

```swift
let imageHeight = (width - ↓24)
```

```swift
return (↓5, ↓10, ↓15)
```

```swift
#ExampleMacro {
    ContentView(value: ↓5)
}
```