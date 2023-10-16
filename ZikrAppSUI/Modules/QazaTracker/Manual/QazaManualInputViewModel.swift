//
//  QazaManualInputViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation
import RealmSwift
import Factory

@MainActor
final class QazaManualInputViewModel: ObservableObject {
    let qazaInputRowViewModels: [QazaManualInputRowViewModel]
    private let fajrInputRowVM: QazaManualInputRowViewModel
    private let dhuhrrInputRowVM: QazaManualInputRowViewModel
    private let safarDhuhrCheckoutRowVM: QazaManualInputRowViewModel
    private let asrInputRowVM: QazaManualInputRowViewModel
    private let safarAsrCheckoutRowVM: QazaManualInputRowViewModel
    private let maghribInputRowVM: QazaManualInputRowViewModel
    private let ishaInputRowVM: QazaManualInputRowViewModel
    private let safarIshaCheckoutRowVM: QazaManualInputRowViewModel
    private let witrInputRowVM: QazaManualInputRowViewModel
    private let fastInputRowVM: QazaManualInputRowViewModel
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        fajrInputRowVM = .init(count: 0,
                               title: "fajr".localized(LocalizationService.shared.language),
                                                     prayerType: .fajr)
        dhuhrrInputRowVM = .init(count: 0,
                                                       title: "dhuhr".localized(LocalizationService.shared.language),
                                                       prayerType: .dhuhr)
        safarDhuhrCheckoutRowVM = .init(count: 0, title: "safarDhuhr".localized(LocalizationService.shared.language),
                                                                prayerType: .safarDhuhr)
        asrInputRowVM = .init(count: 0,
                                                    title: "asr".localized(LocalizationService.shared.language),
                                                    prayerType: .asr)
        safarAsrCheckoutRowVM = .init(count: 0, title: "safarAsr".localized(LocalizationService.shared.language),
                                                              prayerType: .safarAsr)
        maghribInputRowVM = .init(count: 0,
                                                        title: "maghrib".localized(LocalizationService.shared.language),
                                                        prayerType: .maghrib)
        ishaInputRowVM = .init(count: 0,
                                                     title: "isha".localized(LocalizationService.shared.language),
                                                     prayerType: .isha)
        safarIshaCheckoutRowVM = .init(count: 0, title: "safarIsha".localized(LocalizationService.shared.language),
                                                               prayerType: .safarIsha)
        witrInputRowVM = .init(count: 0,
                                                     title: "witr".localized(LocalizationService.shared.language),
                                                     prayerType: .witr)
        fastInputRowVM = .init(count: 0, title: "fast".localized(LocalizationService.shared.language), prayerType: .fast)
        qazaInputRowViewModels = [fajrInputRowVM,
                                  dhuhrrInputRowVM, safarDhuhrCheckoutRowVM,
                                  asrInputRowVM, safarAsrCheckoutRowVM,
                                  maghribInputRowVM,
                                  ishaInputRowVM, safarIshaCheckoutRowVM,
                                  witrInputRowVM, fastInputRowVM]
    }
    
    func saveUser() {
        hapticLight()
        let fajr = QazaPrayer(title: "fajr", targetAmount: fajrInputRowVM.count, doneAmount: 0)
        let dhuhr = QazaPrayer(title: "dhuhr", targetAmount: dhuhrrInputRowVM.count, doneAmount: 0)
        let safarDhuhr = SafarQazaPrayer(title: "safarDhuhr", targetAmount: safarDhuhrCheckoutRowVM.count, doneAmount: 0)
        let asr = QazaPrayer(title: "asr", targetAmount: asrInputRowVM.count, doneAmount: 0)
        let safarAsr = SafarQazaPrayer(title: "safarAsr", targetAmount: safarAsrCheckoutRowVM.count, doneAmount: 0)
        let maghrib = QazaPrayer(title: "maghrib", targetAmount: maghribInputRowVM.count, doneAmount: 0)
        let isha = QazaPrayer(title: "isha", targetAmount: ishaInputRowVM.count, doneAmount: 0)
        let safarIsha = SafarQazaPrayer(title: "safarIsha", targetAmount: safarIshaCheckoutRowVM.count, doneAmount: 0)
        let witr = QazaPrayer(title: "witr", targetAmount: witrInputRowVM.count, doneAmount: 0)
        let fast = QazaPrayer(title: "fast", targetAmount: fastInputRowVM.count, doneAmount: 0)

        let realm = try! Realm()
        try! realm.write {
            realm.add(fajr)
            realm.add(dhuhr)
            realm.add(safarDhuhr)
            realm.add(asr)
            realm.add(safarAsr)
            realm.add(maghrib)
            realm.add(isha)
            realm.add(safarIsha)
            realm.add(witr)
            realm.add(fast)
        }
        completion()
    }
}

extension QazaManualInputViewModel: Hapticable {}
