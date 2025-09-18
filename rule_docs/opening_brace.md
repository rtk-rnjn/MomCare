# Opening Brace Spacing

The correct positioning of braces that introduce a block of code or member list is highly controversial. No matter which style is preferred, consistency is key. Apart from different tastes, the positioning of braces can also have a significant impact on the readability of the code, especially for visually impaired developers. This rule ensures that braces are preceded by a single space and on the same line as the declaration. Comments between the declaration and the opening brace are respected. Check out the `contrasted_opening_brace` rule for a different style.

* **Identifier:** `opening_brace`
* **Enabled by default:** Yes
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
  <tr>
  <td>
  ignore_multiline_type_headers
  </td>
  <td>
  false
  </td>
  </tr>
  <tr>
  <td>
  ignore_multiline_statement_conditions
  </td>
  <td>
  false
  </td>
  </tr>
  <tr>
  <td>
  ignore_multiline_function_signatures
  </td>
  <td>
  false
  </td>
  </tr>
  <tr>
  <td>
  allow_multiline_func
  </td>
  <td>
  false
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
func abc() {
}
```

```swift
[].map() { $0 }
```

```swift
[].map({ })
```

```swift
if let a = b { }
```

```swift
while a == b { }
```

```swift
guard let a = b else { }
```

```swift
struct Rule {}
```

```swift
struct Parent {
	struct Child {
		let foo: Int
	}
}
```

```swift
func f(rect: CGRect) {
    {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        print(centre)
    }()
}
```

```swift
func f(rect: CGRect) -> () -> Void {
    {
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        print(centre)
    }
}
```

```swift
func f() -> () -> Void {
    {}
}
```

```swift
class Rule:
  NSObject {
  var a: String {
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
if c {}
else {}
```

```swift
    if c /* comment */ {
        return
    }
```

## Triggering Examples

```swift
func abc()↓{
}
```

```swift
func abc()
	↓{ }
```

```swift
func abc(a: A,
	b: B)
↓{
```

```swift
[].map()↓{ $0 }
```

```swift
struct OldContentView: View {
  @State private var showOptions = false

  var body: some View {
    Button(action: {
      self.showOptions.toggle()
    })↓{
      Image(systemName: "gear")
    }
  }
}
```

```swift
struct OldContentView: View {
  @State private var showOptions = false

  var body: some View {
    Button(action: {
      self.showOptions.toggle()
    })
   ↓{
      Image(systemName: "gear")
    }
  }
}
```

```swift
struct OldContentView: View {
  @State private var showOptions = false

  var body: some View {
    Button {
      self.showOptions.toggle()
    } label:↓{
      Image(systemName: "gear")
    }
  }
}
```

```swift
if let a = b↓{ }
```

```swift
while a == b↓{ }
```

```swift
guard let a = b else↓{ }
```

```swift
if
	let a = b,
	let c = d
	where a == c↓{ }
```

```swift
while
	let a = b,
	let c = d
	where a == c↓{ }
```

```swift
guard
	let a = b,
	let c = d
	where a == c else↓{ }
```

```swift
struct Rule↓{}
```

```swift
struct Rule
↓{
}
```

```swift
struct Rule

	↓{
}
```

```swift
struct Parent {
	struct Child
	↓{
		let foo: Int
	}
}
```

```swift
switch a↓{}
```

```swift
if
	let a = b,
	let c = d,
	a == c
↓{ }
```

```swift
while
	let a = b,
	let c = d,
	a == c
↓{ }
```

```swift
guard
	let a = b,
	let c = d,
	a == c else
↓{ }
```

```swift
class Rule↓{}

```

```swift
actor Rule↓{}

```

```swift
enum Rule↓{}

```

```swift
protocol Rule↓{}

```

```swift
extension Rule↓{}

```

```swift
class Rule {
  var a: String↓{
    return ""
  }
}
```

```swift
class Rule {
  var a: String {
    willSet↓{

    }
    didSet  ↓{

    }
  }
}
```

```swift
precedencegroup Group↓{
  assignment: true
}
```

```swift
if
    "test".isEmpty
↓{
    // code here
}
```

```swift
func fooFun() {
    let foo: String? = "foo"
    let bar: String? = "bar"

    if
        let foo = foo,
        let bar = bar
    ↓{
        print(foo + bar)
    }
}
```

```swift
if
    let a = ["A", "B"].first,
    let b = ["B"].first
↓{
    print(a)
}
```

```swift
if c  ↓{}
else /* comment */  ↓{}
```