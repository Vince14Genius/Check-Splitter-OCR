//
//  SplitterFlowState.swift
//  Splitter
//
//  Created by Vincent C. on 9/26/23.
//

import SwiftUI

@Observable class SplitterFlowState {
    var items = [Item]()
    var totalCost: Decimal?
    var payers = [Payer]()
    var shares = [Share]()
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
