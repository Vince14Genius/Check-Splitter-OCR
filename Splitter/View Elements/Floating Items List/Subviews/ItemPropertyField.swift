//
//  ItemPropertyField.swift
//  Splitter
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
    @Binding var state: FloatingBarState
    
    @State private var isShowingEditAlert = false
    @State private var textFieldValue = ""
    
    @State private var isShowingNameEmptyAlert = false
    @State private var isShowingPriceInvalidAlert = false
    @State private var isShowingPriceZeroAlert = false
    
    private var themeColor: Color {
        switch fieldType {
        case .name:
            .blue
        case .price(_):
            .green
        }
    }
    
    private var editAlertTitle: String {
        switch fieldType {
        case .name:
            "Edit Item Name"
        case .price(_):
            "Edit Price"
        }
    }
    
    private func saveText(_ text: String) {
        defer { textFieldValue = "" }
        var newItem = item
        switch fieldType {
        case .name:
            guard !textFieldValue.isEmpty else {
                isShowingNameEmptyAlert = true
                return
            }
            newItem.name = textFieldValue
        case .price(_):
            guard let newPrice = Decimal(string: textFieldValue) else {
                isShowingPriceInvalidAlert = true
                return
            }
            do {
                try newItem.setPrice(to: newPrice)
            } catch {
                if case Item.AssignmentError.itemPriceZero = error {
                    isShowingPriceZeroAlert = true
                    return
                }
            }
        }
        state = .focused(item: newItem)
    }
    
    var body: some View {
        Button {
            isShowingEditAlert = true
        } label: {
            Group {
                switch fieldType {
                case .name:
                    if let name = item.name {
                        Text(name)
                            .foregroundStyle(Color(.label))
                    } else {
                        Text("Item Name")
                            .foregroundStyle(Color(.secondaryLabel))
                            .italic()
                    }
                case .price(let currency):
                    if let price = item.price {
                        Text(price.formatted(.currency(code: currency.rawValue)))
                            .monospacedDigit()
                            .foregroundStyle(Color(.label))
                    } else {
                        Text("Price")
                            .foregroundStyle(Color(.secondaryLabel))
                            .italic()
                    }
                }
            }
            .font(.headline)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(themeColor.opacity(0.3))
            )
            .monospacedDigit()
        }
        .alert(editAlertTitle, isPresented: $isShowingEditAlert) {
            TextField(editAlertTitle, text: $textFieldValue)
                .keyboardType({
                    switch fieldType {
                    case .name:
                        .default
                    case .price(_):
                        .decimalPad
                    }
                }())
            Button("Cancel", role: .cancel) { textFieldValue = "" }
            Button("Done") { saveText(textFieldValue) }
        }
        .alert("Item name cannot be empty!", isPresented: $isShowingNameEmptyAlert) {}
        .alert("Invalid price: not a number!", isPresented: $isShowingPriceInvalidAlert) {}
        .alert("Invalid price: 0 is not allowed", isPresented: $isShowingPriceZeroAlert) {}
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
