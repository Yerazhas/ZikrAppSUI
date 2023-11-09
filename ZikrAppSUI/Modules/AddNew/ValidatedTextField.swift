import SwiftUI

struct ValidatedTextField: View {
    @StateObject var viewModel: ValidatedTextFieldViewModel
    @FocusState var isFocused: Bool
    let keyboardType: UIKeyboardType
    var color: Color = .paleGray

    var body: some View {
        ZStack {
            color
                .onTapGesture {
                    isFocused = true
                }
                .frame(height: 50)
                .cornerRadius(16)
            TextField(
                viewModel.placeholder,
                text: $viewModel.value,
                onEditingChanged: viewModel.didEdit(isChanged:)
            )
            .padding()
            .focused($isFocused)
            .onSubmit {
                viewModel.onSubmitAction?()
            }
            .submitLabel(.done)
            .keyboardType(keyboardType)
            .disableAutocorrection(true)
            .onChange(
                of: viewModel.value,
                perform: viewModel.didChange(text:)
            )
            .cornerRadius(16)
            .foregroundColor(viewModel.state == .invalid ? .red : .primary)
        }
        if self.viewModel.state == .invalid {
            HStack {
                Text(viewModel.errorMessage)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(.top, -6)
                Spacer()
            }
        }
    }
}
