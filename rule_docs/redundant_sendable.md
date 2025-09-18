# Redundant Sendable

Sendable conformance is redundant on an actor-isolated type

* **Identifier:** `redundant_sendable`
* **Enabled by default:** Yes
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
  <tr>
  <td>
  global_actors
  </td>
  <td>
  []
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
struct S: Sendable {}
```

```swift
class C: Sendable {}
```

```swift
actor A {}
```

```swift
@MainActor struct S {}
```

```swift
@MyActor enum E: Sendable { case a }
```

```swift
@MainActor protocol P: Sendable {}
```

## Triggering Examples

```swift
@MainActor struct ↓S: Sendable {}
```

```swift
actor ↓A: Sendable {}
```

```swift
//
// global_actors: ["MyActor"]
//

@MyActor enum ↓E: Sendable { case a }

```