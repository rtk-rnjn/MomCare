# Async Without Await

Declaration should not be async if it doesn't use await

* **Identifier:** `async_without_await`
* **Enabled by default:** No
* **Supports autocorrection:** Yes
* **Kind:** lint
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
func test() {
    func test() async {
        await test()
    }
},
```

```swift
func test() {
    func test() async {
        await test().value
    }
},
```

```swift
func test() async {
    await scheduler.task { foo { bar() } }
}
```

```swift
func test() async {
    perform(await try foo().value)
}
```

```swift
func test() async {
    perform(try await foo())
}
```

```swift
func test() async {
    await perform()
    func baz() {
        qux()
    }
}
```

```swift
let x: () async -> Void = {
    await test()
}
```

```swift
let x: () async -> Void = {
    await { await test() }()
}
```

```swift
func test() async {
    await foo()
}
let x = { bar() }
```

```swift
let x: (() async -> Void)? = {
    await { await test() }()
}
```

```swift
let x: (() async -> Void)? = nil
let x: () -> Void = { test() }
```

```swift
var test: Int {
    get async throws {
        try await foo()
    }
}
var foo: Int {
    get throws {
        try bar()
    }
}
```

```swift
init() async {
    await foo()
}
```

```swift
init() async {
    func test() async {
        await foo()
    }
    await { await foo() }()
}
```

```swift
subscript(row: Int) -> Double {
    get async {
        await foo()
    }
}
```

```swift
func foo() async -> Int
func bar() async -> Int
```

```swift
var foo: Int { get async }
var bar: Int { get async }
```

```swift
init(foo: bar) async
init(baz: qux) async
let baz = { qux() }
```

```swift
typealias Foo = () async -> Void
typealias Bar = () async -> Void
let baz = { qux() }
```

```swift
func test() async {
    for await foo in bar {}
}
```

```swift
func test() async {
    while let foo = await bar() {}
}
```

```swift
func test() async {
    async let foo = bar()
    let baz = await foo
}
```

```swift
func test() async {
    async let foo = bar()
    await foo
}
```

```swift
func test() async {
    async let foo = bar()
}
```

```swift
func foo(bar: () async -> Void) { { } }
```

```swift
func foo(bar: () async -> Void = { await baz() }) { {} }
```

```swift
func foo() -> (() async -> Void)? { {} }
```

```swift
func foo(
    bar: () async -> Void,
    baz: () -> Void = {}
) { { } }
```

```swift
func foo(bar: () async -> Void = {}) { }
```

## Triggering Examples

```swift
func test() ↓async {
    perform()
}
```

```swift
func test() {
    func baz() ↓async {
        qux()
    }
    perform()
    func baz() {
        qux()
    }
}
```

```swift
func test() ↓async {
    func baz() async {
        await qux()
    }
}
```

```swift
func test() ↓async {
  func foo() ↓async {}
  let bar = { await foo() }
}
```

```swift
func test() ↓async {
    let bar = {
        func foo() ↓async {}
    }
}
```

```swift
let x: (() ↓async -> Void)? = { test() }
```

```swift
var test: Int {
    get ↓async throws {
        foo()
    }
}
```

```swift
var test: Int {
    get ↓async throws {
        func foo() ↓async {}
        let bar = { await foo() }
    }
}
```

```swift
var test: Int {
    get throws {
        func foo() {}
        let bar: () ↓async -> Void = { foo() }
    }
}
```

```swift
init() ↓async {}
```

```swift
init() ↓async {
    func foo() ↓async {}
    let bar: () ↓async -> Void = { foo() }
}
```

```swift
subscript(row: Int) -> Double {
    get ↓async {
        1.0
    }
}
```

```swift
func test() ↓async {
    for foo in bar {}
}
```

```swift
func test() ↓async {
    while let foo = bar() {}
}
```