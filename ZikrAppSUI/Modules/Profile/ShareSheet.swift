//
//  ShareSheet.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 21.01.2023.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
        
        let activityItems: [Any]
        let applicationActivities: [UIActivity]? = nil
        let excludedActivityTypes: [UIActivity.ActivityType]? = nil
        let callback: Callback? = nil
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: applicationActivities)
            controller.excludedActivityTypes = excludedActivityTypes
            controller.completionWithItemsHandler = callback
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}
