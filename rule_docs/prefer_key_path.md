# Prefer Key Path

Use a key path argument instead of a closure with property access

* **Identifier:** `prefer_key_path`
* **Enabled by default:** No
* **Supports autocorrection:** Yes
* **Kind:** idiomatic
* **Analyzer rule:** No
* **Minimum Swift compiler version:** 5.2.0
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
  restrict_to_standard_functions
  </td>
  <td>
  true
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
f {}
```

```swift
f { $0 }
```

```swift
f { $0.a }
```

```swift
let f = { $0.a }(b)
```

```swift
//
// restrict_to_standard_functions: false
//

f {}

```

```swift
//
// restrict_to_standard_functions: false
//

f() { g() }

```

```swift
//
// restrict_to_standard_functions: false
//

f { a.b.c }

```

```swift
//
// restrict_to_standard_functions: false
//

f { a, b in a.b }

```

```swift
//
// restrict_to_standard_functions: false
//

f { (a, b) in a.b }

```

```swift
//
// restrict_to_standard_functions: false
//

f { $0.a } g: { $0.b }

```

```swift
//
// restrict_to_standard_functions: false
//

[1, 2, 3].reduce(1) { $0 + $1 }

```

```swift
f.map(1) { $0.a }
```

```swift
f.filter({ $0.a }, x)
```

```swift
#Predicate { $0.a }
```

```swift
let transform: (Int) -> Int = nil ?? { $0.a }
```

## Triggering Examples

```swift
f.map ↓{ $0.a }
```

```swift
f.filter ↓{ $0.a }
```

```swift
f.first ↓{ $0.a }
```

```swift
f.contains ↓{ $0.a }
```

```swift
f.contains(where: ↓{ $0.a })
```

```swift
//
// restrict_to_standard_functions: false
//

f(↓{ $0.a })

```

```swift
//
// restrict_to_standard_functions: false
//

f(a: ↓{ $0.b })

```

```swift
//
// restrict_to_standard_functions: false
//

f(a: ↓{ a in a.b }, x)

```

```swift
f.map ↓{ a in a.b.c }
```

```swift
f.allSatisfy ↓{ (a: A) in a.b }
```

```swift
f.first ↓{ (a b: A) in b.c }
```

```swift
f.contains ↓{ $0.0.a }
```

```swift
f.compactMap ↓{ $0.a.b.c.d }
```

```swift
f.flatMap ↓{ $0.a.b }
```

```swift
//
// restrict_to_standard_functions: false
//

let f: (Int) -> Int = ↓{ $0.bigEndian }

```

```swift
transform = ↓{ $0.a }
```