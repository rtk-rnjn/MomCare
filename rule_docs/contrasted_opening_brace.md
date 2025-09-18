# Contrasted Opening Brace

The correct positioning of braces that introduce a block of code or member list is highly controversial. No matter which style is preferred, consistency is key. Apart from different tastes, the positioning of braces can also have a significant impact on the readability of the code, especially for visually impaired developers. This rule ensures that braces are on a separate line after the declaration to contrast the code block from the rest of the declaration. Comments between the declaration and the opening brace are respected. Check out the `opening_brace` rule for a different style.

* **Identifier:** `contrasted_opening_brace`
* **Enabled by default:** No
* **Supports autocorrection:** Yes
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
func abc()
{
}
```

```swift
[].map()
{
    $0
}
```

```swift
[].map(
    {
    }
)
```

```swift
if let a = b
{
}
```

```swift
while a == b
{
}
```

```swift
guard let a = b else
{
}
```

```swift
struct Rule
{
}
```

```swift
struct Parent
{
    struct Child
    {
        let foo: Int
    }
}
```

```swift
func f(rect: CGRect)
{
    {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        print(centre)
    }()
}
```

```swift
func f(rect: CGRect) -> () -> Void
{
    {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        print(centre)
    }
}
```

```swift
func f() -> () -> Void
{
    {}
}
```

```swift
@MyProperty class Rule:
  NSObject
{
  var a: String
  {
    return ""
  }
}
```

```swift
self.foo(
    (
        "String parameter",
        { "Do something here" }
    )
)
```

```swift
let pattern = #/(\{(?<key>\w+)\})/#
```

```swift
if c
{}
else
{}
```

```swift
    if c /* comment */
    {
        return
    }
```

```swift
if c1
{
  return
} else if c2
{
  return
} else if c3
{
  return
}
```

```swift
let a = f.map
{ a in
    a
}
```

## Triggering Examples

```swift
func abc()↓{
}
```

```swift
func abc() { }
```

```swift
func abc(a: A,
         b: B) {}
```

```swift
[].map { $0 }
```

```swift
struct OldContentView: View ↓{
  @State private var showOptions = false

  var body: some View ↓{
    Button(action: {
      self.showOptions.toggle()
    })↓{
      Image(systemName: "gear")
    } label: ↓{
      Image(systemName: "gear")
    }
  }
}
```

```swift
class Rule
{
  var a: String↓{
    return ""
  }
}
```

```swift
@MyProperty class Rule
{
  var a: String
  {
    willSet↓{

    }
    didSet  ↓{

    }
  }
}
```

```swift
precedencegroup Group ↓{
  assignment: true
}
```

```swift
if
    "test".isEmpty ↓{
    // code here
}
```

```swift
if c  ↓{}
else /* comment */  ↓{}
```

```swift
if c
  ↓{
    // code here
}
```

```swift
if c1 ↓{
  return
} else if c2↓{
  return
} else if c3
 ↓{
  return
}
```

```swift
func f()
{
    return a.map
            ↓{ $0 }
}
```

```swift
a ↓{
    $0
} b: ↓{
    $1
}
```