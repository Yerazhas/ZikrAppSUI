//
//  QazaCalculationViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation

final class QazaCalculationViewModel: ObservableObject {
    
    @Published var gender: Gender = .male

    let genders: [Gender] = [.male, .female]

    let maleViewModel: MaleProfileDetailsFillOutViewModel
    let femaleViewModel: FemaleProfileDetailsFillOutViewModel
    
    
    init(maleViewModel: MaleProfileDetailsFillOutViewModel, femaleViewModel: FemaleProfileDetailsFillOutViewModel) {
        self.maleViewModel = maleViewModel
        self.femaleViewModel = femaleViewModel
    }
}

enum Gender: String, Identifiable {
    case male
    case female
    
    var id: Int {
        switch self {
        case .male:
            return 0
        case .female:
            return 1
        }
    }
}

extension Gender: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension Gender: Codable {}
