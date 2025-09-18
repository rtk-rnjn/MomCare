# Redundant Type Annotation

Variables should not have redundant type annotation

* **Identifier:** `redundant_type_annotation`
* **Enabled by default:** No
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
  ignore_attributes
  </td>
  <td>
  [&quot;IBInspectable&quot;]
  </td>
  </tr>
  <tr>
  <td>
  ignore_properties
  </td>
  <td>
  false
  </td>
  </tr>
  <tr>
  <td>
  consider_default_literal_types_redundant
  </td>
  <td>
  false
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
var url = URL()
```

```swift
var url: CustomStringConvertible = URL()
```

```swift
var one: Int = 1, two: Int = 2, three: Int
```

```swift
guard let url = URL() else { return }
```

```swift
if let url = URL() { return }
```

```swift
let alphanumerics = CharacterSet.alphanumerics
```

```swift
var set: Set<Int> = Set([])
```

```swift
var set: Set<Int> = Set.init([])
```

```swift
var set = Set<Int>([])
```

```swift
var set = Set<Int>.init([])
```

```swift
guard var set: Set<Int> = Set([]) else { return }
```

```swift
if var set: Set<Int> = Set.init([]) { return }
```

```swift
guard var set = Set<Int>([]) else { return }
```

```swift
if var set = Set<Int>.init([]) { return }
```

```swift
var one: A<T> = B()
```

```swift
var one: A = B<T>()
```

```swift
var one: A<T> = B<T>()
```

```swift
let a = A.b.c.d
```

```swift
let a: B = A.b.c.d
```

```swift
enum Direction {
    case up
    case down
}

var direction: Direction = .up
```

```swift
enum Direction {
    case up
    case down
}

var direction = Direction.up
```

```swift
//
// ignore_attributes: ["IgnoreMe"]
//

@IgnoreMe var a: Int = Int(5)

```

```swift
//
// ignore_attributes: ["IgnoreMe"]
//

var a: Int {
    @IgnoreMe let i: Int = Int(1)
    return i
}

```

```swift
var bol: Bool = true
```

```swift
var dbl: Double = 0.0
```

```swift
var int: Int = 0
```

```swift
var str: String = "str"
```

```swift
//
// ignore_properties: true
//

struct Foo {
    var url: URL = URL()
    let myVar: Int? = 0, s: String = ""
}

```

## Triggering Examples

```swift
var url↓:URL=URL()
```

```swift
var url↓:URL = URL(string: "")
```

```swift
var url↓: URL = URL()
```

```swift
let url↓: URL = URL()
```

```swift
lazy var url↓: URL = URL()
```

```swift
let url↓: URL = URL()!
```

```swift
var one: Int = 1, two↓: Int = Int(5), three: Int
```

```swift
guard let url↓: URL = URL() else { return }
```

```swift
if let url↓: URL = URL() { return }
```

```swift
let alphanumerics↓: CharacterSet = CharacterSet.alphanumerics
```

```swift
var set↓: Set<Int> = Set<Int>([])
```

```swift
var set↓: Set<Int> = Set<Int>.init([])
```

```swift
var set↓: Set = Set<Int>([])
```

```swift
var set↓: Set = Set<Int>.init([])
```

```swift
guard var set↓: Set = Set<Int>([]) else { return }
```

```swift
if var set↓: Set = Set<Int>.init([]) { return }
```

```swift
guard var set↓: Set<Int> = Set<Int>([]) else { return }
```

```swift
if var set↓: Set<Int> = Set<Int>.init([]) { return }
```

```swift
var set↓: Set = Set<Int>([]), otherSet: Set<Int>
```

```swift
var num↓: Int = Int.random(0..<10)
```

```swift
let a↓: A = A.b.c.d
```

```swift
let a↓: A = A.f().b
```

```swift
class ViewController: UIViewController {
  func someMethod() {
    let myVar↓: Int = Int(5)
  }
}
```

```swift
//
// ignore_properties: true
//

class ViewController: UIViewController {
  func someMethod() {
    let myVar↓: Int = Int(5)
  }
}

```

```swift
let a↓: [Int] = [Int]()
```

```swift
let a↓: A.B = A.B()
```

```swift
enum Direction {
    case up
    case down
}

var direction↓: Direction = Direction.up
```

```swift
//
// ignore_attributes: ["IgnoreMe"]
//

@DontIgnoreMe var a↓: Int = Int(5)

```

```swift
//
// ignore_attributes: ["IgnoreMe"]
//

@IgnoreMe
var a: Int {
    let i↓: Int = Int(1)
    return i
}

```

```swift
//
// consider_default_literal_types_redundant: true
//

var bol↓: Bool = true

```

```swift
//
// consider_default_literal_types_redundant: true
//

var dbl↓: Double = 0.0

```

```swift
//
// consider_default_literal_types_redundant: true
//

var int↓: Int = 0

```

```swift
//
// consider_default_literal_types_redundant: true
//

var str↓: String = "str"

```