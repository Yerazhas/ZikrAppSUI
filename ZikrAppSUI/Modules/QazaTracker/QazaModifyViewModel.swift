//
//  QazaModifyViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 09.10.2023.
//

import Foundation
import RealmSwift
import Factory

typealias QazaModifyOut = (QazaModifyOutCmd) -> Void
enum QazaModifyOutCmd {
    case update(QazaPrayer)
    case openPaywall
}

final class QazaModifyViewModel: ObservableObject {
    @Published var qazaPrayer: QazaPrayer
    @Published var lastUpdatedString: String?
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.subscriptionSyncService) private var subscriptionSyncService

    let out: QazaModifyOut

    init(qazaPrayer: QazaPrayer, out: @escaping QazaModifyOut) {
        self.qazaPrayer = qazaPrayer
        let language = LocalizationService.shared.language
        self.out = out
        if let lastModifiedDate = qazaPrayer.dailyProgress.sorted(by: { lhs, rhs in
            lhs.date.isOlderThan(date: rhs.date)
        }).last {
            if lastModifiedDate.date.isToday {
                lastUpdatedString = "lastUpdated".localized(language, args: "today".localized(language))
            } else if lastModifiedDate.date.isYesterday {
                lastUpdatedString = "lastUpdated".localized(language, args: "yesterday".localized(language))
            } else {
                lastUpdatedString = "lastUpdated".localized(language, args: lastModifiedDate.date.string)
            }
        }
    }

    func decrement() {
        guard subscriptionSyncService.isSubscribed || appStatsService.canMakeUpQaza else {
            hapticStrong()
            out(.openPaywall)
            return
        }
        hapticLight()
        let realm = try! Realm()
        if qazaPrayer.type == .normal {
            guard let tempQazaPrayer = realm.objects(QazaPrayer.self).first(where: { $0.id == qazaPrayer.id }) else { return }

            try! realm.write {
                if tempQazaPrayer.targetAmount > tempQazaPrayer.doneAmount {
                    tempQazaPrayer.doneAmount += 1
                }
                if var todayProgressDate = tempQazaPrayer.dailyProgress.first(where: { $0.date.isToday }) {
                    todayProgressDate.amountDone += 1
                    tempQazaPrayer.dailyProgress.removeLast()
                    tempQazaPrayer.dailyProgress.append(todayProgressDate)
                } else {
                    tempQazaPrayer.dailyProgress.append(.init(date: .init(), amountDone: 1))
                }
            }
            self.qazaPrayer = tempQazaPrayer
            appStatsService.didMakeUpQaza()
            out(.update(tempQazaPrayer))
        } else {
            guard let tempQazaPrayer = realm.objects(SafarQazaPrayer.self).first(where: { $0.id == qazaPrayer.id }) else { return }
            try! realm.write {
                if tempQazaPrayer.targetAmount > tempQazaPrayer.doneAmount {
                    tempQazaPrayer.doneAmount += 1
                }
                if var todayProgressDate = tempQazaPrayer.dailyProgress.first(where: { $0.date.isToday }) {
                    todayProgressDate.amountDone += 1
                    tempQazaPrayer.dailyProgress.removeLast()
                    tempQazaPrayer.dailyProgress.append(todayProgressDate)
                } else {
                    tempQazaPrayer.dailyProgress.append(.init(date: .init(), amountDone: 1))
                }
            }
            self.qazaPrayer = tempQazaPrayer
            appStatsService.didMakeUpQaza()
            out(.update(tempQazaPrayer))
        }
    }

    func increment() {
        guard subscriptionSyncService.isSubscribed || appStatsService.canMakeUpQaza else {
            hapticStrong()
            out(.openPaywall)
            return
        }
        hapticLight()
        let realm = try! Realm()
        if qazaPrayer.type == .normal {
            guard let tempQazaPrayer = realm.objects(QazaPrayer.self).first(where: { $0.id == qazaPrayer.id }) else { return }
            try! realm.write {
                tempQazaPrayer.targetAmount += 1
            }
            self.qazaPrayer = tempQazaPrayer
            appStatsService.didMakeUpQaza()
            out(.update(tempQazaPrayer))
        } else {
            guard let tempQazaPrayer = realm.objects(SafarQazaPrayer.self).first(where: { $0.id == qazaPrayer.id }) else { return }
            try! realm.write {
                tempQazaPrayer.targetAmount += 1
            }
            self.qazaPrayer = tempQazaPrayer
            appStatsService.didMakeUpQaza()
            out(.update(tempQazaPrayer))
        }
    }
}

extension QazaModifyViewModel: Hapticable {}
