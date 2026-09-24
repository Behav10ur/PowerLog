# PowerLog Project Instructions

## Project
- Native iOS SwiftUI application.
- Xcode project: `PowerLog.xcodeproj`
- Target and scheme: `PowerLog`
- Deployment target: iOS 18.1
- Swift version: 5.0
- Sources are in `PowerLog/`.

## Development
- Follow existing SwiftUI patterns and 4-space indentation.
- Use PascalCase for types, camelCase for properties and methods, and `@State private var` for local view state.
- Prefer async/await APIs; avoid Combine.
- Keep changes scoped to the requested task and avoid unrelated refactors.
- Do not add comments unless explicitly requested.

## Validation
- Build changes with Xcode's Build Project action.
- There is currently no test target, standalone lint command, or standalone typecheck command.
- Use compiler diagnostics for quick validation and a full project build before finishing.
