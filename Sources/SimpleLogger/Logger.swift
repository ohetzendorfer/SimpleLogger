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
            guard LoggerStorage.shared.topicMessages.contains(where: { $0.id == topicMessage.id }) else { return }
            printOutput(output, topicMessage: topicMessage)
        } else if let defaultType = LoggerStorage.shared.defaultTopicMessage {
            printOutput(output, topicMessage: defaultType)
        }
    }
    
    private static func printOutput(_ output: Any, topicMessage: LoggerTopicMessage) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let date = dateFormatter.string(from: Date())
        print("\(topicMessage.icon) \(topicMessage.title)\t\t\(date)\t\t\(output)")
    }
}
