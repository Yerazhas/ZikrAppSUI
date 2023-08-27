//
//  StatisticsViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 03.08.2023.
//

import Combine
import RealmSwift
import Factory

final class StatisticsViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @Published var zikrProgresses: [ProgressData] = []
    @Published var duaProgresses: [ProgressData] = []
    @Published var wirdProgresses: [ProgressData] = []
    @Published var zikrsAmount: Int = 0
    @Published var duasAmount: Int = 0
    @Published var collectionsAmount: Int = 0
    @Published var idealDaysCount: Int = 0
    @Published var mockDataWarningText: String?
    @Published var showsSubscribeButton: Bool = false
    @Injected(Container.subscriptionSyncService) private var subscriptionService
    let completion: () -> Void
    private var cancellable: AnyCancellable?

    init(completion: @escaping () -> Void) {
        self.completion = completion
        setupBasedOnSubscription(subscriptionService.isSubscribed)
        cancellable = subscriptionService.isSubscribedPublisher.sink { [weak self] isSubscribed in
            self?.setupBasedOnSubscription(isSubscribed)
        }
    }

    deinit {
        cancellable = nil
    }

    private func setupBasedOnSubscription(_ isSubscribed: Bool) {
        if isSubscribed {
            getYearTraction()
            getTotalAmounts()
            getIdealDays()
            isLoading = false
            showsSubscribeButton = false
        } else {
            zikrsAmount = 14500
            duasAmount = 439
            collectionsAmount = 137
            idealDaysCount = 250
            mockDataWarningText = "dataForDemo"
            getMockYearTraction()
            isLoading = false
            showsSubscribeButton = true
        }
    }

    func getYearTraction() {
        zikrProgresses.removeAll()
        duaProgresses.removeAll()
        wirdProgresses.removeAll()

        let realm = try! Realm()
        let trackedZikrs = realm.objects(Zikr.self).where({ $0.dailyTargetAmountAmount > 0 })
        let trackedDuas = realm.objects(Dua.self).where({ $0.dailyTargetAmountAmount > 0 })
        let trackedWirds = realm.objects(Wird.self).where({ $0.dailyTargetAmountAmount > 0 })

        let dates = datesForCurrentYear()
        for zikr in trackedZikrs {
            var tempZikrProgresses = [Progress]()
            for i in 0..<dates.count {
                let date = dates[i]
                var tempProgress: CGFloat = 0
                if let trackedProgress = zikr.dailyProgress.first(where: { $0.date.isSame(to: date) }) {
                    tempProgress = CGFloat(trackedProgress.amountDone) / CGFloat(trackedProgress.targetAmount)
                }
                let progress = Progress(index: i, progress: tempProgress)
                tempZikrProgresses.append(progress)
            }
            zikrProgresses.append(.init(id: zikr.id, title: zikr.title, progresses: tempZikrProgresses))
        }

        for dua in trackedDuas {
            var tempDuaProgresses = [Progress]()
            for i in 0..<dates.count {
                let date = dates[i]
                var tempProgress: CGFloat = 0
                if let trackedProgress = dua.dailyProgress.first(where: { $0.date.isSame(to: date) }) {
                    tempProgress = CGFloat(trackedProgress.amountDone) / CGFloat(trackedProgress.targetAmount)
                }
                let progress = Progress(index: i, progress: tempProgress)
                tempDuaProgresses.append(progress)
            }
            duaProgresses.append(.init(id: dua.id, title: dua.title, progresses: tempDuaProgresses))
        }

        for wird in trackedWirds {
            var tempWirdProgresses = [Progress]()
            for i in 0..<dates.count {
                let date = dates[i]
                var tempProgress: CGFloat = 0
                if let trackedProgress = wird.dailyProgress.first(where: { $0.date.isSame(to: date) }) {
                    tempProgress = CGFloat(trackedProgress.amountDone) / CGFloat(trackedProgress.targetAmount)
                }
                let progress = Progress(index: i, progress: tempProgress)
                tempWirdProgresses.append(progress)
            }
            wirdProgresses.append(.init(id: wird.id, title: wird.title, progresses: tempWirdProgresses))
        }
    }

    func subscribe() {
        completion()
    }

    func getMockYearTraction() {
        zikrProgresses.removeAll()
        let dates = datesForCurrentYear()
        let zikrs = ["salawat", "istighfar", "hasbunallahu", "duaOfYunus"]
        for zikr in zikrs {
            var tempProgresses = [Progress]()
            for i in 0..<dates.count {
                var progress: CGFloat = .random(in: 0.2...0.6)
                if 100...200 ~= i {
                    progress = .random(in: 0.5...1.0)
                } else if 200...400 ~= i {
                    progress = .random(in: 0.8...1.0)
                }
                let tempProgress = Progress(index: i, progress: progress)
                tempProgresses.append(tempProgress)
            }
            zikrProgresses.append(.init(id: zikr, title: zikr, progresses: tempProgresses))
        }
    }

    func getTotalAmounts() {
        let realm = try! Realm()

        zikrsAmount = realm.objects(Zikr.self).map { $0.totalDoneCount }.reduce(0, +)
        duasAmount = realm.objects(Dua.self).map { $0.totalDoneCount }.reduce(0, +)
        collectionsAmount = realm.objects(Wird.self).map { $0.totalDoneCount }.reduce(0, +)
    }

    func getIdealDays() {
        let realm = try! Realm()
        let progresses = realm.objects(DailyZikrProgress.self)
        let groupedProgresses = Dictionary(grouping: progresses) { progress -> String in
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                return dateFormatter.string(from: progress.date)
        }
        for (_, v) in groupedProgresses {
            let count = v.count
            let tempIdealDaysCount = v.map { CGFloat($0.amountDone) / CGFloat($0.targetAmount) }.reduce(0, +)
            if tempIdealDaysCount / CGFloat(count) == 1.0 {
                idealDaysCount += 1
            }
        }
        
    }
}

struct Progress: Identifiable {
    let index: Int
    let progress: CGFloat
    var id: Int {
        index
    }
}

struct ProgressData: Identifiable {
    let id: String
    let title: String
    let progresses: [Progress]
}
