//
//  ItemPropertyField.swift
//  OCRTestApp
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct ItemPropertyField: View {
    enum FieldType {
        case name
        case price(Currency)
    }
    
    let item: Item.Initiation
    let fieldType: FieldType
    
    private var themeColor: Color {
        switch fieldType {
        case .name:
            .blue
        case .price(_):
            .green
        }
    }
    
    var body: some View {
        Button {} label: {
            Group {
                switch fieldType {
                case .name:
                    if let name = item.name {
                        Text(name)
                    } else {
                        Text("")
                    }
                case .price(let currency):
                    if let price = item.price {
                        Text(price.formatted(.currency(code: currency.rawValue)))
                    } else {
                        Text("")
                    }
                }
            }
            .foregroundStyle(Color(.label))
            .font(.headline)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(themeColor.opacity(0.3))
            )
        }
    }
}

#Preview {
    ContentView(items: [
        .init(name: "hello", price: 9.99),
        .init(name: "たこわさ", price: 7.99)
    ])
}
