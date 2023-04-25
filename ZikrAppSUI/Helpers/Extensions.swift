//
//  Extensions.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI

extension View {
    func schemeAdapted(colorScheme: ColorScheme) -> some View {
        self.foregroundColor(colorScheme == .light ? .black : .white)
    }
}

extension Font {
    static func uthmanicArabic(size: CGFloat) -> Font {
        custom("KFGQPCUthmanicScriptHAFS", size: size)
    }
}

extension String {
    static let didTransferZikrs = "didTransferZikrs"
    static let didSetAppLang = "didSetAppLang"
}

extension UINavigationController {
    func push<Content: View>(suiView: Content, animated: Bool = true) {
        let hostingVC = UIHostingController(rootView: suiView)
//        hostingVC.view.backgroundColor = .clear
        pushViewController(hostingVC, animated: animated)
    }
    
    func set<Content: View>(suiView: Content, animated: Bool = true) {
        let hostingVC = UIHostingController(rootView: suiView)
        setViewControllers([hostingVC], animated: animated)
    }
}
