//
//  Item.swift
//  Splitter
//
//  Created by Vincent C. on 9/2/23.
//

import Foundation
import SwiftUI

struct Item: Identifiable, Equatable {
    var id = UUID()
    var name: String
    var price: Double
    
    static func ==(_ lhs: Item, _ rhs: Item) -> Bool { lhs.id == rhs.id }
}

extension Item {
    enum AssignmentError: Error {
        case itemPriceZero
    }
    
    struct Initiation: Equatable {
        var name: String?
        private(set) var price: Double?
        var replacementIndex: [Item].Index?
        
        mutating func setPrice(to value: Double) throws {
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
