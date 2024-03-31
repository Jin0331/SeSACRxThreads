//
//  String+Extension.swift
//  SeSACRxThreads
//
//  Created by JinwooLee on 3/31/24.
//

import Foundation

extension String {
    static func createRandomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String(
            (0..<length)
                .map { _ in letters.randomElement()! }
        )
    }
}
