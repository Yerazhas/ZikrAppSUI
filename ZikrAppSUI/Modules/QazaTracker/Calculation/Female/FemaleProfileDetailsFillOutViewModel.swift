//
//  FemaleProfileDetailsFillOutViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 08.10.2023.
//

import Foundation
import Combine
import Factory
import RealmSwift

final class FemaleProfileDetailsFillOutViewModel: ProfileDetailsFillOutViewModelProtocol {
    @Published var isMajorityDateUnknown = false {
        didSet {
            handleIfMajorityDateUnknown(isMajorityDateUnknown)
        }
    }
    @Published var isPrayerStartDateToday = false {
        didSet {
            handleIsPrayerStartDateToday()
        }
    }
    @Published var safarDaysCount = 0
    @Published var haidDaysCount = 0
    @Published var childBirthCount = 0
    @Published var majorityAge = 0 {
        didSet {
            handleMajorityAge(oldValue: oldValue)
        }
    }
    @Published var majorityDate: Date?
    @Published var birthdayDateViewModel = TitledDateInputViewModel(
        title: "birthDay".localized(LocalizationService.shared.language),
        placeholder: "yourBirthDay".localized(LocalizationService.shared.language)
    )
    @Published var prayerStartDateViewModel = TitledDateInputViewModel(
        title: "prayerStartDate".localized(LocalizationService.shared.language),
        placeholder: "yourPrayerStartDate".localized(LocalizationService.shared.language)
    )
    
    @Published var shouldShowError: Bool = false
    @Published var error: CalculationError?

    private var isSetOnce = false
    private var cancellableSet: Set<AnyCancellable> = []
    private(set) var hijriCalendar = Calendar.init(identifier: .islamicCivil)
    let completion: () -> Void

    init(completion: @escaping () -> Void) {
        self.completion = completion
        handleBirthdayDate()
        handleIsValidBirthdayPublisher()
    }

    deinit {
        cancellableSet.removeAll()
    }

    func isValid() -> Bool {
        guard birthdayDateViewModel.date != nil else {
            handleError(.emptyBirthdayDate)
            return false
        }
        guard let majorityDate = majorityDate else {
            handleError(.emptyMajorityDate)
            return false
        }
        guard let prayerStartDate = prayerStartDateViewModel.date else {
            handleError(.emptyPrayerStartDate)
            return false
        }
        guard majorityDate < prayerStartDate else {
            handleError(.invalidMajorityAndPrayerStartDatesRelation)
            return false
        }
        
        return true
    }

    func calculateQazaPrayersAmount() {
        guard isValid() else { return }
        let prayerStartDate = prayerStartDateViewModel.date!
        let calendar = Calendar.current
        let daysDateComponents = calendar.dateComponents([.day], from: majorityDate!, to: prayerStartDate)
        let monthsDateComponents = calendar.dateComponents([.month], from: majorityDate!, to: prayerStartDate)
        guard let differenceInDays = daysDateComponents.day else { return }
        let totalHaidDays = getTotalHaidDaysCount(dateComponents: monthsDateComponents)
        let totalNifasDaysCount = getTotalNifasDaysCount()
        let qazaPrayersCount = differenceInDays - totalHaidDays - totalNifasDaysCount
//        let user = User(birthdayDate: birthdayDateViewModel.date!,
//                        majorityDate: majorityDate!,
//                        majorityAge: majorityAge,
//                        prayerStartDate: prayerStartDate,
//                        safarDaysCount: safarDaysCount,
//                        qazaPrayersCount: qazaPrayersCount)
        let fajr = QazaPrayer(title: "fajr", targetAmount: qazaPrayersCount - safarDaysCount, doneAmount: 0)
        let dhuhr = QazaPrayer(title: "dhuhr", targetAmount: qazaPrayersCount - safarDaysCount, doneAmount: 0)
        let safarDhuhr = SafarQazaPrayer(title: "safarDhuhr", targetAmount: safarDaysCount, doneAmount: 0)
        let asr = QazaPrayer(title: "asr", targetAmount: qazaPrayersCount - safarDaysCount, doneAmount: 0)
        let safarAsr = SafarQazaPrayer(title: "safarAsr", targetAmount: safarDaysCount, doneAmount: 0)
        let maghrib = QazaPrayer(title: "maghrib", targetAmount: qazaPrayersCount - safarDaysCount, doneAmount: 0)
        let isha = QazaPrayer(title: "isha", targetAmount: qazaPrayersCount - safarDaysCount, doneAmount: 0)
        let safarIsha = SafarQazaPrayer(title: "safarIsha", targetAmount: safarDaysCount, doneAmount: 0)
        let witr = QazaPrayer(title: "witr", targetAmount: qazaPrayersCount - safarDaysCount, doneAmount: 0)
        let fast = QazaPrayer(title: "fast", targetAmount: 0, doneAmount: 0)

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
    
    private func handleBirthdayDate() {
        birthdayDateViewModel.$date.sink { [weak self] birthdayDate in
            guard let self = self,
                  self.majorityAge > 0,
                  let birthdayDate = birthdayDate else { return }
            
            guard let majorityDate = self.getIncrementedDate(from: birthdayDate, by: self.majorityAge) else { return }
            if majorityDate > Date() {
                handleError(.incorrectMajorityAge)
            } else {
                self.majorityDate = majorityDate
            }
        }.store(in: &cancellableSet)
    }
    
    private func handleIsValidBirthdayPublisher() {
        isValidBirthdayPublisher
            .sink { isValid in
                if !isValid{
                    self.birthdayDateViewModel.date = nil
                }
            }
            .store(in: &cancellableSet)
    }
    
    private func handleIsPrayerStartDateToday() {
        if isPrayerStartDateToday {
            prayerStartDateViewModel.date = Date()
        } else {
            prayerStartDateViewModel.date = nil
        }
    }
    
    private func handleMajorityAge(oldValue: Int) {
        guard majorityAge < 16 else {
            majorityAge = oldValue
            return
        }
        guard let birthdayDate = birthdayDateViewModel.date else {
            return
        }
        guard let majorityDate = getIncrementedDate(from: birthdayDate, by: majorityAge) else { return }
        if majorityDate > Date() {
            majorityAge = oldValue
        } else {
            self.majorityDate = majorityDate
        }
    }
    
    private func handleIfMajorityDateUnknown(_ isMajorityDateUnknown: Bool) {
        if isMajorityDateUnknown {
            if let birthdayDate = birthdayDateViewModel.date {
                if let majorityDate = getIncrementedDate(from: birthdayDate, by: 15), majorityDate < Date () {
                    self.majorityDate = majorityDate
                    majorityAge = 15
                } else {
                    handleError(.incorrectMajorityAge)
                    self.isMajorityDateUnknown.toggle()
                }
            } else {
                majorityAge = 15
            }
        } else {
            majorityAge = 0
            guard birthdayDateViewModel.date != nil else { return }
            majorityDate = nil
        }
    }
    
    private func handleError(_ error: CalculationError) {
        hapticStrong()
        shouldShowError = true
        self.error = error
    }
    
    private var isValidBirthdayPublisher: AnyPublisher<Bool, Never> {
        birthdayDateViewModel.$date
            .filter { $0 != nil }
            .map { tempDate in
            guard let date = tempDate,
                  let majorityDate = self.getIncrementedDate(from: date, by: self.majorityAge) else {
                return false
            }
            return majorityDate < Date()
        }
        .eraseToAnyPublisher()
    }
    
    private func getTotalHaidDaysCount(dateComponents: DateComponents) -> Int {
        guard let monthsCount = dateComponents.month else { return 0 }
        return monthsCount * haidDaysCount
    }
    
    private func getTotalNifasDaysCount() -> Int {
        childBirthCount * 40
    }
}

extension FemaleProfileDetailsFillOutViewModel: Hapticable {}
