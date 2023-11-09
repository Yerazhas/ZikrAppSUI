//
//  AddNewViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 01.07.2023.
//

import Combine
import RealmSwift
import Factory

public typealias AddNewOut = (AddNewOutCmd) -> Void
public enum AddNewOutCmd {
    case success
    case error(String)
}

final class AddNewViewModel: ObservableObject {
    @Injected(Container.appStatsService) private var appStatsService
    @Injected(Container.analyticsService) private var analyticsService
    @Published var zikrViewModels: [AddNewZikrViewModel] = []
    @Published var contentType: ZikrType = .zikr
    private let language = LocalizationService.shared.language
    private(set) lazy var titleViewModel: ValidatedTextFieldViewModel = {
        ValidatedTextFieldViewModel(
            placeholder: "title".localized(language),
            errorMessage: "enterAValidTitle".localized(language),
            onSubmitAction: {},
            validation: isValidTitle(_:),
            onStateChangeAction: { [weak self] state in
                guard let self else { return }
//                self.isButtonActive = state == .valid && self.emailViewModel.state  == .valid
            }
        )
    }()

    private(set) lazy var arabicViewModel: ValidatedTextFieldViewModel = {
        ValidatedTextFieldViewModel(
            placeholder: "arabicText".localized(language),
            errorMessage: "",
            onSubmitAction: didPressAdd,
            validation: { _ in return true },
            onStateChangeAction: { [weak self] state in
                guard let self else { return }
//                self.isButtonActive = state == .valid && self.emailViewModel.state  == .valid
            }
        )
    }()

    private(set) lazy var transcriptionViewModel: ValidatedTextFieldViewModel = {
        ValidatedTextFieldViewModel(
            placeholder: "transcription".localized(language),
            errorMessage: "",
            onSubmitAction: didPressAdd,
            validation: { _ in return true },
            onStateChangeAction: { [weak self] state in
                guard let self else { return }
//                self.isButtonActive = state == .valid && self.emailViewModel.state  == .valid
            }
        )
    }()

    private(set) lazy var translationViewModel: ValidatedTextFieldViewModel = {
        ValidatedTextFieldViewModel(
            placeholder: "translation".localized(language),
            errorMessage: "",
            onSubmitAction: didPressAdd,
            validation: { _ in return true },
            onStateChangeAction: { [weak self] state in
                guard let self else { return }
//                self.isButtonActive = state == .valid && self.emailViewModel.state  == .valid
            }
        )
    }()

    private let out: AddNewOut

    init(out: @escaping AddNewOut) {
        self.out = out
        var realm: Realm
        do {
            realm = try Realm()
            let zikrs = realm.objects(Zikr.self)
            let duas = realm.objects(Dua.self)
            zikrViewModels = zikrs.map { .init(zikr: $0) }
            zikrViewModels += duas.map { .init(zikr: $0) }
        } catch {
            fatalError()
        }
    }

    func onAppear() {
        analyticsService.trackOpenAddNew()
    }

    func didPressAdd() {
        hapticLight()
        switch contentType {
        case .zikr:
            guard titleViewModel.state == .valid else {
                hapticStrong()
                out(.error("fillFieldsCorrectly".localized(language)))
                return
            }
            let zikr = Zikr()
            zikr.id = UUID().uuidString
            zikr.title = titleViewModel.value
            zikr.isDeletable = true
            if arabicViewModel.state == .valid {
                zikr.arabicTitle = arabicViewModel.value
            }
            if transcriptionViewModel.state == .valid {
                zikr.transcriptionKZ = transcriptionViewModel.value
                zikr.transcriptionRU = transcriptionViewModel.value
                zikr.transcriptionEN = transcriptionViewModel.value
            }
            if translationViewModel.state == .valid {
                zikr.translationKZ = translationViewModel.value
                zikr.translationRU = translationViewModel.value
                zikr.translationEN = translationViewModel.value
            }
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(zikr)
                    appStatsService.setDidAddZikr()
                    analyticsService.trackAddNewSuccess(zikrType: .zikr)
                    out(.success)
                }
            } catch {
                print(error.localizedDescription)
            }
        case .dua:
            guard titleViewModel.state == .valid else {
                hapticStrong()
                out(.error("fillFieldsCorrectly".localized(language)))
                return
            }
            let dua = Dua()
            dua.id = UUID().uuidString
            dua.title = titleViewModel.value
            dua.isDeletable = true
            if arabicViewModel.state == .valid {
                dua.arabicTitle = arabicViewModel.value
            }
            if transcriptionViewModel.state == .valid {
                dua.transcriptionKZ = transcriptionViewModel.value
                dua.transcriptionRU = transcriptionViewModel.value
                dua.transcriptionEN = transcriptionViewModel.value
            }
            if translationViewModel.state == .valid {
                dua.translationKZ = translationViewModel.value
                dua.translationRU = translationViewModel.value
                dua.translationEN = translationViewModel.value
            }
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(dua)
                    appStatsService.setDidAddZikr()
                    analyticsService.trackAddNewSuccess(zikrType: .dua)
                    out(.success)
                }
            } catch {
                print(error.localizedDescription)
            }
        case .wird:
            let language = LocalizationService.shared.language
            guard titleViewModel.state == .valid, !zikrViewModels.filter { $0.isSelected }.isEmpty else {
                hapticStrong()
                out(.error("fillFieldsCorrectly".localized(language)))
                return
            }
            do {
                let realm = try Realm()

                let wird = Wird()
                wird.id = UUID().uuidString
                wird.title = titleViewModel.value
                wird.isDeletable = true
                for zikrViewModel in zikrViewModels.filter { $0.isSelected } {
                    let wirdZikr = zikrViewModel.zikr.makeWirdZikr()
                    wirdZikr.targetCount = zikrViewModel.targetAmount
                    wird.zikrs.append(wirdZikr)
                }
                try realm.write {
                    realm.add(wird)
                    appStatsService.setDidAddZikr()
                    analyticsService.trackAddNewSuccess(zikrType: .wird)
                    out(.success)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    private func isValidTitle(_ string: String) -> Bool {
        !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension AddNewViewModel: Hapticable {}
