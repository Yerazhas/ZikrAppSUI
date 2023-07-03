//
//  AddNewViewModel.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 01.07.2023.
//

import Combine
import RealmSwift

public typealias AddNewOut = (AddNewOutCmd) -> Void
public enum AddNewOutCmd {
    case success
    case error(String)
}

final class AddNewViewModel: ObservableObject {
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
            if arabicViewModel.state == .valid {
                zikr.arabicTitle = arabicViewModel.value
            }
            if transcriptionViewModel.state == .valid {
//                zikr.transcription = transcriptionViewModel.value
            }
        case .dua:
            print()
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