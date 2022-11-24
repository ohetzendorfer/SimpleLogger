# SimpleLogger
Simple logging with self defined topics.
```
🐵 VERBOSE        21:52:16.540        logging something
🐸 DEBUG          21:52:16.540        is this working?
🦊 ERROR          21:53:16.540        Upsie, that should not have happened
```

```
// 2022-11-20.log
🦊 ERROR          21:53:16.540        Upsie, that should not have happened
```

## Installation
Add this swift package to your project.

## Usage
Create logger topics, setup and start logging.
 
### Create topics
A topic can either be used to represent a specific severity, like in the sample below, or it can be used to define
particular areas of your application you wish to log information for. E.g. a specific module, a remote client or 
whatever parts your application consists of.

The topic has a `title`, a `icon` and two boolean flags: `printInConsole` and `writeToFile`.
These booleans define if your logs should appear as output on the console and if they should be written to a log file
on the device itself.

If you enable the `writeToFile` flag the library will create a directory in your app's `Documents` folder named `logs`.
In this directory there will be a unique subfolder in which you will find log files per day that contain all logs that
return `true` for the `writeToFile` flag. The directory containing the logs can be retrieved using the function 
`Logger#getLogDirectoryUrl`.


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
    
    public var printInConsole: Bool {
        switch self {
        case .verbose, .error: return true
        case .debug: return false
        }
    }
        
    public var writeToFile: Bool {
        switch self {
        case .error: return true
        case .verbose, .debug: return false
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
logger.output("Upsie, that should not have happened", .error)
```
