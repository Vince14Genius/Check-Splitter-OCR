//
//  CurrencyPicker.swift
//  Splitter
//
//  Created by Vincent C. on 9/21/23.
//

import SwiftUI

struct CurrencyPicker: View {
    @Binding var currency: Currency
    
    @State private var isShowingPickerSheet = false
    
    var body: some View {
        Button {
            isShowingPickerSheet = true
        } label: {
            HStack {
                Text(currency.rawValue.uppercased())
                Image(systemName: "chevron.up.chevron.down")
                    .font(.title3)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .foregroundStyle(Color(.label))
        }
        .accessibilityLabel("Change currency. Current currency: \(currency.rawValue)")
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .stroke(.primary.opacity(0.1))
        )
        .sheet(isPresented: $isShowingPickerSheet) {
            VStack {
                Text("Select Currency")
                    .font(.title2)
                Picker("Currency", selection: $currency) {
                    ForEach(Currency.allCases, id: \.self) {
                        Text($0.rawValue.uppercased())
                    }
                }
                .pickerStyle(.wheel)
                Button("Done") {
                    isShowingPickerSheet = false
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return, modifiers: [])
            }
            .presentationBackground(.thinMaterial)
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    CurrencyPicker(currency: .constant(.jpy))
}
