//
//  Date+Extension.swift
//  Reed
//
//  Created by Raven Weitzel on 1/13/20.
//  Copyright © 2020 Raven Weitzel. All rights reserved.
//

import UIKit

extension Date {
    
    //provides a date in "X ago" format
   var timeAgoString: String? {
      let formatter = DateComponentsFormatter()
      formatter.unitsStyle = .full
      formatter.maximumUnitCount = 1
      formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]

      guard let timeString = formatter.string(from: self, to: Date()) else {
           return nil
      }

      let formatString = NSLocalizedString("%@ ago", comment: "")
      return String(format: formatString, timeString)
   }
}
