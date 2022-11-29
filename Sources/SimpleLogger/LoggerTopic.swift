//
//  LoggerTopicMessage.swift
//
//
//  Created by Oliver on 20.03.20.
//

public protocol LoggerTopic {
    var title: String { get }
    var icon: Character { get }
    var printInConsole: Bool { get }
    var writeToFile: Bool { get }
    var configuration: TopicConfiguration? { get }
}

public struct TopicConfiguration {
    var autoDelteLogFiles: Bool = Constants.DEFAULT_AUTO_DELETE_LOG_FILES
    var keepLogsForDays: Int = Constants.DEFAULT_FILE_ROLLOVER_IN_DAYS
}
