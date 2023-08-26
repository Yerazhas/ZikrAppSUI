//
//  ZikrService.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.01.2023.
//

import Foundation
import RealmSwift

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
