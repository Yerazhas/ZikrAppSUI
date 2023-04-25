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
            let realm = try! Realm()
            try realm.write {
                zikrs.forEach { realm.add($0) }
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }

    func transferDuasFromJson() {
        let jsonUrl = Bundle.main.url(forResource: "duas", withExtension: "json")!
        do {
            let data = try Data(contentsOf: jsonUrl)
            let zikrs = try JSONDecoder().decode([Dua].self, from: data)
            let realm = try! Realm()
            try realm.write {
                zikrs.forEach { realm.add($0) }
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
            let realm = try! Realm()
            try realm.write {
                zikrs.forEach { realm.add($0) }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateZikrTotalCount(type: ZikrType, id: String, totalCount: Int) {
        let realm = try! Realm()
        switch type {
        case .zikr:
            guard let zikr = realm.objects(Zikr.self).filter ({ $0.id == id }).first else { return }
            try! realm.write {
                zikr.totalDoneCount = totalCount
            }
        case .dua:
            guard let dua = realm.objects(Dua.self).filter ({ $0.id == id }).first else { return }
            try! realm.write {
                dua.totalDoneCount = totalCount
            }
        case .wird:
            guard let wird = realm.objects(Wird.self).first(where: { $0.id == id }) else { return }
            try! realm.write {
                wird.totalDoneCount = totalCount
            }
        }
    }
}
