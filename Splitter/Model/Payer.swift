import Foundation

struct Payer: Identifiable, Equatable {
    var id = UUID()
    var name: String
    
    static func ==(_ lhs: Payer, _ rhs: Payer) -> Bool { lhs.id == rhs.id }
}
