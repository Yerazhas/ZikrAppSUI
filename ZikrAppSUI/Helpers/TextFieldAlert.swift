//
//  TextFieldAlert.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 30.10.2023.
//

import SwiftUI

struct TextFieldAlert: ViewModifier {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Binding var isPresented: Bool
    let title: String
    @Binding var text: String
    let placeholder: String
    let action: (String) -> Void
    @FocusState var isFocused: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            content
                .disabled(isPresented)
            if isPresented {
                VStack {
                    Text(title).font(.headline).padding()
                    TextField(placeholder, text: $text).textFieldStyle(.roundedBorder).padding()
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                    Divider()
                    HStack{
                        Spacer()
                        Button(role: .cancel) {
                            withAnimation {
                                isPresented.toggle()
                            }
                        } label: {
                            Text("cancel".localized(language))
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        Button() {
                            action(text)
                            withAnimation {
                                isPresented.toggle()
                            }
                        } label: {
                            Text("ok".localized(language))
                        }
                        Spacer()
                    }
                }
                .background(.background)
                .frame(width: 300, height: 200)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.quaternary, lineWidth: 1)
                }
                .onAppear {
                    isFocused = true
                }
            }
        }
    }
}

extension View {
    public func textFieldAlert(
        isPresented: Binding<Bool>,
        title: String,
        text: Binding<String>,
        placeholder: String = "",
        action: @escaping (String) -> Void
    ) -> some View {
        self.modifier(TextFieldAlert(isPresented: isPresented, title: title, text: text, placeholder: placeholder, action: action))
    }
}
