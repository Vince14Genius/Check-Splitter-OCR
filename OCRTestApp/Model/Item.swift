//
//  Item.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/2/23.
//

import Foundation
import SwiftUI

struct Item: Identifiable {
    var id = UUID()
    var name: String
    var price: Decimal
}

extension Item {
    struct Initiation: Equatable {
        var name: String?
        var price: Decimal?
        var replacementIndex: [Item].Index?
    }
    
    init?(_ initiationValue: Initiation) {
        guard
            let name = initiationValue.name,
            let price = initiationValue.price
        else {
            return nil
        }
        self.name = name
        self.price = price
    }
}
