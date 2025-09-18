# No Empty Block

Code blocks should contain at least one statement or comment

* **Identifier:** `no_empty_block`
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
  disabled_block_types
  </td>
  <td>
  []
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
func f() {
    /* do something */
}

var flag = true {
    willSet { /* do something */ }
}
```

```swift
class Apple {
    init() { /* do something */ }

    deinit { /* do something */ }
}
```

```swift
for _ in 0..<10 { /* do something */ }

do {
    /* do something */
} catch {
    /* do something */
}

func f() {
    defer {
        /* do something */
    }
    print("other code")
}

if flag {
    /* do something */
} else {
    /* do something */
}

repeat { /* do something */ } while (flag)

while i < 10 { /* do something */ }
```

```swift
//
// disabled_block_types: [function_bodies]
//

func f() {}

var flag = true {
    willSet {}
}

```

```swift
//
// disabled_block_types: [initializer_bodies]
//

class Apple {
    init() {}

    deinit {}
}

```

```swift
//
// disabled_block_types: [statement_blocks]
//

for _ in 0..<10 {}

do {
} catch {
}

func f() {
    defer {}
    print("other code")
}

if flag {
} else {
}

repeat {} while (flag)

while i < 10 {}

```

```swift
f { _ in /* comment */ }
f { _ in // comment
}
f { _ in
    // comment
}
```

```swift
//
// disabled_block_types: [closure_blocks]
//

f {}
{}()

```

## Triggering Examples

```swift
func f() ↓{}

var flag = true {
    willSet ↓{}
}
```

```swift
class Apple {
    init() ↓{}

    deinit ↓{}
}
```

```swift
for _ in 0..<10 ↓{}

do ↓{
} catch ↓{
}

func f() {
    defer ↓{}
    print("other code")
}

if flag ↓{
} else ↓{
}

repeat ↓{} while (flag)

while i < 10 ↓{}
```

```swift
f ↓{}
```

```swift
Button ↓{} label: ↓{}
```