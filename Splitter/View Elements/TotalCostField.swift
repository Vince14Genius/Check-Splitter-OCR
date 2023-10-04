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
    let areOCRResultsAvailable: Bool
    
    @State private var isShowingEditAlert = false
    @State private var textFieldValue = ""
    
    @State private var isShowingCostInvalidAlert = false
    
    @State private var scale = 1.0
    
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
                            .scaleEffect(scale)
                            .animation(.easeInOut, value: scale)
                    } else {
                        VStack(alignment: .trailing) {
                            Text("Enter Total Cost")
                                .italic()
                            if areOCRResultsAvailable {
                                Text("or Drag and Drop")
                                    .font(.caption)
                            }
                        }
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
        .dropDestination(for: String.self) { droppedStrings, _ in
            if let price = Double(droppedStrings.first ?? "") {
                value = price
                return true
            } else {
                return false
            }
        }
        .onChange(of: value) {
            scale = 1.2
            _ = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                scale = 1.0
            }
        }
    }
}

#Preview {
    Group {
        TotalCostField(value: .constant(nil), currency: .jpy, areOCRResultsAvailable: false)
        TotalCostField(value: .constant(nil), currency: .jpy, areOCRResultsAvailable: true)
        TotalCostField(value: .constant(69), currency: .jpy, areOCRResultsAvailable: false)
    }
}
