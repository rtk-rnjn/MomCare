---
description: 'Coding conventions and guidelines'
applyTo: '**/*.swift'
---

# Swift Coding Conventions

## Swift Instructions

- Write expressive names of variables, functions, and types, using camelCase for variable and function names, and PascalCase for type names. It's ok to use abbreviations if they are well-known and widely accepted.
- No force unwrapping of optionals (e.g., using `!`), instead use optional binding (e.g., `if let` or `guard let`) to safely unwrap optionals.
- No limit on line length, but try to keep lines under 100 characters when possible.
- Break down complex functions into smaller, more manageable functions.
- Use `OSLog` for logging instead of print statements.

## General Instructions

- Always prioritize readability and clarity.
- For algorithm-related code, include explanations of the approach used; otherwise avoid commenting the code at all.
- Codes should be self-explanatory and easy to follow, and should not requires comments unless absolutely necessary.
- Handle edge cases and write clear exception handling.
- Use consistent naming conventions and follow language-specific best practices.

## Code Style and Formatting

- Use 4 spaces for indentation, and do not use tabs.
- Use `.swiftformat` and `.swiftlint.yml` files to enforce code style and formatting rules.

## Example (Good Code):

```swift
struct Song: Codable, Sendable {
    let id: String = UUID().uuidString

    var title: String?
    var artist: String?
    var uri: String?
}

enum Source {
    case local
    case remote
}

func fetchSong(from source: Source) -> Song? {
    logger.info("Fetching song from \(source)")

    switch source {
    case .local:
        return fetchSongFromLocal()
    case .remote:
        return fetchSongFromRemote()
    }
}
```

## Example (Bad Code)

```swift
import OSLog

let logger: Logger = .init(subsystem: "com.example.SongFetcher", category: "network")

struct Song: Codable, Sendable {
    let id: String = UUID().uuidString

    var title: String?
    var artist: String?
    var uri: String?
}

enum Source {
    case local
    case remote
}

func fetchSong(from source: Source) -> Song? {
    // Fetch song from the source
    print("Fetching song from \(source)")

    switch source {
    case .local:
        return fetchSongFromLocal()
    case .remote:
        return fetchSongFromRemote()
    }
}
```
