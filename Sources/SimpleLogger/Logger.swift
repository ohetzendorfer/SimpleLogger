//
//  Logger.swift
//
//
//  Created by Oliver on 20.03.20.
//

import Foundation

public struct Logger {
    
    public static func setup(topicMessages: [LoggerTopicMessage], defaultTopicMessage: LoggerTopicMessage?) {
        LoggerStorage.shared.topicMessages = topicMessages
        LoggerStorage.shared.defaultTopicMessage = defaultTopicMessage
    }
    
    public static func output(_ output: Any, _ topicMessage: LoggerTopicMessage? = nil) {
        if let topicMessage = topicMessage {
            printOutput(output, topicMessage: topicMessage)
        } else if let defaultTopicMessage = LoggerStorage.shared.defaultTopicMessage {
            printOutput(output, topicMessage: defaultTopicMessage)
        }
    }
    
    private static func printOutput(_ output: Any, topicMessage: LoggerTopicMessage) {
        guard LoggerStorage.shared.topicMessages.contains(where: { $0.id == topicMessage.id }) else { return }
        print("\(topicMessage.icon) \(topicMessage.title)\t\t\(getPrintableDate())\t\t\(output)")
    }
    
    private static func getPrintableDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }
}
