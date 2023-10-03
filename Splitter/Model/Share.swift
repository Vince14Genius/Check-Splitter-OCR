import Foundation

struct Share: Identifiable, Equatable {
    var payerID: Payer.ID
    var itemID: Item.ID
    
    static func from(item: Item, payer: Payer) -> Share {
        .init(payerID: payer.id, itemID: item.id)
    }
    
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
    
    static func ==(_ lhs: Share, _ rhs: Share) -> Bool { lhs.id == rhs.id }
    
    func has(_ item: Item) -> Bool { itemID == item.id }
    func has(_ payer: Payer) -> Bool { payerID == payer.id }
}

extension Array<Share> {
    func sanitized(payers: [Payer], items: [Item]) -> [Share] {
        filter { share in
            payers.contains {
                share.has($0)
            } && items.contains {
                share.has($0)
            }
        }
    }
}
