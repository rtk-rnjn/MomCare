# Missing Docs

Declarations should be documented.

* **Identifier:** `missing_docs`
* **Enabled by default:** No
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
  warning
  </td>
  <td>
  [open, public]
  </td>
  </tr>
  <tr>
  <td>
  excludes_extensions
  </td>
  <td>
  true
  </td>
  </tr>
  <tr>
  <td>
  excludes_inherited_types
  </td>
  <td>
  true
  </td>
  </tr>
  <tr>
  <td>
  excludes_trivial_init
  </td>
  <td>
  false
  </td>
  </tr>
  <tr>
  <td>
  evaluate_effective_access_control_level
  </td>
  <td>
  false
  </td>
  </tr>
  </tbody>
  </table>

## Non Triggering Examples

```swift
/// docs
public class A {
/// docs
public func b() {}
}
// no docs
public class B: A { override public func b() {} }
```

```swift
import Foundation
// no docs
public class B: NSObject {
// no docs
override public var description: String { fatalError() } }
```

```swift
/// docs
public class A {
    var j = 1
    var i: Int { 1 }
    func f() {}
    deinit {}
}
```

```swift
public extension A {}
```

```swift
enum E {
    case A
}
```

```swift
//
// excludes_trivial_init: true
//

/// docs
public class A {
    public init() {}
}

```

```swift
//
// evaluate_effective_access_control_level: true
//

class C {
    public func f() {}
}

```

```swift
public struct S: ~Copyable, P {
    public init() {}
}
```

## Triggering Examples

```swift
public ↓func a() {}
```

```swift
// regular comment
public ↓func a() {}
```

```swift
/* regular comment */
public ↓func a() {}
```

```swift
/// docs
public protocol A {
    // no docs
    ↓var b: Int { get }
}
/// docs
public struct C: A {
    public let b: Int
}
```

```swift
/// a doc
public class C {
    public static ↓let i = 1
}
```

```swift
public extension A {
    public ↓func f() {}
    static ↓var i: Int { 1 }
    ↓struct S {
        func f() {}
    }
    ↓class C {
        func f() {}
    }
    ↓actor A {
        func f() {}
    }
    ↓enum E {
        ↓case a
        func f() {}
    }
}
```

```swift
public extension A {
    ↓enum E {
        enum Inner {
            case a
        }
    }
}
```

```swift
extension E {
    public ↓struct S {
        public static ↓let i = 1
    }
}
```

```swift
extension E {
    public ↓func f() {}
}
```

```swift
//
// excludes_trivial_init: true
//

/// docs
public class A {
    public ↓init(argument: String) {}
}

```

```swift
//
// excludes_inherited_types: false
//

public ↓struct C: A {
    public ↓let b: Int
}

```

```swift
//
// excludes_extensions: false
//

public ↓extension A {
    public ↓func f() {}
}

```

```swift
public extension E {
    ↓var i: Int {
        let j = 1
        func f() {}
        return j
    }
}
```

```swift
#if os(macOS)
public ↓func f() {}
#endif
```

```swift
public ↓enum E {
    ↓case A, B
    func f() {}
    init(_ i: Int) { self = .A }
}
```

```swift
/// a doc
public struct S {}
public extension S {
    ↓enum E {
        ↓case A
    }
}
```

```swift
//
// evaluate_effective_access_control_level: false
//

class C {
    public ↓func f() {}
}

```

```swift
public ↓struct S: ~Copyable, ~Escapable {
    public ↓init() {}
}
```