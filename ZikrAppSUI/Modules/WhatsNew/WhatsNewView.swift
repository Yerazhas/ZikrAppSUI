//
//  WhatsNewView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 17.08.2023.
//

import SwiftUI

struct WhatsNewView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    private let benefits: [String] = [
        "Доступна платная ZikrApp Premium подписка, купив которую, вы можете:",
        "Добавлять неограниченное количество зикров, дуа для духовного роста",
        "Установить ежедневное количество зикров, формировать привычки, отслеживать прогресс",
        "Смотреть инсайты, статистику на вашем духовном пути и многое другое."
    ]
    let completion: () -> Void

    var body: some View {
        VStack {
            Text("What's New in ZikrApp")
                .font(.largeTitle)
                .bold()
            ForEach(benefits, id: \.self) { benefit in
                IconTitleView(title: benefit)
                    .padding(.top, 10)
            }
            .padding(.leading, 40)
            .padding(.top, 20)
            Spacer()
            Button {
                hapticLight()
                completion()
            } label: {
                ZStack {
                    Color.blue
                        .cornerRadius(12)
                    Text("continue".localized(language))
                        .foregroundColor(.white)
                        .font(.title2)
                }
            }
            .frame(height: 60)
            .padding(.horizontal)

        }
        .padding()
        .padding(.top, 40)
        .interactiveDismissDisabled(true)
    }
}

struct WhatsNewView_Previews: PreviewProvider {
    static var previews: some View {
        WhatsNewView {}
    }
}

extension WhatsNewView: Hapticable {}
