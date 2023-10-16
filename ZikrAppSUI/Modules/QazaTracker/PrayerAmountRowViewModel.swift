//
//  PrayerAmountRowViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation

class PrayerAmountRowViewModel: ObservableObject, Identifiable {
    @Published var count: Int {
        didSet {
            didSetCount()
        }
    }
    var title: String
    var id: String {
        title
    }
    let isEditable: Bool

    init(count: Int, title: String?, isEditable: Bool = false) {
        self.count = count
        self.title = title ?? ""
        self.isEditable = isEditable
    }

    func didSetCount() {}
}
