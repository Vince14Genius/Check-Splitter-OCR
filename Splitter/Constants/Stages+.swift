//
//  Stages+.swift
//  Splitter
//
//  Created by Vincent C. on 9/24/23.
//

import Foundation

extension Stage {
    var backButton: NavigationButtonSetup? {
        switch self {
        case .receipt:
            nil
        case .assignPayers:
            .init(title: "Back")
        case .calculated:
            .init(title: "Back")
        }
    }
    
    var nextButton: NavigationButtonSetup? {
        switch self {
        case .receipt:
            .init(title: "Next")
        case .assignPayers:
            .init(title: "Calculate!")
        case .calculated:
            .init(title: "Start Over", alert: "Are you sure you want to start over?")
        }
    }
}

struct NavigationButtonSetup {
    var title: String
    var alert: String? = nil
}
