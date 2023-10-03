//
//  SplitterFlowState.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

@Observable class SplitterFlowState {
    var totalCost: Double?
    var items = [Item]() { didSet { sanitizeShares() } }
    var payers = [Payer]() { didSet { sanitizeShares() } }
    var shares = [Share]()
    
    var canCalculate: Bool {
        totalCost != nil && !items.isEmpty && !payers.isEmpty &&
        items.allSatisfy { item in shares.contains { $0.itemID == item.id } } &&
        payers.allSatisfy { payer in shares.contains { $0.payerID == payer.id } }
    }
    
    func sanitizeShares() {
        shares.removeAll { share in
            !(items.contains { $0.id == share.itemID } && payers.contains { $0.id == share.payerID })
        }
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
