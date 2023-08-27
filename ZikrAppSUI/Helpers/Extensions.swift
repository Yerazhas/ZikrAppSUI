//
//  Extensions.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 15.01.2023.
//

import SwiftUI
import StoreKit

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
    static let didTransferZikrs1 = "didTransferZikrs1" // add localized fields on zikr, like translation, transcription (KZ, RU, EN)
    static let didSetAppLang = "didSetAppLang"
    static let didSeeWhatsNew = "didSeenWhatsNew"
    static let didSeeOnboarding = "didSeeOnboarding"
    static let didSeeDailyAmountToolTip = "didSeeDailyAmountToolTip"
    static let didSeeStatisticsToolTip = "didSeeStatisticsToolTip"

    // AppStats
    static let didAddNewZikr = "didAddNewZikr"
    static let numberOfExpansion = "numberOfExpansion"
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

extension Text {
    func foregroundLinearGradient(
        themeFirstColor: String,
        themeSecondColor: String?
    ) -> some View
    {
        var stops: [Gradient.Stop] = [.init(color: Color(themeFirstColor), location: 0.00)]
        if let themeSecondColor {
            stops.append(.init(color: Color(themeSecondColor), location: 1.00))
        }
        return self.overlay {
            LinearGradient(
                stops: stops,
                startPoint: UnitPoint(x: 1, y: 0.96),
                endPoint: UnitPoint(x: 0, y: 0)
            )
            .mask(
                self
            )
        }
    }
}

extension View {
    var asImage: UIImage {
//         Must ignore safe area due to a bug in iOS 15+ https://stackoverflow.com/a/69819567/1011161
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.top))
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: targetSize)
        view?.backgroundColor = .clear

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3 // Ensures 3x-scale images. You can customise this however you like.
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

        @MainActor
        func snapshot() -> UIImage {
            let controller = UIHostingController(rootView: self)
            let view = controller.view
    
            let targetSize = controller.view.intrinsicContentSize
            view?.bounds = CGRect(origin: .zero, size: targetSize)
            view?.backgroundColor = .clear
    
            let renderer = UIGraphicsImageRenderer(size: targetSize)
    
            return renderer.image { _ in
                view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
            }
        }
}

extension View {
    /// Custom Spacers
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// Checking Two dates are same
    func isSameDate(_ date1: Date, _ date2: Date) -> Bool {
        return Calendar.current.isDate(date1, inSameDayAs: date2)
    }
}

extension View {
    func makeLinearGradient(
        themeFirstColor: String,
        themeSecondColor: String?
    ) -> LinearGradient {
        var stops: [Gradient.Stop] = [.init(color: Color(themeFirstColor).opacity(0.7), location: 0.00)]
        if let themeSecondColor {
            stops.append(.init(color: Color(themeSecondColor).opacity(0.7), location: 1.00))
        }
        return LinearGradient(
            stops: stops,
            startPoint: UnitPoint(x: 1, y: 0.96),
            endPoint: UnitPoint(x: 0, y: 0)
        )
    }
}

struct PressAction: ViewModifier {
    var isPressedChanged: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        isPressedChanged(true)
                    })
                    .onEnded({ _ in
                        isPressedChanged(false)
                    })
            )
    }
}

public extension View {
    func pressAction(isPressedChanged: @escaping (Bool) -> Void) -> some View {
        modifier(PressAction(isPressedChanged: isPressedChanged))
    }
}

extension SKProductSubscriptionPeriod {

    private static var componentFormatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }

    private static func format(unit: NSCalendar.Unit, numberOfUnits: Int) -> String? {
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        componentFormatter.allowedUnits = [unit]

        switch unit {
        case .day:
            dateComponents.setValue(numberOfUnits, for: .day)
        case .weekOfMonth:
            dateComponents.setValue(numberOfUnits, for: .weekOfMonth)
        case .month:
            dateComponents.setValue(numberOfUnits, for: .month)
        case .year:
            dateComponents.setValue(numberOfUnits, for: .year)
        default:
            return nil
        }

        return componentFormatter.string(from: dateComponents)
    }

    var localizedPeriod: String? {
        return Self.format(unit: unit.toCalendarUnit(), numberOfUnits: numberOfUnits)
    }

    var periodString: String {
        let string: String
        switch unit {
        case .month:
            string = "monthly".localized(LocalizationService.shared.language)
        case .year:
            string = "yearly".localized(LocalizationService.shared.language)
        @unknown default:
            string = ""
        }
        return string
    }

    var subscriptionDescription: String {
        let string: String
        switch unit {
        case .month:
            string = "autoRenewingMonthly".localized(LocalizationService.shared.language)
        case .year:
            string = "autoRenewingYearly".localized(LocalizationService.shared.language)
        @unknown default:
            string = ""
        }
        return string
    }
}

extension SKProduct.PeriodUnit {

    func toCalendarUnit() -> NSCalendar.Unit {
        switch self {
        case .day:
            return .day
        case .month:
            return .month
        case .week:
            return .weekOfMonth
        case .year:
            return .year
        @unknown default:
            print("Unknown period unit")
        }

        return .day
    }

}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }
}

