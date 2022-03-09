//
//  Logger.swift
//
//
//  Created by Oliver on 20.03.20.
//

import Foundation

public struct Logger<Topic: LoggerTopic> {

    var topicType: Topic.Type
    var defaultTopic: Topic
    
    public func output(
        _ output: Any,
        _ topic: Topic? = nil
    ) {
        printOutput(
            output,
            topic: topic ?? defaultTopic
        )
    }
    
    private func printOutput(
        _ output: Any,
        topic: Topic
    ) {
        print("\(topic.icon) \(topic.title)\t\t\(getPrintableDate())\t\t\(output)")
    }
    
    private func getPrintableDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        return dateFormatter.string(from: Date())
    }
}
