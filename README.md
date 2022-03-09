# SimpleLogger
Simple logging with self defined topics.
```
🐵 VERBOSE        21:52:16.540        logging something
🐸 DEBUG          21:52:16.540        is this working?
```

## Installation
Add this swift package to your project.

## Usage
Create logger topics, setup and start logging.
 
### Create topics
```swift
enum MyTopic: String, LoggerTopic {
    case verbose, debug, error

    var title: String {
        switch self {
        case .verbose: return "INFO"
        case .debug, .error: return rawValue.uppercased()
        }
    }

    var icon: Character {
        switch self {
        case .verbose: return "🐵"
        case .debug: return "🐸"
        case .error: return "🦊"
        }
    }
    
    public var isShowable: Bool {
        switch self {
        case .verbose, .error: return true
        case .debug: return false
        }
    }
}
```
### Setup
```swift
let logger = Logger(
    topicType: MyTopic.self,
    defaultTopic: .verbose
)
```
### Logging
```swift
logger.output("logging something") // using default .verbose
logger.output("is this working?", .debug)
```
