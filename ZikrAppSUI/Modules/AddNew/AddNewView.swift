//
//  AddNewView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 19.02.2023.
//

import SwiftUI
import RealmSwift

struct AddNewView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("themeFirstColor") private var themeFirstColor = ThemeService.shared.firstColor
    @AppStorage("themeSecondColor") private var themeSecondColor: String?
    @StateObject private var viewModel: AddNewViewModel
    private let columns = [
        GridItem(.flexible(minimum: 100))
    ]

    public init(out: @escaping AddNewOut) {
        self._viewModel = StateObject(wrappedValue: AddNewViewModel(out: out))
    }

    var body: some View {
        ZStack {
//            Color(.systemBackground)
            colorScheme == .dark ? Color.black : Color.white
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text("addNewZikr".localized(language))
                            .bold()
                            .padding(.top)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Button {
                            viewModel.didPressAdd()
                        } label: {
                            Text("add".localized(language))
                                .foregroundLinearGradient(themeFirstColor: themeFirstColor, themeSecondColor: themeSecondColor)
                        }
                        
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
                Picker(selection: $viewModel.contentType) {
                    Text("zikr".localized(language))
                        .tag(ZikrType.zikr)
                    Text("dua".localized(language))
                        .tag(ZikrType.dua)
                    Text("wird".localized(language))
                        .tag(ZikrType.wird)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
                .padding()
                VStack(alignment: .leading, spacing: 14) {
                    ValidatedTextField(viewModel: viewModel.titleViewModel, keyboardType: .alphabet)
                        .padding(.horizontal)
                    if viewModel.contentType == .wird {
                        Text("selectZikrs".localized(language))
                            .font(.headline)
                            .padding(.horizontal)
                        Divider()
                        addWirdView
                    } else {
                        Group {
                            ValidatedTextField(viewModel: viewModel.arabicViewModel, keyboardType: .alphabet)
                                .font(.uthmanicArabic(size: 18))
                            ValidatedTextField(viewModel: viewModel.transcriptionViewModel, keyboardType: .alphabet)
                            ValidatedTextField(viewModel: viewModel.translationViewModel, keyboardType: .alphabet)
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
            }
            
    //        .navigationBarHidden(false)
    //        .navigationTitle("addNew".localized(language))
            .onChange(of: viewModel.contentType) { _ in
                hapticLight()
            }
        }
    }

    private var addWirdView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(viewModel.zikrViewModels) { zikr in
                    VStack {
                        AddNewZikrView(viewModel: zikr)
                            .frame(height: 100)
                        Divider()
                    }
                }
            }
            .animation(.none)
            .padding(.vertical, 10)
        }
    }
}

extension AddNewView: Hapticable {}

struct AddNewView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewView { _ in }
    }
}
