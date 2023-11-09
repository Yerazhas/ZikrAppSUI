//
//  SFSafariView.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 20.08.2023.
//

import SwiftUI
import SafariServices

struct SFSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariView>) {
        return
    }
}
