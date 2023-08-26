//
//  DailyZikrProgress.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 25.07.2023.
//

import RealmSwift

class DailyZikrProgress: Object {
    @objc dynamic var date: Date = Date()
    @objc dynamic var targetAmount: Int = 0
    @objc dynamic var amountDone: Int = 0
    @objc dynamic var isActive: Bool = true // New property to indicate if the zikr is active on this day or not

    init(date: Date, targetAmount: Int, amountDone: Int, isActive: Bool) {
        self.date = date
        self.targetAmount = targetAmount
        self.amountDone = amountDone
        self.isActive = isActive
    }

    override init() {
        super.init()
    }
}
