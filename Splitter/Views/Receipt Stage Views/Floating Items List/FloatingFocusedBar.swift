//
//  FloatingFocusedBar.swift
//  Splitter
//
//  Created by Vincent C. on 9/19/23.
//

import SwiftUI

struct FloatingFocusedBar: View {
    let item: Item.Initiation
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let currency: Currency
    let presentListSheetIfNeeded: () -> Void
    
    private func dismiss() {
        state = .minimized
        presentListSheetIfNeeded()
    }
    
    var body: some View {
        HStack {
            ItemPropertyField(item: item, fieldType: .name, state: $state)
            Spacer()
            ItemPropertyField(item: item, fieldType: .price(currency), state: $state)
            CancelButton(state: $state, dismiss: dismiss)
            ConfirmButton(item: item, items: $items, state: $state, dismiss: dismiss)
        }
    }
}

private struct CancelButton: View {
    @Binding var state: FloatingBarState
    let dismiss: () -> Void
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Label("Cancel", systemImage: "multiply.circle")
                .labelStyle(.iconOnly)
                .font(.title)
        }
        .keyboardShortcut(.escape, modifiers: [])
        .foregroundStyle(.primary)
    }
}

private struct ConfirmButton: View {
    let item: Item.Initiation
    @Binding var items: [Item]
    @Binding var state: FloatingBarState
    let dismiss: () -> Void
    
    var body: some View {
        if let completedItem = Item(from: item) {
            Button {
                if let replacementIndex = item.replacementIndex {
                    items[replacementIndex] = completedItem
                    dismiss()
                } else {
                    items.append(completedItem)
                    dismiss()
                }
            } label: {
                Label("Confirm", systemImage: "checkmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
            .keyboardShortcut(.return, modifiers: [])
        } else {
            Button {} label: {
                Label("Confirm", systemImage: "checkmark.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.title)
            }
            .disabled(true)
        }
    }
}

#Preview {
    StageSwitcherView(flowState: .sampleData)
}
