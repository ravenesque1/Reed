//
//  ReedViewModel.swift
//  Reed
//
//  Created by Raven Weitzel on 12/19/19.
//  Copyright © 2019 Raven Weitzel. All rights reserved.
//

import CancelBag
import Combine

class ReedViewModel: ObservableObject {
    
    let cancelBag = CancelBag()

    @Published var statusMessage = ""
    @Published var isStatusMessageShown = false
    @Published var isErrorShown = false
    @Published var errorMessage = ""
}
