//
//   WirdShareViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 18.07.2023.
//

import Foundation
import RealmSwift

final class WirdShareViewModel: ObservableObject {
    private let zikrService = ZikrService()
    let wird: Wird
    let targetedZikrs: [TargetedZikr]

    init(wird: Wird) {
        self.wird = wird
        var tempTargetedZikrs = [TargetedZikr]()
        let realm = try! Realm()
        let zikrs = realm.objects(Zikr.self)
        let duas = realm.objects(Dua.self)
        for zikr in wird.zikrs {
            if zikr.type == .zikr {
                if let tempZikr = zikrs.first(where: { $0.id == zikr.zikrId }) {
                    tempTargetedZikrs.append(.init(zikr: tempZikr, targetAmount: zikr.targetCount))
                }
            } else if zikr.type == .dua {
                if let tempDua = duas.first(where: { $0.id == zikr.zikrId }) {
                    tempTargetedZikrs.append(.init(zikr: tempDua, targetAmount: zikr.targetCount))
                }
            }
        }
        targetedZikrs = tempTargetedZikrs
    }
}
