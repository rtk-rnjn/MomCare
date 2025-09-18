# Shorthand Argument

Shorthand arguments like `$0`, `$1`, etc. in closures can be confusing. Avoid using them too far away from the beginning of the closure. Optionally, while usage of a single shorthand argument is okay, more than one or complex ones with field accesses might increase the risk of obfuscation.

* **Identifier:** `shorthand_argument`
* **Enabled by default:** No
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
  severity
  </td>
  <td>
  warning
  </td>
  </tr>
  <tr>
  <td>
  allow_until_line_after_opening_brace
  </td>
  <td>
  4
  </td>
  </tr>
  <tr>
  <td>
  always_disallow_more_than_one
  </td>
  <td>
  false
  </td>
  </tr>
  <tr>
  <td>
  always_disallow_member_access
  </td>
  <td>
  false
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
f { $0 }
```

```swift
f {
    $0
  + $1
  + $2
}
```

```swift
f { $0.a + $0.b }
```

```swift
//
// allow_until_line_after_opening_brace: 1
//

f {
    $0
  +  g { $0 }

```

## Triggering Examples

```swift
f {
    $0
  + $1
  + $2

  + ↓$0
}
```

```swift
//
// allow_until_line_after_opening_brace: 5
//

f {
    $0
  + $1
  + $2
  +  5
  + $0
  + ↓$1
}

```

```swift
//
// always_disallow_more_than_one: true
//

f { ↓$0 + ↓$1 }

```

```swift
//
// allow_until_line_after_opening_brace: 3
// always_disallow_member_access: true
//

f {
    ↓$0.a
  + ↓$0.b
  + $1
  + ↓$2.c
}

```