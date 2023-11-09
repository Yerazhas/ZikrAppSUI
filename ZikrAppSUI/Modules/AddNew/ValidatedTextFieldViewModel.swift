import Foundation
import Combine

final class ValidatedTextFieldViewModel: ObservableObject {
    enum State {
        case idle
        case valid
        case invalid
    }

    let placeholder: String
    let errorMessage: String
    @Published var value: String
    @Published var state: State = .idle {
        didSet {
            onStateChangeAction?(state)
        }
    }
    var onSubmitAction: (() -> Void)?
    private var validation: (String) -> Bool
    private var onStateChangeAction: ((State) -> Void)?

    init(
        value: String = "",
        placeholder: String,
        errorMessage: String,
        onSubmitAction: (() -> Void)? = nil,
        validation: @escaping (String) -> Bool,
        onStateChangeAction: ((State) -> Void)? = nil
    ) {
        self.value = value
        self.placeholder = placeholder
        self.errorMessage = errorMessage
        self.onSubmitAction = onSubmitAction
        self.validation = validation
        self.onStateChangeAction = onStateChangeAction
    }

    func didEdit(isChanged: Bool) {
        guard !isChanged else { return }
        let isValid = self.validation(value)
        if isValid {
            state = .valid
        } else {
            hapticStrong()
            state = .invalid
        }
    }

    func didChange(text: String) {
        if validation(text) {
            state = .valid
        } else {
            state = .idle
        }
    }
}

extension ValidatedTextFieldViewModel: Hapticable {}
