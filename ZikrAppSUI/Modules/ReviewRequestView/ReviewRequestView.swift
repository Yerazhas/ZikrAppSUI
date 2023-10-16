//
//  ReviewRequestView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 21.09.2023.
//

import SwiftUI

struct ReviewRequestView: View {
    let completion: () -> Void
    @AppStorage("language") private var language = LocalizationService.shared.language

    var body: some View {
        ZStack {
            Color.systemGreen.ignoresSafeArea()
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        HStack {
                            Button {
                                completion()
                            } label: {
                                Image(systemName: "xmark")
                                    .renderingMode(.template)
                                    .resizable()
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 18, height: 18)
                            Spacer()
                        }
                        .padding(.horizontal)
                        Text("reviewRequestTitle".localized(language))
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                        VStack {
                            IconTitleView(title: "reviewRequest".localized(language))
                                .padding(.top, 10)
                            Link(destination: .init(string: "https://apps.apple.com/kz/app/zikrapp-dhikr-dua-tasbih/id1590270292?action=write-review")!) {
                                ZStack {
                                    Color.black.cornerRadius(10)
                                    Text("leaveReview".localized(language))
                                        .bold()
                                }
                                .frame(height: 50)
                                .padding(.horizontal)
                            }
                            IconTitleView(title: "writeWhatsappTelegram".localized(language))
                                .padding(.top, 30)
                            Link(destination: .init(string: "https://api.whatsapp.com/send?phone=77473528357")!) {
                                ZStack {
                                    Color.black.cornerRadius(10)
                                    Text("writeWhatsapp".localized(language))
                                        .bold()
                                }
                                .frame(height: 50)
                                .padding(.horizontal)
                            }
                            Link(destination: .init(string: "https://t.me/yera_zhas")!) {
                                ZStack {
                                    Color.black.cornerRadius(10)
                                    Text("writeTelegram".localized(language))
                                        .bold()
                                }
                                .frame(height: 50)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct ReviewRequestView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewRequestView {}
    }
}
