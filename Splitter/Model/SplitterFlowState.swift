//
//  SplitterFlowState.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

@Observable class SplitterFlowState {
    var items = [Item]()
    var totalCost: Double?
    var payers = [Payer]()
    var shares = [Share]()
    
    private var hasUnassignedItem: Bool {
        !items.allSatisfy { item in shares.contains { $0.itemID == item.id } }
    }
    
    private var hasUnassignedPayer: Bool {
        !payers.allSatisfy { payer in shares.contains { $0.payerID == payer.id } }
    }
    
    private var isItemSubtotalZero: Bool {
        shares.reduce(0) { partialResult, share in
            guard let item = items.first(where: { $0.id == share.itemID }) else {
                return partialResult
            }
            return partialResult + share.realQuantity * item.price
        } == 0
    }
    
    var isReceiptStageIncomplete: Bool {
        totalCost == nil || items.isEmpty
    }
    
    var isItemAssignmentIncomplete: Bool {
        hasUnassignedItem || isItemSubtotalZero
    }
    
    var isPayerAssignmentIncomplete: Bool {
        payers.isEmpty || hasUnassignedPayer
    }
    
    var shouldShowItemSubtotalZeroWarning: Bool {
        !hasUnassignedItem && isItemSubtotalZero
    }
    
    var canCalculate: Bool {
        !isReceiptStageIncomplete && !isItemAssignmentIncomplete && !isPayerAssignmentIncomplete
    }
}

extension SplitterFlowState {
    static private let itemHelloUUID = UUID()
    static private let itemTakowasaUUID = UUID()
    static private let payerJohnUUID = UUID()
    static private let payerMarisaUUID = UUID()
    static private let payerAaaUUID = UUID()
    
    static var sampleData: SplitterFlowState {
        let sample = SplitterFlowState()
        sample.totalCost = 34.33
        sample.items = [
            .init(id: itemHelloUUID, name: "hello", price: 9.99),
            .init(id: itemTakowasaUUID, name: "たこわさ", price: 7.49),
            .init(name: "No Payers Example", price: 29.99),
        ]
        sample.payers = [
            .init(id: payerJohnUUID, name: "John"),
            .init(id: payerMarisaUUID, name: "Marisa"),
            .init(name: "X"),
            .init(id: payerAaaUUID, name: "Aaa Bbb Ccc Dddd"),
        ]
        sample.shares = [
            .init(
                payerID: payerJohnUUID,
                itemID: itemHelloUUID
            ),
            .init(
                payerID: payerJohnUUID,
                itemID: itemTakowasaUUID,
                wholeNumberQuantity: 0,
                fractionPartNumerator: 2,
                fractionPartDenominator: 3
            ),
            .init(
                payerID: payerMarisaUUID,
                itemID: itemTakowasaUUID,
                wholeNumberQuantity: 0,
                fractionPartNumerator: 3,
                fractionPartDenominator: 4
            ),
            .init(
                payerID: payerAaaUUID,
                itemID: itemTakowasaUUID,
                wholeNumberQuantity: 1
            )
        ]
        return sample
    }
}
