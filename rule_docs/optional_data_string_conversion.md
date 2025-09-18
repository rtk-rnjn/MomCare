# Optional Data -> String Conversion

Prefer failable `String(bytes:encoding:)` initializer when converting `Data` to `String`

* **Identifier:** `optional_data_string_conversion`
* **Enabled by default:** Yes
* **Supports autocorrection:** No
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
String(data: data, encoding: .utf8)
```

```swift
String(bytes: data, encoding: .utf8)
```

```swift
String(UTF8.self)
```

```swift
String(a, b, c, UTF8.self)
```

```swift
String(decoding: data, encoding: UTF8.self)
```

## Triggering Examples

```swift
String(decoding: data, as: UTF8.self)
```