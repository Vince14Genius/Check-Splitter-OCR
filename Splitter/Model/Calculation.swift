//
//  Calculation.swift
//  Splitter
//
//  Created by Vincent C. on 10/1/23.
//

import Foundation

struct ResultPayer: Hashable {
    var name: String
    var items: [ResultItem]
    var payerTotal: Double
}

struct ResultItem: Hashable {
    var name: String
    var realQuantity: Double
    var originalUnitPrice: Double
    
    var originalSharePrice: Double { originalUnitPrice * realQuantity }
    
    func finalPrice(multiplier: Double) -> Double {
        originalSharePrice * multiplier
    }
}

struct CalculationResult {
    private(set) var payers: [ResultPayer]
    private(set) var multiplier: Double
    private(set) var totalCost: Double
    
    init(totalCost: Double, payers: [Payer], items: [Item], shares: [Share]) {
        // convert data into a form that is easier for calculations
        let intermediaryPayers = IntermediateResultPayer.arrayFrom(payers: payers, items: items, shares: shares)
        
        // divide total cost by subtotal to get the multiplier ratio
        let globalSubtotal = intermediaryPayers.globalSubtotal
        self.totalCost = totalCost
        self.multiplier = totalCost / globalSubtotal
        
        // calculate final costs by multiplying each payer subtotal
        // by the multiplier ratio
        self.payers = []
        self.payers = intermediaryPayers.map {
            .init(name: $0.payerName, items: $0.items, payerTotal: $0.subtotal * multiplier)
        }
    }
}

/// Converts ID-based shares to structs that store indices of the `payers` and `items` arrays
private struct IndexifiedShare {
    private(set) var payerID: Payer.ID
    private(set) var itemIndex: [Item].Index
    private(set) var realQuantity: Double
    
    private init?(share: Share, items: [Item]) {
        guard let itemIndex = items.firstIndex(where: { $0.id == share.itemID }) else {
            return nil
        }
        payerID = share.payerID
        self.itemIndex = itemIndex
        realQuantity = share.realQuantity
    }
    
    static func arrayFrom(shares: [Share], items: [Item]) -> [IndexifiedShare] {
        shares.compactMap {
            .init(share: $0, items: items)
        }
    }
}

extension Array<IndexifiedShare> {
    /// Returns the list of item shares for the given payer
    func itemResults(for payer: Payer, items: [Item]) -> [ResultItem] {
        filter {
            $0.payerID == payer.id
        }.map {
            .init(
                name: items[$0.itemIndex].name,
                realQuantity: $0.realQuantity,
                originalUnitPrice: items[$0.itemIndex].price
            )
        }
    }
}

private struct IntermediateResultPayer {
    var payerName: String
    var items: [ResultItem]
    
    init(payer: Payer, items: [Item], shares: [Share]) {
        payerName = payer.name
        self.items = IndexifiedShare.arrayFrom(shares: shares, items: items)
            .itemResults(for: payer, items: items)
    }
    
    var subtotal: Double {
        items.reduce(0) {
            $0 + $1.originalSharePrice
        }
    }
    
    func ratio(to globalSubtotal: Double) -> Double {
        subtotal / globalSubtotal
    }
    
    static func arrayFrom(payers: [Payer], items: [Item], shares: [Share]) -> [IntermediateResultPayer] {
        payers.map {
            .init(payer: $0, items: items, shares: shares)
        }
    }
}

extension Array<IntermediateResultPayer> {
    var globalSubtotal: Double {
        reduce(0) { $0 + $1.subtotal }
    }
}

