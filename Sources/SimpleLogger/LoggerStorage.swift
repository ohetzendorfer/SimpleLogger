//
//  LoggerStorage.swift
//
//
//  Created by Oliver on 20.03.20.
//

struct LoggerStorage {
    static var shared = LoggerStorage()
    
    var topicMessages = [LoggerTopicMessage]()
    var defaultTopicMessage: LoggerTopicMessage?
    var maxCharaters: Int = 0
}
