//
//  Logger.swift
//
//
//  Created by Oliver on 20.03.20.
//

import Foundation

public struct Logger<Topic: LoggerTopic> {

    public var topicType: Topic.Type
    public var defaultTopic: Topic

    private let newLine: Data? = "\n".data(using: .utf8)
    private let logLineDateFormatter = Logger.getDateFormatter(for: "HH:mm:ss.SSS")
    private let logFileNameDateFormatter = Logger.getDateFormatter(for: "yyyy-MM-dd")

    public init(
        topicType: Topic.Type,
        defaultTopic: Topic
    ) {
        self.topicType = topicType
        self.defaultTopic = defaultTopic
    }

    public func output(
        _ output: Any,
        _ topic: Topic? = nil
    ) {
        let safeTopic = topic ?? defaultTopic

        if safeTopic.printInConsole {
            printOutput(output, safeTopic)
        }
        if safeTopic.writeToFile {
            writeOutput(output, safeTopic)
        }
    }

    private func printOutput(
        _ output: Any,
        _ topic: Topic
    ) {
        print(getOutputAsString(output, topic))
    }

    private func writeOutput(
        _ output: Any,
        _ topic: Topic
    ) {
        let logFileUrl = getLogFileUrl()
        guard let outputData = getOutputAsString(output, topic).data(using: .utf8) else { return }

        do {
            let logFileExists: Bool
            let fileManager = FileManager.default

            if #available(iOS 16.0, *) {
                logFileExists = fileManager.fileExists(atPath: logFileUrl.path())
            } else {
                logFileExists = fileManager.fileExists(atPath: logFileUrl.path)
            }

            if logFileExists {
                try appendToExistingLogFile(url: logFileUrl, data: outputData)
            } else {
                try createNewLogFile(url: logFileUrl, data: outputData)
            }
        } catch {
            print("Could not write data to logfile, caught: \(error)")
        }
    }

    private func appendToExistingLogFile(url: URL, data: Data) throws {
        let fileHandle = try FileHandle(forWritingTo: url)

        if #available(iOS 13.4, *) {
            try fileHandle.seekToEnd()
        } else {
            fileHandle.seekToEndOfFile()
        }

        if let newLine {
            fileHandle.write(newLine)
        }
        fileHandle.write(data)

        if #available(iOS 13.0, *) {
            try fileHandle.close()
        } else {
            fileHandle.closeFile()
        }
    }

    private func createNewLogFile(url: URL, data: Data) throws {
        try data.write(to: url, options: .atomic)
    }

    private func getOutputAsString(
        _ output: Any,
        _ topic: Topic
    ) -> String {
        return "\(topic.icon) \(topic.title)\t\t\(getPrintableDate())\t\t\(output)"
    }

    private func getPrintableDate() -> String {
        return logLineDateFormatter.string(from: Date())
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public func getLogDirectoryUrl() -> URL {
        let logDirectoryName = "logs"
        var logDirectory: URL

        if #available(iOS 16.0, *) {
            logDirectory = getDocumentsDirectory().appending(path: logDirectoryName)
        } else {
            logDirectory = getDocumentsDirectory().appendingPathComponent(logDirectoryName)
        }

        if !directoryExists(path: logDirectory) {
            do {
                try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: false)
            } catch {
                print("Could not create directory '\(logDirectory)'")
            }
        }
        return logDirectory
    }

    private func directoryExists(path: URL) -> Bool {
        var isDirectory: ObjCBool = true
        let exists: Bool
        let fileManager = FileManager.default

        if #available(iOS 16.0, *) {
            exists = fileManager.fileExists(atPath: path.path(), isDirectory: &isDirectory)
        } else {
            exists = fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory)
        }
        return exists && isDirectory.boolValue
    }

    private func getLogFileUrl() -> URL {
        let logFile = logFileNameDateFormatter.string(from: Date()) + ".log"
        if #available(iOS 16.0, *) {
            return getLogDirectoryUrl().appending(path: logFile)
        } else {
            return getLogDirectoryUrl().appendingPathComponent(logFile)
        }
    }

    private static func getDateFormatter(for pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter
    }
}
