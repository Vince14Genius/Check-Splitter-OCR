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
    enum AssignmentError: Error {
        case itemPriceZero
    }
    
    struct Initiation: Equatable {
        var name: String?
        private(set) var price: Decimal?
        var replacementIndex: [Item].Index?
        
        mutating func setPrice(to value: Decimal) throws {
            if value == 0 { throw AssignmentError.itemPriceZero }
            price = value
        }
    }
    
    init?(from initiationValue: Initiation) {
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
