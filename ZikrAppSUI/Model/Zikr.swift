//
//  Zikr.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.01.2023.
//

import Foundation
import RealmSwift

class Zikr: Object, Decodable, Identifiable {
    @Persisted var id: String
    @Persisted var title: String
    @Persisted var arabicTitle: String

    @Persisted var translationKZ: String
    @Persisted var translationRU: String
    @Persisted var translationEN: String

    @Persisted var transcriptionKZ: String
    @Persisted var transcriptionRU: String
    @Persisted var transcriptionEN: String

    @Persisted var dailyTargetAmountAmount: Int = 0
    @Persisted var dailyProgress = List<DailyZikrProgress>()

    @Persisted var isDeletable: Bool
    var type: ZikrType {
        .zikr
    }
    @Persisted var totalDoneCount: Int
    @Persisted var currentDoneCount: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case arabicTitle
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        arabicTitle = try container.decode(String.self, forKey: .arabicTitle)

        isDeletable = false
        totalDoneCount = 0
        super.init()
    }

    override init() {
        super.init()
    }

    func getTranslation(language: Language) -> String {
        switch language {
        case .kz:
            return translationKZ
        case .ru:
            return translationRU
        case .en:
            return translationEN
        }
    }

    func getTranscription(language: Language) -> String {
        switch language {
        case .kz:
            return transcriptionKZ
        case .ru:
            return transcriptionRU
        case .en:
            return transcriptionEN
        }
    }

    func makeWirdZikr() -> WirdZikr {
        let wirdZikr = WirdZikr()
        wirdZikr.zikrId = id
        wirdZikr.zikrType = type.rawValue
        return wirdZikr
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

enum ZikrType: String {
    case zikr
    case dua
    case wird
}
