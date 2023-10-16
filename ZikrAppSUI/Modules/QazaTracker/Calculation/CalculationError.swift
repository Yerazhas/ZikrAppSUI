//
//  CalculationError.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 09.10.2023.
//

import Foundation

enum CalculationError: String, Error {
    case emptyBirthdayDate
    case emptyMajorityDate
    case emptyPrayerStartDate
    case invalidMajorityAndPrayerStartDatesRelation
    case incorrectMajorityAge
    case unknownError
}

extension CalculationError: LocalizedError {
    
    var descriptionKey: String {
        rawValue + "Desc"
    }
    
    var reasonKey: String {
        rawValue + "Reason"
    }
    
    var errorDescription: String? {
        descriptionKey
    }
    
    var failureReason: String? {
        reasonKey
    }
    
}
