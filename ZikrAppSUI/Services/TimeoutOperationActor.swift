//
//  TimeoutOperationActor.swift
//  ZikrAppSUI
//
//  Created by Yerassyl Zhassuzakhov on 12.09.2023.
//

import Foundation

actor TimeoutOperationActor {
    var isValid = true

    public func operationWith(timeout: TimeInterval, operation: @escaping () async -> Void) async {
        await withCheckedContinuation { continuation in
            let timer = Timer(timeInterval: timeout, repeats: false, block: { timer in
                timer.invalidate()
                self.isValid = false
                continuation.resume()
            })
            RunLoop.main.add(timer, forMode: .common)

            Task {
                await operation()

                if isValid {
                    timer.invalidate()
                    continuation.resume()
                }
            }
        }
    }
}
