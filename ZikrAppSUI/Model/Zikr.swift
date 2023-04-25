//
//  Zikr.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 16.01.2023.
//

import Foundation
import RealmSwift

class Zikr: Object, Decodable, Identifiable {
    @Persisted var id: String
    @Persisted var title: String
    @Persisted var arabicTitle: String
    @Persisted var isDeletable: Bool
    var type: ZikrType {
        .zikr
    }
    @Persisted var totalDoneCount: Int
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case arabicTitle
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        arabicTitle = try container.decode(String.self, forKey: .arabicTitle)
        isDeletable = false
        totalDoneCount = 0
        super.init()
    }

    override init() {
        super.init()
    }
}

enum ZikrType: String {
    case zikr
    case dua
    case wird
}
