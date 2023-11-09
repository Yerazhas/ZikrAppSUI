//
//  QazaPrayer.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation
import RealmSwift

class QazaPrayer: Object, Identifiable {
    var id: String {
        title
    }
    @Persisted var title: String
    @Persisted var targetAmount: Int = 0
    @Persisted var doneAmount: Int = 0
    @Persisted var dailyProgress = List<QazaPrayerProgress>()
    var type: QazaType {
        .normal
    }
    var prayerType: PrayerType? {
        PrayerType(rawValue: title)
    }

    init(title: String, targetAmount: Int, doneAmount: Int, dailyProgress: List<QazaPrayerProgress> = List<QazaPrayerProgress>()) {
        self.title = title
        self.targetAmount = targetAmount
        self.doneAmount = doneAmount
        self.dailyProgress = dailyProgress
    }

    override init() {
        super.init()
    }

    func getCurrentProgress(for date: Date) -> (Int, Int)? {
        (doneAmount, targetAmount)
    }
}

class QazaPrayerProgress: Object {
    @objc dynamic var date: Date = Date()
    @objc dynamic var amountDone: Int = 0

    init(date: Date, amountDone: Int) {
        self.date = date
        self.amountDone = amountDone
    }

    override init() {
        super.init()
    }
}
