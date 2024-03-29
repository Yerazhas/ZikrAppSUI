//
//  QazaTrackerViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 09.10.2023.
//

import Foundation
import RealmSwift
import Factory

typealias QazaTrackerOut = (QazaTrackerOutCmd) -> Void
enum QazaTrackerOutCmd {
    case openPaywall
    case delete(() -> Void)
}

@MainActor
final class QazaTrackerViewModel: ObservableObject {
    @Published var qazaPrayers: [QazaViewModel] = []
    @Published var safarQazaPrayers: [QazaViewModel] = []
    @Published var selectedQazaPrayer: QazaPrayer?
    @Injected(Container.appStatsService) private var appStatsService
    private let out: QazaTrackerOut

    init(out: @escaping QazaTrackerOut) {
        self.out = out
        let realm = try! Realm()
        let qazaPrayers = realm.objects(QazaPrayer.self)
        var filteredQazaPrayers: [QazaPrayer] = []
        for qazaPrayer in qazaPrayers {
            if qazaPrayer.type == .normal {
                filteredQazaPrayers.append(qazaPrayer)
            } else if qazaPrayer.title == "fast" {
                filteredQazaPrayers.append(qazaPrayer)
            }
        }
        self.qazaPrayers = realm.objects(QazaPrayer.self).filter("title IN %@", filteredQazaPrayers.map({ $0.id })).map { QazaViewModel(qazaPrayer: $0, date: .init()) }

        let safarQazaPrayers = realm.objects(SafarQazaPrayer.self)
        var filteredSafarQazaPrayers: [SafarQazaPrayer] = []
        for qazaPrayer in safarQazaPrayers {
            if qazaPrayer.type == .safar {
                filteredSafarQazaPrayers.append(qazaPrayer)
            }
        }
        self.safarQazaPrayers = realm.objects(SafarQazaPrayer.self).filter("title IN %@", filteredSafarQazaPrayers.map({ $0.id })).map { QazaViewModel(qazaPrayer: $0, date: .init()) }
    }

    func selectQazaPrayer(_ qazaPrayer: QazaPrayer) {
        selectedQazaPrayer = qazaPrayer
    }

    func openPaywall() {
        out(.openPaywall)
    }

    func resetQazas() {
        hapticLight()
        out(.delete({
            self.deleteQazaPrayers()
        }))
    }

    private func deleteQazaPrayers() {
        let realm = try! Realm()
        let prayers = realm.objects(QazaPrayer.self)
        let safarPrayers = realm.objects(SafarQazaPrayer.self)
        try! realm.write({
            for prayer in prayers {
                realm.delete(prayer)
            }
            for prayer in safarPrayers {
                realm.delete(prayer)
            }
        })
        appStatsService.resetDidSetUpQaza()
    }

    func updateQazaPrayer(to modifiedQazaPrayer: QazaPrayer) {
        if modifiedQazaPrayer.type == .normal {
            guard let index = qazaPrayers.firstIndex(where: { $0.qazaPrayer.id == modifiedQazaPrayer.id }) else  { return }
            qazaPrayers[index] = .init(qazaPrayer: modifiedQazaPrayer, date: .init())
        } else {
            guard let index = safarQazaPrayers.firstIndex(where: { $0.qazaPrayer.id == modifiedQazaPrayer.id }) else  { return }
            safarQazaPrayers[index] = .init(qazaPrayer: modifiedQazaPrayer, date: .init())
        }
    }
}

extension QazaTrackerViewModel: Hapticable {}
