//
//  Stages.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/22/23.
//

import Foundation

enum Stage: Hashable {
    case totalCost, items, payers
    
    var completionRequiredStages: [Stage] {
        switch self {
        case .totalCost:
            []
        case .items:
            [.totalCost]
        case .payers:
            [.totalCost, .items]
        }
    }
}
