//
//  ZikrSharePreviewView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.07.2023.
//

import SwiftUI

struct ZikrSharePreviewView: View {
    @AppStorage("language") private var language = LocalizationService.shared.language
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPresentingShareSheet = false
    let image: UIImage

    var body: some View {
        GeometryReader { gr in
            ZStack {
                (colorScheme == .dark ? Color.black : Color.white).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: gr.size.width * 0.8)
                                .padding(.top, 20)
                            Spacer()
                        }
                    }
                    .padding(.bottom, 100)
                }
                VStack {
                    Spacer()
                    Button {
                        isPresentingShareSheet = true
                    } label: {
                        ZStack {
                            Color.blue
                                .cornerRadius(20)
                            Text("share".localized(language))
                        }
                    }
                    .frame(height: 60)
                    .padding(.horizontal)
                    .foregroundColor(.white)
                    .font(.title2)

                }
            }
        }
        .sheet(
            isPresented: $isPresentingShareSheet, content: {
                ShareSheet(
                    activityItems: [
                        image
                    ]
                )
            }
        )
    }
}

struct ZikrSharePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZikrSharePreviewView(image: .init())
    }
}
