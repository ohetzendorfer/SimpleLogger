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

        guard let isWriteToFile = safeTopic.writeToFile, isWriteToFile else { return }
        writeOutput(output, safeTopic)
    }
    
    private func printOutput(
        _ output: Any,
        _ topic: Topic
    ) {
        print("\(topic.icon) \(topic.title)\t\t\(getPrintableDate())\t\t\(output)")
    }

    private func writeOutput(
        _ output: Any,
        _ topic: Topic
    ) {
        // TODO: implement file logging
    }
    
    private func getPrintableDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }
}
