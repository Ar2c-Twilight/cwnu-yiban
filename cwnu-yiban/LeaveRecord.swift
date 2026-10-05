//
//  LeaveRecord.swift
//  cwnu-yiban
//

import Foundation

// Codable：可以和JSON互相转换，用于保存到文件
struct LeaveRecord: Codable {
    var studentID: String
    var name: String
    var date: String
    var duration: String
    var reason: String
    var location: String

    var checked: Bool

    // 示例数据
    static let example = LeaveRecord(
        studentID: "202520240619",
        name: "殷庭宇",
        date: "2025/09/30 20 至 2025/10/08 20",
        duration: "8天0小时",
        reason: "回家",
        location: "四川省成都市市辖区四川成都市辖区周边",

        checked: true
    )
}
