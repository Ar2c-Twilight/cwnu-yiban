//
//  LeaveRecordStore.swift
//  cwnu-yiban
//

import Foundation

// 把请假记录以JSON文件的形式，保存在App的Documents目录里
enum LeaveRecordStore {

    private static let fileURL = URL.documentsDirectory.appending(path: "leaveRecords.json")

    // 读取记录；第一次启动还没有文件时，返回一条示例数据
    static func load() -> [LeaveRecord] {
        guard let data = try? Data(contentsOf: fileURL),
              let records = try? JSONDecoder().decode([LeaveRecord].self, from: data) else {
            return [LeaveRecord.example]
        }
        return records
    }

    static func save(_ records: [LeaveRecord]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted,]
            let data = try encoder.encode(records)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("保存请假记录失败：\(error)")
        }
    }
}
