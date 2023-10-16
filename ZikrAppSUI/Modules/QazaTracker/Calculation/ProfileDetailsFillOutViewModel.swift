//
//  ProfileDetailsFillOutViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation

protocol ProfileDetailsFillOutViewModelProtocol: ObservableObject {
    var hijriCalendar: Calendar { get }
    func isValid() -> Bool
    func isValidBirthdayDate(_ birthdayDate: Date, against majorityDate: Date) -> Bool
    func getIncrementedDate(from date: Date, by years: Int) -> Date?
    
}

extension ProfileDetailsFillOutViewModelProtocol {
    
    func isValidBirthdayDate(_ birthdayDate: Date, against majorityDate: Date) -> Bool {
        return birthdayDate < majorityDate
    }
    
    func getIncrementedDate(from date: Date, by years: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = years
        let incrementedDate = hijriCalendar.date(byAdding: dateComponents, to: date)
        return incrementedDate
    }
    
}
