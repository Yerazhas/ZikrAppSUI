//
//  ZikrService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.01.2023.
//

import Foundation
import RealmSwift
import Factory

final class ZikrService {
    func transferZikrsFromJson() {
        let jsonUrl = Bundle.main.url(forResource: "zikrs", withExtension: "json")!
        do {
            let data = try Data(contentsOf: jsonUrl)
            let zikrs = try JSONDecoder().decode([Zikr].self, from: data)
            let realm = try Realm()
            try realm.write {
                for zikr in zikrs {
                    zikr.translationKZ = "\(zikr.title).translation".localized(.kz)
                    zikr.translationRU = "\(zikr.title).translation".localized(.ru)
                    zikr.translationEN = "\(zikr.title).translation".localized(.en)

                    zikr.transcriptionKZ = "\(zikr.title).transcription".localized(.kz)
                    zikr.transcriptionRU = "\(zikr.title).transcription".localized(.ru)
                    zikr.transcriptionEN = "\(zikr.title).transcription".localized(.en)

                    realm.add(zikr)
                }
                zikrs.forEach { realm.add($0) }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }

    func transferZikrsFromJson1() {
        do {
            let realm = try Realm()
            let zikrs = realm.objects(Zikr.self)
            try realm.write {
                for zikr in zikrs {
                    zikr.translationKZ = "\(zikr.title).translation".localized(.kz)
                    zikr.translationRU = "\(zikr.title).translation".localized(.ru)
                    zikr.translationEN = "\(zikr.title).translation".localized(.en)

                    zikr.transcriptionKZ = "\(zikr.title).transcription".localized(.kz)
                    zikr.transcriptionRU = "\(zikr.title).transcription".localized(.ru)
                    zikr.transcriptionEN = "\(zikr.title).transcription".localized(.en)
                    
                    realm.add(zikr)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

//    func addPalestineDuas() {
//        do {
//            let realm = try Realm()
//            let jsonUrl = Bundle.main.url(forResource: "duas", withExtension: "json")!
//            let data = try Data(contentsOf: jsonUrl)
//            let duas = try JSONDecoder().decode([Dua].self, from: data)
//            let realmDuas = realm.objects(Dua.self)
//            let tempRealmDuas = realmDuas
//            try realm.write {
//                for realmDua in realmDuas {
//                    realm.delete(realmDua)
//                }
//                for dua in duas {
//                    dua.translationKZ = "\(dua.title).translation".localized(.kz)
//                    dua.translationRU = "\(dua.title).translation".localized(.ru)
//                    dua.translationEN = "\(dua.title).translation".localized(.en)
//
//                    dua.transcriptionKZ = "\(dua.title).transcription".localized(.kz)
//                    dua.transcriptionRU = "\(dua.title).transcription".localized(.ru)
//                    dua.transcriptionEN = "\(dua.title).transcription".localized(.en)
//                    if let foundDua = tempRealmDuas.first(where: { $0.id == dua.id }) {
//                        dua.dailyTargetAmountAmount = foundDua.dailyTargetAmountAmount
//                        dua.currentDoneCount = foundDua.currentDoneCount
//                        dua.totalDoneCount = foundDua.totalDoneCount
//                        dua.dailyProgress = foundDua.dailyProgress
//                    }
//
//                    realm.add(dua)
//                }
//                duas.forEach { realm.add($0) }
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }

    func fixTextsInVersion1_8() {
        do {
            let realm = try Realm()
            if let zikr = realm.objects(Zikr.self).first(where: { $0.id == "duaOfYunus" }) {
                try realm.write {
                    zikr.arabicTitle = "لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِين"
                }
            }
            if let dua = realm.objects(Dua.self).first(where: { $0.id == "duaOfYunus" }) {
                try realm.write {
                    dua.arabicTitle = "لَّا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِين"
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func fixTextsInVersion1_9_0() {
        do {
            let realm = try Realm()
            if let zikr = realm.objects(Zikr.self).first(where: { $0.id == "lailahaillaantalMalikulHaqqulMubin" }) {
                try realm.write {
                    zikr.arabicTitle = "لا إِلَٰهَ إِلَّا أَنتَ المَلِكُ الحَقُّ المُبِينْ"
                }
            }
            if let dua = realm.objects(Dua.self).first(where: { $0.id == "lailahaillaantalMalikulHaqqulMubin" }) {
                try realm.write {
                    dua.arabicTitle = "لا إِلَٰهَ إِلَّا أَنتَ المَلِكُ الحَقُّ المُبِينْ"
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func fixTextsInVersion2_0_4() {
        do {
            let realm = try Realm()
            if let dua = realm.objects(Dua.self).first(where: { $0.id == "al-falaq" }) {
                try realm.write {
                    dua.arabicTitle = "قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ ١ مِن شَرِّ مَا خَلَقَ ٢ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ٣ وَمِن شَرِّ ٱلنَّفَّـٰثَـٰتِ فِى ٱلْعُقَدِ ٤ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ ٥"
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func transferDuasFromJson() {
        let jsonUrl = Bundle.main.url(forResource: "duas", withExtension: "json")!
        do {
            let data = try Data(contentsOf: jsonUrl)
            let duas = try JSONDecoder().decode([Dua].self, from: data)
            let realm = try Realm()
            try realm.write {
                for dua in duas {
                    dua.translationKZ = "\(dua.title).translation".localized(.kz)
                    dua.translationRU = "\(dua.title).translation".localized(.ru)
                    dua.translationEN = "\(dua.title).translation".localized(.en)

                    dua.transcriptionKZ = "\(dua.title).transcription".localized(.kz)
                    dua.transcriptionRU = "\(dua.title).transcription".localized(.ru)
                    dua.transcriptionEN = "\(dua.title).transcription".localized(.en)

                    realm.add(dua)
                }
                duas.forEach { realm.add($0) }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func transferDuasFromJson1() {
        do {
            let realm = try Realm()
            let duas = realm.objects(Dua.self)
            try realm.write {
                for dua in duas {
                    dua.translationKZ = "\(dua.title).translation".localized(.kz)
                    dua.translationRU = "\(dua.title).translation".localized(.ru)
                    dua.translationEN = "\(dua.title).translation".localized(.en)
                    
                    dua.transcriptionKZ = "\(dua.title).transcription".localized(.kz)
                    dua.transcriptionRU = "\(dua.title).transcription".localized(.ru)
                    dua.transcriptionEN = "\(dua.title).transcription".localized(.en)
                    
                    realm.add(dua)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func transferWirdsFromJson() {
        let jsonUrl = Bundle.main.url(forResource: "wirds", withExtension: "json")!
        do {
            let data = try Data(contentsOf: jsonUrl)
            let zikrs = try JSONDecoder().decode([Wird].self, from: data)
            let realm = try Realm()
            try realm.write {
                zikrs.forEach { realm.add($0) }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func setDefaultTrackerZikrs() {
        do {
            let realm = try Realm()
            if let salawat = realm.objects(Zikr.self).first(where: { $0.id == "salawat" }) {
                try realm.write {
                    salawat.dailyTargetAmountAmount = 100
                }
            }
            if let istighfar = realm.objects(Zikr.self).first(where: { $0.id == "istighfar" }) {
                try realm.write {
                    istighfar.dailyTargetAmountAmount = 100
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

//    func transferWirdsFromJson1() {
//        let jsonUrl = Bundle.main.url(forResource: "wirds", withExtension: "json")!
//        do {
//            let data = try Data(contentsOf: jsonUrl)
//            let zikrs = try JSONDecoder().decode([Wird].self, from: data)
//            let realm = try! Realm()
//            try realm.write {
//                zikrs.forEach { realm.add($0) }
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }

    func updateZikrTotalCount(
        type: ZikrType,
        id: String,
        isSubscribed: Bool,
        currentlyDoneCount: Int,
        internalDoneCount: Int,
        totallyDoneCount: Int
    ) {
        let realm = try! Realm()
        switch type {
        case .zikr:
            guard let zikr = realm.objects(Zikr.self).filter ({ $0.id == id }).first else { return }
            try! realm.write {
                zikr.totalDoneCount = totallyDoneCount
                zikr.currentDoneCount = currentlyDoneCount
                guard isSubscribed else { return }
                if zikr.dailyTargetAmountAmount > 0 {
                    if var todayProgressDate = zikr.dailyProgress.first(where: { $0.date.isToday }) {
                        let tempCurrentlyDoneCount = min(todayProgressDate.amountDone + internalDoneCount, zikr.dailyTargetAmountAmount)
                        todayProgressDate.amountDone = tempCurrentlyDoneCount
                        zikr.dailyProgress.removeLast()
                        zikr.dailyProgress.append(todayProgressDate)
                    } else {
                        let tempCurrentlyDoneCount = min(internalDoneCount, zikr.dailyTargetAmountAmount)
                        zikr.dailyProgress.append(.init(date: .init(), targetAmount: zikr.dailyTargetAmountAmount, amountDone: tempCurrentlyDoneCount, isActive: true))
                    }
                }
            }
        case .dua:
            guard let dua = realm.objects(Dua.self).filter ({ $0.id == id }).first else { return }
            try! realm.write {
                dua.totalDoneCount = totallyDoneCount
                dua.currentDoneCount = currentlyDoneCount
                guard isSubscribed else { return }
                if dua.dailyTargetAmountAmount > 0 {
                    if var todayProgressDate = dua.dailyProgress.first(where: { $0.date.isToday }) {
                        let tempCurrentlyDoneCount = min(todayProgressDate.amountDone + internalDoneCount, dua.dailyTargetAmountAmount)
                        todayProgressDate.amountDone = tempCurrentlyDoneCount
                        dua.dailyProgress.removeLast()
                        dua.dailyProgress.append(todayProgressDate)
                    } else {
                        let tempCurrentlyDoneCount = min(internalDoneCount, dua.dailyTargetAmountAmount)
                        dua.dailyProgress.append(.init(date: .init(), targetAmount: dua.dailyTargetAmountAmount, amountDone: tempCurrentlyDoneCount, isActive: true))
                    }
                }
            }
        case .wird:
            guard let wird = realm.objects(Wird.self).first(where: { $0.id == id }) else { return }
            try! realm.write {
                wird.totalDoneCount = totallyDoneCount
                guard isSubscribed else { return }
                if wird.dailyTargetAmountAmount > 0 {
                    if var todayProgressDate = wird.dailyProgress.first(where: { $0.date.isToday }) {
                        let tempCurrentlyDoneCount = min(todayProgressDate.amountDone + currentlyDoneCount, wird.dailyTargetAmountAmount)
                        todayProgressDate.amountDone = tempCurrentlyDoneCount
                        wird.dailyProgress.removeLast()
                        wird.dailyProgress.append(todayProgressDate)
                    } else {
                        let tempCurrentlyDoneCount = min(currentlyDoneCount, wird.dailyTargetAmountAmount)
                        wird.dailyProgress.append(.init(date: .init(), targetAmount: wird.dailyTargetAmountAmount, amountDone: tempCurrentlyDoneCount, isActive: true))
                    }
                }
            }
        }
    }
}

extension Container {
    static let zikrService = Factory<ZikrService> {
        ZikrService()
    }
}
