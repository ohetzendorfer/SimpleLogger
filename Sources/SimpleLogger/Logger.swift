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

    private let fileManager = FileManager.default
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

        guard safeTopic.isShowable else { return }
        printOutput(output, safeTopic)

        guard safeTopic.isWriteToFile else { return }
        writeOutput(output, safeTopic)
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

        let logFile = getLogFile()

        guard let outputData = getOutputAsString(output, topic).data(using: .utf8) else { return }

        do {

            let logFileExists: Bool

            if #available(iOS 16.0, *) {
                logFileExists = fileManager.fileExists(atPath: logFile.path())
            } else {
                logFileExists = fileManager.fileExists(atPath: logFile.path)
            }

            if logFileExists {
                try appendToExistingLogFile(logFile: logFile, data: outputData)
            } else {
                try createNewLogFile(logFile: logFile, data: outputData)
            }
        } catch {
            print("Could not write data to logfile, caught: \(error)")
        }
    }

    private func appendToExistingLogFile(logFile: URL, data: Data) throws {
        if let fileHandle = try? FileHandle(forWritingTo: logFile) {

            if #available(iOS 13.4, *) {
                try fileHandle.seekToEnd()
            } else {
                fileHandle.seekToEndOfFile()
            }

            fileHandle.write(data)

            if #available(iOS 13.0, *) {
                try fileHandle.close()
            } else {
                fileHandle.closeFile()
            }
        }
    }

    private func createNewLogFile(logFile: URL, data: Data) throws {
        try data.write(to: logFile, options: .atomic)
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
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    public func getLogDirectory() -> URL {

        let logDirectoryName = "logs"
        var logDirectory: URL

        if #available(iOS 16.0, *) {
            logDirectory = getDocumentsDirectory().appending(path: logDirectoryName)
        } else {
            logDirectory = getDocumentsDirectory().appendingPathComponent(logDirectoryName)
        }

        if !directoryExists(path: logDirectory) {
            do {
                try fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: false)
            } catch {
                print("Could not create directory '\(logDirectory)'")
            }
        }

        return logDirectory
    }

    private func directoryExists(path: URL) -> Bool {
        var isDirectory : ObjCBool = true
        let exists: Bool
        if #available(iOS 16.0, *) {
            exists = fileManager.fileExists(atPath: path.path(), isDirectory: &isDirectory)
        } else {
            exists = fileManager.fileExists(atPath: path.path, isDirectory: &isDirectory)
        }
        return exists && isDirectory.boolValue
    }

    private func getLogFile() -> URL {
        let logFile = logFileNameDateFormatter.string(from: Date()) + ".log"
        if #available(iOS 16.0, *) {
            return getLogDirectory().appending(path: logFile)
        } else {
            return getLogDirectory().appendingPathComponent(logFile)
        }
    }

    private static func getDateFormatter(for pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter
    }
}
