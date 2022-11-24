//
//  Logger.swift
//
//
//  Created by Oliver on 20.03.20.
//

import Foundation
import UIKit

public struct Logger<Topic: LoggerTopic> {

    public var topicType: Topic.Type
    public var defaultTopic: Topic

    private let newLine: Data? = "\n".data(using: .utf8)
    private let logLineDateFormatter = Logger.getDateFormatter(for: "HH:mm:ss.SSS")
    private let logFileNameDateFormatter = Logger.getDateFormatter(for: "yyyy-MM-dd")
    private let logFileSuffix = ".log"

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
        if let autoDeleteLogFiles = safeTopic.configuration?.autoDelteLogFiles, autoDeleteLogFiles {
            handleLogFileRollOver(for: safeTopic)
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
        let uniqueDeviceId = getUniqueDeviceId()
        let logDirectoryName = "logs"
        var logDirectory: URL

        if #available(iOS 16.0, *) {
            logDirectory = getDocumentsDirectory()
                .appending(path: logDirectoryName)
                .appending(path: uniqueDeviceId.uuidString)
        } else {
            logDirectory = getDocumentsDirectory()
                .appendingPathComponent(logDirectoryName)
                .appendingPathComponent(uniqueDeviceId.uuidString)
        }

        if !logDirectory.existsAndIsDirectory() {
            do {
                try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: false)
            } catch {
                print("Could not create directory '\(logDirectory)'")
            }
        }
        return logDirectory
    }

    private func getUniqueDeviceId() -> UUID {
        guard let deviceId = UIDevice.current.identifierForVendor else {
            fatalError("Could not evaluate a unique device ID")
        }
        return deviceId
    }

    private func getLogFileUrl() -> URL {
        let logFile = logFileNameDateFormatter.string(from: Date()) + logFileSuffix
        return getLogDirectoryUrl().safeAppending(path: logFile)
    }

    private func handleLogFileRollOver(for topic: Topic) {

        let autoDeleteLogFiles = topic.configuration?.autoDelteLogFiles ?? Constants.DEFAULT_AUTO_DELETE_LOG_FILES
        guard autoDeleteLogFiles else  { return }

        let keepLogsForDays = topic.configuration?.keepLogsForDays ?? Constants.DEFAULT_FILE_ROLLOVER_IN_DAYS
        let logDirectoryUrl = getLogDirectoryUrl()

        if !logDirectoryUrl.isEmptyDirectory() {
            guard let keepFilesUntil = Date().subtract(days: keepLogsForDays) else {
                fatalError("Could not evaluate the threshold date for log files to keep.")
            }

            for logFile in logDirectoryUrl.listFiles() {
                if let logFileDate = parseDateFromLogFileName(logFileName: logFile),
                   logFileDate.isBefore(keepFilesUntil) {
                    logDirectoryUrl.safeAppending(path: logFile).deleteFile()
                }
            }
        }
    }

    private func parseDateFromLogFileName(logFileName: String) -> Date? {
        return logFileNameDateFormatter.date(from: logFileName.removeSuffix(suffix: logFileSuffix))
    }

    private static func getDateFormatter(for pattern: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter
    }
}

// MARK: URL Extensions
private extension URL {

    func safePath() -> String {
        if #available(iOS 16.0, *) {
            return path()
        } else {
            return path
        }
    }

    func safeAppending(path: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(path: path)
        } else {
            return appendingPathComponent(path)
        }
    }

    func existsAndIsDirectory() -> Bool {
        var isDirectory: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: safePath(), isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    func isEmptyDirectory() -> Bool {
        guard existsAndIsDirectory() else { return false }
        do {
            return try FileManager.default.contentsOfDirectory(atPath: safePath()).isEmpty
        } catch {
            fatalError("Could not check if \(safePath()) is an empty directory, got: \(error)")
        }
    }

    func listFiles() -> [String] {
        do {
            return try FileManager.default.contentsOfDirectory(atPath: safePath())
        } catch {
            fatalError("Could not list files at path \(safePath()), got: \(error)")
        }
    }

    func deleteFile() {
        do {
            try FileManager.default.removeItem(atPath: safePath())
        } catch {
            fatalError("Could not delete file at \(safePath()), got: \(error)")
        }
    }
}

// MARK: Date Extensions
private extension Date {
    func subtract(days: Int) -> Date? {
        var signedDays = days
        if signedDays.signum() == 1 {
            signedDays.negate()
        }
        return Calendar.current.date(byAdding: .day, value: signedDays, to: self)
    }

    func isBefore(_ other: Date) -> Bool {
        return self < other
    }
}

// MARK: String Extensions
private extension String {
    func removeSuffix(suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
