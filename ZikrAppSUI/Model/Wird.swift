//
//  Wird.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.01.2023.
//

import Foundation
import RealmSwift

class Wird: Object, Decodable, Identifiable {
    @Persisted var id: String
    @Persisted var title: String
    @Persisted var isDeletable: Bool
    @Persisted var zikrs: List<WirdZikr>
    @Persisted var totalDoneCount: Int

    @Persisted var dailyTargetAmountAmount: Int = 0
    @Persisted var dailyProgress = List<DailyZikrProgress>()

    @Persisted var repeatTimes: Int?
    var type: ZikrType {
        .wird
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case zikrs
        case repeatTimes
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        isDeletable = false
        let tempZikrs = try container.decode([WirdZikr].self, forKey: .zikrs)
        let zikrsList = List<WirdZikr>()
        for zikr in tempZikrs {
            zikrsList.append(zikr)
        }
        repeatTimes = try container.decode(Int?.self, forKey: .repeatTimes)
        zikrs = zikrsList
        totalDoneCount = 0
        super.init()
    }

    override init() {
        super.init()
    }

    func getSubtitle(language: Language) -> String {
        zikrs.map { "\($0.targetCount) \($0.zikrId.localized(language))" }.joined(separator: ", ")
    }

    func getCurrentProgress(for date: Date) -> (Int, Int)? {
        if date.isPastDay {
            guard let progress = dailyProgress.first(where: { $0.date.isSame(to: date) && $0.isActive }) else { return nil }
            return (progress.amountDone, progress.targetAmount)
        } else {
            if let progress = dailyProgress.first(where: { $0.date.isSame(to: date) && $0.isActive }) {
                return (progress.amountDone, progress.targetAmount)
            } else {
                return (0, dailyTargetAmountAmount)
            }
        }
    }
}

class WirdZikr: Object, Decodable {
    @Persisted var zikrId: String
    @Persisted var targetCount: Int
    @Persisted var zikrType: String
    var type: ZikrType {
        ZikrType(rawValue: zikrType) ?? .zikr
    }
}
