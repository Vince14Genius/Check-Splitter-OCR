//
//  TotalCostField.swift
//  Splitter
//
//  Created by Vincent C. on 9/23/23.
//

import SwiftUI

struct TotalCostField: View {
    @Binding var value: Double?
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
                            .monospacedDigit()
                    } else {
                        Text("Enter Total Cost")
                            .italic()
                    }
                    Image(systemName: "pencil")
                        .font(.title3)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(Color(.label))
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
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
                if let newValue = Double(textFieldValue) {
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
