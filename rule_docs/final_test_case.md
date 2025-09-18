# Final Test Case

Test cases should be final

* **Identifier:** `final_test_case`
* **Enabled by default:** No
* **Supports autocorrection:** Yes
* **Kind:** performance
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
final class Test: XCTestCase {}
```

```swift
open class Test: XCTestCase {}
```

```swift
public final class Test: QuickSpec {}
```

```swift
class Test: MyTestCase {}
```

```swift
//
// test_parent_classes: ["MyTestCase", "QuickSpec", "XCTestCase"]
//

struct Test: MyTestCase {}

```

## Triggering Examples

```swift
class ↓Test: XCTestCase {}
```

```swift
public class ↓Test: QuickSpec {}
```

```swift
//
// test_parent_classes: ["MyTestCase", "QuickSpec", "XCTestCase"]
//

class ↓Test: MyTestCase {}

```