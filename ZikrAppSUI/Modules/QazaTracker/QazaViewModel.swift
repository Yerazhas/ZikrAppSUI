//
//  QazaViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 09.10.2023.
//

import Foundation

final class QazaViewModel: ObservableObject {
    @Published var qazaPrayer: QazaPrayer
    @Published var isFinished: Bool
    @Published var isPerformedToday: Bool

    init(qazaPrayer: QazaPrayer, date: Date) {
        self.qazaPrayer = qazaPrayer
        self.isFinished = qazaPrayer.targetAmount == qazaPrayer.doneAmount
        self.isPerformedToday = qazaPrayer.dailyProgress.contains(where: { $0.date.isSame(to: date) })
    }

    func updateQazaPrayer(with modifiedQazaPrayer: QazaPrayer, date: Date) {
        self.qazaPrayer = modifiedQazaPrayer
        self.isPerformedToday = qazaPrayer.dailyProgress.contains(where: { $0.date.isSame(to: date) })
    }
}
