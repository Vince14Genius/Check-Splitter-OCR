//
//  TotalCostField.swift
//  Splitter
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct TotalCostField: View {
    @Binding var value: Decimal?
    let currency: Currency
    
    @State private var isShowingEditAlert = false
    @State private var textFieldValue = ""
    
    @State private var isShowingCostInvalidAlert = false
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                isShowingEditAlert = true
            } label: {
                HStack {
                    if let value {
                        Text("Total: **\(value.formatted(.currency(code: currency.rawValue)))**")
                    } else {
                        Text("Enter Total Cost")
                            .italic()
                    }
                    Image(systemName: "pencil")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(Color(.label))
//                .foregroundStyle(value == nil ? .red : Color(.label))
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .stroke(value == nil ? Color.red : .primary.opacity(0.1))
            )
        }
        .alert("Total Cost", isPresented: $isShowingEditAlert) {
            TextField("Enter total cost", text: $textFieldValue)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) {
                textFieldValue = ""
            }
            Button("Done") {
                if let newValue = Decimal(string: textFieldValue) {
                    value = newValue
                } else {
                    isShowingCostInvalidAlert = true
                }
            }
        }
        .alert("Invalid cost: not a number!", isPresented: $isShowingCostInvalidAlert) {}
    }
}

#Preview {
    Group {
        TotalCostField(value: .constant(nil), currency: .jpy)
        TotalCostField(value: .constant(69), currency: .jpy)
    }
}
