//
//  AddNewZikrView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 02.07.2023.
//

import SwiftUI

struct AddNewZikrView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    @StateObject private var viewModel: AddNewZikrViewModel

    init(viewModel: AddNewZikrViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            (viewModel.isSelected ? Color.paleGray : Color(.systemBackground))
                .onTapGesture {
                    hapticLight()
                    withAnimation {
                        viewModel.toggleSelection()
                    }
                }
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text(viewModel.zikr.type.rawValue.localized(language))
                            .font(.headline)
                            .foregroundLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                        Spacer()
                        Image("ic-checkmark")
                            .opacity(0)
                    }
                    Group {
                        Text(viewModel.zikr.title.localized(language))
                        Text("\(viewModel.zikr.title).transcription".localized(language))
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    Spacer()
                }
                .onTapGesture {
                    hapticLight()
                    withAnimation {
                        viewModel.toggleSelection()
                    }
                }
                if viewModel.isSelected {
                    ValidatedTextField(
                        viewModel: viewModel.textFieldViewModel,
                        keyboardType: .decimalPad,
                        color: Color(.systemBackground)
                    )
                    .frame(width: 80, height: 80)
                    .font(.headline)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
        }
    }
}

extension AddNewZikrView: Hapticable {}

struct AddNewZikrView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewZikrView(viewModel: .init(zikr: .init()))
    }
}
