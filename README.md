# SimpleLogger
This is a simple logger which is build in a topic oriented way.

## Installation
Add swift package to your project.

## Usage
Create logger topics, setup the logger and start logging.
 
### Create your topic
```
enum MyTopic: String, LoggerTopic {
    case verbose, debug, error

    public var title: String {
        return rawValue.uppercased()
    }

    public var icon: Character {
        switch self {
        case .verbose: return "🐵"
        case .debug: return "🐸"
        case .error: return "🦊"
        }
    }
}
```
### Setup
```
let logger = Logger(
    topicType: MyTopic.self,
    defaultTopic: .verbose
)
```
### Output
```
logger.output("my log") // using default .verbose
logger.output("my log", .debug)
```
