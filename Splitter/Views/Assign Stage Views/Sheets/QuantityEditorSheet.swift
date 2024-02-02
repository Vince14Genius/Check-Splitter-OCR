//
//  QuantityEditor.swift
//  Splitter
//
//  Created by Vincent C. on 9/30/23.
//

import SwiftUI

struct QuantityEditorSheet: View {
    let itemName: String
    let payerName: String
    @Binding var share: Share
    let dismissAction: () -> Void
    let unassignAction: () -> Void
    
    private var isInvalid: Bool {
        share.isDenominatorZero || share.isZero
    }
    
    @State private var showsFractionEditor = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Item").fontWeight(.light)
                Spacer()
                Text(itemName).bold()
            }
            HStack {
                Text("Payer").fontWeight(.light)
                Spacer()
                Text(payerName).bold()
            }
            Divider()
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text("Quantity: **\(share.realQuantity.roundedToTwoPlaces)**")
                        .foregroundStyle(isInvalid ? .red : .secondary)
                }
                if showsFractionEditor {
                    Text("Whole Number Part")
                        .font(.headline)
                }
                HStack {
                    Stepper("Count", value: $share.wholeNumberQuantity)
                    Text("\(share.wholeNumberQuantity)")
                        .font(.title2)
                        .foregroundStyle(share.isZero ? .red : .primary)
                        .frame(minWidth: 40)
                }
                if showsFractionEditor {
                    Text("Fractional Part")
                        .font(.headline)
                    VStack(spacing: 2) {
                        HStack {
                            Stepper("Numerator", value: $share.fractionPartNumerator)
                            Text("\(share.fractionPartNumerator)")
                                .font(.title2)
                                .foregroundStyle(share.isZero ? .red : .primary)
                                .frame(minWidth: 40)
                            
                        }
                        HStack {
                            Spacer()
                            Rectangle()
                                .padding(.horizontal, 6)
                                .frame(width: 40, height: 1)
                                .padding(.bottom, 2)
                        }
                        HStack {
                            Stepper("Denominator", value: $share.fractionPartDenominator)
                            Text("\(share.fractionPartDenominator)")
                                .foregroundStyle({
                                    switch share.fractionPartDenominator {
                                    case 0: Color.red
                                    case 1: Color.secondary
                                    default: Color.primary
                                    }
                                }())
                                .font(.title2)
                                .frame(minWidth: 40)
                        }
                    }
                }
                if !showsFractionEditor {
                    HStack {
                        Text("Quick Fractions")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("1/2") {
                            share.wholeNumberQuantity = 0
                            share.fractionPartNumerator = 1
                            share.fractionPartDenominator = 2
                        }
                        Button("1/3") {
                            share.wholeNumberQuantity = 0
                            share.fractionPartNumerator = 1
                            share.fractionPartDenominator = 3
                        }
                        Button("1/4") {
                            share.wholeNumberQuantity = 0
                            share.fractionPartNumerator = 1
                            share.fractionPartDenominator = 4
                        }
                    }
                    .padding(.top)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.primary)
                }
                Toggle("Show fraction editor", isOn: $showsFractionEditor)
            }
            .monospacedDigit()
            Spacer()
            Button("Done", action: dismissAction)
                .buttonStyle(.borderedProminent)
                .disabled(isInvalid)
                .keyboardShortcut(.return, modifiers: [])
            Button("Unassign", role: .destructive) {
                unassignAction()
                dismissAction()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .presentationBackground(.thinMaterial)
        .presentationDetents([.medium])
        .animation(.easeInOut, value: showsFractionEditor)
    }
}

private struct QuantityEditor_PreviewWrapper: View {
    @State private var share = Share(payerID: UUID(), itemID: UUID())
    
    var body: some View {
        QuantityEditorSheet(itemName: "TestItemName", payerName: "TestPayerName", share: $share) {} unassignAction: {}
    }
}

#Preview {
    QuantityEditor_PreviewWrapper()
}
