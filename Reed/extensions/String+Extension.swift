//
//  String+Extension.swift
//  Reed
//
//  Created by Raven Weitzel on 12/16/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import Foundation

extension String {
    private func countryName(from countryCode: String) -> String? {
        return (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode)
    }

    func isValidCountryCode(_ string: String) -> Bool {
        return countryName(from: string) != nil
    }
}
