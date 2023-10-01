import Foundation

struct Share: Identifiable {
    var payerID: Payer.ID
    var itemID: Item.ID
    
    var wholeNumberQuantity: Int = 1
    var fractionPartNumerator: Int = 0
    var fractionPartDenominator: Int = 1
    
    var isZero: Bool {
        Double(wholeNumberQuantity) + Double(fractionPartNumerator) / Double(fractionPartDenominator) == 0
    }
    
    var isDenominatorZero: Bool {
        fractionPartDenominator == 0
    }
    
    var realQuantity: Double {
        let wholeNumber = Double(wholeNumberQuantity)
        let numerator = Double(fractionPartNumerator)
        let denominator = Double(fractionPartDenominator)
        return wholeNumber + numerator / denominator
    }
    
    struct ID: Hashable {
        var payerID: Payer.ID
        var itemID: Item.ID
    }
    
    var id: ID {
        .init(payerID: payerID, itemID: itemID)
    }
}

extension Array<Share> {
    func sanitized(payers: [Payer], items: [Item]) -> [Share] {
        filter { share in
            payers.contains {
                $0.id == share.payerID
            } && items.contains {
                $0.id == share.itemID
            }
        }
    }
}
